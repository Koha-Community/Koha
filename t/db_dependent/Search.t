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

use YAML;

use C4::Debug;
require C4::Context;

# work around spurious wide character warnings
use open ':std', ':encoding(utf8)';

use Test::More tests => 4;
use Test::MockModule;
use Test::Warn;

use Koha::Caches;

use MARC::Record;
use File::Spec;
use File::Basename;
use File::Find;

use File::Temp qw/ tempdir /;
use File::Path;

our $child;
our $datadir;

sub index_sample_records_and_launch_zebra {
    my ($datadir, $indexing_mode, $marc_type) = @_;

    my $sourcedir = dirname(__FILE__) . "/data";
    unlink("$datadir/zebra.log");
    if (-f "$sourcedir/${marc_type}/zebraexport/biblio/exported_records") {
        my $zebra_bib_cfg = ($indexing_mode eq 'dom') ? 'zebra-biblios-dom.cfg' : 'zebra-biblios.cfg';
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_bib_cfg  -v none,fatal -g iso2709 -d biblios init");
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_bib_cfg  -v none,fatal -g iso2709 -d biblios update $sourcedir/${marc_type}/zebraexport/biblio");
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_bib_cfg  -v none,fatal -g iso2709 -d biblios commit");
    }
    # ... and add large bib records, if present
    if (-f "$sourcedir/${marc_type}/zebraexport/large_biblio_${indexing_mode}/exported_records.xml") {
        my $zebra_bib_cfg = ($indexing_mode eq 'dom') ? 'zebra-biblios-dom.cfg' : 'zebra-biblios.cfg';
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_bib_cfg  -v none,fatal -g marcxml -d biblios update $sourcedir/${marc_type}/zebraexport/large_biblio_${indexing_mode}");
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_bib_cfg  -v none,fatal -g marcxml -d biblios commit");
    }
    if (-f "$sourcedir/${marc_type}/zebraexport/authority/exported_records") {
        my $zebra_auth_cfg = ($indexing_mode eq 'dom') ? 'zebra-authorities-dom.cfg' : 'zebra-authorities.cfg';
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_auth_cfg  -v none,fatal -g iso2709 -d authorities init");
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_auth_cfg  -v none,fatal -g iso2709 -d authorities update $sourcedir/${marc_type}/zebraexport/authority");
        system("zebraidx -c $datadir/etc/koha/zebradb/$zebra_auth_cfg  -v none,fatal -g iso2709 -d authorities commit");
    }

    $child = fork();
    if ($child == 0) {
        exec("zebrasrv -f $datadir/etc/koha-conf.xml -v none,request -l $datadir/zebra.log");
        exit;
    }

    sleep(1);
}

sub cleanup {
    if ($child) {
        kill 9, $child;

        # Clean up the Zebra files since the child process was just shot
        rmtree $datadir;
    }
}

# Fall back to make sure that the Zebra process
# and files get cleaned up
END {
    cleanup();
}

our $QueryStemming = 0;
our $QueryAutoTruncate = 0;
our $QueryWeightFields = 0;
our $QueryFuzzy = 0;
our $UseQueryParser = 0;
our $SearchEngine = 'Zebra';
our $marcflavour = 'MARC21';
our $contextmodule = new Test::MockModule('C4::Context');
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
    } elsif ($pref eq 'UseQueryParser') {
        return $UseQueryParser;
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
    } elsif ($pref eq 'opaclanguages') {
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
    } else {
        warn "The syspref $pref was requested but I don't know what to say; this indicates that the test requires updating"
            unless $pref =~ m/(XSLT|item|branch|holding|image)/i;
        return 0;
    }
});
$contextmodule->mock('queryparser', sub {
    my $QParser     = Koha::QueryParser::Driver::PQF->new();
    $QParser->load_config("$datadir/etc/searchengine/queryparser.yaml");
    return $QParser;
});

our $bibliomodule = new Test::MockModule('C4::Biblio');

sub mock_GetMarcSubfieldStructure {
    my $marc_type = shift;
    if ($marc_type eq 'marc21') {
        $bibliomodule->mock('GetMarcSubfieldStructure', sub {
            return {
                    'biblio.biblionumber' => [{ tagfield =>  '999', tagsubfield => 'c' }],
                    'biblio.isbn' => [{ tagfield => '020', tagsubfield => 'a' }],
                    'biblio.title' => [{ tagfield => '245', tagsubfield => 'a' }],
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
    my $indexing_mode = shift;
    $datadir = tempdir();
    system(dirname(__FILE__) . "/zebra_config.pl $datadir marc21 $indexing_mode");

    Koha::Caches->get_instance('config')->flush_all;

    mock_GetMarcSubfieldStructure('marc21');
    my $context = new C4::Context("$datadir/etc/koha-conf.xml");
    $context->set_context();

    is($context->config('zebra_bib_index_mode'),$indexing_mode,
        "zebra_bib_index_mode is properly set to '$indexing_mode' in the created koha-conf.xml file (BZ11499)");
    is($context->config('zebra_auth_index_mode'),$indexing_mode,
        "zebra_auth_index_mode is properly set to '$indexing_mode' in the created koha-conf.xml file (BZ11499)");

    use_ok('C4::Search');

    # set search syspreferences to a known starting point
    $QueryStemming = 0;
    $QueryAutoTruncate = 0;
    $QueryWeightFields = 0;
    $QueryFuzzy = 0;
    $UseQueryParser = 0;
    $marcflavour = 'MARC21';

    my $indexes = C4::Search::getIndexes();
    is(scalar(grep(/^ti$/, @$indexes)), 1, "Title index supported");

    my $bibliomodule = new Test::MockModule('C4::Biblio');

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

    index_sample_records_and_launch_zebra($datadir, $indexing_mode, 'marc21');

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

if ( $indexing_mode eq 'dom' ) {
    ( undef, $results_hashref, $facets_loop ) =
        getRecords('salud', 'salud', [], [ 'biblioserver' ], '19', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
    ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() =~ m/^Efectos del ambiente/ &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[7],'UTF-8')->title_proper() eq 'Salud y seguridad de los trabajadores del sector salud: manual para gerentes y administradores^ies' &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/
        , "Simple relevance sorting in getRecords matches old behavior");

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('salud', 'salud', [ 'author_az' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
    ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() =~ m/la enfermedad laboral\^ies$/ &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[6],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/ &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() eq 'World health statistics 2009^ien'
        , "Simple ascending author sorting in getRecords matches old behavior");

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('salud', 'salud', [ 'author_za' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
    ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() eq 'World health statistics 2009^ien' &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[12],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/ &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() =~ m/la enfermedad laboral\^ies$/
        , "Simple descending author sorting in getRecords matches old behavior");

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('salud', 'salud', [ 'pubdate_asc' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
    ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() eq 'Manual de higiene industrial^ies' &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[7],'UTF-8')->title_proper() =~ m/seguridad e higiene del trabajo\^ies$/ &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() =~ m/^Indicadores de resultados identificados/
        , "Simple ascending publication date sorting in getRecords matches old behavior");

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('salud', 'salud', [ 'pubdate_dsc' ], [ 'biblioserver' ], '38', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
    ok(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper() =~ m/^Estado de salud/ &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[7],'UTF-8')->title_proper() eq 'World health statistics 2009^ien' &&
        MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[18],'UTF-8')->title_proper() eq 'Manual de higiene industrial^ies'
        , "Simple descending publication date sorting in getRecords matches old behavior");

} elsif ( $indexing_mode eq 'grs1' ){
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
}

    ( undef, $results_hashref, $facets_loop ) =
        getRecords('books', 'books', [ 'relevance' ], [ 'biblioserver' ], '20', 0, undef, \%branches, \%itemtypes, undef, 1);
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

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 19, "getRecords generated keyword search for 'salud' matched right number of records");

    my @newresults = searchResults('opac', $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 18, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"});
    is(scalar @newresults,18, "searchResults returns requested number of hits");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([ 'and' ], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
    like($query, qr/kw\W.*salud\W.*and.*kw\W.*higiene/, "Built composed explicit-and CCL keyword query");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 3, "getRecords generated composed keyword search for 'salud' explicit-and 'higiene' matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([ 'or' ], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
    like($query, qr/kw\W.*salud\W.*or.*kw\W.*higiene/, "Built composed explicit-or CCL keyword query");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 20, "getRecords generated composed keyword search for 'salud' explicit-or 'higiene' matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'salud', 'higiene' ], [], [], [], 0, 'en');
    like($query, qr/kw\W.*salud\W.*and.*kw\W.*higiene/, "Built composed implicit-and CCL keyword query");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 3, "getRecords generated composed keyword search for 'salud' implicit-and 'higiene' matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'salud' ], [ 'kw' ], [ 'su-to:Laboratorios' ], [], 0, 'en');
    like($query, qr/kw\W.*salud\W*and\W*su-to\W.*Laboratorios/, "Faceted query generated correctly");
    unlike($query_desc, qr/Laboratorios/, "Facets not included in query description");

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated faceted search matched right number of records");


    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'mc-itype:MP', 'mc-itype:MU' ], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated mc-faceted search matched right number of records");


    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'mc-loc:GEN', 'branch:FFL' ], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 2, "getRecords generated multi-faceted search matched right number of records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'NEKLS' ], [ 'Code-institution' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 12,
       'search using index whose name contains "ns" returns expected results (bug 10271)');

    $UseQueryParser = 1;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'book' ], [ 'kw' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 101, "Search for 'book' with index set to 'kw' returns 101 hits");
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([ 'and' ], [ 'book', 'another' ], [ 'kw', 'kw' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 1, "Search for 'kw:book && kw:another' returns 1 hit");
    $UseQueryParser = 0;

    # FIXME: the availability limit does not actually work, so for the moment we
    # are just checking that it behaves consistently
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ '' ], [ 'kw' ], [ 'available' ], [], 0, 'en');

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
    $query_type ) = buildQuery([], [ 'pqf=@attr 1=_ALLRECORDS @attr 2=103 ""' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 180, "getRecords on _ALLRECORDS PQF returned all records");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'pqf=@attr 1=1016 "Lessig"' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 4, "getRecords PQF author search for Lessig returned proper number of matches");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'ccl=au:Lessig' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 4, "getRecords CCL author search for Lessig returned proper number of matches");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'cql=dc.author any lessig' ], [], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 4, "getRecords CQL author search for Lessig returned proper number of matches");

    $QueryStemming = $QueryAutoTruncate = $QueryFuzzy = 0;
    $QueryWeightFields = 1;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'salud' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 19, "Weighted query returned correct number of results");
    if ($indexing_mode eq 'grs1') {
        is(MARC::Record::new_from_usmarc($results_hashref->{biblioserver}->{RECORDS}->[0])->title_proper(), 'Salud y seguridad de los trabajadores del sector salud: manual para gerentes y administradores^ies', "Weighted query returns best match first");
    } else {
        local $TODO = "Query weighting does not behave exactly the same in DOM vs. GRS";
        is(MARC::Record::new_from_xml($results_hashref->{biblioserver}->{RECORDS}->[0],'UTF-8')->title_proper(), 'Salud y seguridad de los trabajadores del sector salud: manual para gerentes y administradores^ies', "Weighted query returns best match first");
    }

    $QueryStemming = $QueryWeightFields = $QueryFuzzy = 0;
    $QueryAutoTruncate = 1;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic' returns matches  with automatic truncation on");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic*' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic*' returns matches with automatic truncation on");

    $QueryStemming = $QueryFuzzy = $QueryAutoTruncate = 0;
    $QueryWeightFields = 1;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'web application' ], [ 'kw' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 1, "Search for 'web application' returns one hit with QueryWeightFields on");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'web "application' ], [ 'kw' ], [], [], 0, 'en');
    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 1, "Search for 'web \"application' returns one hit with QueryWeightFields on (bug 7518)");

    $QueryStemming = $QueryWeightFields = $QueryFuzzy = $QueryAutoTruncate = 0;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, undef, "Search for 'medic' returns no matches with automatic truncation off");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'medic*' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 5, "Search for 'medic*' returns matches with automatic truncation off");

    $QueryStemming = $QueryWeightFields = 1;
    $QueryFuzzy = $QueryAutoTruncate = 0;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'pressed' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, 7, "Search for 'pressed' returns matches when stemming (and query weighting) is on");

    $QueryStemming = $QueryWeightFields = $QueryFuzzy = $QueryAutoTruncate = 0;
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'pressed' ], [ 'kw' ], [], [], 0, 'en');

    ($error, $results_hashref, $facets_loop) = getRecords($query,$simple_query,[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    is($results_hashref->{biblioserver}->{hits}, undef, "Search for 'pressed' returns no matches when stemming is off");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'ccl=an:42' ], [], ['available'], [], 0, 'en');
    is( $query, "an:42 and ( ( allrecords,AlwaysMatches:'' not onloan,AlwaysMatches:'') and (lost,st-numeric=0) )", 'buildQuery should add the available part to the query if requested with ccl' );
    is( $query_desc, 'an:42', 'buildQuery should remove the available part from the query' );

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


    ## Regression test for Bug 10741

    # make one of the test items appear to be in transit
    my $circ_module = new Test::MockModule('C4::Circulation');
    $circ_module->mock('GetTransfers', sub {
        my $itemnumber = shift // -1;
        if ($itemnumber == 11) {
            return ('2013-07-19', 'MPL', 'CPL');
        } else {
            return;
        }
    });

    ($error, $results_hashref, $facets_loop) = getRecords("TEST12121212","TEST12121212",[ ], [ 'biblioserver' ],20,0,undef,\%branches,\%itemtypes,$query_type,0);
    @newresults = searchResults('intranet', $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 17, 0, 0,
        $results_hashref->{'biblioserver'}->{"RECORDS"});
    ok(!exists($newresults[0]->{norequests}), 'presence of a transit does not block hold request action (bug 10741)');

    ## Regression test for bug 10684
    ( undef, $results_hashref, $facets_loop ) =
        getRecords('ti:punctuation', 'punctuation', [], [ 'biblioserver' ], '19', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
    is($results_hashref->{biblioserver}->{hits}, 1, "search for ti:punctuation returned expected number of records");
    warning_like { @newresults = searchResults('intranet', $query_desc,
                    $results_hashref->{'biblioserver'}->{'hits'}, 20, 0, 0,
                    $results_hashref->{'biblioserver'}->{"RECORDS"}) }
                qr/^ERROR DECODING RECORD - Tag "50%" is not a valid tag/,
                "Warning is raised correctly for invalid tags in MARC::Record";
    is(scalar(@newresults), 0, 'a record that cannot be parsed by MARC::Record is simply skipped (bug 10684)');

    # Testing exploding indexes
    my $term;
    my $searchmodule = new Test::MockModule('C4::Search');
    $searchmodule->mock('SimpleSearch', sub {
        my $query = shift;

        is($query, "he:$term", "Searching for expected term '$term' for exploding") or return '', [], 0;

        my $record = MARC::Record->new;
        if ($query =~ m/Arizona/) {
            $record->add_fields(
                [ '001', '1234' ],
                [ '151', ' ', ' ', a => 'Arizona' ],
                [ '551', ' ', ' ', a => 'United States', w => 'g' ],
                [ '551', ' ', ' ', a => 'Maricopa County', w => 'h' ],
                [ '551', ' ', ' ', a => 'Navajo County', w => 'h' ],
                [ '551', ' ', ' ', a => 'Pima County', w => 'h' ],
                [ '551', ' ', ' ', a => 'New Mexico' ],
                );
        }
        return '', [ $record->as_usmarc() ], 1;
    });

    $UseQueryParser = 1;
    $term = 'Arizona';
    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ $term ], [ 'su-br' ], [  ], [], 0, 'en');
    matchesExplodedTerms("Advanced search for broader subjects", $query, 'Arizona', 'United States');

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ $term ], [ 'su-na' ], [  ], [], 0, 'en');
    matchesExplodedTerms("Advanced search for narrower subjects", $query, 'Arizona', 'Maricopa County', 'Navajo County', 'Pima County');

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ $term ], [ 'su-rl' ], [  ], [], 0, 'en');
    matchesExplodedTerms("Advanced search for related subjects", $query, 'Arizona', 'United States', 'Maricopa County', 'Navajo County', 'Pima County');

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ "$term", 'history' ], [ 'su-rl', 'kw' ], [  ], [], 0, 'en');
    matchesExplodedTerms("Advanced search for related subjects and keyword 'history' searches related subjects", $query, 'Arizona', 'United States', 'Maricopa County', 'Navajo County', 'Pima County');
    like($query, qr/history/, "Advanced search for related subjects and keyword 'history' searches for 'history'");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ 'history', "$term" ], [ 'kw', 'su-rl' ], [  ], [], 0, 'en');
    matchesExplodedTerms("Order of terms doesn't matter for advanced search", $query, 'Arizona', 'United States', 'Maricopa County', 'Navajo County', 'Pima County');
    like($query, qr/history/, "Order of terms doesn't matter for advanced search");

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ "su-br($term)" ], [  ], [  ], [], 0, 'en');
    matchesExplodedTerms("Simple search for broader subjects", $query, 'Arizona', 'United States');

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ "su-na($term)" ], [  ], [  ], [], 0, 'en');
    matchesExplodedTerms("Simple search for narrower subjects", $query, 'Arizona', 'Maricopa County', 'Navajo County', 'Pima County');

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ "su-rl($term)" ], [  ], [  ], [], 0, 'en');
    matchesExplodedTerms("Simple search for related subjects", $query, 'Arizona', 'United States', 'Maricopa County', 'Navajo County', 'Pima County');

    ( $error, $query, $simple_query, $query_cgi,
    $query_desc, $limit, $limit_cgi, $limit_desc,
    $query_type ) = buildQuery([], [ "history && su-rl($term)" ], [  ], [  ], [], 0, 'en');
    matchesExplodedTerms("Simple search for related subjects and keyword 'history' searches related subjects", $query, 'Arizona', 'United States', 'Maricopa County', 'Navajo County', 'Pima County');
    like($query, qr/history/, "Simple search for related subjects and keyword 'history' searches for 'history'");

    sub matchesExplodedTerms {
        my ($message, $query, @terms) = @_;
        my $match = '(' . join ('|', map { " \@attr 1=Subject \@attr 4=1 \"$_\"" } @terms) . "){" . scalar(@terms) . "}";
        like($query, qr/$match/, $message);
    }

    # authority records
    use_ok('C4::AuthoritiesMarc');
    $UseQueryParser = 0;

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

    $UseQueryParser = 1;

    ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['starts'],
        ['shakespeare'], 0, 10, '', '', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on mainentry starts with "shakespeare" (QP)');
    ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['starts'],
        ['shakespeare'], 0, 10, '', 'HeadingAsc', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on mainentry starts with "shakespeare" sorted by heading ascending (QP)');
    ($auths, $count) = SearchAuthorities(
        ['mainentry'], ['and'], [''], ['starts'],
        ['shakespeare'], 0, 10, '', 'HeadingDsc', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on mainentry starts with "shakespeare" sorted by heading descending (QP)');
    ($auths, $count) = SearchAuthorities(
        ['match'], ['and'], [''], ['contains'],
        ['沙士北亞威廉姆'], 0, 10, '', '', 1
    );
    is($count, 1, 'MARC21 authorities: one hit on match contains "沙士北亞威廉姆" (QP)');

    # retrieve records that are larger than the MARC limit of 99,999 octets
    ( undef, $results_hashref, $facets_loop ) =
        getRecords('ti:marc the large record', '', [], [ 'biblioserver' ], '20', 0, undef, \%branches, \%itemtypes, 'ccl', undef);
    is($results_hashref->{biblioserver}->{hits}, 1, "Can do a search that retrieves an over-large bib record (bug 11096)");
    @newresults = searchResults('opac', $query_desc, $results_hashref->{'biblioserver'}->{'hits'}, 10, 0, 0,
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
        getRecords('ccl=( AND )', '', ['title_az'], [ 'biblioserver' ], '20', 0, undef, \%branches, \%itemtypes, 'ccl', undef)
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
                   'au' => { 'expanded'    => undef,
                             'label_value' => "Authors" },
        'holdingbranch' => { 'expanded'    => undef,
                             'label_value' => "HoldingLibrary" },
                'itype' => { 'expanded'    => undef,
                             'label_value' => "ItemTypes" },
             'location' => { 'expanded'    => undef,
                             'label_value' => "Location" },
                   'se' => { 'expanded'    => undef,
                             'label_value' => "Series" },
               'su-geo' => { 'expanded'    => undef,
                             'label_value' => "Places" },
                'su-to' => { 'expanded'    => undef,
                             'label_value' => "Topics" },
                'su-ut' => { 'expanded'    => undef,
                             'label_value' => "Titles" }
    };
    delete $expected_facets_info_marc21->{holdingbranch}
        if Koha::Libraries->count == 1;
    is_deeply( $facets_info, $expected_facets_info_marc21,
        "_get_facets_info returns the correct data");

    cleanup();
}

sub run_unimarc_search_tests {
    my $indexing_mode = shift;
    $datadir = tempdir();
    system(dirname(__FILE__) . "/zebra_config.pl $datadir unimarc $indexing_mode");

    Koha::Caches->get_instance('config')->flush_all;

    mock_GetMarcSubfieldStructure('unimarc');
    my $context = new C4::Context("$datadir/etc/koha-conf.xml");
    $context->set_context();

    use_ok('C4::Search');

    # set search syspreferences to a known starting point
    $QueryStemming = 0;
    $QueryAutoTruncate = 0;
    $QueryWeightFields = 0;
    $QueryFuzzy = 0;
    $UseQueryParser = 0;
    $marcflavour = 'UNIMARC';

    index_sample_records_and_launch_zebra($datadir, $indexing_mode, 'unimarc');

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
    use_ok('C4::AuthoritiesMarc');
    $UseQueryParser = 0;

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
                   'au' => { 'expanded'    => undef,
                             'label_value' => "Authors" },
        'holdingbranch' => { 'expanded'    => undef,
                             'label_value' => "HoldingLibrary" },
             'location' => { 'expanded'    => undef,
                             'label_value' => "Location" },
                   'se' => { 'expanded'    => undef,
                             'label_value' => "Series" },
               'su-geo' => { 'expanded'    => undef,
                             'label_value' => "Places" },
                'su-to' => { 'expanded'    => undef,
                             'label_value' => "Topics" },
                'su-ut' => { 'expanded'    => undef,
                             'label_value' => "Titles" }
    };
    delete $expected_facets_info_unimarc->{holdingbranch}
        if Koha::Libraries->count == 1;
    is_deeply( $facets_info, $expected_facets_info_unimarc,
        "_get_facets_info returns the correct data");

    cleanup();
}

subtest 'MARC21 + GRS-1' => sub {
    plan tests => 109;
    run_marc21_search_tests('grs1');
};

subtest 'MARC21 + DOM' => sub {
    plan tests => 109;
    run_marc21_search_tests('dom');
};

subtest 'UNIMARC + GRS-1' => sub {
    plan tests => 14;
    run_unimarc_search_tests('grs1');
};

subtest 'UNIMARC + DOM' => sub {
    plan tests => 14;
    run_unimarc_search_tests('dom');
};

# Make sure that following tests are not using our config settings
Koha::Caches->get_instance('config')->flush_all;

