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

use CGI qw ( -utf8 );

use Test::More tests => 12;
use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;
use t::lib::Dates;
use XML::LibXML;

use C4::Items qw( ModItemTransfer );
use C4::Circulation qw( AddIssue );
use C4::Reserves qw (AddReserve ModReserve ModReserveAffect ModReserveStatus);

use Koha::AuthUtils;
use Koha::DateUtils qw( dt_from_string );

BEGIN {
    use_ok('C4::ILSDI::Services', qw( AuthenticatePatron GetPatronInfo LookupPatron HoldTitle HoldItem GetRecords RenewLoan GetAvailability ));
}

my $schema  = Koha::Database->schema;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

subtest 'AuthenticatePatron test' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $plain_password = 'tomasito';

    $builder->build({
        source => 'Borrower',
        value => {
            cardnumber => undef,
        }
    });

    my $borrower = $builder->build({
        source => 'Borrower',
        value  => {
            cardnumber => undef,
            password => Koha::AuthUtils::hash_password( $plain_password ),
            lastseen => "2001-01-01 12:34:56"
        }
    });

    my $query = CGI->new;
    $query->param( 'username', $borrower->{userid});
    $query->param( 'password', $plain_password);

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '' );
    my $reply = C4::ILSDI::Services::AuthenticatePatron( $query );
    is( $reply->{id}, $borrower->{borrowernumber}, "userid and password - Patron authenticated" );
    is( $reply->{code}, undef, "Error code undef");
    my $seen_patron = Koha::Patrons->find({ borrowernumber => $reply->{id} });
    is( $seen_patron->lastseen(), '2001-01-01 12:34:56','Last seen not updated if not tracking patrons');

    $query->param('password','ilsdi-passworD');
    $reply = C4::ILSDI::Services::AuthenticatePatron( $query );
    is( $reply->{code}, 'PatronNotFound', "userid and wrong password - PatronNotFound" );
    is( $reply->{id}, undef, "id undef");

    $query->param( 'password', $plain_password );
    $query->param( 'username', 'wrong-ilsdi-useriD' );
    $reply = C4::ILSDI::Services::AuthenticatePatron( $query );
    is( $reply->{code}, 'PatronNotFound', "non-existing userid - PatronNotFound" );
    is( $reply->{id}, undef, "id undef");

    t::lib::Mocks::mock_preference( 'TrackLastPatronActivity', '1' );
    $query->param( 'username', uc( $borrower->{userid} ));
    $reply = C4::ILSDI::Services::AuthenticatePatron( $query );
    my $now = dt_from_string;
    is( $reply->{id}, $borrower->{borrowernumber}, "userid is not case sensitive - Patron authenticated" );
    is( $reply->{code}, undef, "Error code undef");
    $seen_patron = Koha::Patrons->find({ borrowernumber => $reply->{id} });
    is( t::lib::Dates::compare( $seen_patron->lastseen, $now), 0, 'Last seen updated to today if tracking patrons' );

    $query->param( 'username', $borrower->{cardnumber} );
    $reply = C4::ILSDI::Services::AuthenticatePatron( $query );
    is( $reply->{id}, $borrower->{borrowernumber}, "cardnumber and password - Patron authenticated" );
    is( $reply->{code}, undef, "Error code undef" );

    $query->param( 'password', 'ilsdi-passworD' );
    $reply = C4::ILSDI::Services::AuthenticatePatron( $query );
    is( $reply->{code}, 'PatronNotFound', "cardnumber and wrong password - PatronNotFount" );
    is( $reply->{id}, undef, "id undef" );

    $query->param( 'username', 'randomcardnumber1234' );
    $query->param( 'password', $plain_password );
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is( $reply->{code}, 'PatronNotFound', "non-existing cardnumer/userid - PatronNotFound" );
    is( $reply->{id}, undef, "id undef");

    $query->param( 'username', $borrower->{userid} );
    $query->param( 'password', $plain_password );
    $seen_patron->password_expiration_date('2020-01-01')->store;
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is( $reply->{code}, 'PasswordExpired', "correct credentials, expired password not authenticated" );
    is( $reply->{id}, undef, "id undef");

    $schema->storage->txn_rollback;
};


subtest 'GetPatronInfo/GetBorrowerAttributes test for extended patron attributes' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    $schema->resultset( 'Issue' )->delete_all;
    $schema->resultset( 'Borrower' )->delete_all;
    $schema->resultset( 'BorrowerAttribute' )->delete_all;
    $schema->resultset( 'BorrowerAttributeType' )->delete_all;
    $schema->resultset( 'Category' )->delete_all;
    $schema->resultset( 'Item' )->delete_all; # 'Branch' deps. on this
    $schema->resultset( 'Club' )->delete_all;
    $schema->resultset( 'Branch' )->delete_all;

    # Configure Koha to enable ILS-DI server and extended attributes:
    t::lib::Mocks::mock_preference( 'ILS-DI', 1 );
    t::lib::Mocks::mock_preference( 'ExtendedPatronAttributes', 1 );

    # Set up a library/branch for our user to belong to:
    my $lib = $builder->build( {
        source => 'Branch',
        value => {
            branchcode => 'T_ILSDI',
        }
    } );

    # Create a new category for user to belong to:
    my $cat = $builder->build( {
        source => 'Category',
        value  => {
            category_type                 => 'A',
            BlockExpiredPatronOpacActions => -1,
        }
    } );

    # Create a new attribute type:
    my $attr_type = $builder->build( {
        source => 'BorrowerAttributeType',
        value  => {
            code                      => 'HIDEME',
            opac_display              => 0,
            authorised_value_category => '',
            class                     => '',
        }
    } );
    my $attr_type_visible = $builder->build( {
        source => 'BorrowerAttributeType',
        value  => {
            code                      => 'SHOWME',
            opac_display              => 1,
            authorised_value_category => '',
            class                     => '',
        }
    } );

    # Create a new user:
    my $brwr = $builder->build( {
        source => 'Borrower',
        value  => {
            categorycode => $cat->{'categorycode'},
            branchcode   => $lib->{'branchcode'},
        }
    } );

    # Authorised value:
    my $auth = $builder->build( {
        source => 'AuthorisedValue',
        value  => {
            category => $cat->{'categorycode'}
        }
    } );

    # Set the new attribute for our user:
    my $attr_hidden = $builder->build( {
        source => 'BorrowerAttribute',
        value  => {
            borrowernumber => $brwr->{'borrowernumber'},
            code           => $attr_type->{'code'},
            attribute      => '1337 hidden',
        }
    } );
    my $attr_shown = $builder->build( {
        source => 'BorrowerAttribute',
        value  => {
            borrowernumber => $brwr->{'borrowernumber'},
            code           => $attr_type_visible->{'code'},
            attribute      => '1337 shown',
        }
    } );

    my $fine = $builder->build(
        {
            source => 'Accountline',
            value  => {
                borrowernumber    => $brwr->{borrowernumber},
                debit_type_code   => 'OVERDUE',
                amountoutstanding => 10
            }
        }
    );

    # Prepare and send web request for IL-SDI server:
    my $query = CGI->new;
    $query->param( 'service', 'GetPatronInfo' );
    $query->param( 'patron_id', $brwr->{'borrowernumber'} );
    $query->param( 'show_attributes', '1' );
    $query->param( 'show_fines', '1' );

    my $reply = C4::ILSDI::Services::GetPatronInfo( $query );

    # Build a structure for comparison:
    my $cmp = {
        borrowernumber    => $brwr->{borrowernumber},
        value             => $attr_shown->{'attribute'},
        value_description => $attr_shown->{'attribute'},
        %$attr_type_visible,
        %$attr_shown,
    };

    is( $reply->{'charges'}, '10.00',
        'The \'charges\' attribute should be correctly filled (bug 17836)' );

    is( scalar( @{$reply->{fines}->{fine}}), 1, 'There should be only 1 account line');
    is(
        $reply->{fines}->{fine}->[0]->{accountlines_id},
        $fine->{accountlines_id},
        "The accountline should be the correct one"
    );

    # Check results:
    is_deeply( $reply->{'attributes'}, [ $cmp ], 'Test GetPatronInfo - show_attributes parameter' );

    ok( exists $reply->{is_expired}, 'There should be the is_expired information');

    # Cleanup
    $schema->storage->txn_rollback;
};

subtest 'LookupPatron test' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    $schema->resultset( 'Issue' )->delete_all;
    $schema->resultset( 'Borrower' )->delete_all;
    $schema->resultset( 'BorrowerAttribute' )->delete_all;
    $schema->resultset( 'BorrowerAttributeType' )->delete_all;
    $schema->resultset( 'Category' )->delete_all;
    $schema->resultset( 'Item' )->delete_all; # 'Branch' deps. on this
    $schema->resultset( 'Branch' )->delete_all;

    my $borrower = $builder->build({
        source => 'Borrower',
    });

    my $query = CGI->new();
    my $bad_result = C4::ILSDI::Services::LookupPatron($query);
    is( $bad_result->{message}, 'PatronNotFound', 'No parameters' );

    $query->delete_all();
    $query->param( 'id', $borrower->{firstname} );
    my $optional_result = C4::ILSDI::Services::LookupPatron($query);
    is(
        $optional_result->{id},
        $borrower->{borrowernumber},
        'Valid Firstname only'
    );

    $query->delete_all();
    $query->param( 'id', 'ThereIsNoWayThatThisCouldPossiblyBeValid' );
    my $bad_optional_result = C4::ILSDI::Services::LookupPatron($query);
    is( $bad_optional_result->{message}, 'PatronNotFound', 'Invalid ID' );

    foreach my $id_type (
        'cardnumber',
        'userid',
        'email',
        'borrowernumber',
        'surname',
        'firstname'
    ) {
        $query->delete_all();
        $query->param( 'id_type', $id_type );
        $query->param( 'id', $borrower->{$id_type} );
        my $result = C4::ILSDI::Services::LookupPatron($query);
        is( $result->{'id'}, $borrower->{borrowernumber}, "Checking $id_type" );
    }

    # Cleanup
    $schema->storage->txn_rollback;
};

subtest 'Holds test' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'AllowHoldsOnDamagedItems', 0 );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $item = $builder->build_sample_item(
        {
            damaged => 1
        }
    );

    my $query = CGI->new;
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $item->biblionumber);

    my $reply = C4::ILSDI::Services::HoldTitle( $query );
    is( $reply->{code}, 'damaged', "Item damaged" );

    $item->damaged(0)->store;

    my $hold = $builder->build({
        source => 'Reserve',
        value => {
            borrowernumber => $patron->borrowernumber,
            biblionumber => $item->biblionumber,
            itemnumber => $item->itemnumber
        }
    });

    $reply = C4::ILSDI::Services::HoldTitle( $query );
    is( $reply->{code}, 'itemAlreadyOnHold', "Item already on hold" );

    my $biblio_with_no_item = $builder->build_sample_biblio;

    $query = CGI->new;
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $biblio_with_no_item->biblionumber);

    $reply = C4::ILSDI::Services::HoldTitle( $query );
    is( $reply->{code}, 'NoItems', 'Biblio has no item' );

    my $item2 = $builder->build_sample_item(
        {
            damaged => 0,
        }
    );

    t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );
    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item2->{itype},
            branchcode   => $patron->branchcode,
            rule_name    => 'reservesallowed',
            rule_value   => 1,
        }
    );

    $query = CGI->new;
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $item2->biblionumber);
    $query->param( 'item_id', $item2->itemnumber);

    $reply = C4::ILSDI::Services::HoldItem( $query );
    is( $reply->{code}, 'tooManyReserves', "Too many reserves" );

    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item2->{itype},
            branchcode   => $patron->branchcode,
            rule_name    => 'reservesallowed',
            rule_value   => 0,
        }
    );

    $query = CGI->new;
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $item2->biblionumber);
    $query->param( 'item_id', $item2->itemnumber);

    $reply = C4::ILSDI::Services::HoldItem( $query );
    is( $reply->{code}, 'noReservesAllowed', "No reserves allowed" );

    my $origin_branch = $builder->build(
        {
            source => 'Branch',
            value  => {
                pickup_location => 1,
            }
        }
    );

    # Adding a holdable item.
    my $item3 = $builder->build_sample_item(
       {
           barcode => '123456789',
           library => $origin_branch->{branchcode}
       });

    my $item4 = $builder->build_sample_item(
        {
           biblionumber => $item3->biblionumber,
           damaged => 1,
           library => $origin_branch->{branchcode}
       });

    Koha::CirculationRules->set_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item3->{itype},
            branchcode   => $patron->branchcode,
            rule_name    => 'reservesallowed',
            rule_value   => 10,
        }
    );

    $query = CGI->new;
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $item4->biblionumber);
    $query->param( 'item_id', $item4->itemnumber);

    $reply = C4::ILSDI::Services::HoldItem( $query );
    is( $reply->{code}, 'damaged', "Item is damaged" );

    my $module = Test::MockModule->new('C4::Context');
    $module->mock('userenv', sub { { patron => $patron->unblessed } });
    my $issue = C4::Circulation::AddIssue($patron, $item3->barcode);
    t::lib::Mocks::mock_preference( 'AllowHoldsOnPatronsPossessions', '0' );

    $query = CGI->new;
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $item3->biblionumber);
    $query->param( 'item_id', $item3->itemnumber);
    $query->param( 'pickup_location', $origin_branch->{branchcode});
    $reply = C4::ILSDI::Services::HoldItem( $query );

    is( $reply->{code}, 'alreadypossession', "Patron has issued same book" );
    is( $reply->{pickup_location}, undef, "No reserve placed");

    # Test Patron cannot reserve if expired and BlockExpiredPatronOpacActions
    my $category = $builder->build({
        source => 'Category',
        value => { BlockExpiredPatronOpacActions => -1 }
        });

    my $branch_1 = $builder->build({ source => 'Branch' })->{ branchcode };

    my $expired_borrowernumber = Koha::Patron->new({
        firstname =>  'Expired',
        surname => 'Patron',
        categorycode => $category->{categorycode},
        branchcode => $branch_1,
        dateexpiry => '2000-01-01',
    })->store->borrowernumber;

    t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 1);

    my $item5 = $builder->build({
        source => 'Item',
        value => {
            biblionumber => $biblio_with_no_item->biblionumber,
            damaged => 0,
        }
    });

    $query = CGI->new;
    $query->param( 'patron_id', $expired_borrowernumber);
    $query->param( 'bib_id', $biblio_with_no_item->biblionumber);
    $query->param( 'item_id', $item5->{itemnumber});

    $reply = C4::ILSDI::Services::HoldItem( $query );
    is( $reply->{code}, 'PatronExpired', "Patron is expired" );

    $schema->storage->txn_rollback;
};

subtest 'Holds test for branch transfer limits' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Test enforement of branch transfer limits
    t::lib::Mocks::mock_preference( 'UseBranchTransferLimits', '1' );
    t::lib::Mocks::mock_preference( 'BranchTransferLimitsType', 'itemtype' );

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
    });

    my $origin_branch = $builder->build(
        {
            source => 'Branch',
            value  => {
                pickup_location => 1,
            }
        }
    );
    my $pickup_branch = $builder->build(
        {
            source => 'Branch',
            value  => {
                pickup_location => 1,
            }
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $origin_branch->{branchcode},
        }
    );

    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rule_name    => 'reservesallowed',
            rule_value   => 99,
        }
    );

    my $limit = Koha::Item::Transfer::Limit->new({
        toBranch => $pickup_branch->{branchcode},
        fromBranch => $item->holdingbranch,
        itemtype => $item->effective_itemtype,
    })->store();

    my $query = CGI->new;
    $query->param( 'pickup_location', $pickup_branch->{branchcode} );
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $item->biblionumber);
    $query->param( 'item_id', $item->itemnumber);

    my $reply = C4::ILSDI::Services::HoldItem( $query );
    is( $reply->{code}, 'cannotBeTransferred', "Item hold, Item cannot be transferred" );

    $reply = C4::ILSDI::Services::HoldTitle( $query );
    is( $reply->{code}, 'cannotBeTransferred', "Record hold, Item cannot be transferred" );

    t::lib::Mocks::mock_preference( 'UseBranchTransferLimits', '0' );

    $reply = C4::ILSDI::Services::HoldItem( $query );
    is( $reply->{code}, undef, "Item hold, Item can be transferred" );
    my $hold = Koha::Holds->search({ itemnumber => $item->itemnumber, borrowernumber => $patron->borrowernumber })->next;
    is( $hold->branchcode, $pickup_branch->{branchcode}, 'The library id is correctly set' );

    Koha::Holds->search()->delete();

    $reply = C4::ILSDI::Services::HoldTitle( $query );
    is( $reply->{code}, undef, "Record hold, Item con be transferred" );
    $hold = Koha::Holds->search({ biblionumber => $item->biblionumber, borrowernumber => $patron->borrowernumber })->next;
    is( $hold->branchcode, $pickup_branch->{branchcode}, 'The library id is correctly set' );

    $schema->storage->txn_rollback;
};

subtest 'Holds test with start_date and end_date' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $pickup_library = $builder->build_object(
        {
            class  => 'Koha::Libraries',
            value  => {
                pickup_location => 1,
            }
        }
    );

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
    });

    my $item = $builder->build_sample_item({ library => $pickup_library->branchcode });

    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rule_name    => 'reservesallowed',
            rule_value   => 99,
        }
    );

    my $query = CGI->new;
    $query->param( 'pickup_location', $pickup_library->branchcode );
    $query->param( 'patron_id', $patron->borrowernumber);
    $query->param( 'bib_id', $item->biblionumber);
    $query->param( 'item_id', $item->itemnumber);
    $query->param( 'start_date', '2020-03-20');
    $query->param( 'expiry_date', '2020-04-22');

    my $reply = C4::ILSDI::Services::HoldItem( $query );
    is ($reply->{pickup_location}, $pickup_library->branchname, "Item hold with date parameters was placed");
    my $hold = Koha::Holds->search({ biblionumber => $item->biblionumber})->next();
    is( $hold->biblionumber, $item->biblionumber, "correct biblionumber");
    is( $hold->reservedate, '2020-03-20', "Item hold has correct start date" );
    is( $hold->expirationdate, '2020-04-22', "Item hold has correct end date" );

    $hold->delete();

    $reply = C4::ILSDI::Services::HoldTitle( $query );
    is ($reply->{pickup_location}, $pickup_library->branchname, "Record hold with date parameters was placed");
    $hold = Koha::Holds->search({ biblionumber => $item->biblionumber})->next();
    is( $hold->biblionumber, $item->biblionumber, "correct biblionumber");
    is( $hold->reservedate, '2020-03-20', "Record hold has correct start date" );
    is( $hold->expirationdate, '2020-04-22', "Record hold has correct end date" );

    $schema->storage->txn_rollback;
};

subtest 'GetRecords' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'ILS-DI', 1 );

    my $branch1 = $builder->build({
        source => 'Branch',
    });
    my $branch2 = $builder->build({
        source => 'Branch',
    });

    my $item = $builder->build_sample_item(
        {
            library => $branch1->{branchcode},
        }
    );

    my $patron = $builder->build({
        source => 'Borrower',
    });

    my $issue = $builder->build({
        source => 'Issue',
        value => {
            itemnumber => $item->itemnumber,
        }
    });

    my $hold = $builder->build({
        source => 'Reserve',
        value => {
            biblionumber => $item->biblionumber,
        }
    });

    ModItemTransfer($item->itemnumber, $branch1->{branchcode}, $branch2->{branchcode}, 'Manual');

    my $cgi = CGI->new;
    $cgi->param(service => 'GetRecords');
    $cgi->param(id => $item->biblionumber);

    my $reply = C4::ILSDI::Services::GetRecords($cgi);

    my $transfer = $item->get_transfer;
    my $expected = {
        datesent => $transfer->datesent,
        frombranch => $transfer->frombranch,
        tobranch => $transfer->tobranch,
    };
    is_deeply($reply->{record}->[0]->{items}->{item}->[0]->{transfer}, $expected,
        'GetRecords returns transfer informations');

    # Check informations exposed
    my $reply_issue = $reply->{record}->[0]->{issues}->{issue}->[0];
    is($reply_issue->{itemnumber}, $item->itemnumber, 'GetRecords has an issue tag');
    is($reply_issue->{borrowernumber}, undef, 'GetRecords does not expose borrowernumber in issue tag');
    is($reply_issue->{surname}, undef, 'GetRecords does not expose surname in issue tag');
    is($reply_issue->{firstname}, undef, 'GetRecords does not expose firstname in issue tag');
    is($reply_issue->{cardnumber}, undef, 'GetRecords does not expose cardnumber in issue tag');
    my $reply_reserve = $reply->{record}->[0]->{reserves}->{reserve}->[0];
    is($reply_reserve->{biblionumber}, $item->biblionumber, 'GetRecords has a reserve tag');
    is($reply_reserve->{borrowernumber}, undef, 'GetRecords does not expose borrowernumber in reserve tag');

    $schema->storage->txn_rollback;
};

subtest 'RenewHold' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $cgi    = CGI->new;
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item   = $builder->build_sample_item;
    $cgi->param( patron_id => $patron->borrowernumber );
    $cgi->param( item_id   => $item->itemnumber );

    t::lib::Mocks::mock_userenv( { patron => $patron } );    # For AddIssue
    my $checkout = C4::Circulation::AddIssue( $patron, $item->barcode );

    # Everything is ok
    my $reply = C4::ILSDI::Services::RenewLoan($cgi);
    is( exists $reply->{date_due}, 1, 'If the item is checked out, the date_due key should exist' );

    # The item is not checked out
    $checkout->delete;
    $reply = C4::ILSDI::Services::RenewLoan($cgi);
    is( $reply, undef, 'If the item is not checked out, we should not explode.');    # FIXME We should return an error code instead

    # The item does not exist
    $item->delete;
    $reply = C4::ILSDI::Services::RenewLoan($cgi);
    is( $reply->{code}, 'RecordNotFound', 'If the item does not exist, RecordNotFound should be returned');

    $patron->delete;
    $reply = C4::ILSDI::Services::RenewLoan($cgi);
    is( $reply->{code}, 'PatronNotFound', 'If the patron does not exist, PatronNotFound should be returned');

    $schema->storage->txn_rollback;
};

subtest 'CancelHold' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $cgi = CGI->new;

    my $library = $builder->build_object({
        class => 'Koha::Libraries',
    });

    my $patron = $builder->build_object( { class => 'Koha::Patrons',
                                           value => {
                                               branchcode => $library->branchcode,
                                           },
                                         } );

    my $patron2 = $builder->build_object( { class => 'Koha::Patrons',
                                           value => {
                                               branchcode => $library->branchcode,
                                           },
                                         } );

    my $item = $builder->build_sample_item({ library => $library->branchcode });

    my $reserve = C4::Reserves::AddReserve({branchcode => $library->branchcode,
                                            borrowernumber => $patron->borrowernumber,
                                            biblionumber => $item->biblionumber });

    # Affecting the reserve sets it to a waiting state
    C4::Reserves::ModReserveAffect( $item->itemnumber,
                                    $patron->borrowernumber,
                                    undef,
                                    $reserve,
                                   );

    $cgi->param( patron_id => $patron2->borrowernumber );
    $cgi->param( item_id   => $reserve );


    my $reply = C4::ILSDI::Services::CancelHold($cgi);
    is( $reply->{code}, 'BorrowerCannotCancelHold', 'If the patron is wrong, BorrowerCannotCancelHold should be returned');

    $cgi->param( patron_id => $patron->borrowernumber );
    $reply = C4::ILSDI::Services::CancelHold($cgi);
    is( $reply->{code}, 'BorrowerCannotCancelHold', 'If reserve in a Waiting state, patron cannot cancel');

    C4::Reserves::ModReserveStatus( $item->itemnumber, 'T' );
    $reply = C4::ILSDI::Services::CancelHold($cgi);
    is( $reply->{code}, 'BorrowerCannotCancelHold', 'If reserve in a Transfer state, patron cannot cancel');

    C4::Reserves::ModReserve( {rank => 1, reserve_id => $reserve, branchcode => $library->branchcode} );
    $cgi->param( item_id => $reserve );
    $reply = C4::ILSDI::Services::CancelHold($cgi);
    is( $reply->{code}, 'Canceled', 'If the patron is fine and reserve not waiting, Canceled should be returned and reserve canceled');

    $schema->storage->txn_rollback;
};

subtest 'GetPatronInfo paginated loans' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    my $library = $builder->build_object({
        class => 'Koha::Libraries',
    });

    my $item1 = $builder->build_sample_item({ library => $library->branchcode });
    my $item2 = $builder->build_sample_item({ library => $library->branchcode });
    my $item3 = $builder->build_sample_item({ library => $library->branchcode });
    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => {
            branchcode => $library->branchcode,
        },
    });
    my $module = Test::MockModule->new('C4::Context');
    $module->mock('userenv', sub { { branch => $library->branchcode } });
    my $date_due = Koha::DateUtils::dt_from_string()->add(weeks => 2);
    my $issue1 = C4::Circulation::AddIssue($patron, $item1->barcode, $date_due);
    my $date_due1 = Koha::DateUtils::dt_from_string( $issue1->date_due );
    my $issue2 = C4::Circulation::AddIssue($patron, $item2->barcode, $date_due);
    my $date_due2 = Koha::DateUtils::dt_from_string( $issue2->date_due );
    my $issue3 = C4::Circulation::AddIssue($patron, $item3->barcode, $date_due);
    my $date_due3 = Koha::DateUtils::dt_from_string( $issue3->date_due );

    my $cgi = CGI->new;

    $cgi->param( 'service', 'GetPatronInfo' );
    $cgi->param( 'patron_id', $patron->borrowernumber );
    $cgi->param( 'show_loans', '1' );
    $cgi->param( 'loans_per_page', '2' );
    $cgi->param( 'loans_page', '1' );
    my $reply = C4::ILSDI::Services::GetPatronInfo($cgi);

    is($reply->{total_loans}, 3, 'total_loans == 3');
    is(scalar @{ $reply->{loans}->{loan} }, 2, 'GetPatronInfo returned only 2 loans');
    is($reply->{loans}->{loan}->[0]->{itemnumber}, $item3->itemnumber);
    is($reply->{loans}->{loan}->[1]->{itemnumber}, $item2->itemnumber);

    $cgi->param( 'loans_page', '2' );
    $reply = C4::ILSDI::Services::GetPatronInfo($cgi);

    is($reply->{total_loans}, 3, 'total_loans == 3');
    is(scalar @{ $reply->{loans}->{loan} }, 1, 'GetPatronInfo returned only 1 loan');
    is($reply->{loans}->{loan}->[0]->{itemnumber}, $item1->itemnumber);

    $schema->storage->txn_rollback;
};

subtest 'GetAvailability itemcallnumber' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'ILS-DI', 1 );

    my $item1 = $builder->build_sample_item(
        {
            itemcallnumber => "callnumber",
        }
    );

    my $item2 = $builder->build_sample_item( {} );

    # Build the query
    my $cgi = CGI->new;
    $cgi->param( service => 'GetAvailability' );
    $cgi->param( id      => $item1->itemnumber );
    $cgi->param( id_type => 'item' );

    # Output of GetAvailability is a string containing XML
    my $reply = C4::ILSDI::Services::GetAvailability($cgi);

    # Parse the output and get info
    my $result_XML = XML::LibXML->load_xml( string => $reply );
    my $reply_callnumber =
      $result_XML->findnodes('//dlf:itemcallnumber')->to_literal();

    # Test the output
    is( $reply_callnumber, $item1->itemcallnumber,
        "GetAvailability item has an itemcallnumber tag" );

    $cgi = CGI->new;
    $cgi->param( service => 'GetAvailability' );
    $cgi->param( id      => $item2->itemnumber );
    $cgi->param( id_type => 'item' );
    $reply      = C4::ILSDI::Services::GetAvailability($cgi);
    $result_XML = XML::LibXML->load_xml( string => $reply );
    $reply_callnumber =
      $result_XML->findnodes('//dlf:itemcallnumber')->to_literal();
    is( $reply_callnumber, '',
        "As expected, GetAvailability item has no itemcallnumber tag" );

    $cgi = CGI->new;
    $cgi->param( service => 'GetAvailability' );
    $cgi->param( id      => $item1->biblionumber );
    $cgi->param( id_type => 'biblio' );
    $reply      = C4::ILSDI::Services::GetAvailability($cgi);
    $result_XML = XML::LibXML->load_xml( string => $reply );
    $reply_callnumber =
      $result_XML->findnodes('//dlf:itemcallnumber')->to_literal();
    is( $reply_callnumber, $item1->itemcallnumber,
        "GetAvailability biblio has an itemcallnumber tag" );

    $cgi = CGI->new;
    $cgi->param( service => 'GetAvailability' );
    $cgi->param( id      => $item2->biblionumber );
    $cgi->param( id_type => 'biblio' );
    $reply      = C4::ILSDI::Services::GetAvailability($cgi);
    $result_XML = XML::LibXML->load_xml( string => $reply );
    $reply_callnumber =
      $result_XML->findnodes('//dlf:itemcallnumber')->to_literal();
    is( $reply_callnumber, '',
        "As expected, GetAvailability biblio has no itemcallnumber tag" );

    $schema->storage->txn_rollback;
};
