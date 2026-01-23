#!/usr/bin/perl
#
# Copyright 2018 ByWater Solutions
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::Exception;

use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Charges::Sales');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

subtest 'new' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    throws_ok { Koha::Charges::Sales->new( { staff_id => 1 } ) }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if cash_register parameter missing';

    throws_ok { Koha::Charges::Sales->new( { cash_register => 1 } ) }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if staff_id parameter missing';

    throws_ok {
        Koha::Charges::Sales->new( { staff_id => 1, cash_register => 1 } )
    }
    qr/Koha::Cash::Register/,
        'Exception thrown if cash_register is not a Koha::Cash::Register';

    my $cash_register = $builder->build_object( { class => 'Koha::Cash::Registers' } );

    my $sale = Koha::Charges::Sales->new( { staff_id => 1, cash_register => $cash_register } );
    ok(
        $sale->isa('Koha::Charges::Sales'),
        'New returns a Koha::Charges::Sales object'
    );

    $schema->storage->txn_rollback;
};

subtest 'payment_type (_get_valid_payments) tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $library1      = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2      = $builder->build_object( { class => 'Koha::Libraries' } );
    my $cash_register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library1->branchcode }
        }
    );

    my $sale = Koha::Charges::Sales->new( { staff_id => 1, cash_register => $cash_register } );

    is( $sale->payment_type, undef, "payment_type does not have a default" );

    throws_ok { $sale->payment_type('BOBBYRANDOM') }
    'Koha::Exceptions::Account::UnrecognisedType',
        "Exception thrown if passed a payment type that doesn't exist";

    my $av = Koha::AuthorisedValue->new(
        {
            category         => 'PAYMENT_TYPE',
            authorised_value => 'BOBBYRANDOM',
            lib              => 'Test bobbyrandom',
            lib_opac         => 'Test bobbyrandom',
        }
    )->store;
    $av->replace_library_limits( [ $library2->branchcode ] );

    throws_ok { $sale->payment_type('BOBBYRANDOM') }
    'Koha::Exceptions::Account::UnrecognisedType',
        'Exception thrown if passed payment type that is not valid for the cash registers branch';

    $av->replace_library_limits();
    $sale->{valid_payments} = undef;    # Flush object cache for 'valid_payments'

    my $pt = $sale->payment_type('BOBBYRANDOM');
    is( $pt, 'BOBBYRANDOM', 'Payment type set successfully' );
    is(
        $sale->payment_type, 'BOBBYRANDOM',
        'Getter returns the current payment_type'
    );

    $schema->storage->txn_rollback;
};

subtest 'add_item (_get_valid_items) tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $staff         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library1      = $builder->build_object( { class => 'Koha::Libraries' } );
    my $cash_register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library1->branchcode }
        }
    );

    my $sale = Koha::Charges::Sales->new( { staff_id => $staff->borrowernumber, cash_register => $cash_register } );

    throws_ok { $sale->add_item( { price => 1.00, quantity => 1 } ) }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if `code` parameter is missing';

    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $dt       = Koha::Account::DebitType->new(
        {
            code        => 'BOBBYRANDOM',
            description => 'Test bobbyrandom',
        }
    )->store;
    $dt->replace_library_limits( [ $library2->branchcode ] );

    throws_ok { $sale->add_item( { code => 'BOBBYRANDOM' } ) }
    'Koha::Exceptions::Account::UnrecognisedType',
        'Exception thrown if passed an item code that is not valid for the cash registers branch';

    $dt->replace_library_limits();
    $sale->{valid_items} = undef;    # Flush object cache for 'valid_items'

    throws_ok {
        $sale->add_item( { code => 'BOBBYRANDOM', quantity => 1 } )
    }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if `price` parameter is missing';

    throws_ok {
        $sale->add_item( { code => 'BOBBYRANDOM', price => 1.00 } )
    }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if `quantity` parameter is missing';

    is(
        ref( $sale->add_item( { code => 'BOBBYRANDOM', price => 1.00, quantity => 1 } ) ),
        'Koha::Charges::Sales',
        'Original object returned succesfully'
    );

    is( scalar @{ $sale->{items} }, 1, 'Item added successfully' );

    $schema->storage->txn_rollback;
};

subtest 'purchase tests' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    my $staff         = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library       = $builder->build_object( { class => 'Koha::Libraries' } );
    my $cash_register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode }
        }
    );

    my $item1 = Koha::Account::DebitType->new(
        {
            code        => 'COPYRANDOM',
            description => 'Copier fee',
        }
    )->store;
    my $item2 = Koha::Account::DebitType->new(
        {
            code        => 'CARDRANDOM',
            description => 'New card fee',
        }
    )->store;

    my $sale = Koha::Charges::Sales->new( { staff_id => $staff->borrowernumber, cash_register => $cash_register } );

    throws_ok {
        $sale->purchase()
    }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if `payment_type` is neither set nor passed';

    $sale->payment_type('CASH');    # Set payment_type
    throws_ok {
        $sale->purchase()
    }
    'Koha::Exceptions::NoChanges',
        'Exception thrown if `add_item` is not called before `purchase`';

    $sale->add_item( { code => 'COPYRANDOM', price => 1.00, quantity => 1 } );
    $sale->add_item( { code => 'CARDRANDOM', price => 2.00, quantity => 2 } );

    $sale->{payment_type} = undef;    # Flush payment_type cache in object

    my $credit;
    ok(
        $credit = $sale->purchase( { payment_type => 'CASH' } ),
        "No exception when payment_type passed"
    );

    is( ref($credit), 'Koha::Account::Line', "Koha::Account::Line returned" );
    ok( $credit->is_credit, "return is a credit for payment" );
    is( $credit->credit_type_code,      'PURCHASE', "credit_type_code set correctly to 'PURCHASE' for payment" );
    is( $credit->amount * 1,            -5,         "amount is calculated correctly for payment" );
    is( $credit->amountoutstanding * 1,  0,         "amountoutstanding is set to zero for payment" );
    is( $credit->manager_id,            $staff->borrowernumber, "manager_id set correctionly for payment" );
    is( $credit->register_id,           $cash_register->id,     "register_id set correctly for payment" );
    is( $credit->payment_type,          'CASH',                 "payment_type set correctly for payment" );

    my $offsets = Koha::Account::Offsets->search( { credit_id => $credit->accountlines_id } );
    is( $offsets->count, 3, "One offset was added for each item added" );    # 2 items + 1 purchase

    #ensure relevant fields are set
    #ensure register_id is only ever set with a corresponding payment_type having been set

    $schema->storage->txn_rollback;
};
