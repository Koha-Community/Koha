package Koha::ERM::EHoldings::Title;

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

use base qw(Koha::Object);

use Koha::ERM::EHoldings::Resources;

=head1 NAME

Koha::ERM::EHoldings::Title - Koha ERM Title Object class

=head1 API

=head2 Class Methods

=head3 resources

Returns the resources linked to this title

=cut

sub resources {
    my ( $self, $resources ) = @_;

    if ( $resources ) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->resources->delete;

                # Cannot use the dbic RS, we need to trigger ->store overwrite
                for my $resource (@$resources) {
                    Koha::ERM::EHoldings::Resource->new(
                        { %$resource, title_id => $self->title_id } )->store;
                }
            }
        );
    }
    my $resources_rs = $self->_result->erm_eholdings_resources;
    return Koha::ERM::EHoldings::Resources->_new_from_dbic($resources_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmEholdingsTitle';
}

1;
