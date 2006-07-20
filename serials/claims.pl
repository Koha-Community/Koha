#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Serials;
use C4::Acquisition;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;
use Data::Dumper;

my $query = new CGI;

my $serialid = $query->param('serialid');
my $op = $query->param('op');
my $claimletter = $query->param('claimletter');
my $supplierid = $query->param('supplierid');
my %supplierlist = GetSuppliersWithLateIssues;
my @select_supplier;

foreach my $supplierid (keys %supplierlist){
        my ($count, @dummy) = GetMissingIssues($supplierid);
        my $counting = $count;
        $supplierlist{$supplierid} = $supplierlist{$supplierid}." ($counting)";
	push @select_supplier, $supplierid
}

my @select_letter = (1,2,3,4);
my %letters = (1=>'Claim Form 1',2=>'Claim Form 2',3=>'Claim Form 3',4=>'Claim Form 4');
my ($count2, @missingissues) = GetMissingIssues($supplierid,$serialid);

my $CGIsupplier=CGI::scrolling_list( -name     => 'supplierid',
			-values   => \@select_supplier,
			-default  => $supplierid,
			-labels   => \%supplierlist,
			-size     => 1,
			-multiple => 0 );

my $CGIletter=CGI::scrolling_list( -name     => 'claimletter',
			-values   => \@select_letter,
			-default  => $claimletter,
			-labels   => \%letters,
			-size     => 1,
			-multiple => 0 );
my ($singlesupplier,@supplierinfo);
if($supplierid){
   ($singlesupplier,@supplierinfo)=bookseller($supplierid);
} else { # set up supplierid for the claim links out of main table if all suppliers is chosen
   for(my $i=0; $i<@missingissues;$i++){
       $missingissues[$i]->{'supplierid'} = getsupplierbyserialid($missingissues[$i]->{'serialid'});
   }
}


my $preview=0;
if($op eq 'preview'){
    $preview = 1;
}

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "serials/claims.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

$template->param(
	CGIsupplier => $CGIsupplier,
    	CGIletter => $CGIletter,
        preview => $preview,
        missingissues => \@missingissues,
        supplierid => $supplierid,
        claimletter => $claimletter,
        singlesupplier => $singlesupplier,
        supplierloop => \@supplierinfo,
	intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
	);
output_html_with_http_headers $query, $cookie, $template->output;
