#!/usr/bin/perl

# This test is db dependent: SIPServer needs MsgType which needs Auth.
# And Auth needs config vars and preferences in its BEGIN block.

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Warn;

my ( $mockConfig, $mockPrefork );

BEGIN {
    # In order to test SIPServer::get_timeout, we need to mock
    # Configuration->new and PreFork->run.
    use Test::MockModule;
    use C4::SIP::Sip::Configuration;
    $mockConfig = Test::MockModule->new('C4::SIP::Sip::Configuration');
    $mockConfig->mock( 'new', sub { return {}; } );
    use Net::Server::PreFork;
    $mockPrefork = Test::MockModule->new('Net::Server::PreFork');
    $mockPrefork->mock( 'run', sub { } );
}

use C4::SIP::SIPServer;

# Start testing !
# TODO We should include more tests here.

subtest 'Get_timeout' => sub {
    plan tests => 11;

    my $server = {
        policy  => { timeout => 1 },
        config  => { timeout => 2 },
        service => {
            timeout        => 3,
            client_timeout => 4,
        },
    };

    is( C4::SIP::SIPServer::get_timeout(), 30, "Default fallback" );
    is( C4::SIP::SIPServer::get_timeout( undef,   { fallback  => 25 } ), 25,    "Fallback parameter" );
    is( C4::SIP::SIPServer::get_timeout( $server, { transport => 1 } ),  3,     "Transport value" );
    is( C4::SIP::SIPServer::get_timeout( $server, { client    => 1 } ),  4,     "Client value" );
    is( C4::SIP::SIPServer::get_timeout( $server, { policy    => 1 } ),  '001', "Policy value" );

    delete $server->{policy}->{timeout};
    is( C4::SIP::SIPServer::get_timeout( $server, { policy => 1 } ), '000', "No policy" );

    $server->{service}->{client_timeout} = '0';
    is( C4::SIP::SIPServer::get_timeout( $server, { client => 1 } ), 0, "Client zero" );
    $server->{service}->{client_timeout} = 'no';
    is( C4::SIP::SIPServer::get_timeout( $server, { client => 1 } ), 0, "Client no" );
    delete $server->{service}->{client_timeout};
    is( C4::SIP::SIPServer::get_timeout( $server, { client => 1 } ), 3, "Fallback to service" );

    delete $server->{service}->{timeout};
    is( C4::SIP::SIPServer::get_timeout( $server, { transport => 1 } ), 2, "Back to old config" );
    delete $server->{config}->{timeout};
    is( C4::SIP::SIPServer::get_timeout( $server, { transport => 1 } ), 30, "Fallback again" );
};

subtest '_config_up_to_date() tests' => sub {
    plan tests => 4;

    # _config_up_to_date() compares the shared sip2_resource_last_modified against the
    # per-process $sip2_config_read_timestamp. Mock the cache so we control the former.
    my $resource_last_modified;
    my $cache_mock = Test::MockModule->new('Koha::Cache');
    $cache_mock->mock(
        'get_from_cache',
        sub {
            my ( $self, $key ) = @_;
            return $resource_last_modified if $key eq 'sip2_resource_last_modified';
            return $cache_mock->original('get_from_cache')->(@_);
        }
    );

    $resource_last_modified                         = undef;
    $C4::SIP::SIPServer::sip2_config_read_timestamp = time;
    is(
        C4::SIP::SIPServer::_config_up_to_date(), 0,
        'Not up to date when sip2_resource_last_modified is unset'
    );

    $resource_last_modified                         = 2000;
    $C4::SIP::SIPServer::sip2_config_read_timestamp = 1000;
    is(
        C4::SIP::SIPServer::_config_up_to_date(), 0,
        'Not up to date when the resource changed after this process loaded its config'
    );

    $C4::SIP::SIPServer::sip2_config_read_timestamp = 2000;
    is(
        C4::SIP::SIPServer::_config_up_to_date(), 1,
        'Up to date when this process loaded its config at the last modification'
    );

    $C4::SIP::SIPServer::sip2_config_read_timestamp = 3000;
    is(
        C4::SIP::SIPServer::_config_up_to_date(), 1,
        'Up to date when this process loaded its config after the last modification'
    );
};
