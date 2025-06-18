package Koha::DateTime::Format::RFC3339;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::DateTime::Format::RFC3339 - Parse and format RFC3339 dates

=head1 SYNOPSIS

    $datetime = Koha::DateTime::Format::RFC3339->parse_datetime($rfc3339_datetime_string);
    $rfc3339_datetime_string = Koha::DateTime::Format::RFC3339->format_datetime($datetime);

=head1 API

=head2 Class methods

=head3 parse_datetime

Parse an RFC3339 datetime string and returns a corresponding L<DateTime> object

    $datetime = Koha::DateTime::Format::RFC3339->parse_datetime($rfc3339_datetime_string);

=cut

use Modern::Perl;

use DateTime::Format::Builder (
    parsers => {
        parse_datetime => [
            {
                params => [qw( year month day hour minute second time_zone )],
                regex  =>
                    qr/^(\d{4})-(\d{2})-(\d{2})[Tt\s](\d{2}):(\d{2}):(\d{2})(?:\.\d{1,3})?([Zz]|(?:[\+|\-](?:[01][0-9]|2[0-3]):[0-5][0-9]))$/,
                postprocess => \&_postprocess_datetime,
            },
        ],
    }
);

=head3 format_datetime

Format a L<DateTime> object into an RFC3339 datetime string

    $rfc3339_datetime_string = Koha::DateTime::Format::RFC3339->format_datetime($datetime);

=cut

sub format_datetime {
    my ( $class, $dt ) = @_;

    my $date = $dt->strftime('%FT%T%z');
    substr( $date, -2, 0, ':' );    # timezone "HHmm" => "HH:mm"

    return $date;
}

=head2 Internal methods

=head3 _postprocess_datetime

Called by C<parse_datetime> after parsing the datetime string.

It allows to change C<DateTime::new> parameters just before C<parse_datetime>
calls it.

=cut

sub _postprocess_datetime {
    my %args   = @_;
    my $parsed = $args{parsed};

    # system allows the 0th of the month
    $parsed->{day} = '01' if $parsed->{day} eq '00';

    $parsed->{time_zone} = 'UTC' if $parsed->{time_zone} =~ /^[Zz]$/;

    return 1;
}

1;
