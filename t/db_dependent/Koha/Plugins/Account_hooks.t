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
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;
use Test::MockModule;
use Test::Warn;

use File::Basename;

use Koha::Account qw( add_credit );

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

subtest 'Koha::Account tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $account = $patron->account;
    warning_like {
        $account->add_credit( { amount => 20, interface => 'commandline', type => 'WRITEOFF' } );
    }
    qr/after_account_action called with action: add_credit, type: writeoff, ref: Koha::Account::Line/,
        '->add_credit calls the after_account_action hook with type writeoff';

    warning_like {
        $account->add_credit( { amount => 10, interface => 'commandline', type => 'PAYMENT' } );
    }
    qr/after_account_action called with action: add_credit, type: payment, ref: Koha::Account::Line/,
        '->add_credit calls the after_account_action hook with type payment';

    Koha::Plugins->RemovePlugins;
    $schema->storage->txn_rollback;
};
