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

use Test::More tests => 10;

use DateTime;
use C4::Circulation qw( CanBookBeIssued AddIssue CheckValidBarcode AddReturn );
use C4::Biblio      qw( AddBiblio );
use C4::Items;
use Koha::Database;
use Koha::Library;
use Koha::CirculationRules;
use Koha::DateUtils qw( dt_from_string );
use t::lib::TestBuilder;
use t::lib::Mocks;
use Test::NoWarnings;

my $builder = t::lib::TestBuilder->new;

sub set_userenv {
    my ($library) = @_;
    my $staff = $builder->build_object( { class => "Koha::Patrons" } );
    t::lib::Mocks::mock_userenv( { patron => $staff, branchcode => $library->{branchcode} } );
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Start with a clean slate
$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM biblio|);
$dbh->do(q|DELETE FROM action_logs|);

my $now            = dt_from_string();
my $two_days_later = $now->clone->add( days => 2 );
my $formatted_date = $two_days_later->ymd('');

my $library = $builder->build(
    {
        source => 'Branch',
    }
);

my $patron_category = $builder->build(
    {
        source => 'Category',
        value  => {
            category_type  => 'P',
            noissuescharge => undef,
        }
    }
);

my $patron1 = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

my $biblio = $builder->build_sample_biblio(
    {
        branchcode => $library->{branchcode},
    }
);

my $biblionumber = $biblio->biblionumber;

set_userenv($library);

my ( $error, $question, $alerts, $messages, $message_log );

#Test check out an item that has a “not for loan” status
t::lib::Mocks::mock_preference( 'AllowNotForLoanOverride', 1 );

my $item_1 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
        notforloan   => 1,
    }
);

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron1,
    $item_1->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'item not for loan', 'Item not for loan message displayed' );

#Test check out an item that has a “lost” status
t::lib::Mocks::mock_preference( 'IssueLostItem', 'require confirmation' );

my $item_2 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
        itemlost     => 1,
    }
);

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron1,
    $item_2->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'item lost', 'Item lost message displayed' );

#Test check out an item to a patron who has reached the checkout limit
t::lib::Mocks::mock_preference( 'AllowTooManyOverride', 1 );

Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            maxissueqty         => 0,
            reservesallowed     => 25,
            issuelength         => 14,
            lengthunit          => 'days',
            renewalsallowed     => 1,
            renewalperiod       => 7,
            norenewalbefore     => undef,
            noautorenewalbefore => undef,
            auto_renew          => 0,
            fine                => .10,
            chargeperiod        => 1,
        }
    }
);

my $item_3 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
    }
);

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron1,
    $item_3->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'too many checkout', 'Checkout limit reached message displayed' );

#Test check out an item to a patron who has unpaid fines
t::lib::Mocks::mock_preference( 'AllFinesNeedOverride', 0 );
t::lib::Mocks::mock_preference( 'AllowFineOverride',    1 );
t::lib::Mocks::mock_preference( 'noissuescharge',       5 );
t::lib::Mocks::mock_preference( 'IssuingInProcess',     0 );

$dbh->do(q|DELETE FROM circulation_rules|);

Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => undef,
        rules        => {
            maxissueqty         => 5,
            reservesallowed     => 25,
            issuelength         => 14,
            lengthunit          => 'days',
            renewalsallowed     => 1,
            renewalperiod       => 7,
            norenewalbefore     => undef,
            noautorenewalbefore => undef,
            auto_renew          => 0,
            fine                => .10,
            chargeperiod        => 1,
        }
    }
);

my $patron2 = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

$patron2->account->add_debit(
    {
        amount    => 10,
        interface => C4::Context->interface,
        type      => 'ARTICLE_REQUEST',
    }
);

my $item_4 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
    }
);

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron2,
    $item_4->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'borrower had amend', 'Borrower had amend message displayed' );

#Test check out an item on hold for someone else
my $patron3 = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

my $item_5 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
    }
);

C4::Reserves::AddReserve(
    {
        borrowernumber => $patron3->borrowernumber,
        biblionumber   => $biblionumber,
        itemnumber     => $item_5->itemnumber,
        branchcode     => $library->{branchcode},
    }
);

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron1,
    $item_5->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'item is on reserve for someone else', 'Item on hold by someone else message displayed' );

#Test check out an item that is age-restricted
t::lib::Mocks::mock_preference( 'AgeRestrictionOverride', 1 );
t::lib::Mocks::mock_preference( 'AgeRestrictionMarker',   'PEGI' );

my $patron4 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => 'K',
            dateofbirth  => $formatted_date,
        }
    }
);

my $item_6 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
    }
);

my $biblioitem = $biblio->biblioitem;
$biblioitem->agerestriction('PEGI 6');
$biblioitem->update;

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron4,
    $item_6->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'age restriction', 'Item is age restricted message displayed' );

#Test check out an item already checked out to someone else
t::lib::Mocks::mock_preference( 'AutoReturnCheckedOutItems', 0 );

my $patron5 = $builder->build_object(
    { class => 'Koha::Patrons', value => { categorycode => $patron_category->{categorycode} } } );

my $item_7 = $builder->build_sample_item(
    {
        biblionumber => $biblionumber,
        homebranch   => $patron5->branchcode
    }
);

AddIssue( $patron5, $item_7->barcode );

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron1,
    $item_7->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'item is checked out for someone else', 'Item already checked out message displayed' );

#Test check out to a patron who has restrictions
my $patron6 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $patron_category->{categorycode},
            debarred     => $formatted_date,
        }
    }
);

my $item_8 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
    }
);

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron6,
    $item_8->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'borrower is restricted', 'Borrower is restricted message displayed' );

#Test check out an item to a patron who is not allowed to borrow this item type
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        branchcode   => undef,
        itemtype     => 'BK',
        rules        => {
            maxissueqty         => 5,
            reservesallowed     => 25,
            issuelength         => 14,
            lengthunit          => 'days',
            renewalsallowed     => 1,
            renewalperiod       => 7,
            norenewalbefore     => undef,
            noautorenewalbefore => undef,
            auto_renew          => 0,
            fine                => .10,
            chargeperiod        => 1,
        }
    }
);

my $item_9 = $builder->build_sample_item(
    {
        library      => $library->{branchcode},
        biblionumber => $biblionumber,
    }
);

( $error, $question, $alerts, $messages, $message_log ) = CanBookBeIssued(
    $patron6,
    $item_9->barcode,
    undef,
    undef,
    undef,
    {
        issueconfirmed => 1,
    }
);
is( $message_log->[0], 'borrower is restricted', 'Borrower is restricted for this item type message displayed' );
