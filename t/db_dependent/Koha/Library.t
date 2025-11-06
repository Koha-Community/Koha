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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;

use Koha::Database;
use Koha::AdditionalContents;
use Koha::SMTP::Servers;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'smtp_server() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $library       = $builder->build_object( { class => 'Koha::Libraries' } );
    my $smtp_server_1 = $builder->build_object( { class => 'Koha::SMTP::Servers' } );
    my $smtp_server_2 = $builder->build_object( { class => 'Koha::SMTP::Servers' } );

    is( ref( $library->smtp_server ), 'Koha::SMTP::Server', 'Type is correct' );

    is_deeply(
        $library->smtp_server->unblessed,
        Koha::SMTP::Servers->get_default->unblessed,
        'Fresh library is set the default'
    );

    my $return = $library->smtp_server( { smtp_server => $smtp_server_1 } );
    $library->discard_changes;

    is( ref($return),                 'Koha::Library',      'The setter is chainable' );
    is( ref( $library->smtp_server ), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        $smtp_server_1->unblessed,
        'SMTP server correctly set for library'
    );

    $return = $library->smtp_server( { smtp_server => $smtp_server_2 } );
    $library->discard_changes;

    is( ref($return),                 'Koha::Library',      'The setter is chainable' );
    is( ref( $library->smtp_server ), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        $smtp_server_2->unblessed,
        'SMTP server correctly set for library'
    );

    $return = $library->smtp_server( { smtp_server => undef } );
    $library->discard_changes;

    is( ref($return),                 'Koha::Library',      'The setter is chainable' );
    is( ref( $library->smtp_server ), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        Koha::SMTP::Servers->get_default->unblessed,
        'Resetting makes it return the default'
    );

    $return = $library->smtp_server( { smtp_server => undef } );
    $library->discard_changes;

    is( ref($return),                 'Koha::Library',      'The setter is chainable' );
    is( ref( $library->smtp_server ), 'Koha::SMTP::Server', 'Type is correct' );
    is_deeply(
        $library->smtp_server->unblessed,
        Koha::SMTP::Servers->get_default->unblessed,
        q{Resetting twice doesn't explode and has the expected results}
    );

    $schema->storage->txn_rollback;
};

subtest 'opac_info tests' => sub {
    plan tests => 8;
    $schema->storage->txn_begin;
    my $library01 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library02 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $html01 = $builder->build_object(
        {
            class => 'Koha::AdditionalContents',
            value => {
                category       => 'html_customizations', location => 'OpacLibraryInfo', branchcode => undef,
                expirationdate => undef
            },
        }
    );
    $html01->translated_contents(
        [
            {
                lang    => 'default',
                content => '1',
            }
        ]
    );
    my $html02 = $builder->build_object(
        {
            class => 'Koha::AdditionalContents',
            value => {
                category       => 'html_customizations', location => 'OpacLibraryInfo', branchcode => $library01->id,
                expirationdate => undef
            },
        }
    );
    $html02->translated_contents(
        [
            {
                lang    => 'default',
                content => '2',
            },
            {
                lang    => 'nl-NL',
                content => '3',
            }
        ]
    );
    my $html04 = $builder->build_object(
        {
            class => 'Koha::AdditionalContents',
            value => {
                category       => 'html_customizations', location => 'OpacLibraryInfo', branchcode => undef,
                expirationdate => undef
            },
        }
    );
    $html04->translated_contents(
        [
            {
                lang    => 'fr-FR',
                content => '4',
            }
        ]
    );

    # Start testing
    ok( $library01->opac_info,                        'specific library, default language' );
    ok( $library01->opac_info( { lang => 'nl-NL' } ), 'specific library, specific language' );
    ok( $library01->opac_info( { lang => 'nl-BE' } ), 'specific library, unknown language' );
    ok( $library02->opac_info,                        'unknown library, default language' );
    ok( $library02->opac_info( { lang => 'fr-FR' } ), 'unknown library, specific language' );
    ok( $library02->opac_info( { lang => 'de-DE' } ), 'unknown library, unknown language' );
    $html01->delete;

    ok( $library02->opac_info, 'unknown library, default language (after removing html01)' );
    ok(
        $library02->opac_info( { lang => 'de-DE' } ),
        'unknown library, unknown language (after removing html01)'
    );

    $schema->storage->txn_rollback;
};

subtest 'desks() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $rs = $library->desks;
    is( ref($rs), 'Koha::Desks' );
    is( $rs->count, 0, 'No desks' );

    my $desk_1 = $builder->build_object( { class => 'Koha::Desks', value => { branchcode => $library->id } } );
    my $desk_2 = $builder->build_object( { class => 'Koha::Desks', value => { branchcode => $library->id } } );

    $rs = $library->desks;

    is( $rs->count,    2 );
    is( $rs->next->id, $desk_1->id );
    is( $rs->next->id, $desk_2->id );

    $schema->storage->txn_rollback;
};
