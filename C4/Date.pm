package C4::Date;
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
use C4::Context;
use Date::Calc qw(Parse_Date Decode_Date_EU Decode_Date_US Time_to_Date check_date);

require Exporter;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION = 0.01;

@ISA = qw(Exporter);

@EXPORT = qw(
             &display_date_format
             &get_date_format_string_for_DHTMLcalendar
             &format_date
             &format_date_in_iso
             &fixdate
);


sub get_date_format
{
	#Get the database handle
	my $dbh = C4::Context->dbh;
	return C4::Context->preference('dateformat');
}

sub display_date_format
{
	my $dateformat = get_date_format();

	if ( $dateformat eq "us" )
	{
		return "mm/dd/yyyy";
	}
	elsif ( $dateformat eq "metric" )
	{
		return "dd/mm/yyyy";
	}
	elsif ( $dateformat eq "iso" )
	{
		return "yyyy-mm-dd";
	}
	else
	{
		return "Invalid date format: $dateformat. Please change in system preferences";
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

sub format_date
{
	my $olddate = shift;
	my $newdate;

	if ( ! $olddate )
	{
		return "";
	}

#     warn $olddate;
#     $olddate=~s#/|\.|-##g;
    my ($year,$month,$day)=Parse_Date($olddate);
    ($year,$month,$day)=split /-|\/|\.|:/,$olddate unless ($year && $month);
# 	warn "$olddate annee $year mois $month jour $day";
    if ($year>0 && $month>0){
      my $dateformat = get_date_format();
      $dateformat="metric" if (index(":",$olddate)>0);
      if ( $dateformat eq "us" )
      {
          $newdate = sprintf("%02d/%02d/%04d",$month,$day,$year);
      }
      elsif ( $dateformat eq "metric" )
      {
          $newdate = sprintf("%02d/%02d/%04d",$day,$month,$year);
      }
      elsif ( $dateformat eq "iso" )
      {
  # 		Date_Init("DateFormat=iso");
          $newdate = sprintf("%04d-%02d-%02d",$year,$month,$day);
      }
      else
      {
          return "Invalid date format: $dateformat. Please change in system preferences";
      }
#       warn "newdate :$newdate";
    }
    return $newdate;
}

sub format_date_in_iso
{
    my $olddate = shift;
    my $newdate;

    if ( ! $olddate )
    {
            return "";
    }
    if (check_whether_iso($olddate)){
      return $olddate;
    } else {
      my $dateformat = get_date_format();
      my ($year,$month,$day);
      my @date;
      my $tmpolddate=$olddate;
      $tmpolddate=~s#/|\.|-|\\##g;
      $dateformat="metric" if (index(":",$olddate)>0);
      if ( $dateformat eq "us" )
      {
        ($month,$day,$year)=split /-|\/|\.|:/,$olddate unless ($year && $month);
        if ($month>0 && $day >0){
              @date = Decode_Date_US($tmpolddate);
        } else {
          @date=($year, $month,$day)
        }
      }
      elsif ( $dateformat eq "metric" )
      {
        ($day,$month,$year)=split /-|\/|\.|:/,$olddate unless ($year && $month);
        if ($month>0 && $day >0){
              @date = Decode_Date_EU($tmpolddate);
        } else {
          @date=($year, $month,$day)
        }
      }
      elsif ( $dateformat eq "iso" )
      {
        ($year,$month,$day)=split /-|\/|\.|:/,$olddate unless ($year && $month);
        if ($month>0 && $day >0){
          @date=($year, $month,$day) if (check_date($year,$month,$day));
        } else {
          @date=($year, $month,$day)
        }
      }
      else
      {
          return "9999-99-99";
      }
      $newdate = sprintf("%04d-%02d-%02d",$date[0],$date[1],$date[2]);
      return $newdate;
    }
}

sub check_whether_iso
{
    my $olddate = shift;
    my @olddate= split /\-/,$olddate ;
    return 1 if (length($olddate[0])==4 && length($olddate[1])<=2 && length($olddate[2])<=2);
    return 0;
}

=head2 fixdate

( $date, $invalidduedate ) = fixdate( $year, $month, $day );

=cut

sub fixdate {
    my ( $year, $month, $day ) = @_;
    my $invalidduedate;
    my $date;
    if ( $year && $month && $day ) {
        if ( ( $year eq 0 ) && ( $month eq 0 ) && ( $year eq 0 ) ) {
        }
        else {
            if ( ( $year eq 0 ) || ( $month eq 0 ) || ( $year eq 0 ) ) {
                $invalidduedate = 1;
            }
            else {
                if (
                    ( $day > 30 )
                    && (   ( $month == 4 )
                        || ( $month == 6 )
                        || ( $month == 9 )
                        || ( $month == 11 ) )
                  )
                {
                    $invalidduedate = 1;
                }
                elsif ( ( $day > 29 ) && ( $month == 2 ) ) {
                    $invalidduedate = 1;
                }
                elsif (
                       ( $month == 2 )
                    && ( $day > 28 )
                    && (   ( $year % 4 )
                        && ( ( !( $year % 100 ) || ( $year % 400 ) ) ) )
                  )
                {
                    $invalidduedate = 1;
                }
                else {
                    $date = "$year-$month-$day";
                }
            }
        }
    }
    return ( $date, $invalidduedate );
}

1;
