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

use Test::More tests => 5;
use Test::Mojo;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Suggestions;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($another_patron, undef) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "catalogue" => "1"
    });

    my $suggestion = $builder->build({
        source => 'Suggestion',
        value => {
            suggestedby => $patron->borrowernumber,
            title => 'title one',
            status => 'ASKED',
            suggesteddate => dt_from_string
        }
    });
    my $another_suggestion = $builder->build({
        source => 'Suggestion',
        value => {
            suggestedby => $another_patron->borrowernumber,
            title => 'title two',
            status => 'ASKED',
            suggesteddate => dt_from_string
        }
    });
    my $suggestionid = $suggestion->{'suggestionid'};
    my $another_suggestionid = $another_suggestion->{'suggestionid'};

    my $tx = $t->ua->build_tx(GET => "/api/v1/suggestions?suggestedby="
                              .$patron->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/subject' => $suggestion->{'subject'});

    $tx = $t->ua->build_tx(GET => "/api/v1/suggestions?suggestedby="
                              .$another_patron->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(GET => "/api/v1/suggestions?suggestedby=-1");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0' => undef);

    $tx = $t->ua->build_tx(GET => "/api/v1/suggestions?suggestedby="
                           .$patron->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/subject' => $suggestion->{'subject'});

    $schema->storage->txn_rollback;
};

subtest 'get() tests' => sub {
    plan tests => 10;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($another_patron, undef) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "catalogue" => "1"
    });

    my $suggestion = $builder->build({
        source => 'Suggestion',
        value => {
            suggestedby => $patron->borrowernumber,
            title => 'title one',
            status => 'ASKED',
            suggesteddate => dt_from_string
        }
    });
    my $another_suggestion = $builder->build({
        source => 'Suggestion',
        value => {
            suggestedby => $another_patron->borrowernumber,
            title => 'title two',
            status => 'ASKED',
            suggesteddate => dt_from_string
        }
    });
    my $suggestionid = $suggestion->{'suggestionid'};
    my $another_suggestionid = $another_suggestion->{'suggestionid'};

    my $tx = $t->ua->build_tx(GET => "/api/v1/suggestions/$suggestionid");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/title' => $suggestion->{'title'})
      ->json_is('/STATUS' => $suggestion->{'STATUS'});

    $tx = $t->ua->build_tx(GET => "/api/v1/suggestions/$another_suggestionid");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(GET => "/api/v1/suggestions/$suggestionid");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/title' => $suggestion->{'title'})
      ->json_is('/STATUS' => $suggestion->{'STATUS'});

    $schema->storage->txn_rollback;
};

subtest 'post() tests' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "catalogue" => "1"
    });

    my $suggestion = {
        title => 'Bring milk from the store, please!',
        itemtype => 'BK',
    };

    my $tx = $t->ua->build_tx(POST => "/api/v1/suggestions" => json => $suggestion);
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(401);

    $tx = $t->ua->build_tx(POST => "/api/v1/suggestions" => json => $suggestion);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/title' => $suggestion->{'title'})
      ->json_is('/STATUS' => 'ASKED');

    my $sug = Koha::Suggestions->search({}, {
        order_by => { '-desc' => 'suggestionid' }
    })->next;
    is($sug->title, $suggestion->{title}, 'The suggestion was really added!');

    $suggestion->{'title'} .= 'Librarians title';
    $tx = $t->ua->build_tx(POST => "/api/v1/suggestions" => json => $suggestion);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_is('/title' => $suggestion->{'title'})
      ->json_is('/STATUS' => 'ASKED');

    $sug = Koha::Suggestions->search({}, {
        order_by => { '-desc' => 'suggestionid' }
    })->next;
    is($sug->title, $suggestion->{title}, 'The suggestion was really added!');

    $schema->storage->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "catalogue" => "1"
    });

    my $suggestion = $builder->build({
        source => 'Suggestion',
        value => {
            suggestedby => $patron->borrowernumber,
            title => 'title one',
            status => 'ASKED',
            suggesteddate => dt_from_string
        }
    });

    my $edited_suggestion = {
        title => 'Bring milk from the store, please!',
        itemtype => 'BK',
    };

    my $suggestionid = $suggestion->{'suggestionid'};

    my $tx = $t->ua->build_tx(PUT => "/api/v1/suggestions/$suggestionid" =>
                           json => $edited_suggestion);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/title' => $edited_suggestion->{'title'})
      ->json_is('/itemtype' => $edited_suggestion->{'itemtype'});

    $edited_suggestion = {
        title => 'Jabba the Fit',
        itemtype => 'DVD',
    };

    $tx = $t->ua->build_tx(PUT => "/api/v1/suggestions/$suggestionid" =>
                           json => $edited_suggestion);
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/title' => $edited_suggestion->{'title'})
      ->json_is('/itemtype' => $edited_suggestion->{'itemtype'});

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my ($patron, $session) = create_user_and_session();
    my ($librarian, $librarian_session) = create_user_and_session({
        "catalogue" => "1"
    });

    my $suggestion = $builder->build({
        source => 'Suggestion',
        value => {
            suggestedby => $patron->borrowernumber,
            title => 'title one',
            status => 'ASKED',
            suggesteddate => dt_from_string
        }
    });

    my $suggestion2 = $builder->build({
        source => 'Suggestion',
        value => {
            suggestedby => $patron->borrowernumber,
            title => 'title two',
            status => 'ASKED',
            suggesteddate => dt_from_string
        }
    });

    my $suggestionid = $suggestion->{'suggestionid'};
    my $suggestionid2 = $suggestion2->{'suggestionid'};

    my $tx = $t->ua->build_tx(DELETE => "/api/v1/suggestions/$suggestionid");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/suggestions/$suggestionid2");
    $tx->req->cookies({name => 'CGISESSID', value => $librarian_session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    my $msg = Koha::Suggestions->find($suggestionid);
    is($msg, undef, 'The first suggestion was really deleted!');
    $msg = Koha::Suggestions->find($suggestionid2);
    is($msg, undef, 'The second suggestion was really deleted!');

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
        foreach my $flag (keys %$flags) {
            if ($flags->{$flag} eq '1') {
                Koha::Auth::PermissionManager->grantAllSubpermissions(
                    $patron, $flag
                );
            } else {
                Koha::Auth::PermissionManager->grantPermissions(
                    $patron, $flags
                );
            }
        }
    }

    return ($patron, $session);
}
