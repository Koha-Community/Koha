package Koha::Patron::Relationships;

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

use List::MoreUtils qw( uniq );

use Koha::Database;
use Koha::Patrons;
use Koha::Patron::Relationship;

use base qw(Koha::Objects);

=head1 NAME

Koha::Patron::Relationships - Koha Patron Relationship Object set class

=head1 API

=head2 Class Methods

=cut

=head3 guarantors

Returns all the guarantors in this set of relationships as a list of Koha::Patron objects
or as a Koha::Patrons object depending on the calling context

=cut

sub guarantors {
    my ($self) = @_;

    my $rs = $self->_resultset();

    my @guarantor_ids = $rs->get_column('guarantor_id')->all();

    # Guarantors may not have a guarantor_id, strip out undefs
    @guarantor_ids = grep { defined $_ } @guarantor_ids;
    @guarantor_ids = uniq(@guarantor_ids);

    return Koha::Patrons->search( { borrowernumber => \@guarantor_ids } );
}

=head3 guarantees

Returns all the guarantees in this set of relationships as a list of Koha::Patron objects
or as a Koha::Patrons object depending on the calling context

=cut

sub guarantees {
    my ($self) = @_;

    my $rs = $self->_resultset();

    my @guarantee_ids = uniq( $rs->get_column('guarantee_id')->all() );

    return Koha::Patrons->search(
        { borrowernumber => \@guarantee_ids },
        { order_by       => { -asc => [ 'surname', 'firstname' ] } },
    );
}

=head3 type

=cut

sub _type {
    return 'BorrowerRelationship';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Patron::Relationship';
}

1;
