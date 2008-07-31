#!/usr/bin/perl

use strict;
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
my $order = $input->param('order');
my %supplierlist = GetSuppliersWithLateIssues;
my @select_supplier;

# open template first (security & userenv set here)
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/claims.tmpl",
            query => $input,
            type => "intranet",
            authnotrequired => 0,
            flagsrequired => {serials => 1},
            debug => 1,
            });

foreach my $supplierid (sort {$supplierlist{$a} cmp $supplierlist{$b} } keys %supplierlist){
        my ($count, @dummy) = GetLateOrMissingIssues($supplierid,"",$order);
        my $counting = $count;
        $supplierlist{$supplierid} = $supplierlist{$supplierid}." ($counting)";
	push @select_supplier, $supplierid
}

my $letters = GetLetters("claimissues");
my @letters;
foreach (keys %$letters){
    push @letters ,{code=>$_,name=> $letters->{$_}};
}

my $letter=((scalar(@letters)>1) || ($letters[0]->{name}||$letters[0]->{code}));
my ($count2, @missingissues) = GetLateOrMissingIssues($supplierid,$serialid,$order) if $supplierid;

my $CGIsupplier=CGI::scrolling_list( -name     => 'supplierid',
			-id        => 'supplierid',
			-values   => \@select_supplier,
			-default  => $supplierid,
			-labels   => \%supplierlist,
			-size     => 1,
			-multiple => 0 );

my ($singlesupplier,@supplierinfo);
if($supplierid){
   (@supplierinfo)=GetBookSeller($supplierid);
} else { # set up supplierid for the claim links out of main table if all suppliers is chosen
   for(my $i=0; $i<@missingissues;$i++){
       $missingissues[$i]->{'supplierid'} = getsupplierbyserialid($missingissues[$i]->{'serialid'});
   }
}

my $preview=0;
if($op eq 'preview'){
    $preview = 1;
}

if ($op eq "send_alert"){
  my @serialnums=$input->param("serialid");
  SendAlerts('claimissues',\@serialnums,$input->param("letter_code"));
  my $cntupdate=UpdateClaimdateIssues(\@serialnums);
  ### $cntupdate SHOULD be equal to scalar(@$serialnums)
}

$template->param('letters'=>\@letters,'letter'=>$letter);
$template->param(
        order =>$order,
        CGIsupplier => $CGIsupplier,
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
        );
output_html_with_http_headers $input, $cookie, $template->output;
