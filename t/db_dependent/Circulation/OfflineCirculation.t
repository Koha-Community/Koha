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

use Test::NoWarnings;
use Test::More tests => 4;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Biblio      qw( AddBiblio );
use C4::Circulation qw( AddOfflineOperation ProcessOfflineOperation GetOfflineOperation ProcessOfflineIssue );
use C4::Context;
use C4::Reserves    qw( AddReserve );
use Koha::DateUtils qw( dt_from_string );

use MARC::Record;

# Mock userenv, used by AddIssue
my $branch;
my $manager_id;
my $context = Test::MockModule->new('C4::Context');
$context->mock(
    'userenv',
    sub {
        return {
            branch    => $branch,
            number    => $manager_id,
            firstname => "Adam",
            surname   => "Smaith"
        };
    }
);

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new();

subtest "Bug 34529: Offline circulation should be able to accept userid as well as cardnumber" => sub {

    plan tests => 2;

    $dbh->do("DELETE FROM pending_offline_operations");

    $branch = $builder->build( { source => 'Branch' } )->{branchcode};

    my $borrower1 = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $branch }
        }
    );

    my $biblio = t::lib::TestBuilder->new->build_sample_biblio;
    my $item1  = $builder->build_sample_item(
        {
            biblionumber => $biblio->id,
            library      => $branch,
        }
    );
    my $item2 = $builder->build_sample_item(
        {
            biblionumber => $biblio->id,
            library      => $branch,
        }
    );

    my ( $message, $checkout ) = ProcessOfflineIssue(
        {
            cardnumber => $borrower1->{cardnumber},
            barcode    => $item1->barcode
        }
    );

    is(
        $message, "Success.",
        "ProcessOfflineIssue succeeds with cardnumber"
    );

    ( $message, $checkout ) = ProcessOfflineIssue( { cardnumber => $borrower1->{userid}, barcode => $item2->barcode } );
    is(
        $message,
        "Success.",
        "ProcessOfflineIssue succeeds with user id"
    );

};

subtest "Bug 30114 - Koha offline circulation will always cancel the next hold when issuing item to a patron" => sub {

    plan tests => 3;

    $dbh->do("DELETE FROM pending_offline_operations");

    # Set item-level item types
    t::lib::Mocks::mock_preference( "item-level_itypes", 1 );

    # Create a branch
    $branch = $builder->build( { source => 'Branch' } )->{branchcode};

    # Create a borrower
    my $borrower1 = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $branch }
        }
    );

    my $borrower2 = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $branch }
        }
    );

    my $borrower3 = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $branch }
        }
    );

    # Look for the defined MARC field for biblio-level itemtype
    my $rs = $schema->resultset('MarcSubfieldStructure')->search(
        {
            frameworkcode => '',
            kohafield     => 'biblioitems.itemtype'
        }
    );
    my $tagfield    = $rs->first->tagfield;
    my $tagsubfield = $rs->first->tagsubfield;

    # Create a biblio record with biblio-level itemtype
    my $record = MARC::Record->new();
    my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );
    my $itype = $builder->build( { source => 'Itemtype' } );
    my $item  = $builder->build_sample_item(
        {
            biblionumber => $biblionumber,
            library      => $branch,
            itype        => $itype->{itemtype},
        }
    );

    AddReserve(
        {
            branchcode     => $branch,
            borrowernumber => $borrower1->{borrowernumber},
            biblionumber   => $biblionumber,
            priority       => 1,
            itemnumber     => $item->id,
        }
    );

    AddReserve(
        {
            branchcode     => $branch,
            borrowernumber => $borrower2->{borrowernumber},
            biblionumber   => $biblionumber,
            priority       => 2,
            itemnumber     => $item->id,
        }
    );

    my $now = dt_from_string->truncate( to => 'minute' );
    AddOfflineOperation(
        $borrower3->{borrowernumber}, $borrower3->{branchcode}, $now, 'issue', $item->barcode,
        $borrower3->{cardnumber}
    );

    my $offline_rs = Koha::Database->new()->schema()->resultset('PendingOfflineOperation')->search();
    is( $offline_rs->count, 1, "Found one pending offline operation" );

    is( Koha::Holds->search( { biblionumber => $biblionumber } )->count, 2, "Found two holds for the record" );

    my $op = GetOfflineOperation( $offline_rs->next->id );

    my ($ret) = ProcessOfflineOperation($op);

    is( Koha::Holds->search( { biblionumber => $biblionumber } )->count, 2, "Still found two holds for the record" );
};

subtest "Bug 32934: ProcessOfflineIssue returns checkout object for SIP no block due date" => sub {
    plan tests => 4;

    $branch     = $builder->build( { source => 'Branch' } )->{branchcode};
    $manager_id = $builder->build( { source => 'Borrower' } )->{borrowernumber};

    my $borrower = $builder->build(
        {
            source => 'Borrower',
            value  => { branchcode => $branch }
        }
    );

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item(
        {
            biblionumber => $biblio->id,
            library      => $branch,
        }
    );

    my $due_date = dt_from_string->add( days => 7 )->ymd;

    # Test ProcessOfflineIssue returns both message and checkout object
    my ( $message, $checkout ) = ProcessOfflineIssue(
        {
            cardnumber => $borrower->{cardnumber},
            barcode    => $item->barcode,
            due_date   => $due_date,
            timestamp  => dt_from_string
        }
    );

    is( $message, "Success.", "ProcessOfflineIssue returns success message" );
    isa_ok( $checkout, 'Koha::Checkout', "ProcessOfflineIssue returns checkout object" );
    is( $checkout->borrowernumber,                  $borrower->{borrowernumber}, "Checkout has correct borrower" );
    is( dt_from_string( $checkout->date_due )->ymd, $due_date, "Checkout respects specified due_date" );
};

$schema->storage->txn_rollback;
