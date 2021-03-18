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
use Test::Exception;

use Koha::Database;
use Koha::Patron::Attribute;
use Koha::Patron::Attributes;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'store() tests' => sub {

    plan tests => 3;

    subtest 'repeatable attributes tests' => sub {

        plan tests => 5;

        $schema->storage->txn_begin;

        my $patron = $builder->build( { source => 'Borrower' } )->{borrowernumber};
        my $attribute_type_1 = $builder->build(
            {   source => 'BorrowerAttributeType',
                value  => { repeatable => 1 }
            }
        );
        Koha::Patron::Attribute->new(
            {   borrowernumber => $patron,
                code           => $attribute_type_1->{code},
                attribute      => 'Foo'
            }
        )->store;
        Koha::Patron::Attribute->new(
            {   borrowernumber => $patron,
                code           => $attribute_type_1->{code},
                attribute      => 'Bar'
            }
        )->store;
        my $attr_count
            = Koha::Patron::Attributes->search(
            { borrowernumber => $patron, code => $attribute_type_1->{code} } )
            ->count;
        is( $attr_count, 2,
            '2 repeatable attributes stored and retrieved correcctly' );

        my $attribute_type_2 = $builder->build(
            {   source => 'BorrowerAttributeType',
                value  => { repeatable => 0 }
            }
        );

        Koha::Patron::Attribute->new(
            {   borrowernumber => $patron,
                code           => $attribute_type_2->{code},
                attribute      => 'Foo'
            }
        )->store;
        throws_ok {
            Koha::Patron::Attribute->new(
                {   borrowernumber => $patron,
                    code           => $attribute_type_2->{code},
                    attribute      => 'Bar'
                }
            )->store;
        }
        'Koha::Exceptions::Patron::Attribute::NonRepeatable',
            'Exception thrown trying to store more than one non-repeatable attribute';

        is(
            "$@",
            "Tried to add more than one non-repeatable attributes. type="
            . $attribute_type_2->{code}
            . " value=Bar",
            'Exception stringified correctly, attribute passed correctly'
        );

        my $attributes = Koha::Patron::Attributes->search(
            { borrowernumber => $patron, code => $attribute_type_2->{code} } );
        is( $attributes->count, 1, '1 non-repeatable attribute stored' );
        is( $attributes->next->attribute,
            'Foo', 'Non-repeatable attribute remains unchanged' );

        $schema->storage->txn_rollback;
    };

    subtest 'unique_id attributes tests' => sub {

        plan tests => 5;

        $schema->storage->txn_begin;

        my $patron_1 = $builder->build( { source => 'Borrower' } )->{borrowernumber};
        my $patron_2 = $builder->build( { source => 'Borrower' } )->{borrowernumber};

        my $attribute_type_1 = $builder->build(
            {   source => 'BorrowerAttributeType',
                value  => { unique_id => 0 }
            }
        );
        Koha::Patron::Attribute->new(
            {   borrowernumber => $patron_1,
                code           => $attribute_type_1->{code},
                attribute      => 'Foo'
            }
        )->store;
        Koha::Patron::Attribute->new(
            {   borrowernumber => $patron_2,
                code           => $attribute_type_1->{code},
                attribute      => 'Bar'
            }
        )->store;
        my $attr_count
            = Koha::Patron::Attributes->search(
            { code => $attribute_type_1->{code} } )
            ->count;
        is( $attr_count, 2,
            '2 non-unique attributes stored and retrieved correcctly' );

        my $attribute_type_2 = $builder->build(
            {   source => 'BorrowerAttributeType',
                value  => { unique_id => 1 }
            }
        );

        Koha::Patron::Attribute->new(
            {   borrowernumber => $patron_1,
                code           => $attribute_type_2->{code},
                attribute      => 'Foo'
            }
        )->store;
        throws_ok {
            Koha::Patron::Attribute->new(
                {   borrowernumber => $patron_2,
                    code           => $attribute_type_2->{code},
                    attribute      => 'Foo'
                }
            )->store;
        }
        'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint',
            'Exception thrown trying to store more than one unique attribute';

        is(
            "$@",
            "Your action breaks a unique constraint on the attribute. type="
            . $attribute_type_2->{code}
            . " value=Foo",
            'Exception stringified correctly, attribute passed correctly'
        );

        my $attributes = Koha::Patron::Attributes->search(
            { borrowernumber => $patron_1, code => $attribute_type_2->{code} } );
        is( $attributes->count, 1, '1 unique attribute stored' );
        is( $attributes->next->attribute,
            'Foo', 'unique attribute remains unchanged' );

        $schema->storage->txn_rollback;
    };

    subtest 'invalid type tests' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my $attribute_type = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => {
                    unique_id  => 0,
                    repeatable => 0
                }
            }
        );

        my $code = $attribute_type->code;
        $attribute_type->delete;

        throws_ok
            { Koha::Patron::Attribute->new(
                {
                    borrowernumber => $patron->borrowernumber,
                    code           => $code,
                    attribute      => 'Who knows'

                })->store;
            }
            'Koha::Exceptions::Patron::Attribute::InvalidType',
            'Exception thrown on invalid attribute code';

        is( $@->type, $code, 'type exception parameter passed'  );

        $schema->storage->txn_rollback;
    };
};

subtest 'type() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron
        = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $attr_type = $builder->build( { source => 'BorrowerAttributeType' } );
    my $attribute = Koha::Patron::Attribute->new(
        {   borrowernumber => $patron,
            code           => $attr_type->{code},
            attribute      => $patron
        }
    );

    my $attribute_type = $attribute->type;

    is( ref($attribute_type),
        'Koha::Patron::Attribute::Type',
        '->type returns a Koha::Patron::Attribute::Type object'
    );

    is( $attribute_type->code,
        $attr_type->{code},
        '->type returns the right Koha::Patron::Attribute::Type object' );

    is( $attribute_type->opac_editable,
        $attr_type->{opac_editable},
        '->type returns the right Koha::Patron::Attribute::Type object'
    );

    is( $attribute_type->opac_display,
        $attr_type->{opac_display},
        '->type returns the right Koha::Patron::Attribute::Type object'
    );

    $schema->storage->txn_rollback;
};
