#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::More tests => 44;
use Test::Warn;
use Test::Exception;
use Test::MockModule;
use Time::Fake;
use DateTime;
use JSON;
use utf8;

use C4::Circulation qw( AddIssue AddReturn );
use C4::Biblio;
use C4::Auth qw( checkpw checkpw_hash );

use Koha::ActionLogs;
use Koha::Holds;
use Koha::Old::Holds;
use Koha::Patrons;
use Koha::Old::Patrons;
use Koha::Patron::Attribute::Types;
use Koha::Patron::Categories;
use Koha::Patron::Relationship;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Virtualshelf;
use Koha::Virtualshelves;
use Koha::Notice::Messages;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder       = t::lib::TestBuilder->new;
my $library = $builder->build({source => 'Branch' });
my $category = $builder->build({source => 'Category' });
my $nb_of_patrons = Koha::Patrons->search->count;
my $new_patron_1  = Koha::Patron->new(
    {   cardnumber => 'test_cn_1',
        branchcode => $library->{branchcode},
        categorycode => $category->{categorycode},
        surname => 'surname for patron1',
        firstname => 'firstname for patron1',
        userid => 'a_nonexistent_userid_1',
        flags => 1, # Is superlibrarian
    }
)->store;
my $new_patron_2  = Koha::Patron->new(
    {   cardnumber => 'test_cn_2',
        branchcode => $library->{branchcode},
        categorycode => $category->{categorycode},
        surname => 'surname for patron2',
        firstname => 'firstname for patron2',
        userid => 'a_nonexistent_userid_2',
    }
)->store;

t::lib::Mocks::mock_userenv({ patron => $new_patron_1 });

is( Koha::Patrons->search->count, $nb_of_patrons + 2, 'The 2 patrons should have been added' );

my $retrieved_patron_1 = Koha::Patrons->find( $new_patron_1->borrowernumber );
is( $retrieved_patron_1->cardnumber, $new_patron_1->cardnumber, 'Find a patron by borrowernumber should return the correct patron' );

subtest 'library' => sub {
    plan tests => 2;
    is( $retrieved_patron_1->library->branchcode, $library->{branchcode}, 'Koha::Patron->library should return the correct library' );
    is( ref($retrieved_patron_1->library), 'Koha::Library', 'Koha::Patron->library should return a Koha::Library object' );
};

subtest 'sms_provider' => sub {
    plan tests => 3;
    my $sms_provider = $builder->build({source => 'SmsProvider' });
    is( $retrieved_patron_1->sms_provider, undef, '->sms_provider should return undef if none defined' );
    $retrieved_patron_1->sms_provider_id( $sms_provider->{id} )->store;
    is_deeply( $retrieved_patron_1->sms_provider->unblessed, $sms_provider, 'Koha::Patron->sms_provider returns the correct SMS provider' );
    is( ref($retrieved_patron_1->sms_provider), 'Koha::SMS::Provider', 'Koha::Patron->sms_provider should return a Koha::SMS::Provider object' );
};

subtest 'guarantees' => sub {

    plan tests => 9;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'test|test2' );

    my $guarantees = $new_patron_1->guarantee_relationships;
    is( ref($guarantees), 'Koha::Patron::Relationships', 'Koha::Patron->guarantees should return a Koha::Patrons result set in a scalar context' );
    is( $guarantees->count, 0, 'new_patron_1 should have 0 guarantee relationships' );

    my $guarantee_1 = $builder->build({ source => 'Borrower' });
    my $relationship_1 = Koha::Patron::Relationship->new( { guarantor_id => $new_patron_1->id, guarantee_id => $guarantee_1->{borrowernumber}, relationship => 'test' } )->store();
    my $guarantee_2 = $builder->build({ source => 'Borrower' });
    my $relationship_2 = Koha::Patron::Relationship->new( { guarantor_id => $new_patron_1->id, guarantee_id => $guarantee_2->{borrowernumber}, relationship => 'test' } )->store();

    $guarantees = $new_patron_1->guarantee_relationships;
    is( ref($guarantees), 'Koha::Patron::Relationships', 'Koha::Patron->guarantee_relationships should return a Koha::Patrons result set in a scalar context' );
    is( $guarantees->count, 2, 'new_patron_1 should have 2 guarantees' );

    $guarantees->delete;

    #Test return order of guarantees BZ 18635
    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $guarantor = $builder->build_object( { class => 'Koha::Patrons' } );

    my $order_guarantee1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname     => 'Zebra',
            }
        }
    )->borrowernumber;
    $builder->build_object(
        {
            class => 'Koha::Patron::Relationships',
            value => {
                guarantor_id  => $guarantor->id,
                guarantee_id => $order_guarantee1,
                relationship => 'test',
            }
        }
    );

    my $order_guarantee2 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname     => 'Yak',
            }
        }
    )->borrowernumber;
    $builder->build_object(
        {
            class => 'Koha::Patron::Relationships',
            value => {
                guarantor_id  => $guarantor->id,
                guarantee_id => $order_guarantee2,
                relationship => 'test',
            }
        }
    );

    my $order_guarantee3 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname     => 'Xerus',
                firstname   => 'Walrus',
            }
        }
    )->borrowernumber;
    $builder->build_object(
        {
            class => 'Koha::Patron::Relationships',
            value => {
                guarantor_id  => $guarantor->id,
                guarantee_id => $order_guarantee3,
                relationship => 'test',
            }
        }
    );

    my $order_guarantee4 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname     => 'Xerus',
                firstname   => 'Vulture',
                guarantorid => $guarantor->borrowernumber
            }
        }
    )->borrowernumber;
    $builder->build_object(
        {
            class => 'Koha::Patron::Relationships',
            value => {
                guarantor_id  => $guarantor->id,
                guarantee_id => $order_guarantee4,
                relationship => 'test',
            }
        }
    );

    my $order_guarantee5 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                surname     => 'Xerus',
                firstname   => 'Unicorn',
                guarantorid => $guarantor->borrowernumber
            }
        }
    )->borrowernumber;
    my $r = $builder->build_object(
        {
            class => 'Koha::Patron::Relationships',
            value => {
                guarantor_id  => $guarantor->id,
                guarantee_id => $order_guarantee5,
                relationship => 'test',
            }
        }
    );

    $guarantees = $guarantor->guarantee_relationships->guarantees;

    is( $guarantees->next()->borrowernumber, $order_guarantee5, "Return first guarantor alphabetically" );
    is( $guarantees->next()->borrowernumber, $order_guarantee4, "Return second guarantor alphabetically" );
    is( $guarantees->next()->borrowernumber, $order_guarantee3, "Return third guarantor alphabetically" );
    is( $guarantees->next()->borrowernumber, $order_guarantee2, "Return fourth guarantor alphabetically" );
    is( $guarantees->next()->borrowernumber, $order_guarantee1, "Return fifth guarantor alphabetically" );
};

subtest 'category' => sub {
    plan tests => 2;
    my $patron_category = $new_patron_1->category;
    is( ref( $patron_category), 'Koha::Patron::Category', );
    is( $patron_category->categorycode, $category->{categorycode}, );
};

subtest 'siblings' => sub {

    plan tests => 6;

    my $siblings = $new_patron_1->siblings;
    is( $siblings, undef, 'Koha::Patron->siblings should not crashed if the patron has no guarantor' );
    my $guarantee_1 = $builder->build( { source => 'Borrower' } );
    my $relationship_1 = Koha::Patron::Relationship->new( { guarantor_id => $new_patron_1->borrowernumber, guarantee_id => $guarantee_1->{borrowernumber}, relationship => 'test' } )->store();
    my $retrieved_guarantee_1 = Koha::Patrons->find($guarantee_1);
    $siblings = $retrieved_guarantee_1->siblings;
    is( ref($siblings), 'Koha::Patrons', 'Koha::Patron->siblings should return a Koha::Patrons result set in a scalar context' );
    is( $siblings->count,  0,       'guarantee_1 should not have siblings yet' );
    my $guarantee_2 = $builder->build( { source => 'Borrower' } );
    my $relationship_2 = Koha::Patron::Relationship->new( { guarantor_id => $new_patron_1->borrowernumber, guarantee_id => $guarantee_2->{borrowernumber}, relationship => 'test' } )->store();
    my $guarantee_3 = $builder->build( { source => 'Borrower' } );
    my $relationship_3 = Koha::Patron::Relationship->new( { guarantor_id => $new_patron_1->borrowernumber, guarantee_id => $guarantee_3->{borrowernumber}, relationship => 'test' } )->store();
    $siblings = $retrieved_guarantee_1->siblings;
    is( $siblings->count,               2,                               'guarantee_1 should have 2 siblings' );
    is( $guarantee_2->{borrowernumber}, $siblings->next->borrowernumber, 'guarantee_2 should exist in the guarantees' );
    is( $guarantee_3->{borrowernumber}, $siblings->next->borrowernumber, 'guarantee_3 should exist in the guarantees' );
    $_->delete for $retrieved_guarantee_1->siblings;
    $retrieved_guarantee_1->delete;
};

subtest 'has_overdues' => sub {
    plan tests => 3;

    my $item_1 = $builder->build_sample_item;
    my $retrieved_patron = Koha::Patrons->find( $new_patron_1->borrowernumber );
    is( $retrieved_patron->has_overdues, 0, );

    my $tomorrow = DateTime->today( time_zone => C4::Context->tz() )->add( days => 1 );
    my $issue = Koha::Checkout->new({ borrowernumber => $new_patron_1->id, itemnumber => $item_1->itemnumber, date_due => $tomorrow, branchcode => $library->{branchcode} })->store();
    is( $retrieved_patron->has_overdues, 0, );
    $issue->delete();
    my $yesterday = DateTime->today(time_zone => C4::Context->tz())->add( days => -1 );
    $issue = Koha::Checkout->new({ borrowernumber => $new_patron_1->id, itemnumber => $item_1->itemnumber, date_due => $yesterday, branchcode => $library->{branchcode} })->store();
    $retrieved_patron = Koha::Patrons->find( $new_patron_1->borrowernumber );
    is( $retrieved_patron->has_overdues, 1, );
    $issue->delete();
};

subtest 'is_expired' => sub {
    plan tests => 4;
    my $patron = $builder->build({ source => 'Borrower' });
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    $patron->dateexpiry( undef )->store->discard_changes;
    is( $patron->is_expired, 0, 'Patron should not be considered expired if dateexpiry is not set');
    $patron->dateexpiry( dt_from_string )->store->discard_changes;
    is( $patron->is_expired, 0, 'Patron should not be considered expired if dateexpiry is today');
    $patron->dateexpiry( dt_from_string->add( days => 1 ) )->store->discard_changes;
    is( $patron->is_expired, 0, 'Patron should not be considered expired if dateexpiry is tomorrow');
    $patron->dateexpiry( dt_from_string->add( days => -1 ) )->store->discard_changes;
    is( $patron->is_expired, 1, 'Patron should be considered expired if dateexpiry is yesterday');

    $patron->delete;
};

subtest 'is_going_to_expire' => sub {
    plan tests => 9;

    my $today = dt_from_string(undef, undef, 'floating');
    my $patron = $builder->build({ source => 'Borrower' });
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    $patron->dateexpiry( undef )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is not set');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 0);
    $patron->dateexpiry( $today )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is today');

    $patron->dateexpiry( $today )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is today and pref is 0');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 10);
    $patron->dateexpiry( $today->clone->add( days => 11 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 11 days ahead and pref is 10');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 0);
    $patron->dateexpiry( $today->clone->add( days => 10 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 10 days ahead and pref is 0');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 10);
    $patron->dateexpiry( $today->clone->add( days => 10 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 10 days ahead and pref is 10');
    $patron->delete;

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 10);
    $patron->dateexpiry( $today->clone->add( days => 20 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 20 days ahead and pref is 10');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 20);
    $patron->dateexpiry( $today->clone->add( days => 10 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 1, 'Patron should be considered going to expire if dateexpiry is 10 days ahead and pref is 20');

    { # Testing invalid is going to expiry date
        t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 30);
        # mock_config does not work here, because of tz vs timezone subroutines
        my $context = Test::MockModule->new('C4::Context');
        $context->mock( 'tz', sub {
            'America/Sao_Paulo';
        });
        $patron->dateexpiry(DateTime->new( year => 2019, month => 12, day => 3 ))->store;
        eval { $patron->is_going_to_expire };
        is( $@, '', 'On invalid "is going to expire" date, the method should not crash with "Invalid local time for date in time zone"');
        $context->unmock('tz');
    };

    $patron->delete;
};


subtest 'renew_account' => sub {
    plan tests => 48;

    for my $date ( '2016-03-31', '2016-11-30', '2019-01-31', dt_from_string() ) {
        my $dt = dt_from_string( $date, 'iso' );
        Time::Fake->offset( $dt->epoch );
        my $a_month_ago                = $dt->clone->subtract( months => 1, end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_year_later               = $dt->clone->add( months => 12, end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_year_later_minus_a_month = $a_month_ago->clone->add( months => 12, end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_month_later              = $dt->clone->add( months => 1 , end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_year_later_plus_a_month  = $a_month_later->clone->add( months => 12, end_of_month => 'limit' )->truncate( to => 'day' );
        my $patron_category = $builder->build(
            {   source => 'Category',
                value  => {
                    enrolmentperiod     => 12,
                    enrolmentperioddate => undef,
                }
            }
        );
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => {
                    dateexpiry   => $a_month_ago,
                    categorycode => $patron_category->{categorycode},
                    date_renewed => undef, # Force builder to not populate the column for new patron
                }
            }
        );
        my $patron_2 = $builder->build(
            {  source => 'Borrower',
               value  => {
                   dateexpiry => $a_month_ago,
                   categorycode => $patron_category->{categorycode},
                }
            }
        );
        my $patron_3 = $builder->build(
            {  source => 'Borrower',
               value  => {
                   dateexpiry => $a_month_later,
                   categorycode => $patron_category->{categorycode},
               }
            }
        );
        my $retrieved_patron = Koha::Patrons->find( $patron->{borrowernumber} );
        my $retrieved_patron_2 = Koha::Patrons->find( $patron_2->{borrowernumber} );
        my $retrieved_patron_3 = Koha::Patrons->find( $patron_3->{borrowernumber} );

        is( $retrieved_patron->date_renewed, undef, "Date renewed is not set for patrons that have never been renewed" );

        t::lib::Mocks::mock_preference( 'BorrowerRenewalPeriodBase', 'dateexpiry' );
        t::lib::Mocks::mock_preference( 'BorrowersLog',              1 );
        my $expiry_date = $retrieved_patron->renew_account;
        is( $expiry_date, $a_year_later_minus_a_month, "$a_month_ago + 12 months must be $a_year_later_minus_a_month" );
        my $retrieved_expiry_date = Koha::Patrons->find( $patron->{borrowernumber} )->dateexpiry;
        is( dt_from_string($retrieved_expiry_date), $a_year_later_minus_a_month, "$a_month_ago + 12 months must be $a_year_later_minus_a_month" );
        my $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'RENEW', object => $retrieved_patron->borrowernumber } )->count;
        is( $number_of_logs, 1, 'With BorrowerLogs, Koha::Patron->renew_account should have logged' );

        t::lib::Mocks::mock_preference( 'BorrowerRenewalPeriodBase', 'now' );
        t::lib::Mocks::mock_preference( 'BorrowersLog',              0 );
        $expiry_date = $retrieved_patron->renew_account;
        is( $expiry_date, $a_year_later, "today + 12 months must be $a_year_later" );
        $retrieved_patron = Koha::Patrons->find( $patron->{borrowernumber} );
        is( $retrieved_patron->date_renewed, output_pref({ dt => $dt, dateformat => 'iso', dateonly => 1 }), "Date renewed is set when calling renew_account" );
        $retrieved_expiry_date = $retrieved_patron->dateexpiry;
        is( dt_from_string($retrieved_expiry_date), $a_year_later, "today + 12 months must be $a_year_later" );
        $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'RENEW', object => $retrieved_patron->borrowernumber } )->count;
        is( $number_of_logs, 1, 'Without BorrowerLogs, Koha::Patron->renew_account should not have logged' );

        t::lib::Mocks::mock_preference( 'BorrowerRenewalPeriodBase', 'combination' );
        $expiry_date = $retrieved_patron_2->renew_account;
        is( $expiry_date, $a_year_later, "today + 12 months must be $a_year_later" );
        $retrieved_expiry_date = Koha::Patrons->find( $patron_2->{borrowernumber} )->dateexpiry;
        is( dt_from_string($retrieved_expiry_date), $a_year_later, "today + 12 months must be $a_year_later" );

        $expiry_date = $retrieved_patron_3->renew_account;
        is( $expiry_date, $a_year_later_plus_a_month, "$a_month_later + 12 months must be $a_year_later_plus_a_month" );
        $retrieved_expiry_date = Koha::Patrons->find( $patron_3->{borrowernumber} )->dateexpiry;
        is( dt_from_string($retrieved_expiry_date), $a_year_later_plus_a_month, "$a_month_later + 12 months must be $a_year_later_plus_a_month" );

        $retrieved_patron->delete;
        $retrieved_patron_2->delete;
        $retrieved_patron_3->delete;
    }
    Time::Fake->reset;
};

subtest "move_to_deleted" => sub {
    plan tests => 5;
    my $originally_updated_on = '2016-01-01 12:12:12';
    my $patron = $builder->build( { source => 'Borrower',value => { updated_on => $originally_updated_on } } );
    my $retrieved_patron = Koha::Patrons->find( $patron->{borrowernumber} );
    is( ref( $retrieved_patron->move_to_deleted ), 'Koha::Schema::Result::Deletedborrower', 'Koha::Patron->move_to_deleted should return the Deleted patron' )
      ;    # FIXME This should be Koha::Deleted::Patron
    my $deleted_patron = $schema->resultset('Deletedborrower')
        ->search( { borrowernumber => $patron->{borrowernumber} }, { result_class => 'DBIx::Class::ResultClass::HashRefInflator' } )
        ->next;
    ok( $retrieved_patron->updated_on, 'updated_on should be set for borrowers table' );
    ok( $deleted_patron->{updated_on}, 'updated_on should be set for deleted_borrowers table' );
    isnt( $deleted_patron->{updated_on}, $retrieved_patron->updated_on, 'Koha::Patron->move_to_deleted should have correctly updated the updated_on column');
    $deleted_patron->{updated_on} = $originally_updated_on; #reset for simplicity in comparing all other fields
    is_deeply( $deleted_patron, $patron, 'Koha::Patron->move_to_deleted should have correctly moved the patron to the deleted table' );
    $retrieved_patron->delete( $patron->{borrowernumber} );    # Cleanup
};

subtest "delete" => sub {
    plan tests => 16;
    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
    t::lib::Mocks::mock_preference( 'ListOwnershipUponPatronDeletion', 'transfer' );
    t::lib::Mocks::mock_preference( 'ListOwnerDesignated', undef );
    Koha::Virtualshelves->delete;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron_for_sharing = $builder->build_object({ class => 'Koha::Patrons' });
    my $staff_patron = $builder->build_object({ class => 'Koha::Patrons' });
    t::lib::Mocks::mock_userenv({ patron => $staff_patron });

    my $hold = $builder->build_object({ class => 'Koha::Holds', value => { borrowernumber => $patron->borrowernumber } });
    my $modification = $builder->build_object({ class => 'Koha::Patron::Modifications', value => { borrowernumber => $patron->borrowernumber } });
    my $private_list = Koha::Virtualshelf->new({
        shelfname => "private",
        owner => $patron->borrowernumber,
        public => 0,
    })->store;
    my $public_list = Koha::Virtualshelf->new({
        shelfname => "public",
        owner => $patron->borrowernumber,
        public => 1,
    })->store;
    my $list_to_share = Koha::Virtualshelf->new({
        shelfname => "shared",
        owner => $patron->borrowernumber,
        public => 0,
    })->store;

    $list_to_share->share("valid key")->accept( "valid key", $patron_for_sharing->borrowernumber );
    $list_to_share->share("valid key")->accept( "valid key", $staff_patron->borrowernumber ); # this share should be removed at deletion too
    my $deleted = $patron->delete;
    is( ref($deleted), 'Koha::Patron', 'Koha::Patron->delete should return the deleted patron object if the patron has been correctly deleted' );
    ok( $patron->borrowernumber, 'Still have the deleted borrowernumber' );

    is( Koha::Patrons->find( $patron->borrowernumber ), undef, 'Koha::Patron->delete should have deleted the patron' );

    is (Koha::Old::Holds->search({ reserve_id => $hold->reserve_id })->count, 1, q|Koha::Patron->delete should have cancelled patron's holds| );

    is( Koha::Holds->search( { borrowernumber => $patron->borrowernumber } )->count, 0, q|Koha::Patron->delete should have cancelled patron's holds 2| );

    my $transferred_lists = Koha::Virtualshelves->search({ owner => $staff_patron->borrowernumber })->count;
    is( $transferred_lists, 2, 'Public and shared lists should stay in database under a different owner with a unique name, while private lists delete, with ListOwnershipPatronDeletion set to Transfer');
    is( Koha::Virtualshelfshares->search({ borrowernumber => $staff_patron->borrowernumber })->count, 0, "New owner of list should have shares removed" );
    is( Koha::Virtualshelfshares->search({ borrowernumber => $patron_for_sharing->borrowernumber })->count, 1, "But the other share is still there" );
    is( Koha::Virtualshelves->search({ owner => $patron->borrowernumber })->count, 0, q|Koha::Patron->delete should have deleted patron's lists/removed their ownership| );

    is( Koha::Patron::Modifications->search( { borrowernumber => $patron->borrowernumber } )->count, 0, q|Koha::Patron->delete should have deleted patron's modifications| );

    my $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'DELETE', object => $patron->borrowernumber } )->count;
    is( $number_of_logs, 1, 'With BorrowerLogs, Koha::Patron->delete should have logged' );

    # Test deletion with designated fallback owner
    my $designated_owner = $builder->build_object({ class => 'Koha::Patrons' });
    t::lib::Mocks::mock_preference( 'ListOwnerDesignated', $designated_owner->id );
    $patron = $builder->build_object({ class => 'Koha::Patrons' });
    $private_list = Koha::Virtualshelf->new({ shelfname => "PR1", owner => $patron->id })->store;
    $public_list = Koha::Virtualshelf->new({ shelfname => "PU1", public => 1, owner => $patron->id })->store;
    $list_to_share = Koha::Virtualshelf->new({ shelfname => "SH1", owner => $patron->id })->store;
    $list_to_share->share("valid key")->accept( "valid key", $patron_for_sharing->id );
    $patron->delete;
    is( Koha::Virtualshelves->find( $private_list->id ), undef, 'Private list gone' );
    is( $public_list->discard_changes->get_column('owner'), $designated_owner->id, 'Public list transferred' );
    is( $list_to_share->discard_changes->get_column('owner'), $designated_owner->id, 'Shared list transferred' );

    # Finally test deleting lists
    t::lib::Mocks::mock_preference( 'ListOwnershipUponPatronDeletion', 'delete' );
    Koha::Virtualshelves->delete;
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons' });
    my $private_list2 = Koha::Virtualshelf->new({
         shelfname => "private",
         owner => $patron2->borrowernumber,
         public => 0,
    })->store;
    my $public_list2 = Koha::Virtualshelf->new({
        shelfname => "public",
        owner => $patron2->borrowernumber,
        public => 1,
    })->store;
    my $list_to_share2 = Koha::Virtualshelf->new({
        shelfname => "shared",
        owner => $patron2->borrowernumber,
        public => 0,
    })->store;
    $list_to_share2->share("valid key")->accept( "valid key", $patron_for_sharing->borrowernumber );

    # Delete patron2, check if shelves and shares are now empty
    $patron2->delete;
    is( Koha::Virtualshelves->count, 0, 'All lists should be gone now' );
    is( Koha::Virtualshelfshares->count, 0, 'All shares should be gone too' );
};

subtest 'Koha::Patrons->delete' => sub {
    plan tests => 3;

    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons' });
    my $id1 = $patron1->borrowernumber;
    my $set = Koha::Patrons->search({ borrowernumber => { -in => [$patron1->borrowernumber, $patron2->borrowernumber]}});
    is( $set->count, 2, 'Two patrons found as expected' );
    is( $set->delete({ move => 1 }), 2, 'Two patrons deleted' );
    my $deleted_patrons = Koha::Old::Patrons->search({ borrowernumber => { -in => [$patron1->borrowernumber, $patron2->borrowernumber]}});
    is( $deleted_patrons->count, 2, 'Patrons moved to deletedborrowers' );

    # See other tests in t/db_dependent/Koha/Objects.t
};

subtest 'add_enrolment_fee_if_needed' => sub {
    plan tests => 4;

    my $enrolmentfees = { K  => 5, J => 10, YA => 20 };
    foreach( keys %{$enrolmentfees} ) {
        ( Koha::Patron::Categories->find( $_ ) // $builder->build_object({ class => 'Koha::Patron::Categories', value => { categorycode => $_ } }) )->enrolmentfee( $enrolmentfees->{$_} )->store;
    }
    my $enrolmentfee_K  = $enrolmentfees->{K};
    my $enrolmentfee_J  = $enrolmentfees->{J};
    my $enrolmentfee_YA = $enrolmentfees->{YA};

    my %borrower_data = (
        firstname    => 'my firstname',
        surname      => 'my surname',
        categorycode => 'K',
        branchcode   => $library->{branchcode},
    );

    my $borrowernumber = Koha::Patron->new(\%borrower_data)->store->borrowernumber;
    $borrower_data{borrowernumber} = $borrowernumber;

    my $patron = Koha::Patrons->find( $borrowernumber );
    my $total = $patron->account->balance;
    is( int($total), int($enrolmentfee_K), "New kid pay $enrolmentfee_K" );

    t::lib::Mocks::mock_preference( 'FeeOnChangePatronCategory', 0 );
    $borrower_data{categorycode} = 'J';
    $patron->set(\%borrower_data)->store;
    $total = $patron->account->balance;
    is( int($total), int($enrolmentfee_K), "Kid growing and become a juvenile, but shouldn't pay for the upgrade " );

    $borrower_data{categorycode} = 'K';
    $patron->set(\%borrower_data)->store;
    t::lib::Mocks::mock_preference( 'FeeOnChangePatronCategory', 1 );

    $borrower_data{categorycode} = 'J';
    $patron->set(\%borrower_data)->store;
    $total = $patron->account->balance;
    is( int($total), int($enrolmentfee_K + $enrolmentfee_J), "Kid growing and become a juvenile, they should pay " . ( $enrolmentfee_K + $enrolmentfee_J ) );

    # Check with calling directly Koha::Patron->get_enrolment_fee_if_needed
    $patron->categorycode('YA')->store;
    $total = $patron->account->balance;
    is( int($total),
        int($enrolmentfee_K + $enrolmentfee_J + $enrolmentfee_YA),
        "Juvenile growing and become an young adult, they should pay " . ( $enrolmentfee_K + $enrolmentfee_J + $enrolmentfee_YA )
    );

    $patron->delete;
};

subtest 'checkouts + pending_checkouts + overdues + old_checkouts' => sub {
    plan tests => 17;

    my $library = $builder->build( { source => 'Branch' } );
    my $biblionumber_1 = $builder->build_sample_biblio->biblionumber;
    my $item_1 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_1,
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_1,
        }
    );
    my $biblionumber_2 = $builder->build_sample_biblio->biblionumber;
    my $item_3 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_2,
        }
    );
    my $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $library->{branchcode} }
        }
    );

    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    my $checkouts = $patron->checkouts;
    is( $checkouts->count, 0, 'checkouts should not return any issues for that patron' );
    is( ref($checkouts), 'Koha::Checkouts', 'checkouts should return a Koha::Checkouts object' );
    my $pending_checkouts = $patron->pending_checkouts;
    is( $pending_checkouts->count, 0, 'pending_checkouts should not return any issues for that patron' );
    is( ref($pending_checkouts), 'Koha::Checkouts', 'pending_checkouts should return a Koha::Checkouts object' );
    my $old_checkouts = $patron->old_checkouts;
    is( $old_checkouts->count, 0, 'old_checkouts should not return any issues for that patron' );
    is( ref($old_checkouts), 'Koha::Old::Checkouts', 'old_checkouts should return a Koha::Old::Checkouts object' );

    # Not sure how this is useful, but AddIssue pass this variable to different other subroutines
    $patron = Koha::Patrons->find( $patron->borrowernumber )->unblessed;

    t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });

    AddIssue( $patron, $item_1->barcode, DateTime->now->subtract( days => 1 ) );
    AddIssue( $patron, $item_2->barcode, DateTime->now->subtract( days => 5 ) );
    AddIssue( $patron, $item_3->barcode );

    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    $checkouts = $patron->checkouts;
    is( $checkouts->count, 3, 'checkouts should return 3 issues for that patron' );
    is( ref($checkouts), 'Koha::Checkouts', 'checkouts should return a Koha::Checkouts object' );
    $pending_checkouts = $patron->pending_checkouts;
    is( $pending_checkouts->count, 3, 'pending_checkouts should return 3 issues for that patron' );
    is( ref($pending_checkouts), 'Koha::Checkouts', 'pending_checkouts should return a Koha::Checkouts object' );

    my $first_checkout = $pending_checkouts->next;
    is( $first_checkout->unblessed_all_relateds->{biblionumber}, $item_3->biblionumber, 'pending_checkouts should prefetch values from other tables (here biblio)' );

    my $overdues = $patron->overdues;
    is( $overdues->count, 2, 'Patron should have 2 overdues');
    is( ref($overdues), 'Koha::Checkouts', 'Koha::Patron->overdues should return Koha::Checkouts' );
    is( $overdues->next->itemnumber, $item_1->itemnumber, 'The issue should be returned in the same order as they have been done, first is correct' );
    is( $overdues->next->itemnumber, $item_2->itemnumber, 'The issue should be returned in the same order as they have been done, second is correct' );


    C4::Circulation::AddReturn( $item_1->barcode );
    C4::Circulation::AddReturn( $item_2->barcode );
    $old_checkouts = $patron->old_checkouts;
    is( $old_checkouts->count, 2, 'old_checkouts should return 2 old checkouts that patron' );
    is( ref($old_checkouts), 'Koha::Old::Checkouts', 'old_checkouts should return a Koha::Old::Checkouts object' );

    # Clean stuffs
    Koha::Checkouts->search( { borrowernumber => $patron->borrowernumber } )->delete;
    $patron->delete;
};

subtest 'get_routing_lists' => sub {
    plan tests => 5;

    my $biblio = Koha::Biblio->new()->store();
    my $subscription = Koha::Subscription->new({
        biblionumber => $biblio->biblionumber,
        }
    )->store;

    my $patron = $builder->build( { source => 'Borrower' } );
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );

    is( $patron->get_routing_lists->count, 0, 'Retrieves correct number of routing lists: 0' );

    my $routinglist_count = Koha::Subscription::Routinglists->count;
    my $routinglist = Koha::Subscription::Routinglist->new({
        borrowernumber   => $patron->borrowernumber,
        ranking          => 5,
        subscriptionid   => $subscription->subscriptionid
    })->store;

    is ($patron->get_routing_lists->count, 1, "Retrieves correct number of routing lists: 1");

    my $routinglists = $patron->get_routing_lists;
    is ($routinglists->next->ranking, 5, "Retrieves ranking: 5");
    is( ref($routinglists),   'Koha::Subscription::Routinglists', 'get_routing_lists returns Koha::Subscription::Routinglists' );

    my $subscription2 = Koha::Subscription->new({
        biblionumber => $biblio->biblionumber,
        }
    )->store;
    my $routinglist2 = Koha::Subscription::Routinglist->new({
        borrowernumber   => $patron->borrowernumber,
        ranking          => 1,
        subscriptionid   => $subscription2->subscriptionid
    })->store;

    is ($patron->get_routing_lists->count, 2, "Retrieves correct number of routing lists: 2");

    $patron->delete; # Clean up for later tests

};

subtest 'get_age' => sub {
    plan tests => 31;

    my $patron = $builder->build( { source => 'Borrower' } );
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );

    my @dates = (
        {
            today            => '2020-02-28',
            has_12           => { date => '2007-08-27', expected_age => 12 },
            almost_18        => { date => '2002-03-01', expected_age => 17 },
            has_18_today     => { date => '2002-02-28', expected_age => 18 },
            had_18_yesterday => { date => '2002-02-27', expected_age => 18 },
            almost_16        => { date => '2004-02-29', expected_age => 15 },
            has_16_today     => { date => '2004-02-28', expected_age => 16 },
            had_16_yesterday => { date => '2004-02-27', expected_age => 16 },
            new_born         => { date => '2020-01-27', expected_age => 0 },
        },
        {
            today            => '2020-02-29',
            has_12           => { date => '2007-08-27', expected_age => 12 },
            almost_18        => { date => '2002-03-01', expected_age => 17 },
            has_18_today     => { date => '2002-02-28', expected_age => 18 },
            had_18_yesterday => { date => '2002-02-27', expected_age => 18 },
            almost_16        => { date => '2004-03-01', expected_age => 15 },
            has_16_today     => { date => '2004-02-29', expected_age => 16 },
            had_16_yesterday => { date => '2004-02-28', expected_age => 16 },
            new_born         => { date => '2020-01-27', expected_age => 0 },
        },
        {
            today            => '2020-03-01',
            has_12           => { date => '2007-08-27', expected_age => 12 },
            almost_18        => { date => '2002-03-02', expected_age => 17 },
            has_18_today     => { date => '2002-03-01', expected_age => 18 },
            had_18_yesterday => { date => '2002-02-28', expected_age => 18 },
            almost_16        => { date => '2004-03-02', expected_age => 15 },
            has_16_today     => { date => '2004-03-01', expected_age => 16 },
            had_16_yesterday => { date => '2004-02-29', expected_age => 16 },
        },
        {
            today            => '2019-01-31',
            has_12           => { date => '2006-08-27', expected_age => 12 },
            almost_18        => { date => '2001-02-01', expected_age => 17 },
            has_18_today     => { date => '2001-01-31', expected_age => 18 },
            had_18_yesterday => { date => '2001-01-30', expected_age => 18 },
            almost_16        => { date => '2003-02-01', expected_age => 15 },
            has_16_today     => { date => '2003-01-31', expected_age => 16 },
            had_16_yesterday => { date => '2003-01-30', expected_age => 16 },
        },
    );

    $patron->dateofbirth( undef );
    is( $patron->get_age, undef, 'get_age should return undef if no dateofbirth is defined' );

    for my $date ( @dates ) {

        my $dt = dt_from_string($date->{today});

        Time::Fake->offset( $dt->epoch );

        for my $k ( keys %$date ) {
            next if $k eq 'today';

            my $dob = $date->{$k};
            $patron->dateofbirth( dt_from_string( $dob->{date}, 'iso' ) );
            is(
                $patron->get_age,
                $dob->{expected_age},
                sprintf(
                    "Today=%s, dob=%s, should be %d",
                    $date->{today}, $dob->{date}, $dob->{expected_age}
                )
            );
        }

        Time::Fake->reset;

    }

    $patron->delete;
};

subtest 'is_valid_age' => sub {
    plan tests => 10;

    my $dt = dt_from_string('2020-02-28');

    Time::Fake->offset( $dt->epoch );

    my $category = $builder->build({
        source => 'Category',
        value => {
            categorycode        => 'AGE_5_10',
            dateofbirthrequired => 5,
            upperagelimit       => 10
        }
    });
    $category = Koha::Patron::Categories->find( $category->{categorycode} );

    my $patron = $builder->build({
        source => 'Borrower',
        value => {
            categorycode        => $category->categorycode
        }
    });
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );


    $patron->dateofbirth( undef );
    is( $patron->is_valid_age, 1, 'Patron with no dateofbirth is always valid for any category');

    my @dates = (
        {
            today => '2020-02-28',
            add_m12_m6_m1 =>
              { date => '2007-08-27', expected_age => 12, valid => 0 },
            add_m3_m6_m1 =>
              { date => '2016-08-27', expected_age => 3, valid => 0 },
            add_m7_m6_m1 =>
              { date => '2013-02-28', expected_age => 7, valid => 1 },
            add_m5_0_0 =>
              { date => '2015-02-28', expected_age => 5, valid => 1 },
            add_m5_0_p1 =>
              { date => '2015-03-01', expected_age => 4, valid => 0 },
            add_m5_0_m1 =>
              { date => '2015-02-27', expected_age => 5, valid => 1 },
            add_m11_0_0 =>
              { date => '2009-02-28', expected_age => 11, valid => 0 },
            add_m11_0_p1 =>
              { date => '2009-03-01', expected_age => 10, valid => 1 },
            add_m11_0_m1 =>
              { date => '2009-02-27', expected_age => 11, valid => 0 },
        },
    );

    for my $date ( @dates ) {

        my $dt = dt_from_string($date->{today});

        Time::Fake->offset( $dt->epoch );

        for my $k ( sort keys %$date ) {
            next if $k eq 'today';

            my $dob = $date->{$k};
            $patron->dateofbirth( dt_from_string( $dob->{date}, 'iso' ) );
            is(
                $patron->is_valid_age,
                $dob->{valid},
                sprintf(
                    "Today=%s, dob=%s, is %s, should be valid=%s in category %s",
                    $date->{today}, $dob->{date}, $dob->{expected_age}, $dob->{valid}, $category->categorycode
                )
            );
        }

        Time::Fake->reset;

    }

    $patron->delete;
    $category->delete;
};

subtest 'account' => sub {
    plan tests => 1;

    my $patron = $builder->build({source => 'Borrower'});

    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    my $account = $patron->account;
    is( ref($account),   'Koha::Account', 'account should return a Koha::Account object' );

    $patron->delete;
};

subtest 'search_upcoming_membership_expires' => sub {
    plan tests => 9;

    my $expiry_days = 15;
    t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', $expiry_days );
    my $nb_of_days_before = 1;
    my $nb_of_days_after = 2;

    my $builder = t::lib::TestBuilder->new();

    my $library = $builder->build({ source => 'Branch' });

    # before we add borrowers to this branch, add the expires we have now
    # note that this pertains to the current mocked setting of the pref
    # for this reason we add the new branchcode to most of the tests
    my $nb_of_expires = Koha::Patrons->search_upcoming_membership_expires->count;

    my $patron_1 = $builder->build({
        source => 'Borrower',
        value  => {
            branchcode              => $library->{branchcode},
            dateexpiry              => dt_from_string->add( days => $expiry_days )
        },
    });

    my $patron_2 = $builder->build({
        source => 'Borrower',
        value  => {
            branchcode              => $library->{branchcode},
            dateexpiry              => dt_from_string->add( days => $expiry_days - $nb_of_days_before )
        },
    });

    my $patron_3 = $builder->build({
        source => 'Borrower',
        value  => {
            branchcode              => $library->{branchcode},
            dateexpiry              => dt_from_string->add( days => $expiry_days + $nb_of_days_after )
        },
    });

    # Test without extra parameters
    my $upcoming_mem_expires = Koha::Patrons->search_upcoming_membership_expires();
    is( $upcoming_mem_expires->count, $nb_of_expires + 1, 'Get upcoming membership expires should return one new borrower.' );

    # Test with branch
    $upcoming_mem_expires = Koha::Patrons->search_upcoming_membership_expires({ 'me.branchcode' => $library->{branchcode} });
    is( $upcoming_mem_expires->count, 1, 'Test with branch parameter' );
    my $expired = $upcoming_mem_expires->next;
    is( $expired->surname, $patron_1->{surname}, 'Get upcoming membership expires should return the correct patron.' );
    is( $expired->library->branchemail, $library->{branchemail}, 'Get upcoming membership expires should return the correct patron.' );
    is( $expired->branchcode, $patron_1->{branchcode}, 'Get upcoming membership expires should return the correct patron.' );

    t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', 0 );
    $upcoming_mem_expires = Koha::Patrons->search_upcoming_membership_expires({ 'me.branchcode' => $library->{branchcode} });
    is( $upcoming_mem_expires->count, 0, 'Get upcoming membership expires with MembershipExpiryDaysNotice==0 should not return new records.' );

    # Test MembershipExpiryDaysNotice == undef
    t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', undef );
    $upcoming_mem_expires = Koha::Patrons->search_upcoming_membership_expires({ 'me.branchcode' => $library->{branchcode} });
    is( $upcoming_mem_expires->count, 0, 'Get upcoming membership expires without MembershipExpiryDaysNotice should not return new records.' );

    # Test the before parameter
    t::lib::Mocks::mock_preference( 'MembershipExpiryDaysNotice', 15 );
    $upcoming_mem_expires = Koha::Patrons->search_upcoming_membership_expires({ 'me.branchcode' => $library->{branchcode}, before => $nb_of_days_before });
    is( $upcoming_mem_expires->count, 2, 'Expect two results for before');
    # Test after parameter also
    $upcoming_mem_expires = Koha::Patrons->search_upcoming_membership_expires({ 'me.branchcode' => $library->{branchcode}, before => $nb_of_days_before, after => $nb_of_days_after });
    is( $upcoming_mem_expires->count, 3, 'Expect three results when adding after' );
    Koha::Patrons->search({ borrowernumber => { in => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber}, $patron_3->{borrowernumber} ] } })->delete;
};

subtest 'holds and old_holds' => sub {
    plan tests => 6;

    my $library = $builder->build( { source => 'Branch' } );
    my $biblionumber_1 = $builder->build_sample_biblio->biblionumber;
    my $item_1 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_1,
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_1,
        }
    );
    my $biblionumber_2 = $builder->build_sample_biblio->biblionumber;
    my $item_3 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_2,
        }
    );

    my $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $library->{branchcode} }
        }
    );

    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    my $holds = $patron->holds;
    is( ref($holds), 'Koha::Holds',
        'Koha::Patron->holds should return a Koha::Holds objects' );
    is( $holds->count, 0, 'There should not be holds placed by this patron yet' );

    C4::Reserves::AddReserve(
        {
            branchcode     => $library->{branchcode},
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblionumber_1
        }
    );
    # In the future
    C4::Reserves::AddReserve(
        {
            branchcode      => $library->{branchcode},
            borrowernumber  => $patron->borrowernumber,
            biblionumber    => $biblionumber_2,
            expiration_date => dt_from_string->add( days => 2 )
        }
    );

    $holds = $patron->holds;
    is( $holds->count, 2, 'There should be 2 holds placed by this patron' );

    my $old_holds = $patron->old_holds;
    is( ref($old_holds), 'Koha::Old::Holds',
        'Koha::Patron->old_holds should return a Koha::Old::Holds objects' );
    is( $old_holds->count, 0, 'There should not be any old holds yet');

    my $hold = $holds->next;
    $hold->cancel;

    $old_holds = $patron->old_holds;
    is( $old_holds->count, 1, 'There should  be 1 old (cancelled) hold');

    $old_holds->delete;
    $holds->delete;
    $patron->delete;
};

subtest 'notice_email_address' => sub {
    plan tests => 2;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });

    t::lib::Mocks::mock_preference( 'AutoEmailPrimaryAddress', 'OFF' );
    is ($patron->notice_email_address, $patron->email, "Koha::Patron->notice_email_address returns correct value when AutoEmailPrimaryAddress is off");

    t::lib::Mocks::mock_preference( 'AutoEmailPrimaryAddress', 'emailpro' );
    is ($patron->notice_email_address, $patron->emailpro, "Koha::Patron->notice_email_address returns correct value when AutoEmailPrimaryAddress is emailpro");

    $patron->delete;
};

subtest 'search_patrons_to_anonymise' => sub {

    plan tests => 5;

    # TODO create a subroutine in t::lib::Mocks
    my $branch = $builder->build({ source => 'Branch' });
    my $userenv_patron = $builder->build_object({
        class  => 'Koha::Patrons',
        value  => { branchcode => $branch->{branchcode}, flags => 0 },
    });
    t::lib::Mocks::mock_userenv({ patron => $userenv_patron });

    my $anonymous = $builder->build( { source => 'Borrower', }, );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous->{borrowernumber} );

    subtest 'Anonymous Patron should be undeleteable' => sub {
        plan tests => 2;

        my $anonymous_patron = Koha::Patrons->find( $anonymous->{borrowernumber} );
        throws_ok { $anonymous_patron->delete(); }
            'Koha::Exceptions::Patron::FailedDeleteAnonymousPatron',
            'Attempt to delete anonymous patron throws exception.';
        $anonymous_patron = Koha::Patrons->find( $anonymous->{borrowernumber} );
        is( $anonymous_patron->id, $anonymous->{borrowernumber}, "Anonymous Patron was not deleted" );
    };

    subtest 'patron privacy is 1 (default)' => sub {
        plan tests => 9;

        t::lib::Mocks::mock_preference('IndependentBranches', 0);
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => { privacy => 1, }
            }
        );
        my $item_1 = $builder->build_sample_item;
        my $issue_1 = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item_1->itemnumber,
                },
            }
        );
        my $item_2 = $builder->build_sample_item;
        my $issue_2 = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item_2->itemnumber,
                },
            }
        );

        my ( $returned_1, undef, undef ) = C4::Circulation::AddReturn( $item_1->barcode, undef, undef, dt_from_string('2010-10-10') );
        my ( $returned_2, undef, undef ) = C4::Circulation::AddReturn( $item_2->barcode, undef, undef, dt_from_string('2011-11-11') );
        is( $returned_1 && $returned_2, 1, 'The items should have been returned' );

        my $patrons_to_anonymise = Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } )->search( { 'me.borrowernumber' => $patron->{borrowernumber} } );
        is( ref($patrons_to_anonymise), 'Koha::Patrons', 'search_patrons_to_anonymise should return Koha::Patrons' );

        my $rows_affected = Koha::Old::Checkouts->search(
            {
                borrowernumber => [
                    Koha::Patrons->search_patrons_to_anonymise(
                        { before => '2011-11-12' }
                    )->get_column('borrowernumber')
                ],
                returndate => { '<' => '2011-10-11', }
            }
        )->anonymize;
        ok( $rows_affected > 0, 'AnonymiseIssueHistory should affect at least 1 row' );

        $patrons_to_anonymise = Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } );
        is( $patrons_to_anonymise->count, 0, 'search_patrons_to_anonymise should return 0 after anonymisation is done' );

        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(q|SELECT borrowernumber FROM old_issues where itemnumber = ?|);
        $sth->execute($item_1->itemnumber);
        my ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'With privacy=1, the issue should have been anonymised' );
        $sth->execute($item_2->itemnumber);
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $patron->{borrowernumber}, 'The issue should not have been anonymised, the returned date is later' );

        $rows_affected = Koha::Old::Checkouts->search(
            {
                borrowernumber => [
                    Koha::Patrons->search_patrons_to_anonymise(
                        { before => '2011-11-12' }
                    )->get_column('borrowernumber')
                ],
                returndate => { '<' => '2011-11-12', }
            }
        )->anonymize;
        $sth->execute($item_2->itemnumber);
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'The issue should have been anonymised, the returned date is before' );

        my $sth_reset = $dbh->prepare(q|UPDATE old_issues SET borrowernumber = ? WHERE itemnumber = ?|);
        $sth_reset->execute( $patron->{borrowernumber}, $item_1->itemnumber );
        $sth_reset->execute( $patron->{borrowernumber}, $item_2->itemnumber );
        $rows_affected = Koha::Old::Checkouts->search(
            {
                borrowernumber => [
                    Koha::Patrons->search_patrons_to_anonymise->get_column(
                        'borrowernumber')
                ]
            }
        )->anonymize;
        $sth->execute($item_1->itemnumber);
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'The issue 1 should have been anonymised, before parameter was not passed' );
        $sth->execute($item_2->itemnumber);
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'The issue 2 should have been anonymised, before parameter was not passed' );

        Koha::Patrons->find( $patron->{borrowernumber})->delete;
    };

    subtest 'patron privacy is 0 (forever)' => sub {
        plan tests => 2;

        t::lib::Mocks::mock_preference('IndependentBranches', 0);
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => { privacy => 0, }
            }
        );
        my $item = $builder->build_sample_item;
        my $issue = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->itemnumber,
                },
            }
        );

        my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->barcode, undef, undef, dt_from_string('2010-10-10') );
        is( $returned, 1, 'The item should have been returned' );

        my $dbh = C4::Context->dbh;
        my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
            SELECT borrowernumber FROM old_issues where itemnumber = ?
        |, undef, $item->itemnumber);
        is( $borrowernumber_used_to_anonymised, $patron->{borrowernumber}, 'With privacy=0, the issue should not be anonymised' );
        Koha::Patrons->find( $patron->{borrowernumber})->delete;
    };

    t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );

    subtest 'AnonymousPatron is not defined' => sub {

        plan tests => 2;

        t::lib::Mocks::mock_preference('IndependentBranches', 0);
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => { privacy => 1, }
            }
        );
        my $item = $builder->build_sample_item;
        my $issue = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->itemnumber,
                },
            }
        );

        my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->barcode, undef, undef, dt_from_string('2010-10-10') );
        is( $returned, 1, 'The item should have been returned' );
        my $patrons_to_anonymize = Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } );
        ok( $patrons_to_anonymize->count > 0, 'search_patrons_to_anonymize' );

        Koha::Patrons->find( $patron->{borrowernumber})->delete;
    };

    subtest 'Logged in librarian is not superlibrarian & IndependentBranches' => sub {
        plan tests => 1;
        t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => { privacy => 1 }    # Another branchcode than the logged in librarian
            }
        );
        my $item = $builder->build_sample_item;
        my $issue = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->itemnumber,
                },
            }
        );

        my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->barcode, undef, undef, dt_from_string('2010-10-10') );
        is( Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } )->count, 0 );
        Koha::Patrons->find( $patron->{borrowernumber})->delete;
    };

    Koha::Patrons->find( $anonymous->{borrowernumber})->delete;
    $userenv_patron->delete;

    # Reset IndependentBranches for further tests
    t::lib::Mocks::mock_preference('IndependentBranches', 0);
};

subtest 'libraries_where_can_see_patrons + can_see_patron_infos + search_limited' => sub {
    plan tests => 3;

    # group1
    #   + library_11
    #   + library_12
    # group2
    #   + library21
    $nb_of_patrons = Koha::Patrons->search->count;
    my $group_1 = Koha::Library::Group->new( { title => 'TEST Group 1', ft_hide_patron_info => 1 } )->store;
    my $group_2 = Koha::Library::Group->new( { title => 'TEST Group 2', ft_hide_patron_info => 1 } )->store;
    my $library_11 = $builder->build( { source => 'Branch' } );
    my $library_12 = $builder->build( { source => 'Branch' } );
    my $library_21 = $builder->build( { source => 'Branch' } );
    $library_11 = Koha::Libraries->find( $library_11->{branchcode} );
    $library_12 = Koha::Libraries->find( $library_12->{branchcode} );
    $library_21 = Koha::Libraries->find( $library_21->{branchcode} );
    Koha::Library::Group->new(
        { branchcode => $library_11->branchcode, parent_id => $group_1->id } )->store;
    Koha::Library::Group->new(
        { branchcode => $library_12->branchcode, parent_id => $group_1->id } )->store;
    Koha::Library::Group->new(
        { branchcode => $library_21->branchcode, parent_id => $group_2->id } )->store;

    my $sth = C4::Context->dbh->prepare(q|INSERT INTO user_permissions( borrowernumber, module_bit, code ) VALUES (?, 4, ?)|); # 4 for borrowers
    # 2 patrons from library_11 (group1)
    # patron_11_1 see patron's infos from outside its group
    # Setting flags => undef to not be considered as superlibrarian
    my $patron_11_1 = $builder->build({ source => 'Borrower', value => { branchcode => $library_11->branchcode, flags => undef, }});
    $patron_11_1 = Koha::Patrons->find( $patron_11_1->{borrowernumber} );
    $sth->execute( $patron_11_1->borrowernumber, 'edit_borrowers' );
    $sth->execute( $patron_11_1->borrowernumber, 'view_borrower_infos_from_any_libraries' );
    # patron_11_2 can only see patron's info from its group
    my $patron_11_2 = $builder->build({ source => 'Borrower', value => { branchcode => $library_11->branchcode, flags => undef, }});
    $patron_11_2 = Koha::Patrons->find( $patron_11_2->{borrowernumber} );
    $sth->execute( $patron_11_2->borrowernumber, 'edit_borrowers' );
    # 1 patron from library_12 (group1)
    my $patron_12 = $builder->build({ source => 'Borrower', value => { branchcode => $library_12->branchcode, flags => undef, }});
    $patron_12 = Koha::Patrons->find( $patron_12->{borrowernumber} );
    # 1 patron from library_21 (group2) can only see patron's info from its group
    my $patron_21 = $builder->build({ source => 'Borrower', value => { branchcode => $library_21->branchcode, flags => undef, }});
    $patron_21 = Koha::Patrons->find( $patron_21->{borrowernumber} );
    $sth->execute( $patron_21->borrowernumber, 'edit_borrowers' );

    # Pfiou, we can start now!
    subtest 'libraries_where_can_see_patrons' => sub {
        plan tests => 3;

        my @branchcodes;

        t::lib::Mocks::mock_userenv({ patron => $patron_11_1 });
        @branchcodes = $patron_11_1->libraries_where_can_see_patrons;
        is_deeply( \@branchcodes, [], q|patron_11_1 has view_borrower_infos_from_any_libraries => No restriction| );

        t::lib::Mocks::mock_userenv({ patron => $patron_11_2 });
        @branchcodes = $patron_11_2->libraries_where_can_see_patrons;
        is_deeply( \@branchcodes, [ sort ( $library_11->branchcode, $library_12->branchcode ) ], q|patron_11_2 has not view_borrower_infos_from_any_libraries => Can only see patron's from its group| );

        t::lib::Mocks::mock_userenv({ patron => $patron_21 });
        @branchcodes = $patron_21->libraries_where_can_see_patrons;
        is_deeply( \@branchcodes, [$library_21->branchcode], q|patron_21 has not view_borrower_infos_from_any_libraries => Can only see patron's from its group| );
    };
    subtest 'can_see_patron_infos' => sub {
        plan tests => 6;

        t::lib::Mocks::mock_userenv({ patron => $patron_11_1 });
        is( $patron_11_1->can_see_patron_infos( $patron_11_2 ), 1, q|patron_11_1 can see patron_11_2, from its library| );
        is( $patron_11_1->can_see_patron_infos( $patron_12 ),   1, q|patron_11_1 can see patron_12, from its group| );
        is( $patron_11_1->can_see_patron_infos( $patron_21 ),   1, q|patron_11_1 can see patron_11_2, from another group| );

        t::lib::Mocks::mock_userenv({ patron => $patron_11_2 });
        is( $patron_11_2->can_see_patron_infos( $patron_11_1 ), 1, q|patron_11_2 can see patron_11_1, from its library| );
        is( $patron_11_2->can_see_patron_infos( $patron_12 ),   1, q|patron_11_2 can see patron_12, from its group| );
        is( $patron_11_2->can_see_patron_infos( $patron_21 ),   0, q|patron_11_2 can NOT see patron_21, from another group| );
    };
    subtest 'search_limited' => sub {
        plan tests => 6;

        t::lib::Mocks::mock_userenv({ patron => $patron_11_1 });
        my $total_number_of_patrons = $nb_of_patrons + 4; #we added four in these tests
        is( Koha::Patrons->search->count, $total_number_of_patrons, 'Non-limited search should return all patrons' );
        is( Koha::Patrons->search_limited->count, $total_number_of_patrons, 'patron_11_1 is allowed to see all patrons' );

        t::lib::Mocks::mock_userenv({ patron => $patron_11_2 });
        is( Koha::Patrons->search->count, $total_number_of_patrons, 'Non-limited search should return all patrons');
        is( Koha::Patrons->search_limited->count, 3, 'patron_12_1 is not allowed to see patrons from other groups, only patron_11_1, patron_11_2 and patron_12' );

        t::lib::Mocks::mock_userenv({ patron => $patron_21 });
        is( Koha::Patrons->search->count, $total_number_of_patrons, 'Non-limited search should return all patrons');
        is( Koha::Patrons->search_limited->count, 1, 'patron_21 is not allowed to see patrons from other groups, only himself' );
    };
    $patron_11_1->delete;
    $patron_11_2->delete;
    $patron_12->delete;
    $patron_21->delete;
};

subtest 'account_locked' => sub {
    plan tests => 13;
    my $patron = $builder->build({ source => 'Borrower', value => { login_attempts => 0 } });
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    for my $value ( undef, '', 0 ) {
        t::lib::Mocks::mock_preference('FailedloginAttempts', $value);
        $patron->login_attempts(0)->store;
        is( $patron->account_locked, 0, 'Feature is disabled, patron account should not be considered locked' );
        $patron->login_attempts(1)->store;
        is( $patron->account_locked, 0, 'Feature is disabled, patron account should not be considered locked' );
        $patron->login_attempts(-1)->store;
        is( $patron->account_locked, 1, 'Feature is disabled but administrative lockout has been triggered' );
    }

    t::lib::Mocks::mock_preference('FailedloginAttempts', 3);
    $patron->login_attempts(2)->store;
    is( $patron->account_locked, 0, 'Patron has 2 failed attempts, account should not be considered locked yet' );
    $patron->login_attempts(3)->store;
    is( $patron->account_locked, 1, 'Patron has 3 failed attempts, account should be considered locked yet' );
    $patron->login_attempts(4)->store;
    is( $patron->account_locked, 1, 'Patron could not have 4 failed attempts, but account should still be considered locked' );
    $patron->login_attempts(-1)->store;
    is( $patron->account_locked, 1, 'Administrative lockout triggered' );

    $patron->delete;
};

subtest 'is_child | is_adult' => sub {
    plan tests => 8;
    my $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'A' }
        }
    );
    my $patron_adult = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $category->categorycode }
        }
    );
    $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'I' }
        }
    );
    my $patron_adult_i = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $category->categorycode }
        }
    );
    $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'C' }
        }
    );
    my $patron_child = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $category->categorycode }
        }
    );
    $category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'O' }
        }
    );
    my $patron_other = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $category->categorycode }
        }
    );
    is( $patron_adult->is_adult, 1, 'Patron from category A should be considered adult' );
    is( $patron_adult_i->is_adult, 1, 'Patron from category I should be considered adult' );
    is( $patron_child->is_adult, 0, 'Patron from category C should not be considered adult' );
    is( $patron_other->is_adult, 0, 'Patron from category O should not be considered adult' );

    is( $patron_adult->is_child, 0, 'Patron from category A should be considered child' );
    is( $patron_adult_i->is_child, 0, 'Patron from category I should be considered child' );
    is( $patron_child->is_child, 1, 'Patron from category C should not be considered child' );
    is( $patron_other->is_child, 0, 'Patron from category O should not be considered child' );

    # Clean up
    $patron_adult->delete;
    $patron_adult_i->delete;
    $patron_child->delete;
    $patron_other->delete;
};

subtest 'overdues' => sub {
    plan tests => 7;

    my $library = $builder->build( { source => 'Branch' } );
    my $biblionumber_1 = $builder->build_sample_biblio->biblionumber;
    my $item_1 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_1,
        }
    );
    my $item_2 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
            biblionumber => $biblionumber_1,
        }
    );
    my $item_3 = $builder->build_sample_item(
        {
            library      => $library->{branchcode},
        }
    );

    my $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $library->{branchcode} }
        }
    );

    t::lib::Mocks::mock_preference({ branchcode => $library->{branchcode} });

    AddIssue( $patron, $item_1->barcode, DateTime->now->subtract( days => 1 ) );
    AddIssue( $patron, $item_2->barcode, DateTime->now->subtract( days => 5 ) );
    AddIssue( $patron, $item_3->barcode );

    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    my $overdues = $patron->overdues;
    is( $overdues->count, 2, 'Patron should have 2 overdues');
    is( $overdues->next->itemnumber, $item_1->itemnumber, 'The issue should be returned in the same order as they have been done, first is correct' );
    is( $overdues->next->itemnumber, $item_2->itemnumber, 'The issue should be returned in the same order as they have been done, second is correct' );

    my $o = $overdues->reset->next;
    my $unblessed_overdue = $o->unblessed_all_relateds;
    is( exists( $unblessed_overdue->{issuedate} ), 1, 'Fields from the issues table should be filled' );
    is( exists( $unblessed_overdue->{itemcallnumber} ), 1, 'Fields from the items table should be filled' );
    is( exists( $unblessed_overdue->{title} ), 1, 'Fields from the biblio table should be filled' );
    is( exists( $unblessed_overdue->{itemtype} ), 1, 'Fields from the biblioitems table should be filled' );

    # Clean stuffs
    $patron->checkouts->delete;
    $patron->delete;
};

subtest 'userid_is_valid' => sub {
    plan tests => 9;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'P', enrolmentfee => 0 }
        }
    );
    my %data = (
        cardnumber   => "123456789",
        firstname    => "Tomasito",
        surname      => "None",
        categorycode => $patron_category->categorycode,
        branchcode   => $library->branchcode,
    );

    my $expected_userid_patron_1 = 'tomasito.none';
    my $borrowernumber = Koha::Patron->new(\%data)->store->borrowernumber;
    my $patron_1       = Koha::Patrons->find($borrowernumber);
    is( $patron_1->has_valid_userid, 1, "Should be valid when compared against them self" );
    is ( $patron_1->userid, $expected_userid_patron_1, 'The userid generated should be the one we expect' );

    $patron_1->userid( 'tomasito.non' );
    is( $patron_1->has_valid_userid, # FIXME Joubu: What is the difference with the next test?
        1, 'recently created userid -> unique (borrowernumber passed)' );

    $patron_1->userid( 'tomasitoxxx' );
    is( $patron_1->has_valid_userid,
        1, 'non-existent userid -> unique (borrowernumber passed)' );
    $patron_1->discard_changes; # We compare with the original userid later

    my $patron_not_in_storage = Koha::Patron->new( { userid => '' } );
    is( $patron_not_in_storage->has_valid_userid,
        0, 'userid exists for another patron, patron is not in storage yet' );

    $patron_not_in_storage = Koha::Patron->new( { userid => 'tomasitoxxx' } );
    is( $patron_not_in_storage->has_valid_userid,
        1, 'non-existent userid, patron is not in storage yet' );

    # Regression tests for BZ12226
    my $db_patron = Koha::Patron->new( { userid => C4::Context->config('user') } );
    is( $db_patron->has_valid_userid,
        0, 'Koha::Patron->has_valid_userid should return 0 for the DB user (Bug 12226)' );

    # Add a new borrower with the same userid but different cardnumber
    $data{cardnumber} = "987654321";
    my $new_borrowernumber = Koha::Patron->new(\%data)->store->borrowernumber;
    my $patron_2 = Koha::Patrons->find($new_borrowernumber);
    $patron_2->userid($patron_1->userid);
    is( $patron_2->has_valid_userid,
        0, 'The userid is already in used, it cannot be used for another patron' );

    my $new_userid = 'a_user_id';
    $data{cardnumber} = "234567890";
    $data{userid}     = 'a_user_id';
    $borrowernumber   = Koha::Patron->new(\%data)->store->borrowernumber;
    my $patron_3 = Koha::Patrons->find($borrowernumber);
    is( $patron_3->userid, $new_userid,
        'Koha::Patron->store should insert the given userid' );

    # Cleanup
    $patron_1->delete;
    $patron_2->delete;
    $patron_3->delete;
};

subtest 'generate_userid' => sub {
    plan tests => 7;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'P', enrolmentfee => 0 }
        }
    );
    my %data = (
        cardnumber   => "123456789",
        firstname    => "Tômàsító",
        surname      => "Ñoné",
        categorycode => $patron_category->categorycode,
        branchcode   => $library->branchcode,
    );

    my $expected_userid_patron_1 = 'tomasito.none';
    my $new_patron = Koha::Patron->new({ firstname => $data{firstname}, surname => $data{surname} } );
    $new_patron->generate_userid;
    my $userid = $new_patron->userid;
    is( $userid, $expected_userid_patron_1, 'generate_userid should generate the userid we expect' );
    my $borrowernumber = Koha::Patron->new(\%data)->store->borrowernumber;
    my $patron_1 = Koha::Patrons->find($borrowernumber);
    is ( $patron_1->userid, $expected_userid_patron_1, 'The userid generated should be the one we expect' );

    $new_patron->generate_userid;
    $userid = $new_patron->userid;
    is( $userid, $expected_userid_patron_1 . '1', 'generate_userid should generate the userid we expect' );
    $data{cardnumber} = '987654321';
    my $new_borrowernumber = Koha::Patron->new(\%data)->store->borrowernumber;
    my $patron_2 = Koha::Patrons->find($new_borrowernumber);
    isnt( $patron_2->userid, 'tomasito',
        "Patron with duplicate userid has new userid generated" );
    is( $patron_2->userid, $expected_userid_patron_1 . '1', # TODO we could make that configurable
        "Patron with duplicate userid has new userid generated (1 is appened" );

    $new_patron->generate_userid;
    $userid = $new_patron->userid;
    is( $userid, $expected_userid_patron_1 . '2', 'generate_userid should generate the userid we expect' );

    $patron_1 = Koha::Patrons->find($borrowernumber);
    $patron_1->userid(undef);
    $patron_1->generate_userid;
    $userid = $patron_1->userid;
    is( $userid, $expected_userid_patron_1, 'generate_userid should generate the userid we expect' );

    # Cleanup
    $patron_1->delete;
    $patron_2->delete;
};

$nb_of_patrons = Koha::Patrons->search->count;
$retrieved_patron_1->delete;
is( Koha::Patrons->search->count, $nb_of_patrons - 1, 'Delete should have deleted the patron' );

subtest 'BorrowersLog tests' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $cardnumber = $patron->cardnumber;
    $patron->set( { cardnumber => 'TESTCARDNUMBER' });
    $patron->store;

    my @logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'MODIFY', object => $patron->borrowernumber } );
    my $log_info = from_json( $logs[0]->info );
    is( $log_info->{cardnumber}->{after}, 'TESTCARDNUMBER', 'Got correct new cardnumber' );
    is( $log_info->{cardnumber}->{before}, $cardnumber, 'Got correct old cardnumber' );
    is( scalar @logs, 1, 'With BorrowerLogs, one detailed MODIFY action should be logged for the modification.' );

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', 1 );
    $patron->track_login();
    @logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'MODIFY', object => $patron->borrowernumber } );
    is( scalar @logs, 1, 'With BorrowerLogs and TrackLastPatronActivity we should not spam the logs');
};

$schema->storage->txn_rollback;

subtest 'Test Koha::Patrons::merge' => sub {
    plan tests => 110;

    my $schema = Koha::Database->new()->schema();

    my $resultsets = $Koha::Patron::RESULTSET_PATRON_ID_MAPPING;

    $schema->storage->txn_begin;

    my $keeper  = $builder->build_object({ class => 'Koha::Patrons' });
    my $loser_1 = $builder->build({ source => 'Borrower' })->{borrowernumber};
    my $loser_2 = $builder->build({ source => 'Borrower' })->{borrowernumber};

    my $anonymous_patron_orig = C4::Context->preference('AnonymousPatron');
    my $anonymous_patron = $builder->build({ source => 'Borrower' })->{borrowernumber};
    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron );

    while (my ($r, $field) = each(%$resultsets)) {
        $builder->build({ source => $r, value => { $field => $keeper->id } });
        $builder->build({ source => $r, value => { $field => $loser_1 } });
        $builder->build({ source => $r, value => { $field => $loser_2 } });

        my $keeper_rs =
          $schema->resultset($r)->search( { $field => $keeper->id } );
        is( $keeper_rs->count(), 1, "Found 1 $r rows for keeper" );

        my $loser_1_rs =
          $schema->resultset($r)->search( { $field => $loser_1 } );
        is( $loser_1_rs->count(), 1, "Found 1 $r rows for loser_1" );

        my $loser_2_rs =
          $schema->resultset($r)->search( { $field => $loser_2 } );
        is( $loser_2_rs->count(), 1, "Found 1 $r rows for loser_2" );
    }

    my $results = $keeper->merge_with([ $loser_1, $loser_2 ]);

    while (my ($r, $field) = each(%$resultsets)) {
        my $keeper_rs =
          $schema->resultset($r)->search( {$field => $keeper->id } );
        is( $keeper_rs->count(), 3, "Found 2 $r rows for keeper" );
    }

    is( Koha::Patrons->find($loser_1), undef, 'Loser 1 has been deleted' );
    is( Koha::Patrons->find($loser_2), undef, 'Loser 2 has been deleted' );
    is( ref Koha::Patrons->find($anonymous_patron), 'Koha::Patron', 'Anonymous Patron was not deleted' );

    $anonymous_patron = Koha::Patrons->find($anonymous_patron);
    $results = $anonymous_patron->merge_with( [ $keeper->id ] );
    is( $results, undef, "Anonymous patron cannot have other patrons merged into it" );
    is( Koha::Patrons->search( { borrowernumber => $keeper->id } )->count, 1, "Patron from attempted merge with AnonymousPatron still exists" );

    subtest 'extended attributes' => sub {
        plan tests => 8;

        my $keep_patron =
          $builder->build_object( { class => 'Koha::Patrons' } );
        my $merge_patron =
          $builder->build_object( { class => 'Koha::Patrons' } );

        my $attribute_type_normal_1 = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => { repeatable => 0, unique_id => 0 }
            }
        );
        my $attribute_type_normal_2 = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => { repeatable => 0, unique_id => 0 }
            }
        );

        my $attribute_type_repeatable = $builder->build_object(
            {
                class => 'Koha::Patron::Attribute::Types',
                value => { repeatable => 1, unique_id => 0 }
            }
        );

        my $attr_keep = [
            {
                code      => $attribute_type_normal_1->code,
                attribute => 'from attr 1'
            },
            {
                code      => $attribute_type_repeatable->code,
                attribute => 'from attr repeatable'
            }
        ];

        my $attr_merge = [
            {
                code      => $attribute_type_normal_2->code,
                attribute => 'to attr 2'
            },
            {
                code      => $attribute_type_repeatable->code,
                attribute => 'to attr repeatable'
            },
        ];

        $keep_patron->extended_attributes($attr_keep);
        $merge_patron->extended_attributes($attr_merge);

        $keep_patron->merge_with( [ $merge_patron->borrowernumber ] );
        my $merged_attributes = $keep_patron->extended_attributes;
        is( $merged_attributes->count, 4 );

        sub compare_attributes {
            my ( $got, $expected, $code ) = @_;

            is_deeply(
                [
                    sort $got->search( { code => $code } )
                      ->get_column('attribute')
                ],
                $expected
            );
        }
        compare_attributes(
            $merged_attributes,
            ['from attr 1'],
            $attribute_type_normal_1->code
        );
        compare_attributes(
            $merged_attributes,
            ['to attr 2'],
            $attribute_type_normal_2->code
        );
        compare_attributes(
            $merged_attributes,
            [ 'from attr repeatable', 'to attr repeatable' ],
            $attribute_type_repeatable->code
        );

        # Cleanup
        $keep_patron->delete;
        $merge_patron->delete;

        # Recreate but don't expect an exception if 2 non-repeatable attributes exist, pick the one from the patron we keep
        $keep_patron =
          $builder->build_object( { class => 'Koha::Patrons' } );
        $merge_patron =
          $builder->build_object( { class => 'Koha::Patrons' } );

        $keep_patron->extended_attributes($attr_keep);
        $merge_patron->extended_attributes(
            [
                @$attr_merge,
                {
                    code      => $attribute_type_normal_1->code,
                    attribute => 'yet another attribute for non-repeatable'
                }
            ]
        );

        $keep_patron->merge_with( [ $merge_patron->borrowernumber ] );
        $merged_attributes = $keep_patron->extended_attributes;
        is( $merged_attributes->count, 4 );
        compare_attributes(
            $merged_attributes,
            ['from attr 1'],
            $attribute_type_normal_1->code
        );
        compare_attributes(
            $merged_attributes,
            ['to attr 2'],
            $attribute_type_normal_2->code
        );
        compare_attributes(
            $merged_attributes,
            [ 'from attr repeatable', 'to attr repeatable' ],
            $attribute_type_repeatable->code
        );

    };

    t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );
    $schema->storage->txn_rollback;
};

subtest '->store' => sub {
    plan tests => 8;
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $print_error = $schema->storage->dbh->{PrintError};
    $schema->storage->dbh->{PrintError} = 0; ; # FIXME This does not longer work - because of the transaction in Koha::Patron->store?

    my $patron_1 = $builder->build_object({class=> 'Koha::Patrons'});
    my $patron_2 = $builder->build_object({class=> 'Koha::Patrons'});

    {
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok { $patron_2->userid( $patron_1->userid )->store; }
        'Koha::Exceptions::Object::DuplicateID',
          'Koha::Patron->store raises an exception on duplicate ID';
        close STDERR;
    }

    # Test password
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    my $password = 'password';
    $patron_1->set_password({ password => $password });
    like( $patron_1->password, qr|^\$2|, 'Password should be hashed using bcrypt (start with $2)' );
    my $digest = $patron_1->password;
    $patron_1->surname('xxx')->store;
    is( $patron_1->password, $digest, 'Password should not have changed on ->store');

    # Test uppercasesurnames
    t::lib::Mocks::mock_preference( 'uppercasesurnames', 1 );
    my $surname = lc $patron_1->surname;
    $patron_1->surname($surname)->store;
    isnt( $patron_1->surname, $surname,
        'Surname converts to uppercase on store.');
    t::lib::Mocks::mock_preference( 'uppercasesurnames', 0 );
    $patron_1->surname($surname)->store;
    is( $patron_1->surname, $surname,
        'Surname remains unchanged on store.');

    # Test relationship
    $patron_1->relationship("")->store;
    is( $patron_1->relationship, undef, );

    $schema->storage->dbh->{PrintError} = $print_error;
    $schema->storage->txn_rollback;

    subtest 'skip updated_on for BorrowersLog' => sub {
        plan tests => 1;
        $schema->storage->txn_begin;
        t::lib::Mocks::mock_preference('BorrowersLog', 1);
        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        $patron->updated_on(dt_from_string($patron->updated_on)->add( seconds => 1 ))->store;
        my $logs = Koha::ActionLogs->search({ module =>'MEMBERS', action => 'MODIFY', object => $patron->borrowernumber });
        is($logs->count, 0, '->store should not have generated a log for updated_on') or diag 'Log generated:'.Dumper($logs->unblessed);
        $schema->storage->txn_rollback;
    };

    subtest 'create user usage' => sub {
        plan tests => 1;
        $schema->storage->txn_begin;

        my $library = $builder->build_object( { class => 'Koha::Libraries' } );
        my $patron_category = $builder->build_object(
            {
                class => 'Koha::Patron::Categories',
                value => { category_type => 'P', enrolmentfee => 0 }
            }
        );
        my %data = (
            cardnumber   => "123456789",
            firstname    => "Tômàsító",
            surname      => "Ñoné",
            password     => 'Funk3y',
            categorycode => $patron_category->categorycode,
            branchcode   => $library->branchcode,
        );

        # Enable notifying patrons of password changes for these tests
        t::lib::Mocks::mock_preference( 'NotifyPasswordChange', 1 );
        my $new_patron     = Koha::Patron->new( \%data )->store();
        my $queued_notices = Koha::Notice::Messages->search(
            { borrowernumber => $new_patron->borrowernumber }
        );
        is(
            $queued_notices->count, 0,
            "No notice queued when NotifyPasswordChange enabled and this is a new patron"
        );

        $schema->storage->txn_rollback;
    };
};

subtest '->set_password' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { login_attempts => 3 } } );

    # Disable logging password changes for these tests
    t::lib::Mocks::mock_preference( 'BorrowersLog', 0 );

    # Disable notifying patrons of password changes for these tests
    t::lib::Mocks::mock_preference( 'NotifyPasswordChange', 0 );

    # Password-length tests
    t::lib::Mocks::mock_preference( 'minPasswordLength', undef );
    throws_ok { $patron->set_password({ password => 'ab' }); }
        'Koha::Exceptions::Password::TooShort',
        'minPasswordLength is undef, fall back to 3, fail test';
    is( "$@",
        'Password length (2) is shorter than required (3)',
        'Exception parameters passed correctly'
    );

    t::lib::Mocks::mock_preference( 'minPasswordLength', 2 );
    throws_ok { $patron->set_password({ password => 'ab' }); }
        'Koha::Exceptions::Password::TooShort',
        'minPasswordLength is 2, fall back to 3, fail test';

    t::lib::Mocks::mock_preference( 'minPasswordLength', 5 );
    throws_ok { $patron->set_password({ password => 'abcb' }); }
        'Koha::Exceptions::Password::TooShort',
        'minPasswordLength is 5, fail test';

    # Trailing spaces tests
    throws_ok { $patron->set_password({ password => 'abcD12d   ' }); }
        'Koha::Exceptions::Password::WhitespaceCharacters',
        'Password contains trailing spaces, exception is thrown';

    # Require strong password tests
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 1 );
    throws_ok { $patron->set_password({ password => 'abcd   a' }); }
        'Koha::Exceptions::Password::TooWeak',
        'Password is too weak, exception is thrown';

    # Refresh patron from DB, just to make sure
    $patron->discard_changes;
    is( $patron->login_attempts, 3, 'Previous tests kept login attemps count' );

    $patron->set_password({ password => 'abcD12 34' });
    $patron->discard_changes;

    is( $patron->login_attempts, 0, 'Changing the password resets the login attempts count' );

    lives_ok { $patron->set_password({ password => 'abcd   a', skip_validation => 1 }) }
        'Password is weak, but skip_validation was passed, so no exception thrown';

    # Completeness
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );
    $patron->login_attempts(3)->store;
    my $old_digest = $patron->password;
    $patron->set_password({ password => 'abcd   a' });
    $patron->discard_changes;

    isnt( $patron->password, $old_digest, 'Password has been updated' );
    ok( checkpw_hash('abcd   a', $patron->password), 'Password hash is correct' );
    is( $patron->login_attempts, 0, 'Login attemps have been reset' );

    my $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'CHANGE PASS', object => $patron->borrowernumber } )->count;
    is( $number_of_logs, 0, 'Without BorrowerLogs, Koha::Patron->set_password doesn\'t log password changes' );

    # Enable logging password changes
    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
    $patron->set_password({ password => 'abcd   b' });

    $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'CHANGE PASS', object => $patron->borrowernumber } )->count;
    is( $number_of_logs, 1, 'With BorrowerLogs, Koha::Patron->set_password does log password changes' );

    # Enable notifying patrons of password changes
    t::lib::Mocks::mock_preference( 'NotifyPasswordChange', 1 );
    $patron->set_password({ password => 'abcd   c' });
    my $queued_notices = Koha::Notice::Messages->search({ borrowernumber => $patron->borrowernumber });
    is( $queued_notices->count, 1, "One notice queued when NotifyPasswordChange enabled" );
    my $THE_notice = $queued_notices->next;
    is( $THE_notice->status, 'failed', "The notice was handled immediately and failed on wrong email address."); #FIXME Mock sending mail
    $schema->storage->txn_rollback;
};

$schema->storage->txn_begin;
subtest 'filter_by_expiration_date' => sub {
    plan tests => 3;
    my $count1 = Koha::Patrons->filter_by_expiration_date({ days => 28 })->count;
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    $patron1->dateexpiry( dt_from_string->subtract(days => 27) )->store;
    is( Koha::Patrons->filter_by_expiration_date({ days => 28 })->count, $count1, 'No more expired' );
    $patron1->dateexpiry( dt_from_string->subtract(days => 28) )->store;
    is( Koha::Patrons->filter_by_expiration_date({ days => 28 })->count, $count1 + 1, 'One more expired' );
    $patron1->dateexpiry( dt_from_string->subtract(days => 29) )->store;
    is( Koha::Patrons->filter_by_expiration_date({ days => 28 })->count, $count1 + 1, 'Same number again' );
};

subtest 'search_unsubscribed' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 3 );
    t::lib::Mocks::mock_preference( 'UnsubscribeReflectionDelay', '' );
    is( Koha::Patrons->search_unsubscribed->count, 0, 'Empty delay should return empty set' );

    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons' });

    t::lib::Mocks::mock_preference( 'UnsubscribeReflectionDelay', 0 );
    Koha::Patron::Consents->delete; # for correct counts
    Koha::Patron::Consent->new({ borrowernumber => $patron1->borrowernumber, type => 'GDPR_PROCESSING',  refused_on => dt_from_string })->store;
    is( Koha::Patrons->search_unsubscribed->count, 1, 'Find patron1' );

    # Add another refusal but shift the period
    t::lib::Mocks::mock_preference( 'UnsubscribeReflectionDelay', 2 );
    Koha::Patron::Consent->new({ borrowernumber => $patron2->borrowernumber, type => 'GDPR_PROCESSING',  refused_on => dt_from_string->subtract(days=>2) })->store;
    is( Koha::Patrons->search_unsubscribed->count, 1, 'Find patron2 only' );

    # Try another (special) attempts setting
    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 0 );
    # Lockout is now disabled
    # Patron2 still matches: refused earlier, not locked
    is( Koha::Patrons->search_unsubscribed->count, 1, 'Lockout disabled' );
};

subtest 'search_anonymize_candidates' => sub {
    plan tests => 7;
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons' });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons' });
    $patron1->anonymized(0);
    $patron1->dateexpiry( dt_from_string->add(days => 1) )->store;
    $patron2->anonymized(0);
    $patron2->dateexpiry( dt_from_string->add(days => 1) )->store;

    t::lib::Mocks::mock_preference( 'PatronAnonymizeDelay', q{} );
    is( Koha::Patrons->search_anonymize_candidates->count, 0, 'Empty set' );

    t::lib::Mocks::mock_preference( 'PatronAnonymizeDelay', 0 );
    my $cnt = Koha::Patrons->search_anonymize_candidates->count;
    $patron1->dateexpiry( dt_from_string->subtract(days => 1) )->store;
    $patron2->dateexpiry( dt_from_string->subtract(days => 3) )->store;
    is( Koha::Patrons->search_anonymize_candidates->count, $cnt+2, 'Delay 0' );

    t::lib::Mocks::mock_preference( 'PatronAnonymizeDelay', 2 );
    $patron1->dateexpiry( dt_from_string->add(days => 1) )->store;
    $patron2->dateexpiry( dt_from_string->add(days => 1) )->store;
    $cnt = Koha::Patrons->search_anonymize_candidates->count;
    $patron1->dateexpiry( dt_from_string->subtract(days => 1) )->store;
    $patron2->dateexpiry( dt_from_string->subtract(days => 3) )->store;
    is( Koha::Patrons->search_anonymize_candidates->count, $cnt+1, 'Delay 2' );

    t::lib::Mocks::mock_preference( 'PatronAnonymizeDelay', 4 );
    $patron1->dateexpiry( dt_from_string->add(days => 1) )->store;
    $patron2->dateexpiry( dt_from_string->add(days => 1) )->store;
    $cnt = Koha::Patrons->search_anonymize_candidates->count;
    $patron1->dateexpiry( dt_from_string->subtract(days => 1) )->store;
    $patron2->dateexpiry( dt_from_string->subtract(days => 3) )->store;
    is( Koha::Patrons->search_anonymize_candidates->count, $cnt, 'Delay 4' );

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 3 );
    $patron1->dateexpiry( dt_from_string->subtract(days => 5) )->store;
    $patron1->login_attempts(0)->store;
    $patron2->dateexpiry( dt_from_string->subtract(days => 5) )->store;
    $patron2->login_attempts(0)->store;
    $cnt = Koha::Patrons->search_anonymize_candidates({locked => 1})->count;
    $patron1->login_attempts(3)->store;
    is( Koha::Patrons->search_anonymize_candidates({locked => 1})->count,
        $cnt+1, 'Locked flag' );

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', q{} );
    # Patron 1 still on 3 == locked
    is( Koha::Patrons->search_anonymize_candidates({locked => 1})->count,
        $cnt+1, 'Still expect same number for FailedLoginAttempts empty' );
    $patron1->login_attempts(0)->store;
    # Patron 1 unlocked
    is( Koha::Patrons->search_anonymize_candidates({locked => 1})->count,
        $cnt, 'Patron 1 unlocked' );
};

subtest 'search_anonymized' => sub {
    plan tests => 3;
    my $patron1 = $builder->build_object( { class => 'Koha::Patrons' } );

    t::lib::Mocks::mock_preference( 'PatronRemovalDelay', q{} );
    is( Koha::Patrons->search_anonymized->count, 0, 'Empty set' );

    t::lib::Mocks::mock_preference( 'PatronRemovalDelay', 1 );
    $patron1->dateexpiry( dt_from_string );
    $patron1->anonymized(0)->store;
    my $cnt = Koha::Patrons->search_anonymized->count;
    $patron1->anonymized(1)->store;
    is( Koha::Patrons->search_anonymized->count, $cnt, 'Number unchanged' );
    $patron1->dateexpiry( dt_from_string->subtract(days => 1) )->store;
    is( Koha::Patrons->search_anonymized->count, $cnt+1, 'Found patron1' );
};

subtest 'lock' => sub {
    plan tests => 8;

    my $patron1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron2 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $hold = $builder->build_object({
        class => 'Koha::Holds',
        value => { borrowernumber => $patron1->borrowernumber },
    });

    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', 3 );
    my $expiry = dt_from_string->add(days => 1);
    $patron1->dateexpiry( $expiry );
    $patron1->lock;
    is( $patron1->login_attempts, Koha::Patron::ADMINISTRATIVE_LOCKOUT, 'Check login_attempts' );
    is( $patron1->dateexpiry, $expiry, 'Not expired yet' );
    is( $patron1->holds->count, 1, 'No holds removed' );

    $patron1->lock({ expire => 1, remove => 1});
    isnt( $patron1->dateexpiry, $expiry, 'Expiry date adjusted' );
    is( $patron1->holds->count, 0, 'Holds removed' );

    # Disable lockout feature
    t::lib::Mocks::mock_preference( 'FailedLoginAttempts', q{} );
    $patron1->login_attempts(0);
    $patron1->dateexpiry( $expiry );
    $patron1->store;
    $patron1->lock;
    is( $patron1->login_attempts, Koha::Patron::ADMINISTRATIVE_LOCKOUT, 'Check login_attempts' );

    # Trivial wrapper test (Koha::Patrons->lock)
    $patron1->login_attempts(0)->store;
    Koha::Patrons->search({ borrowernumber => [ $patron1->borrowernumber, $patron2->borrowernumber ] })->lock;
    $patron1->discard_changes; # refresh
    $patron2->discard_changes;
    is( $patron1->login_attempts, Koha::Patron::ADMINISTRATIVE_LOCKOUT, 'Check login_attempts patron 1' );
    is( $patron2->login_attempts, Koha::Patron::ADMINISTRATIVE_LOCKOUT, 'Check login_attempts patron 2' );
};

subtest 'anonymize' => sub {
    plan tests => 10;

    my $patron1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron2 = $builder->build_object( { class => 'Koha::Patrons' } );

    # First try patron with issues
    my $issue = $builder->build_object({ class => 'Koha::Checkouts', value => { borrowernumber => $patron2->borrowernumber } });
    warning_like { $patron2->anonymize } qr/still has issues/, 'Skip patron with issues';
    $issue->delete;

    t::lib::Mocks::mock_preference( 'BorrowerMandatoryField', 'surname|email|cardnumber' );
    my $surname = $patron1->surname; # expect change, no clear
    my $branchcode = $patron1->branchcode; # expect skip
    $patron1->anonymize;
    is($patron1->anonymized, 1, 'Check flag' );

    is( $patron1->dateofbirth, undef, 'Birth date cleared' );
    is( $patron1->firstname, undef, 'First name cleared' );
    isnt( $patron1->surname, $surname, 'Surname changed' );
    ok( $patron1->surname =~ /^\w{10}$/, 'Mandatory surname randomized' );
    is( $patron1->branchcode, $branchcode, 'Branch code skipped' );
    is( $patron1->email, undef, 'Email was mandatory, must be cleared' );

    # Test wrapper in Koha::Patrons
    $patron1->surname($surname)->store; # restore
    my $rs = Koha::Patrons->search({ borrowernumber => [ $patron1->borrowernumber, $patron2->borrowernumber ] })->anonymize;
    $patron1->discard_changes; # refresh
    isnt( $patron1->surname, $surname, 'Surname patron1 changed again' );
    $patron2->discard_changes; # refresh
    is( $patron2->firstname, undef, 'First name patron2 cleared' );
};

subtest 'queue_notice' => sub {
    plan tests => 11;

    my $dbh = C4::Context->dbh;
    t::lib::Mocks::mock_preference( 'AutoEmailPrimaryAddress', 'email' );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $branch = $builder->build_object( { class => 'Koha::Libraries' } );
    my $letter_e = $builder->build_object( {
        class => 'Koha::Notice::Templates',
        value => {
            branchcode => $branch->branchcode,
            message_transport_type => 'email',
            lang => 'default'
        }
    });
    my $letter_p = $builder->build_object( {
        class => 'Koha::Notice::Templates',
        value => {
            code => $letter_e->code,
            module => $letter_e->module,
            branchcode => $branch->branchcode,
            message_transport_type => 'print',
            lang => 'default'
        }
    });
    my $letter_s = $builder->build_object( {
        class => 'Koha::Notice::Templates',
        value => {
            code => $letter_e->code,
            module => $letter_e->module,
            branchcode => $branch->branchcode,
            message_transport_type => 'sms',
            lang => 'default'
        }
    });

    my $letter_params = {
        letter_code => $letter_e->code,
        branchcode  => $letter_e->branchcode,
        module      => $letter_e->module,
        borrowernumber => $patron->borrowernumber,
        tables => {
            borrowers => $patron->borrowernumber,
        }
    };
    my @mtts = ('email');

    is( $patron->queue_notice(), undef, "Nothing is done if no params passed");
    is( $patron->queue_notice({ letter_params => $letter_params }),undef, "Nothing done if only letter");
    is_deeply(
        $patron->queue_notice({ letter_params => $letter_params, message_transports => \@mtts }),
        {sent => ['email'] }, "Email sent"
    );
    $patron->email("")->store;
    is_deeply(
        $patron->queue_notice({ letter_params => $letter_params, message_transports => \@mtts }),
        {sent => ['print'],fallback => ['email']}, "Email fallsback to print if no email"
    );
    push @mtts, 'sms';
    is_deeply(
        $patron->queue_notice({ letter_params => $letter_params, message_transports => \@mtts }),
        {sent => ['print','sms'],fallback => ['email']}, "Email fallsback to print if no email, sms sent"
    );
    $patron->smsalertnumber("")->store;
    my $counter = Koha::Notice::Messages->search({borrowernumber => $patron->borrowernumber })->count;
    is_deeply(
        $patron->queue_notice({ letter_params => $letter_params, message_transports => \@mtts }),
        {sent => ['print'],fallback => ['email','sms']}, "Email fallsback to print if no emai, sms fallsback to print if no sms, only one print sent"
    );
    is( Koha::Notice::Messages->search({borrowernumber => $patron->borrowernumber })->count, $counter+1,"Count of queued notices went up by one");

    # Enable notification for Hold_Filled - Things are hardcoded here but should work with default data
    $dbh->do(q|INSERT INTO borrower_message_preferences( borrowernumber, message_attribute_id ) VALUES ( ?, ?)|, undef, $patron->borrowernumber, 4 );
    my $borrower_message_preference_id = $dbh->last_insert_id(undef, undef, "borrower_message_preferences", undef);
    $dbh->do(q|INSERT INTO borrower_message_transport_preferences( borrower_message_preference_id, message_transport_type) VALUES ( ?, ? )|, undef, $borrower_message_preference_id, 'email' );

    is( $patron->queue_notice({ letter_params => $letter_params, message_transports => \@mtts, message_name => 'Hold_Filled' }),undef, "Nothing done if transports and name sent");

    $patron->email(q|awesome@ismymiddle.name|)->store;
    is_deeply(
        $patron->queue_notice({ letter_params => $letter_params, message_name => 'Hold_Filled' }),
        {sent => ['email'] }, "Email sent when using borrower preferences"
    );
    $counter = Koha::Notice::Messages->search({borrowernumber => $patron->borrowernumber })->count;
    is_deeply(
        $patron->queue_notice({ letter_params => $letter_params, message_name => 'Hold_Filled', test_mode => 1 }),
        {sent => ['email'] }, "Report that email sent when using borrower preferences in test_mode"
    );
    is( Koha::Notice::Messages->search({borrowernumber => $patron->borrowernumber })->count, $counter,"Count of queued notices not increased in test mode");
};

subtest 'filter_by_amount_owed' => sub {
    plan tests => 6;

    my $library = $builder->build({source => 'Branch' });
    my $category = $builder->build({source => 'Category' });

    my $new_patron_cf_1 = Koha::Patron->new(
        {
            cardnumber   => 'test_cn_cf_1',
            branchcode   => $library->{branchcode},
            categorycode => $category->{categorycode},
            surname      => 'surname for patron1',
            firstname    => 'firstname for patron1',
            userid       => 'a_nonexistent_userid_cf_1',
        }
    )->store;
    my $new_patron_cf_2 = Koha::Patron->new(
        {
            cardnumber   => 'test_cn_cf_2',
            branchcode   => $library->{branchcode},
            categorycode => $category->{categorycode},
            surname      => 'surname for patron2',
            firstname    => 'firstname for patron2',
            userid       => 'a_nonexistent_userid_cf_2',
        }
    )->store;
    my $new_patron_cf_3 = Koha::Patron->new(
        {
            cardnumber   => 'test_cn_cf_3',
            branchcode   => $library->{branchcode},
            categorycode => $category->{categorycode},
            surname      => 'surname for patron3',
            firstname    => 'firstname for patron3',
            userid       => 'a_nonexistent_userid_cf_3',
        }
    )->store;

    my $results = Koha::Patrons->search(
        {
            'me.borrowernumber' => [
                $new_patron_cf_1->borrowernumber,
                $new_patron_cf_2->borrowernumber,
                $new_patron_cf_3->borrowernumber
            ]
        }
    );

    my $fine1 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $new_patron_cf_1->borrowernumber,
                amountoutstanding => 12.00,
                amount            => 12.00,
                debit_type_code   => 'OVERDUE',
                branchcode        => $library->{branchcode}
            },
        }
    );
    my $fine2 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $new_patron_cf_2->borrowernumber,
                amountoutstanding => 8.00,
                amount            => 8.00,
                debit_type_code   => 'OVERDUE',
                branchcode        => $library->{branchcode}

            },
        }
    );
    my $fine3 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $new_patron_cf_2->borrowernumber,
                amountoutstanding => 10.00,
                amount            => 10.00,
                debit_type_code   => 'OVERDUE',
                branchcode        => $library->{branchcode}
            },
        }
    );

    my $filtered = $results->filter_by_amount_owed();
    is( ref($filtered), 'Koha::Patrons',
'Koha::Patrons->filter_by_amount_owed should return a Koha::Patrons result set in a scalar context'
    );

    my $lower_limit = 12.00;
    my $upper_limit = 16.00;

    # Catch user with 1 x 12.00 fine and user with no fines.
    $filtered =
      $results->filter_by_amount_owed( { less_than => $upper_limit } );
    is( $filtered->_resultset->as_subselect_rs->count, 2,
"filter_by_amount_owed({ less_than => $upper_limit }) found two patrons"
    );

    # Catch user with 1 x 8.00 and 1 x 10.00 fine
    $filtered =
      $results->filter_by_amount_owed( { more_than => $lower_limit } );
    is( $filtered->_resultset->as_subselect_rs->count, 1,
"filter_by_amount_owed({ more_than => $lower_limit }) found two patrons"
    );

    # User with 2 fines falls above upper limit - Excluded,
    # user with 1 fine falls below lower limit - Excluded
    # and user with no fines falls below lower limit - Excluded.
    $filtered = $results->filter_by_amount_owed(
        { more_than => $lower_limit, less_than => $upper_limit } );
    is( $filtered->_resultset->as_subselect_rs->count, 0,
"filter_by_amount_owed({ more_than => $lower_limit, less_than => $upper_limit }) found zero patrons"
    );

    my $library2 = $builder->build({source => 'Branch' });
    my $fine4 = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $new_patron_cf_2->borrowernumber,
                amountoutstanding => 10.00,
                amount            => 10.00,
                debit_type_code   => 'HOLD',
                branchcode        => $library2->{branchcode}
            },
        }
    );

    # Catch only the user with a HOLD fee over 6.00
    $filtered = $results->filter_by_amount_owed( { more_than => 6.00, debit_type => 'HOLD' } );
    is( $filtered->_resultset->as_subselect_rs->count, 1,
"filter_by_amount_owed({ more_than => 6.00, debit_type => 'HOLD' }) found one patron"
    );

    # Catch only the user with a fee over 6.00 at the specified library
    $filtered = $results->filter_by_amount_owed( { more_than => 6.00, library => $library2->{branchcode} } );
    is( $filtered->_resultset->as_subselect_rs->count, 1,
"filter_by_amount_owed({ more_than => 6.00, library => $library2->{branchcode} }) found one patron"
    );

};

subtest 'filter_by_have_permission' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron_1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1, branchcode => $library->branchcode }
        }
    );

    my $patron_2 = $builder->build_object( # 4096 = 1 << 12 for suggestions
        {
            class => 'Koha::Patrons',
            value => { flags => 4096, branchcode => $library->branchcode }
        }
    );

    my $patron_3 = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0, branchcode => $library->branchcode }
        }
    );
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron_3->borrowernumber,
                module_bit     => 11,
                code           => 'order_manage',
            },
        }
    );

    is_deeply(
        [
            Koha::Patrons->search( { branchcode => $library->branchcode } )
              ->filter_by_have_permission('suggestions.suggestions_manage')
              ->get_column('borrowernumber')
        ],
        [ $patron_1->borrowernumber, $patron_2->borrowernumber ],
        'Superlibrarian and patron with suggestions.suggestions_manage'
    );

    is_deeply(
        [
            Koha::Patrons->search( { branchcode => $library->branchcode } )
              ->filter_by_have_permission('acquisition.order_manage')
              ->get_column('borrowernumber')
        ],
        [ $patron_1->borrowernumber, $patron_3->borrowernumber ],
        'Superlibrarian and patron with acquisition.order_manage'
    );

    is_deeply(
        [
            Koha::Patrons->search( { branchcode => $library->branchcode } )
              ->filter_by_have_permission('parameters.manage_cities')
              ->get_column('borrowernumber')
        ],
        [ $patron_1->borrowernumber ],
        'Only Superlibrarian is returned'
    );

    is_deeply(
        [
            Koha::Patrons->search( { branchcode => $library->branchcode } )
              ->filter_by_have_permission('suggestions')
              ->get_column('borrowernumber')
        ],
        [ $patron_1->borrowernumber, $patron_2->borrowernumber ],
        'Superlibrarian and patron with suggestions'
    );

    throws_ok {
        Koha::Patrons->search( { branchcode => $library->branchcode } )
          ->filter_by_have_permission('dont_exist.subperm');
    } 'Koha::Exceptions::ObjectNotFound';


    $schema->storage->txn_rollback;
};

$schema->storage->txn_rollback;
