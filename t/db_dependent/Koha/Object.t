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

use Test::More tests => 11;
use Test::Exception;
use Test::Warn;
use DateTime;

use C4::Context;
use C4::Biblio; # AddBiblio
use C4::Circulation; # AddIssue
use C4::Members;# AddMember
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;

use Scalar::Util qw( isvstring );
use Try::Tiny;

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

subtest 'is_changed / make_column_dirty' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $object = Koha::Patron->new();
    $object->categorycode( $categorycode );
    $object->branchcode( $branchcode );
    $object->surname("Test Surname");
    $object->store();
    is( $object->is_changed(), 0, "Object is unchanged" );
    $object->surname("Test Surname");
    is( $object->is_changed(), 0, "Object is still unchanged" );
    $object->surname("Test Surname 2");
    is( $object->is_changed(), 1, "Object is changed" );

    $object->store();
    is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

    $object->set({ firstname => 'Test Firstname' });
    is( $object->is_changed(), 1, "Object is changed after Set" );
    $object->store();
    is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

    # Test make_column_dirty
    $object->make_column_dirty('firstname');
    is( $object->is_changed, 1, "Object is changed after make dirty" );
    $object->store;
    is( $object->is_changed, 0, "Store clears dirty mark" );
    $object->make_column_dirty('firstname');
    $object->discard_changes;
    is( $object->is_changed, 0, "Discard clears dirty mark too" );

    $schema->storage->txn_rollback;
};

subtest 'in_storage' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $object = Koha::Patron->new();
    is( $object->in_storage, 0, "Object is not in storage" );
    $object->categorycode( $categorycode );
    $object->branchcode( $branchcode );
    $object->surname("Test Surname");
    $object->store();
    is( $object->in_storage, 1, "Object is now stored" );
    $object->surname("another surname");
    is( $object->in_storage, 1 );

    my $borrowernumber = $object->borrowernumber;
    my $patron = $schema->resultset('Borrower')->find( $borrowernumber );
    is( $patron->surname(), "Test Surname", "Object found in database" );

    $object->delete();
    $patron = $schema->resultset('Borrower')->find( $borrowernumber );
    ok( ! $patron, "Object no longer found in database" );
    is( $object->in_storage, 0, "Object is not in storage" );

    $schema->storage->txn_rollback;
};

subtest 'id' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $patron = Koha::Patron->new({categorycode => $categorycode, branchcode => $branchcode })->store;
    is( $patron->id, $patron->borrowernumber );

    $schema->storage->txn_rollback;
};

subtest 'get_column' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $patron = Koha::Patron->new({categorycode => $categorycode, branchcode => $branchcode })->store;
    is( $patron->get_column('borrowernumber'), $patron->borrowernumber, 'get_column should retrieve the correct value' );

    $schema->storage->txn_rollback;
};

subtest 'discard_changes' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron = $builder->build( { source => 'Borrower' } );
    $patron = Koha::Patrons->find( $patron->{borrowernumber} );
    $patron->dateexpiry(dt_from_string);
    $patron->discard_changes;
    is(
        dt_from_string( $patron->dateexpiry ),
        dt_from_string->truncate( to => 'day' ),
        'discard_changes should refresh the object'
    );

    $schema->storage->txn_rollback;
};

subtest 'TO_JSON tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $dt = dt_from_string();
    my $borrowernumber = $builder->build(
        { source => 'Borrower',
          value => { lost => 1,
                     gonenoaddress => 0,
                     updated_on => $dt,
                     lastseen   => $dt, } })->{borrowernumber};

    my $patron = Koha::Patrons->find($borrowernumber);
    my $lost = $patron->TO_JSON()->{lost};
    my $gonenoaddress = $patron->TO_JSON->{gonenoaddress};
    my $updated_on = $patron->TO_JSON->{updated_on};
    my $lastseen = $patron->TO_JSON->{lastseen};

    ok( $lost->isa('JSON::PP::Boolean'), 'Boolean attribute type is correct' );
    is( $lost, 1, 'Boolean attribute value is correct (true)' );

    ok( $gonenoaddress->isa('JSON::PP::Boolean'), 'Boolean attribute type is correct' );
    is( $gonenoaddress, 0, 'Boolean attribute value is correct (false)' );

    ok( !isvstring($patron->borrowernumber), 'Integer values are not coded as strings' );

    my $rfc3999_regex = qr/
            (?<year>\d{4})
            -
            (?<month>\d{2})
            -
            (?<day>\d{2})
            ([Tt\s])
            (?<hour>\d{2})
            :
            (?<minute>\d{2})
            :
            (?<second>\d{2})
            (([Zz])|([\+|\-]([01][0-9]|2[0-3]):[0-5][0-9]))
        /xms;
    like( $updated_on, $rfc3999_regex, "Date-time $updated_on formatted correctly");
    like( $lastseen, $rfc3999_regex, "Date-time $updated_on formatted correctly");

    $schema->storage->txn_rollback;
};

subtest "Test update method" => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my $library = Koha::Libraries->find( $branchcode );
    $library->update({ branchname => 'New_Name', branchcity => 'AMS' });
    is( $library->branchname, 'New_Name', 'Changed name with update' );
    is( $library->branchcity, 'AMS', 'Changed city too' );
    is( $library->is_changed, 0, 'Change should be stored already' );
    try {
        $library->update({
            branchcity => 'NYC', not_a_column => 53, branchname => 'Name3',
        });
        fail( 'It should not be possible to update an unexisting column without an error from Koha::Object/DBIx' );
    } catch {
        ok( $_->isa('Koha::Exceptions::Object'), 'Caught error when updating wrong column' );
        $library->discard_changes; #requery after failing update
    };
    # Check if the columns are not updated
    is( $library->branchcity, 'AMS', 'First column not updated' );
    is( $library->branchname, 'New_Name', 'Third column not updated' );

    $schema->storage->txn_rollback;
};

subtest 'store() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    # Create a category to make sure its ID doesn't exist on the DB
    my $category = $builder->build_object({ class => 'Koha::Patron::Categories' });
    my $category_id = $category->id;
    $category->delete;

    my $patron = Koha::Patron->new({ categorycode => $category_id });

    my $print_error = $schema->storage->dbh->{PrintError};
    $schema->storage->dbh->{PrintError} = 0;
    throws_ok
        { $patron->store }
        'Koha::Exceptions::Object::FKConstraint',
        'Exception is thrown correctly';
    is(
        $@->message,
        "Broken FK constraint",
        'Exception message is correct'
    );
    is(
        $@->broken_fk,
        'categorycode',
        'Exception field is correct'
    );

    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    $category   = $builder->build_object({ class => 'Koha::Patron::Categories' });
    $patron     = $builder->build_object({ class => 'Koha::Patrons' });

    my $new_patron = Koha::Patron->new({
        branchcode   => $library->id,
        cardnumber   => $patron->cardnumber,
        categorycode => $category->id
    });

    throws_ok
        { $new_patron->store }
        'Koha::Exceptions::Object::DuplicateID',
        'Exception is thrown correctly';

    is(
        $@->message,
        'Duplicate ID',
        'Exception message is correct'
    );

    is(
       $@->duplicate_id,
       'cardnumber',
       'Exception field is correct'
    );

    $new_patron = Koha::Patron->new({
        branchcode   => $library->id,
        userid       => $patron->userid,
        categorycode => $category->id
    });

    throws_ok
        { $new_patron->store }
        'Koha::Exceptions::Object::DuplicateID',
        'Exception is thrown correctly';

    is(
        $@->message,
        'Duplicate ID',
        'Exception message is correct'
    );

    is(
       $@->duplicate_id,
       'userid',
       'Exception field is correct'
    );

    $schema->storage->dbh->{PrintError} = $print_error;

    # Successful test
    $patron->set({ firstname => 'Manuel' });
    my $ret = $patron->store;
    is( ref($ret), 'Koha::Patron', 'store() returns the object on success' );

    $schema->storage->txn_rollback;
};

subtest 'unblessed_all_relateds' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # FIXME It's very painful to create an issue in tests!
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    C4::Context->_new_userenv('xxx');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $library->branchcode, 'Midway Public Library', '', '', '');
    my $patron_category = $builder->build(
        {
            source => 'Category',
            value  => {
                category_type                 => 'P',
                enrolmentfee                  => 0,
                BlockExpiredPatronOpacActions => -1, # Pick the pref value
            }
        }
    );
    my $patron_data = {
        firstname =>  'firstname',
        surname => 'surname',
        categorycode => $patron_category->{categorycode},
        branchcode => $library->branchcode,
    };
    my $borrowernumber = C4::Members::AddMember(%$patron_data);
    my $patron = Koha::Patrons->find( $borrowernumber );
    my ($biblionumber) = AddBiblio( MARC::Record->new, '' );
    my $biblio = Koha::Biblios->find( $biblionumber );
    my $item = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                biblionumber  => $biblio->biblionumber,
                itemlost      => 0,
                withdrawn     => 0,
            }
        }
    );

    my $issue = AddIssue( $patron->unblessed, $item->barcode, DateTime->now->subtract( days => 1 ) );
    my $overdues = Koha::Patrons->find( $patron->id )->get_overdues; # Koha::Patron->get_overdue prefetches
    my $overdue = $overdues->next->unblessed_all_relateds;
    is( $overdue->{issue_id}, $issue->issue_id, 'unblessed_all_relateds has field from the original table (issues)' );
    is( $overdue->{title}, $biblio->title, 'unblessed_all_relateds has field from other tables (biblio)' );
    is( $overdue->{homebranch}, $item->homebranch, 'unblessed_all_relateds has field from other tables (items)' );

    $schema->storage->txn_rollback;
};
