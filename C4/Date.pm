#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

# $Id$

package C4::Date;

use strict;
use C4::Context;
use Date::Manip;


require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v ); };

@ISA = qw(Exporter);

@EXPORT = qw(
  &display_date_format
  &format_date
  &format_date_in_iso
  &today
  get_date_format_string_for_DHTMLcalendar
);

sub get_date_format {

    #Get the database handle
    my $dbh = C4::Context->dbh;
    return C4::Context->preference('dateformat');
}

sub display_date_format {
    my $dateformat = get_date_format();

    if ( $dateformat eq "us" ) {
        return "mm/dd/yyyy";
    }
    elsif ( $dateformat eq "metric" ) {
        return "dd/mm/yyyy";
    }
    elsif ( $dateformat eq "iso" ) {
        return "yyyy-mm-dd";
    }
    else {
        return
"Invalid date format: $dateformat. Please change in system preferences";
    }
}

sub get_date_format_string_for_DHTMLcalendar {
    my $dateformat = get_date_format();

    if ( $dateformat eq 'us' ) {
        return '%m/%d/%Y';
    }
    elsif ( $dateformat eq 'metric' ) {
        return '%d/%m/%Y';
    }
    elsif ( $dateformat eq "iso" ) {
        return '%Y-%m-%d';
    }
    else {
        return 'Invalid date format: '
          . $dateformat . '.'
          . ' Please change in system preferences';
    }
}

sub format_date {
    my $olddate = shift;
    my $newdate;

    if ( !$olddate ) {
        return "";
    }

    my $dateformat = get_date_format();

    if ( $dateformat eq "us" ) {
        Date_Init("DateFormat=US");
        $olddate = ParseDate($olddate);
        $newdate = UnixDate( $olddate, '%m/%d/%Y' );
    }
    elsif ( $dateformat eq "metric" ) {
        Date_Init("DateFormat=metric");
        $olddate = ParseDate($olddate);
        $newdate = UnixDate( $olddate, '%d/%m/%Y' );
    }
    elsif ( $dateformat eq "iso" ) {
        Date_Init("DateFormat=iso");
        $olddate = ParseDate($olddate);
        $newdate = UnixDate( $olddate, '%Y-%m-%d' );
    }
    else {
        return
"Invalid date format: $dateformat. Please change in system preferences";
    }
}

sub format_date_in_iso {
    my $olddate = shift;
    my $newdate;

    if ( !$olddate ) {
        return "";
    }

    my $dateformat = get_date_format();

    if ( $dateformat eq "us" ) {
        Date_Init("DateFormat=US");
        $olddate = ParseDate($olddate);
    }
    elsif ( $dateformat eq "metric" ) {
        Date_Init("DateFormat=metric");
        $olddate = ParseDate($olddate);
    }
    elsif ( $dateformat eq "iso" ) {
        Date_Init("DateFormat=iso");
        $olddate = ParseDate($olddate);
    }
    else {
        return "9999-99-99";
    }

    $newdate = UnixDate( $olddate, '%Y-%m-%d' );

    return $newdate;
}


1;
