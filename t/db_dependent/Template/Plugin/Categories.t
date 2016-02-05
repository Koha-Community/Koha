use Modern::Perl;

use Test::More tests => 5;

use C4::Context;
use Koha::Template::Plugin::Categories;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my @categories = Koha::Template::Plugin::Categories->new->all;
isnt( scalar( @categories ), 0, 'Plugin Categories should return categories' );
my $selected_categories = [ grep { $_->{selected} } @categories ];
is( scalar( @$selected_categories ), 0, 'Plugin Categories should not select one if not given' );

my $category = $categories[-1];
@categories = Koha::Template::Plugin::Categories->new->all({selected => $category->{categorycode}});
isnt( scalar( @categories ), 0, 'Plugin Categories should return categories if selected needed' );
$selected_categories = [ grep { $_->{selected} } @categories ];
is( scalar( @$selected_categories ), 1, 'Plugin Categories should select only 1 category' );
is( $selected_categories->[0]->{categorycode}, $category->{categorycode}, 'Plugin Categories should select the good one' );
