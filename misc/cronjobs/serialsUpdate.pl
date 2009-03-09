#!/usr/bin/perl -w

# Copyright 2008 SARL Biblibre
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

use strict;
use warnings;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Debug;
use C4::Serials;

use Date::Calc qw/Date_to_Days check_date/;
use Getopt::Long;
use Pod::Usage;

my $dbh = C4::Context->dbh;

my $man     = 0;
my $help    = 0;
my $confirm = 0;

GetOptions(
    'help|?' => \$help,
    'c'      => \$confirm,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

# select all serials with not "irregular" periodicity that are late
my $sth = $dbh->prepare("
     SELECT *
     FROM serial 
     LEFT JOIN subscription 
       ON (subscription.subscriptionid=serial.subscriptionid) 
     WHERE serial.status = 1 
       AND periodicity <> 32
       AND DATE_ADD(planneddate, INTERVAL CAST(graceperiod AS SIGNED) DAY) < NOW()
     ");
$sth->execute();

while ( my $issue = $sth->fetchrow_hashref ) {

    my $subscription      = &GetSubscription( $issue->{subscriptionid} );
    my $planneddate       = $issue->{planneddate};

    if( $subscription && $planneddate && $planneddate ne "0000-00-00" ){
        my $nextpublisheddate = GetNextDate( $planneddate, $subscription );
        my $today             = format_date_in_iso( C4::Dates->new()->output() );

        if ($nextpublisheddate && $today){
            my ( $year,  $month,  $day )  = split( /-/, $nextpublisheddate );
            my ( $tyear, $tmonth, $tday ) = split( /-/, $today );
            if (   check_date( $year, $month, $day )
                && check_date( $tyear, $tmonth, $tday )
                && Date_to_Days( $year, $month, $day ) <
                Date_to_Days( $tyear, $tmonth, $tday ) )
            {
        
            ModSerialStatus( $issue->{serialid}, $issue->{serialseq},
                $issue->{planneddate}, $issue->{publisheddate},
                3, "Automatically set to late" );
            print $issue->{serialid}." update\n";
            }
        }else{
            print "Error with serial(".$issue->{serialid}.") has no existent 
                   subscription(".$issue->{subscriptionid}.") attached
                   or planneddate is ";
        }
    }
}
