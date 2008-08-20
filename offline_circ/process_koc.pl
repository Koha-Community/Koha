#!/usr/bin/perl

# 2008 Kyle Hall <kyle.m.hall@gmail.com>

# This file is part of Koha.
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
#

use strict;
require Exporter;

use CGI;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Biblio;
use C4::Accounts;
use C4::Circulation;
use C4::Members;
use C4::Stats;

use Date::Calc qw( Add_Delta_Days Date_to_Days );

use constant DEBUG => 0;

our $query = new CGI;

my ($template, $loggedinuser, $cookie)
  = get_template_and_user( { template_name => "offline_circ/process_koc.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 1,
				debug => 1,
				});

## 'Local' globals.
our $dbh = C4::Context->dbh();

our $branchcode = C4::Context->userenv->{branch};

warn "Branchcode: $branchcode";

our @output; ## For storing messages to be displayed to the user

$query::POST_MAX = 1024 * 10000;

my $file = $query->param("kocfile");
$file=~m/^.*(\\|\/)(.*)/; # strip the remote path and keep the filename 
my $name = $file; 

my $header = <$file>;

while ( my $line = <$file> ) {
  my ( $type, $cardnumber, $barcode, $datetime ) = split( /\t/, $line );
  ( $datetime ) = split( /\+/, $datetime );
  my ( $date ) = split( / /, $datetime );

  my $circ;
  $circ->{ 'type' } = $type;
  $circ->{ 'cardnumber' } = $cardnumber;
  $circ->{ 'barcode' } = $barcode;
  $circ->{ 'datetime' } = $datetime;
  $circ->{ 'date' } = $date;
  
  if ( $circ->{ 'type' } eq 'issue' ) {
    kocIssueItem( $circ, $branchcode );
  } elsif ( $circ->{ 'type' } eq 'return' ) {
    kocReturnItem( $circ );
  } elsif ( $circ->{ 'type' } eq 'payment' ) {
    kocMakePayment( $circ );
  }
}

$template->param(
		intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),

                messages => \@output,
	);
output_html_with_http_headers $query, $cookie, $template->output;

sub kocIssueItem {
  my ( $circ, $branchcode ) = @_;

  my $borrower = GetMember( $circ->{ 'cardnumber' }, 'cardnumber' );
  my $item = GetBiblioFromItemNumber( undef, $circ->{ 'barcode' } );
  my $issue = GetItemIssue( $item->{'itemnumber'} );

  my $issuingrule = GetIssuingRule( $borrower->{ 'categorycode' }, $item->{ 'itemtype' }, $branchcode );
  my $issuelength = $issuingrule->{ 'issuelength' };
  my ( $year, $month, $day ) = split( /-/, $circ->{'date'} );
  ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, $issuelength );
  my $date_due = "$year-$month-$day";
  
  if ( $issue->{ 'date_due' } ) { ## Item is currently checked out to another person.
warn "Item Currently Issued.";
    my $issue = GetOpenIssue( $item->{'itemnumber'} );

    if ( $issue->{'borrowernumber'} eq $borrower->{'borrowernumber'} ) { ## Issued to this person already, renew it.
warn "Item issued to this member already, renewing.";
    
      my $renewals = $issue->{'renewals'} + 1;
      ForceRenewal( $item->{'itemnumber'}, $circ->{'date'}, $date_due ) unless ( DEBUG );

      push( @output, { message => "Renewed $item->{ 'title' } ( $item->{ 'barcode' } ) to $borrower->{ 'firstname' } $borrower->{ 'surename' } ( $borrower->{'cardnumber'} ) : $circ->{ 'datetime' }\n" } );

    } else { 
warn "Item issued to a different member.";
warn "Date of previous issue: $issue->{'issuedate'}";
warn "Date of this issue: $circ->{'date'}";
      my ( $i_y, $i_m, $i_d ) = split( /-/, $issue->{'issuedate'} );
      my ( $c_y, $c_m, $c_d ) = split( /-/, $circ->{'date'} );
      
      if ( Date_to_Days( $i_y, $i_m, $i_d ) < Date_to_Days( $c_y, $c_m, $c_d ) ) { ## Current issue to a different persion is older than this issue, return and issue.
warn "Current issue to another member is older, returning and issuing";
        push( @output, { message => "$item->{ 'title' } ( $item->{'barcode'} ) currently issued, returning item.\n" } );
        ## AddReturnk() should be replaced with a custom function, as it will make the return date today, should be before the issue date of the current circ
        AddReturn( $circ->{ 'barcode' }, $branchcode ) unless ( DEBUG );

        ForceIssue( $borrower->{ 'borrowernumber' }, $item->{ 'itemnumber' }, $date_due, $branchcode, $circ->{'date'} ) unless ( DEBUG );

        push( @output, { message => "Issued $item->{ 'title' } ( $item->{ 'barcode' } ) to $borrower->{ 'firstname' } $borrower->{ 'surename' } ( $borrower->{'cardnumber'} ) : $circ->{ 'datetime' }\n" } );

      } else { ## Current issue is *newer* than this issue, write a 'returned' issue, as the item is most likely in the hands of someone else now.
warn "Current issue to another member is newer. Doing nothing";
        ## This situation should only happen of the Offline Circ data is *really* old.
        ## FIXME: write line to old_issues and statistics
      }
    
    }
  } else { ## Item is not checked out to anyone at the moment, go ahead and issue it
    ForceIssue( $borrower->{ 'borrowernumber' }, $item->{ 'itemnumber' }, $date_due, $branchcode, $circ->{'date'} ) unless ( DEBUG );
    push( @output, { message => "Issued $item->{ 'title' } ( $item->{ 'barcode' } ) to $borrower->{ 'firstname' } $borrower->{ 'surename' } ( $borrower->{'cardnumber'} ) : $circ->{ 'datetime' }\n" } );
  }  
}

sub kocReturnItem {
  my ( $circ ) = @_;
  ForceReturn( $circ->{'barcode'}, $circ->{'date'}, $branchcode );
  
  my $item = GetBiblioFromItemNumber( undef, $circ->{'barcode'} );
  
  ## FIXME: Is there a way to get the borrower of an item through the Koha API?
  my $sth=$dbh->prepare( "SELECT borrowernumber FROM issues WHERE itemnumber = ? AND returndate IS NULL");
  $sth->execute( $item->{'itemnumber'} );
  my ( $borrowernumber ) = $sth->fetchrow;
  $sth->finish();

  push( @output, { message => "Returned $item->{ 'title' } ( $item->{ 'barcode' } ) From borrower number $borrowernumber : $circ->{ 'datetime' }\n" } ); 
}

sub kocMakePayment {
  my ( $circ ) = @_;
  my $borrower = GetMember( $circ->{ 'cardnumber' }, 'cardnumber' );
  recordpayment( my $env, $borrower->{'borrowernumber'}, $circ->{'barcode'} );
}

