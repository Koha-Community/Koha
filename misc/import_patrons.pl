#!/usr/bin/perl

# Parts copyright 2014 ByWater Solutions
#
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

use Modern::Perl;

use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use Koha::Script;
use Koha::Patrons::Import;
my $Import = Koha::Patrons::Import->new();

my $csv_file;
my $matchpoint;
my $overwrite_cardnumber;
my $overwrite_passwords;
my $welcome_new = 0;
my %defaults;
my $ext_preserve = 0;
my $confirm;
my $verbose      = 0;
my $help;
my @preserve_fields;

GetOptions(
    'c|confirm'                      => \$confirm,
    'f|file=s'                       => \$csv_file,
    'm|matchpoint=s'                 => \$matchpoint,
    'd|default=s'                    => \%defaults,
    'o|overwrite'                    => \$overwrite_cardnumber,
    'op|overwrite_passwords'         => \$overwrite_passwords,
    'en|email-new'                   => \$welcome_new,
    'p|preserve-extended-attributes' => \$ext_preserve,
    'pf|preserve-field=s'            => \@preserve_fields,
    'v|verbose+'                     => \$verbose,
    'h|help|?'                       => \$help,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(q|--file is required|) unless $csv_file;
pod2usage(q|--matchpoint is required|) unless $matchpoint;

warn "Running in dry-run mode, provide --confirm to apply the changes\n" unless $confirm;

my $handle;
open( $handle, "<", $csv_file ) or die $!;

my $return = $Import->import_patrons(
    {
        file                         => $handle,
        defaults                     => \%defaults,
        matchpoint                   => $matchpoint,
        overwrite_cardnumber         => $overwrite_cardnumber,
        overwrite_passwords          => $overwrite_passwords,
        preserve_extended_attributes => $ext_preserve,
        preserve_fields              => \@preserve_fields,
        send_welcome                 => $welcome_new,
        dry_run                      => !$confirm,
    }
);

my $feedback    = $return->{feedback};
my $errors      = $return->{errors};
my $imported    = $return->{imported};
my $overwritten = $return->{overwritten};
my $alreadyindb = $return->{already_in_db};
my $invalid     = $return->{invalid};

if ($verbose) {
    my $total = $imported + $alreadyindb + $invalid + $overwritten;
    say q{};
    say "Import complete:";
    say "Imported:    $imported";
    say "Overwritten: $overwritten";
    say "Skipped:     $alreadyindb";
    say "Invalid:     $invalid";
    say "Total:       $total";
    say q{};
}

if ($verbose > 1 ) {
    say "Errors:";
    say Data::Dumper::Dumper( $errors );
}

if ($verbose > 2 ) {
    say "Feedback:";
    say Data::Dumper::Dumper( $feedback );
}

=head1 NAME

import_patrons.pl - CLI script to import patrons data into Koha

=head1 SYNOPSIS

import_patrons.pl --file /path/to/patrons.csv --matchpoint cardnumber --confirm [--default branchcode=MPL] [--overwrite] [--preserve_field <column>] [--preserve-extended-attributes] [--verbose]

=head1 OPTIONS

=over 8

=item B<-h|--help>

Prints a brief help message and exits

=item B<-c|--confirm>

Confirms you really want to import these patrons, otherwise prints this help

=item B<-f|--file>

Path to the CSV file of patrons to import

=item B<-c|--matchpoint>

Field on which to match incoming patrons to existing patrons

=item B<-d|--default>

Set defaults to patron fields, repeatable e.g. --default branchcode=MPL --default categorycode=PT

=item B<-k|--preserve-field>

Prevent specified patron fields for existing patrons from being overwritten

=item B<-o|--overwrite>

Overwrite existing patrons with new data if a match is found

=item B<-p|--preserve-extended-attributes>

Retain extended patron attributes for existing patrons being overwritten

=item B<-en|--email-new>

Send the ACCTDETAILS welcome email to new users

=item B<-v|--verbose>

Be verbose

Multiple -v options increase the verbosity

2 repetitions or above will report lines in error

3 repetitions or above will report feedback

=back

=cut
