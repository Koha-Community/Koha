#!/usr/bin/perl

use Modern::Perl;

use List::MoreUtils 'any';

use Test::More tests => 19;

use t::lib::TestBuilder;

BEGIN {
    use FindBin;
    use lib $FindBin::Bin;
    use_ok('Koha::Library::Group');
    use_ok('Koha::Library::Groups');
}

our $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM library_groups|);

my $builder = t::lib::TestBuilder->new();

my $library1 = $builder->build( { source => 'Branch' } );
my $library2 = $builder->build( { source => 'Branch' } );
my $library3 = $builder->build( { source => 'Branch' } );
my $library4 = $builder->build( { source => 'Branch' } );
my $library5 = $builder->build( { source => 'Branch' } );
my $library6 = $builder->build( { source => 'Branch' } );
my $library7 = $builder->build( { source => 'Branch' } );

my $root_group =
  Koha::Library::Group->new( { title => "Test root group" } )->store();

my @root_groups = Koha::Library::Groups->get_root_groups();
my $in_list = any { $_->id eq $root_group->id } @root_groups;
ok( $in_list, 'New root group is in the list returned by the get_root_groups method');

my $groupA  = Koha::Library::Group->new({ parent_id => $root_group->id, title => 'Group A' })->store();
my $groupA1 = Koha::Library::Group->new({ parent_id => $groupA->id,     title => 'Group A1' })->store();
my $groupA2 = Koha::Library::Group->new({ parent_id => $groupA->id,     title => 'Group A2' })->store();
my $groupB  = Koha::Library::Group->new({ parent_id => $root_group->id, title => 'Group B' })->store();

my $groupA_library1  = Koha::Library::Group->new({ parent_id => $groupA->id,  branchcode => $library1->{branchcode} })->store();
my $groupB_library1  = Koha::Library::Group->new({ parent_id => $groupB->id,  branchcode => $library1->{branchcode} })->store();
my $groupA1_library2 = Koha::Library::Group->new({ parent_id => $groupA1->id, branchcode => $library2->{branchcode} })->store();

my @children = $root_group->children()->as_list();
is( $children[0]->id, $groupA->id, 'Child of root group set correctly' );

@children = $groupA->children()->as_list();
is( $children[1]->id, $groupA1->id, 'Child 1 of 2nd level group set correctly' );
is( $children[2]->id, $groupA2->id, 'Child 2 of 2nd level group set correctly' );
is( $children[0]->id, $groupA_library1->id, 'Child 3 of 2nd level group set correctly' );

is( $children[0]->branchcode, $groupA_library1->branchcode, 'Child 3 is correctly set as leaf node' );

@children = $groupA1->children()->as_list();
is( $children[0]->branchcode, $library2->{branchcode}, 'Child 1 of 3rd level group correctly set as leaf node' );

my $library = $groupA_library1->library();
is( ref( $library ), 'Koha::Library', 'Method library returns a Koha::Library object' );
is( $library->id, $groupA_library1->branchcode, 'Branchcode for fetched library matches' );

my @libraries_not_direct_children = $groupA->libraries_not_direct_children();
$in_list = any { $_->id eq $groupA_library1->branchcode } @libraries_not_direct_children;
ok( !$in_list, 'Method libraries_not_direct_children returns all libraries not direct descendants of group, library 1 is not in the list');
$in_list = any { $_->id eq $groupA1_library2->branchcode } @libraries_not_direct_children;
ok( $in_list, 'Method libraries_not_direct_children returns all libraries not direct descendants of group, library 2 is in the list');

subtest 'Koha::Library->library_groups' => sub {
    plan tests => 4;
    my $library3 = Koha::Libraries->find( $library3->{branchcode} );
    my $groups = $library3->library_groups;
    is( ref( $groups ), 'Koha::Library::Groups', 'Koha::Library->library_groups should return Koha::Library::Groups' );
    is( $groups->count, 0, 'Library 3 should not be part of any groups');

    my $library1 = Koha::Libraries->find( $library1->{branchcode} );
    $groups = $library1->library_groups;
    is( ref( $groups ), 'Koha::Library::Groups', 'Koha::Library->library_groups should return Koha::Library::Groups' );
    is( $groups->count, 2, 'Library 1 should be part of 2 groups' );
};

# root_group
#     + groupA
#         + groupA1
#             + groupA1_library2
#         + groupA_library1
#         + groupA2
#     + groupB
#         + groupB_library1

subtest 'Koha::Library::Group->has_child' => sub {
    plan tests => 2;
    is( $groupA->has_child( $library1->{branchcode} ), 1, 'library1 should be condidered as a child of groupA' );
    is( $groupB->has_child( $library2->{branchcode} ), 0, 'library2 should not be considered as a child of groupB' );

    # TODO This is not implemented because not used yet
    # ->has_child only works with libraries
    #is( $groupA->has_child( $groupA1 ), 1, 'groupA1 should be condidered as a child of groupA' );

    # FIXME At the time of writing this test fails because the ->children methods does not return more than 1 level of depth
    # See Bug 15707 comments 166-170+
    #is( $groupA->has_child( $groupA1_library2->branchcode ), 1, 'groupA1_library2 should be considered as a child of groupA (it is a grandchild)' );
};

my $groupX = Koha::Library::Group->new( { title => "Group X" } )->store();
my $groupX_library1 = Koha::Library::Group->new({ parent_id => $groupX->id,  branchcode => $library1->{branchcode} })->store();
my $groupX_library2 = Koha::Library::Group->new({ parent_id => $groupX->id,  branchcode => $library2->{branchcode} })->store();
my $groupX1 = Koha::Library::Group->new({ parent_id => $groupX->id, title => 'Group X1' })->store();
my $groupX1_library3 = Koha::Library::Group->new({ parent_id => $groupX1->id,  branchcode => $library3->{branchcode} })->store();
my $groupX1_library4 = Koha::Library::Group->new({ parent_id => $groupX1->id,  branchcode => $library4->{branchcode} })->store();
my $groupX2 = Koha::Library::Group->new({ parent_id => $groupX->id, title => 'Group X2' })->store();
my $groupX2_library5 = Koha::Library::Group->new({ parent_id => $groupX2->id,  branchcode => $library5->{branchcode} })->store();
my $groupX2_library6 = Koha::Library::Group->new({ parent_id => $groupX2->id,  branchcode => $library6->{branchcode} })->store();

my @branchcodes = sort( $library1->{branchcode}, $library2->{branchcode} );
my @group_branchcodes = sort( map { $_->branchcode } $groupX->libraries->as_list );
is_deeply( \@branchcodes, \@group_branchcodes, "Group libraries are returned correctly" );
is( ref($groupX->libraries), 'Koha::Libraries', '->libraries should return a Koha::Libraries iterator' );

@branchcodes = sort( $library1->{branchcode}, $library2->{branchcode}, $library3->{branchcode}, $library4->{branchcode}, $library5->{branchcode}, $library6->{branchcode} );
@group_branchcodes = sort( map { $_->branchcode } $groupX->all_libraries );
is_deeply( \@branchcodes, \@group_branchcodes, "Group all_libraries are returned correctly" );
is( ref(($groupX->all_libraries)[0]), 'Koha::Library', '->all_libraries should return a list of Koha::Library - in the future it should be fixed to return a Koha::Libraries iterator instead'); # FIXME
