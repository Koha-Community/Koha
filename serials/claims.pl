#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Output;
use C4::Bookseller;
use C4::Context;
use C4::Letters;
my $input = new CGI;

my $serialid = $input->param('serialid');
my $op = $input->param('op');
my $claimletter = $input->param('claimletter');
my $supplierid = $input->param('supplierid');
my $suppliername = $input->param('suppliername');
my $order = $input->param('order');
my $supplierlist = GetSuppliersWithLateIssues;

# open template first (security & userenv set here)
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/claims.tmpl",
            query => $input,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => {serials => 1},
            debug => 1,
            });

for my $supplier ( @{$supplierlist} ) {
        my @dummy = GetLateOrMissingIssues($supplier->{id},q{},$order);
        my $counting = scalar @dummy;
        $supplier->{name} .= " ($counting)";
        if ($supplierid && $supplierid == $supplier->{id}) {
            $supplier->{selected} = 1;
        }
}

my $letters = GetLetters('claimissues');
my @letters;
foreach (keys %{$letters}){
    push @letters ,{code=>$_,name=> $letters->{$_}};
}

my $letter=((scalar(@letters)>1) || ($letters[0]->{name}||$letters[0]->{code}));
my  @missingissues;
if ($supplierid) {
    @missingissues = GetLateOrMissingIssues($supplierid,$serialid,$order);
}

my ($singlesupplier,@supplierinfo);
if($supplierid){
   (@supplierinfo)=GetBookSeller($supplierid);
} else { # set up supplierid for the claim links out of main table if all suppliers is chosen
   for my $mi (@missingissues){
       $mi->{supplierid} = getsupplierbyserialid($mi->{serialid});
   }
}

my $preview=0;
if($op && $op eq 'preview'){
    $preview = 1;
} else {
    my @serialnums=$input->param('serialid');
    if (@serialnums) { # i.e. they have been flagged to generate claims
        SendAlerts('claimissues',\@serialnums,$input->param("letter_code"));
        my $cntupdate=UpdateClaimdateIssues(\@serialnums);
        ### $cntupdate SHOULD be equal to scalar(@$serialnums)
    }
}
$template->param('letters'=>\@letters,'letter'=>$letter);
$template->param(
        order =>$order,
        supplier_loop => $supplierlist,
        phone => $supplierinfo[0]->{phone},
        booksellerfax => $supplierinfo[0]->{booksellerfax},
        bookselleremail => $supplierinfo[0]->{bookselleremail},
        preview => $preview,
        missingissues => \@missingissues,
        supplierid => $supplierid,
        claimletter => $claimletter,
        singlesupplier => $singlesupplier,
        supplierloop => \@supplierinfo,
        dateformat    => C4::Context->preference("dateformat"),
    	DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
        );
output_html_with_http_headers $input, $cookie, $template->output;
