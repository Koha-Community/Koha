#!/usr/bin/env perl

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


use Test::More tests => 8;
use Test::Mojo;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Notice::Messages;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 24;

    $schema->storage->txn_begin;

    Koha::Notice::Messages->delete;

    my ($patron, $session) = create_user_and_session();
    my ($another_patron, undef) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "messages" => "get_message"
    });

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
            time_queued => '2016-01-01 13:00:00'
        }
    });
    my $another_notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $another_patron->borrowernumber,
            time_queued => '2017-01-01 13:00:00'
        }
    });
    my $message_id = $notice->{'message_id'};
    my $another_message_id = $another_notice->{'message_id'};

    my $tx = $t->ua->build_tx(GET => "/api/v1/notices?borrowernumber="
                              .$patron->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/subject' => $notice->{'subject'});

    $tx = $t->ua->build_tx(GET => "/api/v1/notices?borrowernumber="
                              .$another_patron->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(GET => "/api/v1/notices?borrowernumber=-1");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0' => undef);

    $tx = $t->ua->build_tx(GET => "/api/v1/notices?borrowernumber="
                           .$patron->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/subject' => $notice->{'subject'});

    $tx = $t->ua->build_tx(GET => '/api/v1/notices?'
                        .'time_queued_start=2016-12-12 12:00:00');
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/subject' => $another_notice->{'subject'})
      ->json_hasnt('/1');

    $tx = $t->ua->build_tx(GET => '/api/v1/notices?'
                           .'time_queued_end=2016-12-12 12:00:00');
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/subject' => $notice->{'subject'})
      ->json_hasnt('/1');

    $tx = $t->ua->build_tx(GET => '/api/v1/notices?'
    .'time_queued_start=2014-12-12 12:00:00&time_queued_end=2018-01-01 12:00:00');
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/subject' => $notice->{'subject'})
      ->json_is('/1/subject' => $another_notice->{'subject'})
      ->json_hasnt('/2');

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($another_patron, undef) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "messages" => "get_message"
    });

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
        }
    });
    my $another_notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $another_patron->borrowernumber,
        }
    });
    my $message_id = $notice->{'message_id'};
    my $another_message_id = $another_notice->{'message_id'};

    my $tx = $t->ua->build_tx(GET => "/api/v1/notices/$message_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/subject' => $notice->{'subject'});

    $tx = $t->ua->build_tx(GET => "/api/v1/notices/$another_message_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(GET => "/api/v1/notices/$message_id");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/subject' => $notice->{'subject'});

    $schema->storage->txn_rollback;
};

subtest 'post() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "messages" => "create_message"
    });

    my $notice = {
        borrowernumber => 0+$patron->borrowernumber,
        subject => 'Bring milk from the store, please!',
        content => 'Title says it all',
        message_transport_type => 'email',
        status => 'failed',
    };

    my $tx = $t->ua->build_tx(POST => "/api/v1/notices" => json => $notice);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(POST => "/api/v1/notices" => json => $notice);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/subject' => $notice->{'subject'});

    my $msg = Koha::Notice::Messages->search({}, {
        order_by => { '-desc' => 'message_id' }
    })->next;
    is($msg->subject, $notice->{subject}, 'The notice was really added!');

    $schema->storage->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "messages" => "update_message"
    });

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
        }
    });

    my $new_notice = {
        subject => 'Bring milk from the store, please!',
        content => 'Title says it all',
        message_transport_type => 'email',
        status => 'failed',
    };

    my $message_id = $notice->{'message_id'};

    my $tx = $t->ua->build_tx(PUT => "/api/v1/notices/$message_id" =>
                           json => $new_notice);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(PUT => "/api/v1/notices/$message_id" =>
                           json => $new_notice);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/subject' => $new_notice->{'subject'});

    $schema->storage->txn_rollback;
};

subtest 'put() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "messages" => "update_message"
    });

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
        }
    });

    my $new_notice = {
        status => 'pending',
    };

    my $message_id = $notice->{'message_id'};

    my $tx = $t->ua->build_tx(PATCH => "/api/v1/notices/$message_id" =>
                           json => $new_notice);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(PATCH => "/api/v1/notices/$message_id" =>
                           json => $new_notice);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/subject' => $notice->{'subject'})
      ->json_is('/status' => $new_notice->{'status'});

    $schema->storage->txn_rollback;
};

subtest 'resend() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "messages" => "resend_message"
    });

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
            status => 'failed'
        }
    });

    my $message_id = $notice->{'message_id'};

    my $msg = Koha::Notice::Messages->find($message_id);
    is($msg->status, 'failed', 'The notice is in failed status.');

    my $tx = $t->ua->build_tx(POST => "/api/v1/notices/$message_id/resend");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(POST => "/api/v1/notices/$message_id/resend");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(204);

    $msg = Koha::Notice::Messages->find($message_id);
    is($msg->status, 'pending', 'The notice has been set to pending!');

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "messages" => "delete_message"
    });

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
        }
    });

    my $message_id = $notice->{'message_id'};

    my $tx = $t->ua->build_tx(DELETE => "/api/v1/notices/$message_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/notices/$message_id");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(204);

    my $msg = Koha::Notice::Messages->find($message_id);
    is($msg, undef, 'The notice was really deleted!');

    $schema->storage->txn_rollback;
};

subtest 'Notices::Report::labyrintti() tests' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();

    my $notice = $builder->build({
        source => 'MessageQueue',
        value => {
            borrowernumber => $patron->borrowernumber,
        }
    });

    my $labyrintti_config = {
        labyrintti => {
            reportUrlAllowedIPs => ''
        }
    };

    t::lib::Mocks::mock_config('smsProviders', $labyrintti_config);

    my $tx = $t->ua->build_tx(POST => "/api/v1/notices/-1/report/labyrintti"
        => form => { status => 'ERROR', message => 'Landline number' });
    $tx->req->env({REMOTE_ADDR => '100.100.100.100'});
    $t->request_ok($tx)
      ->status_is(401);

    $labyrintti_config = {
        labyrintti => {
            reportUrlAllowedIPs => '127.0.0.1,123.123.123.123'
        }
    };

    t::lib::Mocks::mock_config('smsProviders', $labyrintti_config);

    my $message_id = $notice->{'message_id'};

    $tx = $t->ua->build_tx(POST => "/api/v1/notices/-1/report/labyrintti"
        => form => { status => 'ERROR', message => 'Landline number' });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404);

    # $tx->req->env({ REMOTE_ADDR => '123.123.123.123' }) not working?
    # ..mock $tx->remote_address then.
    my $module = Test::MockModule->new('Mojo::Transaction');
    $module->mock('remote_address', sub {
        my $self = shift;
        return $self->original_remote_address(@_) if @_;
        return '100.100.100.100'
    });
    $tx = $t->ua->build_tx(POST => "/api/v1/notices/-1/report/labyrintti"
        => form => { status => 'ERROR', message => 'Landline number' });
    $tx->req->env({REMOTE_ADDR => '100.100.100.100'});
    $t->request_ok($tx)
      ->status_is(401);
    $module->unmock_all();

    $tx = $t->ua->build_tx(POST => "/api/v1/notices/$message_id/report/labyrintti"
        => form => { status => 'ERROR', message => 'Landline number' });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    my $msg = Koha::Notice::Messages->find($message_id);
    is($msg->status, 'failed', 'Labyrintti reported delivery as failed');
    is($msg->delivery_note, 'Landline number',
       'The correct delivery note was stored');

    t::lib::Mocks::mock_config('smsProviders', {});
    $tx = $t->ua->build_tx(POST => "/api/v1/notices/-1/report/labyrintti"
        => form => { status => 'ERROR', message => 'Landline number' });
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(401);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my ($flags) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            lost         => 0,
        }
    });

    my $session = t::lib::Mocks::mock_session({borrower => $borrower});
    my $patron = Koha::Patrons->find($borrower->{borrowernumber});
    if ( $flags ) {
        Koha::Auth::PermissionManager->grantPermissions($patron, $flags);
    }

    return ($patron, $session);
}
