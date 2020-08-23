#!/usr/bin/perl

# Copyright 2020 Koha Development team
#
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

use Test::More tests => 1;

use Koha::Database;
use Koha::SMTP::Servers;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'smtp_server() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $library       = $builder->build_object({ class => 'Koha::Libraries' });
    my $smtp_server_1 = $builder->build_object({ class => 'Koha::SMTP::Servers' });
    my $smtp_server_2 = $builder->build_object({ class => 'Koha::SMTP::Servers' });

    is( ref($library->smtp_server), 'Koha::SMTP::Server', 'Type is correct' );

    is_deeply(
        $library->smtp_server->unblessed,
        Koha::SMTP::Servers->get_default->unblessed,
        'Fresh library is set the default'
    );

    my $return = $library->smtp_server({ smtp_server => $smtp_server_1 });
    $library->discard_changes;

    is( ref($return), 'Koha::Library', 'The setter is chainable' );
    is( ref($library->smtp_server), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        $smtp_server_1->unblessed,
        'SMTP server correctly set for library'
    );

    $return = $library->smtp_server({ smtp_server => $smtp_server_2 });
    $library->discard_changes;

    is( ref($return), 'Koha::Library', 'The setter is chainable' );
    is( ref($library->smtp_server), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        $smtp_server_2->unblessed,
        'SMTP server correctly set for library'
    );

    $return = $library->smtp_server({ smtp_server => undef });
    $library->discard_changes;

    is( ref($return), 'Koha::Library', 'The setter is chainable' );
    is( ref($library->smtp_server), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        Koha::SMTP::Servers->get_default->unblessed,
        'Resetting makes it return the default'
    );

    $return = $library->smtp_server({ smtp_server => undef });
    $library->discard_changes;

    is( ref($return), 'Koha::Library', 'The setter is chainable' );
    is( ref($library->smtp_server), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        Koha::SMTP::Servers->get_default->unblessed,
        q{Resetting twice doesn't explode and has the expected results}
    );

    $schema->storage->txn_rollback;
};
