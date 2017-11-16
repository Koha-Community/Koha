#!/usr/bin/perl

use Modern::Perl;
use Data::Dumper;
use utf8;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use Carp::Always;
use Try::Tiny;
use Scalar::Util qw(blessed);

use Getopt::Long qw(:config no_ignore_case);
use Cache::Memcached::Fast;

use C4::Context;



my $help;

GetOptions(
    'h|help'                      => \$help,
);

my $usage = <<USAGE;

This script checks if memcached connection works.
It is intended to be a part of the Ansible build chain, but can be invoked from for ex.
some monitoring solution to find out that Koha does actually utilize memcached.

 -h --help             This nice help

EXIT VALUES

    This script exits with 0, if memcached connection works.

USAGE

if ($help) {
  print $usage;
  exit 0;
}

my $survivalInstructions = <<SURVIVE;

To debug memcached issues, go to the memcached server and set verbosity to
    -vv

This is done by editing /etc/memcached.conf
and writing or uncommenting the above

Then:

systemctl restart memcached
journalctl -u memached -f

Observe if Koha can reach memcached, and you start to see memcached internal debug logging.

If nothing pops up in the logs, check memcached server address in \$KOHA_CONF and
make sure memcached listens on the correct IP/socket, governed by the -l and -s directives
in the memcached conf.


If more varied ways of fault appear, please document them here.

SURVIVE

##DUPLICATION WARNING FROM Koha::Cache->new()
my $namespace = C4::Context->config('memcached_namespace') || 'koha';
die "Couldn't load the 'memcached_namespace' from \$KOHA_CONF" unless $namespace;
my @servers = split /,/, C4::Context->config('memcached_servers') || '';
die "Couldn't load 'memcached_servers' from \$KOHA_CONF" unless @servers;
##End of duplication

my $memcached = Cache::Memcached::Fast->new(
  {
    servers            => \@servers,
    namespace          => $namespace,
  }
);

# Ensure we can actually talk to the memcached server
my $ismemcached = $memcached->set('ansible-connection-test','1');
if (not($ismemcached) && defined($ismemcached)) {
  die "Memcached can be reached, but some strange reason caused the set-command to fail.\n$survivalInstructions";
}
elsif (not(defined($ismemcached))) {
  die "Memcached can not be reached, most certainly the IP/socket is misconfigured or the memcached server is down.\n$survivalInstructions";
}

my $v = $memcached->server_versions();
print "Memcached connection verified, current servers:\n";
foreach my $address (keys %$v) {
  print '    '.$address.' => '.$v->{$address}."\n";
}

exit 0;
