#!/usr/bin/perl

use Modern::Perl;

use Pod::Usage   qw( pod2usage );
use Getopt::Long qw( GetOptions );

use Koha::Script -cron;
use C4::Context;
use C4::UsageStats;
use C4::Log qw( cronlogaction );
use POSIX   qw( strftime );

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my ( $help, $verbose, $force, $quiet );
GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'f|force'   => \$force,
    'q|quiet'   => \$quiet,
) || pod2usage(1);

if ($help) {
    pod2usage(0);
}

unless ( C4::Context->preference('UsageStats') ) {
    $quiet && exit;
    pod2usage(
        q|
The UsageStats system preference is not set.
If your library wants to share their usage statistics with the Koha community, you have to switch on this system preference

Setting the quiet flag will silence this message.
|
    );
    exit 1;
}

my $report = C4::UsageStats::BuildReport();
C4::UsageStats::ReportToCommunity($report);
C4::Context->set_preference(
    'UsageStatsLastUpdateTime',
    strftime( "%s", localtime )
);

cronlogaction( { action => 'End', info => "COMPLETED" } );

=head1 NAME

share_usage_with_koha_community.pl - Share your library's usage with the Koha community

=head1 SYNOPSIS

share_usage_with_koha_community.pl [-h|--help] [-v|--verbose] [-f|--force] [-q|--quiet]

If the UsageStats system preference is set, you can launch this script to share your usage data
anonymously with the Koha community.

Collecting Koha usage statistics will help developers to know how Koha is used across the world.

This script will send the usage data for the bibliographic and authority records, checkouts, holds, orders,
and subscriptions.

Only the total number is retrieved. In no case will private data be shared!

In order to know which parts of Koha modules are used, this script will collect some system preference values.

If you want to tell us who you are, you can fill the UsageStatsLibraryName system preference with your library name, UsageStatsLibraryUrl, UsageStatsLibraryType and/or UsageStatsCountry, UsageStatsLibrariesInfo.

All these data will be analyzed on the http://hea.koha-community.org Koha community website.

IMPORTANT : please do NOT run the cron on the 1st, but on another day. The idea is to avoid all
Koha libraries sending their data at the same time ! So choose any day between 1 and 28 !

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<-v|--verbose>

Verbose mode

=item B<-f|--force>

Force the update

=item B<-q|--quiet>

Do not emit "The UsageStats system preference is not set" message

=back

=head1 AUTHOR

Alex Arnaud <alex.arnaud@biblibre.com>

Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT

Copyright 2014 BibLibre

=head1 LICENSE

This file is part of Koha.

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=cut
