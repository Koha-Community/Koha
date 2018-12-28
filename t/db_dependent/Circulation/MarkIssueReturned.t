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

use Test::More tests => 3;
use Test::Exception;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation;
use C4::Context;
use Koha::Checkouts;
use Koha::Database;
use Koha::Old::Checkouts;
use Koha::Patrons;

my $schema = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Failure tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'P', enrolmentfee => 0 } } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron   = $builder->build_object(
        {   class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, categorycode => $category->categorycode }
        }
    );
    my $biblioitem = $builder->build_object( { class => 'Koha::Biblioitems' } );
    my $item       = $builder->build_object(
        {   class => 'Koha::Items',
            value  => {
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->biblionumber,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my ( $issue_id, $issue );
    # The next call will return undef for invalid item number
    eval { $issue_id = C4::Circulation::MarkIssueReturned( $patron->borrowernumber, 'invalid_itemnumber', undef, 0 ) };
    is( $@, '', 'No die triggered by invalid itemnumber' );
    is( $issue_id, undef, 'No issue_id returned' );

    # In the next call we return the item and try it another time
    $issue = C4::Circulation::AddIssue( $patron, $item->barcode );
    eval { $issue_id = C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, undef, 0 ) };
    is( $issue_id, $issue->issue_id, "Item has been returned (issue $issue_id)" );
    eval { $issue_id = C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, undef, 0 ) };
    is( $@, '', 'No crash on returning item twice' );
    is( $issue_id, undef, 'Cannot return an item twice' );


    $schema->storage->txn_rollback;
};

subtest 'Anonymous patron tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'P', enrolmentfee => 0 } } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron   = $builder->build_object(
        {   class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, categorycode => $category->categorycode }
        }
    );
    my $biblioitem = $builder->build_object( { class => 'Koha::Biblioitems' } );
    my $item       = $builder->build_object(
        {   class => 'Koha::Items',
            value  => {
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->biblionumber,
            }
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Anonymous patron not set
    t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );

    my $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );
    eval { C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, undef, 2 ) };
    like ( $@, qr<Fatal error: the patron \(\d+\) .* AnonymousPatron>, 'AnonymousPatron is not set - Fatal error on anonymization' );
    Koha::Checkouts->find( $issue->issue_id )->delete;

    # Create a valid anonymous user
    my $anonymous = $builder->build_object({
        class => 'Koha::Patrons',
        value => {
            categorycode => $category->categorycode,
            branchcode => $library->branchcode
        }
    });
    t::lib::Mocks::mock_preference('AnonymousPatron', $anonymous->borrowernumber);
    $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

    eval { C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, undef, 2 ) };
    is ( $@, q||, 'AnonymousPatron is set correctly - no error expected');

    $schema->storage->txn_rollback;
};

subtest 'Manually pass a return date' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'P', enrolmentfee => 0 } } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {   class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, categorycode => $category->categorycode }
        }
    );
    my $biblioitem = $builder->build_object( { class => 'Koha::Biblioitems' } );
    my $item       = $builder->build_object(
        {   class => 'Koha::Items',
            value  => {
                homebranch    => $library->branchcode,
                holdingbranch => $library->branchcode,
                notforloan    => 0,
                itemlost      => 0,
                withdrawn     => 0,
                biblionumber  => $biblioitem->biblionumber,
            }
        }
    );

    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });

    my ( $issue, $issue_id );

    $issue = C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );
    $issue_id = C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, '2018-12-25', 0 );

    is( $issue_id, $issue->issue_id, "Item has been returned" );
    my $old_checkout = Koha::Old::Checkouts->find( $issue_id );
    is( $old_checkout->returndate, '2018-12-25 00:00:00', 'Manually passed date stored correctly' );

    $issue = C4::Circulation::AddIssue( $patron, $item->barcode );

    throws_ok
        { $issue_id = C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, 'bad_date', 0 ); }
        'Koha::Exceptions::Object::BadValue',
        'An exception is thrown on bad date';

    $schema->storage->txn_rollback;
};
