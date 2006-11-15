#!/usr/bin/perl
## written by T Garip 2006-10-10 tgarip@neu.edu.tr
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
use DateTime;
use DateTime::Format::ISO8601;
use DateTime::Format::Strptime;
use DateTime::Format::Duration;
use POSIX qw(ceil floor);
require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v ); };

@ISA = qw(Exporter);

@EXPORT = qw(
  &display_date_format
  &format_date
  &format_date_in_iso
  &get_date_format_string_for_DHTMLcalendar
  &DATE_diff &DATE_Add
&get_today &DATE_Add_Duration &DATE_obj &get_duration
&DATE_subtract
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
    if ( !$olddate || $olddate eq "0000-00-00" ) {
        return "";
    }
		$olddate=~s/-//g;
		my $olddate=substr($olddate,0,8);
    my $dateformat = get_date_format();
eval{$newdate =DateTime::Format::ISO8601->parse_datetime($olddate);};
if ($@ || !$newdate){
##MARC21 tag 008 has this format YYMMDD
my $parser =    DateTime::Format::Strptime->new( pattern => '%y%m%d' );
        $newdate =$parser->parse_datetime($olddate);
}
if (!$newdate){
return ""; #### some script call format_date more than once --FIX scripts
}

    if ( $dateformat eq "us" ) {
      return $newdate->mdy('/');
    
    }
    elsif ( $dateformat eq "metric" ) {
        return $newdate->dmy('/');
    }
    elsif ( $dateformat eq "iso" ) {
        return $newdate->ymd;
    }
    else {
        return
"Invalid date format: $dateformat. Please change in system preferences";
    }

}

sub format_date_in_iso {
    my $olddate = shift;
    my $newdate;
  my $parser;
    if ( !$olddate || $olddate eq "0000-00-00" ) {
        return "";
    }

$parser =    DateTime::Format::Strptime->new( pattern => '%d/%m/%Y' );
        $newdate =$parser->parse_datetime($olddate);
if (!$newdate){
$parser =    DateTime::Format::Strptime->new( pattern => '%m/%d/%Y' );
$newdate =$parser->parse_datetime($olddate);
}
if (!$newdate){
 $parser =    DateTime::Format::Strptime->new( pattern => '%Y-%m-%d' );
$newdate =$parser->parse_datetime($olddate);
}
 if (!$newdate){
 $parser =    DateTime::Format::Strptime->new( pattern => '%y-%m-%d' );
$newdate =$parser->parse_datetime($olddate);
}
  
    return $newdate->ymd if $newdate;
}
sub DATE_diff {
## returns 1 if date1>date2 0 if date1==date2 -1 if date1<date2
my ($date1,$date2)=@_;
my $dt1=DateTime::Format::ISO8601->parse_datetime($date1);
my $dt2=DateTime::Format::ISO8601->parse_datetime($date2);
my $diff=DateTime->compare( $dt1, $dt2 );
return $diff;
}
sub DATE_Add {
## $amount in days
my ($date,$amount)=@_;
my $dt1=DateTime::Format::ISO8601->parse_datetime($date);
$dt1->add( days=>$amount );
return $dt1->ymd;
}
sub DATE_Add_Duration {
## Similar as above but uses Duration object as amount --used heavily in serials
my ($date,$amount)=@_;
my $dt1=DateTime::Format::ISO8601->parse_datetime($date);
$dt1->add_duration($amount) ;
return $dt1->ymd;
}
sub get_today{
my $dt=DateTime->today;
return $dt->ymd;
}

sub DATE_obj{
# only send iso dates to this
my $date=shift;
   my $parser =    DateTime::Format::Strptime->new( pattern => '%Y-%m-%d' );
      my  $newdate =$parser->parse_datetime($date);
return $newdate;
}
sub get_duration{
my $period=shift;

my $parse;
if ($period=~/ays/){
$parse="\%e days";
}elsif ($period=~/week/){
$parse="\%W weeks";
}elsif ($period=~/year/){
$parse="\%Y years";
}elsif ($period=~/onth/){
$parse="\%m months";
}

my $parser=DateTime::Format::Duration->new(pattern => $parse  );
	my $duration=$parser->parse_duration($period);

return $duration;

}
sub DATE_subtract{
my ($date1,$date2)=@_;
my $dt1=DateTime::Format::ISO8601->parse_datetime($date1);
my $dt2=DateTime::Format::ISO8601->parse_datetime($date2);
my $dur=$dt2->subtract_datetime_absolute($dt1);## in seconds
my $days=$dur->seconds/(60*60*24);
return floor($days);
}
1;
