#!/usr/bin/perl

# This file is part of Koha
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
use utf8;
use Encode;

use Test::More tests => 6;
use Test::MockModule;
use Test::Exception;
use Test::Warn;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::BatchUpdateItem;
use Koha::BackgroundJob::MARCImportCommitBatch;

use t::lib::Mocks;
use t::lib::Mocks::Logger;
use t::lib::TestBuilder;
use t::lib::Koha::BackgroundJob::BatchTest;

my $logger  = t::lib::Mocks::Logger->new;
my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_derived_class() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $job_object = Koha::BackgroundJob->new();
    my $mapping    = $job_object->type_to_class_mapping;

    # pick the first
    my $type = ( keys %{$mapping} )[0];

    my $job = $builder->build_object(
        {
            class => 'Koha::BackgroundJobs',
            value => { type => $type, data => 'Foo' }
        }
    );

    my $derived = $job->_derived_class;

    is( ref($derived), $mapping->{$type}, 'Job object class is correct' );
    ok( $derived->in_storage, 'The object is correctly marked as in storage' );

    $derived->data('Bar')->store->discard_changes;
    $job->discard_changes;

    is_deeply(
        $job->unblessed, $derived->unblessed,
        '_derived_class object refers to the same DB object and can be manipulated as expected'
    );

    $schema->storage->txn_rollback;
};

subtest 'enqueue() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    # Enqueue without args
    throws_ok { Koha::BackgroundJob::BatchUpdateItem->new->enqueue }
    'Koha::Exceptions::BackgroundJob',
        'Enqueue BatchUpdateItem without data throws exception';

    # The following test needs a mock to trigger the exception
    my $mock = Test::MockModule->new('Net::Stomp');
    $mock->mock( 'send_with_receipt', sub { 0 } );
    throws_ok { Koha::BackgroundJob::MARCImportCommitBatch->new->enqueue }
    'Koha::Exceptions::BackgroundJob',
        'Enqueue MARCImportCommitBatch with mock throws exception';
    $mock->unmock('send_with_receipt');

    # FIXME: This all feels we need to do it better...
    my $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2 ] } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,           2,     'Two steps' );
    is( $job->status,         'new', 'Initial status set correctly' );
    is( $job->borrowernumber, undef, 'No userenv, borrowernumber undef' );

    my $interface = C4::Context->interface;
    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );
    my $job_context = {
        number        => $patron->borrowernumber,
        id            => $patron->userid,
        cardnumber    => $patron->cardnumber,
        firstname     => $patron->firstname,
        surname       => $patron->surname,
        branch        => $patron->library->branchcode,
        branchname    => $patron->library->branchname,
        flags         => $patron->flags,
        emailaddress  => $patron->email,
        register_id   => undef,
        register_name => undef,
        shibboleth    => undef,
        desk_id       => undef,
        desk_name     => undef,
        interface     => $interface
    };

    $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2, 3 ] } );
    $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,           3,            'Three steps' );
    is( $job->status,         'new',        'Initial status set correctly' );
    is( $job->borrowernumber, $patron->id,  'Borrowernumber set from userenv' );
    is( $job->queue,          'long_tasks', 'BatchUpdateItem should use the long_tasks queue' );
    is_deeply( $job->json->decode( $job->context ), $job_context, 'Context set from userenv + interface' );

    $schema->storage->txn_rollback;
};

subtest 'start(), step() and finish() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    # FIXME: This all feels we need to do it better...
    my $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2 ] } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->started_on, undef, 'started_on not set yet' );
    is( $job->size,       2,     'Two steps' );

    $job->start;

    isnt( $job->started_on, undef, 'started_on set' );
    is( $job->status, 'started' );
    is( $job->progress, 0, 'No progress yet' );

    $job->step;
    is( $job->progress, 1, 'First step' );
    $job->step;
    is( $job->progress, 2, 'Second step' );
    throws_ok { $job->step; }
    'Koha::Exceptions::BackgroundJob::StepOutOfBounds',
        'Tried to make a forbidden extra step';

    is( $job->progress, 2, 'progress remains unchanged' );

    my $data = { some => 'data' };

    $job->status('cancelled')->store;
    $job->finish($data);

    is( $job->status, 'cancelled', "'finish' leaves 'cancelled' untouched" );
    isnt( $job->ended_on, undef, 'ended_on set' );
    is_deeply( $job->json->decode( $job->data ), $data );

    $job->status('started')->store;
    $job->finish($data);

    is( $job->status, 'finished' );
    isnt( $job->ended_on, undef, 'ended_on set' );
    is_deeply( $job->json->decode( $job->data ), $data );

    throws_ok { $job->start; }
    'Koha::Exceptions::BackgroundJob::InconsistentStatus',
        'Exception thrown trying to start a finished job';

    is( $@->expected_status, 'new' );

    throws_ok { $job->step; }
    'Koha::Exceptions::BackgroundJob::InconsistentStatus',
        'Exception thrown trying to start a finished job';

    is( $@->expected_status, 'started' );

    $schema->storage->txn_rollback;
};

subtest 'process tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    C4::Context->interface('intranet');
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );
    my $job_context = {
        number        => $patron->borrowernumber,
        id            => $patron->userid,
        cardnumber    => $patron->cardnumber,
        firstname     => $patron->firstname,
        surname       => $patron->surname,
        branch        => $patron->library->branchcode,
        branchname    => $patron->library->branchname,
        flags         => $patron->flags,
        emailaddress  => $patron->email,
        register_id   => undef,
        register_name => undef,
        shibboleth    => undef,
        desk_id       => undef,
        desk_name     => undef,
    };

    my $background_job_module = Test::MockModule->new('Koha::BackgroundJob');
    $background_job_module->mock(
        'type_to_class_mapping',
        sub {
            return { batch_test => 't::lib::Koha::BackgroundJob::BatchTest' };
        }
    );

    my $job_id = t::lib::Koha::BackgroundJob::BatchTest->new->enqueue( { size => 10, a => 'aaa', b => 'bbb' } );
    my $job    = Koha::BackgroundJobs->find($job_id);

    C4::Context->interface('opac');
    C4::Context->unset_userenv;
    is( C4::Context->userenv,   undef,  "Userenv unset prior to calling process" );
    is( C4::Context->interface, 'opac', "Interface set to opac prior to calling process" );

    $job->process();
    is_deeply( C4::Context->userenv,   $job_context, "Userenv set from job context on process" );
    is_deeply( C4::Context->interface, 'intranet',   "Interface set from job context on process" );

    # Manually add a job (->new->store) without context
    my $json           = $job->json;                                    # sorry, quickly borrowing your json object
    my $data           = $json->encode( { a => 'a', b => 'b' } );
    my $incomplete_job = t::lib::Koha::BackgroundJob::BatchTest->new(
        {
            status         => 'new',
            size           => 1,
            borrowernumber => $patron->borrowernumber,
            type           => 'batch_test',
            data           => $data,
        }
    )->store;

    $incomplete_job = Koha::BackgroundJobs->find( $incomplete_job->id );
    $incomplete_job->process();
    $logger->warn_is( "A background job didn't have context defined (" . $incomplete_job->id . ")" );

    $schema->storage->txn_rollback;
};

subtest 'decoded_data() and set_encoded_data() tests' => sub {

    plan tests => 8;
    $schema->storage->txn_begin;

    my $job = Koha::BackgroundJob::BatchUpdateItem->new->set_encoded_data(undef);
    is( $job->decoded_data, undef, 'undef is undef' );

    my $data = { some => 'data' };

    $job->set_encoded_data($data);

    is_deeply( $job->json->decode( $job->data ), $data, 'decode what we sent' );
    is_deeply( $job->decoded_data,               $data, 'check with decoded_data' );

    # Let's get some Unicode stuff into the game
    $data = { favorite_Chinese => [ '葑', '癱' ], latin_dancing => [ '¢', '¥', 'á', 'û' ] };
    $job->set_encoded_data($data)->store;

    $job->discard_changes;    # refresh
    is_deeply( $job->decoded_data, $data, 'Deep compare with Unicode data' );

    # To convince you even more
    is( ord( $job->decoded_data->{favorite_Chinese}->[0] ), 33873, 'We still found Unicode \x8451' );
    is( ord( $job->decoded_data->{latin_dancing}->[0] ),    162,   'We still found the equivalent of Unicode \x00A2' );

    # Testing with sending encoded data (which we normally shouldn't do)
    my $utf8_data;
    foreach my $k ( 'favorite_Chinese', 'latin_dancing' ) {
        foreach my $c ( @{ $data->{$k} } ) {
            push @{ $utf8_data->{$k} }, Encode::encode( 'UTF-8', $c );
        }
    }
    $job->set_encoded_data($utf8_data)->store;
    $job->discard_changes;    # refresh
    is_deeply( $job->decoded_data, $utf8_data, 'Deep compare with utf8_data' );

    # Need more evidence?
    is( ord( $job->decoded_data->{favorite_Chinese}->[0] ), 232, 'We still found a UTF8 encoded byte' )
        ;                     # ord does not need substr here

    $schema->storage->txn_rollback;
};

subtest 'connect' => sub {
    plan tests => 2;

    subtest 'JobsNotificationMethod' => sub {
        plan tests => 3;
        t::lib::Mocks::mock_config( 'message_broker', { hostname => 'not_localhost', port => '99999' } );

        t::lib::Mocks::mock_preference( 'JobsNotificationMethod', 'STOMP' );
        my $job;
        warning_like { $job = Koha::BackgroundJob->connect() } qr{Cannot connect to broker};
        is( $job, undef, "Return undef if unable to connect when using stomp" );

        t::lib::Mocks::mock_preference( 'JobsNotificationMethod', 'polling' );
        $job = Koha::BackgroundJob->connect();
        is( $job, undef, "Return undef if using polling" );
    };

    subtest 'wrong credentials' => sub {
        plan tests => 2;
        t::lib::Mocks::mock_preference( 'JobsNotificationMethod', 'STOMP' );

        t::lib::Mocks::mock_config(
            'message_broker',
            { hostname => 'localhost', port => '61613', username => 'guest', password => 'wrong_password' }
        );

        my $job;
        warning_is { $job = Koha::BackgroundJob->connect() }
        q{Cannot connect to broker (Access refused for user 'guest')};
        is( $job, undef, "Return undef if unable to connect when using stomp" );

    };
};
