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
use File::Basename;
use Test::More tests => 4;
use Test::MockModule;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use C4::Circulation qw();
use Koha::CirculationRules;
use Koha::Plugins::Methods;
use Koha::Recalls;

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

subtest 'after_recall_action hook' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;
    # Avoid testing useless warnings
    my $test_plugin = Test::MockModule->new('Koha::Plugin::Test');
    $test_plugin->mock( 'after_item_action',   undef );
    $test_plugin->mock( 'after_circ_action', undef );
    $test_plugin->mock( 'after_biblio_action', undef );
    $test_plugin->mock( 'patron_barcode_transform', undef );
    $test_plugin->mock( 'item_barcode_transform', undef );

    my $item = $builder->build_sample_item();
    my $biblio = $item->biblio;
    my $branch = $item->holdingbranch;
    my $category = $builder->build({ source => 'Category' })->{ categorycode };
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons', value => { categorycode => $category, branchcode => $branch } });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons', value => { categorycode => $category, branchcode => $branch } });
    t::lib::Mocks::mock_userenv({ patron => $patron1 });

    Koha::CirculationRules->set_rules({
        branchcode => undef,
        categorycode => undef,
        itemtype => undef,
        rules => {
            'recall_due_date_interval' => undef,
            'recalls_allowed' => 10,
        }
    });

    C4::Circulation::AddIssue( $patron2, $item->barcode );

    warning_like {
      Koha::Recalls->add_recall({
          patron => $patron1,
          biblio => $biblio,
          branchcode => $branch,
          item => undef,
          expirationdate => undef,
          interface => 'COMMANDLINE',
      });
    }
    qr/after_recall_action called with action: add, ref: Koha::Recall/,
      '->add_recall calls the after_recall_action hook with action add';

    Koha::Plugins::Methods->delete;
    $schema->storage->txn_rollback;
};
