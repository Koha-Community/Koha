#!/usr/bin/perl -w
#-----------------------------------
# Copyright 2008 LibLime
#
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
#-----------------------------------

=head1 NAME

longoverdue.pl  cron script to set lost statuses on overdue materials.
                Execute without options for help.

=cut

use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Context;
use C4::Items;
use C4::Accounts;
use Getopt::Long;

my  $lost;  #  key=lost value,  value=num days.
my ($charge, $verbose, $confirm);
my $endrange = 366;  # FIXME hardcoded - don't deal with anything overdue by more than this num days.

GetOptions( 
    'lost=s%'    => \$lost,
    'c|charge=s' => \$charge,
    'confirm'    => \$confirm,
    'verbose'    => \$verbose,
);

my $usage = << 'ENDUSAGE';
longoverdue.pl : This cron script set lost values on overdue items and optionally sets charges the patron's account
for the item's replacement price.  It is designed to be run as a nightly job.  The command line options that globally
define this behavior for this script  will likely be moved into Koha's core circulation / issuing rules code in a 
near-term release, so this script is not intended to have a long lifetime.  

This script takes the following parameters :

    --lost | -l         This option takes the form of n=lv,
                        where n is num days overdue, and lv is the lost value.  See warning below.

    --charge | -c       This specifies what lost value triggers Koha to charge the account for the
                        lost item.  Replacement costs are not charged if this is not specified.

    --verbose | v       verbose.

    --confirm           confirm.  without this option, the script will report the number of affected items and
                        return without modifying any records.

  examples :
  $PERL5LIB/misc/cronjobs/longoverdue.pl --lost 30=1
    Would set LOST=1 after 30 days (up to one year), but not charge the account.
    This would be suitable for the Koha default LOST authorized value of 1 -> 'Lost'.

  $PERL5LIB/misc/cronjobs/longoverdue.pl --lost 60=2 --charge 1
    Would set LOST=2 after 60 days (up to one year), and charge the account when setting LOST=2.
    This would be suitable for the Koha default LOST authorized value of 2 -> 'Long Overdue' 

WARNING:  Flippant use of this script could set all or most of the items in your catalog to Lost and charge your
patrons for them!

WARNING:  This script is known to be faulty.  It is NOT recommended to use multiple --lost options.
          See http://bugs.koha.org/cgi-bin/bugzilla/show_bug.cgi?id=2881

ENDUSAGE

# FIXME: We need three pieces of data to operate:
#         ~ lower bound (number of days),
#         ~ upper bound (number of days),
#         ~ new lost value.
#        Right now we get only two, causing the endrange hack.  This is a design-level failure.
# FIXME: do checks on --lost ranges to make sure they are exclusive.
# FIXME: do checks on --lost ranges to make sure the authorized values exist.
# FIXME: do checks on --lost ranges to make sure don't go past endrange.
# FIXME: convert to using pod2usage
# FIXME: allow --help or -h
# 
if ( ! defined($lost) ) {
    print $usage;
    die "ERROR: No --lost (-l) option defined";
}
unless ($confirm) {
    $verbose = 1;     # If you're not running it for real, then the whole point is the print output.
    print "### TEST MODE -- NO ACTIONS TAKEN ###\n";
}

# In my opinion, this line is safe SQL to have outside the API. --atz
our $bounds_sth = C4::Context->dbh->prepare("SELECT DATE_SUB(CURDATE(), INTERVAL ? DAY)");

sub bounds ($) {
    $bounds_sth->execute(shift);
    return $bounds_sth->fetchrow;
}

# FIXME - This sql should be inside the API.
sub longoverdue_sth {
    my $query = "
    SELECT items.itemnumber, borrowernumber, date_due
      FROM issues, items
     WHERE items.itemnumber = issues.itemnumber
      AND  DATE_SUB(CURDATE(), INTERVAL ? DAY)  > date_due
      AND  DATE_SUB(CURDATE(), INTERVAL ? DAY) <= date_due
      AND  itemlost <> ?
     ORDER BY date_due
    ";
    return C4::Context->dbh->prepare($query);
}

#FIXME - Should add a 'system' user and get suitable userenv for it for logging, etc.

my $count;
# my @ranges = map { 
my @report;
my $total = 0;
my $i = 0;

# FIXME - The item is only marked returned if you supply --charge .
#         We need a better way to handle this.
#
my $sth_items = longoverdue_sth();

foreach my $startrange (sort keys %$lost) {
    if( my $lostvalue = $lost->{$startrange} ) {
        my ($date1) = bounds($startrange);
        my ($date2) = bounds(  $endrange);
        # print "\nRange ", ++$i, "\nDue $startrange - $endrange days ago ($date2 to $date1), lost => $lostvalue\n" if($verbose);
        $verbose and 
            printf "\nRange %s\nDue %3s - %3s days ago (%s to %s), lost => %s\n", ++$i,
            $startrange, $endrange, $date2, $date1, $lostvalue;
        $sth_items->execute($startrange, $endrange, $lostvalue);
        $count=0;
        while (my $row=$sth_items->fetchrow_hashref) {
            printf ("Due %s: item %5s from borrower %5s to lost: %s\n", $row->{date_due}, $row->{itemnumber}, $row->{borrowernumber}, $lostvalue) if($verbose);
            if($confirm) {
                ModItem({ itemlost => $lostvalue }, $row->{'biblionumber'}, $row->{'itemnumber'});
                chargelostitem($row->{'itemnumber'}) if( $charge && $charge eq $lostvalue);
            }
            $count++;
        }
        push @report, {
           startrange => $startrange,
             endrange => $endrange,
                range => "$startrange - $endrange",
                date1 => $date1,
                date2 => $date2,
            lostvalue => $lostvalue,
                count => $count,
        };
        $total += $count;
    }
    $endrange = $startrange;
}

sub summarize ($$) {
    my $arg = shift;    # ref to array
    my $got_items = shift || 0;     # print "count" line for items
    my @report = @$arg or return undef;
    my $i = 0;
    for my $range (@report) {
        printf "\nRange %s\nDue %3s - %3s days ago (%s to %s), lost => %s\n", ++$i,
            map {$range->{$_}} qw(startrange endrange date2 date1 lostvalue);
        $got_items and printf "  %4s items\n", $range->{count};
    }
}

print "\n### LONGOVERDUE SUMMARY ###";
summarize (\@report, 1);
print "\nTOTAL: $total items\n";
