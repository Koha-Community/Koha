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

use MARC::Record;
use Test::NoWarnings;
use Test::More tests => 5;
use Test::Warn;

use File::Basename;

use C4::AuthoritiesMarc ();
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'after_authority_action hook' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;
    my $plugin = Koha::Plugin::Test->new->enable;
    my $id;

    my $record = MARC::Record->new;
    $record->append_fields( MARC::Field->new( '100', '1', '2', a => 'Name' ) );
    my $type = $builder->build( { source => 'AuthType', value => { auth_tag_to_report => '100' } } );

    warnings_exist { ($id) = C4::AuthoritiesMarc::AddAuthority( $record, undef, $type->{authtypecode} ); }
    qr/after_authority_action called with action: create, id: \d+/,
        'AddAuthority calls the hook with action=create, id passed';

    warnings_exist { C4::AuthoritiesMarc::ModAuthority( $id, $record, $type->{authtypecode}, { skip_merge => 1 } ); }
    qr/after_authority_action called with action: modify, id: $id/,
        'ModAuthority calls the hook with action=modify, id passed';

    warnings_exist { C4::AuthoritiesMarc::DelAuthority( { authid => $id, skip_merge => 1 } ); }
    qr/after_authority_action called with action: delete, id: $id/,
        'DelAuthority calls the hook with action=delete, id passed';

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
