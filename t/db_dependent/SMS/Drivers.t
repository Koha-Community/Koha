#!/usr/bin/env perl

# Copyright Koha-Suomi Oy 2017
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 3;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Letters;

use Koha::Database;
use Koha::Libraries;
use Koha::Notice::Messages;
use Koha::Patrons;

use SMS::Send;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my @check_installed_status = (
    'Labyrintti::Driver',
    'Arena::Driver',
);

subtest 'Ensure driver is installed' => sub {
    plan tests => scalar @check_installed_status * 2;

    my %drivers = map { $_ => 1 } SMS::Send->installed_drivers;
    foreach my $driver (@check_installed_status) {
        use_ok('SMS::Send::'.$driver);
        ok($drivers{$driver}, "$driver is installed.");
    }
};

subtest 'Labyrintti::Driver tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    Koha::Notice::Messages->search->delete;
    my $config = {
        labyrintti => {
            user => 'test',
            passwd => 'test',
            reportUrl => 'test',
            Unicode => 'yes',
            sourceName => 'koha',
        },
    };
    t::lib::Mocks::mock_config('smsProviders', $config);
    t::lib::Mocks::mock_preference('SMSSendDriver', 'Labyrintti::Driver');
    # Mock LWP::Curl->post to forward the POST request to our subroutine instead
    # of actual Labyrintti SMS gateway server
    my $sms_module = new Test::MockModule('LWP::Curl');
    $sms_module->mock(
        'post',
        sub {
            my ($self, $url, $params) = @_;
            return labyrintti_gateway($self, $params);
        }
    );

    my $patron = create_user();
    $patron->smsalertnumber('+3580000000')->store;

    subtest 'Test connection error' => sub {
        plan tests => 2;

        my $notice = create_notice($patron);
        my $message_id = $notice->message_id;

        $notice->content('want_connection_error')->store;
        C4::Letters::SendQueuedMessages();
        $notice = Koha::Notice::Messages->find($message_id);
        is($notice->status, 'pending', 'Status is still pending');
        is($notice->delivery_note, 'Connection failed. Attempting to resend.',
           'Connection was failed and notice has a delivery note for it');
        $notice->status('failed')->store; # However we don't want to resend it now.
    };

    subtest 'Test delivery failure' => sub {
        plan tests => 2;

        my $notice = create_notice($patron);
        my $message_id = $notice->message_id;

        $notice->content('want_delivery_failure')->store;
        C4::Letters::SendQueuedMessages();
        $notice = Koha::Notice::Messages->find($message_id);
        is($notice->status, 'failed', 'Delivery failed');
        is($notice->delivery_note, 'a problem',
           'An appropriate delivery note is stored.');
    };

    subtest 'Test successful delivery' => sub {
        plan tests => 1;

        my $notice = create_notice($patron);
        my $message_id = $notice->message_id;

        C4::Letters::SendQueuedMessages();
        $notice = Koha::Notice::Messages->find($message_id);
        is($notice->status, 'sent', 'Notice was sent');
    };

    $sms_module->unmock('post');
    $schema->storage->txn_rollback;
};

subtest 'Arena::Driver tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    Koha::Notice::Messages->search->delete;

    t::lib::Mocks::mock_preference('SMSSendDriver', 'Arena::Driver');
    # Mock LWP::Curl->post to forward the POST request to our subroutine instead
    # of actual Arena SMS gateway server
    my $sms_module = new Test::MockModule('LWP::Curl');
    $sms_module->mock(
        'post',
        sub {
            my ($self, $url, $params) = @_;
            return arena_gateway($self, $params);
        }
    );

    my $patron = create_user();
    $patron->smsalertnumber('+3580000000')->store;

    my $config = {
        arena => {
            user => 'test',
            passwd => 'test',
            reportUrl => 'test',
            Unicode => 'yes',
            sourceName => 'koha',
            substr($patron->branchcode, 0, 3) => {
                clientid => 'test',
            }
        },
    };
    t::lib::Mocks::mock_config('smsProviders', $config);

    subtest 'Test connection error' => sub {
        plan tests => 2;

        my $notice = create_notice($patron);
        my $message_id = $notice->message_id;

        t::lib::Mocks::mock_config('smsProviders', $config);

        $notice->content('want_connection_error')->store;
        C4::Letters::SendQueuedMessages();
        $notice = Koha::Notice::Messages->find($message_id);
        is($notice->status, 'pending', 'Status is still pending');
        is($notice->delivery_note, 'Connection failed. Attempting to resend.',
           'Connection was failed and notice has a delivery note for it');
        $notice->status('failed')->store; # However we don't want to resend it now.
    };

    subtest 'Test delivery failure' => sub {
        plan tests => 2;

        my $notice = create_notice($patron);
        my $message_id = $notice->message_id;

        $notice->content('want_delivery_failure')->store;
        C4::Letters::SendQueuedMessages();
        $notice = Koha::Notice::Messages->find($message_id);
        is($notice->status, 'failed', 'Delivery failed');
        is($notice->delivery_note, 'a problem',
           'An appropriate delivery note is stored.');
    };

    subtest 'Test successful delivery' => sub {
        plan tests => 1;

        my $notice = create_notice($patron);
        my $message_id = $notice->message_id;

        C4::Letters::SendQueuedMessages();
        $notice = Koha::Notice::Messages->find($message_id);
        is($notice->status, 'sent', 'Notice was sent');
    };

    $sms_module->unmock('post');
    $schema->storage->txn_rollback;
};

sub labyrintti_gateway {
    my ($lwpcurl, $params) = @_;

    # Simulate Labyrintti Gateway response

    if ($params->{text} eq 'want_connection_error') {
        $lwpcurl->{retcode} = 6;
    }
    elsif ($params->{text} eq 'want_delivery_failure') {
        return 'message failed: a problem';
    }

    return 'OK 1';
}

sub arena_gateway {
    my ($lwpcurl, $params) = @_;

    # Simulate Arena Gateway response

    if ($params->{msg} eq 'want_connection_error') {
        $lwpcurl->{retcode} = 6;
    }
    elsif ($params->{msg} eq 'want_delivery_failure') {
        return 'message failed: a problem';
    }

    return '<accepted>';
}

sub create_user {
    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
        }
    });
    return Koha::Patrons->find($borrower->{borrowernumber});
}

sub create_notice {
    my ($patron) = @_;

    my $branch = Koha::Libraries->find($patron->branchcode);

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
            time_queued => '2016-01-01 13:00:00',
            status => 'pending',
            message_transport_type => 'sms',
            from_address => $branch->branchemail,
        }
    });
    return Koha::Notice::Messages->find($notice->{message_id});
}
