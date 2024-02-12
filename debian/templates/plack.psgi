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

        my %stateless_methods = (
            GET     => 1,
            HEAD    => 1,
            OPTIONS => 1,
            TRACE   => 1,
        );

        my %stateful_methods = (
            POST   => 1,
            PUT    => 1,
            DELETE => 1,
            PATCH  => 1,
        );

        my $original_op    = $q->param('op');
        my $request_method = $q->request_method // q{};
        if ( $stateless_methods{$request_method} && defined $original_op && $original_op =~ m{^cud-} ) {
            Koha::Logger->get->warn("Programming error - op '$original_op' must not start with 'cud-' for $request_method");
            $q->param( 'op', '' );
            $q->param( 'debug_programming_error', "'$original_op' must not start with 'cud-' for $request_method" );
        } elsif ( $stateful_methods{$request_method} ) {
            # Get the CSRF token from the param list or the header
            my $csrf_token = $q->param('csrf_token') || $q->http('HTTP_CSRF_TOKEN');

            if ( defined $q->param('op') && $original_op !~ m{^cud-} ) {
                Koha::Logger->get->warn("Programming error - op '$original_op' must start with 'cud-' for $request_method");
                $q->param( 'op', '' );
                $q->param( 'debug_programming_error', "'$original_op' must start with 'cud-' for $request_method" );
            }

            if ( $csrf_token ) {
                unless (
                    Koha::Token->new->check_csrf(
                        {
                            session_id => scalar $q->cookie('CGISESSID'),
                            token      => $csrf_token,
                        }
                    )
                    )
                {
                    Koha::Logger->get->debug("The form submission failed (Wrong CSRF token).");
                    $q->param( 'op', '' );
                    $q->param( 'invalid_csrf_token', 1);
                }
            } else {
                Koha::Logger->get->warn("Programming error - No CSRF token passed for $request_method");
                $q->param( 'op', '' );
                $q->param( 'debug_programming_error', "No CSRF token passed for $request_method" );
            }
        }

        return $q;
    };
}

my $home = $ENV{KOHA_HOME};
my $intranet = Plack::App::CGIBin->new(
    root => $ENV{DEV_INSTALL}? $home: "$home/intranet/cgi-bin"
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
        $intranet;
    };
    mount '/api/v1/app.pl' => builder {
        if ( Log::Log4perl->get_logger('plack-api')->has_appenders ){
            enable 'Log4perl', category => 'plack-api';
            enable 'LogWarn';
        }
        $apiv1;
    };
};
