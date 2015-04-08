#!/usr/bin/perl

#  This script loops through each overdue item, determines the fine,
#  and updates the total amount of fines due by each user.  It relies on
#  the existence of /tmp/fines, which is created by ???
# Doesnt really rely on it, it relys on being able to write to /tmp/
# It creates the fines file
#
#  This script is meant to be run nightly out of cron.

# Copyright 2000-2002 Katipo Communications
# Copyright 2011 PTFS-Europe Ltd
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

use strict;
use warnings;
use 5.010;

use C4::Context;
use C4::Overdues;
use Getopt::Long;
use Carp;
use File::Spec;

use Koha::Calendar;
use Koha::DateUtils;

my $help;
my $verbose;
my $output_dir;
my $log;

GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'l|log'     => \$log,
    'o|out:s'   => \$output_dir,
);
my $usage = << 'ENDUSAGE';

This script calculates and charges overdue fines
to patron accounts.  The Koha system preference 'finesMode' controls
whether the fines are calculated and charged to the patron accounts ("Calculate and charge");
calculated and emailed to the admin but not applied ("Calculate (but only for mailing to the admin)"); or not calculated ("Don't calculate").

This script has the following parameters :
    -h --help: this message
    -l --log: log the output to a file (optional if the -o parameter is given)
    -o --out:  ouput directory for logs (defaults to env or /tmp if !exist)
    -v --verbose

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

my @borrower_fields =
  qw(cardnumber categorycode surname firstname email phone address citystate);
my @item_fields  = qw(itemnumber barcode date_due);
my @other_fields = qw(type days_overdue fine);
my $libname      = C4::Context->preference('LibraryName');
my $control      = C4::Context->preference('CircControl');
my $mode         = C4::Context->preference('finesMode');
my $delim = "\t";    # ?  C4::Context->preference('delimiter') || "\t";

my %is_holiday;
my $today = DateTime->now( time_zone => C4::Context->tz() );
my $filename;
if ($log or $output_dir) {
    $filename = get_filename($output_dir);
}

my $fh;
if ($filename) {
    open $fh, '>>', $filename or croak "Cannot write file $filename: $!";
    print {$fh} join $delim, ( @borrower_fields, @item_fields, @other_fields );
    print {$fh} "\n";
}
my $counted = 0;
my $overdues = Getoverdues();
for my $overdue ( @{$overdues} ) {
    next if $overdue->{itemlost};

    if ( !defined $overdue->{borrowernumber} ) {
        carp
"ERROR in Getoverdues : issues.borrowernumber IS NULL.  Repair 'issues' table now!  Skipping record.\n";
        next;
    }
    my $borrower = BorType( $overdue->{borrowernumber} );
    my $branchcode =
        ( $control eq 'ItemHomeLibrary' ) ? $overdue->{homebranch}
      : ( $control eq 'PatronLibrary' )   ? $borrower->{branchcode}
      :                                     $overdue->{branchcode};

# In final case, CircControl must be PickupLibrary. (branchcode comes from issues table here).
    if ( !exists $is_holiday{$branchcode} ) {
        $is_holiday{$branchcode} = set_holiday( $branchcode, $today );
    }

    my $datedue = dt_from_string( $overdue->{date_due} );
    if ( DateTime->compare( $datedue, $today ) == 1 ) {
        next;    # not overdue
    }
    ++$counted;

    my ( $amount, $type, $unitcounttotal ) =
      CalcFine( $overdue, $borrower->{categorycode},
        $branchcode, $datedue, $today );
    $type ||= q{};

    # Don't update the fine if today is a holiday.
    # This ensures that dropbox mode will remove the correct amount of fine.
    if ( $mode eq 'production' && !$is_holiday{$branchcode} ) {
        if ( $amount > 0 ) {
            UpdateFine(
                $overdue->{itemnumber},
                $overdue->{borrowernumber},
                $amount, $type, output_pref($datedue)
            );
        }
    }
    if ($filename) {
        my @cells;
        push @cells,
          map { defined $borrower->{$_} ? $borrower->{$_} : q{} }
          @borrower_fields;
        push @cells, map { $overdue->{$_} } @item_fields;
        push @cells, $type, $unitcounttotal, $amount;
        say {$fh} join $delim, @cells;
    }
}
if ($filename){
    close $fh;
}

if ($verbose) {
    my $overdue_items = @{$overdues};
    print <<"EOM";
Fines assessment -- $today
EOM
    if ($filename) {
        say "Saved to $filename";
    }
    print <<"EOM";
Number of Overdue Items:
     counted $overdue_items
    reported $counted

EOM
}

sub set_holiday {
    my ( $branch, $dt ) = @_;

    my $calendar = Koha::Calendar->new( branchcode => $branch );
    return $calendar->is_holiday($dt);
}

sub get_filename {
    my $directory = shift;
    if ( !$directory ) {
        $directory = File::Spec->tmpdir();
    }
    if ( !-d $directory ) {
        carp "Could not write to $directory ... does not exist!";
    }
    my $name = C4::Context->config('database');
    $name =~ s/\W//;
    $name .= join q{}, q{_}, $today->ymd(), '.log';
    $name = File::Spec->catfile( $directory, $name );
    if ($verbose && $log) {
        say "writing to $name";
    }
    return $name;
}
