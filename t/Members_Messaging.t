#!/usr/bin/perl
#
# Test GetPatronMessagingPreferences and SetMessagingPreference
#

use strict;
use warnings;

use Test::NoWarnings;
use Test::More tests => 11;

use t::lib::TestBuilder;
use Koha::Database;
use C4::Members::Messaging qw( SetMessagingPreference GetPatronMessagingPreferences );

BEGIN {
    use_ok('C4::Members::Messaging');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# Tests 1-9: Basic functionality tests
# These tests verify that GetPatronMessagingPreferences and SetMessagingPreference
# correctly store and retrieve data. BorrowersLog preference is NOT enabled for these
# tests as they are testing core data persistence, not logging behavior.

subtest 'GetPatronMessagingPreferences returns empty hash when no preference exists' => sub {
    plan tests => 1;

    $schema->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $message_attribute    = $builder->build( { source => 'MessageAttribute' } );
    my $message_attribute_id = $message_attribute->{message_attribute_id};

    my $pref = GetPatronMessagingPreferences( $patron_id, $message_attribute_id );
    is_deeply( $pref, {}, 'Empty hash returned when no preference set' );

    $schema->txn_rollback;
};

subtest 'GetPatronMessagingPreferences returns preference data when changed' => sub {
    plan tests => 1;

    $schema->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $message_attribute    = $builder->build( { source => 'MessageAttribute' } );
    my $message_attribute_id = $message_attribute->{message_attribute_id};

    $builder->build( { source => 'MessageTransport', value => { message_attribute_id => $message_attribute_id } } );

    # Create preference with metadata and transport
    my $built_pref = $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $message_attribute_id,
                wants_digest         => 1,
                days_in_advance      => 5
            }
        }
    );

    $builder->build(
        {
            source => 'BorrowerMessageTransportPreference',
            value  => {
                borrower_message_preference_id => $built_pref->{borrower_message_preference_id},
                message_transport_type         => 'email'
            }
        }
    );

    my $pref = GetPatronMessagingPreferences( $patron_id, $message_attribute_id );
    ok( keys %{$pref}, 'Preference data returned' );

    $schema->txn_rollback;
};

subtest 'SetMessagingPreference detects transport changes' => sub {
    plan tests => 1;

    $schema->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $message_attribute    = $builder->build( { source => 'MessageAttribute' } );
    my $message_attribute_id = $message_attribute->{message_attribute_id};

    $builder->build( { source => 'MessageTransport', value => { message_attribute_id => $message_attribute_id } } );

    # Create initial preference without transport
    $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $message_attribute_id,
                wants_digest         => 0,
                days_in_advance      => undef
            }
        }
    );

    # Add transport
    SetMessagingPreference(
        {
            borrowernumber          => $patron_id,
            message_attribute_id    => $message_attribute_id,
            message_transport_types => ['email']
        }
    );

    my $pref = GetPatronMessagingPreferences( $patron_id, $message_attribute_id );
    is( $pref->{transports}->[0], 'email', 'Transport added' );

    $schema->txn_rollback;
};

subtest 'SetMessagingPreference detects metadata changes' => sub {
    plan tests => 2;

    $schema->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $message_attribute    = $builder->build( { source => 'MessageAttribute' } );
    my $message_attribute_id = $message_attribute->{message_attribute_id};

    $builder->build( { source => 'MessageTransport', value => { message_attribute_id => $message_attribute_id } } );

    # Create initial preference
    $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $message_attribute_id,
                wants_digest         => 0,
                days_in_advance      => undef
            }
        }
    );

    # Update metadata
    SetMessagingPreference(
        {
            borrowernumber          => $patron_id,
            message_attribute_id    => $message_attribute_id,
            message_transport_types => ['email'],
            wants_digest            => 1,
            days_in_advance         => 7
        }
    );

    my $pref = GetPatronMessagingPreferences( $patron_id, $message_attribute_id );
    is( $pref->{wants_digest},    1, 'wants_digest changed' );
    is( $pref->{days_in_advance}, 7, 'days_in_advance changed' );

    $schema->txn_rollback;
};

subtest 'GetPatronMessagingPreferences tracks digest support separately from row values' => sub {
    plan tests => 2;

    $schema->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $plain_message_attribute    = $builder->build( { source => 'MessageAttribute' } );
    my $plain_message_attribute_id = $plain_message_attribute->{message_attribute_id};
    $builder->build(
        {
            source => 'MessageTransport',
            value  => {
                message_attribute_id   => $plain_message_attribute_id,
                message_transport_type => 'email',
                is_digest              => 0,
            }
        }
    );
    $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $plain_message_attribute_id,
                wants_digest         => 0,
                days_in_advance      => undef,
            }
        }
    );

    my $plain_pref = GetPatronMessagingPreferences( $patron_id, $plain_message_attribute_id );
    is( $plain_pref->{has_digest}, 0, 'non-digest message is flagged as digest-disabled' );

    my $digest_message_attribute    = $builder->build( { source => 'MessageAttribute' } );
    my $digest_message_attribute_id = $digest_message_attribute->{message_attribute_id};
    $builder->build(
        {
            source => 'MessageTransport',
            value  => {
                message_attribute_id   => $digest_message_attribute_id,
                message_transport_type => 'email',
                is_digest              => 1,
            }
        }
    );
    $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $digest_message_attribute_id,
                wants_digest         => 1,
                days_in_advance      => 7,
            }
        }
    );

    my $digest_pref = GetPatronMessagingPreferences( $patron_id, $digest_message_attribute_id );
    is( $digest_pref->{has_digest}, 1, 'digest-capable message is flagged as digest-enabled' );

    $schema->txn_rollback;
};

subtest 'GetPatronMessagingPreferences tracks takes_days support separately from row values' => sub {
    plan tests => 2;

    $schema->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $no_days_message_attribute = $builder->build( { source => 'MessageAttribute', value => { takes_days => 0 } } );
    my $no_days_message_attribute_id = $no_days_message_attribute->{message_attribute_id};
    $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $no_days_message_attribute_id,
                wants_digest         => 0,
                days_in_advance      => undef,
            }
        }
    );
    my $no_days_pref = GetPatronMessagingPreferences( $patron_id, $no_days_message_attribute_id );
    is( $no_days_pref->{takes_days}, 0, 'non-day-based message is flagged as not taking days' );

    my $days_message_attribute    = $builder->build( { source => 'MessageAttribute', value => { takes_days => 1 } } );
    my $days_message_attribute_id = $days_message_attribute->{message_attribute_id};
    $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $days_message_attribute_id,
                wants_digest         => 0,
                days_in_advance      => 3,
            }
        }
    );
    my $days_pref = GetPatronMessagingPreferences( $patron_id, $days_message_attribute_id );
    is( $days_pref->{takes_days}, 1, 'day-based message is flagged as taking days' );

    $schema->txn_rollback;
};

subtest 'SetMessagingPreference deletes existing preference when transport list is empty' => sub {
    plan tests => 2;

    $schema->txn_begin;

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $message_attribute    = $builder->build( { source => 'MessageAttribute' } );
    my $message_attribute_id = $message_attribute->{message_attribute_id};

    $builder->build(
        {
            source => 'BorrowerMessagePreference',
            value  => {
                borrowernumber       => $patron_id,
                message_attribute_id => $message_attribute_id,
                wants_digest         => 1,
                days_in_advance      => 7,
            }
        }
    );

    SetMessagingPreference(
        {
            borrowernumber          => $patron_id,
            message_attribute_id    => $message_attribute_id,
            message_transport_types => [],
            wants_digest            => 0,
            days_in_advance         => undef,
        }
    );

    my $pref = GetPatronMessagingPreferences( $patron_id, $message_attribute_id );
    is_deeply( $pref, {}, 'empty transport lists delete the existing preference' );

    my $after = GetPatronMessagingPreferences( $patron_id, $message_attribute_id );
    is_deeply( $after, {}, 'no preference remains after clearing all transports' );

    $schema->txn_rollback;
};

# Tests 10-13: Logging behavior tests
# These tests verify that SetMessagingPreference correctly logs changes when the
# BorrowersLog system preference is enabled. BorrowersLog MUST be enabled for these
# tests to verify that logging occurs as expected when data changes.

subtest 'SetMessagingPreference logs undef for removed digest and days values' => sub {
    plan tests => 4;

    $schema->txn_begin;

    # Enable BorrowersLog to test logging behavior
    require t::lib::Mocks;
    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $message_attribute = $builder->build(
        {
            source => 'MessageAttribute',
            value  => { message_name => 'Test_Message', takes_days => 1 },
        }
    );
    my $message_attribute_id = $message_attribute->{message_attribute_id};
    $builder->build(
        {
            source => 'MessageTransport',
            value  => {
                message_attribute_id   => $message_attribute_id,
                message_transport_type => 'email',
                is_digest              => 1,
            },
        }
    );

    my @calls;
    {
        no warnings 'redefine';

        # Mock logaction to capture all logged changes, including before and after values
        local *C4::Members::Messaging::logaction = sub {
            my ( $module, $action, $borrowernumber, $updated, $extra, $original ) = @_;
            push @calls, { updated => $updated, original => $original };
        };

        SetMessagingPreference(
            {
                borrowernumber          => $patron_id,
                message_attribute_id    => $message_attribute_id,
                message_transport_types => ['email'],
                wants_digest            => 1,
                days_in_advance         => 7,
            }
        );

        SetMessagingPreference(
            {
                borrowernumber          => $patron_id,
                message_attribute_id    => $message_attribute_id,
                message_transport_types => [],
                wants_digest            => 0,
                days_in_advance         => undef,
            }
        );
    }

    is( scalar(@calls), 2, 'Correct number of log entries when logging is enabled' );
    my $last_call = $calls[-1];
    is( $last_call->{updated}{'Test_Message.wants_digest'},    undef, 'removed wants_digest is logged as undef' );
    is( $last_call->{updated}{'Test_Message.days_in_advance'}, undef, 'removed days_in_advance is logged as undef' );
    is( $last_call->{original}{'Test_Message.wants_digest'},   1,     'removed wants_digest original value logged' );

    $schema->txn_rollback;
};

subtest 'No logging when preference values do not change' => sub {
    plan tests => 1;

    $schema->txn_begin;

    # Enable BorrowersLog to test that logging is NOT triggered when values don't change
    require t::lib::Mocks;
    t::lib::Mocks::mock_preference( 'BorrowersLog', 1 );

    my $patron    = $builder->build( { source => 'Borrower' } );
    my $patron_id = $patron->{borrowernumber};

    my $message_attribute = $builder->build(
        {
            source => 'MessageAttribute',
            value  => { message_name => 'Test_NoChange', takes_days => 1 },
        }
    );
    my $message_attribute_id = $message_attribute->{message_attribute_id};
    $builder->build(
        {
            source => 'MessageTransport',
            value  => {
                message_attribute_id   => $message_attribute_id,
                message_transport_type => 'email',
                is_digest              => 1,
            },
        }
    );

    my @calls;
    {
        no warnings 'redefine';

        # Mock logaction to capture all logged changes, including before and after values
        local *C4::Members::Messaging::logaction = sub {
            my ( $module, $action, $borrowernumber, $updated, $extra, $original ) = @_;
            push @calls, { updated => $updated, original => $original };
        };

        # First call: set initial values
        SetMessagingPreference(
            {
                borrowernumber          => $patron_id,
                message_attribute_id    => $message_attribute_id,
                message_transport_types => ['email'],
                wants_digest            => 1,
                days_in_advance         => 7,
            }
        );

        # Second call: set the SAME values (no change)
        SetMessagingPreference(
            {
                borrowernumber          => $patron_id,
                message_attribute_id    => $message_attribute_id,
                message_transport_types => ['email'],
                wants_digest            => 1,
                days_in_advance         => 7,
            }
        );
    }

    is( scalar(@calls), 1, 'Only first change is logged, second identical call produces no log' );

    $schema->txn_rollback;
};
