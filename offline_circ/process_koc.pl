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

# this is the file version number that we're coded against.
my $FILE_VERSION = '1.0';

our $query = CGI->new;

my ($template, $loggedinuser, $cookie)
  = get_template_and_user( { template_name => "offline_circ/process_koc.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 1,
				debug => 1,
				});

## 'Local' globals.
our $dbh = C4::Context->dbh();
our @output; ## For storing messages to be displayed to the user

$query::POST_MAX = 1024 * 10000;
my $file = $query->param("kocfile");
$file=~m/^.*(\\|\/)(.*)/; # strip the remote path and keep the filename 

my $header_line = <$file>;
my $file_info   = parse_header_line($header_line);
if ($file_info->{'Version'} ne $FILE_VERSION) {
    push( @output, { message => "Warning: This file is version '$file_info->{'Version'}', but I only know how to import version '$FILE_VERSION'. I'll try my best." } );
}


while ( my $line = <$file> ) {

    # my ( $date, $time, $command, @arguments ) = parse_command_line( $line );
    my $command_line = parse_command_line($line);

    # map command names in the file to subroutine names
    my %dispatch_table = (
        issue   => \&kocIssueItem,
        return  => \&kocReturnItem,
        payment => \&kocMakePayment,
    );

    # call the right sub name, passing the hashref of command_line to it.
    if ( exists $dispatch_table{ $command_line->{'command'} } ) {
        $dispatch_table{ $command_line->{'command'} }->($command_line);
    } else {
        warn "unknown command: '$command_line->{command}' not processed";
    }

}

$template->param(
		intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),

                messages => \@output,
	);
output_html_with_http_headers $query, $cookie, $template->output;

=head3 parse_header_line

parses the header line from a .koc file. This is the line that
specifies things such as the file version, and the name and version of
the offline circulation tool that generated the file. See
L<http://wiki.koha.org/doku.php?id=koha_offline_circulation_file_format>
for more information.

pass in a string containing the header line (the first line from th
file).

returns a hashref containing the information from the header.

=cut

sub parse_header_line {
    my $header_line = shift;
    chomp($header_line);

    my @fields = split( /\t/, $header_line );
    my %header_info = map { split( /=/, $_ ) } @fields;
    return \%header_info;
}

=head3 parse_command_line

=cut

sub parse_command_line {
    my $command_line = shift;
    chomp($command_line);

    my ( $timestamp, $command, @args ) = split( /\t/, $command_line );
    my ( $date,      $time,    $id )   = split( /\s/, $timestamp );

    my %command = (
        date    => $date,
        time    => $time,
        id      => $id,
        command => $command,
    );

    # set the rest of the keys using a hash slice
    my $argument_names = arguments_for_command($command);
    @command{@$argument_names} = @args;

    return \%command;

}

=head3 arguments_for_command

fetches the names of the columns (and function arguments) found in the
.koc file for a particular command name. For instance, the C<issue>
command requires a C<cardnumber> and C<barcode>. In that case this
function returns a reference to the list C<qw( cardnumber barcode )>.

parameters: the command name

returns: listref of column names.

=cut

sub arguments_for_command {
    my $command = shift;

    # define the fields for this version of the file.
    my %format = (
        issue   => [qw( cardnumber barcode )],
        return  => [qw( barcode )],
        payment => [qw( cardnumber amount )],
    );

    return $format{$command};
}

sub kocIssueItem {
  my $circ = shift;

  my $branchcode = C4::Context->userenv->{branch};
  my $borrower = GetMember( $circ->{ 'cardnumber' }, 'cardnumber' );
  my $item = GetBiblioFromItemNumber( undef, $circ->{ 'barcode' } );
  my $issue = GetItemIssue( $item->{'itemnumber'} );

  my $issuingrule = GetIssuingRule( $borrower->{ 'categorycode' }, $item->{ 'itemtype' }, $branchcode );
  my $issuelength = $issuingrule->{ 'issuelength' };
  my ( $year, $month, $day ) = split( /-/, $circ->{'date'} );
  ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, $issuelength );
  my $date_due = sprintf("%04d-%02d-%02d", $year, $month, $day);
  
  if ( $issue->{ 'date_due' } ) { ## Item is currently checked out to another person.
warn "Item Currently Issued.";
    my $issue = GetOpenIssue( $item->{'itemnumber'} );

    if ( $issue->{'borrowernumber'} eq $borrower->{'borrowernumber'} ) { ## Issued to this person already, renew it.
warn "Item issued to this member already, renewing.";
    
    my $date_due_object = C4::Dates->new($date_due ,'iso');
    C4::Circulation::AddRenewal(
        $issue->{'borrowernumber'},    # borrowernumber
        $item->{'itemnumber'},         # itemnumber
        undef,                         # branch
        $date_due_object,              # datedue
        $circ->{'date'},               # issuedate
    ) unless ($DEBUG);

      push( @output, { message => "Renewed $item->{ 'title' } ( $item->{ 'barcode' } ) to $borrower->{ 'firstname' } $borrower->{ 'surename' } ( $borrower->{'cardnumber'} ) : $circ->{ 'datetime' }\n" } );

    } else {
warn "Item issued to a different member.";
warn "Date of previous issue: $issue->{'issuedate'}";
warn "Date of this issue: $circ->{'date'}";
      my ( $i_y, $i_m, $i_d ) = split( /-/, $issue->{'issuedate'} );
      my ( $c_y, $c_m, $c_d ) = split( /-/, $circ->{'date'} );
      
      if ( Date_to_Days( $i_y, $i_m, $i_d ) < Date_to_Days( $c_y, $c_m, $c_d ) ) { ## Current issue to a different persion is older than this issue, return and issue.
        C4::Circulation::AddIssue( $borrower, $circ->{'barcode'}, $date_due ) unless ( DEBUG );
        push( @output, { message => "Issued $item->{ 'title' } ( $item->{ 'barcode' } ) to $borrower->{ 'firstname' } $borrower->{ 'surename' } ( $borrower->{'cardnumber'} ) : $circ->{ 'datetime' }\n" } );

      } else { ## Current issue is *newer* than this issue, write a 'returned' issue, as the item is most likely in the hands of someone else now.
warn "Current issue to another member is newer. Doing nothing";
        ## This situation should only happen of the Offline Circ data is *really* old.
        ## FIXME: write line to old_issues and statistics
      }
    
    }
  } else { ## Item is not checked out to anyone at the moment, go ahead and issue it
      C4::Circulation::AddIssue( $borrower, $circ->{'barcode'}, $date_due ) unless ( DEBUG );
    push( @output, { message => "Issued $item->{ 'title' } ( $item->{ 'barcode' } ) to $borrower->{ 'firstname' } $borrower->{ 'surename' } ( $borrower->{'cardnumber'} ) : $circ->{ 'datetime' }\n" } );
  }  
}

sub kocReturnItem {
  my ( $circ ) = @_;
  my $item = GetBiblioFromItemNumber( undef, $circ->{ 'barcode' } );
  warn( Data::Dumper->Dump( [ $circ, $item ], [ qw( circ item ) ] ) );
  my $borrowernumber = _get_borrowernumber_from_barcode( $circ->{'barcode'} );
  unless ( $borrowernumber ) {
      push( @output, { message => "Warning: unable to determine borrower from item ($item->{'barcode'}). Cannot mark returned\n" } );
  }
  C4::Circulation::MarkIssueReturned( $borrowernumber,
                                      $item->{'itemnumber'},
                                      undef,
                                      $circ->{'date'} );
  
  push( @output, { message => "Returned $item->{ 'title' } ( $item->{ 'barcode' } ) From borrower number $borrowernumber : $circ->{ 'datetime' }\n" } ); 
}

sub kocMakePayment {
  my ( $circ ) = @_;
  my $borrower = GetMember( $circ->{ 'cardnumber' }, 'cardnumber' );
  recordpayment( $borrower->{'borrowernumber'}, $circ->{'amount'} );
  push( @output, { message => "accepted payment ($circ->{'amount'}) from cardnumber ($circ->{'cardnumber'}), borrower ($borrower->{'borrowernumber'})" } );
}

=head3 _get_borrowernumber_from_barcode

pass in a barcode
get back the borrowernumber of the patron who has it checked out.
undef if that can't be found

=cut

sub _get_borrowernumber_from_barcode {
    my $barcode = shift;

    return unless $barcode;

    my $item = GetBiblioFromItemNumber( undef, $barcode );
    return unless $item->{'itemnumber'};
    
    my $issue = C4::Circulation::GetItemIssue( $item->{'itemnumber'} );
    return unless $issue->{'borrowernumber'};
    return $issue->{'borrowernumber'};
    
}
