package Koha::REST::V1::CirculationRules;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::CirculationRules;

=head1 API

=head2 Methods

=head3 get_kinds

List all available circulation rules that can be used.

=cut

sub get_kinds {
    my $c = shift->openapi->valid_input or return;

    return $c->render(
        status  => 200,
        openapi => Koha::CirculationRules->rule_kinds,
    );
}

=head3 list_effective_rules

List all effective rules for the requested patron/item/branch combination

=cut

sub list_effective_rules {
    my $c = shift->openapi->valid_input or return;

    my $item_type       = $c->param('item_type_id');
    my $branchcode      = $c->param('library_id');
    my $patron_category = $c->param('patron_category_id');
    my $rules           = $c->param('rules') // [ keys %{ Koha::CirculationRules->rule_kinds } ];

    if ($item_type) {
        my $type = Koha::ItemTypes->find($item_type);
        return $c->render_invalid_parameter_value(
            {
                path   => '/query/item_type',
                values => {
                    uri   => '/api/v1/item_types',
                    field => 'item_type_id'
                }
            }
        ) unless $type;
    }

    if ($branchcode) {
        my $library = Koha::Libraries->find($branchcode);
        return $c->render_invalid_parameter_value(
            {
                path   => '/query/library',
                values => {
                    uri   => '/api/v1/libraries',
                    field => 'library_id'
                }
            }
        ) unless $library;
    }

    if ($patron_category) {
        my $category = Koha::Patron::Categories->find($patron_category);
        return $c->render_invalid_parameter_value(
            {
                path   => '/query/patron_category',
                values => {
                    uri   => '/api/v1/patron_categories',
                    field => 'patron_category_id'
                }
            }
        ) unless $category;
    }

    my $effective_rules = Koha::CirculationRules->get_effective_rules(
        {
            categorycode => $patron_category,
            itemtype     => $item_type,
            branchcode   => $branchcode,
            rules        => $rules
        }
    );

    return $c->render(
        status  => 200,
        openapi => $effective_rules ? $effective_rules : {}
    );
}

1;
