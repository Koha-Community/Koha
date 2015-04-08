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

use Date::Calc qw( Add_Delta_Days Date_to_Days );

use constant DEBUG => 0;

# this is the file version number that we're coded against.
my $FILE_VERSION = '1.0';

my $query = CGI->new;
my @output;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => "offline_circ/enqueue_koc.tt",
    query => $query,
    type => "intranet",
    authnotrequired => 0,
     flagsrequired   => { circulate => "circulate_remaining_permissions" },
});


my $fileID=$query->param('uploadedfileid');
my %cookies = parse CGI::Cookie($cookie);
my $sessionID = $cookies{'CGISESSID'}->value;
## 'Local' globals.
our $dbh = C4::Context->dbh();

if ($fileID) {
    my $uploaded_file = C4::UploadedFile->fetch($sessionID, $fileID);
    my $fh = $uploaded_file->fh();
    my @input_lines = <$fh>;

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

    my $userid = C4::Context->userenv->{id};
    my $branchcode = C4::Context->userenv->{branch};

    foreach  my $line (@input_lines)  {
        my $command_line = parse_command_line($line);
        my $timestamp = $command_line->{'date'} . ' ' . $command_line->{'time'};
        my $action = $command_line->{'command'};
        my $barcode = $command_line->{'barcode'};
        my $cardnumber = $command_line->{'cardnumber'};
        my $amount = $command_line->{'amount'};

        AddOfflineOperation( $userid, $branchcode, $timestamp, $action, $barcode, $cardnumber, $amount );
    }

}

$template->param( messages => \@output );

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
