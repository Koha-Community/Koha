#!/usr/bin/perl

# Copyright 2019 Koha Development team
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

use Test::More tests => 3;
use Test::Exception;

use Koha::Database;
use Koha::Patrons;
use Koha::Patron::Relationships;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'add_guarantor() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'father1|father2' );

    my $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });

    throws_ok
        { $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber }); }
        'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown as no relationship passed';

    is( $patron_1->guarantee_relationships->count, 0, 'No guarantors added' );

    throws_ok
        { $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber, relationship => 'father' }); }
        'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown as a wrong relationship was passed';

    is( $patron_1->guarantee_relationships->count, 0, 'No guarantors added' );

    $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber, relationship => 'father1' });

    my $guarantors = $patron_1->guarantor_relationships;

    is( $guarantors->count, 1, 'No guarantors added' );

    $SIG{__WARN__} = sub {}; # FIXME: PrintError = 0 not working!

    throws_ok
        { $patron_1->add_guarantor({ guarantor_id => $patron_2->borrowernumber, relationship => 'father2' }); }
        'Koha::Exceptions::Patron::Relationship::DuplicateRelationship',
        'Exception is thrown for duplicated relationship';

    $schema->storage->txn_rollback;
};

subtest 'add_enrolment_fee_if_needed() tests' => sub {

    plan tests => 2;

    subtest 'category has enrolment fee' => sub {
        plan tests => 7;

        $schema->storage->txn_begin;

        my $category = $builder->build_object(
            {
                class => 'Koha::Patron::Categories',
                value => {
                    enrolmentfee => 20
                }
            }
        );

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    categorycode => $category->categorycode
                }
            }
        );

        my $enrollment_fee = $patron->add_enrolment_fee_if_needed();
        is( $enrollment_fee * 1, 20, 'Enrolment fee amount is correct' );
        my $account = $patron->account;
        is( $patron->account->balance * 1, 20, 'Patron charged the enrolment fee' );
        # second enrolment fee, new
        $enrollment_fee = $patron->add_enrolment_fee_if_needed(0);
        # third enrolment fee, renewal
        $enrollment_fee = $patron->add_enrolment_fee_if_needed(1);
        is( $patron->account->balance * 1, 60, 'Patron charged the enrolment fees' );

        my @debits = $account->outstanding_debits;
        is( scalar @debits, 3, '3 enrolment fees' );
        is( $debits[0]->debit_type_code, 'ACCOUNT', 'Account type set correctly' );
        is( $debits[1]->debit_type_code, 'ACCOUNT', 'Account type set correctly' );
        is( $debits[2]->debit_type_code, 'ACCOUNT_RENEW', 'Account type set correctly' );

        $schema->storage->txn_rollback;
    };

    subtest 'no enrolment fee' => sub {

        plan tests => 3;

        $schema->storage->txn_begin;

        my $category = $builder->build_object(
            {
                class => 'Koha::Patron::Categories',
                value => {
                    enrolmentfee => 0
                }
            }
        );

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    categorycode => $category->categorycode
                }
            }
        );

        my $enrollment_fee = $patron->add_enrolment_fee_if_needed();
        is( $enrollment_fee * 1, 0, 'No enrolment fee' );
        my $account = $patron->account;
        is( $patron->account->balance, 0, 'Patron not charged anything' );

        my @debits = $account->outstanding_debits;
        is( scalar @debits, 0, 'no debits' );

        $schema->storage->txn_rollback;
    };
};

subtest 'is_superlibrarian() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                flags => 16
            }
        }
    );

    ok( !$patron->is_superlibrarian, 'Patron is not a superlibrarian and the method returns the correct value' );

    $patron->flags(1)->store->discard_changes;
    ok( $patron->is_superlibrarian, 'Patron is a superlibrarian and the method returns the correct value' );

    $schema->storage->txn_rollback;
};
