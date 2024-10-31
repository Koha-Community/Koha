package Koha::REST::V1::ExtendedAttributeTypes;

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

# IMPORTANT NOTE
#
# Whilst this class is named ExtendedAttributeTypes, it currently
# allows for querying the Koha::AdditionalFields objects only.
#
# The longer term goal is to merge the additional fields, patron
# attributes and ill request attributes features into one system.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::AdditionalFields;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $resource_type = $c->param('resource_type');

    # FIXME: Maybe not the best place for this mapping
    my $resource_to_table = {
        basket    => 'aqbasket',
        credit    => 'accountlines:credit',
        debit     => 'accountlines:debit',
        invoice   => 'aqinvoices',
        license   => 'erm_licenses',
        agreement => 'erm_agreements',
        package   => 'erm_packages',
        order     => 'aqorders',
    };

    return try {
        my $additional_fields_set = Koha::AdditionalFields->new;
        if ( $resource_type && $resource_to_table->{$resource_type} ) {
            $additional_fields_set =
                $additional_fields_set->search( { tablename => $resource_to_table->{$resource_type} } );
        } elsif ($resource_type) {
            $additional_fields_set = $additional_fields_set->search( { tablename => $resource_type } );
        } else {
            $additional_fields_set = $additional_fields_set->search();
        }

        return $c->render(
            status  => 200,
            openapi => $c->objects->search($additional_fields_set)
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
