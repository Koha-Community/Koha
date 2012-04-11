#!/usr/bin/perl
use Plack::Builder;
use Plack::App::CGIBin;
use lib qw( ./lib );
use Plack::Middleware::Debug;
use Plack::App::Directory;

BEGIN {

# override configuration from startup script below:
# (requires --reload option)

$ENV{PLACK_DEBUG} = 1; # toggle debugging

# memcache change requires restart
$ENV{MEMCACHED_SERVERS} = "localhost:11211";
#$ENV{MEMCACHED_DEBUG} = 0;

$ENV{PROFILE_PER_PAGE} = 1; # reset persistant and profile counters after each page, like CGI
#$ENV{INTRANET} = 1; # usually passed from script

#$ENV{DBI_AUTOPROXY}='dbi:Gofer:transport=null;cache=DBI::Util::CacheMemory'

} # BEGIN

use C4::Context;
use C4::Languages;
use C4::Members;
use C4::Dates;
use C4::Boolean;
use C4::Letters;
use C4::Koha;
use C4::XSLT;
use C4::Branch;
use C4::Category;
=for preload
use C4::Tags; # FIXME
=cut

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

my $CGI_ROOT = $ENV{INTRANET} ? $ENV{INTRANETDIR} : $ENV{OPACDIR};
warn "# using Koha ", $ENV{INTRANET} ? 'intranet' : 'OPAC', " CGI from $CGI_ROOT\n";
my $app=Plack::App::CGIBin->new(root => $CGI_ROOT);
my $home = sub {
	return [ 302, [ Location => '/cgi-bin/koha/' . ( $ENV{INTRANET} ? 'mainpage.pl' : 'opac-main.pl' ) ] ];
};

builder {

	# please don't use plugins which are under enable_if $ENV{PLACK_DEBUG} in production!
	# they are known to leek memory
	enable_if { $ENV{PLACK_DEBUG} } 'Debug',  panels => [
		qw(Environment Response Timer Memory),
		# optional plugins (uncomment to enable) are sorted according to performance implact
#		[ 'Devel::Size', for => \&watch_for_size ], # https://github.com/dpavlin/p5-plack-devel-debug-devel-size
#		[ 'DBIProfile', profile => 2 ],
#		[ 'DBITrace', level => 1 ], # a LOT of fine-graded SQL trace
#		[ 'Profiler::NYTProf', exclude => [qw(.*\.css .*\.png .*\.ico .*\.js .*\.gif)] ],
	];

	# don't enable this plugin in production, since stack traces reveal too much information
	# about system to potential attackers!
	enable_if { $ENV{PLACK_DEBUG} } 'StackTrace';

	# this enables plackup or starman to serve static files and provide working plack
	# setup without need for front-end web server to serve static files
	enable_if { $ENV{INTRANETDIR} } "Plack::Middleware::Static",
		path => qr{^/(intranet|opac)-tmpl/},
		root => "$ENV{INTRANETDIR}/koha-tmpl/";

	mount "/cgi-bin/koha" => $app;
	mount "/" => $home;

};
