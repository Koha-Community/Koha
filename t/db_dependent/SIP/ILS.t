#!/usr/bin/perl

# Tests for C4::SIP::ILS
# Please help to extend them!

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

use Test::More tests => 15;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Reserves qw( AddReserve );
use C4::Circulation qw( AddIssue );
use Koha::CirculationRules;
use Koha::Database;
use Koha::Holds;

BEGIN {
    use_ok('C4::SIP::ILS');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();

my $class = 'C4::SIP::ILS';
my $institution = { id => 'CPL', };

my $ils = $class->new( $institution );

isa_ok( $ils, $class );

# Check all methods required for interface are there
my @methods = qw(
    find_patron find_item checkout_ok checkin_ok offline_ok status_update_ok
    offline_ok checkout checkin end_patron_session pay_fee add_hold cancel_hold
    alter_hold renew renew_all
);

can_ok( $ils, @methods );

is( $ils->institution(), 'CPL', 'institution method returns id' );

is( $ils->institution_id(), 'CPL', 'institution_id method returns id' );

is( $ils->supports('checkout'), 1, 'checkout supported' );

is( $ils->supports('security_inhibit'),
    q{}, 'unsupported feature returns false' );

is( $ils->test_cardnumber_compare( 'A1234', 'a1234' ),
    1, 'borrower bc test is case insensitive' );

is( $ils->test_cardnumber_compare( 'A1234', 'b1234' ),
    q{}, 'borrower bc test identifies difference' );

subtest add_hold => sub {
    plan tests => 4;

    my $library = $builder->build_object(
        {
            class => 'Koha::Libraries',
            value => {
                pickup_location => 1
            }
        }
    );
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv(
        { branchcode => $library->branchcode, flags => 1 } );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            branchcode   => $library->branchcode,
            itemtype     => $item->effective_itemtype,
            rules        => {
                onshelfholds     => 1,
                reservesallowed  => 3,
                holds_per_record => 3,
                issuelength      => 5,
                lengthunit       => 'days',
            }
        }
    );

    my $ils = C4::SIP::ILS->new( { id => $library->branchcode } );

    # Send empty AD segments (i.e. empty string for patron_pwd)
    my $transaction = $ils->add_hold( $patron->cardnumber, "", $item->barcode, undef );
    isnt(
        $transaction->{screen_msg},
        'Invalid patron password.',
        "Empty password succeeds"
    );
    ok( $transaction->{ok}, "Transaction returned success");
    is( $item->biblio->holds->count(), 1, "Hold was placed on bib");
    # FIXME: Should we not allow for item-level holds when we're passed an item barcode...
    is( $item->holds->count(),0,"Hold was placed at bib level");
};

subtest cancel_hold => sub {
    plan tests => 6;

    my $library = $builder->build_object ({ class => 'Koha::Libraries' });
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode, flags => 1 });

    my $item = $builder->build_sample_item({
        library       => $library->branchcode,
    });

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            branchcode   => $library->branchcode,
            itemtype     => $item->effective_itemtype,
            rules        => {
                onshelfholds     => 1,
                reservesallowed  => 3,
                holds_per_record => 3,
                issuelength      => 5,
                lengthunit       => 'days',
            }
        }
    );

    my $reserve1 = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblio->biblionumber,
            itemnumber     => $item->itemnumber,
        }
    );
    is( $item->biblio->holds->count(), 1, "Hold was placed on bib");
    is( $item->holds->count(),1,"Hold was placed on specific item");

    my $ils = C4::SIP::ILS->new({ id => $library->branchcode });
    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $transaction = $ils->cancel_hold($patron->cardnumber,"",$item->barcode,undef);

    isnt( $transaction->{screen_msg}, 'Invalid patron password.', "Empty password succeeds" );
    is( $transaction->{screen_msg},"Hold Cancelled.","We get a success message when hold cancelled");

    is( $item->biblio->holds->count(), 0, "Bib has 0 holds remaining");
    is( $item->holds->count(), 0,  "Item has 0 holds remaining");
};

subtest cancel_waiting_hold => sub {
    plan tests => 7;

    my $library = $builder->build_object ({ class => 'Koha::Libraries' });
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode, flags => 1 });

    my $item = $builder->build_sample_item({
        library => $library->branchcode,
    });

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            branchcode   => $library->branchcode,
            itemtype     => $item->effective_itemtype,
            rules        => {
                onshelfholds     => 1,
                reservesallowed  => 3,
                holds_per_record => 3,
                issuelength      => 5,
                lengthunit       => 'days',
            }
        }
    );

    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblio->biblionumber,
            itemnumber     => $item->itemnumber,
        }
    );
    is( $item->biblio->holds->count(), 1, "Hold was placed on bib");
    is( $item->holds->count(),1,"Hold was placed on specific item");

    my $hold = Koha::Holds->find( $reserve_id );
    ok( $hold, 'Get hold object' );
    $hold->update({ found => 'W' });
    $hold->get_from_storage;

    is( $hold->found, 'W', "Hold was correctly set to waiting." );

    my $ils = C4::SIP::ILS->new({ id => $library->branchcode });
    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $transaction = $ils->cancel_hold($patron->cardnumber,undef,$item->barcode,undef);

    is( $transaction->{screen_msg},"Hold Cancelled.","We get a success message when hold cancelled");

    is( $item->biblio->holds->count(), 0, "Bib has 0 holds remaining");
    is( $item->holds->count(), 0,  "Item has 0 holds remaining");
};

subtest checkout => sub {
    plan tests => 4;

    my $library = $builder->build_object ({ class => 'Koha::Libraries' });
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode, flags => 1 });

    my $item = $builder->build_sample_item({
        library => $library->branchcode,
    });

    Koha::CirculationRules->set_rules(
        {
            categorycode => $patron->categorycode,
            branchcode   => $library->branchcode,
            itemtype     => $item->effective_itemtype,
            rules        => {
                onshelfholds     => 1,
                reservesallowed  => 3,
                holds_per_record => 3,
                issuelength      => 5,
                lengthunit       => 'days',
                renewalsallowed  => 6,
            }
        }
    );

    AddIssue( $patron, $item->barcode, undef, 0 );
    my $checkout = $item->checkout;
    ok( defined($checkout), "Checkout added");
    is( $checkout->renewals_count, 0, "Correct renewals");

    my $ils = C4::SIP::ILS->new({ id => $library->branchcode });
    my $sip_patron = C4::SIP::ILS::Patron->new( $patron->cardnumber );
    my $transaction = $ils->checkout($patron->cardnumber, $item->barcode);

    is( $transaction->{screen_msg},"Item already checked out to you: renewing item.", "We get a success message when issue is renewed");

    $checkout->discard_changes();
    is( $checkout->renewals_count, 1, "Renewals has been reduced");
};

subtest renew_all => sub {
    plan tests => 1;

    my $library = $builder->build_object ({ class => 'Koha::Libraries' });
    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode, flags => 1 });

    my $ils = C4::SIP::ILS->new({ id => $library->branchcode });

    # Send empty AD segments (i.e. empty string for patron_pwd)
    my $transaction = $ils->renew_all( $patron->cardnumber, "", undef );
    isnt( $transaction->{screen_msg}, 'Invalid patron password.', "Empty password succeeds" );
};

subtest renew => sub {
    plan tests => 2;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron  = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode,
            }
        }
    );
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    Koha::CirculationRules->set_rule(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rule_name    => 'renewalsallowed',
            rule_value   => '5',
        }
    );

    my $item = $builder->build_sample_item(
        {
            library => $library->branchcode,
        }
    );

    AddIssue( $patron->unblessed, $item->barcode, undef, 0 );
    my $checkout = $item->checkout;
    ok( defined($checkout), "Successfully checked out an item prior to renewal" );

    my $ils = C4::SIP::ILS->new( { id => $library->branchcode } );

    my $transaction = $ils->renew( $patron->cardnumber, "", $item->barcode );

    is( $transaction->{renewal_ok}, 1, "Renewal succeeded" );

};

$schema->storage->txn_rollback;
