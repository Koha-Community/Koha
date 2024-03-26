package Koha::DateTime::Format::SQL;

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

=head1 NAME

Koha::DateTime::Format::SQL - Parse SQL dates

=head1 SYNOPSIS

    $datetime = Koha::DateTime::Format::SQL->parse_datetime($sql_datetime_string);

=cut

use Modern::Perl;

use DateTime::Format::MySQL;

use Koha::Config;

our $timezone;

=head1 API

=head2 Class methods

=head3 parse_datetime

Parse an SQL datetime string and returns a corresponding L<DateTime> object

    $datetime = Koha::DateTime::Format::SQL->parse_datetime($rfc3339_datetime_string);

DateTime's time zone is automatically set to the configured timezone (or
'local' if none is configured), unless the year is 9999 in which case the
timezone is 'floating'.

=cut

sub parse_datetime {
    my ( $class, $date ) = @_;

    my $dt = DateTime::Format::MySQL->parse_datetime($date);

    # No TZ for dates 'infinite' => see bug 13242
    if ( $dt->year < 9999 ) {
        $timezone //= Koha::Config->get_instance->timezone;
        $dt->set_time_zone($timezone);
    }

    return $dt;
}

1;
