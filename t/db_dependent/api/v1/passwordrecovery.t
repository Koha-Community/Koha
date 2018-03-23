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


use Test::More tests => 2;
use Test::Mojo;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Notice::Messages;
use Koha::Notice::Templates;

use Crypt::Eksblowfish::Bcrypt qw(en_base64);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'recovery() tests' => sub {
    plan tests => 35;

    $schema->storage->txn_begin;

    unless(Koha::Notice::Templates->search({
        module => 'members',
        code => 'PASSWORD_RESET'
    })->count) {
        Koha::Notice::Template->new({
            module => 'members',
            code => 'PASSWORD_RESET',
            branchcode => '',
            name => 'PASSWORD_RESET',
            title => 'PASSWORD_RESET',
            content => '<<passwordreseturl>>',
            message_transport_type => 'email',
            lang => 'default',
        })->store;
    }

    my $url = '/api/v1/patrons/password/recovery';

    my ($patron, $session) = create_user_and_session();

    my $tx = $t->ua->build_tx(POST => $url => json => {});
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400);

    t::lib::Mocks::mock_preference('OpacResetPassword', 0);
    t::lib::Mocks::mock_preference('OpacPasswordChange', 0);
    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        cardnumber => $patron->cardnumber
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    t::lib::Mocks::mock_preference('OpacPasswordChange', 1);
    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        cardnumber => $patron->cardnumber
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    t::lib::Mocks::mock_preference('OpacResetPassword', 1);
    t::lib::Mocks::mock_preference('OpacPasswordChange', 0);
    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        cardnumber => $patron->cardnumber
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    t::lib::Mocks::mock_preference('OpacPasswordChange', 1);

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => 'nonexistent',
        cardnumber => $patron->cardnumber
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404);

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        cardnumber => 'nonexistent'
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404);

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => 'nonexistent',
        userid     => $patron->userid
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404);

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        userid     => 'nonexistent'
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404);

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        cardnumber => $patron->cardnumber
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/status' => 1);

    my $rs = Koha::Database->new->schema->resultset('BorrowerPasswordRecovery');
    is(
        $rs->search({ borrowernumber => $patron->borrowernumber })->count, 1,
        'Password modification request found in database'
    );
    $rs->next->set_columns({
        valid_until => '1970-01-01 12:00:00' })->update_or_insert();

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        cardnumber => $patron->cardnumber
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/status' => 1, 'Duplicate expired request regenerated');

    my $notice_content = Koha::Notice::Messages->search({
        borrowernumber => $patron->borrowernumber,
        letter_code => 'PASSWORD_RESET',
        message_transport_type => 'email'
    }, {
        order_by => { '-desc' => 'message_id' }
    })->next->content;
    like($notice_content,
         qr/cgi-bin\/koha\/opac-password-recovery\.pl\?uniqueKey=/,
         'Found Koha OPAC link in email'
    );

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        userid     => $patron->userid
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/status' => 1);

    is(
        $rs->search({ borrowernumber => $patron->borrowernumber })->count, 1,
        'Password modification request found in database'
    );

    $tx = $t->ua->build_tx(POST => $url => json => {
        email      => $patron->email,
        userid     => $patron->userid,
        cardnumber => $patron->cardnumber,
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/status' => 1);

    is(
        $rs->search({ borrowernumber => $patron->borrowernumber })->count, 1,
        'Password modification request found in database'
    );

    my $notice = Koha::Notice::Messages->search({
        borrowernumber => $patron->borrowernumber,
        letter_code => 'PASSWORD_RESET',
        message_transport_type => 'email'
    })->count;
    is($notice, 4, 'Found password reset letters in message queue.');

    subtest 'custom reset link' => sub {
        plan tests => 5;

        t::lib::Mocks::mock_preference(
            'OpacResetPasswordHostWhitelist', ''
        );

        $tx = $t->ua->build_tx(POST => $url => json => {
            email      => $patron->email,
            userid     => $patron->userid,
            complete_url => 'https://notallowed'
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(400);

        t::lib::Mocks::mock_preference(
            'OpacResetPasswordHostWhitelist', 'allowed'
        );

        $tx = $t->ua->build_tx(POST => $url => json => {
            email      => $patron->email,
            userid     => $patron->userid,
            complete_url => 'https://allowed/reset-password.pl?uniqueKey={uuid}'
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(201);

        my $rs = Koha::Database->new->schema->resultset('BorrowerPasswordRecovery');
        my $uuid = quotemeta $rs->search({
            borrowernumber => $patron->borrowernumber
        }, {
            order_by => { '-desc' => 'valid_until' }
        })->next->uuid;
        my $notice_to_external_service = Koha::Notice::Messages->search({
            borrowernumber => $patron->borrowernumber,
            letter_code => 'PASSWORD_RESET',
            message_transport_type => 'email'
        }, {
            order_by => { '-desc' => 'message_id' }
        })->next;
        my $content = $notice_to_external_service->content;
        like(
             $content,
             qr/https:\/\/allowed\/reset-password\.pl\?uniqueKey=$uuid/,
             'Found custom link in email'
        );
    };

    subtest 'skip letter enqueueing' => sub {
        plan tests => 10;

        t::lib::Mocks::mock_preference(
            'OpacResetPasswordHostWhitelist', 'anotherallowed'
        );
        my ($service_borrowernumber, $service_session) = create_user_and_session({
            borrowers => 'get_password_reset_uuid'
        });

        $tx = $t->ua->build_tx(POST => $url => json => {
            email      => $patron->email,
            userid     => $patron->userid,
            complete_url => 'https://anotherallowed/reset-password.pl',
            skip_email => Mojo::JSON->true
        });
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(401);

        $tx = $t->ua->build_tx(POST => $url => json => {
            email      => $patron->email,
            userid     => $patron->userid,
            complete_url => 'https://anotherallowed/reset-password.pl',
            skip_email => Mojo::JSON->true
        });
        $tx->req->cookies({name => 'CGISESSID', value => $session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(403);

        Koha::Notice::Messages->search({
            borrowernumber => $patron->borrowernumber,
            letter_code => 'PASSWORD_RESET',
            message_transport_type => 'email'
        })->delete;

        $tx = $t->ua->build_tx(POST => $url => json => {
            email      => $patron->email,
            userid     => $patron->userid,
            complete_url => 'https://notallowed/reset-password.pl',
            skip_email => Mojo::JSON->true,
        });
        $tx->req->cookies({name => 'CGISESSID', value => $service_session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(400);

        $tx = $t->ua->build_tx(POST => $url => json => {
            email      => $patron->email,
            userid     => $patron->userid,
            complete_url => 'https://anotherallowed/reset-password.pl',
            skip_email => Mojo::JSON->true,
        });
        $tx->req->cookies({name => 'CGISESSID', value => $service_session->id});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(201);
        my $uuid = $rs->search({
            borrowernumber => $patron->borrowernumber
        }, {
            order_by => { '-desc' => 'valid_until' }
        })->next->uuid;
        $t->json_is('/uuid', $uuid);

        is(Koha::Notice::Messages->search({
            borrowernumber => $patron->borrowernumber,
            letter_code => 'PASSWORD_RESET',
            message_transport_type => 'email'
        })->count, 0, 'Email not enqueued');
    };

    $schema->storage->txn_rollback;
};

subtest 'complete_recovery() tests' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $rs = Koha::Database->new->schema->resultset('BorrowerPasswordRecovery');

    my ($patron, $session) = create_user_and_session();
    my $uuid_str;
    do {
        $uuid_str = '$2a$08$'.en_base64(Koha::AuthUtils::generate_salt('weak', 16));
    } while ( substr ( $uuid_str, -1, 1 ) eq '.' );
    my $recovery = $builder->build({
        source => 'BorrowerPasswordRecovery',
        value  => {
            borrowernumber => $patron->borrowernumber,
            uuid => $uuid_str
        }
    });

    my $url = '/api/v1/patrons/password/recovery/complete';

    my $tx = $t->ua->build_tx(POST => $url => json => {});
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400);

    $tx = $t->ua->build_tx(POST => $url.'notfound' => json => {
        uuid                 => $uuid_str,
        new_password         => 'test',
        confirm_new_password => 'test',
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404);

    t::lib::Mocks::mock_preference('minPasswordLength', 4);
    $tx = $t->ua->build_tx(POST => $url => json => {
        uuid                 => $uuid_str,
        new_password         => '1234',
        confirm_new_password => '1234',
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    my $stored_pw = Koha::Patrons->find($patron->borrowernumber)->password;
    is(
      $stored_pw,
       Koha::AuthUtils::hash_password('1234', $stored_pw), 'Password changed'
    );

    $tx = $t->ua->build_tx(POST => $url => json => {
        uuid                 => $uuid_str,
        new_password         => '1234',
        confirm_new_password => '1234',
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404, 'Previous uuid not found');

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
