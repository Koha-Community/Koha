#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 5;
use C4::Context;

use C4::Biblio;
use C4::Members;
use C4::Branch;
use C4::Circulation;
use C4::Items;
use C4::Context;

use Koha::DateUtils qw( dt_from_string );
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

our $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM branch_item_rules|);
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM branch_borrower_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_circ_rules|);
$dbh->do(q|DELETE FROM default_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_item_rules|);
$dbh->do(q|DELETE FROM issuingrules|);

my $builder = t::lib::TestBuilder->new();

my $branch = $builder->build({
    source => 'Branch',
});

my $patron = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $branch->{branchcode},
    },
});

my $biblio = $builder->build({
    source => 'Biblio',
    value => {
        branchcode => $branch->{branchcode},
    },
});
my $item = $builder->build({
    source => 'Item',
    value => {
        biblionumber => $biblio->{biblionumber},
        homebranch => $branch->{branchcode},
        holdingbranch => $branch->{branchcode},
    },
});

my $issuingrule = $builder->build({
    source => 'Issuingrule',
    value => {
        branchcode         => $branch->{branchcode},
        categorycode       => '*',
        itemtype           => '*',
        maxissueqty        => 2,
        maxonsiteissueqty  => 1,
        lengthunit         => 'days',
        issuelength        => 5,
    },
});

C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv($patron->{borrowernumber}, $patron->{userid}, 'usercnum', 'First name', 'Surname', $branch->{branchcode}, 'My Library', 0);

# Add onsite checkout
C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string, undef, dt_from_string, undef, { onsite_checkout => 1 } );

my ( $impossible, $messages );
t::lib::Mocks::mock_preference('SwitchOnSiteCheckouts', 0);
( $impossible, undef, undef, $messages ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
is( $impossible->{NO_RENEWAL_FOR_ONSITE_CHECKOUTS}, 1, '' );

t::lib::Mocks::mock_preference('SwitchOnSiteCheckouts', 1);
( undef, undef, undef, $messages ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
is( $messages->{ONSITE_CHECKOUT_WILL_BE_SWITCHED}, 1, '' );
C4::Circulation::AddIssue( $patron, $item->{barcode}, undef, undef, undef, undef, { switch_onsite_checkout => 1 } );
my $issue = C4::Circulation::GetItemIssue( $item->{itemnumber} );
is( $issue->{onsite_checkout}, 0, '' );
my $five_days_after = dt_from_string->add( days => 5 )->set( hour => 23, minute => 59, second => 0 );
is( $issue->{date_due}, $five_days_after );

# Specific case
t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
my $another_item = $builder->build({
    source => 'Item',
    value => {
        biblionumber => $biblio->{biblionumber},
        homebranch => $branch->{branchcode},
        holdingbranch => $branch->{branchcode},
    },
});

C4::Circulation::AddIssue( $patron, $another_item->{barcode}, dt_from_string, undef, dt_from_string, undef, { onsite_checkout => 1 } );
( undef, undef, undef, $messages ) = C4::Circulation::CanBookBeIssued( $patron, $another_item->{barcode} );
is( $messages->{ONSITE_CHECKOUT_WILL_BE_SWITCHED}, 1, '' );

$schema->storage->txn_rollback;

1;
