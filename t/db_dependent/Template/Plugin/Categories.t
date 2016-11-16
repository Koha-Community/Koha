use Modern::Perl;

use Test::More tests => 1;

use Koha::Database;
use Koha::Template::Plugin::Categories;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
$builder->build({ source => 'Category' });

my @categories = Koha::Template::Plugin::Categories->new->all;
isnt( scalar( @categories ), 0, 'Plugin Categories should return categories' );
my $selected_categories = [ grep { $_->{selected} } @categories ];

$schema->storage->txn_rollback;
