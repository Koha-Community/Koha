#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use utf8;

use C4::AuthoritiesMarc qw( SearchAuthorities );
use C4::XSLT;
require C4::Context;

# work around spurious wide character warnings
use open ':std', ':encoding(utf8)';

use Test::More tests => 3;
use Test::MockModule;
use Test::Warn;
use t::lib::Mocks;
use t::lib::Mocks::Zebra;

use Koha::Caches;

use MARC::Record;
use File::Spec;
use File::Basename;
use File::Find;

use File::Temp qw/ tempdir /;
use File::Path;

# Fall back to make sure that the Zebra process
# and files get cleaned up
our @cleanup;

sub matchesExplodedTerms {
    my ($message, $query, @terms) = @_;
    my $match = '(' . join ('|', map { " \@attr 1=Subject \@attr 4=1 \"$_\"" } @terms) . "){" . scalar(@terms) . "}";
    like($query, qr/$match/, $message);
}

our $QueryStemming = 0;
our $QueryAutoTruncate = 0;
our $QueryWeightFields = 0;
our $QueryFuzzy = 0;
our $SearchEngine = 'Zebra';
our $marcflavour = 'MARC21';
our $htdocs = File::Spec->rel2abs(dirname($0));
my @htdocs = split /\//, $htdocs;
$htdocs[-2] = 'koha-tmpl';
$htdocs[-1] = 'opac-tmpl';
$htdocs = join '/', @htdocs;
our $contextmodule = Test::MockModule->new('C4::Context');
$contextmodule->mock('preference', sub {
    my ($self, $pref) = @_;
    if ($pref eq 'marcflavour') {
        return $marcflavour;
    } elsif ($pref eq 'QueryStemming') {
        return $QueryStemming;
    } elsif ($pref eq 'QueryAutoTruncate') {
        return $QueryAutoTruncate;
    } elsif ($pref eq 'QueryWeightFields') {
        return $QueryWeightFields;
    } elsif ($pref eq 'QueryFuzzy') {
        return $QueryFuzzy;
    } elsif ($pref eq 'SearchEngine') {
        return $SearchEngine;
    } elsif ($pref eq 'maxRecordsForFacets') {
        return 20;
    } elsif ($pref eq 'FacetLabelTruncationLength') {
        return 20;
    } elsif ($pref eq 'FacetMaxCount') {
        return 20;
    } elsif ($pref eq 'OpacHiddenItems') {
        return '';
    } elsif ($pref eq 'opacthemes') {
        return 'bootstrap';
    } elsif ($pref eq 'OPACLanguages') {
        return 'en';
    } elsif ($pref eq 'AlternateHoldingsField') {
        return '490av';
    } elsif ($pref eq 'AuthoritySeparator') {
        return '--';
    } elsif ($pref eq 'DisplayLibraryFacets') {
        return 'holding';
    } elsif ($pref eq 'UNIMARCAuthorsFacetsSeparator') {
        return '--';
    } elsif ($pref eq 'casAuthentication' or $pref eq 'casLogout' or $pref eq 'casServerUrl' ) {
        return '';
    } elsif ($pref eq 'template') {
        return 'prog';
    } elsif ($pref eq 'OPACXSLTResultsDisplay') {
        return C4::XSLT::_get_best_default_xslt_filename($htdocs, 'bootstrap','en',$marcflavour . 'slim2OPACResults.xsl');
    } elsif ($pref eq 'BiblioDefaultView') {
        return 'normal';
    } elsif ($pref eq 'IdRef') {
        return '0';
    } elsif ($pref eq 'IntranetBiblioDefaultView') {
        return 'normal';
    } elsif ($pref eq 'OPACBaseURL') {
        return 'http://library.mydnsname.org';
    } elsif ($pref eq 'OPACResultsLibrary') {
        return 'homebranch';
    } elsif ($pref eq 'OpacSuppression') {
        return '0';
    } elsif ($pref eq 'OPACURLOpenInNewWindow') {
        return '0';
    } elsif ($pref eq 'TraceCompleteSubfields') {
        return '0';
    } elsif ($pref eq 'TraceSubjectSubdivisions') {
        return '0';
    } elsif ($pref eq 'TrackClicks') {
        return '0';
    } elsif ($pref eq 'URLLinkText') {
        return q{};
    } elsif ($pref eq 'UseAuthoritiesForTracings') {
        return '1';
    } elsif ($pref eq 'UseControlNumber') {
        return '0';
    } elsif ($pref eq 'UseICUStyleQuotes') {
        return '0';
    } elsif ($pref eq 'viewISBD') {
        return '1';
    } elsif ($pref eq 'EasyAnalyticalRecords') {
        return '0';
    } elsif ($pref eq 'OpenURLResolverURL') {
        return '0';
    } elsif ($pref eq 'OPACShowOpenURL') {
        return '0';
    } elsif ($pref eq 'OpenURLText') {
        return '0';
    } elsif ($pref eq 'OPACShowMusicalInscripts') {
        return '0';
    } elsif ($pref eq 'OPACPlayMusicalInscripts') {
        return '0';
    } elsif ($pref eq 'Reference_NFL_Statuses') {
        return '0';
    } elsif ($pref eq 'FacetOrder') {
        return 'Alphabetical';
    } elsif ($pref eq 'OPACResultsUnavailableGroupingBy') {
        return 'branch';
    } elsif ($pref eq 'SearchLimitLibrary') {
        return 'both';
    } elsif ($pref eq 'UseRecalls') {
        return '0';
    } else {
        warn "The syspref $pref was requested but I don't know what to say; this indicates that the test requires updating"
            unless $pref =~ m/(XSLT|item|branch|holding|image)/i;
        return 0;
    }
});

our $bibliomodule = Test::MockModule->new('C4::Biblio');

sub mock_GetMarcSubfieldStructure {
    my $marc_type = shift;
    if ($marc_type eq 'MARC21') {
        $bibliomodule->mock('GetMarcSubfieldStructure', sub {
            return {
                    'biblio.biblionumber' => [{ tagfield =>  '999', tagsubfield => 'c' }],
                    'biblio.isbn' => [{ tagfield => '020', tagsubfield => 'a' }],
                    'biblio.title' => [{ tagfield => '245', tagsubfield => 'a' }],
                    'biblio.author' => [{ tagfield => '100', tagsubfield => 'a' }],
                    'biblio.notes' => [{ tagfield => '500', tagsubfield => 'a' }],
                    'items.barcode' => [{ tagfield => '952', tagsubfield => 'p' }],
                    'items.booksellerid' => [{ tagfield => '952', tagsubfield => 'e' }],
                    'items.ccode' => [{ tagfield => '952', tagsubfield => '8' }],
                    'items.cn_sort' => [{ tagfield => '952', tagsubfield => '6' }],
                    'items.cn_source' => [{ tagfield => '952', tagsubfield => '2' }],
                    'items.coded_location_qualifier' => [{ tagfield => '952', tagsubfield => 'f' }],
                    'items.copynumber' => [{ tagfield => '952', tagsubfield => 't' }],
                    'items.damaged' => [{ tagfield => '952', tagsubfield => '4' }],
                    'items.dateaccessioned' => [{ tagfield => '952', tagsubfield => 'd' }],
                    'items.datelastborrowed' => [{ tagfield => '952', tagsubfield => 's' }],
                    'items.datelastseen' => [{ tagfield => '952', tagsubfield => 'r' }],
                    'items.enumchron' => [{ tagfield => '952', tagsubfield => 'h' }],
                    'items.holdingbranch' => [{ tagfield => '952', tagsubfield => 'b' }],
                    'items.homebranch' => [{ tagfield => '952', tagsubfield => 'a' }],
                    'items.issues' => [{ tagfield => '952', tagsubfield => 'l' }],
                    'items.itemcallnumber' => [{ tagfield => '952', tagsubfield => 'o' }],
                    'items.itemlost' => [{ tagfield => '952', tagsubfield => '1' }],
                    'items.itemnotes' => [{ tagfield => '952', tagsubfield => 'z' }],
                    'items.itemnumber' => [{ tagfield => '952', tagsubfield => '9' }],
                    'items.itype' => [{ tagfield => '952', tagsubfield => 'y' }],
                    'items.location' => [{ tagfield => '952', tagsubfield => 'c' }],
                    'items.materials' => [{ tagfield => '952', tagsubfield => '3' }],
                    'items.nonpublicnote' => [{ tagfield => '952', tagsubfield => 'x' }],
                    'items.notforloan' => [{ tagfield => '952', tagsubfield => '7' }],
                    'items.onloan' => [{ tagfield => '952', tagsubfield => 'q' }],
                    'items.price' => [{ tagfield => '952', tagsubfield => 'g' }],
                    'items.renewals' => [{ tagfield => '952', tagsubfield => 'm' }],
                    'items.replacementprice' => [{ tagfield => '952', tagsubfield => 'v' }],
                    'items.replacementpricedate' => [{ tagfield => '952', tagsubfield => 'w' }],
                    'items.reserves' => [{ tagfield => '952', tagsubfield => 'n' }],
                    'items.restricted' => [{ tagfield => '952', tagsubfield => '5' }],
                    'items.stack' => [{ tagfield => '952', tagsubfield => 'j' }],
                    'items.uri' => [{ tagfield => '952', tagsubfield => 'u' }],
                    'items.withdrawn' => [{ tagfield => '952', tagsubfield => '0' }],
                };
        });
    }
}

sub run_marc21_search_tests {

    $marcflavour = 'MARC21';
    my $mock_zebra = t::lib::Mocks::Zebra->new({marcflavour => $marcflavour});
    push @cleanup, $mock_zebra;

    mock_GetMarcSubfieldStructure($marcflavour);

    use_ok('C4::Search', qw( getIndexes FindDuplicate SimpleSearch getRecords buildQuery searchResults ));

    # set search syspreferences to a known starting point
    $QueryStemming = 0;
    $QueryAutoTruncate = 0;
    $QueryWeightFields = 0;
    $QueryFuzzy = 0;

    my $indexes = C4::Search::getIndexes();
    is(scalar(grep(/^ti$/, @$indexes)), 1, "Title index supported");
    is(scalar(grep(/^arl$/, @$indexes)), 1, "Accelerated reading level index supported");
    is(scalar(grep(/^arp$/, @$indexes)), 1, "Accelerated reading point index supported");

    my $bibliomodule = Test::MockModule->new('C4::Biblio');

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
        'BK' => { 'imageurl' => 'bridge/book.png', 'summary' => '', 'itemtype' => 'BK', 'description' => 'Books' },
        'CF' => { 'imageurl' => 'bridge/computer_file.png', 'summary' => '', 'itemtype' => 'CF', 'description' => 'Computer Files' },
        'CR' => { 'imageurl' => 'bridge/periodical.png', 'summary' => '', 'itemtype' => 'CR', 'description' => 'Continuing Resources' },
        'MP' => { 'imageurl' => 'bridge/map.png', 'summary' => '', 'itemtype' => 'MP', 'description' => 'Maps' },
        'MU' => { 'imageurl' => 'bridge/sound.png', 'summary' => '', 'itemtype' => 'MU', 'description' => 'Music' },
        'MX' => { 'imageurl' => 'bridge/kit.png', 'summary' => '', 'itemtype' => 'MX', 'description' => 'Mixed Materials' },
        'REF' => { 'imageurl' => '', 'summary' => '', 'itemtype' => 'REF', 'description' => 'Reference' },
        'VM' => { 'imageurl' => 'bridge/dvd.png', 'summary' => '', 'itemtype' => 'VM', 'description' => 'Visual Materials' },
    );

    my $sourcedir = dirname(__FILE__) . "/data";
    $mock_zebra->load_records(
        sprintf( "%s/%s/zebraexport/biblio", $sourcedir, lc($marcflavour) ),
        'iso2709', 'biblios', 1 );
    $mock_zebra->load_records(
        sprintf(
            "%s/%s/zebraexport/large_biblio",
            $sourcedir, lc($marcflavour)
        ),
        'marcxml', 'biblios', 0
    );
    $mock_zebra->load_records(
        sprintf( "%s/%s/zebraexport/authority", $sourcedir, lc($marcflavour) ),
        'iso2709', 'authorities', 1
    );

    $mock_zebra->launch_zebra;

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

    ( $error, $marcresults, $total_hits ) = SimpleSearch("Music-number=49631-2", 0, 10);
    is($total_hits, 1, "SimpleSearch on music publisher number works (bug 8252)");
    ( $error, $marcresults, $total_hits ) = SimpleSearch("Identifier-publisher-for-music=49631-2", 0, 10);
    is($total_hits, 1, "SimpleSearch on music publisher number works using Identifier-publisher-for-music (bug 8252)");

    # Testing getRecords

    my $results_hashref;
    my $facets_loop;
    ( undef, $results_hashref, $facets_loop ) =
        getRecords('kw:book', 'book', [], [ 'biblioserver' ], '19', 0, \%branches, \%itemtypes, 'ccl', undef);
    is($results_hashref->{biblioserver}->{hits}, 101, "getRecords keyword search for 'book' matched right number of records");
    is(scalar @{$results_hashref->{biblioserver}->{RECORDS}}, 19, "getRecords returned requested number of records");
    my $record5 = $results_hashref->{biblioserver}->{RECORDS}->[5];
    ( undef, $results_hashref, $facets_loop ) =
        getRecords('kw:book', 'book', [], [ 'biblioserver' ], '20', 5, \%branches, \%itemtypes, 'ccl', undef);
    ok(!defined $results_hashref->{biblioserver}->{RECORDS}->[0] &&
        !defined $results_hashref->{biblioserver}->{RECORDS}->[1] &&
        !defined $results_hashref->{biblioserver}->{RECORDS}->[2] &&
        !defined $results_hashref->{biblioserver}->{RECORDS}->[3] &&
        !defined $results_hashref->{biblioserver}->{RECORDS}->[4] &&
        $results_hashref->{biblioserver}->{RECORDS}->[5] eq $record5, "getRecords cursor works");

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('ti:book', 'ti:book', [], [ 'biblioserver' ], '20', 0, \%branches, \%itemtypes, 'ccl', undef);
    is($results_hashref->{biblioserver}->{hits}, 11, "getRecords title search for 'book' matched right number of records");

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('au:Lessig', 'au:Lessig', [], [ 'biblioserver' ], '20', 0, \%branches, \%itemtypes, 'ccl', undef);
    is($results_hashref->{biblioserver}->{hits}, 4, "getRecords title search for 'Australia' matched right number of records");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [], [ 'biblioserver' ], '19', 0, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() =~ m/^Efectos del ambiente/ &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[7],'UTF-8')->title_proper() eq 'Salud y seguridad de los trabajadores del sector salud: manual para gerentes y administradores^ies' &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/
    , "Simple relevance sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'author_az' ], [ 'biblioserver' ], '38', 0, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() =~ m/la enfermedad laboral\^ies$/ &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[6],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/ &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() eq 'World health statistics 2009^ien'
    , "Simple ascending author sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'author_za' ], [ 'biblioserver' ], '38', 0, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() eq 'World health statistics 2009^ien' &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[12],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/ &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() =~ m/la enfermedad laboral\^ies$/
    , "Simple descending author sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'pubdate_asc' ], [ 'biblioserver' ], '38', 0, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() eq 'Manual de higiene industrial^ies' &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[7],'UTF-8')->title_proper() =~ m/seguridad e higiene del trabajo\^ies$/ &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/
    , "Simple ascending publication date sorting in getRecords matches old behavior");

( undef, $results_hashref, $facets_loop ) =
    getRecords('salud', 'salud', [ 'pubdate_dsc' ], [ 'biblioserver' ], '38', 0, \%branches, \%itemtypes, 'ccl', undef);
ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() =~ m/^Estado de salud/ &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[7],'UTF-8')->title_proper() eq 'World health statistics 2009^ien' &&
    MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() eq 'Manual de higiene industrial^ies'
    , "Simple descending publication date sorting in getRecords matches old behavior");

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('books', 'books', [ 'relevance' ], [ 'biblioserver' ], '20', 0, \%branches, \%itemtypes, undef, 1);
    $record = MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0]);
    is($record->title_proper(), 'Books', "Scan returned requested item");
    is($record->subfield('100', 'a'), 2, "Scan returned correct number of records matching term");
    # Time to test buildQuery and searchResults too.

    my ( $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type );
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'salud' ], [], [], [], 0, 'en');
    like($query, qr/kw\W.*salud/, "Built CCL keyword query");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 19, "getRecords generated keyword search for 'salud' matched right number of records");

    my @newresults = searchResults({'interface' => 'opac'}, $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 18, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"});
    is(scalar @newresults,18, "searchResults returns requested number of hits");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([ 'AND' ], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
    like($query, qr/kw\W.*salud\W.*AND.*kw\W.*higiene/, "Built composed explicit-and CCL keyword query");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 3, "getRecords generated composed keyword search for 'salud' explicit-and 'higiene' matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([ 'OR' ], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
    like($query, qr/kw\W.*salud\W.*OR.*kw\W.*higiene/, "Built composed explicit-or CCL keyword query");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 20, "getRecords generated composed keyword search for 'salud' explicit-or 'higiene' matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
    like($query, qr/kw\W.*salud\W.*AND.*kw\W.*higiene/, "Built composed implicit-and CCL keyword query");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 3, "getRecords generated composed keyword search for 'salud' implicit-and 'higiene' matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'salud' ], [ 'kw' ], [ 'su-to:Laboratorios' ], [], 0, 'en');
    like($query, qr/kw\W.*salud\W*and\W*su-to\W.*Laboratorios/, "Faceted query generated correctly");
    unlike($query_desc, qr/Laboratorios/, "Facets not included in query description");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated faceted search matched right number of records");


    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'mc-itype:MP', 'mc-itype:MU' ], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated mc-faceted search matched right number of records");


    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'mc-loc:GEN', 'branch:FFL' ], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated multi-faceted search matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'NEKLS' ], [ 'Code-institution' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 12,
       'search using index whose name contains "ns" returns expected results (bug 10271)');

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'available' ], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated availability-limited search matched right number of records");

    @newresults = searchResults({'interface'=>'opac'}, $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 17, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"});
    my $allavailable = 'true';
    foreach my $result (@newresults) {
        $allavailable = 'false' unless $result->{availablecount} > 0;
    }
    is ($allavailable, 'true', 'All records have at least one item available');

    my $mocked_xslt = Test::MockModule->new('Koha::XSLT::Base');
    $mocked_xslt->mock( 'transform', sub {
        my ($self, $xml) = @_;
        return $xml;
    });

    @newresults = searchResults({'interface'=>'opac'}, $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 17, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"}, { anonymous_session => 1 });

    like( $newresults[0]->{XSLTResultsRecord}, qr/<variable name="anonymous_session">1<\/variable>/, "Variable injected correctly" );

    my $biblio_id = $newresults[0]->{biblionumber};
    my $fw = C4::Biblio::GetFrameworkCode($biblio_id);

    my $dbh = C4::Context->dbh;
    # FIXME This change is revert in END
    # Hide subfield 'p' in OPAC
    $dbh->do(qq{
        UPDATE marc_subfield_structure
        SET hidden=4
        WHERE frameworkcode='$fw' AND
              tagfield=952 AND
              tagsubfield='p';
    });

    # Hide subfield 'y' in Staff
    $dbh->do(qq{
        UPDATE marc_subfield_structure
        SET hidden=-7
        WHERE frameworkcode='$fw' AND
              tagfield=952 AND
              tagsubfield='y';
    });

    Koha::Caches->get_instance->flush_all;

    @newresults = searchResults(
        { 'interface' => 'opac' },
        $query_desc,
        $results_hashref->{'biblioserver'}->{'hits'},
        17,
        0,
        0,
        $results_hashref->{'biblioserver'}->{"RECORDS"}
    );

    unlike( $newresults[0]->{XSLTResultsRecord}, qr/<subfield code="p">TEST11111<\/subfield>/, '952\$p hidden in OPAC' );

    @newresults = searchResults(
        { 'interface' => 'intranet' },
        $query_desc,
        $results_hashref->{'biblioserver'}->{'hits'},
        17,
        0,
        0,
        $results_hashref->{'biblioserver'}->{"RECORDS"}
    );

    unlike( $newresults[0]->{XSLTResultsRecord}, qr/<subfield code="y">Books<\/subfield>/, '952\$y hidden on staff interface' );

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'pqf=@attr 1=_ALLRECORDS @attr 2=103 ""' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 180, "getRecords on _ALLRECORDS PQF returned all records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'pqf=@attr 1=1016 "Lessig"' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 4, "getRecords PQF author search for Lessig returned proper number of matches");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'ccl=au:Lessig' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 4, "getRecords CCL author search for Lessig returned proper number of matches");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'cql=dc.author any lessig' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 4, "getRecords CQL author search for Lessig returned proper number of matches");

    $QueryStemming = $QueryAutoTruncate = $QueryFuzzy = 0;
    $QueryWeightFields = 1;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'salud' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 19, "Weighted query returned correct number of results");
    is(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper(), 'Salud y seguridad de los trabajadores del sector salud: manual para gerentes y administradores^ies', "Weighted query returns best match first");

    $QueryStemming = $QueryWeightFields = $QueryFuzzy = 0;
    $QueryAutoTruncate = 1;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic' returns matches  with automatic truncation on");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic*' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic*' returns matches with automatic truncation on");

    $QueryStemming = $QueryFuzzy = $QueryAutoTruncate = 0;
    $QueryWeightFields = 1;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'web application' ], [ 'kw' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 1, "Search for 'web application' returns one hit with QueryWeightFields on");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'web "application' ], [ 'kw' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 1, "Search for 'web \"application' returns one hit with QueryWeightFields on (bug 7518)");

    $QueryStemming = $QueryWeightFields = $QueryFuzzy = $QueryAutoTruncate = 0;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, undef, "Search for 'medic' returns no matches with automatic truncation off");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic*' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic*' returns matches with automatic truncation off");

    $QueryStemming = $QueryWeightFields = 1;
    $QueryFuzzy = $QueryAutoTruncate = 0;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'pressed' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 7, "Search for 'pressed' returns matches when stemming (and query weighting) is on");

    $QueryStemming = $QueryWeightFields = $QueryFuzzy = $QueryAutoTruncate = 0;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'pressed' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, undef, "Search for 'pressed' returns no matches when stemming is off");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'ccl=an:42' ], [], ['available'], [], 0, 'en');
    is( $query, "an:42 and (( (allrecords,AlwaysMatches='') and (not-onloan-count,st-numeric >= 1) and (lost,st-numeric=0) ))", 'buildQuery should add the available part to the query if requested with ccl' );
    is( $query_desc, 'an:42', 'buildQuery should remove the available part from the query' );

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'ccl=an:42' ], [], ['branch:CPL'], [], 0, 'en');
    is( $query, "an:42 and (homebranch: CPL or holdingbranch: CPL)", 'buildQuery should expand the limit as necessary for ccl queries' );
    is( $query_desc, 'an:42', 'buildQuery should not add limit to limit desc for ccl queries' );

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 0 ], [ 'su,phr' ], [], [], 0, 'en');
    is($query, 'su,phr=(rk=(0)) ', 'buildQuery should keep 0 value in query');
    is($query_cgi, 'idx=su%2Cphr&q=0', 'buildQuery should keep 0 value in query_cgi');
    is($query_desc, 'su,phr: 0', 'buildQuery should keep 0 value in query_desc');

    # Bug 23086
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [], [], [ 'mc-ccode:NF(IC'], [], 0, 'en');
    like($query, qr/ccode="NF\(IC"/, "Limit quoted correctly");

    # Let's see what happens when we pass bad data into these routines.
    # We have to catch warnings since we're not very good about returning errors.

    warning_like { ( $error, $marcresults, $total_hits ) = SimpleSearch("@==ccl blah", 0, 9) } qr/CCL parsing error/,
        "SimpleSearch warns about CCL parsing error with nonsense query";
    isnt($error, undef, "SimpleSearch returns an error when passed gibberish");

    warning_like {( undef, $results_hashref, $facets_loop ) =
        getRecords('kw:book', 'book', [], [ 'biblioserver' ], '19', 0, \%branches, \%itemtypes, 'nonsense', undef) }
        qr/Unknown query_type/, "getRecords warns about unknown query type";

    warning_like {( undef, $results_hashref, $facets_loop ) =
        getRecords('pqf=@attr 1=4 "title"', 'pqf=@attr 1=4 "title"', [], [ 'biblioserver' ], '19', 0, \%branches, \%itemtypes, '', undef) }
        qr/WARNING: query problem/, "getRecords warns when query type is not specified for non-CCL query";

    # Let's just test a few other bits and bobs, just for fun

    ($error, $results_hashref, $facets_loop) = getRecords("Godzina pąsowej róży","Godzina pąsowej róży",[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    @newresults = searchResults({'interface'=>'intranet'}, $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 17, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"});
    is(scalar(@{$newresults[0]->{'ALTERNATEHOLDINGS'}}), 1, 'Alternate holdings filled in correctly');


    ## Regression test for Bug 10741

    # make one of the test items appear to be in transit
    my $circ_module = Test::MockModule->new('C4::Circulation');
    $circ_module->mock('GetTransfers', sub {
        my $itemnumber = shift // -1;
        if ($itemnumber == 11) {
            return ('2013-07-19', 'MPL', 'CPL');
        } else {
            return;
        }
    });

    ($error, $results_hashref, $facets_loop) = getRecords("TEST12121212","TEST12121212",[ ], [ 'biblioserver' ],20,0,\%branches,\%itemtypes,$query_type,0);
    @newresults = searchResults({'interface'=>'intranet'}, $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 17, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"});
    ok(!exists($newresults[0]->{norequests}), 'presence of a transit does not block hold request action (bug 10741)');

    ## Regression test for bug 10684
    ( undef, $results_hashref, $facets_loop ) =
        getRecords('ti:punctuation', 'punctuation', [], [ 'biblioserver' ], '19', 0, \%branches, \%itemtypes, 'ccl', undef);
    is($results_hashref->{biblioserver}->{hits}, 1, "search for ti:punctuation returned expected number of records");
    warning_like { @newresults = searchResults({'intranet' => 'intranet'}, $query_desc,
                    $results_hashref->{'biblioserver'}->{'hits'}, 20, 0, 0,
                    $results_hashref->{'biblioserver'}->{"RECORDS"}) }
                qr/^ERROR DECODING RECORD - Tag "50%" is not a valid tag/,
                "Warning is raised correctly for invalid tags in MARC::Record";
    is(scalar(@newresults), 0, 'a record that cannot be parsed by MARC::Record is simply skipped (bug 10684)');

    my ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['starts'],
        ['shakespeare'], 0, 10, '', '', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on mainentry starts with "shakespeare"');
    ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['starts'],
        ['shakespeare'], 0, 10, '', 'HeadingAsc', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on mainentry starts with "shakespeare" sorted by heading ascending');
    ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['starts'],
        ['shakespeare'], 0, 10, '', 'HeadingDsc', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on mainentry starts with "shakespeare" sorted by heading descending');
    ($auths, $count) = SearchAuthorities(
        ['match'], ['and'], [''], ['contains'],
        ['沙士北亞威廉姆'], 0, 10, '', '', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on match contains "沙士北亞威廉姆"');
    ($auths, $count) = SearchAuthorities(
        ['LC-card-number'], ['and'], [''], ['contains'],
        ['99282477'], 0, 10, '', '', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on LC-card-number contains "99282477"');
    ($auths, $count) = SearchAuthorities(
        ['all'], ['and'], [''], ['contains'],
        ['professional wrestler'], 0, 10, '', '', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on "all" (entire record) contains "professional wrestler"');

    #NOTE: the 2nd parameter is unused in SearchAuthorities...
    ($auths, $count) = SearchAuthorities(
        ['Any','Any'], [''], [''], ['contains'],
        ['professional wrestler','shakespeare'], 0, 10, '', '', 1
    );
    is($count, 2, 'MARC21 authorities: multiple values create operands implicitly joined by OR');

    # retrieve records that are larger than the MARC limit of 99,999 octets
    ( undef, $results_hashref, $facets_loop ) =
        getRecords('ti:marc the large record', '', [], [ 'biblioserver' ], '20', 0, \%branches, \%itemtypes, 'ccl', undef);
    is($results_hashref->{biblioserver}->{hits}, 1, "Can do a search that retrieves an over-large bib record (bug 11096)");
    @newresults = searchResults({'interface' =>'opac'}, $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 10, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"});
    is($newresults[0]->{title}, 'Marc the Large Record', 'Able to render the title for over-large bib record (bug 11096)');
    is($newresults[0]->{biblionumber}, '300', 'Over-large bib record has the correct biblionumber (bug 11096)');
    like($newresults[0]->{notes}, qr/This is large note #550/, 'Able to render the notes field for over-large bib record (bug 11096)');

    # notforloancount should be returned as part of searchResults output
    ok( defined $newresults[0]->{notforloancount},
        '\'notforloancount\' defined in searchResults output (Bug 12419)');
    is( $newresults[0]->{notforloancount}, 2,
        '\'notforloancount\' == 2 (Bug 12419)');

    # verify that we don't attempt to sort if no results were returned
    # because of a query error
    warning_like {( undef, $results_hashref, $facets_loop ) =
        getRecords('ccl=( AND )', '', ['title_az'], [ 'biblioserver' ], '20', 0, \%branches, \%itemtypes, 'ccl', undef)
    } qr/WARNING: query problem with/, 'got warning instead of crash when attempting to run invalid query (bug 9578)';
    
    # Test facet calculation
    my $facets_counter = {};
    my $facets         = C4::Koha::getFacets();
    # Create a record with a 100$z field
    my $marc_record    = MARC::Record->new;
    $marc_record->add_fields(
        [ '001', '1234' ],
        [ '100', ' ', ' ', a => 'Cohen Arazi, Tomas' ],
        [ '100', 'z', ' ', a => 'Tomasito' ],
        [ '245', ' ', ' ', a => 'First try' ]
    );
    C4::Search::_get_facets_data_from_record( $marc_record, $facets, $facets_counter );
    is_deeply( { au => { 'Cohen Arazi, Tomas' => 1 } },  $facets_counter,
        "_get_facets_data_from_record doesn't count 100\$z (Bug 12788)");
    $marc_record    = MARC::Record->new;
    $marc_record->add_fields(
        [ '001', '1234' ],
        [ '100', ' ', ' ', a => 'Cohen Arazi, Tomas' ],
        [ '100', 'z', ' ', a => 'Tomasito' ],
        [ '245', ' ', ' ', a => 'Second try' ]
    );
    C4::Search::_get_facets_data_from_record( $marc_record, $facets, $facets_counter );
    is_deeply( { au => { 'Cohen Arazi, Tomas' => 2 } },  $facets_counter,
        "_get_facets_data_from_record correctly counts author facet twice");

    # Test _get_facets_info
    my $facets_info = C4::Search::_get_facets_info( $facets );
    my $expected_facets_info_marc21 = {
                   'au' => { 'label_value' => "Authors" },
                'ccode' => { 'label_value' => "CollectionCodes" },
        'holdingbranch' => { 'label_value' => "HoldingLibrary" },
                'itype' => { 'label_value' => "ItemTypes" },
             'location' => { 'label_value' => "Location" },
                   'se' => { 'label_value' => "Series" },
               'su-geo' => { 'label_value' => "Places" },
                'su-to' => { 'label_value' => "Topics" },
                'su-ut' => { 'label_value' => "Titles" }
    };
    delete $expected_facets_info_marc21->{holdingbranch}
        if Koha::Libraries->count == 1;
    is_deeply( $facets_info, $expected_facets_info_marc21,
        "_get_facets_info returns the correct data");

    $mock_zebra->cleanup;
}

sub run_unimarc_search_tests {

    $marcflavour = 'UNIMARC';
    my $mock_zebra = t::lib::Mocks::Zebra->new({marcflavour => $marcflavour});
    push @cleanup, $mock_zebra;

    mock_GetMarcSubfieldStructure($marcflavour);

    use_ok('C4::Search', qw( getIndexes FindDuplicate SimpleSearch getRecords buildQuery searchResults ));

    # set search syspreferences to a known starting point
    $QueryStemming = 0;
    $QueryAutoTruncate = 0;
    $QueryWeightFields = 0;
    $QueryFuzzy = 0;

    my $sourcedir = dirname(__FILE__) . "/data";
    $mock_zebra->load_records(
        sprintf( "%s/%s/zebraexport/biblio", $sourcedir, lc($marcflavour) ),
        'iso2709', 'biblios', 1 );
    $mock_zebra->load_records(
        sprintf(
            "%s/%s/zebraexport/large_biblio",
            $sourcedir, lc($marcflavour)
        ),
        'marcxml', 'biblios', 0
    );
    $mock_zebra->load_records(
        sprintf( "%s/%s/zebraexport/authority", $sourcedir, lc($marcflavour) ),
        'iso2709', 'authorities', 1
    );
    $mock_zebra->launch_zebra;

    my ( $error, $marcresults, $total_hits ) = SimpleSearch("ti=Järnvägarnas efterfrågan och den svenska industrin", 0, 10);
    is($total_hits, 1, 'UNIMARC title search');
    ( $error, $marcresults, $total_hits ) = SimpleSearch("ta=u", 0, 10);
    is($total_hits, 1, 'UNIMARC target audience = u');
    ( $error, $marcresults, $total_hits ) = SimpleSearch("ta=k", 0, 10);
    is($total_hits, 4, 'UNIMARC target audience = k');
    ( $error, $marcresults, $total_hits ) = SimpleSearch("ta=m", 0, 10);
    is($total_hits, 3, 'UNIMARC target audience = m');
    ( $error, $marcresults, $total_hits ) = SimpleSearch("item=EXCLU DU PRET", 0, 10);
    is($total_hits, 1, 'UNIMARC generic item index (bug 10037)');

    # authority records
    use_ok('C4::AuthoritiesMarc', qw( SearchAuthorities ));

    my ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['contains'],
        ['wil'], 0, 10, '', '', 1
    );
    is($count, 11, 'UNIMARC authorities: hits on mainentry contains "wil"');
    ($auths, $count) = SearchAuthorities(
        ['match'], ['and'], [''], ['contains'],
        ['wil'], 0, 10, '', '', 1
    );
    is($count, 11, 'UNIMARC authorities: hits on match contains "wil"');
    ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['contains'],
        ['michel'], 0, 20, '', '', 1
    );
    is($count, 14, 'UNIMARC authorities: hits on mainentry contains "michel"');
    ($auths, $count) = SearchAuthorities(
        ['mainmainentry'], ['and'], [''], ['exact'],
        ['valley'], 0, 20, '', '', 1
    );
    is($count, 1, 'UNIMARC authorities: hits on mainmainentry = "valley"');
    ($auths, $count) = SearchAuthorities(
        ['mainmainentry'], ['and'], [''], ['exact'],
        ['vall'], 0, 20, '', '', 1
    );
    is($count, 0, 'UNIMARC authorities: no hits on mainmainentry = "vall"');
    ($auths, $count) = SearchAuthorities(
        ['Any'], ['and'], [''], ['starts'],
        ['jean'], 0, 30, '', '', 1
    );
    is($count, 24, 'UNIMARC authorities: hits on any starts with "jean"');

    # Test _get_facets_info
    my $facets      = C4::Koha::getFacets();
    my $facets_info = C4::Search::_get_facets_info( $facets );
    my $expected_facets_info_unimarc = {
                   'au' => { 'label_value' => "Authors" },
                'ccode' => { 'label_value' => "CollectionCodes" },
        'holdingbranch' => { 'label_value' => "HoldingLibrary" },
             'location' => { 'label_value' => "Location" },
                   'se' => { 'label_value' => "Series" },
               'su-geo' => { 'label_value' => "Places" },
                'su-to' => { 'label_value' => "Topics" }
    };
    delete $expected_facets_info_unimarc->{holdingbranch}
        if Koha::Libraries->count == 1;
    is_deeply( $facets_info, $expected_facets_info_unimarc,
        "_get_facets_info returns the correct data");

    $mock_zebra->cleanup;
}

subtest 'MARC21 + DOM' => sub {
    plan tests => 93;
    run_marc21_search_tests();
};

subtest 'UNIMARC + DOM' => sub {
    plan tests => 14;
    run_unimarc_search_tests();
};


subtest 'FindDuplicate' => sub {
    plan tests => 6;
    Koha::Caches->get_instance('config')->flush_all;
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21' );
    mock_GetMarcSubfieldStructure('MARC21');
    my $z_searcher = Test::MockModule->new('C4::Search');
    $z_searcher->mock('SimpleSearch', sub {
        warn shift @_;
        return 1;
    });
    my $e_searcher = Test::MockModule->new('Koha::SearchEngine::Elasticsearch::Search');
    $e_searcher->mock('simple_search_compat', sub {
        shift @_;
        warn shift @_;
        return 1;
    });

    my $record_1 = MARC::Record->new;
    $record_1 ->add_fields(
            [ '100', '0', '0', a => 'Morgenstern, Erin' ],
            [ '245', '0', '0', a => 'The night circus /' ]
    );
    my $record_2 = MARC::Record->new;
    $record_2 ->add_fields(
            [ '245', '0', '0', a => 'The book of nothing /' ]
    );
    my $record_3 = MARC::Record->new;
    $record_3->add_fields(
            [ '245', '0', '0', a => 'Frog and toad all year /' ]
    );

    foreach my $engine ('Zebra','Elasticsearch'){
        t::lib::Mocks::mock_preference('searchEngine', $engine );

        warning_is { C4::Search::FindDuplicate($record_1);}
            q/ti,ext:"The night circus \/" AND au,ext:"Morgenstern, Erin"/,"Term correctly formed and passed to $engine";

        warning_is { C4::Search::FindDuplicate($record_2);}
            q/ti,ext:"The book of nothing \/"/,"Term correctly formed and passed to $engine";

        warning_is { C4::Search::FindDuplicate($record_3);}
            q/ti,ext:"Frog and toad all year \/"/,"Term correctly formed and passed to $engine";
    }

};

# Make sure that following tests are not using our config settings
Koha::Caches->get_instance('config')->flush_all;

END {

    $_->cleanup for @cleanup;
    my $dbh = C4::Context->dbh;
    # Restore visibility of subfields in OPAC
    $dbh->do(q{
        UPDATE marc_subfield_structure
        SET hidden=0
        WHERE tagfield=952 AND
              ( tagsubfield IN ('p', 'y') )
    });

    Koha::Caches->get_instance->flush_all;
};
