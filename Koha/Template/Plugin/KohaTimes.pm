package Koha::Template::Plugin::KohaTimes;

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

use Modern::Perl;
use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

our $DYNAMIC = 1;

sub filter {
    my ( $self, $text, $args, $config ) = @_;
    return "" unless $text;

    my ( $hours, $minutes, $seconds ) = split( ':', $text );
    if ( C4::Context->preference('TimeFormat') eq "12hr" ) {
        my $ampm = ( $hours >= 12 ) ? 'pm' : 'am';
        $hours = ( $hours == 0 ) ? "12"            : $hours;
        $hours = ( $hours > 12 ) ? ( $hours - 12 ) : $hours;
        $hours = sprintf '%.2u', $hours;

        return "$hours:$minutes $ampm";
    } else {
        return "$hours:$minutes";
    }
}

1;
