package Koha::DateUtils;

# Copyright (c) 2011 PTFS-Europe Ltd.
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
# Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use DateTime;
use C4::Context;
use Carp;

use base 'Exporter';

our @EXPORT = (
    qw( dt_from_string output_pref format_sqldatetime )
);

=head1 DateUtils

Koha::DateUtils - Transitional wrappers to ease use of DateTime

=head1 DESCRIPTION

Koha has historically only used dates not datetimes and been content to
handle these as strings. It also has confused formatting with actual dates
this is a temporary module for wrappers to hide the complexity of switch to DateTime

=cut

=head2 dt_ftom_string

$dt = dt_from_string($date_string, [$format, $timezone ]);

Passed a date string returns a DateTime object format and timezone default
to the system preferences. If the date string is empty DateTime->now is returned

=cut

sub dt_from_string {
    my ( $date_string, $date_format, $tz ) = @_;

    return if $date_string and $date_string =~ m|^0000-0|;

    $tz = C4::Context->tz unless $tz;;

    return DateTime->now( time_zone => $tz ) unless $date_string;

    $date_format = C4::Context->preference('dateformat') unless $date_format;

    if ( ref($date_string) eq 'DateTime' ) {    # already a dt return it
        return $date_string;
    }

    my $regex;

    # The fallback format is sql/iso
    my $fallback_re = qr|
        (?<year>\d{4})
        -
        (?<month>\d{2})
        -
        (?<day>\d{2})
    |xms;

    if ( $date_format eq 'metric' ) {
        # metric format is "dd/mm/yyyy[ hh:mm:ss]"
        $regex = qr|
            (?<day>\d{2})
            /
            (?<month>\d{2})
            /
            (?<year>\d{4})
        |xms;
    }
    elsif ( $date_format eq 'dmydot' ) {
        # dmydot format is "dd.mm.yyyy[ hh:mm:ss]"
        $regex = qr|
            (?<day>\d{2})
            .
            (?<month>\d{2})
            .
            (?<year>\d{4})
        |xms;
    }
    elsif ( $date_format eq 'us' ) {
        # us format is "mm/dd/yyyy[ hh:mm:ss]"
        $regex = qr|
            (?<month>\d{2})
            /
            (?<day>\d{2})
            /
            (?<year>\d{4})
        |xms;
    }
    elsif ( $date_format eq 'iso' or $date_format eq 'sql' ) {
        # iso or sql format are yyyy-dd-mm[ hh:mm:ss]"
        $regex = $fallback_re;
    }
    else {
        die "Invalid dateformat parameter ($date_format)";
    }

    # Add the faculative time part [hh:mm[:ss]]
    my $time_re .= qr|
            (
                \s*
                (?<hour>\d{2})
                :
                (?<minute>\d{2})
                (
                    :
                    (?<second>\d{2})
                )?
            )?
    |xms;
    $regex .= $time_re;
    $fallback_re .= $time_re;

    my %dt_params;
    if ( $date_string =~ $regex ) {
        %dt_params = (
            year   => $+{year},
            month  => $+{month},
            day    => $+{day},
            hour   => $+{hour},
            minute => $+{minute},
            second => $+{second},
        );
    } elsif ( $date_string =~ $fallback_re ) {
        %dt_params = (
            year   => $+{year},
            month  => $+{month},
            day    => $+{day},
            hour   => $+{hour},
            minute => $+{minute},
            second => $+{second},
        );
    }
    else {
        die "The given date ($date_string) does not match the date format ($date_format)";
    }

    # system allows the 0th of the month
    $dt_params{day} = '01' if $dt_params{day} eq '00';

    # Set default hh:mm:ss to 00:00:00
    $dt_params{hour}   = 00 unless defined $dt_params{hour};
    $dt_params{minute} = 00 unless defined $dt_params{minute};
    $dt_params{second} = 00 unless defined $dt_params{second};

    my $dt = eval {
        DateTime->new(
            %dt_params,
            # No TZ for dates 'infinite' => see bug 13242
            ( $dt_params{year} < 9999 ? ( time_zone => $tz->name ) : () ),
        );
    };
    if ($@) {
        $tz = DateTime::TimeZone->new( name => 'floating' );
        $dt = DateTime->new(
            %dt_params,
            # No TZ for dates 'infinite' => see bug 13242
            ( $dt_params{year} < 9999 ? ( time_zone => $tz->name ) : () ),
        );
    }
    return $dt;
}

=head2 output_pref

$date_string = output_pref({ dt => $dt [, dateformat => $date_format, timeformat => $time_format, dateonly => 0|1, as_due_date => 0|1 ] });
$date_string = output_pref( $dt );

Returns a string containing the time & date formatted as per the C4::Context setting,
or C<undef> if C<undef> was provided.

This routine can either be passed a DateTime object or or a hashref.  If it is
passed a hashref, the expected keys are a mandatory 'dt' for the DateTime,
an optional 'dateformat' to override the dateformat system preference, an
optional 'timeformat' to override the TimeFormat system preference value,
and an optional 'dateonly' to specify that only the formatted date string
should be returned without the time.

=cut

sub output_pref {
    my $params = shift;
    my ( $dt, $str, $force_pref, $force_time, $dateonly, $as_due_date );
    if ( ref $params eq 'HASH' ) {
        $dt         = $params->{dt};
        $str        = $params->{str};
        $force_pref = $params->{dateformat};         # if testing we want to override Context
        $force_time = $params->{timeformat};
        $dateonly   = $params->{dateonly} || 0;    # if you don't want the hours and minutes
        $as_due_date = $params->{as_due_date} || 0; # don't display the hours and minutes if eq to 23:59 or 11:59 (depending the TimeFormat value)
    } else {
        $dt = $params;
    }

    carp "output_pref should not be called with both dt and str parameters"
        and return
            if $dt and $str;

    $dt = eval { dt_from_string( $str ) } if $str;
    carp "Invalid date '$str' passed to output_pref\n" if $@;

    return unless defined $dt;

    # FIXME: see bug 13242 => no TZ for dates 'infinite'
    if ( $dt->ymd !~ /^9999/ ) {
        my $tz = $dateonly ? DateTime::TimeZone->new(name => 'floating') : C4::Context->tz;
        $dt->set_time_zone( $tz );
    }

    my $pref =
      defined $force_pref ? $force_pref : C4::Context->preference('dateformat');

    my $time_format = $force_time || C4::Context->preference('TimeFormat') || q{};
    my $time = ( $time_format eq '12hr' ) ? '%I:%M %p' : '%H:%M';
    my $date;
    if ( $pref =~ m/^iso/ ) {
        $date = $dateonly
          ? $dt->strftime("%Y-%m-%d")
          : $dt->strftime("%Y-%m-%d $time");
    }
    elsif ( $pref =~ m/^metric/ ) {
        $date = $dateonly
          ? $dt->strftime("%d/%m/%Y")
          : $dt->strftime("%d/%m/%Y $time");
    }
    elsif ( $pref =~ m/^dmydot/ ) {
        $date = $dateonly
          ? $dt->strftime("%d.%m.%Y")
          : $dt->strftime("%d.%m.%Y $time");
    }

    elsif ( $pref =~ m/^us/ ) {
        $date = $dateonly
          ? $dt->strftime("%m/%d/%Y")
          : $dt->strftime("%m/%d/%Y $time");
    }
    else {
        $date = $dateonly
          ? $dt->strftime("%Y-%m-%d")
          : $dt->strftime("%Y-%m-%d $time");
    }

    if ( $as_due_date ) {
        $time_format eq '12hr'
            ? $date =~ s| 11:59 PM$||
            : $date =~ s| 23:59$||;
    }

    return $date;
}

=head2 format_sqldatetime

$string = format_sqldatetime( $string_as_returned_from_db );

a convenience routine for calling dt_from_string and formatting the result
with output_pref as it is a frequent activity in scripts

=cut

sub format_sqldatetime {
    my $str        = shift;
    my $force_pref = shift;    # if testing we want to override Context
    my $force_time = shift;
    my $dateonly   = shift;

    if ( defined $str && $str =~ m/^\d{4}-\d{2}-\d{2}/ ) {
        my $dt = dt_from_string( $str, 'sql' );
        return q{} unless $dt;
        $dt->truncate( to => 'minute' );
        return output_pref({
            dt => $dt,
            dateformat => $force_pref,
            timeformat => $force_time,
            dateonly => $dateonly
        });
    }
    return q{};
}

1;
