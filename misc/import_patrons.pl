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

use Getopt::Long;

use Koha::Patrons::Import;
my $Import = Koha::Patrons::Import->new();

my $csv_file;
my $matchpoint;
my $overwrite_cardnumber;
my %defaults;
my $ext_preserve = 0;
my $confirm;
my $verbose      = 0;
my $help;

GetOptions(
    'c|confirm'                     => \$confirm,
    'f|file=s'                      => \$csv_file,
    'm|matchpoint=s'                => \$matchpoint,
    'd|default=s'                   => \%defaults,
    'o|overwrite'                   => \$overwrite_cardnumber,
    'p|preserve-extended-atributes' => \$ext_preserve,
    'v|verbose+'                    => \$verbose,
    'h|help|?'                      => \$help,
);

print_help() if ( $help || !$csv_file || !$matchpoint || !$confirm );

my $handle;
open( $handle, "<", $csv_file ) or die $!;

my $return = $Import->import_patrons(
    {
        file                         => $handle,
        defaults                     => \%defaults,
        matchpoint                   => $matchpoint,
        overwrite_cardnumber         => $overwrite_cardnumber,
        preserve_extended_attributes => $ext_preserve,
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

sub print_help {
    print <<_USAGE_;
import_patrons.pl -c /path/to/patrons.csv -m cardnumber
    -c --confirm                        Confirms you really want to import these patrons, otherwise prints this help
    -f --file                           Path to the CSV file of patrons to import
    -m --matchpoint                     Field on which to match incoming patrons to existing patrons
    -d --default                        Set defaults to patron fields, repeatable e.g. --default branchcode=MPL --default categorycode=PT
    -p --preserve-extended-atributes    Retain extended patron attributes for existing patrons being overwritten
    -o --overwrite                      Overwrite existing patrons with new data if a match is found
    -v --verbose                        Be verbose
_USAGE_
    exit;
}
