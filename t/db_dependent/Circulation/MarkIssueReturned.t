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
use Test::Exception;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation qw( MarkIssueReturned AddIssue );
use C4::Context;
use Koha::Checkouts;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Old::Checkouts;
use Koha::Patrons;
use Koha::Patron::Debarments qw( AddUniqueDebarment );

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
    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
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

    plan tests => 3;

    $schema->storage->txn_begin;

    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'P', enrolmentfee => 0 } } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron   = $builder->build_object(
        {   class => 'Koha::Patrons',
            value => { branchcode => $library->branchcode, categorycode => $category->categorycode }
        }
    );
    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Anonymous patron not set
    t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );

    my $issue = C4::Circulation::AddIssue( $patron, $item->barcode );

    throws_ok
        { C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, undef, 2 ); }
        'Koha::Exceptions::SysPref::NotSet',
        'AnonymousPatron not set causes an exception';

    is( $@->syspref, 'AnonymousPatron', 'AnonymousPatron is not set - Fatal error on anonymization' );
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
    $issue = C4::Circulation::AddIssue( $patron, $item->barcode );

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
    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });

    my ( $issue, $issue_id );

    $issue = C4::Circulation::AddIssue( $patron, $item->barcode );
    $issue_id = C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, '2018-12-25', 0 );

    is( $issue_id, $issue->issue_id, "Item has been returned" );
    my $old_checkout = Koha::Old::Checkouts->find( $issue_id );
    is( $old_checkout->returndate, '2018-12-25 00:00:00', 'Manually passed date stored correctly' );

    $issue = C4::Circulation::AddIssue( $patron, $item->barcode );

    {
        # Hiding the expected warning displayed by DBI
        # DBD::mysql::st execute failed: Incorrect datetime value: 'bad_date' for column 'returndate'
        local *STDERR;
        open STDERR, '>', '/dev/null';
        throws_ok
            { $issue_id = C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item->itemnumber, 'bad_date', 0 ); }
            'Koha::Exceptions::Object::BadValue',
            'An exception is thrown on bad date';
        close STDERR;
    }

    $schema->storage->txn_rollback;
};

subtest 'AutoRemoveOverduesRestrictions' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference('AutoRemoveOverduesRestrictions', 1);

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    t::lib::Mocks::mock_userenv( { branchcode => $patron->branchcode } );
    my $item_1 = $builder->build_sample_item;
    my $item_2 = $builder->build_sample_item;
    my $item_3 = $builder->build_sample_item;
    my $five_days_ago = dt_from_string->subtract( days => 5 );
    my $checkout_1 = AddIssue( $patron, $item_1->barcode, $five_days_ago ); # overdue
    my $checkout_2 = AddIssue( $patron, $item_2->barcode, $five_days_ago ); # overdue
    my $checkout_3 = AddIssue( $patron, $item_3->barcode ); # not overdue

    Koha::Patron::Debarments::AddUniqueDebarment(
        {
            borrowernumber => $patron->borrowernumber,
            type           => 'OVERDUES',
            comment => "OVERDUES_PROCESS simulation",
        }
    );

    C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item_1->itemnumber );

    my $restrictions = $patron->restrictions;
    my $THE_restriction = $restrictions->next;
    is( $THE_restriction->type->code, 'OVERDUES', 'OVERDUES debarment is not removed if patron still has overdues' );

    C4::Circulation::MarkIssueReturned( $patron->borrowernumber, $item_2->itemnumber );

    $restrictions = $patron->restrictions;
    is( $restrictions->count, 0, 'OVERDUES debarment is removed if patron does not have overdues' );

    $schema->storage->txn_rollback;
};
