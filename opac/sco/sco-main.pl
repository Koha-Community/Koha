#!/usr/bin/perl
# This code has been modified by Trendsetters (originally from opac-user.pl)
# This code has been modified by rch
# We're going to authenticate a self-check user.  we'll add a flag to borrowers 'selfcheck'
# We're in a controlled environment; we trust the user. so the selfcheck station will accept a patronid and 
# issue items to that borrower.
#
use strict;
use warnings;

use CGI;

#use C4::Authsco;
use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Reserves;
use C4::Search;
use C4::Output;
use C4::Members;
use HTML::Template::Pro;
use C4::Dates;
use C4::Biblio;
use C4::Items;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "sco/sco-main.tmpl",
                             query => $query,
                             type => "opac",
                             authnotrequired => 0,
                             flagsrequired => { circulate => 1 },
                             debug => 1,
                             });
my $dbh = C4::Context->dbh;

my $issuerid = $loggedinuser;
my ($op, $patronid, $barcode, $confirmed, $timedout) = (
    $query->param("op")         || '',
    $query->param("patronid")   || '',
    $query->param("barcode")    || '',
    $query->param( "confirmed") || '',
    $query->param( "timedout")  || '', #not actually using this...
);

my %confirmation_strings = ( RENEW_ISSUE => "This item is already checked out to you.  Return it?", );
my $issuenoconfirm = 1; #don't need to confirm on issue.
my $cnt = 0;
#warn "issuerid: " . $issuerid;
my ($issuer) = GetMemberDetails($issuerid);
my $item = GetItem(undef,$barcode);
my $borrower;
($borrower) = GetMemberDetails(undef,$patronid);

my $branch = $issuer->{branchcode};
my $confirm_required = 0;
my $return_only = 0;
#warn "issuer cardnum: " . $issuer->{cardnumber};
#warn "cardnumber= ".$borrower->{cardnumber};
if ($op eq "logout") {
        $query->param( patronid => undef );
}
  if ($op eq "returnbook") {
      my ($doreturn ) = AddReturn($barcode, $branch);
     #warn "returnbook: " . $doreturn;
    ($borrower) = GetMemberDetails(undef, $patronid);
  }
  
  if ($op eq "checkout" ) {
	my $impossible = {};
	my $needconfirm = {};
      if ( !$confirmed ) {
	 ($impossible,$needconfirm) = CanBookBeIssued($borrower,$barcode);
      }
	$confirm_required = scalar(keys(%$needconfirm));
	#warn "confirm_required: " . $confirm_required ;
	if (scalar(keys(%$impossible))) {
    #  warn "impossible: numkeys: " . scalar (keys(%$impossible));
         my ($issue_error) = keys %$impossible ;
         # FIXME  we assume only one error.
	 $template->param( impossible => $issue_error,
	 		title => $item->{title} ,
			hide_main => 1,
			);
	#warn "issue_error: " . $issue_error ;
	if ($issue_error eq "NO_MORE_RENEWALS") {
	 	$return_only = 1;
		$template->param ( returnitem => 1,
				barcode => $barcode ,
				);
	 }
      } elsif ($needconfirm->{RENEW_ISSUE} ) {
          if ( $confirmed ) {
	  #warn "renewing";
            AddRenewal($borrower,$item->{itemnumber});
          } else {
	  #warn "renew confirmation";
           $template->param( renew => 1,
	   		barcode => $barcode,
            confirm => 1,
            confirm_renew_issue => 1,
	 		hide_main => 1,
			);
          }
      } elsif ( $confirm_required && !$confirmed ) {
      #warn "failed confirmation";
         my ($confirmation) = keys %$needconfirm ;
         $template->param( impossible => $confirmation,
	 		hide_main => 1,
	 		);
      } else {
	 if ( $confirmed || $issuenoconfirm ) {  # we'll want to call getpatroninfo again to get updated issues.
      	    #warn "issuing book?";
            AddIssue($borrower,$barcode);
	#    ($borrower, $flags) = getpatroninformation(undef,undef, $patronid);
		
       #    $template->param( patronid => $patronid,
#			validuser => 1,
#			);
         } else {
           $confirm_required = 1;
	   #warn "issue confirmation";
           $template->param( confirm => "Issuing title: " . $item->{title} ,
			barcode => $barcode,
			hide_main => 1,
			inputfocus => 'confirm',
			);
	}
      }
   } # op=checkout

if ($borrower->{cardnumber}) {

#   warn "here's the issuer's  branchcode: ".$issuer->{branchcode};
#   warn "here's the user's  branchcode: ".$borrower->{branchcode};
	my $bornum = $borrower->{borrowernumber};
	my $borrowername = $borrower->{firstname} . " " . $borrower->{surname};
	my @issues;
	my ($countissues,$issueslist) = GetPendingIssues($borrower->{'borrowernumber'});
	foreach my $it ( @$issueslist ) {
		push @issues, $it;
		$cnt++;
	}
   $template->param(  validuser => 1,  
   			borrowername => $borrowername,
			issues_count => $cnt, 
			ISSUES => \@issues,,
			patronid => $patronid ,
			noitemlinks => 1 ,
		);
   $cnt = 0;
   my $inputfocus;
   if ($return_only ==1) {
      $inputfocus = 'returnbook' ;
   }elsif ($confirm_required == 1) {
      $inputfocus = 'confirm' ;
   } else {
      $inputfocus = 'barcode' ;
    }

$template->param( inputfocus => $inputfocus,
		nofines => 1,
		);

} else {

 $template->param( patronid => $patronid,  nouser => $patronid,
 			inputfocus => 'patronid', );
}

output_html_with_http_headers $query, $cookie, $template->output;
