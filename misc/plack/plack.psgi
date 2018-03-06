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

use lib($ENV{PERL_MODULE_DIR});
use lib($ENV{PERL_MODULE_DIR}.'/installer');

use Plack::Builder;
use Plack::App::CGIBin;
use Plack::App::Directory;
use Plack::App::URLMap;
use Plack::Request;

use Mojo::Server::PSGI;

# Pre-load libraries
use C4::Boolean;
use C4::Context;
use C4::Koha;
use C4::Languages;
use C4::Letters;
use C4::Members;
use C4::XSLT;
use Koha::Caches;
use Koha::Cache::Memory::Lite;
use Koha::Database;
use Koha::DateUtils;

#BZ 16520, add timestamps to warnings

use CGI qw(-utf8 ); # we will loose -utf8 under plack, otherwise
{
    no warnings 'redefine';
    my $old_new = \&CGI::new;
    *CGI::new = sub {
        my $q = $old_new->( @_ );
        $CGI::PARAM_UTF8 = 1;

        my $syspref_cache = Koha::Caches->get_instance('syspref');
        if ($syspref_cache->{'memcached_cache'}) { #When using a shared caching medium, cache invalidations can be communicated between workers.
            Koha::Caches->flush_L1_caches();
        }
        else { #Without a shared cache medium, workers cannot invalidate cached values in each others memory, if for. ex. a syspref is changed.
            Koha::Caches->flush(); #Then we must flush all caches periodically.
        }
        Koha::Cache::Memory::Lite->flush();
        return $q;
    };
}

use Devel::Size 0.77; # 0.71 doesn't work for Koha
my $watch_capture_regex = '(C4|Koha)';

sub watch_for_size {
        my @watch =
        map { s/^.*$watch_capture_regex/$1/; s/\//::/g; s/\.pm$//; $_ } # fix paths
        grep { /$watch_capture_regex/ }
        keys %INC
        ;
        warn "# watch_for_size ",join(' ',@watch);
        return @watch;
};





my $intranet = Plack::App::CGIBin->new(
    root => $ENV{INTRANET_CGI_DIR}
)->to_app;

my $opac = Plack::App::CGIBin->new(
    root => $ENV{OPAC_CGI_DIR}
)->to_app;

my $apiv1  = builder {
    my $server = Mojo::Server::PSGI->new;
    $server->load_app($ENV{PERL_MODULE_DIR}.'/api/v1/app.pl');
    $server->to_psgi_app;
};

my $proxies = C4::Context->config('trusted_proxy');

builder {
    # Enable logging
    enable "+Koha::Middleware::Logger";
    enable "LogWarn";
    enable "LogErrors";

    enable "ReverseProxy";
    enable_if { $proxies } "Plack::Middleware::RealIP",
        header => 'X-Forwarded-For',
        trusted_proxy => [split /[ ,]+/, $proxies];
    enable "Plack::Middleware::Static";
    # + is required so Plack doesn't try to prefix Plack::Middleware::
    enable "+Koha::Middleware::SetEnv";

    ### INTRODUCING DEBUG PLUGINS ###
    # don't enable this plugin in production, since stack traces reveal too much information
    # about system to potential attackers!
    enable_if { $ENV{PLACK_DEBUG} } 'StackTrace';
    # please don't use plugins which are under enable_if $ENV{PLACK_DEBUG} in production!
    # they are known to leek memory
    enable_if { $ENV{PLACK_DEBUG} } 'Debug',  panels => [
            qw(Environment Response Timer Memory),
            # optional plugins (uncomment to enable) are sorted according to performance implact
#           [ 'Devel::Size', for => \&watch_for_size ], # https://github.com/dpavlin/p5-plack-devel-debug-devel-size
#           [ 'DBIProfile', profile => 2 ],
#           [ 'DBITrace', level => 1 ], # a LOT of fine-graded SQL trace
#           [ 'Profiler::NYTProf', exclude => [qw(.*\.css .*\.png .*\.ico .*\.js .*\.gif)] ],
    ];


    ##Mount apps to endpoints
    mount '/opac'          => $opac;
    mount '/intranet'      => $intranet;
    mount '/api/v1/app.pl' => $apiv1;

};
