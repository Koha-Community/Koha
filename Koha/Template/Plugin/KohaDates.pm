package Koha::Template::Plugin::KohaDates;

# Copyright Catalyst IT 2011

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

use Koha::DateUtils;
our $DYNAMIC = 1;

sub filter {
    my ( $self, $text, $args, $config ) = @_;
    return "" unless $text;
    $config->{with_hours} //= 0;

    my $dt = dt_from_string( $text, 'iso' );

    return $config->{as_due_date} ?
        output_pref({ dt => $dt, as_due_date => 1 }) :
        output_pref({ dt => $dt, dateonly => !$config->{with_hours} });
}

1;
