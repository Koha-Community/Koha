
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

use Test::More tests => 4;

use C4::Context;
use C4::Circulation;

use Koha::Database;
use Koha::Items;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

# TODO create a subroutine in t::lib::Mocks
my $userenv_patron = $builder->build( { source => 'Borrower', }, );
C4::Context->_new_userenv('DUMMY SESSION');
C4::Context->set_userenv(
    $userenv_patron->{borrowernumber},
    $userenv_patron->{userid},
    'usercnum', 'First name', 'Surname',
    $userenv_patron->{_fk}{branchcode}{branchcode},
    $userenv_patron->{_fk}{branchcode}{branchname}, 0
);

my $anonymous = $builder->build( { source => 'Borrower', }, );

t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous->{borrowernumber} );

subtest 'patron privacy is 1 (default)' => sub {
    plan tests => 4;
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
    my ( $rows_affected, $err ) = C4::Circulation::AnonymiseIssueHistory('2010-10-11');
    ok( $rows_affected > 0, 'AnonymiseIssueHistory should affect at least 1 row' );
    is( $err, undef, 'AnonymiseIssueHistory should not return any error if success' );

    my $dbh = C4::Context->dbh;
    my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
        SELECT borrowernumber FROM old_issues where itemnumber = ?
    |, undef, $item->{itemnumber});
    is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'With privacy=1, the issue should have been anonymised' );

};

subtest 'patron privacy is 0 (forever)' => sub {
    plan tests => 3;

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
    my ( $rows_affected, $err ) = C4::Circulation::AnonymiseIssueHistory('2010-10-11');
    is( $err, undef, 'AnonymiseIssueHistory should not return any error if success' );

    my $dbh = C4::Context->dbh;
    my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
        SELECT borrowernumber FROM old_issues where itemnumber = ?
    |, undef, $item->{itemnumber});
    is( $borrowernumber_used_to_anonymised, $patron->{borrowernumber}, 'With privacy=0, the issue should not be anonymised' );
};

t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );

subtest 'AnonymousPatron is not defined' => sub {
    plan tests => 4;
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
    my ( $rows_affected, $err ) = C4::Circulation::AnonymiseIssueHistory('2010-10-11');
    ok( $rows_affected > 0, 'AnonymiseIssueHistory should affect at least 1 row' );
    is( $err, undef, 'AnonymiseIssueHistory should not return any error if success' );

    my $dbh = C4::Context->dbh;
    my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
        SELECT borrowernumber FROM old_issues where itemnumber = ?
    |, undef, $item->{itemnumber});
    is( $borrowernumber_used_to_anonymised, undef, 'With AnonymousPatron is not defined, the issue should have been anonymised anyway' );
};

subtest 'Test StoreLastBorrower' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '1' );

    my $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );

    my $item = $builder->build(
        {
            source => 'Item',
            value  => {
                itemlost  => 0,
                withdrawn => 0,
            },
        }
    );

    my $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->{itemnumber},
            },
        }
    );

    my $item_object   = Koha::Items->find( $item->{itemnumber} );
    my $patron_object = $item_object->last_returned_by();
    is( $patron_object, undef, 'Koha::Item::last_returned_by returned undef' );

    my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );

    $item_object   = Koha::Items->find( $item->{itemnumber} );
    $patron_object = $item_object->last_returned_by();
    is( ref($patron_object), 'Koha::Patron', 'Koha::Item::last_returned_by returned Koha::Patron' );

    $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );

    $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->{itemnumber},
            },
        }
    );

    ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );

    $item_object   = Koha::Items->find( $item->{itemnumber} );
    $patron_object = $item_object->last_returned_by();
    is( $patron_object->id, $patron->{borrowernumber}, 'Second patron to return item replaces the first' );

    $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );
    $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );

    $item_object->last_returned_by($patron_object);
    $item_object = Koha::Items->find( $item->{itemnumber} );
    my $patron_object2 = $item_object->last_returned_by();
    is( $patron_object->id, $patron_object2->id,
        'Calling last_returned_by with Borrower object sets last_returned_by to that borrower' );

    $patron_object->delete;
    $item_object = Koha::Items->find( $item->{itemnumber} );
    is( $item_object->last_returned_by, undef, 'last_returned_by should return undef if the last patron to return the item has been deleted' );

    t::lib::Mocks::mock_preference( 'StoreLastBorrower', '0' );
    $patron = $builder->build(
        {
            source => 'Borrower',
            value  => { privacy => 1, }
        }
    );

    $issue = $builder->build(
        {
            source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->{itemnumber},
            },
        }
    );
    ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );

    $item_object   = Koha::Items->find( $item->{itemnumber} );
    is( $item_object->last_returned_by, undef, 'Last patron to return item should not be stored if StoreLastBorrower if off' );
};

$schema->storage->txn_rollback;

1;
