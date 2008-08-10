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

GetOptions( 
            'l|lost=s%'    => \$lost,
            'c|charge=s'  => \$charge,
            'confirm'  => \$confirm,
            'v|verbose'  => \$verbose,
       );
my $usage = << 'ENDUSAGE';
longoverdue.pl : This cron script set lost values on overdue items and optionally sets charges the patron's account
for the item's replacement price.  It is designed to be run as a nightly job.  The command line options that globally
define this behavior for this script  will likely be moved into Koha's core circulation / issuing rules code in a 
near-term release, so this script is not intended to have a long lifetime.  

This script takes the following parameters :

    --lost | -l         This option may be used multiple times, and takes the form of n=lv ,
                        where n is num days overdue, and lv is the lost value.

    --charge | -c       This specifies what lost value triggers Koha to charge the account for the
                        lost item.  Replacement costs are not charged if this is not specified.

    --verbose | v       verbose.

    --confirm           confirm.  without -c, this script will report the number of affected items and
                        return without modifying any records.

  example :  $PERL5LIB/misc/cronjobs/longoverdue.pl --lost 30=2 --lost 60=1 --charge 1
    would set LOST= 1  after 30 days, LOST= 2 after 60 days, and charge the account when setting LOST= 2 (i.e., 60 days).
    This would be suitable for the Koha default LOST authorized values of 1 -> 'Lost' and 2 -> 'Long Overdue' 

WARNING:  Flippant use of this script could set all or most of the items in your catalog to Lost and charge your
patrons for them!

ENDUSAGE

if ( ! defined($lost) ) {
    print $usage;
    die;
}

my $dbh = C4::Context->dbh();

#FIXME - Should add a 'system' user and get suitable userenv for it for logging, etc.

my $endrange = 366;  # hardcoded - don't deal with anything overdue by more than this num days.

my @interval = sort keys %$lost;

my $count;
my @report;

# FIXME - The item is only marked returned if you supply --charge .
#         We need a better way to handle this.
#
# FIXME - no sql should be outside the API.

my $query = "SELECT items.itemnumber,borrowernumber FROM issues,items WHERE items.itemnumber=issues.itemnumber AND 
        DATE_SUB( CURDATE(), INTERVAL ? DAY) > date_due AND DATE_SUB( CURDATE(), INTERVAL ? DAY ) <= date_due AND itemlost <> ? ";
my $sth_items = $dbh->prepare($query);
while ( my $startrange = shift @interval ) {
    if( my $lostvalue = $lost->{$startrange} ) {
        #warn "query: $query    \\with\\ params: $startrange,$endrange, $lostvalue "if($verbose);
        warn "starting range: $startrange - $endrange with lost value $lostvalue" if($verbose);
        $sth_items->execute( $startrange,$endrange, $lostvalue );
        $count=0;
        while (my $row=$sth_items->fetchrow_hashref) {
        warn "updating $row->{'itemnumber'} for borrower $row->{'borrowernumber'} to lost: $lostvalue" if($verbose);
            if($confirm) {
                ModItem({ itemlost => $lostvalue }, $row->{'biblionumber'}, $row->{'itemnumber'});
                chargelostitem($row->{'itemnumber'}) if( $charge && $charge eq $lostvalue);
            }
            $count++;
        }
        push @report, { range => "$startrange - $endrange",
                        lostvalue =>  $lostvalue,
                        count => $count,
                     };
    }
    $endrange = $startrange;
}
for my $range (@report) {
    for my $var (keys %$range) {
        warn "$var :  $range->{$var}";
    }
}


$sth_items->finish;
$dbh->disconnect;
