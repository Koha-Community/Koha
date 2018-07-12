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

use Test::More tests => 32;
use Test::Warn;
use Test::Exception;
use Time::Fake;
use DateTime;
use JSON;

use C4::Biblio;
use C4::Circulation;

use C4::Circulation;

use Koha::Holds;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Database;
use Koha::DateUtils;
use Koha::Virtualshelves;

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

C4::Context->_new_userenv('xxx');
set_logged_in_user( $new_patron_1 );

is( Koha::Patrons->search->count, $nb_of_patrons + 2, 'The 2 patrons should have been added' );

my $retrieved_patron_1 = Koha::Patrons->find( $new_patron_1->borrowernumber );
is( $retrieved_patron_1->cardnumber, $new_patron_1->cardnumber, 'Find a patron by borrowernumber should return the correct patron' );

subtest 'library' => sub {
    plan tests => 2;
    is( $retrieved_patron_1->library->branchcode, $library->{branchcode}, 'Koha::Patron->library should return the correct library' );
    is( ref($retrieved_patron_1->library), 'Koha::Library', 'Koha::Patron->library should return a Koha::Library object' );
};

subtest 'guarantees' => sub {
    plan tests => 8;
    my $guarantees = $new_patron_1->guarantees;
    is( ref($guarantees), 'Koha::Patrons', 'Koha::Patron->guarantees should return a Koha::Patrons result set in a scalar context' );
    is( $guarantees->count, 0, 'new_patron_1 should have 0 guarantee' );
    my @guarantees = $new_patron_1->guarantees;
    is( ref(\@guarantees), 'ARRAY', 'Koha::Patron->guarantees should return an array in a list context' );
    is( scalar(@guarantees), 0, 'new_patron_1 should have 0 guarantee' );

    my $guarantee_1 = $builder->build({ source => 'Borrower', value => { guarantorid => $new_patron_1->borrowernumber }});
    my $guarantee_2 = $builder->build({ source => 'Borrower', value => { guarantorid => $new_patron_1->borrowernumber }});

    $guarantees = $new_patron_1->guarantees;
    is( ref($guarantees), 'Koha::Patrons', 'Koha::Patron->guarantees should return a Koha::Patrons result set in a scalar context' );
    is( $guarantees->count, 2, 'new_patron_1 should have 2 guarantees' );
    @guarantees = $new_patron_1->guarantees;
    is( ref(\@guarantees), 'ARRAY', 'Koha::Patron->guarantees should return an array in a list context' );
    is( scalar(@guarantees), 2, 'new_patron_1 should have 2 guarantees' );
    $_->delete for @guarantees;
};

subtest 'category' => sub {
    plan tests => 2;
    my $patron_category = $new_patron_1->category;
    is( ref( $patron_category), 'Koha::Patron::Category', );
    is( $patron_category->categorycode, $category->{categorycode}, );
};

subtest 'siblings' => sub {
    plan tests => 7;
    my $siblings = $new_patron_1->siblings;
    is( $siblings, undef, 'Koha::Patron->siblings should not crashed if the patron has no guarantor' );
    my $guarantee_1 = $builder->build( { source => 'Borrower', value => { guarantorid => $new_patron_1->borrowernumber } } );
    my $retrieved_guarantee_1 = Koha::Patrons->find($guarantee_1);
    $siblings = $retrieved_guarantee_1->siblings;
    is( ref($siblings), 'Koha::Patrons', 'Koha::Patron->siblings should return a Koha::Patrons result set in a scalar context' );
    my @siblings = $retrieved_guarantee_1->siblings;
    is( ref( \@siblings ), 'ARRAY', 'Koha::Patron->siblings should return an array in a list context' );
    is( $siblings->count,  0,       'guarantee_1 should not have siblings yet' );
    my $guarantee_2 = $builder->build( { source => 'Borrower', value => { guarantorid => $new_patron_1->borrowernumber } } );
    my $guarantee_3 = $builder->build( { source => 'Borrower', value => { guarantorid => $new_patron_1->borrowernumber } } );
    $siblings = $retrieved_guarantee_1->siblings;
    is( $siblings->count,               2,                               'guarantee_1 should have 2 siblings' );
    is( $guarantee_2->{borrowernumber}, $siblings->next->borrowernumber, 'guarantee_2 should exist in the guarantees' );
    is( $guarantee_3->{borrowernumber}, $siblings->next->borrowernumber, 'guarantee_3 should exist in the guarantees' );
    $_->delete for $retrieved_guarantee_1->siblings;
    $retrieved_guarantee_1->delete;
};

subtest 'has_overdues' => sub {
    plan tests => 3;

    my $biblioitem_1 = $builder->build( { source => 'Biblioitem' } );
    my $item_1 = $builder->build(
        {   source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem_1->{biblionumber}
            }
        }
    );
    my $retrieved_patron = Koha::Patrons->find( $new_patron_1->borrowernumber );
    is( $retrieved_patron->has_overdues, 0, );

    my $tomorrow = DateTime->today( time_zone => C4::Context->tz() )->add( days => 1 );
    my $issue = Koha::Checkout->new({ borrowernumber => $new_patron_1->id, itemnumber => $item_1->{itemnumber}, date_due => $tomorrow, branchcode => $library->{branchcode} })->store();
    is( $retrieved_patron->has_overdues, 0, );
    $issue->delete();
    my $yesterday = DateTime->today(time_zone => C4::Context->tz())->add( days => -1 );
    $issue = Koha::Checkout->new({ borrowernumber => $new_patron_1->id, itemnumber => $item_1->{itemnumber}, date_due => $yesterday, branchcode => $library->{branchcode} })->store();
    $retrieved_patron = Koha::Patrons->find( $new_patron_1->borrowernumber );
    is( $retrieved_patron->has_overdues, 1, );
    $issue->delete();
};

subtest 'update_password' => sub {
    plan tests => 7;

    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
    my $original_userid   = $new_patron_1->userid;
    my $original_password = $new_patron_1->password;
    warning_like { $retrieved_patron_1->update_password( $new_patron_2->userid, 'another_password' ) }
    qr{Duplicate entry},
      'Koha::Patron->update_password should warn if the userid is already used by another patron';
    is( Koha::Patrons->find( $new_patron_1->borrowernumber )->userid,   $original_userid,   'Koha::Patron->update_password should not have updated the userid' );
    is( Koha::Patrons->find( $new_patron_1->borrowernumber )->password, $original_password, 'Koha::Patron->update_password should not have updated the userid' );

    $retrieved_patron_1->update_password( 'another_nonexistent_userid_1', 'another_password' );
    is( Koha::Patrons->find( $new_patron_1->borrowernumber )->userid,   'another_nonexistent_userid_1', 'Koha::Patron->update_password should have updated the userid' );
    is( Koha::Patrons->find( $new_patron_1->borrowernumber )->password, 'another_password',             'Koha::Patron->update_password should have updated the password' );

    my $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'CHANGE PASS', object => $new_patron_1->borrowernumber } )->count;
    is( $number_of_logs, 1, 'With BorrowerLogs, Koha::Patron->update_password should have logged' );

    t::lib::Mocks::mock_preference( 'BorrowersLog', 0 );
    $retrieved_patron_1->update_password( 'yet_another_nonexistent_userid_1', 'another_password' );
    $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'CHANGE PASS', object => $new_patron_1->borrowernumber } )->count;
    is( $number_of_logs, 1, 'With BorrowerLogs, Koha::Patron->update_password should not have logged' );
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
    plan tests => 8;
    my $patron = $builder->build({ source => 'Borrower' });
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    $patron->dateexpiry( undef )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is not set');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 0);
    $patron->dateexpiry( dt_from_string )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is today');

    $patron->dateexpiry( dt_from_string )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is today and pref is 0');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 10);
    $patron->dateexpiry( dt_from_string->add( days => 11 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 11 days ahead and pref is 10');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 0);
    $patron->dateexpiry( dt_from_string->add( days => 10 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 10 days ahead and pref is 0');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 10);
    $patron->dateexpiry( dt_from_string->add( days => 10 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 10 days ahead and pref is 10');
    $patron->delete;

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 10);
    $patron->dateexpiry( dt_from_string->add( days => 20 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 0, 'Patron should not be considered going to expire if dateexpiry is 20 days ahead and pref is 10');

    t::lib::Mocks::mock_preference('NotifyBorrowerDeparture', 20);
    $patron->dateexpiry( dt_from_string->add( days => 10 ) )->store->discard_changes;
    is( $patron->is_going_to_expire, 1, 'Patron should be considered going to expire if dateexpiry is 10 days ahead and pref is 20');

    $patron->delete;
};


subtest 'renew_account' => sub {
    plan tests => 36;

    for my $date ( '2016-03-31', '2016-11-30', dt_from_string() ) {
        my $dt = dt_from_string( $date, 'iso' );
        Time::Fake->offset( $dt->epoch );
        my $a_month_ago                = $dt->clone->subtract( months => 1, end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_year_later               = $dt->clone->add( months => 12, end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_year_later_minus_a_month = $dt->clone->add( months => 11, end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_month_later              = $dt->clone->add( months => 1 , end_of_month => 'limit' )->truncate( to => 'day' );
        my $a_year_later_plus_a_month  = $dt->clone->add( months => 13, end_of_month => 'limit' )->truncate( to => 'day' );
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
    plan tests => 5;
    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
    my $patron           = $builder->build( { source => 'Borrower' } );
    my $retrieved_patron = Koha::Patrons->find( $patron->{borrowernumber} );
    my $hold             = $builder->build(
        {   source => 'Reserve',
            value  => { borrowernumber => $patron->{borrowernumber} }
        }
    );
    my $list = $builder->build(
        {   source => 'Virtualshelve',
            value  => { owner => $patron->{borrowernumber} }
        }
    );

    my $deleted = $retrieved_patron->delete;
    is( $deleted, 1, 'Koha::Patron->delete should return 1 if the patron has been correctly deleted' );

    is( Koha::Patrons->find( $patron->{borrowernumber} ), undef, 'Koha::Patron->delete should have deleted the patron' );

    is( Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } )->count, 0, q|Koha::Patron->delete should have deleted patron's holds| );

    is( Koha::Virtualshelves->search( { owner => $patron->{borrowernumber} } )->count, 0, q|Koha::Patron->delete should have deleted patron's lists| );

    my $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'DELETE', object => $retrieved_patron->borrowernumber } )->count;
    is( $number_of_logs, 1, 'With BorrowerLogs, Koha::Patron->delete should have logged' );
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

subtest 'checkouts + pending_checkouts + get_overdues + old_checkouts' => sub {
    plan tests => 17;

    my $library = $builder->build( { source => 'Branch' } );
    my ($biblionumber_1) = AddBiblio( MARC::Record->new, '' );
    my $item_1 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_1,
                itemlost      => 0,
                withdrawn     => 0,
            }
        }
    );
    my $item_2 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_1,
                itemlost      => 0,
                withdrawn     => 0,
            }
        }
    );
    my ($biblionumber_2) = AddBiblio( MARC::Record->new, '' );
    my $item_3 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_2,
                itemlost      => 0,
                withdrawn     => 0,
            }
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

    my $module = new Test::MockModule('C4::Context');
    $module->mock( 'userenv', sub { { branch => $library->{branchcode} } } );

    AddIssue( $patron, $item_1->{barcode}, DateTime->now->subtract( days => 1 ) );
    AddIssue( $patron, $item_2->{barcode}, DateTime->now->subtract( days => 5 ) );
    AddIssue( $patron, $item_3->{barcode} );

    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    $checkouts = $patron->checkouts;
    is( $checkouts->count, 3, 'checkouts should return 3 issues for that patron' );
    is( ref($checkouts), 'Koha::Checkouts', 'checkouts should return a Koha::Checkouts object' );
    $pending_checkouts = $patron->pending_checkouts;
    is( $pending_checkouts->count, 3, 'pending_checkouts should return 3 issues for that patron' );
    is( ref($pending_checkouts), 'Koha::Checkouts', 'pending_checkouts should return a Koha::Checkouts object' );

    my $first_checkout = $pending_checkouts->next;
    is( $first_checkout->unblessed_all_relateds->{biblionumber}, $item_3->{biblionumber}, 'pending_checkouts should prefetch values from other tables (here biblio)' );

    my $overdues = $patron->get_overdues;
    is( $overdues->count, 2, 'Patron should have 2 overdues');
    is( ref($overdues), 'Koha::Checkouts', 'Koha::Patron->get_overdues should return Koha::Checkouts' );
    is( $overdues->next->itemnumber, $item_1->{itemnumber}, 'The issue should be returned in the same order as they have been done, first is correct' );
    is( $overdues->next->itemnumber, $item_2->{itemnumber}, 'The issue should be returned in the same order as they have been done, second is correct' );


    C4::Circulation::AddReturn( $item_1->{barcode} );
    C4::Circulation::AddReturn( $item_2->{barcode} );
    $old_checkouts = $patron->old_checkouts;
    is( $old_checkouts->count, 2, 'old_checkouts should return 2 old checkouts that patron' );
    is( ref($old_checkouts), 'Koha::Old::Checkouts', 'old_checkouts should return a Koha::Old::Checkouts object' );

    # Clean stuffs
    Koha::Checkouts->search( { borrowernumber => $patron->borrowernumber } )->delete;
    $patron->delete;
    $module->unmock('userenv');
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
    plan tests => 7;

    my $patron = $builder->build( { source => 'Borrower' } );
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );

    my $today = dt_from_string;

    $patron->dateofbirth( undef );
    is( $patron->get_age, undef, 'get_age should return undef if no dateofbirth is defined' );
    $patron->dateofbirth( $today->clone->add( years => -12, months => -6, days => -1, end_of_month => 'limit'  ) );
    is( $patron->get_age, 12, 'Patron should be 12' );
    $patron->dateofbirth( $today->clone->add( years => -18, months => 0, days => 1, end_of_month => 'limit'  ) );
    is( $patron->get_age, 17, 'Patron should be 17, happy birthday tomorrow!' );
    $patron->dateofbirth( $today->clone->add( years => -18, months => 0, days => 0, end_of_month => 'limit'  ) );
    is( $patron->get_age, 18, 'Patron should be 18' );
    $patron->dateofbirth( $today->clone->add( years => -18, months => -12, days => -31, end_of_month => 'limit'  ) );
    is( $patron->get_age, 19, 'Patron should be 19' );
    $patron->dateofbirth( $today->clone->add( years => -18, months => -12, days => -30, end_of_month => 'limit'  ) );
    is( $patron->get_age, 19, 'Patron should be 19 again' );
    $patron->dateofbirth( $today->clone->add( years => 0,   months => -1, days => -1, end_of_month => 'limit'  ) );
    is( $patron->get_age, 0, 'Patron is a newborn child' );

    $patron->delete;
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
    my ($biblionumber_1) = AddBiblio( MARC::Record->new, '' );
    my $item_1 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_1
            }
        }
    );
    my $item_2 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_1
            }
        }
    );
    my ($biblionumber_2) = AddBiblio( MARC::Record->new, '' );
    my $item_3 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_2
            }
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

    C4::Reserves::AddReserve( $library->{branchcode},
        $patron->borrowernumber, $biblionumber_1 );
    # In the future
    C4::Reserves::AddReserve( $library->{branchcode},
        $patron->borrowernumber, $biblionumber_2, undef, undef, dt_from_string->add( days => 2 ) );

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

subtest 'search_patrons_to_anonymise & anonymise_issue_history' => sub {
    plan tests => 4;

    # TODO create a subroutine in t::lib::Mocks
    my $branch = $builder->build({ source => 'Branch' });
    my $userenv_patron = $builder->build({
        source => 'Borrower',
        value  => { branchcode => $branch->{branchcode} },
    });
    C4::Context->_new_userenv('DUMMY SESSION');
    C4::Context->set_userenv(
        $userenv_patron->{borrowernumber},
        $userenv_patron->{userid},
        'usercnum', 'First name', 'Surname',
        $branch->{branchcode},
        $branch->{branchname},
        0,
    );
    my $anonymous = $builder->build( { source => 'Borrower', }, );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous->{borrowernumber} );

    subtest 'patron privacy is 1 (default)' => sub {
        plan tests => 8;

        t::lib::Mocks::mock_preference('IndependentBranches', 0);
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => { privacy => 1, }
            }
        );
        my $item_1 = $builder->build(
            {   source => 'Item',
                value  => {
                    itemlost  => 0,
                    withdrawn => 0,
                },
            }
        );
        my $issue_1 = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item_1->{itemnumber},
                },
            }
        );
        my $item_2 = $builder->build(
            {   source => 'Item',
                value  => {
                    itemlost  => 0,
                    withdrawn => 0,
                },
            }
        );
        my $issue_2 = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item_2->{itemnumber},
                },
            }
        );

        my ( $returned_1, undef, undef ) = C4::Circulation::AddReturn( $item_1->{barcode}, undef, undef, undef, '2010-10-10' );
        my ( $returned_2, undef, undef ) = C4::Circulation::AddReturn( $item_2->{barcode}, undef, undef, undef, '2011-11-11' );
        is( $returned_1 && $returned_2, 1, 'The items should have been returned' );

        my $patrons_to_anonymise = Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } )->search( { 'me.borrowernumber' => $patron->{borrowernumber} } );
        is( ref($patrons_to_anonymise), 'Koha::Patrons', 'search_patrons_to_anonymise should return Koha::Patrons' );

        my $rows_affected = Koha::Patrons->search_patrons_to_anonymise( { before => '2011-11-12' } )->anonymise_issue_history( { before => '2010-10-11' } );
        ok( $rows_affected > 0, 'AnonymiseIssueHistory should affect at least 1 row' );

        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare(q|SELECT borrowernumber FROM old_issues where itemnumber = ?|);
        $sth->execute($item_1->{itemnumber});
        my ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'With privacy=1, the issue should have been anonymised' );
        $sth->execute($item_2->{itemnumber});
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $patron->{borrowernumber}, 'The issue should not have been anonymised, the returned date is later' );

        $rows_affected = Koha::Patrons->search_patrons_to_anonymise( { before => '2011-11-12' } )->anonymise_issue_history;
        $sth->execute($item_2->{itemnumber});
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'The issue should have been anonymised, the returned date is before' );

        my $sth_reset = $dbh->prepare(q|UPDATE old_issues SET borrowernumber = ? WHERE itemnumber = ?|);
        $sth_reset->execute( $patron->{borrowernumber}, $item_1->{itemnumber} );
        $sth_reset->execute( $patron->{borrowernumber}, $item_2->{itemnumber} );
        $rows_affected = Koha::Patrons->search_patrons_to_anonymise->anonymise_issue_history;
        $sth->execute($item_1->{itemnumber});
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'The issue 1 should have been anonymised, before parameter was not passed' );
        $sth->execute($item_2->{itemnumber});
        ($borrowernumber_used_to_anonymised) = $sth->fetchrow_array;
        is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'The issue 2 should have been anonymised, before parameter was not passed' );

        Koha::Patrons->find( $patron->{borrowernumber})->delete;
    };

    subtest 'patron privacy is 0 (forever)' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference('IndependentBranches', 0);
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => { privacy => 0, }
            }
        );
        my $item = $builder->build(
            {   source => 'Item',
                value  => {
                    itemlost  => 0,
                    withdrawn => 0,
                },
            }
        );
        my $issue = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->{itemnumber},
                },
            }
        );

        my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );
        is( $returned, 1, 'The item should have been returned' );
        my $rows_affected = Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } )->anonymise_issue_history( { before => '2010-10-11' } );
        ok( $rows_affected > 0, 'AnonymiseIssueHistory should not return any error if success' );

        my $dbh = C4::Context->dbh;
        my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
            SELECT borrowernumber FROM old_issues where itemnumber = ?
        |, undef, $item->{itemnumber});
        is( $borrowernumber_used_to_anonymised, $patron->{borrowernumber}, 'With privacy=0, the issue should not be anonymised' );
        Koha::Patrons->find( $patron->{borrowernumber})->delete;
    };

    t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );

    subtest 'AnonymousPatron is not defined' => sub {
        plan tests => 3;

        t::lib::Mocks::mock_preference('IndependentBranches', 0);
        my $patron = $builder->build(
            {   source => 'Borrower',
                value  => { privacy => 1, }
            }
        );
        my $item = $builder->build(
            {   source => 'Item',
                value  => {
                    itemlost  => 0,
                    withdrawn => 0,
                },
            }
        );
        my $issue = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->{itemnumber},
                },
            }
        );

        my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );
        is( $returned, 1, 'The item should have been returned' );
        my $rows_affected = Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } )->anonymise_issue_history( { before => '2010-10-11' } );
        ok( $rows_affected > 0, 'AnonymiseIssueHistory should affect at least 1 row' );

        my $dbh = C4::Context->dbh;
        my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
            SELECT borrowernumber FROM old_issues where itemnumber = ?
        |, undef, $item->{itemnumber});
        is( $borrowernumber_used_to_anonymised, undef, 'With AnonymousPatron is not defined, the issue should have been anonymised anyway' );
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
        my $item = $builder->build(
            {   source => 'Item',
                value  => {
                    itemlost  => 0,
                    withdrawn => 0,
                },
            }
        );
        my $issue = $builder->build(
            {   source => 'Issue',
                value  => {
                    borrowernumber => $patron->{borrowernumber},
                    itemnumber     => $item->{itemnumber},
                },
            }
        );

        my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );
        is( Koha::Patrons->search_patrons_to_anonymise( { before => '2010-10-11' } )->count, 0 );
        Koha::Patrons->find( $patron->{borrowernumber})->delete;
    };

    Koha::Patrons->find( $anonymous->{borrowernumber})->delete;
    Koha::Patrons->find( $userenv_patron->{borrowernumber})->delete;

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

        set_logged_in_user( $patron_11_1 );
        @branchcodes = $patron_11_1->libraries_where_can_see_patrons;
        is_deeply( \@branchcodes, [], q|patron_11_1 has view_borrower_infos_from_any_libraries => No restriction| );

        set_logged_in_user( $patron_11_2 );
        @branchcodes = $patron_11_2->libraries_where_can_see_patrons;
        is_deeply( \@branchcodes, [ sort ( $library_11->branchcode, $library_12->branchcode ) ], q|patron_11_2 has not view_borrower_infos_from_any_libraries => Can only see patron's from its group| );

        set_logged_in_user( $patron_21 );
        @branchcodes = $patron_21->libraries_where_can_see_patrons;
        is_deeply( \@branchcodes, [$library_21->branchcode], q|patron_21 has not view_borrower_infos_from_any_libraries => Can only see patron's from its group| );
    };
    subtest 'can_see_patron_infos' => sub {
        plan tests => 6;

        set_logged_in_user( $patron_11_1 );
        is( $patron_11_1->can_see_patron_infos( $patron_11_2 ), 1, q|patron_11_1 can see patron_11_2, from its library| );
        is( $patron_11_1->can_see_patron_infos( $patron_12 ),   1, q|patron_11_1 can see patron_12, from its group| );
        is( $patron_11_1->can_see_patron_infos( $patron_21 ),   1, q|patron_11_1 can see patron_11_2, from another group| );

        set_logged_in_user( $patron_11_2 );
        is( $patron_11_2->can_see_patron_infos( $patron_11_1 ), 1, q|patron_11_2 can see patron_11_1, from its library| );
        is( $patron_11_2->can_see_patron_infos( $patron_12 ),   1, q|patron_11_2 can see patron_12, from its group| );
        is( $patron_11_2->can_see_patron_infos( $patron_21 ),   0, q|patron_11_2 can NOT see patron_21, from another group| );
    };
    subtest 'search_limited' => sub {
        plan tests => 6;

        set_logged_in_user( $patron_11_1 );
        my $total_number_of_patrons = $nb_of_patrons + 6; # 2 created before + 4 for these subtests
        is( Koha::Patrons->search->count, $total_number_of_patrons, 'Non-limited search should return all patrons');
        is( Koha::Patrons->search_limited->count, $total_number_of_patrons, 'patron_11_1 is allowed to see all patrons' );

        set_logged_in_user( $patron_11_2 );
        is( Koha::Patrons->search->count, $total_number_of_patrons, 'Non-limited search should return all patrons');
        is( Koha::Patrons->search_limited->count, 3, 'patron_12_1 is not allowed to see patrons from other groups, only patron_11_1, patron_11_2 and patron_12' );

        set_logged_in_user( $patron_21 );
        is( Koha::Patrons->search->count, $total_number_of_patrons, 'Non-limited search should return all patrons');
        is( Koha::Patrons->search_limited->count, 1, 'patron_21 is not allowed to see patrons from other groups, only himself' );
    };
    $patron_11_1->delete;
    $patron_11_2->delete;
    $patron_12->delete;
    $patron_21->delete;
};

subtest 'account_locked' => sub {
    plan tests => 8;
    my $patron = $builder->build({ source => 'Borrower', value => { login_attempts => 0 } });
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    for my $value ( undef, '', 0 ) {
        t::lib::Mocks::mock_preference('FailedloginAttempts', $value);
        is( $patron->account_locked, 0, 'Feature is disabled, patron account should not be considered locked' );
        $patron->login_attempts(1)->store;
        is( $patron->account_locked, 0, 'Feature is disabled, patron account should not be considered locked' );
    }

    t::lib::Mocks::mock_preference('FailedloginAttempts', 3);
    $patron->login_attempts(2)->store;
    is( $patron->account_locked, 0, 'Patron has 2 failed attempts, account should not be considered locked yet' );
    $patron->login_attempts(3)->store;
    is( $patron->account_locked, 1, 'Patron has 3 failed attempts, account should be considered locked yet' );

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

subtest 'get_overdues' => sub {
    plan tests => 7;

    my $library = $builder->build( { source => 'Branch' } );
    my ($biblionumber_1) = AddBiblio( MARC::Record->new, '' );
    my $item_1 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_1
            }
        }
    );
    my $item_2 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_1
            }
        }
    );
    my ($biblionumber_2) = AddBiblio( MARC::Record->new, '' );
    my $item_3 = $builder->build(
        {
            source => 'Item',
            value  => {
                homebranch    => $library->{branchcode},
                holdingbranch => $library->{branchcode},
                biblionumber  => $biblionumber_2
            }
        }
    );
    my $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $library->{branchcode} }
        }
    );

    my $module = new Test::MockModule('C4::Context');
    $module->mock( 'userenv', sub { { branch => $library->{branchcode} } } );

    AddIssue( $patron, $item_1->{barcode}, DateTime->now->subtract( days => 1 ) );
    AddIssue( $patron, $item_2->{barcode}, DateTime->now->subtract( days => 5 ) );
    AddIssue( $patron, $item_3->{barcode} );

    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    my $overdues = $patron->get_overdues;
    is( $overdues->count, 2, 'Patron should have 2 overdues');
    is( $overdues->next->itemnumber, $item_1->{itemnumber}, 'The issue should be returned in the same order as they have been done, first is correct' );
    is( $overdues->next->itemnumber, $item_2->{itemnumber}, 'The issue should be returned in the same order as they have been done, second is correct' );

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
    plan tests => 8;

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
        firstname    => "Tomasito",
        surname      => "None",
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


$retrieved_patron_1->delete;
is( Koha::Patrons->search->count, $nb_of_patrons + 1, 'Delete should have deleted the patron' );

subtest 'Log cardnumber change' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $cardnumber = $patron->cardnumber;
    $patron->set( { cardnumber => 'TESTCARDNUMBER' });
    $patron->store;

    my @logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'MODIFY', object => $patron->borrowernumber } );
    my $log_info = from_json( $logs[0]->info );
    is( $log_info->{cardnumber_replaced}->{new_cardnumber}, 'TESTCARDNUMBER', 'Got correct new cardnumber' );
    is( $log_info->{cardnumber_replaced}->{previous_cardnumber}, $cardnumber, 'Got correct old cardnumber' );
    is( scalar @logs, 2, 'With BorrowerLogs, Change in cardnumber should be logged, as well as general alert of patron mod.' );
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

    $schema->storage->txn_rollback;
};

subtest '->store' => sub {
    plan tests => 1;
    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $print_error = $schema->storage->dbh->{PrintError};
    $schema->storage->dbh->{PrintError} = 0; ; # FIXME This does not longer work - because of the transaction in Koha::Patron->store?

    my $patron_1 = $builder->build_object({class=> 'Koha::Patrons'});
    my $patron_2 = $builder->build_object({class=> 'Koha::Patrons'});

    throws_ok
        { $patron_2->userid($patron_1->userid)->store; }
        'Koha::Exceptions::Object::DuplicateID',
        'Koha::Patron->store raises an exception on duplicate ID';

    $schema->storage->dbh->{PrintError} = $print_error;
    $schema->storage->txn_rollback;
};


# TODO Move to t::lib::Mocks and reuse it!
sub set_logged_in_user {
    my ($patron) = @_;
    C4::Context->set_userenv(
        $patron->borrowernumber, $patron->userid,
        $patron->cardnumber,     'firstname',
        'surname',               $patron->library->branchcode,
        'Midway Public Library', $patron->flags,
        '',                      ''
    );
}
