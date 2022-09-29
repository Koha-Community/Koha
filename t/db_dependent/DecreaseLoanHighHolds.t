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
use DateTime;

use C4::Circulation qw( CalcDateDue checkHighHolds CanBookBeIssued );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;
use Koha::Biblio;
use Koha::Item;
use Koha::Holds;
use Koha::Hold;
use Koha::CirculationRules;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Test::More tests => 26;

my $dbh    = C4::Context->dbh;
my $schema = Koha::Database->new()->schema();
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin();

my $now_value       = dt_from_string();
my $mocked_datetime = Test::MockModule->new('DateTime');
$mocked_datetime->mock( 'now', sub { return $now_value->clone; } );

my $library  = $builder->build( { source => 'Branch' } );
my $category = $builder->build( { source => 'Category' } );
my $itemtype = $builder->build( { source => 'Itemtype' } )->{itemtype};

t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });
is( C4::Context->userenv->{branch}, $library->{branchcode}, 'userenv set' );

my $patron_category = $builder->build({
    source => 'Category',
    value => {
        category_type => 'P',
        enrolmentfee => 0
    }
});

my @patrons;
for my $i ( 1 .. 20 ) {
    my $patron = Koha::Patron->new({
        firstname => 'Kyle',
        surname => 'Hall',
        categorycode => $category->{categorycode},
        branchcode => $library->{branchcode},
        categorycode => $patron_category->{categorycode},
    })->store();
    push( @patrons, $patron );
}

my $biblio = $builder->build_sample_biblio();

# The biblio gets 10 items
my @items;
for my $i ( 1 .. 10 ) {
    my $item = $builder->build_sample_item(
        {
            biblionumber     => $biblio->id(),
            itype            => $itemtype
        }
    );
    push( @items, $item );
}

# Place 6 holds, patrons 0,1,2,3,4,5
for my $i ( 0 .. 5 ) {
    my $patron = $patrons[$i];
    my $hold   = Koha::Hold->new(
        {
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            branchcode     => $library->{branchcode},
        }
    )->store();
}

my $item   = shift(@items);
my $patron = shift(@patrons);
my $patron_hold = Koha::Holds->find({ borrowernumber => $patron->borrowernumber, biblionumber => $item->biblionumber });

Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => $item->itype,
        rules        => {
            issuelength     => '14',
            lengthunit      => 'days',
            reservesallowed => '99',
            holds_per_record => '99',
            decreaseloanholds => 0,
        }
    }
);

my $orig_due = C4::Circulation::CalcDateDue(
    dt_from_string(),
    $item->effective_itemtype,
    $patron->branchcode,
    $patron
);

t::lib::Mocks::mock_preference( 'decreaseLoanHighHolds',               1 );
t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsDuration',       1 );
t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsValue',          1 );
t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsControl',        'static' );
t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsIgnoreStatuses', 'damaged,itemlost,notforloan,withdrawn' );

my $data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded},        1,          "Static mode should exceed threshold" );
is( $data->{outstanding},     5,          "Should have 5 outstanding holds" );
is( $data->{duration},        0,          "Should have duration of 0 because of specific circulation rules" );
is( ref( $data->{due_date} ), 'DateTime', "due_date should be a DateTime object" );

t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsValue',          5 );
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded},        0,          "Static mode should not exceed threshold when it equals outstanding holds" );
is( $data->{outstanding},     5,          "Should have 5 outstanding holds" );
is( $data->{duration},        0,          "Should have duration of 0 because decrease not calculated" );
is( $data->{due_date},     undef,         "duedate undefined as not decreasing loan period" );
t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsValue',          1 );

Koha::CirculationRules->set_rules(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => $item->itype,
        rules        => {
            issuelength     => '14',
            lengthunit      => 'days',
            reservesallowed => '99',
            holds_per_record => '99',
            decreaseloanholds => undef,
        }
    }
);

$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{duration}, 1, "Should have a duration of 1 because no specific circulation rules so defaults to system preference" );

my $duedate = $data->{due_date};
is($duedate->hour, $orig_due->hour, 'New due hour is equal to original due hour.');
is($duedate->min, $orig_due->min, 'New due minute is equal to original due minute.');
is($duedate->sec, 0, 'New due date second is zero.');

t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsControl', 'dynamic' );
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 0, "Should not exceed threshold" );


# Place 7 more holds - patrons 5,6,7,8,9,10,11
for my $i ( 5 .. 11 ) {
    my $patron = $patrons[$i];
    my $hold   = Koha::Hold->new(
        {
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            branchcode     => $library->{branchcode},
        }
    )->store();
}

# Note in counts below, patron's own hold is not counted

# 12 holds, threshold is 1 over 10 holdable items = 11
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 1, "Should exceed threshold of 1" );
is( $data->{outstanding}, 12, "Should exceed threshold of 1" );

# 12 holds, threshold is 2 over 10 holdable items = 12 (equal is okay)
t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsValue', 2 );
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 0, "Should not exceed threshold of 2" );

my $unholdable = pop(@items);
$unholdable->damaged(-1);
$unholdable->store();

# 12 holds, threshold is 2 over 9 holdable items = 11
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 1, "Should exceed threshold with one damaged item" );

$unholdable->damaged(0);
$unholdable->itemlost(-1);
$unholdable->store();

# 12 holds, threshold is 2 over 9 holdable items = 11
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 1, "Should exceed threshold with one lost item" );

$unholdable->itemlost(0);
$unholdable->notforloan(-1);
$unholdable->store();

# 12 holds, threshold is 2 over 9 holdable items = 11
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 1, "Should exceed threshold with one notforloan item" );

$unholdable->notforloan(0);
$unholdable->withdrawn(-1);
$unholdable->store();

# 12 holds, threshold is 2 over 9 holdable items = 11
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 1, "Should exceed threshold with one withdrawn item" );

$patron_hold->found('F')->store;
# 11 holds, threshold is 2 over 9 holdable items = 11
$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{exceeded}, 1, "Should exceed threshold with one withdrawn item" );
$patron_hold->found(undef)->store;

t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');

my ( undef, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode );
ok( $needsconfirmation->{HIGHHOLDS}, "High holds checkout needs confirmation" );

( undef, $needsconfirmation ) = CanBookBeIssued( $patron, $item->barcode, undef, undef, undef, { override_high_holds => 1 } );
ok( !$needsconfirmation->{HIGHHOLDS}, "High holds checkout does not need confirmation" );

Koha::CirculationRules->set_rule(
    {
        branchcode   => undef,
        categorycode => undef,
        itemtype     => $item->itype,
        rule_name    => 'decreaseloanholds',
        rule_value   => 2,
    }
);

$data = C4::Circulation::checkHighHolds( $item, $patron );
is( $data->{duration}, 2, "Circulation rules override system preferences" );


subtest "Test patron's own holds do not count towards HighHolds count" => sub {

    plan tests => 2;

    my $item = $builder->build_sample_item();
    my $item2 = $builder->build_sample_item({ biblionumber => $item->biblionumber });
    my $item3 = $builder->build_sample_item({ biblionumber => $item->biblionumber });

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => {
            branchcode => $item->homebranch
        }
    });
    my $hold = $builder->build_object({
        class => 'Koha::Holds',
        value => {
            biblionumber => $item->biblionumber,
            borrowernumber => $patron->id,
            suspend => 0,
            found => undef
        }
    });

    Koha::CirculationRules->set_rules(
        {
            branchcode   => $item->homebranch,
            categorycode => undef,
            itemtype     => $item->itype,
            rules        => {
                issuelength     => '14',
                lengthunit      => 'days',
                reservesallowed => '99',
                holds_per_record => '1',
            }
        }
    );

    t::lib::Mocks::mock_preference( 'decreaseLoanHighHolds',               1 );
    t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsDuration',       1 );
    t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsValue',          1 );
    t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsControl',        'static' );
    t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsIgnoreStatuses', 'damaged,itemlost,notforloan,withdrawn' );

    my $data = C4::Circulation::checkHighHolds( $item , $patron );
    ok( !$data->{exceeded}, "Patron's hold on the record does not limit their own circulation if static decrease");
    t::lib::Mocks::mock_preference( 'decreaseLoanHighHoldsControl',        'dynamic' );
    # 3 items on record, patron has 1 hold
    $data = C4::Circulation::checkHighHolds( $item, $patron );
    ok( !$data->{exceeded}, "Patron's hold on the record does not limit their own circulation if dynamic decrease");

};

$schema->storage->txn_rollback();
