#!/usr/bin/perl
# Written by Pasi Korkalo / Koha-Suomi Oy
# GNU GPL3 or later applies.

use strict;
use warnings;
use utf8;
use C4::Context;
use POSIX qw(strftime);

my $dbh = C4::Context->dbh();

sub checkstatistics {
    # An entry in statistics would imply that something has happened to the item in Koha, which is a reason enough to leave the dates alone
    my $stat_sth = $dbh->prepare ( "SELECT count(*) FROM statistics where itemnumber = ? AND other != 'KONVERSIO' AND other NOT LIKE '%KONKIR' LIMIT 1;" );
       $stat_sth->execute(shift);

    return $stat_sth->fetch();
}

my $confirm;
my $conversiondate;
my $pallasconversiondate;
my @pallasconversion;

for (@ARGV) {
    if ( $_ eq '-c' ) {
        $confirm=1;
    }
    else {
        $conversiondate=$_;
        @pallasconversion=split( '-', $conversiondate );
        $pallasconversion[1]--;
        $pallasconversion[1] = sprintf( "%02d", $pallasconversion[1] );
        $pallasconversiondate = "$pallasconversion[0]-$pallasconversion[1]-$pallasconversion[2]";
    }
}

if ( ! $conversiondate ) {
    print STDERR "You need to provide the date of the Pallas conversion in ISO-format as an argument, i.e. 2015-12-23\n";
    exit 1;
}

if ( ! $confirm ) {
    print STDERR "Testing only, no changes to the database will be made. Use -c switch to write to database.\n";
}

my @item;
my @datelastborrowed;
my @datelastseen;

my $datelastborrowed_month;
my $datelastseen_month;

my $today = strftime "%Y-%m-%d", localtime();

my $sth = $dbh->prepare( "SELECT itemnumber,datelastborrowed,datelastseen FROM items WHERE replacementpricedate='$conversiondate' AND datelastborrowed IS NOT NULL;");
   $sth->execute();

while ( @item = $sth->fetchrow_array() ) {

    # Handle datelastborrowed
    @datelastborrowed = split( '-', $item[1] );

    if ( $item[1] lt $pallasconversiondate || checkstatistics( $item[0] ) == 0 ) {
        $datelastborrowed[1]++;
        $datelastborrowed[1] = 12 if ( $datelastborrowed[1] > 12 ); # This shouldn't happen, but make sure just in case...
        $datelastborrowed[1] = sprintf( "%02d", $datelastborrowed[1] );
        print STDERR "Changing item $item[0] datelastborrowed $item[1] -> $datelastborrowed[0]-$datelastborrowed[1]-$datelastborrowed[2].\n";
        if ( $confirm ) {
            $dbh->do( "UPDATE items SET datelastborrowed='$datelastborrowed[0]-$datelastborrowed[1]-$datelastborrowed[2]' WHERE itemnumber='$item[0]';" );
        }
        else {
            print "UPDATE items SET datelastborrowed='$datelastborrowed[0]-$datelastborrowed[1]-$datelastborrowed[2]' WHERE itemnumber='$item[0]';\n";
        }
    }
    elsif ( $item[1] gt $today || $datelastborrowed[1] == 0 ) {
        print STDERR "Changing item $item[0] datelastborrowed $item[1] -> null.\n";
        if ( $confirm ) {
            $dbh->do( "UPDATE items SET datelastborrowed=null WHERE itemnumber='$item[0]';" );
        }
        else {
            print "UPDATE items SET datelastborrowed=null WHERE itemnumber='$item[0]';\n";
        }
    }
    else {
        print STDERR "Skipping item $item[0] datelastborrowed $item[1] (no change).\n";
    }

    # Handle datelastseen
    @datelastseen = split( '-', $item[2] );

    if ( $item[2] lt $pallasconversiondate || checkstatistics( $item[0] ) == 0 ) {
        $datelastseen[1]++ ;
        $datelastseen[1] = 12 if ( $datelastseen[1] > 12 ); # This shouldn't happen, but make sure just in case...
        $datelastseen[1] = sprintf( "%02d", $datelastseen[1] );
        print STDERR "Changing item $item[0] datelastseen $item[2] -> $datelastseen[0]-$datelastseen[1]-$datelastseen[2].\n";
        if ( $confirm ) {
            $dbh->do( "UPDATE items SET datelastseen='$datelastseen[0]-$datelastseen[1]-$datelastseen[2]' WHERE itemnumber='$item[0]';" );
        }
        else {
            print "UPDATE items SET datelastseen='$datelastseen[0]-$datelastseen[1]-$datelastseen[2]' WHERE itemnumber='$item[0]';\n";
        }
    }
    elsif ( $item[2] gt $today || $datelastseen[2] == 0 ) {
        print STDERR "Changing item $item[0] datelastseen $item[2] -> null.\n";
        if ( $confirm ) {
            $dbh->do( "UPDATE items SET datelastseen=null WHERE itemnumber='$item[0]';" );
        }
        else {
            print "UPDATE items SET datelastseen=null WHERE itemnumber='$item[0]';\n";
        }
    }
    else {
        print STDERR "Skipping item $item[0] datelastseen $item[2] (no change).\n";
    }

}

exit 0;
