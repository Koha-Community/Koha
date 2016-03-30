#!/usr/bin/perl

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

use Test::More;
use Koha::Database;

my @modules = (
    [ qw( Borrower Deletedborrower ) ],
    [ qw( Biblio Deletedbiblio ) ],
    [ qw( Biblioitem Deletedbiblioitem ) ],
    [ qw( Item Deleteditem ) ],
);

my @keys_to_check = qw( size is_nullable data_type accessor datetime_undef_if_invalid default_value );

for my $modules ( @modules ) {
    my $rs_1 = Koha::Database->new->schema->resultset($modules->[0]);
    my $rs_2 = Koha::Database->new->schema->resultset($modules->[1]);
    my $col_infos_1 = $rs_1->result_source->columns_info;
    my $col_infos_2 = $rs_2->result_source->columns_info;
    while ( my ( $column_name, $column_infos ) = each %$col_infos_1 ) {
        while ( my ( $column_attribute, $value ) = each %$column_infos ) {
            if ( grep {$_ eq $column_attribute} @keys_to_check ) {
                my $val_1 = $col_infos_1->{$column_name}{$column_attribute};
                my $val_2 = $col_infos_2->{$column_name}{$column_attribute};
                # Dereference if we got a reference to a scalar
                if ( ref($val_1) eq 'SCALAR' ) {
                    $val_1 = ${$val_1};
                    $val_2 = ${$val_2};
                }

                if ( ref($val_1) eq 'ARRAY') {
                    is_deeply( $val_1, $val_2,
                        "tables related to $modules->[0] and $modules->[1] should not differ on $column_name.$column_attribute"
                    );
                } else {
                    is( $val_1, $val_2,
                        "tables related to $modules->[0] and $modules->[1] should not differ on $column_name.$column_attribute"
                    );
                }
            }
        }
    }
}

done_testing();

1;
