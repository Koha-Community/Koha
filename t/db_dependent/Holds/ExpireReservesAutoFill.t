#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 3;

use t::lib::Mocks;
use t::lib::TestBuilder;

use MARC::Record;

use C4::Context;
use C4::Biblio;
use C4::Items;
use Koha::Database;
use Koha::Holds;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('C4::Reserves');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $dbh     = C4::Context->dbh;

# Create two random branches
my $library_1 = $builder->build({ source => 'Branch' })->{ branchcode };
my $library_2 = $builder->build({ source => 'Branch' })->{ branchcode };

my $biblio = $builder->build_sample_biblio({ itemtype => 'DUMMY' });
my $biblionumber = $biblio->id;

# Create item instance for testing.
my $itemnumber = $builder->build_sample_item({ library => $library_1, biblionumber => $biblio->biblionumber })->itemnumber;

my $patron_1 = $builder->build( { source => 'Borrower' } );
my $patron_2 = $builder->build( { source => 'Borrower' } );
my $patron_3 = $builder->build( { source => 'Borrower' } );

subtest 'Test automatically canceled expired waiting holds to fill the next hold, without a transfer' => sub {
    plan tests => 10;

    $dbh->do('DELETE FROM reserves');
    $dbh->do('DELETE FROM message_queue');

    # Add a hold on the item for each of our patrons
    my $hold_1 = Koha::Hold->new(
        {
            priority       => 0,
            borrowernumber => $patron_1->{borrowernumber},
            branchcode     => $library_1,
            biblionumber   => $biblionumber,
            itemnumber     => $itemnumber,
            found          => 'W',
            reservedate    => '1900-01-01',
            waitingdate    => '1900-01-01',
            expirationdate => '1900-01-01',
            lowestPriority => 0,
            suspend        => 0,
        }
    )->store();
    my $hold_2 = Koha::Hold->new(
        {
            priority       => 1,
            borrowernumber => $patron_2->{borrowernumber},
            branchcode     => $library_1,
            biblionumber   => $biblionumber,
            itemnumber     => $itemnumber,
            reservedate    => '1900-01-01',
            expirationdate => '9999-01-01',
            lowestPriority => 0,
            suspend        => 0,
        }
    )->store();
    my $hold_3 = Koha::Hold->new(
        {
            priority       => 2,
            borrowernumber => $patron_2->{borrowernumber},
            branchcode     => $library_1,
            biblionumber   => $biblionumber,
            itemnumber     => $itemnumber,
            reservedate    => '1900-01-01',
            expirationdate => '9999-01-01',
            lowestPriority => 0,
            suspend        => 0,
        }
    )->store();

    # Test CancelExpiredReserves
    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );
    t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay',       1 );
    t::lib::Mocks::mock_preference( 'ExpireReservesOnHolidays',     1 );
    t::lib::Mocks::mock_preference( 'ExpireReservesAutoFill',       1 );
    t::lib::Mocks::mock_preference( 'ExpireReservesAutoFillEmail',
        'kyle@example.com' );

    CancelExpiredReserves();

    my $holds = Koha::Holds->search( {}, { order_by => 'priority' } );
    $hold_2 = $holds->next;
    $hold_3 = $holds->next;

    is( $holds->count,     2,   'Found 2 holds' );
    is( $hold_2->priority, 0,   'Next hold in line now has priority of 0' );
    is( $hold_2->found,    'W', 'Next hold in line is now set to waiting' );

    my @messages = $schema->resultset('MessageQueue')
      ->search( { letter_code => 'HOLD_CHANGED' } );
    is( @messages, 1, 'Found 1 message in the message queue' );
    is( $messages[0]->to_address, 'kyle@example.com', 'Message sent to correct email address' );

    $hold_2->expirationdate('1900-01-01')->store();

    CancelExpiredReserves();

    $holds = Koha::Holds->search( {}, { order_by => 'priority' } );
    $hold_3 = $holds->next;

    is( $holds->count,     1,   'Found 1 hold' );
    is( $hold_3->priority, 0,   'Next hold in line now has priority of 0' );
    is( $hold_3->found,    'W', 'Next hold in line is now set to waiting' );

    @messages = $schema->resultset('MessageQueue')
      ->search( { letter_code => 'HOLD_CHANGED' } );
    is( @messages, 2, 'Found 2 messages in the message queue' );
    is( $messages[0]->to_address, 'kyle@example.com', 'Message sent to correct email address' );
};

subtest 'Test automatically canceled expired waiting holds to fill the next hold, with a transfer' => sub {
    plan tests => 5;

    $dbh->do('DELETE FROM reserves');
    $dbh->do('DELETE FROM message_queue');

    # Add a hold on the item for each of our patrons
    my $hold_1 = Koha::Hold->new(
        {
            priority       => 0,
            borrowernumber => $patron_1->{borrowernumber},
            branchcode     => $library_1,
            biblionumber   => $biblionumber,
            itemnumber     => $itemnumber,
            found          => 'W',
            reservedate    => '1900-01-01',
            waitingdate    => '1900-01-01',
            expirationdate => '1900-01-01',
            lowestPriority => 0,
            suspend        => 0,
        }
    )->store();
    my $hold_2 = Koha::Hold->new(
        {
            priority       => 1,
            borrowernumber => $patron_2->{borrowernumber},
            branchcode     => $library_2,
            biblionumber   => $biblionumber,
            itemnumber     => $itemnumber,
            reservedate    => '1900-01-01',
            expirationdate => '9999-01-01',
            lowestPriority => 0,
            suspend        => 0,
        }
    )->store();

    # Test CancelExpiredReserves
    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelay', 1 );
    t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay',       1 );
    t::lib::Mocks::mock_preference( 'ExpireReservesOnHolidays',     1 );
    t::lib::Mocks::mock_preference( 'ExpireReservesAutoFill',       1 );
    t::lib::Mocks::mock_preference( 'ExpireReservesAutoFillEmail',
        'kyle@example.com' );

    CancelExpiredReserves();

    my @holds = Koha::Holds->search( {}, { order_by => 'priority' } );
    $hold_2 = $holds[0];

    is( @holds,            1,   'Found 1 hold' );
    is( $hold_2->priority, 0,   'Next hold in line now has priority of 0' );
    is( $hold_2->found,    'T', 'Next hold in line is now set to in transit' );
    is( $hold_2->branchcode, $library_2, "Next hold in line has correct branchcode" );

    my @messages = $schema->resultset('MessageQueue')
      ->search( { letter_code => 'HOLD_CHANGED' } );
    is( @messages, 1, 'Nessage is generated in the message queue when generating transfer' );
};
