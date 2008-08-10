#!/usr/bin/perl
# code modified by Trendsetters (from original circulation.pl)
# Please use 8-character tabs for this file (indents are every 4 characters)
#
#  rychi edit: we're just trying to issue some books. 'Trendsetters' code mostly deleted.
#    Note:  This is incomplete; implemented for a library that trusts its users and  has no fines;
#    as such, there are some circ functions that are missing and tests that are skipped.
#    
#    The issuer is a special user
#  with borrowerflag 'selfcheck' set.  The borrower has been authenticated.
#  We're going to post a barcode with a form, and check that barcode for issuability.
#  If it's issuable, we issue it.  If there's an error, we call a popup.
#

# Copyright  2006 
# # This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use CGI;
use C4::Circulation;
use C4::Search;
use DBI;
use C4::Auth;
use C4::Output;
use C4::Koha;
use HTML::Template::Pro;
use C4::Dates;

my $query=new CGI;

#my ($loggedinuser, $sessioncookie, $sessionID) = checkauth
#	($query, 0, { circulate => 1 });
#  loggedinuser is the 'selfchaeckout user'.
my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name	=> 'sco/sco-circ.tmpl',
	query		=> $query,
	type		=> "opac",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $issuerid = $loggedinuser;
my ( $userid, $op, $barcode, $confirmed )= $query->param("userid", "op", "barcode", "confirmed" );
my $env ;
my %confirmation_strings = ( RENEW_ISSUE => "This item is already checked out to you.  Renew it?", );
my $cnt = 0;

my ($issuer, $flags) = getpatroninformation(undef,undef, $issuerid);
my $item = getiteminformation(undef,undef,$barcode);

if ($op eq "finish") {
	$query->param( userid => undef );
} elsif ($userid) {  

   my $env = {branchcode =>  $issuer->{'branchcode'} }; 
   warn "here's the branchcode: ".$issuer->{branchcode};
   my ($borrower, $flags) = getpatroninformation(undef,undef, $userid);
   my $bornum = $borrower->{borrowernumber};
   
   my $borrowerissues = [];
   my $issues = currentissues( $env, $borrower);
   
   foreach (%$issues) {
   	$borrowerissues->[$cnt]->{issued} = $_ ;
	$cnt++;
   }
   $cnt=0;
   $template->param( OVERDUES => $borrower->{ODUES} ,
   			ISSUES => $borrowerissues,
			);

   if ($op eq "checkout" ) {
      my ($impossible,$needconfirm) = canbookbeissued(undef,$borrower,$barcode);
      if ($impossible) {
         my ($issue_error) = keys %$impossible ;
         $template->param( impossible => $issue_error );
      } elsif ($needconfirm->{RENEW_ISSUE} ) {
      	  if ( $confirmed ) {
            renewbook($env,$bornum,$item->{itemnumber},"");
          } else {
	   $template->param( confirm => $confirmation_strings{RENEW_ISSUE} );
          }
      } elsif ($needconfirm && !$confirmed ) {
         my ($confirmation) = keys %$needconfirm ;      
	 $template->param( impossible => $confirmation );
      } else {
         issuebook($env,$bornum,$barcode,"");
      }

#getiteminformation(undef,undef,$item);

   } else {

}
			
# reload the borrower info for the sake of reseting the flags.....
#	if ($borrowernumber) {
#		($borrower, $flags) = getpatroninformation(\%env,$borrowernumber,0);
#	}
} else {
	$template->param( noauth => 1, );
}

output_html_with_http_headers $query, $cookie, $template->output;


#sub patrontable {
#    my ($borrower) = @_;
#    my $flags = $borrower->{'flags'};
#    my $flaginfotable='';
#    my $flaginfotext;
#    #my $flaginfotext='';
#    my $flag;
#    my $color='';
#    foreach $flag (sort keys %$flags) {
#    	warn $flag;
##    	my @itemswaiting='';
#	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
#	$flags->{$flag}->{'message'}=~s/\n/<br>/g;
#	if ($flags->{$flag}->{'noissues'}) {
#		$template->param(
#			noissues => 'true',
#			color => $color,
#			 );
#		if ($flag eq 'GNA'){
#			$template->param(
#				gna => 'true'
#				);
#			}
#		if ($flag eq 'LOST'){
#			$template->param(
#				lost => 'true'
#			);
#			}
#		if ($flag eq 'DBARRED'){
#			$template->param(
#				dbarred => 'true'
#			);
#			}
#		if ($flag eq 'CHARGES') {
#			$template->param(
#				charges => 'true',
#				chargesmsg => $flags->{'CHARGES'}->{'message'}
#				 );
#		}
#	} else {
#		 if ($flag eq 'CHARGES') {
#			$template->param(
#				charges => 'true',
#				chargesmsg => $flags->{'CHARGES'}->{'message'}
#			 );
#		}
#	    	if ($flag eq 'WAITING') {
#			my $items=$flags->{$flag}->{'itemlist'};
#		        my @itemswaiting;
#			foreach my $item (@$items) {
#			my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
#			$iteminformation->{'branchname'} = $branches->{$iteminformation->{'holdingbranch'}}->{'branchname'};
#			push @itemswaiting, $iteminformation;
#			}
#			$template->param(
#				waiting => 'true',
#				waitingmsg => $flags->{'WAITING'}->{'message'},
#				itemswaiting => \@itemswaiting,
#				 );
#		}
#		if ($flag eq 'ODUES') {
#			$template->param(
#				odues => 'true',
#				oduesmsg => $flags->{'ODUES'}->{'message'}
#				 );
#
#			my $items=$flags->{$flag}->{'itemlist'};
#			my $currentcolor=$color;
#			{
#			my $color=$currentcolor;
#			    my @itemswaiting;
#			foreach my $item (@$items) {
#				($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
#				my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
#				push @itemswaiting, $iteminformation;
#			}
#			}
#			if ($query->param('module') ne 'returns'){
#				$template->param( nonreturns => 'true' );
#			}
#		}
#		if ($flag eq 'NOTES') {
#			$template->param(
#				notes => 'true',
#				notesmsg => $flags->{'NOTES'}->{'message'}
#				 );
#		}
#	}
#    }
#    return($patrontable, $flaginfotext);
#}

