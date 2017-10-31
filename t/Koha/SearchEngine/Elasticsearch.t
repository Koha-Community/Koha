#!/usr/bin/perl
#
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
use Test::Exception;

use t::lib::Mocks;

use Koha::SearchEngine::Elasticsearch;

subtest '_read_configuration() tests' => sub {

    plan tests => 10;

    my $configuration;
    t::lib::Mocks::mock_config( 'elasticsearch', undef );

    # 'elasticsearch' missing in configuration
    throws_ok {
        $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    }
    'Koha::Exceptions::Config::MissingEntry',
      'Configuration problem, exception thrown';
    is(
        $@->message,
        "Missing 'elasticsearch' block in config file",
        'Exception message is correct'
    );

    # 'elasticsearch' present but no 'server' entry
    t::lib::Mocks::mock_config( 'elasticsearch', {} );
    throws_ok {
        $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    }
    'Koha::Exceptions::Config::MissingEntry',
      'Configuration problem, exception thrown';
    is(
        $@->message,
        "Missing 'server' entry in config file for elasticsearch",
        'Exception message is correct'
    );

    # 'elasticsearch' and 'server' entries present, but no 'index_name'
    t::lib::Mocks::mock_config( 'elasticsearch', { server => 'a_server' } );
    throws_ok {
        $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    }
    'Koha::Exceptions::Config::MissingEntry',
      'Configuration problem, exception thrown';
    is(
        $@->message,
        "Missing 'index_name' entry in config file for elasticsearch",
        'Exception message is correct'
    );

    # Correct configuration, only one server
    t::lib::Mocks::mock_config( 'elasticsearch',  { server => 'a_server', index_name => 'index' } );

    $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    is( $configuration->{index_name}, 'index', 'Index configuration parsed correctly' );
    is_deeply( $configuration->{nodes}, ['a_server'], 'Server configuration parsed correctly' );

    # Correct configuration, two servers
    my @servers = ('a_server', 'another_server');
    t::lib::Mocks::mock_config( 'elasticsearch', { server => \@servers, index_name => 'index' } );

    $configuration = Koha::SearchEngine::Elasticsearch::_read_configuration;
    is( $configuration->{index_name}, 'index', 'Index configuration parsed correctly' );
    is_deeply( $configuration->{nodes}, \@servers , 'Server configuration parsed correctly' );
};
