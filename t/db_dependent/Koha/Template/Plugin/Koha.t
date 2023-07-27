#!/usr/bin/env perl

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

use Test::More tests => 1;

use Template::Context;
use Template::Stash;

use C4::Auth;
use Koha::Database;
use Koha::Template::Plugin::Koha;

my $schema = Koha::Database->new->schema;

subtest 'GenerateCSRF() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $session = C4::Auth::get_session('');

    my $stash   = Template::Stash->new( { sessionID => $session->id } );
    my $context = Template::Context->new( { STASH => $stash } );

    my $plugin = Koha::Template::Plugin::Koha->new($context);

    my $token = $plugin->GenerateCSRF();

    ok( Koha::Token->new->check_csrf( { session_id => $session->id, token => $token } ) );

    $schema->storage->txn_rollback;
};
