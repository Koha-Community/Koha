#!/usr/bin/perl -w

package C4::Date;

use strict;
use C4::Context;
use DateTime;
use DateTime::Format::ISO8601;
use DateTime::Format::Strptime;
use DateTime::Format::Duration;
use POSIX qw(ceil floor);
use Date::Calc
  qw(Parse_Date Decode_Date_EU Decode_Date_US Time_to_Date check_date);

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
  &display_date_format
  &format_date
  &format_date_in_iso
  &get_date_format_string_for_DHTMLcalendar
  &DATE_diff &DATE_Add
  &get_today &DATE_Add_Duration &DATE_obj &get_duration
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

sub format_date {
    my $olddate = shift;
    my $newdate;

    if ( !$olddate ) {
        return "";
    }

    #     warn $olddate;
    #     $olddate=~s#/|\.|-##g;
    my ( $year, $month, $day ) = Parse_Date($olddate);
    ( $year, $month, $day ) = split /-|\/|\.|:/, $olddate
      unless ( $year && $month );

    # 	warn "$olddate annee $year mois $month jour $day";
    if ( $year > 0 && $month > 0 ) {
        my $dateformat = get_date_format();
        $dateformat = "metric" if ( index( ":", $olddate ) > 0 );
        if ( $dateformat eq "us" ) {
            $newdate = sprintf( "%02d/%02d/%04d", $month, $day, $year );
        }
        elsif ( $dateformat eq "metric" ) {
            $newdate = sprintf( "%02d/%02d/%04d", $day, $month, $year );
        }
        elsif ( $dateformat eq "iso" ) {

            # 		Date_Init("DateFormat=iso");
            $newdate = sprintf( "%04d-%02d-%02d", $year, $month, $day );
        }
        else {
            return
"Invalid date format: $dateformat. Please change in system preferences";
        }

        #       warn "newdate :$newdate";
    }
    return $newdate;
}

sub format_date_in_iso {
    my $olddate = shift;
    my $newdate;

    if ( !$olddate ) {
        return "";
    }

    my $dateformat = get_date_format();
    my ( $year, $month, $day );
    my @date;
    my $tmpolddate = $olddate;
    $tmpolddate =~ s#/|\.|-|\\##g;
    $dateformat = "metric" if ( index( ":", $olddate ) > 0 );
    if ( $dateformat eq "us" ) {
        ( $month, $day, $year ) = split /-|\/|\.|:/, $olddate
          unless ( $year && $month );
        if ( $month > 0 && $day > 0 ) {
            @date = Decode_Date_US($tmpolddate);
        }
        else {
            @date = ( $year, $month, $day );
        }
    }
    elsif ( $dateformat eq "metric" ) {
        ( $day, $month, $year ) = split /-|\/|\.|:/, $olddate
          unless ( $year && $month );
        if ( $month > 0 && $day > 0 ) {
            @date = Decode_Date_EU($tmpolddate);
        }
        else {
            @date = ( $year, $month, $day );
        }
    }
    elsif ( $dateformat eq "iso" ) {
        ( $year, $month, $day ) = split /-|\/|\.|:/, $olddate
          unless ( $year && $month );
        if ( $month > 0 && $day > 0 ) {
            @date = ( $year, $month, $day )
              if ( check_date( $year, $month, $day ) );
        }
        else {
            @date = ( $year, $month, $day );
        }
    }
    else {
        return "9999-99-99";
    }

    $newdate = sprintf( "%04d-%02d-%02d", $date[0], $date[1], $date[2] );

    return $newdate;
}

sub DATE_diff {
## returns 1 if date1>date2 0 if date1==date2 -1 if date1<date2
    my ( $date1, $date2 ) = @_;
    my $dt1  = DateTime::Format::ISO8601->parse_datetime($date1);
    my $dt2  = DateTime::Format::ISO8601->parse_datetime($date2);
    my $diff = DateTime->compare( $dt1, $dt2 );
    return $diff;
}

sub DATE_Add {
## $amount in days
    my ( $date, $amount ) = @_;
    my $dt1 = DateTime::Format::ISO8601->parse_datetime($date);
    $dt1->add( days => $amount );
    return $dt1->ymd;
}

sub DATE_Add_Duration {
## Similar as above but uses Duration object as amount --used heavily in serials
    my ( $date, $amount ) = @_;
    my $dt1 = DateTime::Format::ISO8601->parse_datetime($date);
    $dt1->add_duration($amount);
    return $dt1->ymd;
}

sub get_today {
    my $dt = DateTime->today;
    return $dt->ymd;
}

sub DATE_obj {

    # only send iso dates to this
    my $date    = shift;
    my $parser  = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d' );
    my $newdate = $parser->parse_datetime($date);
    return $newdate;
}

sub get_duration {
    my $period = shift;

    my $parse;
    if ( $period =~ /ays/ ) {
        $parse = "\%e days";
    }
    elsif ( $period =~ /week/ ) {
        $parse = "\%W weeks";
    }
    elsif ( $period =~ /year/ ) {
        $parse = "\%Y years";
    }
    elsif ( $period =~ /onth/ ) {
        $parse = "\%m months";
    }

    my $parser   = DateTime::Format::Duration->new( pattern => $parse );
    my $duration = $parser->parse_duration($period);

    return $duration;

}

sub DATE_subtract {
    my ( $date1, $date2 ) = @_;
    my $dt1  = DateTime::Format::ISO8601->parse_datetime($date1);
    my $dt2  = DateTime::Format::ISO8601->parse_datetime($date2);
    my $dur  = $dt2->subtract_datetime_absolute($dt1);             ## in seconds
    my $days = $dur->seconds / ( 60 * 60 * 24 );
    return floor($days);
}

1;
