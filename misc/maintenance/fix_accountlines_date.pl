#!/usr/bin/perl
#
# Copyright (C) 2008 LibLime
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
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Dates;
use Getopt::Long;
use Pod::Usage;

=head1 NAME

fix_accountlines_date.pl - Fix date code in the description of fines

=head1 SYNOPSIS

fix_accountlines_date.pl -m date_format [ -n fines_to_process ] [ -d ] [ --help or -h ]

 Options:
   --help or -h                Brief usage message
   --man                       Full documentation
   -n fines_to_process         How many fines to process; if left off will
                               process all
   -m date_format              What format the dates are currently in; 'us'
                               or 'metric' (REQUIRED)
   -d                          Run in debugging mode

=head1 DESCRIPTION

This script fixes the date code in the description of fines. Previously, the
format of this was determined by which script you were using to update fines (see the -m option)

=over 8

=item B<--help>

Prints a brief usage message and exits.

=item B<--man>

Prints a full manual page and exits.

=item B<-n>

Process only a certain amount of fines. If this option is left off, this script
will process everything.

=item B<-m>

This required option tells the script what format your dates are currently in.
If you were previously using the fines2.pl or fines-sanop.pl script to update 
your fines, they will be in 'metric' format. If you were using the fines-ll.pl
script, they will be in 'us' format. After this script is finished, they will
be in whatever format your 'dateformat' system preference specifies.

=item B<-d>

Run in debugging mode; this prints out a lot of information and should be used
only if there is a problem and with the '-n' option.

=back

=cut

my $mode = '';
my $want_help = 0;
my $limit = -1;
my $done = 0;
my $DEBUG = 0;

# Regexes for the two date formats
our $US_DATE = '((0\d|1[0-2])\/([0-2]\d|3[01])\/(\d{4}))';
our $METRIC_DATE = '(([0-2]\d|3[01])\/(0\d|1[0-2])\/(\d{4}))';

sub print_usage {
    print <<_USAGE_
$0: Fix the date code in the description of fines

Due to the multiple scripts used to update fines in earlier versions of Koha,
this script should be used to change the format of the date codes in the
accountlines table before you start using Koha 3.0.

Parameters:
  --mode or -m        This should be 'us' or 'metric', and tells the script
                      what format your old dates are in.
  --debug or -d       Run this script in debug mode.
  --limit or -n       How many accountlines rows to fix; useful for testing.
  --help or -h        Print out this help message.
_USAGE_
}

my $result = GetOptions(
    'm=s' => \$mode,
    'd'  => \$DEBUG,
    'n=i'  => \$limit, 
    'help|h'   => \$want_help,
);

if (not $result or $want_help or ($mode ne 'us' and $mode ne 'metric')) {
    print_usage();
    exit 0;
}

our $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
my $sth = $dbh->prepare("
SELECT borrowernumber, itemnumber, accountno, description
  FROM accountlines
  WHERE accounttype in ('FU', 'F', 'O', 'M')
;");
$sth->execute();

my $update_sth = $dbh->prepare('
UPDATE accountlines
  SET description = ?
  WHERE borrowernumber = ? AND itemnumber = ? AND accountno = ?
;');


while (my $accountline = $sth->fetchrow_hashref) {
    my $description = $accountline->{'description'};
    my $updated = 0;

    if ($mode eq 'us') {
        if ($description =~ /$US_DATE/) { # mm/dd/yyyy
            my $date = C4::Dates->new($1, 'us');
            print "Converting $1 (us) to " . $date->output() . "\n" if $DEBUG;
            $description =~ s/$US_DATE/$date->output()/;
            $updated = 1;
        }
    } elsif ($mode eq 'metric') {
        if ($description =~ /$METRIC_DATE/) { # dd/mm/yyyy
            my $date = C4::Dates->new($1, 'metric');
            print "Converting $1 (metric) to " . $date->output() . "\n" if $DEBUG;
            $description =~ s/$METRIC_DATE/$date->output()/;
            $updated = 2;
        }
    }

    print "Changing description from '" . $accountline->{'description'} . "' to '" . $description . "'\n" if $DEBUG;
    $update_sth->execute($description, $accountline->{'borrowernumber'}, $accountline->{'itemnumber'}, $accountline->{'accountno'});

    $done++;

    last if ($done == $limit); # $done can't be -1, so this works
}

$dbh->commit();
