use Modern::Perl;

use Test::More tests => 5;

use C4::Context;
use Koha::Library;
use Koha::Template::Plugin::Branches;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

for my $i ( 1 .. 5 ) {
    Koha::Library->new(
{
        branchcode     => "test_br_$i",
        branchname     => "test_br_$i",
}
    )->store;

}

my $branches = Koha::Template::Plugin::Branches->new->all;
my $test_branches = [ grep { $_->{branchcode} =~ m|^test_br_| } @$branches ];
is( scalar( @$test_branches ), 5, 'Plugin Branches should return the branches' );
my $selected_branches = [ grep { $_->{selected} } @$branches ];
is( scalar( @$selected_branches ), 0, 'Plugin Branches should not select a branch if not needed' );

$branches = Koha::Template::Plugin::Branches->new->all({selected => 'test_br_3'});
$test_branches = [ grep { $_->{branchcode} =~ m|^test_br_| } @$branches ];
is( scalar( @$test_branches ), 5, 'Plugin Branches should return the branches if selected passed' );
$selected_branches = [ grep { $_->{selected} } @$branches ];
is( scalar( @$selected_branches ), 1, 'Plugin Branches should return only 1 selected if passed' );
is( $selected_branches->[0]->{branchcode}, 'test_br_3', 'Plugin Branches should select the good one' );
