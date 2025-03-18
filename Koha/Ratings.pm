package Koha::Ratings;

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

use Koha::Rating;

use base qw(Koha::Objects);

=head1 NAME

Koha::Ratings - Koha Rating Object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_avg_rating

=cut

sub get_avg_rating {
    my ($self) = @_;

    my $sum   = $self->_resultset->get_column('rating_value')->sum();
    my $total = $self->count();

    my $avg = 0;
    if ( $sum and $total ) {
        eval { $avg = $sum / $total };
    }
    $avg = sprintf( "%.1f", $avg );

    return $avg;
}

=head3 type

=cut

sub _type {
    return 'Rating';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Rating';
}

1;
