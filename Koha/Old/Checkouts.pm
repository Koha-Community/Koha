package Koha::Old::Checkouts;

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

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Old::Checkout;

use base qw(Koha::Objects);

sub filter_by_todays_checkins {
    my ( $self ) = @_;

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    my $today = dt_from_string;
    my $today_start = $today->clone->set( hour =>  0, minute =>  0, second =>  0 );
    my $today_end   = $today->clone->set( hour => 23, minute => 59, second => 59 );
    $today_start = $dtf->format_datetime( $today_start );
    $today_end   = $dtf->format_datetime( $today_end );
    return $self->search({
        returndate => {
            '>=' => $today_start,
            '<=' => $today_end,
        },
    });
}

sub _type {
    return 'OldIssue';
}

sub object_class {
    return 'Koha::Old::Checkout';
}

1;
