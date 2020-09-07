use Modern::Perl;
use Test::More tests => 2;

use_ok('Koha::Template::Plugin::Cache');

ok(my $cache = Koha::Template::Plugin::Cache->new());
