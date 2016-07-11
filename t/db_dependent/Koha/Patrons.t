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

use Test::More tests => 7;
use Test::Warn;

use Koha::Patron;
use Koha::Patrons;
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

is( Koha::Patrons->search->count, $nb_of_patrons + 2, 'The 2 patrons should have been added' );

my $retrieved_patron_1 = Koha::Patrons->find( $new_patron_1->borrowernumber );
is( $retrieved_patron_1->cardnumber, $new_patron_1->cardnumber, 'Find a patron by borrowernumber should return the correct patron' );

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

subtest 'extend_subscription' => sub {
    plan tests => 6;
    my $a_month_ago                = dt_from_string->add( months => -1 )->truncate( to => 'day' );
    my $a_year_later               = dt_from_string->add( months => 12 )->truncate( to => 'day' );
    my $a_year_later_minus_a_month = dt_from_string->add( months => 11 )->truncate( to => 'day' );
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
            }
        }
    );
    my $retrieved_patron = Koha::Patrons->find( $patron->{borrowernumber} );

    t::lib::Mocks::mock_preference( 'BorrowerRenewalPeriodBase', 'dateexpiry' );
    t::lib::Mocks::mock_preference( 'BorrowersLog',              1 );
    my $expiry_date = $retrieved_patron->extend_subscription;
    is( $expiry_date, $a_year_later_minus_a_month, );
    my $retrieved_expiry_date = Koha::Patrons->find( $patron->{borrowernumber} )->dateexpiry;
    is( dt_from_string($retrieved_expiry_date), $a_year_later_minus_a_month );
    my $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'RENEW', object => $retrieved_patron->borrowernumber } )->count;
    is( $number_of_logs, 1, 'With BorrowerLogs, Koha::Patron->extend_subscription should have logged' );

    t::lib::Mocks::mock_preference( 'BorrowerRenewalPeriodBase', 'now' );
    t::lib::Mocks::mock_preference( 'BorrowersLog',              0 );
    $expiry_date = $retrieved_patron->extend_subscription;
    is( $expiry_date, $a_year_later, );
    $retrieved_expiry_date = Koha::Patrons->find( $patron->{borrowernumber} )->dateexpiry;
    is( dt_from_string($retrieved_expiry_date), $a_year_later );
    $number_of_logs = $schema->resultset('ActionLog')->search( { module => 'MEMBERS', action => 'RENEW', object => $retrieved_patron->borrowernumber } )->count;
    is( $number_of_logs, 1, 'Without BorrowerLogs, Koha::Patron->extend_subscription should not have logged' );

    $retrieved_patron->delete;
};

$retrieved_patron_1->delete;
is( Koha::Patrons->search->count, $nb_of_patrons + 1, 'Delete should have deleted the patron' );

$schema->storage->txn_rollback;

1;
