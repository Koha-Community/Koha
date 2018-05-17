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


use Test::More tests => 2;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Notice::Templates;
use Koha::Patron::Message::Preferences;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 34;

    $schema->storage->txn_begin;

    my $path = '/api/v1/messaging_preferences';

    my ($patron, $session) = create_user_and_session();
    my $borrowernumber = $patron->borrowernumber;
    my $categorycode   = $patron->categorycode;
    my ($another_patron, undef) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        flags => 16
    });
    my ($preference, $mtt1, $mtt2) = build_a_test_complete_preference({
        patron => $patron
    });
    my ($preference2, $mtt1_2, $mtt2_2) = build_a_test_category_preference({
        patron => $patron
    });

    t::lib::Mocks::mock_preference('EnhancedMessagingPreferences', 1);
    my $tx = $t->ua->build_tx(GET => $path);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(401);

    $tx = $t->ua->build_tx(GET => "$path?borrowernumber="
                           .$another_patron->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(GET => "$path?categorycode=$categorycode");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(GET => $path);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is('/error', 'Patron or category not found');

    t::lib::Mocks::mock_preference('EnhancedMessagingPreferences', 0);
    $tx = $t->ua->build_tx(GET => "$path?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_is('/error' => 'Enhanced messaging preferences are not enabled');
    t::lib::Mocks::mock_preference('EnhancedMessagingPreferences', 1);

    $tx = $t->ua->build_tx(GET => "$path?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_has('/'.$preference->message_name);

    $tx = $t->ua->build_tx(GET => "$path?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_has('/'.$preference->message_name)
      ->json_has('/'.$preference2->message_name)
      ->json_is('/'.$preference->message_name.'/transport_types/'
                .$mtt1->message_transport_type => Mojo::JSON->true)
      ->json_is('/'.$preference->message_name.'/transport_types/'
                .$mtt2->message_transport_type => Mojo::JSON->true)
      ->json_is('/'.$preference->message_name.'/days_in_advance/configurable'
                => Mojo::JSON->false)
      ->json_is('/'.$preference->message_name.'/days_in_advance/value'
                => undef)
      ->json_is('/'.$preference->message_name.'/digest/configurable'
                => Mojo::JSON->false)
      ->json_is('/'.$preference->message_name.'/digest/value'
                => Mojo::JSON->false);

    $tx = $t->ua->build_tx(GET => "$path?categorycode=$categorycode");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_has('/'.$preference->message_name)
      ->json_has('/'.$preference2->message_name)
      ->json_is('/'.$preference2->message_name.'/transport_types/'
                .$mtt1_2->message_transport_type => Mojo::JSON->true)
      ->json_is('/'.$preference2->message_name.'/transport_types/'
                .$mtt2_2->message_transport_type => Mojo::JSON->true)
      ->json_is('/'.$preference2->message_name.'/days_in_advance/configurable'
                => Mojo::JSON->false)
      ->json_is('/'.$preference2->message_name.'/days_in_advance/value'
                => undef)
      ->json_is('/'.$preference2->message_name.'/digest/value'
                => Mojo::JSON->false);

    $schema->storage->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 29;

    $schema->storage->txn_begin;

    my $path = '/api/v1/messaging_preferences';

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        flags => 16
    });
    my ($another_patron, undef) = create_user_and_session();
    my $borrowernumber = $patron->borrowernumber;
    my $categorycode   = $patron->categorycode;
    my ($preference, $mtt1, $mtt2) = build_a_test_complete_preference({
        patron => $patron
    });
    my ($preference2, $mtt1_2, $mtt2_2) = build_a_test_category_preference({
        patron => $patron
    });

    my $edited_preference = {
        $preference->message_name => {
            digest => {
                value => Mojo::JSON->true
            },
            days_in_advance => {
                value => 15
            },
            transport_types => {
                $mtt1->message_transport_type => Mojo::JSON->true,
                $mtt2->message_transport_type => Mojo::JSON->false
            }
        }
    };

    t::lib::Mocks::mock_preference('EnhancedMessagingPreferences', 1);
    my $tx = $t->ua->build_tx(PUT => $path => json => $edited_preference);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(401);

    $tx = $t->ua->build_tx(PUT => "$path?borrowernumber="
                           .$another_patron->borrowernumber
                           => json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(PUT => "$path?categorycode=$categorycode"
                           => json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(PUT => $path => json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400)
      ->json_is('/error', 'Patron or category not found');

    t::lib::Mocks::mock_preference('EnhancedMessagingPreferences', 0);
    $tx = $t->ua->build_tx(PUT => "$path?borrowernumber=$borrowernumber" =>
                           json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_is('/error' => 'Enhanced messaging preferences are not enabled');
    t::lib::Mocks::mock_preference('EnhancedMessagingPreferences', 1);

    $tx = $t->ua->build_tx(PUT => "$path?borrowernumber=$borrowernumber" =>
                           json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400)
      ->json_like('/error' => qr/^days_in_advance cannot/);

    $edited_preference->{$preference->message_name}->
                                        {days_in_advance}->{value} = undef;
    $tx = $t->ua->build_tx(PUT => "$path?borrowernumber=$borrowernumber" =>
                           json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400)
      ->json_like('/error' => qr/igest not available/);

    $edited_preference->{$preference->message_name}->{digest}->{value}
                        = Mojo::JSON->false;
    $tx = $t->ua->build_tx(PUT => "$path?borrowernumber=$borrowernumber" =>
                           json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/'.$preference->message_name.'/transport_types/'.
                $mtt2->message_transport_type => Mojo::JSON->false)
      ->json_is('/'.$preference->message_name.'/transport_types/'.
                $mtt1->message_transport_type => Mojo::JSON->true);

    subtest 'Ensure things get logged' => sub {
        plan tests => 3;

        my $logs = C4::Log::GetLogs("","","",["MEMBERS"],["MOD MTT"],
        $patron->borrowernumber,"");
        is($logs->[0]->{action}, 'MOD MTT', 'Correct log action');
        is($logs->[0]->{object}, $patron->borrowernumber, 'Correct borrowernumber');
        is($logs->[0]->{interface}, 'rest', 'REST interface');
    };

    Koha::Patron::Message::Transports->search({
        message_attribute_id => $preference->message_attribute_id,
    })->update({ is_digest => 1 });
    $edited_preference->{$preference->message_name}->{digest}->{value}
                        = Mojo::JSON->true;
    $tx = $t->ua->build_tx(PUT => "$path?borrowernumber=$borrowernumber" =>
                           json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/'.$preference->message_name.'/digest/value' => Mojo::JSON->true);

    # Test librarian access
    $tx = $t->ua->build_tx(PUT => "$path?borrowernumber=$borrowernumber" =>
                           json => $edited_preference);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/'.$preference->message_name.'/digest/value' => Mojo::JSON->true);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my ($params) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            flags        => $params->{'flags'} || 0,
            lost         => 0,
        }
    });

    my $session = t::lib::Mocks::mock_session({borrower => $borrower});
    my $patron = Koha::Patrons->find($borrower->{borrowernumber});

    return ($patron, $session);
}


sub build_a_test_attribute {
    my ($params) = @_;

    $params->{takes_days} = $params->{takes_days} && $params->{takes_days} > 0
                            ? 1 : 0;

    my $attribute = $builder->build({
        source => 'MessageAttribute',
        value => $params,
    });

    return Koha::Patron::Message::Attributes->find(
        $attribute->{message_attribute_id}
    );
}

sub build_a_test_category {
    my $categorycode   = $builder->build({
        source => 'Category' })->{categorycode};

    return Koha::Patron::Categories->find($categorycode);
}

sub build_a_test_letter {
    my ($params) = @_;

    my $mtt = $params->{mtt} ? $params->{mtt} : 'email';
    my $branchcode     = $builder->build({
        source => 'Branch' })->{branchcode};
    my $letter = $builder->build({
        source => 'Letter',
        value => {
            branchcode => '',
            is_html => 0,
            message_transport_type => $mtt
        }
    });

    return Koha::Notice::Templates->find({
        module     => $letter->{module},
        code       => $letter->{code},
        branchcode => $letter->{branchcode},
    });
}

sub build_a_test_transport_type {
    my $mtt = $builder->build({
        source => 'MessageTransportType' });

    return Koha::Patron::Message::Transport::Types->find(
        $mtt->{message_transport_type}
    );
}

sub build_a_test_category_preference {
    my ($params) = @_;

    my $patron = $params->{patron};
    my $attr = $params->{attr}
                    ? $params->{attr}
                    : build_a_test_attribute($params->{days_in_advance});

    my $letter = $params->{letter} ? $params->{letter} : build_a_test_letter();
    my $mtt1 = $params->{mtt1} ? $params->{mtt1} : build_a_test_transport_type();
    my $mtt2 = $params->{mtt2} ? $params->{mtt2} : build_a_test_transport_type();

    Koha::Patron::Message::Transport->new({
        message_attribute_id   => $attr->message_attribute_id,
        message_transport_type => $mtt1->message_transport_type,
        is_digest              => $params->{digest} ? 1 : 0,
        letter_module          => $letter->module,
        letter_code            => $letter->code,
    })->store;

    Koha::Patron::Message::Transport->new({
        message_attribute_id   => $attr->message_attribute_id,
        message_transport_type => $mtt2->message_transport_type,
        is_digest              => $params->{digest} ? 1 : 0,
        letter_module          => $letter->module,
        letter_code            => $letter->code,
    })->store;

    my $default = Koha::Patron::Message::Preference->new({
        categorycode         => $patron->categorycode,
        message_attribute_id => $attr->message_attribute_id,
        wants_digest         => $params->{digest} ? 1 : 0,
        days_in_advance      => $params->{days_in_advance}
                                 ? $params->{days_in_advance} : undef,
    })->store;

    Koha::Patron::Message::Transport::Preference->new({
        borrower_message_preference_id => $default->borrower_message_preference_id,
        message_transport_type         => $mtt1->message_transport_type,
    })->store;
    Koha::Patron::Message::Transport::Preference->new({
        borrower_message_preference_id => $default->borrower_message_preference_id,
        message_transport_type         => $mtt2->message_transport_type,
    })->store;

    return ($default, $mtt1, $mtt2);
}

sub build_a_test_complete_preference {
    my ($params) = @_;

    my ($default, $mtt1, $mtt2) = build_a_test_category_preference($params);
    my $patron = $params->{patron};
    $patron->set_default_messaging_preferences;
    return (Koha::Patron::Message::Preferences->search({
        borrowernumber => $patron->borrowernumber
    })->next, $mtt1, $mtt2);
}
