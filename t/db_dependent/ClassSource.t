#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 25;
use Test::Warn;

use C4::Context;

BEGIN {
    use_ok('C4::ClassSource');
}
can_ok( 'C4::ClassSource',
    qw( AddClassSortRule
        AddClassSource
        GetClassSort
        GetClassSortRule
        GetClassSortRules
        GetClassSource
        GetClassSources
        DelClassSortRule
        DelClassSource
        GetSourcesForSortRule
        ModClassSortRule
        ModClassSource)
);

#Start transaction
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

#Start tests
$dbh->do(q|DELETE FROM class_sources|);
$dbh->do(q|DELETE FROM class_sort_rules|);

#Test AddClassSortRule
my $countSources  = scalar( keys(%{ GetClassSources() }) );
my $countSources2 = scalar( keys(%{ GetClassSortRules() }) );
AddClassSortRule( 'sortrule1', 'description1', 'routine1' );
AddClassSortRule( 'sortrule2', 'description2', 'routine2' );
is(
    scalar( keys(%{ GetClassSortRules() }) ),
    $countSources + 2,
    "SortRule1 and SortRules2 have been added"
);

#Test AddClassSource
AddClassSource( 'source1', 'Description_source1', 1, 'sortrule1' );
AddClassSource( 'source2', 'Description_source2', 0, 'sortrule1' );
is(
    scalar( keys(%{ GetClassSources() }) ),
    $countSources2 + 2,
    "Source1 and source2 have been added"
);

#Test GetClassSortRule
is_deeply(
    GetClassSortRule('sortrule1'),
    {
        class_sort_rule => 'sortrule1',
        description     => 'description1',
        sort_routine    => 'routine1'
    },
    "GetClassSort gives sortrule1's information"
);
is_deeply( GetClassSortRule(), undef,
    "GetClassSort without params returns undef" );
is_deeply( GetClassSortRule('doesnt_exist'),
    undef, "GetClassSort with an id which doesn't exist returns undef" );

#Test GetClassSortRules
my $getsortrules = GetClassSortRules();
is_deeply(
    $getsortrules,
    {
        sortrule1 => {
            class_sort_rule => 'sortrule1',
            description     => 'description1',
            sort_routine    => 'routine1'
        },
        sortrule2 => {
            class_sort_rule => 'sortrule2',
            description     => 'description2',
            sort_routine    => 'routine2'
        }
    },
    "GetClassSortRules returns the id off all SortRule and their information"
);

#Test GetClassSource
my $getsource1 = GetClassSource('source1');
is_deeply(
    $getsource1,
    {
        cn_source       => 'source1',
        description     => 'Description_source1',
        used            => 1,
        class_sort_rule => 'sortrule1'
    },
    "GetClassSource gives source1's information"
);
is_deeply( GetClassSource(), undef,
    "GetClassSource without params returns undef" );
is_deeply( GetClassSource('doesnt_exist'),
    undef, "GetClassSource with an id which doesn't exist returns undef" );

#Test GetClassSources
my $getsources = GetClassSources();
is_deeply(
    $getsources,
    {
        source1 => {
            cn_source       => 'source1',
            description     => 'Description_source1',
            used            => 1,
            class_sort_rule => 'sortrule1'
        },
        source2 => {
            cn_source       => 'source2',
            description     => 'Description_source2',
            used            => 0,
            class_sort_rule => 'sortrule1'
        }
    },
    "GetClassSources returns the id off all sources and their information"
);

#Test GetClassSort
my $getclassSort;
#Note: Create a warning:" attempting to use non-existent class sorting routine $sort_routine"
warning_like
    { $getclassSort = GetClassSort( 'source1', 'sortrule1', 'item1' ) }
    qr/attempting to use non-existent class sorting routine/,
    'Non-existent class warning caught';
is( $getclassSort, "SORTRULE1_ITEM1",
" the sort key corresponding to Source1 and sortrule1 and item1 is SORTRULE1_ITEM1"
);

#Test GetSourcesForSorSortRule
my @sources = GetSourcesForSortRule('sortrule1');
is_deeply(
    \@sources,
    [ 'source1', 'source2' ],
    "Sortrule1 has source1 and source2"
);
@sources = GetSourcesForSortRule();
is_deeply( \@sources, [],
    "Without params GetSourcesForSortRule returns an empty array" );
@sources = GetSourcesForSortRule('doesnt_exist');
is_deeply( \@sources, [],
    "With a wrong params GetSourcesForSortRule returns an empty array" );

#Test DelClassSortRule
#DelClassSortRule ('sortrule1');
#is(scalar (keys (%{ GetClassSortRules() })),1,"SortRule1 has been deleted");#FIXME : impossible if some sources exist
DelClassSortRule('sortrule2');
is( scalar( keys(%{ GetClassSortRules() }) ), 1, "SortRule2 has been deleted" );
DelClassSortRule();
is( scalar( keys(%{ GetClassSortRules() }) ),
    1, "Without params DelClassSortRule doesn't do anything" );
DelClassSortRule('doesnt_exist');
is( scalar( keys(%{ GetClassSortRules() }) ),
    1, "With wrong id, DelClassSortRule doesn't do anything" );

#Test DelClassSource
DelClassSource('source2');
is( scalar( keys(%{ GetClassSources() }) ), 1, "Source2 has been deleted" );
DelClassSource();
is( scalar( keys(%{ GetClassSources() }) ),
    1, "Without params DelClassSource doesn't do anything" );
DelClassSource('doesnt_exist');
is( scalar( keys(%{ GetClassSources() }) ),
    1, "With wrong id, DelClassSource doesn't do anything" );

#Test ModClassSortRule
ModClassSortRule( 'sortrule1', 'description1_modified', 'routine1_modified' );
is_deeply(
    GetClassSortRule('sortrule1'),
    {
        class_sort_rule => 'sortrule1',
        description     => 'description1_modified',
        sort_routine    => 'routine1_modified'
    },
    "Sortrule1 has been modified"
);

#Test ModClassSource
ModClassSource( 'source1', 'Description_source1_modified', 0, 'sortrule1' );
is_deeply(
    GetClassSource('source1'),
    {
        cn_source       => 'source1',
        description     => 'Description_source1_modified',
        used            => 0,
        class_sort_rule => 'sortrule1'
    },
    "Source1 has been modified"
);

#End transaction
$dbh->rollback;
