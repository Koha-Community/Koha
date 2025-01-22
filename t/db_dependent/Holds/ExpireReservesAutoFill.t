#!/usr/bin/perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;

use t::lib::Mocks;
use t::lib::TestBuilder;

use MARC::Record;

use C4::Context;
use C4::Biblio;
use C4::Items;
use Koha::Database;
use Koha::Holds;
use Koha::Notice::Messages;

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
my $branch_1 = $builder->build_object(
    {
        class => 'Koha::Libraries',
        value => {
            branchemail   => 'branch1@e.mail',
            branchreplyto => 'branch1@reply.to'
        }
    }
);
my $library_1 = $branch_1->branchcode;
my $branch_2  = $builder->build_object(
    {
        class => 'Koha::Libraries',
        value => {
            branchemail   => 'branch2@e.mail',
            branchreplyto => 'branch2@reply.to'
        }
    }
);
my $library_2 = $branch_2->branchcode;

subtest 'Test automatically canceled expired waiting holds to fill the next hold, without a transfer' => sub {
    plan tests => 12;

    my $item         = $builder->build_sample_item( { library => $library_1 } );
    my $biblionumber = $item->biblionumber;
    my $itemnumber   = $item->itemnumber;

    my $patron_1 = $builder->build( { source => 'Borrower' } );
    my $patron_2 = $builder->build( { source => 'Borrower' } );
    my $patron_3 = $builder->build( { source => 'Borrower' } );

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
            borrowernumber => $patron_3->{borrowernumber},
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
    t::lib::Mocks::mock_preference(
        'ExpireReservesAutoFillEmail',
        'kyle@example.com'
    );

    $hold_1->cancel( { autofill => 1 } );

    my $holds = Koha::Holds->search( { biblionumber => $biblionumber }, { order_by => 'priority' } );
    $hold_2 = $holds->next;
    $hold_3 = $holds->next;

    is( $holds->count,     2,   'Found 2 holds' );
    is( $hold_2->priority, 0,   'Next hold in line now has priority of 0' );
    is( $hold_2->found,    'W', 'Next hold in line is now set to waiting' );

    my $messages = Koha::Notice::Messages->search(
        {
            letter_code    => 'HOLD_CHANGED',
            borrowernumber => $patron_2->{borrowernumber}
        }
    );
    is( $messages->count, 1, 'Found message in the message queue with  borrower 2 as the object' );
    my $message = $messages->next;
    is( $message->to_address,   'kyle@example.com',     'Message sent to correct email address' );
    is( $message->from_address, $branch_1->branchemail, "Message is sent from library's email" );

    $hold_2->cancel( { autofill => 1 } );

    $holds  = Koha::Holds->search( { biblionumber => $biblionumber }, { order_by => 'priority' } );
    $hold_3 = $holds->next;

    is( $holds->count,     1,   'Found 1 hold' );
    is( $hold_3->priority, 0,   'Next hold in line now has priority of 0' );
    is( $hold_3->found,    'W', 'Next hold in line is now set to waiting' );

    $messages = Koha::Notice::Messages->search(
        {
            letter_code    => 'HOLD_CHANGED',
            borrowernumber => $patron_3->{borrowernumber}
        }
    );
    is( $messages->count, 1, 'Found message with borrower 3 as the object' );
    $message = $messages->next;
    is( $message->to_address,   'kyle@example.com',     'Message sent to correct email address' );
    is( $message->from_address, $branch_1->branchemail, "Message is sent from library's email" );
};

subtest 'Test automatically canceled expired waiting holds to fill the next hold, with a transfer' => sub {
    plan tests => 7;

    my $item         = $builder->build_sample_item( { library => $library_1 } );
    my $biblionumber = $item->biblionumber;
    my $itemnumber   = $item->itemnumber;

    my $patron_1 = $builder->build( { source => 'Borrower' } );
    my $patron_2 = $builder->build( { source => 'Borrower' } );
    my $patron_3 = $builder->build( { source => 'Borrower' } );

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
    t::lib::Mocks::mock_preference( 'ExpireReservesAutoFillEmail',  '' );

    $hold_1->cancel( { autofill => 1 } );

    my @holds = Koha::Holds->search( { biblionumber => $biblionumber }, { order_by => 'priority' } )->as_list;
    $hold_2 = $holds[0];

    is( @holds,              1,          'Found 1 hold' );
    is( $hold_2->priority,   0,          'Next hold in line now has priority of 0' );
    is( $hold_2->found,      'T',        'Next hold in line is now set to in transit' );
    is( $hold_2->branchcode, $library_2, "Next hold in line has correct branchcode" );

    my $messages = Koha::Notice::Messages->search(
        {
            letter_code    => 'HOLD_CHANGED',
            borrowernumber => $patron_2->{borrowernumber}
        }
    );
    is( $messages->count, 1, 'Message is generated in the message queue when generating transfer' );
    my $message = $messages->next;

    # Is the below correct? Email of changed hold is sent to the receiving library
    # how does the sending library know to remove book from the holds shelf?
    is(
        $message->to_address, $branch_2->branchreplyto,
        "Message is sent to the incoming email of the library with the next hold"
    );
    is( $message->from_address, $branch_2->branchemail, "Message is sent from library's email" );
};

$schema->storage->txn_rollback;
