#!/usr/bin/perl

# Copyright 2016 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 2;

use t::lib::TestBuilder;

use Koha::Database;
use Koha::Patron::Attribute;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'opac_display() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron
        = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $attribute_type_1 = $builder->build(
        {   source => 'BorrowerAttributeType',
            value  => { opac_display => 1 }
        }
    );

    my $attribute_1 = Koha::Patron::Attribute->new(
        {   borrowernumber => $patron,
            code           => $attribute_type_1->{code},
            attribute      => $patron
        }
    );
    is( $attribute_1->opac_display, 1, '->opac_display returns 1' );

    my $attribute_type_2 = $builder->build(
        {   source => 'BorrowerAttributeType',
            value  => { opac_display => 0 }
        }
    );

    my $attribute_2 = Koha::Patron::Attribute->new(
        {   borrowernumber => $patron,
            code           => $attribute_type_2->{code},
            attribute      => $patron
        }
    );
    is( $attribute_2->opac_display, 0, '->opac_display returns 0' );

    $schema->storage->txn_rollback;
};

subtest 'opac_editable() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron
        = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $attribute_type_1 = $builder->build(
        {   source => 'BorrowerAttributeType',
            value  => { opac_editable => 1 }
        }
    );

    my $attribute_1 = Koha::Patron::Attribute->new(
        {   borrowernumber => $patron,
            code           => $attribute_type_1->{code},
            attribute      => $patron
        }
    );
    is( $attribute_1->opac_editable, 1, '->opac_editable returns 1' );

    my $attribute_type_2 = $builder->build(
        {   source => 'BorrowerAttributeType',
            value  => { opac_editable => 0 }
        }
    );

    my $attribute_2 = Koha::Patron::Attribute->new(
        {   borrowernumber => $patron,
            code           => $attribute_type_2->{code},
            attribute      => $patron
        }
    );
    is( $attribute_2->opac_editable, 0, '->opac_editable returns 0' );

    $schema->storage->txn_rollback;
};

1;
