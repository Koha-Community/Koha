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

use Test::More tests => 5;
use Test::Exception;

use File::Basename;

use C4::Items;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
    use_ok('Koha::Patron');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'UseKohaPlugins', 1 );
t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'check_password hook tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $plugin = Koha::Plugin::Test->new->enable;

    my $library  = $builder->build( { source => 'Branch' } );
    my $category = $builder->build( { source => 'Category' } );
    my $patron   = Koha::Patron->new(
        {
            cardnumber   => 'test_cn_1',
            branchcode   => $library->{branchcode},
            categorycode => $category->{categorycode},
            surname      => 'surname for patron1',
            firstname    => 'firstname for patron1',
            userid       => 'a_nonexistent_userid_1',
            password     => "exploder",
        }
    );

    throws_ok { $patron->store } 'Koha::Exceptions::Password::Plugin',
      'Exception raised for adding patron with bad password';
    $patron->password('1234');
    ok( $patron->store, 'Patron created with good password' );

    t::lib::Mocks::mock_preference( 'RequireStrongPassword', '0' );
    throws_ok { $patron->set_password({ password => 'explosion' }) } 'Koha::Exceptions::Password::Plugin',
      'Exception raised for update patron password with bad string';
    ok( $patron->set_password({ password => '4321' }), 'Patron password updated with good string' );
    ok( $patron->set_password({ password => 'explosion', skip_validation => 1}), 'Patron password updated via skip validation');

    $schema->storage->txn_rollback;
    Koha::Plugins::Methods->delete;
};

1;
