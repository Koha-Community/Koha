#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2023 PTFS Europe Ltd
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

marc_ordering_process.pl - cron script to retrieve MARC files and create order lines

=head1 SYNOPSIS

./marc_ordering_process.pl [-c|--confirm] [-v|--verbose]

or, in crontab:
# Once every day
0 3 * * * marc_ordering_process.pl -c

=head1 DESCRIPTION

This script searches for new MARC files in an SFTP location
If there are new files, it stages those files, adds bilbios/items and creates order lines

=head1 OPTIONS

=over

=item B<-v|--verbose>

Print report to standard out.

=item B<-c|--confirm>

Without this parameter no changes will be made

=item B<-d|--delete>

Delete the file once it has been processed

=back

=cut

use Modern::Perl;
use Pod::Usage   qw( pod2usage );
use Getopt::Long qw( GetOptions );
use File::Copy   qw( copy move );

use Koha::Script -cron;
use Koha::MarcOrder;
use Koha::MarcOrderAccounts;

use C4::Log qw( cronlogaction );

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my ( $help, $verbose, $confirm, $delete );
GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'c|confirm' => \$confirm,
    'd|delete'  => \$delete,
) || pod2usage(1);

pod2usage(0) if $help;

$verbose = 1            unless $verbose or $confirm;
print "Test run only\n" unless $confirm;

print "Fetching MARC ordering accounts\n" if $verbose;
my @accounts = Koha::MarcOrderAccounts->search(
    {},
    { join => [ 'vendor', 'budget' ] }
)->as_list;

if ( scalar(@accounts) == 0 ) {
    print "No accounts found - you must create a MARC order account for this cronjob to run\n" if $verbose;
}

foreach my $acct (@accounts) {
    if ($verbose) {
        say sprintf "Starting MARC ordering process for %s", $acct->vendor->name;
        say sprintf "Looking for new files in %s",           $acct->download_directory;
    }

    my $working_dir = $acct->download_directory;
    opendir my $dir, $working_dir or die "Can't open filepath";
    my @files = grep { /\.(mrc|marcxml|mrk)/i } readdir $dir;
    closedir $dir;
    print "No new files found\n" if scalar(@files) == 0;

    my $files_processed = 0;

    foreach my $filename (@files) {
        my $full_path = "$working_dir/$filename";
        my $args      = {
            filename => $filename,
            filepath => $full_path,
            profile  => $acct,
            agent    => 'cron'
        };
        if ( $acct->match_field && $acct->match_value ) {
            my $file_match = Koha::MarcOrder->match_file_to_account($args);
            next if !$file_match;
        }
        if ($confirm) {
            say sprintf "Creating order lines from file %s", $filename if $verbose;

            my $result = Koha::MarcOrder->create_order_lines_from_file($args);
            if ( $result->{success} ) {
                $files_processed++;
                say sprintf "Successfully processed file: %s", $filename if $verbose;
                if ($delete) {
                    say sprintf "Deleting processed file: %s", $filename if $verbose;
                    unlink $full_path;
                } else {
                    mkdir "$working_dir/archive" unless -d "$working_dir/archive";
                    say sprintf "Moving file to archive: %s", $filename if $verbose;
                    move( $full_path, "$working_dir/archive/$filename" );
                }
            } else {
                say sprintf "Error processing file: %s", $filename        if $verbose;
                say sprintf "Error message: %s",         $result->{error} if $verbose;
            }
        }
    }
    say sprintf "%s file(s) processed", $files_processed unless $files_processed == 0;
    print "Moving to next account\n\n";
}
print "Process complete\n";
cronlogaction( { action => 'End', info => "COMPLETED" } );
