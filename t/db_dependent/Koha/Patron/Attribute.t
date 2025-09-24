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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use JSON qw( to_json );

use Test::NoWarnings;
use Test::More tests => 5;

use t::lib::TestBuilder;
use t::lib::Mocks;
use Test::Exception;

use Koha::Database;
use Koha::Patron::Attribute;
use Koha::Patron::Attributes;
use Koha::ActionLogs;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'store() tests' => sub {

    plan tests => 6;

    subtest 'Update an attribute should update the patron "updated_on" field' => sub {

        plan tests => 1;

        $schema->storage->txn_begin;

        my $patron     = $builder->build_object( { class => 'Koha::Patrons' } );
        my $updated_on = $patron->updated_on;

        sleep 1;    # Timestamps are in one second increments, so we need to wait one second

        my $type = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => {
                    mandatory     => 0,
                    repeatable    => 0,
                    unique_id     => 0,
                    category_code => undef
                }
            }
        );

        my $attr = $patron->add_extended_attribute(
            {
                code      => $type->code,
                attribute => 'TEST'
            }
        );

        $attr->set( { attribute => 'TEST' } )->store();

        $patron->discard_changes;

        isnt( $updated_on, $patron->updated_on, "Updated on was updated by attribute storage" );

        $schema->storage->txn_rollback;
    };

    subtest 'repeatable attributes tests' => sub {

        plan tests => 5;

        $schema->storage->txn_begin;

        my $patron           = $builder->build( { source => 'Borrower' } )->{borrowernumber};
        my $attribute_type_1 = $builder->build(
            {
                source => 'BorrowerAttributeType',
                value  => { repeatable => 1, is_date => 0 }
            }
        );
        Koha::Patron::Attribute->new(
            {
                borrowernumber => $patron,
                code           => $attribute_type_1->{code},
                attribute      => 'Foo'
            }
        )->store;
        Koha::Patron::Attribute->new(
            {
                borrowernumber => $patron,
                code           => $attribute_type_1->{code},
                attribute      => 'Bar'
            }
        )->store;
        my $attr_count =
            Koha::Patron::Attributes->search( { borrowernumber => $patron, code => $attribute_type_1->{code} } )->count;
        is(
            $attr_count, 2,
            '2 repeatable attributes stored and retrieved correcctly'
        );

        my $attribute_type_2 = $builder->build(
            {
                source => 'BorrowerAttributeType',
                value  => { repeatable => 0, is_date => 0 }
            }
        );

        Koha::Patron::Attribute->new(
            {
                borrowernumber => $patron,
                code           => $attribute_type_2->{code},
                attribute      => 'Foo'
            }
        )->store;
        throws_ok {
            Koha::Patron::Attribute->new(
                {
                    borrowernumber => $patron,
                    code           => $attribute_type_2->{code},
                    attribute      => 'Bar'
                }
            )->store;
        }
        'Koha::Exceptions::Patron::Attribute::NonRepeatable',
            'Exception thrown trying to store more than one non-repeatable attribute';

        is(
            "$@",
            "Tried to add more than one non-repeatable attributes. type=" . $attribute_type_2->{code} . " value=Bar",
            'Exception stringified correctly, attribute passed correctly'
        );

        my $attributes =
            Koha::Patron::Attributes->search( { borrowernumber => $patron, code => $attribute_type_2->{code} } );
        is( $attributes->count, 1, '1 non-repeatable attribute stored' );
        is(
            $attributes->next->attribute,
            'Foo', 'Non-repeatable attribute remains unchanged'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'is_date attributes tests' => sub {
        plan tests => 3;

        $schema->storage->txn_begin;

        my $patron           = $builder->build( { source => 'Borrower' } )->{borrowernumber};
        my $attribute_type_1 = $builder->build(
            {
                source => 'BorrowerAttributeType',
                value  => { is_date => 1 }
            }
        );

        throws_ok {
            Koha::Patron::Attribute->new(
                {
                    borrowernumber => $patron,
                    code           => $attribute_type_1->{code},
                    attribute      => 'not_a_date'
                }
            )->store;
        }
        'Koha::Exceptions::Patron::Attribute::InvalidAttributeValue',
            'Exception thrown trying to store a date attribute with non-date value';

        is(
            "$@",
            "Tried to use an invalid value for attribute type. type=" . $attribute_type_1->{code} . " value=not_a_date",
            'Exception stringified correctly, attribute passed correctly'
        );

        Koha::Patron::Attribute->new(
            {
                borrowernumber => $patron,
                code           => $attribute_type_1->{code},
                attribute      => '2024-03-04'
            }
        )->store;

        my $attr_count =
            Koha::Patron::Attributes->search( { borrowernumber => $patron, code => $attribute_type_1->{code} } )->count;
        is(
            $attr_count, 1,
            '1 date attribute stored and retrieved correctly'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'unique_id attributes tests' => sub {

        plan tests => 5;

        $schema->storage->txn_begin;

        my $patron_1 = $builder->build( { source => 'Borrower' } )->{borrowernumber};
        my $patron_2 = $builder->build( { source => 'Borrower' } )->{borrowernumber};

        my $attribute_type_1 = $builder->build(
            {
                source => 'BorrowerAttributeType',
                value  => { unique_id => 0, is_date => 0 }
            }
        );
        Koha::Patron::Attribute->new(
            {
                borrowernumber => $patron_1,
                code           => $attribute_type_1->{code},
                attribute      => 'Foo'
            }
        )->store;
        Koha::Patron::Attribute->new(
            {
                borrowernumber => $patron_2,
                code           => $attribute_type_1->{code},
                attribute      => 'Bar'
            }
        )->store;
        my $attr_count = Koha::Patron::Attributes->search( { code => $attribute_type_1->{code} } )->count;
        is(
            $attr_count, 2,
            '2 non-unique attributes stored and retrieved correcctly'
        );

        my $attribute_type_2 = $builder->build(
            {
                source => 'BorrowerAttributeType',
                value  => { unique_id => 1, is_date => 0 }
            }
        );

        Koha::Patron::Attribute->new(
            {
                borrowernumber => $patron_1,
                code           => $attribute_type_2->{code},
                attribute      => 'Foo'
            }
        )->store;
        throws_ok {
            Koha::Patron::Attribute->new(
                {
                    borrowernumber => $patron_2,
                    code           => $attribute_type_2->{code},
                    attribute      => 'Foo'
                }
            )->store;
        }
        'Koha::Exceptions::Patron::Attribute::UniqueIDConstraint',
            'Exception thrown trying to store more than one unique attribute';

        is(
            "$@",
            "Your action breaks a unique constraint on the attribute. type=" . $attribute_type_2->{code} . " value=Foo",
            'Exception stringified correctly, attribute passed correctly'
        );

        my $attributes =
            Koha::Patron::Attributes->search( { borrowernumber => $patron_1, code => $attribute_type_2->{code} } );
        is( $attributes->count, 1, '1 unique attribute stored' );
        is(
            $attributes->next->attribute,
            'Foo', 'unique attribute remains unchanged'
        );

        $schema->storage->txn_rollback;
    };

    subtest 'invalid type tests' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
        my $attribute_type = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => {
                    unique_id  => 0,
                    repeatable => 0,
                    is_date    => 0
                }
            }
        );

        my $code = $attribute_type->code;
        $attribute_type->delete;

        throws_ok {
            Koha::Patron::Attribute->new(
                {
                    borrowernumber => $patron->borrowernumber,
                    code           => $code,
                    attribute      => 'Who knows'

                }
            )->store;
        }
        'Koha::Exceptions::Patron::Attribute::InvalidType',
            'Exception thrown on invalid attribute code';

        is( $@->type, $code, 'type exception parameter passed' );

        $schema->storage->txn_rollback;
    };

    subtest 'Edit attribute tests for non-repeatable tests (Bug 28031)' => sub {

        plan tests => 1;

        $schema->storage->txn_begin;

        my $patron              = $builder->build_object( { class => 'Koha::Patrons' } );
        my $non_repeatable_type = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => {
                    mandatory     => 0,
                    repeatable    => 0,
                    unique_id     => 1,
                    is_date       => 0,
                    category_code => undef
                }
            }
        );

        # Here we test the case of editing an already stored attribute
        my $non_repeatable_attr = $patron->add_extended_attribute(
            {
                code      => $non_repeatable_type->code,
                attribute => 'WOW'
            }
        );

        $non_repeatable_attr->set( { attribute => 'HEY' } )->store->discard_changes;

        is( $non_repeatable_attr->attribute, 'HEY', 'Value stored correctly' );

        $schema->storage->txn_rollback;
    };
};

subtest 'type() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $attr_type = $builder->build( { source => 'BorrowerAttributeType' } );
    my $attribute = Koha::Patron::Attribute->new(
        {
            borrowernumber => $patron,
            code           => $attr_type->{code},
            attribute      => $patron
        }
    );

    my $attribute_type = $attribute->type;

    is(
        ref($attribute_type),
        'Koha::Patron::Attribute::Type',
        '->type returns a Koha::Patron::Attribute::Type object'
    );

    is(
        $attribute_type->code,
        $attr_type->{code},
        '->type returns the right Koha::Patron::Attribute::Type object'
    );

    is(
        $attribute_type->opac_editable,
        $attr_type->{opac_editable},
        '->type returns the right Koha::Patron::Attribute::Type object'
    );

    is(
        $attribute_type->opac_display,
        $attr_type->{opac_display},
        '->type returns the right Koha::Patron::Attribute::Type object'
    );

    $schema->storage->txn_rollback;
};

subtest 'merge_and_replace_with' => sub {
    plan tests => 2;

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $unique_attribute_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                unique_id  => 1,
                repeatable => 0,
                is_date    => 0
            }
        }
    );
    my $repeatable_attribute_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                unique_id  => 0,
                repeatable => 1,
                is_date    => 0
            }
        }
    );
    my $normal_attribute_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => {
                unique_id  => 0,
                repeatable => 0,
                is_date    => 0
            }
        }
    );
    my $non_existent_attribute_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
        }
    );
    my $non_existent_attribute_type_code = $non_existent_attribute_type->code;
    $non_existent_attribute_type->delete;

    my $attributes = [
        {
            attribute => 'my unique attribute 1',
            code      => $unique_attribute_type->code(),
        },
        {
            attribute => 'my repeatable attribute 1',
            code      => $repeatable_attribute_type->code(),
        },
        {
            attribute => 'my normal attribute 1',
            code      => $normal_attribute_type->code(),
        }
    ];
    $patron->extended_attributes($attributes);

    my $new_attributes = [
        {
            attribute => 'my repeatable attribute 2',
            code      => $repeatable_attribute_type->code(),
        },
        {
            attribute => 'my repeatable attribute 3',
            code      => $repeatable_attribute_type->code(),
        },
        {
            attribute => 'my normal attribute 2',
            code      => $normal_attribute_type->code(),
        },
        {
            attribute => 'my unique attribute 2',
            code      => $unique_attribute_type->code(),
        }
    ];

    my $new_extended_attributes = $patron->extended_attributes->merge_and_replace_with($new_attributes);

    my $expected = [
        {
            attribute => 'my normal attribute 2',          # Attribute 1 has been replaced by attribute 2
            code      => $normal_attribute_type->code(),
        },
        {
            attribute => 'my unique attribute 2',          # Attribute 1 has been replaced by attribute 2
            code      => $unique_attribute_type->code(),
        },
        {
            attribute => 'my repeatable attribute 1',
            code      => $repeatable_attribute_type->code(),
        },
        {
            attribute => 'my repeatable attribute 2',
            code      => $repeatable_attribute_type->code(),
        },
        {
            attribute => 'my repeatable attribute 3',
            code      => $repeatable_attribute_type->code(),
        },
    ];
    $expected = [ sort { $a->{code} cmp $b->{code} || $a->{attribute} cmp $b->{attribute} } @$expected ];
    is_deeply( $new_extended_attributes, $expected );

    throws_ok {
        $patron->extended_attributes->merge_and_replace_with(
            [
                { code => $non_existent_attribute_type_code, attribute => 'foobar' },
            ]
        );
    }
    'Koha::Exceptions::Patron::Attribute::InvalidType',
        'Exception thrown on invalid attribute type';

    $schema->storage->txn_rollback;

};

subtest 'action log tests' => sub {
    plan tests => 12;
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $get_info = sub {
        my ( $before, $after, $code, $repeatable ) = @_;
        my $change = {
            before => $before,
            after  => $after
        };
        if ($repeatable) {
            while ( my ( $k, $v ) = each %{$change} ) {
                if ( ref $v eq 'ARRAY' ) {
                    $change->{$k} = [ sort @{$v} ];
                } else {
                    $change->{$k} = $v ? [$v] : [];
                }
            }
        }
        return to_json( { "attribute.$code" => $change }, { pretty => 1, canonical => 1 } );
    };

    my $patron         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $attribute_type = $builder->build_object(
        {
            class => 'Koha::Patron::Attribute::Types',
            value => { repeatable => 0 }
        }
    );

    t::lib::Mocks::mock_preference( 'BorrowersLog', 0 );
    my $attributes = [
        {
            attribute => 'Foo',
            code      => $attribute_type->code,
        }
    ];
    $patron->extended_attributes($attributes);

    my $info        = $get_info->( '', 'Foo', $attribute_type->code );
    my $action_logs = Koha::ActionLogs->search(
        {
            module => "MEMBERS",
            action => "MODIFY",
            object => $patron->borrowernumber,
            info   => $info
        }
    );
    is(
        $action_logs->count,
        0,
        'No action log entry has been created when adding patron attribute if BorrowersLog syspref disabled'
    );

    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
    my $current_action_logs_count;
    my $repeatable_text;
    for my $repeatable ( 0, 1 ) {
        $repeatable_text = $repeatable ? ' repeatable' : '';

        $patron->extended_attributes( [] );

        $attribute_type = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => { repeatable => $repeatable }
            }
        );
        $attributes = [
            {
                attribute => 'Foo',
                code      => $attribute_type->code,
            }
        ];

        $patron->extended_attributes($attributes);
        $info        = $get_info->( '', 'Foo', $attribute_type->code, $repeatable );
        $action_logs = Koha::ActionLogs->search(
            {
                module => "MEMBERS",
                action => "MODIFY",
                object => $patron->borrowernumber,
                info   => $info
            }
        );
        is(
            $action_logs->count,
            1,
            "An action log entry has been created when adding$repeatable_text patron attribute"
        );

        $current_action_logs_count = Koha::ActionLogs->search(
            {
                module => "MEMBERS",
                action => "MODIFY",
                object => $patron->borrowernumber
            }
        )->count;

        $patron->extended_attributes($attributes);
        $action_logs = Koha::ActionLogs->search(
            {
                module => "MEMBERS",
                action => "MODIFY",
                object => $patron->borrowernumber
            }
        );
        is(
            $action_logs->count,
            $current_action_logs_count,
            "No additional action log entry has been created when updating$repeatable_text patron attribute with same value"
        );

        $attributes = [
            {
                attribute => 'Bar',
                code      => $attribute_type->code,
            }
        ];
        $patron->extended_attributes($attributes);
        $info        = $get_info->( 'Foo', 'Bar', $attribute_type->code, $repeatable );
        $action_logs = Koha::ActionLogs->search(
            {
                module => "MEMBERS",
                action => "MODIFY",
                object => $patron->borrowernumber,
                info   => $info
            }
        );
        is(
            $action_logs->count,
            1,
            "New action log entry has been created when updating$repeatable_text patron attribute with different value"
        );

        $patron->extended_attributes( [] );
        $info        = $get_info->( 'Bar', '', $attribute_type->code, $repeatable );
        $action_logs = Koha::ActionLogs->search(
            {
                module => "MEMBERS",
                action => "MODIFY",
                object => $patron->borrowernumber,
                info   => $info
            }
        );
        is(
            $action_logs->count,
            1,
            "New action log entry has been created when deleting$repeatable_text patron attribute value"
        );
    }

    $attributes = [
        {
            attribute => 'Foo',
            code      => $attribute_type->code,
        },
        {
            attribute => 'Bar',
            code      => $attribute_type->code,
        }
    ];
    $patron->extended_attributes($attributes);

    $info = $get_info->( [], [ 'Foo', 'Bar' ], $attribute_type->code, 1 );
    use Data::Dumper;
    print Dumper($info);
    $action_logs = Koha::ActionLogs->search(
        {
            module => "MEMBERS",
            action => "MODIFY",
            object => $patron->borrowernumber,
            info   => $info
        }
    );
    is(
        $action_logs->count,
        1,
        "New action log entry has been created when updating repeatable patron attribute with multiple values"
    );

    $attributes = [
        {
            attribute => 'Foo',
            code      => $attribute_type->code,
        },
        {
            attribute => 'Bar',
            code      => $attribute_type->code,
        },
        {
            attribute => 'Baz',
            code      => $attribute_type->code,
        }
    ];
    $patron->extended_attributes($attributes);

    $info = $get_info->(
        [ 'Foo', 'Bar' ],
        [ 'Foo', 'Bar', 'Baz' ],
        $attribute_type->code,
        1
    );
    $action_logs = Koha::ActionLogs->search(
        {
            module => "MEMBERS",
            action => "MODIFY",
            object => $patron->borrowernumber,
            info   => $info
        }
    );
    is(
        $action_logs->count,
        1,
        "New action log entry has been created when updating repeatable patron attribute with existing multiple values with multiple values"
    );

    my $attribute = {
        attribute => 'Qux',
        code      => $attribute_type->code,
    };
    $patron->add_extended_attribute($attribute);

    $info = $get_info->(
        [ 'Foo', 'Bar', 'Baz' ],
        [ 'Foo', 'Bar', 'Baz', 'Qux' ],
        $attribute_type->code,
        1
    );
    $action_logs = Koha::ActionLogs->search(
        {
            module => "MEMBERS",
            action => "MODIFY",
            object => $patron->borrowernumber,
            info   => $info
        }
    );
    is(
        $action_logs->count,
        1,
        "New action log entry has been created when updating patron attributes using add_extended_attribute"
    );

    $schema->storage->txn_rollback;
};
