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

=head3 list_rules

Get effective rules for the requested patron/item/branch combination

=cut

sub list_rules {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $effective       = $c->param('effective') // 1;
        my $kinds           = $c->param('rules')     // [ keys %{ Koha::CirculationRules->rule_kinds } ];
        my $item_type       = $c->param('item_type_id');
        my $branchcode      = $c->param('library_id');
        my $patron_category = $c->param('patron_category_id');
        my ( $filter_branch, $filter_itemtype, $filter_patron );

        if ($item_type) {
            $filter_itemtype = 1;
            if ( $item_type eq '*' ) {
                $item_type = undef;
            } else {
                my $type = Koha::ItemTypes->find($item_type);
                return $c->render_invalid_parameter_value(
                    {
                        path   => '/query/item_type_id',
                        values => {
                            uri   => '/api/v1/item_types',
                            field => 'item_type_id'
                        }
                    }
                ) unless $type;
            }
        }

        if ($branchcode) {
            $filter_branch = 1;
            if ( $branchcode eq '*' ) {
                $branchcode = undef;
            } else {
                my $library = Koha::Libraries->find($branchcode);
                return $c->render_invalid_parameter_value(
                    {
                        path   => '/query/library_id',
                        values => {
                            uri   => '/api/v1/libraries',
                            field => 'library_id'
                        }
                    }
                ) unless $library;
            }
        }

        if ($patron_category) {
            $filter_patron = 1;
            if ( $patron_category eq '*' ) {
                $patron_category = undef;
            } else {
                my $category = Koha::Patron::Categories->find($patron_category);
                return $c->render_invalid_parameter_value(
                    {
                        path   => '/query/patron_category_id',
                        values => {
                            uri   => '/api/v1/patron_categories',
                            field => 'patron_category_id'
                        }
                    }
                ) unless $category;
            }
        }

        my $rules;
        if ($effective) {

            my $effective_rules = Koha::CirculationRules->get_effective_rules(
                {
                    categorycode => $patron_category,
                    itemtype     => $item_type,
                    branchcode   => $branchcode,
                    rules        => $kinds
                }
            ) // {};
            my $return;
            for my $kind ( @{$kinds} ) {
                $return->{$kind} = $effective_rules->{$kind};
            }
            push @{$rules}, $return;
        } else {
            my $select = [
                { 'COALESCE' => [ 'branchcode',   \["'*'"] ], -as => 'branchcode' },
                { 'COALESCE' => [ 'categorycode', \["'*'"] ], -as => 'categorycode' },
                { 'COALESCE' => [ 'itemtype',     \["'*'"] ], -as => 'itemtype' }
            ];
            my $as = [ 'branchcode', 'categorycode', 'itemtype' ];
            for my $kind ( @{$kinds} ) {
                push @{$select}, { max => \[ "CASE WHEN rule_name = ? THEN rule_value END", $kind ], -as => $kind };
                push @{$as}, $kind;
            }

            $rules = Koha::CirculationRules->search(
                {
                    ( $filter_branch   ? ( branchcode   => $branchcode )      : () ),
                    ( $filter_itemtype ? ( itemtype     => $item_type )       : () ),
                    ( $filter_patron   ? ( categorycode => $patron_category ) : () )
                },
                {
                    select   => $select,
                    as       => $as,
                    group_by => [ 'branchcode', 'categorycode', 'itemtype' ]
                }
            )->unblessed;

        }

        return $c->render(
            status  => 200,
            openapi => $rules
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
