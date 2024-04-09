# Copyright 2020 BibLibre
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

use FindBin;
use Plack::Builder;
use Mojo::Server::PSGI;

sub psgi_app {
    my ($script) = @_;

    my $server = Mojo::Server::PSGI->new;
    $server->load_app("$FindBin::Bin/$script");

    return $server->to_psgi_app;
}

my $opac = psgi_app('bin/opac');
my $intranet = psgi_app('bin/intranet');

my $opac_port = $ENV{KOHA_OPAC_PORT} || 5001;
my $intranet_port = $ENV{KOHA_INTRANET_PORT} || 5000;
my $port2app = {
    $opac_port => $opac,
    $intranet_port => $intranet,
};

builder {
    # This middleware decides which app to run (opac or intranet) depending on
    # SERVER_PORT.  It must be run before ReverseProxy middleware which can
    # modify SERVER_PORT
    enable sub {
        my $app = shift;
        sub {
            my $env = shift;
            $env->{'koha.app'} = $port2app->{$env->{SERVER_PORT}} || $intranet;
            return $app->($env);
        }
    };

    enable 'ReverseProxy';
    enable '+Koha::Middleware::UserEnv';
    enable '+Koha::Middleware::SetEnv';
    enable '+Koha::Middleware::RealIP';

    sub {
        my $env = shift;
        $env->{'koha.app'}->($env);
    };
}
