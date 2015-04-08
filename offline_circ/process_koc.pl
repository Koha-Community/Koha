#!/usr/bin/perl

# 2008 Kyle Hall <kyle.m.hall@gmail.com>

# This file is part of Koha.
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
#

use strict;
use warnings;

use CGI;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Biblio;
use C4::Accounts;
use C4::Circulation;
use C4::Items;
use C4::Members;
use C4::Stats;
use C4::UploadedFile;
use C4::BackgroundJob;

use Date::Calc qw( Add_Delta_Days Date_to_Days );

use constant DEBUG => 0;

# this is the file version number that we're coded against.
my $FILE_VERSION = '1.0';

our $query = CGI->new;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => "offline_circ/process_koc.tt",
    query => $query,
    type => "intranet",
    authnotrequired => 0,
     flagsrequired   => { circulate => "circulate_remaining_permissions" },
});


my $fileID=$query->param('uploadedfileid');
my $runinbackground = $query->param('runinbackground');
my $completedJobID = $query->param('completedJobID');
my %cookies = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;
## 'Local' globals.
our $dbh = C4::Context->dbh();
our @output = (); ## For storing messages to be displayed to the user


if ($completedJobID) {
    my $job = C4::BackgroundJob->fetch($sessionID, $completedJobID);
    my $results = $job->results();
    $template->param(transactions_loaded => 1);
    $template->param(messages => $results->{results});
} elsif ($fileID) {
    my $uploaded_file = C4::UploadedFile->fetch($sessionID, $fileID);
    my $fh = $uploaded_file->fh();
    my @input_lines = <$fh>;

    my $filename = $uploaded_file->name();
    my $job = undef;

    if ($runinbackground) {
        my $job_size = scalar(@input_lines);
        $job = C4::BackgroundJob->new($sessionID, $filename, $ENV{'SCRIPT_NAME'}, $job_size);
        my $jobID = $job->id();

        # fork off
        if (my $pid = fork) {
            # parent
            # return job ID as JSON

            # prevent parent exiting from
            # destroying the kid's database handle
            # FIXME: according to DBI doc, this may not work for Oracle
            $dbh->{InactiveDestroy}  = 1;

            my $reply = CGI->new("");
            print $reply->header(-type => 'text/html');
            print '{"jobID":"' . $jobID . '"}';
            exit 0;
        } elsif (defined $pid) {
            # child
            # close STDOUT to signal to Apache that
            # we're now running in the background
            close STDOUT;
            close STDERR;
        } else {
            # fork failed, so exit immediately
            # fork failed, so exit immediately
            warn "fork failed while attempting to run $ENV{'SCRIPT_NAME'} as a background job";
            exit 0;
        }

        # if we get here, we're a child that has detached
        # itself from Apache

    }

    my $header_line = shift @input_lines;
    my $file_info   = parse_header_line($header_line);
    if ($file_info->{'Version'} ne $FILE_VERSION) {
        push @output, {
            message => 1,
            ERROR_file_version => 1,
            upload_version => $file_info->{'Version'},
            current_version => $FILE_VERSION
        };
    }

    my $i = 0;
    foreach  my $line (@input_lines)  {
        $i++;
        my $command_line = parse_command_line($line);

        # map command names in the file to subroutine names
        my %dispatch_table = (
            issue     => \&kocIssueItem,
            'return'  => \&kocReturnItem,
            payment   => \&kocMakePayment,
        );

        # call the right sub name, passing the hashref of command_line to it.
        if ( exists $dispatch_table{ $command_line->{'command'} } ) {
            $dispatch_table{ $command_line->{'command'} }->($command_line);
        } else {
            warn "unknown command: '$command_line->{command}' not processed";
        }

        if ($runinbackground) {
            $job->progress($i);
        }
    }

    if ($runinbackground) {
        $job->finish({ results => \@output }) if defined($job);
    } else {
        $template->param(transactions_loaded => 1);
        $template->param(messages => \@output);
    }
}

output_html_with_http_headers $query, $cookie, $template->output;

=head1 FUNCTIONS

=head2 parse_header_line

parses the header line from a .koc file. This is the line that
specifies things such as the file version, and the name and version of
the offline circulation tool that generated the file. See
L<http://wiki.koha-community.org/wiki/Koha_offline_circulation_file_format>
for more information.

pass in a string containing the header line (the first line from th
file).

returns a hashref containing the information from the header.

=cut

sub parse_header_line {
    my $header_line = shift;
    chomp($header_line);
    $header_line =~ s/\r//g;

    my @fields = split( /\t/, $header_line );
    my %header_info = map { split( /=/, $_ ) } @fields;
    return \%header_info;
}

=head2 parse_command_line

=cut

sub parse_command_line {
    my $command_line = shift;
    chomp($command_line);
    $command_line =~ s/\r//g;

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

=head2 arguments_for_command

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

    $circ->{ 'barcode' } = barcodedecode($circ->{'barcode'}) if( $circ->{'barcode'} && C4::Context->preference('itemBarcodeInputFilter'));
    my $branchcode = C4::Context->userenv->{branch};
    my $borrower = GetMember( 'cardnumber'=>$circ->{ 'cardnumber' } );
    my $item = GetBiblioFromItemNumber( undef, $circ->{ 'barcode' } );
    my $issue = GetItemIssue( $item->{'itemnumber'} );

    if ( $issue->{ 'date_due' } ) { ## Item is currently checked out to another person.
        #warn "Item Currently Issued.";
        my $issue = GetOpenIssue( $item->{'itemnumber'} );

        if ( $issue->{'borrowernumber'} eq $borrower->{'borrowernumber'} ) { ## Issued to this person already, renew it.
            #warn "Item issued to this member already, renewing.";

            C4::Circulation::AddRenewal(
                $issue->{'borrowernumber'},    # borrowernumber
                $item->{'itemnumber'},         # itemnumber
                undef,                         # branch
                undef,                         # datedue - let AddRenewal calculate it automatically
                $circ->{'date'},               # issuedate
            ) unless ($DEBUG);

            push @output, {
                renew => 1,
                title => $item->{ 'title' },
                biblionumber => $item->{'biblionumber'},
                barcode => $item->{ 'barcode' },
                firstname => $borrower->{ 'firstname' },
                surname => $borrower->{ 'surname' },
                borrowernumber => $borrower->{'borrowernumber'},
                cardnumber => $borrower->{'cardnumber'},
                datetime => $circ->{ 'datetime' }
            };

        } else {
            #warn "Item issued to a different member.";
            #warn "Date of previous issue: $issue->{'issuedate'}";
            #warn "Date of this issue: $circ->{'date'}";
            my ( $i_y, $i_m, $i_d ) = split( /-/, $issue->{'issuedate'} );
            my ( $c_y, $c_m, $c_d ) = split( /-/, $circ->{'date'} );

            if ( Date_to_Days( $i_y, $i_m, $i_d ) < Date_to_Days( $c_y, $c_m, $c_d ) ) { ## Current issue to a different persion is older than this issue, return and issue.
                C4::Circulation::AddIssue( $borrower, $circ->{'barcode'}, undef, undef, $circ->{'date'} ) unless ( DEBUG );
                push @output, {
                    issue => 1,
                    title => $item->{ 'title' },
                    biblionumber => $item->{'biblionumber'},
                    barcode => $item->{ 'barcode' },
                    firstname => $borrower->{ 'firstname' },
                    surname => $borrower->{ 'surname' },
                    borrowernumber => $borrower->{'borrowernumber'},
                    cardnumber => $borrower->{'cardnumber'},
                    datetime => $circ->{ 'datetime' }
                };

            } else { ## Current issue is *newer* than this issue, write a 'returned' issue, as the item is most likely in the hands of someone else now.
                #warn "Current issue to another member is newer. Doing nothing";
                ## This situation should only happen of the Offline Circ data is *really* old.
                ## FIXME: write line to old_issues and statistics
            }
        }
    } else { ## Item is not checked out to anyone at the moment, go ahead and issue it
        C4::Circulation::AddIssue( $borrower, $circ->{'barcode'}, undef, undef, $circ->{'date'} ) unless ( DEBUG );
        push @output, {
            issue => 1,
            title => $item->{ 'title' },
            biblionumber => $item->{'biblionumber'},
            barcode => $item->{ 'barcode' },
            firstname => $borrower->{ 'firstname' },
            surname => $borrower->{ 'surname' },
            borrowernumber => $borrower->{'borrowernumber'},
            cardnumber => $borrower->{'cardnumber'},
            datetime =>$circ->{ 'datetime' }
        };
    }
}

sub kocReturnItem {
    my ( $circ ) = @_;
    $circ->{'barcode'} = barcodedecode($circ->{'barcode'}) if( $circ->{'barcode'} && C4::Context->preference('itemBarcodeInputFilter'));
    my $item = GetBiblioFromItemNumber( undef, $circ->{ 'barcode' } );
    #warn( Data::Dumper->Dump( [ $circ, $item ], [ qw( circ item ) ] ) );
    my $borrowernumber = _get_borrowernumber_from_barcode( $circ->{'barcode'} );
    if ( $borrowernumber ) {
        my $borrower = GetMember( 'borrowernumber' => $borrowernumber );
        C4::Circulation::MarkIssueReturned(
            $borrowernumber,
            $item->{'itemnumber'},
            undef,
            $circ->{'date'},
            $borrower->{'privacy'}
        );

        ModItem({ onloan => undef }, $item->{'biblionumber'}, $item->{'itemnumber'});
        ModDateLastSeen( $item->{'itemnumber'} );

        push @output, {
            return => 1,
            title => $item->{ 'title' },
            biblionumber => $item->{'biblionumber'},
            barcode => $item->{ 'barcode' },
            borrowernumber => $borrower->{'borrowernumber'},
            firstname => $borrower->{'firstname'},
            surname => $borrower->{'surname'},
            cardnumber => $borrower->{'cardnumber'},
            datetime => $circ->{ 'datetime' }
        };
    } else {
        push @output, {
            ERROR_no_borrower_from_item => 1,
            badbarcode => $circ->{'barcode'}
        };
    }
}

sub kocMakePayment {
    my ( $circ ) = @_;
    my $borrower = GetMember( 'cardnumber'=>$circ->{ 'cardnumber' } );
    recordpayment( $borrower->{'borrowernumber'}, $circ->{'amount'} );
    push @output, {
        payment => 1,
        amount => $circ->{'amount'},
        firstname => $borrower->{'firstname'},
        surname => $borrower->{'surname'},
        cardnumber => $circ->{'cardnumber'},
        borrower => $borrower->{'borrowernumber'}
    };
}

=head2 _get_borrowernumber_from_barcode

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
