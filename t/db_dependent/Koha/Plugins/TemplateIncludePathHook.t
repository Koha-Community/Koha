#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::MockModule;
use Test::Warn;

use File::Basename;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    require t::lib::Mocks;
    t::lib::Mocks::mock_config( 'enable_plugins', 1 );
    t::lib::Mocks::mock_config( 'pluginsdir',     $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
}

my $schema = Koha::Database->new->schema;

subtest 'template_include_paths' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    Koha::Plugins->new->InstallPlugins();
    Koha::Plugin::Test->new->enable;

    require C4::Templates;
    my $c4_template = C4::Templates::gettemplate( 'intranet-main.tt', 'intranet' );
    my $template    = $c4_template->{TEMPLATE};
    my $output      = '';
    $template->process( \"[% INCLUDE test.inc %]", {}, \$output ) || die $template->error();
    is( $output, 'included content' );

    $schema->storage->txn_rollback;
};

subtest 'cannot override core templates' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    Koha::Plugins->new->InstallPlugins();
    Koha::Plugin::Test->new->enable;

    require C4::Templates;
    my $c4_template = C4::Templates::gettemplate( 'intranet-main.tt', 'intranet' );
    my $template    = $c4_template->{TEMPLATE};
    my $output      = '';
    $template->process( \"[% INCLUDE 'csrf-token.inc' %]", {}, \$output ) || die $template->error();
    unlike( $output, qr/OVERRIDE/ );

    $schema->storage->txn_rollback;
};
