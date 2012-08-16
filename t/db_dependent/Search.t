#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use utf8;

use YAML;

use C4::Debug;
require C4::Context;

use Test::More tests => 57;
use Test::MockModule;
use MARC::Record;
use File::Spec;
use File::Basename;
use File::Find;
use Test::Warn;
use File::Temp qw/ tempdir /;
use File::Path;

my $datadir = tempdir();
system(dirname(__FILE__) . "/zebra_config.pl $datadir");
my $sourcedir = dirname(__FILE__) . "/data";

my $QueryStemming = 0;
my $QueryAutoTruncate = 0;
my $QueryWeightFields = 0;
my $QueryFuzzy = 0;
my $QueryRemoveStopwords = 0;
my $contextmodule = new Test::MockModule('C4::Context');
$contextmodule->mock('_new_dbh', sub {
    my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
    || die "Cannot create handle: $DBI::errstr\n";
    return $dbh });
$contextmodule->mock('preference', sub {
    my ($self, $pref) = @_;
    if ($pref eq 'NoZebra') {
        return 0;
    } elsif ($pref eq 'marcflavour') {
        return 'MARC21';
    } elsif ($pref eq 'QueryStemming') {
        return $QueryStemming;
    } elsif ($pref eq 'QueryAutoTruncate') {
        return $QueryAutoTruncate;
    } elsif ($pref eq 'QueryWeightFields') {
        return $QueryWeightFields;
    } elsif ($pref eq 'QueryFuzzy') {
        return $QueryFuzzy;
    } elsif ($pref eq 'QueryRemoveStopwords') {
        return $QueryRemoveStopwords;
    } elsif ($pref eq 'maxRecordsForFacets') {
        return 20;
    } elsif ($pref eq 'FacetLabelTruncationLength') {
        return 20;
    } elsif ($pref eq 'OpacHiddenItems') {
        return '';
    } elsif ($pref eq 'AlternateHoldingsField') {
        return '490av';
    } else {
        warn "The syspref $pref was requested but I don't know what to say; this indicates that the test requires updating"
            unless $pref =~ m/(XSLT|item|branch|holding|image|insecure)/i;
        return 0;
    }
});
$contextmodule->mock('marcfromkohafield', sub {
    my %hash = (
        '' => {
            'biblio.biblionumber' => [ '999', 'c' ],
            'items.barcode' => ['952', 'p' ],
            'items.booksellerid' => ['952', 'e' ],
            'items.ccode' => ['952', '8' ],
            'items.cn_sort' => ['952', '6' ],
            'items.cn_source' => ['952', '2' ],
            'items.coded_location_qualifier' => ['952', 'f' ],
            'items.copynumber' => ['952', 't' ],
            'items.damaged' => ['952', '4' ],
            'items.dateaccessioned' => ['952', 'd' ],
            'items.datelastborrowed' => ['952', 's' ],
            'items.datelastseen' => ['952', 'r' ],
            'items.enumchron' => ['952', 'h' ],
            'items.holdingbranch' => ['952', 'b' ],
            'items.homebranch' => ['952', 'a' ],
            'items.issues' => ['952', 'l' ],
            'items.itemcallnumber' => ['952', 'o' ],
            'items.itemlost' => ['952', '1' ],
            'items.itemnotes' => ['952', 'z' ],
            'items.itemnumber' => ['952', '9' ],
            'items.itype' => ['952', 'y' ],
            'items.location' => ['952', 'c' ],
            'items.materials' => ['952', '3' ],
            'items.nonpublicnote' => ['952', 'x' ],
            'items.notforloan' => ['952', '7' ],
            'items.onloan' => ['952', 'q' ],
            'items.price' => ['952', 'g' ],
            'items.renewals' => ['952', 'm' ],
            'items.replacementprice' => ['952', 'v' ],
            'items.replacementpricedate' => ['952', 'w' ],
            'items.reserves' => ['952', 'n' ],
            'items.restricted' => ['952', '5' ],
            'items.stack' => ['952', 'j' ],
            'items.uri' => ['952', 'u' ],
            'items.wthdrawn' => ['952', '0' ]
            }
        );
        return \%hash;
});
my $context = new C4::Context("$datadir/etc/koha-conf.xml");
$context->set_context();

use_ok('C4::Search');

foreach my $string ("Leçon","modèles") {
    my @results=C4::Search::_remove_stopwords($string,"kw");
    $debug && warn "$string ",Dump(@results);
    ok($results[0] eq $string,"$string is not modified");
}

foreach my $string ("A book about the stars") {
    my @results=C4::Search::_remove_stopwords($string,"kw");
    $debug && warn "$string ",Dump(@results);
    ok($results[0] ne $string,"$results[0] from $string");
}

my $indexes = C4::Search::getIndexes();
is(scalar(grep(/^ti$/, @$indexes)), 1, "Title index supported");

my $bibliomodule = new Test::MockModule('C4::Biblio');
$bibliomodule->mock('_get_inverted_marc_field_map', sub {
    my %hash = (
        '' => {
            '245' => { 'sfs' => { 'a' => [ [ 'biblio', 'title' ] ], 'b' => [ [ 'bibliosubtitle', 'subtitle' ] ] },
                'list' => [ [ 'a', 'biblio', 'title' ], [ 'b', 'bibliosubtitle', 'subtitle' ] ]
            },
            '100' => {
                'sfs' => { 'a' => [ [ 'biblio', 'author' ] ] },
                'list' => [ [ 'a', 'biblio', 'author' ] ]
            },
            '999' => {
                'sfs' => { 'c' => [ [ 'biblio', 'biblionumber' ] ], 'd' => [ [ 'biblioitems', 'biblioitemnumber' ] ] },
                'list' => [ [ 'd', 'biblioitems', 'biblioitemnumber' ], [ 'c', 'biblio', 'biblionumber' ] ]
            },
            '020' => {
                'sfs' => { 'a' => [ [ 'biblioitems', 'isbn' ] ] },
                'list' => [ [ 'a', 'biblioitems', 'isbn' ] ]
            }
        }
    );
    return \%hash;
});
my $dbh = C4::Context->dbh;
$dbh->{mock_add_resultset} = {
    sql     => 'SHOW COLUMNS FROM items',
    results => [
        [ 'itemnumber' ], [ 'biblionumber' ], [ 'biblioitemnumber' ],
        [ 'barcode' ], [ 'dateaccessioned' ], [ 'booksellerid' ],
        [ 'homebranch' ], [ 'price' ], [ 'replacementprice' ],
        [ 'replacementpricedate' ], [ 'datelastborrowed' ], [ 'datelastseen' ],
        [ 'stack' ], [ 'notforloan' ], [ 'damaged' ],
        [ 'itemlost' ], [ 'wthdrawn' ], [ 'itemcallnumber' ],
        [ 'issues' ], [ 'renewals' ], [ 'reserves' ],
        [ 'restricted' ], [ 'itemnotes' ], [ 'nonpublicnote' ],
        [ 'holdingbranch' ], [ 'paidfor' ], [ 'timestamp' ],
        [ 'location' ], [ 'permanent_location' ], [ 'onloan' ],
        [ 'cn_source' ], [ 'cn_sort' ], [ 'ccode' ],
        [ 'materials' ], [ 'uri' ], [ 'itype' ],
        [ 'more_subfields_xml' ], [ 'enumchron' ], [ 'copynumber' ],
        [ 'stocknumber' ],
    ]
};

my %branches = (
    'CPL' => { 'branchaddress1' => 'Jefferson Summit', 'branchcode' => 'CPL', 'branchname' => 'Centerville', },
    'FFL' => { 'branchaddress1' => 'River Station', 'branchcode' => 'FFL', 'branchname' => 'Fairfield', },
    'FPL' => { 'branchaddress1' => 'Hickory Squere', 'branchcode' => 'FPL', 'branchname' => 'Fairview', },
    'FRL' => { 'branchaddress1' => 'Smith Heights', 'branchcode' => 'FRL', 'branchname' => 'Franklin', },
    'IPT' => { 'branchaddress1' => '', 'branchcode' => 'IPT', 'branchname' => "Institut Protestant de Théologie", },
    'LPL' => { 'branchaddress1' => 'East Hills', 'branchcode' => 'LPL', 'branchname' => 'Liberty', },
    'MPL' => { 'branchaddress1' => '372 Forest Street', 'branchcode' => 'MPL', 'branchname' => 'Midway', },
    'PVL' => { 'branchaddress1' => 'Meadow Grove', 'branchcode' => 'PVL', 'branchname' => 'Pleasant Valley', },
    'RPL' => { 'branchaddress1' => 'Johnson Terrace', 'branchcode' => 'RPL', 'branchname' => 'Riverside', },
    'SPL' => { 'branchaddress1' => 'Highland Boulevard', 'branchcode' => 'SPL', 'branchname' => 'Springfield', },
    'S'   => { 'branchaddress1' => '', 'branchcode' => 'S', 'branchname' => 'Test', },
    'TPL' => { 'branchaddress1' => 'Valley Way', 'branchcode' => 'TPL', 'branchname' => 'Troy', },
    'UPL' => { 'branchaddress1' => 'Chestnut Hollow', 'branchcode' => 'UPL', 'branchname' => 'Union', },
);
my %itemtypes = (
    'BK' => { 'imageurl' => 'bridge/book.gif', 'summary' => '', 'itemtype' => 'BK', 'description' => 'Books' },
    'CF' => { 'imageurl' => 'bridge/computer_file.gif', 'summary' => '', 'itemtype' => 'CF', 'description' => 'Computer Files' },
    'CR' => { 'imageurl' => 'bridge/periodical.gif', 'summary' => '', 'itemtype' => 'CR', 'description' => 'Continuing Resources' },
    'MP' => { 'imageurl' => 'bridge/map.gif', 'summary' => '', 'itemtype' => 'MP', 'description' => 'Maps' },
    'MU' => { 'imageurl' => 'bridge/sound.gif', 'summary' => '', 'itemtype' => 'MU', 'description' => 'Music' },
    'MX' => { 'imageurl' => 'bridge/kit.gif', 'summary' => '', 'itemtype' => 'MX', 'description' => 'Mixed Materials' },
    'REF' => { 'imageurl' => '', 'summary' => '', 'itemtype' => 'REF', 'description' => 'Reference' },
    'VM' => { 'imageurl' => 'bridge/dvd.gif', 'summary' => '', 'itemtype' => 'VM', 'description' => 'Visual Materials' },
);

unlink("$datadir/zebra.log");
system("zebraidx -c $datadir/etc/koha/zebradb/zebra-biblios.cfg  -v none,fatal,warn  -g iso2709 -d biblios init");
system("zebraidx -c $datadir/etc/koha/zebradb/zebra-biblios.cfg  -v none,fatal,warn   -g iso2709 -d biblios update $sourcedir/zebraexport/biblio");
system("zebraidx -c $datadir/etc/koha/zebradb/zebra-biblios.cfg  -v none,fatal,warn  -g iso2709 -d biblios commit");

my $child = fork();
if ($child == 0) {
    exec("zebrasrv -f $datadir/etc/koha-conf.xml -v none,request -l $datadir/zebra.log");
    exit;
}

sleep(1);

my ($biblionumber, $title);
my $record = MARC::Record->new;

$record->add_fields(
        [ '020', ' ', ' ', a => '9788522421718' ],
        [ '245', '0', '0', a => 'Administração da produção /' ]
        );
($biblionumber,undef,$title) = FindDuplicate($record);
is($biblionumber, 51, 'Found duplicate with ISBN');

$record = MARC::Record->new;

$record->add_fields(
        [ '100', '1', ' ', a => 'Carter, Philip J.' ],
        [ '245', '1', '4', a => 'Test your emotional intelligence :' ]
        );
($biblionumber,undef,$title) = FindDuplicate($record);
is($biblionumber, 203, 'Found duplicate with author/title');

# Testing SimpleSearch

my ( $error, $marcresults, $total_hits ) = SimpleSearch("book", 0, 9);

is(scalar @$marcresults, 9, "SimpleSearch retrieved requested number of records");
is($total_hits, 101, "SimpleSearch for 'book' matched right number of records");
is($error, undef, "SimpleSearch does not return an error when successful");

my $marcresults2;
( $error, $marcresults2, $total_hits ) = SimpleSearch("book", 5, 5);
is($marcresults->[5], $marcresults2->[0], "SimpleSearch cursor functions");

( $error, $marcresults, $total_hits ) = SimpleSearch("kw=book", 0, 10);
is($total_hits, 101, "SimpleSearch handles simple CCL");

# Testing getRecords

my $results_hashref;
my $facets_loop;
( undef, $results_hashref, $facets_loop ) =
    getRecords('kw:book', 'book', [], [ 'biblioserver' ], '19', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
is($results_hashref->{biblioserver}->{hits}, 101, "getRecords keyword search for 'book' matched right number of records");
is(scalar @{$results_hashref->{biblioserver}->{RECORDS}}, 19, "getRecords returned requested number of records");
my $record5 = $results_hashref->{biblioserver}->{RECORDS}->[5];
( undef, $results_hashref, $facets_loop ) =
    getRecords('kw:book', 'book', [], [ 'biblioserver' ], '20', 5, undef, \%branches, \%itemtypes, 'ccl', undef);
ok(!defined $results_hashref->{biblioserver}->{RECORDS}->[0] &&
    !defined $results_hashref->{biblioserver}->{RECORDS}->[1] &&
    !defined $results_hashref->{biblioserver}->{RECORDS}->[2] &&
    !defined $results_hashref->{biblioserver}->{RECORDS}->[3] &&
    !defined $results_hashref->{biblioserver}->{RECORDS}->[4] &&
    $results_hashref->{biblioserver}->{RECORDS}->[5] eq $record5, "getRecords cursor works");

( undef, $results_hashref, $facets_loop ) =
    getRecords('ti:book', 'ti:book', [], [ 'biblioserver' ], '20', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
is($results_hashref->{biblioserver}->{hits}, 11, "getRecords title search for 'book' matched right number of records");

( undef, $results_hashref, $facets_loop ) =
    getRecords('au:Lessig', 'au:Lessig', [], [ 'biblioserver' ], '20', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
is($results_hashref->{biblioserver}->{hits}, 4, "getRecords title search for 'Australia' matched right number of records");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [], [ 'biblioserver' ], '19', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0])->title_proper() =~ m/^Efectos del ambiente/ &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[7])->title_proper() eq 'Salud y seguridad de los trabajadores del sector salud: manual para gerentes y administradores^ies' &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[18])->title_proper() =~ m/^Indicadores de resultados identificados/
    , "Simple relevance sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'author_az' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0])->title_proper() =~ m/la enfermedad laboral\^ies$/ &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[6])->title_proper() =~ m/^Indicadores de resultados identificados/ &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[18])->title_proper() eq 'World health statistics 2009^ien'
    , "Simple ascending author sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'author_za' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0])->title_proper() eq 'World health statistics 2009^ien' &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[12])->title_proper() =~ m/^Indicadores de resultados identificados/ &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[18])->title_proper() =~ m/la enfermedad laboral\^ies$/
    , "Simple descending author sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'pubdate_asc' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0])->title_proper() eq 'Manual de higiene industrial^ies' &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[7])->title_proper() =~ m/seguridad e higiene del trabajo\^ies$/ &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[18])->title_proper() =~ m/^Indicadores de resultados identificados/
    , "Simple ascending publication date sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'pubdate_dsc' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0])->title_proper() =~ m/^Estado de salud/ &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[7])->title_proper() eq 'World health statistics 2009^ien' &&
    MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[18])->title_proper() eq 'Manual de higiene industrial^ies'
    , "Simple descending publication date sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('books', 'books', [ 'relevance' ], [ 'biblioserver' ], '20', 0, undef, \%branches, \%itemtypes, undef, 1);
$record = MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0]);
is($record->title_proper(), 'books', "Scan returned requested item");
is($record->subfield('100', 'a'), 2, "Scan returned correct number of records matching term");

# Time to test buildQuery and searchResults too.

my ( $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type );
( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'salud' ], [], [], [], 0, 'en');
like($query, qr/kw\W.*salud/, "Built CCL keyword query");

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 19, "getRecords generated keyword search for 'salud' matched right number of records");

my @newresults = searchResults('opac', $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 18, 0, 0,
    $results_hashref->{'biblioserver'}->{"RECORDS"});
is(scalar @newresults,18, "searchResults returns requested number of hits");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([ 'and' ], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
like($query, qr/kw\W.*salud\W.*and.*kw\W.*higiene/, "Built composed explicit-and CCL keyword query");

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 3, "getRecords generated composed keyword search for 'salud' explicit-and 'higiene' matched right number of records");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([ 'or' ], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
like($query, qr/kw\W.*salud\W.*or.*kw\W.*higiene/, "Built composed explicit-or CCL keyword query");

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 20, "getRecords generated composed keyword search for 'salud' explicit-or 'higiene' matched right number of records");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
like($query, qr/kw\W.*salud\W.*and.*kw\W.*higiene/, "Built composed implicit-and CCL keyword query");

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 3, "getRecords generated composed keyword search for 'salud' implicit-and 'higiene' matched right number of records");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'salud' ], [ 'kw' ], [ 'su-to:Laboratorios' ], [], 0, 'en');
like($query, qr/kw\W.*salud\W*and\W*su-to\W.*Laboratorios/, "Faceted query generated correctly");
unlike($query_desc, qr/Laboratorios/, "Facets not included in query description");

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated faceted search matched right number of records");


( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'mc-itype:MP', 'mc-itype:MU' ], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated mc-faceted search matched right number of records");


( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'mc-loc:GEN', 'branch:FFL' ], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated multi-faceted search matched right number of records");


# FIXME: the availability limit does not actually work, so for the moment we
# are just checking that it behaves consistently
( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'available' ], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 26, "getRecords generated availability-limited search matched right number of records");

@newresults = searchResults('opac', $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 17, 0, 0,
    $results_hashref->{'biblioserver'}->{"RECORDS"});
my $allavailable = 'true';
foreach my $result (@newresults) {
    $allavailable = 'false' unless $result->{availablecount} > 0;
}
is ($allavailable, 'true', 'All records have at least one item available');


( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'pqf=@attr 1=_ALLRECORDS @attr 2=103 ""' ], [], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 178, "getRecords on _ALLRECORDS PQF returned all records");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'pqf=@attr 1=1016 "Lessig"' ], [], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 4, "getRecords PQF author search for Lessig returned proper number of matches");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'ccl=au:Lessig' ], [], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 4, "getRecords CCL author search for Lessig returned proper number of matches");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'cql=dc.author any lessig' ], [], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 4, "getRecords CQL author search for Lessig returned proper number of matches");

$QueryStemming = $QueryAutoTruncate = $QueryFuzzy = $QueryRemoveStopwords = 0;
$QueryWeightFields = 1;
( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'salud' ], [ 'kw' ], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 19, "Weighted query returned correct number of results");
is(MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0])->title_proper(), 'Salud y seguridad de los trabajadores del sector salud: manual para gerentes y administradores^ies', "Weighted query returns best match first");

$QueryStemming = $QueryWeightFields = $QueryFuzzy = $QueryRemoveStopwords = 0;
$QueryAutoTruncate = 1;
( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'medic' ], [ 'kw' ], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic' returns matches  with automatic truncation on");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'medic*' ], [ 'kw' ], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic*' returns matches with automatic truncation on");

$QueryStemming = $QueryWeightFields = $QueryFuzzy = $QueryRemoveStopwords = $QueryAutoTruncate = 0;
( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'medic' ], [ 'kw' ], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, undef, "Search for 'medic' returns no matches with automatic truncation off");

( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'medic*' ], [ 'kw' ], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic*' returns matches with automatic truncation off");

$QueryStemming = $QueryWeightFields = 1;
$QueryFuzzy = $QueryRemoveStopwords = $QueryAutoTruncate = 0;
( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'pressed' ], [ 'kw' ], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, 7, "Search for 'pressed' returns matches when stemming (and query weighting) is on");

$QueryStemming = $QueryWeightFields = $QueryFuzzy = $QueryRemoveStopwords = $QueryAutoTruncate = 0;
( $error, $query, $simple_query, $query_cgi,
$query_desc, $limit, $limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = buildQuery([], [ 'pressed' ], [ 'kw' ], [], [], 0, 'en');

($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
is($results_hashref->{biblioserver}->{hits}, undef, "Search for 'pressed' returns no matches when stemming is off");

# Let's see what happens when we pass bad data into these routines.
# We have to catch warnings since we're not very good about returning errors.

warning_like { ( $error, $marcresults, $total_hits ) = SimpleSearch("@==ccl blah", 0, 9) } qr/CCL parsing error/,
    "SimpleSearch warns about CCL parsing error with nonsense query";
isnt($error, undef, "SimpleSearch returns an error when passed gibberish");

warning_like {( undef, $results_hashref, $facets_loop ) =
    getRecords('kw:book', 'book', [], [ 'biblioserver' ], '19', 0, undef, \%branches, \%itemtypes, 'nonsense', undef) }
    qr/Unknown query_type/, "getRecords warns about unknown query type";

warning_like {( undef, $results_hashref, $facets_loop ) =
    getRecords('pqf=@attr 1=4 "title"', 'pqf=@attr 1=4 "title"', [], [ 'biblioserver' ], '19', 0, undef, \%branches, \%itemtypes, '', undef) }
    qr/WARNING: query problem/, "getRecords warns when query type is not specified for non-CCL query";

# Let's just test a few other bits and bobs, just for fun

($error, $results_hashref, $facets_loop) = getRecords("Godzina pąsowej róży","Godzina pąsowej róży",[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
@newresults = searchResults('intranet', $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 17, 0, 0,
    $results_hashref->{'biblioserver'}->{"RECORDS"});
is($newresults[0]->{'alternateholdings_count'}, 1, 'Alternate holdings filled in correctly');

END {
    if ($child) {
        kill 9, $child;

        # Clean up the Zebra files since the child process was just shot
        rmtree $datadir;
    }
}

1;
