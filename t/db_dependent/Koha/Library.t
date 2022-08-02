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

use Test::More tests => 2;

use Koha::Database;
use Koha::AdditionalContents;
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

subtest 'opac_info tests' => sub {
    plan tests => 8;
    $schema->storage->txn_begin;
    my $library01 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library02 = $builder->build_object({ class => 'Koha::Libraries' });

    my $html01 = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => { category => 'html_customizations', location => 'OpacLibraryInfo', branchcode => undef, lang => 'default', content => '1', expirationdate => undef },
    });
    my $html02 = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => { category => 'html_customizations', location => 'OpacLibraryInfo', branchcode => $library01->id, lang => 'default', content => '2', expirationdate => undef },
    });
    my $html03 = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => { category => 'html_customizations', location => 'OpacLibraryInfo', branchcode => $library01->id, lang => 'nl-NL', content => '3', expirationdate => undef },
    });
    my $html04 = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => { category => 'html_customizations', location => 'OpacLibraryInfo', branchcode => undef, lang => 'fr-FR', content => '4', expirationdate => undef },
    });

    # Start testing
    is( $library01->opac_info->content, '2', 'specific library, default language' );
    is( $library01->opac_info({ lang => 'nl-NL' })->content, '3', 'specific library, specific language' );
    is( $library01->opac_info({ lang => 'nl-BE' })->content, '2', 'specific library, unknown language' );
    is( $library02->opac_info->content, '1', 'unknown library, default language' );
    is( $library02->opac_info({ lang => 'fr-FR' })->content, '4', 'unknown library, specific language' );
    is( $library02->opac_info({ lang => 'de-DE' })->content, '1', 'unknown library, unknown language' );
    $html01->delete;
    is( $library02->opac_info, undef, 'unknown library, default language (after removing html01)' );
    is( $library02->opac_info({ lang => 'de-DE' }), undef, 'unknown library, unknown language (after removing html01)' );

    $schema->storage->txn_rollback;
};
