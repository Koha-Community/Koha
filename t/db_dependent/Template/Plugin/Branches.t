use Modern::Perl;

use Test::More tests => 11;

use C4::Context;
use Koha::Library;
use Koha::Libraries;
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
my $library = Koha::Libraries->search->next->unblessed;

my $plugin = Koha::Template::Plugin::Branches->new();
ok($plugin, "initialized Branches plugin");

my $name = $plugin->GetName($library->{branchcode});
is($name, $library->{branchname}, 'retrieved expected name for library');

$name = $plugin->GetName('__ANY__');
is($name, '', 'received empty string as name of the "__ANY__" placeholder library code');

$name = $plugin->GetName(undef);
is($name, '', 'received empty string as name of NULL/undefined library code');

$library = $plugin->GetLoggedInBranchcode();
is($library, '', 'no active library if there is no active user session');
C4::Context->_new_userenv('DUMMY_SESSION_ID');
C4::Context->set_userenv(123, 'userid', 'usercnum', 'First name', 'Surname', 'MYLIBRARY', 'My Library', 0);
$library = $plugin->GetLoggedInBranchcode();
is($library, 'MYLIBRARY', 'GetLoggedInBranchcode() returns active library');

my $branches = $plugin->all;
my $test_branches = [ grep { $_->{branchcode} =~ m|^test_br_| } @$branches ];
is( scalar( @$test_branches ), 5, 'Plugin Branches should return the branches' );
my $selected_branches = [ grep { $_->{selected} } @$branches ];
is( scalar( @$selected_branches ), 0, 'Plugin Branches should not select a branch if not needed' );

$branches = $plugin->all({selected => 'test_br_3'});
$test_branches = [ grep { $_->{branchcode} =~ m|^test_br_| } @$branches ];
is( scalar( @$test_branches ), 5, 'Plugin Branches should return the branches if selected passed' );
$selected_branches = [ grep { $_->{selected} } @$branches ];
is( scalar( @$selected_branches ), 1, 'Plugin Branches should return only 1 selected if passed' );
is( $selected_branches->[0]->{branchcode}, 'test_br_3', 'Plugin Branches should select the good one' );
