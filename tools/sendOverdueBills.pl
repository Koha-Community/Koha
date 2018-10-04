#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2016 Observis Oy
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use CGI qw(:standard);
use CGI::Carp;

use C4::Auth qw/:DEFAULT get_session/;
use C4::Members;
use C4::Output;
use C4::Context;
use C4::KohaSuomi::Billing::BillingManager;
use C4::KohaSuomi::Billing::SapErp;
use C4::KohaSuomi::Billing::PDFBill;

use Koha::DateUtils;
use DateTime;
use DateTime::Format::MySQL;
use POSIX;
use constant ITEM_ADD_FINE => 5.00; #Add fine per item. Predefined;

use Data::Dumper;

#Variable declarations
my $input = CGI->new;
my $dbh = C4::Context->dbh;

my $i = 0; # This variable is used as rowcounter

my $page = $input->param('page');
my $totalpages = $input->param('totalpages');
my $results = $input->param('results');
my $showall = $input->param('showall'); # Boolean 1 or 0
my $showbilled = $input->param('showbilled'); # Boolean 1 or 0
my $shownotbilled = $input->param('shownotbilled'); # Boolean 1 or 0
my $bypatron = $input->param('bypatron'); # Boolean 1 or 0
my $group = $input->param('group'); # Boolean 1 or 0
my $send = $input->param('send');
my $msg; #Variable for messages;
my $branch;

#Selecting template
my ($template, $loggedinuser, $cookie) = get_template_and_user({
                        template_name => "tools/sendOverdueBills.tt",
                        type => "intranet",
                        query => $input,
                        authnotrequired => 0,
                        flagsrequired   => { tools => 'edit_notices' },
                        debug           => 1,
    }
);

if($page < 1 || $page == ""){
	$page = 1;
}

if($results < 10 || $results > 100 || $results == ""){
	$results = 10;
}

my @paramdata; #Array for storing form parameters and values
my @overduedata; #Array for storing data from database
my $resultnumber = ($page-1)*$results;


$branch = $input->param('branch') || C4::Context->userenv->{branch};

my $branchloop = Koha::Libraries->search({}, { order_by => ['branchname'] })->unblessed;
for my $library ( @$branchloop ) {
    $library->{selected} = 1 if $library->{branchcode} eq $branch
}

my $account = GetBranchBillingAccount($branch);

my $branchcategory = CheckBillCategory($branch);

#Form handling
if($send){
	my %form;
	#Row numbers starts from 1!
	for(my $j=1;$j<=100;$j++){

		if(defined param('issue_id_'.$j)){

		$form{'borrowernumber'} = param('borrowernumber_'.$j);
            $form{'issue_id'} = param('issue_id_'.$j);
            $form{'duedate'} = param('duedate_'.$j);
            $form{'surname'} = param('surname_'.$j);
            $form{'firstname'} = param('firstname_'.$j);
            $form{'dateofbirth'} = param('dateofbirth_'.$j);
            $form{'address'} = param('address_'.$j);
            $form{'zipcode'} = param('zipcode_'.$j);
            $form{'city'} = param('city_'.$j);
            $form{'itemnum'} = param('itemnum_'.$j);
            $form{'title'} = param('title_'.$j);

			#If there is "," in replacementprice as decimal separator, replace it with "."
			my $replacementprice = param('replacementprice_'.$j);
			my $position = index($replacementprice, ",");
			if($position > -1){
				$replacementprice = substr($replacementprice, $position, ".");
			}

			#Calculate total price
			my $totalprice = $replacementprice;

			$form{'replacementprice'} = $totalprice;
			$form{'fine'} = param('fine_'.$j).'.00';
			$form{'billingdate'} = param('billingdate_'.$j);

            my $overdue_price = OverduePrice($form{'itemnum'});

			push @paramdata, {

				borrowernumber => $form{'borrowernumber'},
				issue_id => $form{'issue_id'},
				duedate => $form{'duedate'},
				surname => $form{'surname'},
				firstname => $form{'firstname'},
				dateofbirth => $form{'dateofbirth'},
				address => $form{'address'},
				zipcode => $form{'zipcode'},
				city => $form{'city'},
				title => $form{'title'},
				replacementprice => $form{'replacementprice'},
				fine => $form{'fine'},
				billingdate => $form{'billingdate'},
                itemnumber => $form{'itemnum'},
                plastic => ITEM_ADD_FINE.'.00',
                overdue_price => $overdue_price,
                branchcode => $branch

			};
		}
	}

	my $senddata;
    my $propertymissing;

	if(@paramdata > 0){
        if ($account eq 'SAPERP') {
            $senddata = C4::KohaSuomi::Billing::SapErp::send_xml(@paramdata);
        } elsif ($account eq 'PDFBILL'){
            $senddata = C4::KohaSuomi::Billing::PDFBill::create_pdf(@paramdata);
        } else {
            $propertymissing = "Can't find billing interface. Library has to have billing group property. Set it in basic parameters. There is available two interface, SAPERP or PDFBILL";
        }


	}


	# If send_xml returns 1 (on success)...
	if($senddata == 1){

		foreach my $keydata (@paramdata){

			if($keydata->{billingdate} eq ""){
                ModOverdueBills('insert', $keydata->{issue_id});
			}
			else{
				ModOverdueBills('update', $keydata->{issue_id});
			}
		}
	}
	else{
            if ($propertymissing) {
                $msg = $propertymissing;
            } else {
                if ($senddata) {
                    $msg = $senddata;
                } else {
                    $msg = "Can't send billing data. Select overdue items and try again to send bills.";
                }

            }
		}
}

#Getting data from database
my $issues;

my $delay = CheckOverduerules($branch);

if($showall == 1){
    $issues = GetOverduedIssues($branch, $resultnumber, $results, $delay, $showall, $showbilled, $shownotbilled, $bypatron, $group, $branchcategory);
}
else{
    $issues = GetOverduedIssues($branch, $resultnumber, $results, $delay, $showall, $showbilled, $shownotbilled, $bypatron, $group, $branchcategory);
}

foreach my $data (@{$issues}) {

	$i++;

	my $dt = dt_from_string($data->{date_due});
	my $billingdt = "";
	my $birthdt = "";
    my $bdate;
	my $borrowernumber = $data->{borrowernumber};

	if(defined $data->{billingdate} && $data->{billingdate} ne ""){
		$billingdt = output_pref(dt_from_string($data->{billingdate}));
        my ($y, $m, $d) = $data->{billingdate}=~ /^(\d\d\d\d)-(\d\d)-(\d\d)/;
        $bdate = $y."-".$m."-".$d;
	}

	if($data->{dateofbirth} ne ""){
		$birthdt = output_pref(dt_from_string($data->{dateofbirth}));
	}

	if($data->{borrowernumber} eq ""){
		$borrowernumber = "0";
	}

    push @overduedata, {
	duedate                	=> output_pref($dt),
	dateofbirth				=> $birthdt,
        borrowernumber         	=> $borrowernumber,
        barcode                	=> $data->{barcode},
        itemnum                	=> $data->{itemnumber},
        surname                	=> $data->{surname},
        firstname              	=> $data->{firstname},
        address                	=> $data->{address},
        city                   	=> $data->{city},
        zipcode                	=> $data->{zipcode},
        phone                  	=> $data->{phone},
        email                  	=> $data->{email},
        biblionumber           	=> $data->{biblionumber},
        title                  	=> $data->{title},
        author                 	=> $data->{author},
        copyrightdate			=> $data->{copyrightdate},
        replacementprice       	=> $data->{replacementprice},
        fine			       	=> $delay->{delayfine},
        rowcount              	=> $i,
        issue_id             	=> $data->{issue_id},
        billingdate             => $billingdt,
        gfirstname              => $data->{gfirstname},
        gsurname                => $data->{gsurname},
        guarantorid             => $data->{guarantorid},
        gphone                  => $data->{gphone},
        gemail                  => $data->{gemail},
        gmobile                 => $data->{gmobile},
        gphonepro               => $data->{gphonepro},
        gaddress                => $data->{gaddress},
        gcity                   => $data->{gcity},
        gzipcode                => $data->{gzipcode},
        bdate                   => $bdate,
        ssnkey					=> $data->{ssnkey}
    };
}

#Getting max page number
if ($totalpages == 0 || !$totalpages) {

    my $totalcount = GetTotalPages($branch, $showall, $showbilled, $shownotbilled, $delay, $group, $branchcategory);
	$totalpages = POSIX::ceil($totalcount/$results); # Max page number
}

if(@overduedata <= 0){
	$msg = "There are no overdue items to show for billing.
	<ol>
	<li>Make sure that there is a value defined for Delay and Fine for library branches beginning with $branch at least for 'HENKILO' or 'LAPSI' in second tab of
	<a href='/cgi-bin/koha/tools/overduerules.pl'>Overdue notice/status triggers</a> page.</li>
	<li>Wait for redirection or refresh this page.</li>
	</ol>";
}

my $now = strftime "%Y-%m-%d", localtime;

#Passing variables to template as parameters
$template->param(
overdueloop => \@overduedata,
branchloop => $branchloop,
rowcount => $i,
page => $page,
sqlrows => $totalpages,
results => $results,
showall => $showall,
showbilled => $showbilled,
shownotbilled => $shownotbilled,
bypatron => $bypatron,
group => $group,
branch => $branch,
msg => $msg,
date => $now,
account => $account,
branchcategory => $branchcategory
);

output_html_with_http_headers($input, $cookie, $template->output);