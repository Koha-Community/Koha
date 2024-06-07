#!/usr/bin/perl

# This file is part of Koha.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use Modern::Perl;

use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::Directory;
use Plack::App::URLMap;
use Plack::Request;

use Mojo::Server::PSGI;

# Pre-load libraries
use C4::Koha;
use C4::Languages;
use C4::Letters;
use C4::Members;
use C4::XSLT;
use Koha::Caches;
use Koha::Cache::Memory::Lite;
use Koha::Database;
use Koha::DateUtils;
use Koha::Logger;

use Log::Log4perl;
use CGI qw(-utf8 ); # we will loose -utf8 under plack, otherwise
{
    no warnings 'redefine';
    my $old_new = \&CGI::new;
    *CGI::new = sub {
        my $q = $old_new->( @_ );
        $CGI::PARAM_UTF8 = 1;
        Koha::Caches->flush_L1_caches();
        Koha::Cache::Memory::Lite->flush();
        return $q;
    };
}

my $home = $ENV{KOHA_HOME};
my $intranet = Plack::App::CGIBin->new(
    root => $ENV{DEV_INSTALL}? $home: "$home/intranet/cgi-bin"
)->to_app;

my $intranet_svc = Plack::App::CGIBin->new(
    root => $ENV{DEV_INSTALL}? "$home/svc": "$home/intranet/cgi-bin/svc"
)->to_app;

my $opac = Plack::App::CGIBin->new(
    root => $ENV{DEV_INSTALL}? "$home/opac": "$home/opac/cgi-bin/opac"
)->to_app;

my $apiv1  = builder {
    my $server = Mojo::Server::PSGI->new;
    $server->load_app("$home/api/v1/app.pl");
    $server->to_psgi_app;
};

Koha::Logger->_init;

builder {
    enable "ReverseProxy";
    enable "Plack::Middleware::Static";

    # + is required so Plack doesn't try to prefix Plack::Middleware::
    enable "+Koha::Middleware::UserEnv";
    enable "+Koha::Middleware::SetEnv";
    enable "+Koha::Middleware::RealIP";

    mount '/opac'          => builder {
        #NOTE: it is important that these are relative links
        enable 'ErrorDocument',
            400 => 'errors/400.pl',
            401 => 'errors/401.pl',
            402 => 'errors/402.pl',
            403 => 'errors/403.pl',
            404 => 'errors/404.pl',
            500 => 'errors/500.pl',
            subrequest => 1;
        #NOTE: Without this middleware to catch fatal errors, ErrorDocument won't be able to render a 500 document
        #NOTE: This middleware must be closer to the PSGI app than ErrorDocument
        enable "HTTPExceptions";
        if ( Log::Log4perl->get_logger('plack-opac')->has_appenders ){
            enable 'Log4perl', category => 'plack-opac';
            enable 'LogWarn';
        }
        enable "+Koha::Middleware::CSRF";
        $opac;
    };
    mount '/intranet'      => builder {
        #NOTE: it is important that these are relative links
        enable 'ErrorDocument',
            400 => 'errors/400.pl',
            401 => 'errors/401.pl',
            402 => 'errors/402.pl',
            403 => 'errors/403.pl',
            404 => 'errors/404.pl',
            500 => 'errors/500.pl',
            subrequest => 1;
        #NOTE: Without this middleware to catch fatal errors, ErrorDocument won't be able to render a 500 document
        #NOTE: This middleware must be closer to the PSGI app than ErrorDocument
        enable "HTTPExceptions";
        if ( Log::Log4perl->get_logger('plack-intranet')->has_appenders ){
            enable 'Log4perl', category => 'plack-intranet';
            enable 'LogWarn';
        }
        enable "+Koha::Middleware::CSRF";
        $intranet;
    };
    mount '/intranet_svc'      => builder {
        if ( Log::Log4perl->get_logger('plack-intranet')->has_appenders ){
            enable 'Log4perl', category => 'plack-intranet';
            enable 'LogWarn';
        }
        enable "+Koha::Middleware::CSRF";
        $intranet_svc;
    };
    mount '/api/v1/app.pl' => builder {
        if ( Log::Log4perl->get_logger('plack-api')->has_appenders ){
            enable 'Log4perl', category => 'plack-api';
            enable 'LogWarn';
        }
        $apiv1;
    };
};
