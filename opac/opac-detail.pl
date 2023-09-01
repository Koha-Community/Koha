#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
# Copyright 2011 KohaAloha, NZ
#
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

use CGI qw ( -utf8 );
use C4::Acquisition qw( SearchOrders );
use C4::Auth qw( get_template_and_user get_session );
use C4::Koha qw(
    getitemtypeimagelocation
    GetNormalizedEAN
    GetNormalizedISBN
    GetNormalizedOCLCNumber
    GetNormalizedUPC
);
use C4::Search qw( new_record_from_zebra searchResults getRecords );
use C4::Serials qw( CountSubscriptionFromBiblionumber SearchSubscriptions GetLatestSerials );
use C4::Output qw( parametrized_url output_html_with_http_headers );
use C4::Biblio qw(
    CountItemsIssued
    GetBiblioData
    GetMarcControlnumber
    GetMarcISBN
    GetMarcISSN
    GetMarcSeries
    GetMarcSubjects
    GetMarcUrls
);
use C4::Tags qw( get_tags );
use C4::XISBN qw( get_xisbns );
use C4::External::Amazon qw( get_amazon_tld );
use C4::External::BakerTaylor qw( image_url link_url );
use C4::External::Syndetics qw(
    get_syndetics_anotes
    get_syndetics_excerpt
    get_syndetics_index
    get_syndetics_reviews
    get_syndetics_summary
    get_syndetics_toc
);
use C4::Members;
use C4::XSLT qw( XSLTParse4Display );
use C4::ShelfBrowser qw( GetNearbyItems );
use C4::Reserves qw( GetReserveStatus IsAvailableForItemLevelRequest );
use C4::Charset qw( SetUTF8Flag );
use MARC::Field;
use List::MoreUtils qw( any );
use C4::HTML5Media;
use C4::CourseReserves qw( GetItemCourseReservesInfo );

use Koha::Biblios;
use Koha::RecordProcessor;
use Koha::AuthorisedValues;
use Koha::CirculationRules;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Acquisition::Orders;
use Koha::Virtualshelves;
use Koha::Patrons;
use Koha::Plugins;
use Koha::Ratings;
use Koha::Reviews;
use Koha::Serial::Items;
use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;
use Koha::Util::MARC;

use JSON qw( decode_json );

my $query = CGI->new();

my $biblionumber = $query->param('biblionumber') || $query->param('bib') || 0;
$biblionumber = int($biblionumber);

my $specific_item = $query->param('itemnumber') ? Koha::Items->find( scalar $query->param('itemnumber') ) : undef;
$biblionumber = $specific_item->biblionumber if $specific_item;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-detail.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $patron = Koha::Patrons->find( $borrowernumber );

my $biblio = Koha::Biblios->find( $biblionumber );
my $record = $biblio ? $biblio->metadata->record : undef;
unless ( $biblio && $record ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl"); # escape early
    exit;
}

my $items = $biblio->items->search_ordered;
if ($specific_item) {
    $items = $items->search( { itemnumber => scalar $query->param('itemnumber') } );
    $template->param( specific_item => 1 );
}

unless ( $patron and $patron->category->override_hidden_items ) {
    # only skip this check if there's a logged in user
    # and its category overrides OpacHiddenItems
    if ( $biblio->hidden_in_opac({ rules => C4::Context->yaml_preference('OpacHiddenItems') }) ) {
        print $query->redirect('/cgi-bin/koha/errors/404.pl'); # escape early
        exit;
    }
    if ( $items->count >= 1 ) {
        $items = $items->filter_by_visible_in_opac( { patron => $patron } );
    }
}

my $framework = $biblio ? $biblio->frameworkcode : q{};
my $record_processor = Koha::RecordProcessor->new({
    filters => 'ViewPolicy',
    options => {
        interface => 'opac',
        frameworkcode => $framework
    }
});
$record_processor->process($record);

# redirect if opacsuppression is enabled and biblio is suppressed
if (C4::Context->preference('OpacSuppression')) {
    # FIXME hardcoded; the suppression flag ought to be materialized
    # as a column on biblio or the like
    my $opacsuppressionfield = '942';
    my $opacsuppressionfieldvalue = $record->field($opacsuppressionfield);
    # redirect to opac-blocked info page or 404?
    my $opacsuppressionredirect;
    if ( C4::Context->preference("OpacSuppressionRedirect") ) {
        $opacsuppressionredirect = "/cgi-bin/koha/opac-blocked.pl";
    } else {
        $opacsuppressionredirect = "/cgi-bin/koha/errors/404.pl";
    }
    if ( $opacsuppressionfieldvalue &&
         $opacsuppressionfieldvalue->subfield("n") &&
         $opacsuppressionfieldvalue->subfield("n") == 1) {
        # if OPAC suppression by IP address
        if (C4::Context->preference('OpacSuppressionByIPRange')) {
            my $IPAddress = $ENV{'REMOTE_ADDR'};
            my $IPRange = C4::Context->preference('OpacSuppressionByIPRange');
            if ($IPAddress !~ /^$IPRange/)  {
                print $query->redirect($opacsuppressionredirect);
                exit;
            }
        } else {
            print $query->redirect($opacsuppressionredirect);
            exit;
        }
    }
}

$template->param(
    biblio => $biblio
);

# get biblionumbers stored in the cart
my @cart_list;

if($query->cookie("bib_list")){
    my $cart_list = $query->cookie("bib_list");
    @cart_list = split(/\//, $cart_list);
    if ( grep {$_ eq $biblionumber} @cart_list) {
        $template->param( incart => 1 );
    }
}


SetUTF8Flag($record);
my $marcflavour      = C4::Context->preference("marcflavour");
my $ean = GetNormalizedEAN( $record, $marcflavour );

my $OpacBrowseResults = C4::Context->preference("OpacBrowseResults");

# We look for the busc param to build the simple paging from the search
if ($OpacBrowseResults) {
my $session = get_session($query->cookie("CGISESSID"));
my %paging = (previous => {}, next => {});
if ($session->param('busc')) {
    use URI::Escape qw( uri_escape_utf8 uri_unescape );

    # Rebuild the string to store on session
    # param value is URI encoded and params separator is HTML encode (&amp;)
    sub rebuildBuscParam
    {
        my $arrParamsBusc = shift;

        my $pasarParams = '';
        my $j = 0;
        for (keys %$arrParamsBusc) {
            if ($_ =~ /^(?:query|listBiblios|newlistBiblios|query_type|simple_query|total|offset|offsetSearch|next|previous|count|expand|scan)/) {
                if (defined($arrParamsBusc->{$_})) {
                    $pasarParams .= '&amp;' if ($j);
                    $pasarParams .= $_ . '=' . Encode::decode('UTF-8', uri_escape_utf8( $arrParamsBusc->{$_} ));
                    $j++;
                }
            } else {
                for my $value (@{$arrParamsBusc->{$_}}) {
                    next if !defined($value);
                    $pasarParams .= '&amp;' if ($j);
                    $pasarParams .= $_ . '=' . Encode::decode('UTF-8', uri_escape_utf8($value));
                    $j++;
                }
            }
        }
        return $pasarParams;
    }#rebuildBuscParam

    # Search given the current values from the busc param
    sub searchAgain
    {
        my ($arrParamsBusc, $offset, $results_per_page, $patron) = @_;

        my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };
        my @servers;
        @servers = @{$arrParamsBusc->{'server'}} if $arrParamsBusc->{'server'};
        @servers = ("biblioserver") unless (@servers);

        my ($default_sort_by, @sort_by);
        $default_sort_by = C4::Context->default_catalog_sort_by;
        @sort_by = @{$arrParamsBusc->{'sort_by'}} if $arrParamsBusc->{'sort_by'};
        $sort_by[0] = $default_sort_by if !$sort_by[0] && defined($default_sort_by);
        my ($error, $results_hashref, $facets);
        eval {
            my $searcher = Koha::SearchEngine::Search->new(
                { index => $Koha::SearchEngine::BIBLIOS_INDEX } );
            my $json = JSON->new->utf8->allow_nonref(1);
            ($error, $results_hashref, $facets) = $searcher->search_compat($json->decode($arrParamsBusc->{'query'}),$arrParamsBusc->{'simple_query'},\@sort_by,\@servers,$results_per_page,$offset,undef,$itemtypes,$arrParamsBusc->{'query_type'},$arrParamsBusc->{'scan'});
        };
        my $hits;
        my @newresults;
        my $search_context = {
            interface => 'opac',
            patron    => $patron,
        };
        for (my $i=0;$i<@servers;$i++) {
            my $server = $servers[$i];
            $hits = $results_hashref->{$server}->{"hits"};
            @newresults = searchResults( $search_context, '', $hits, $results_per_page, $offset, $arrParamsBusc->{'scan'}, $results_hashref->{$server}->{"RECORDS"});
        }
        return \@newresults;
    }#searchAgain

    # Build the current list of biblionumbers in this search
    sub buildListBiblios
    {
        my ($newresultsRef, $results_per_page) = @_;

        my $listBiblios = '';
        my $j = 0;
        foreach (@$newresultsRef) {
            my $bibnum = ($_->{biblionumber})?$_->{biblionumber}:0;
            $listBiblios .= $bibnum . ',';
            $j++;
            last if ($j == $results_per_page);
        }
        chop $listBiblios if ($listBiblios =~ /,$/);
        return $listBiblios;
    }#buildListBiblios

    my $busc = $session->param("busc");
    my @arrBusc = split(/\&(?:amp;)?/, $busc);
    my ($key, $value);
    my %arrParamsBusc = ();
    for (@arrBusc) {
        ($key, $value) = split(/=/, $_, 2);
        if ($key =~ /^(?:query|listBiblios|newlistBiblios|query_type|simple_query|next|previous|total|offset|offsetSearch|count|expand|scan)/) {
            $arrParamsBusc{$key} = uri_unescape($value);
        } else {
            unless (exists($arrParamsBusc{$key})) {
                $arrParamsBusc{$key} = [];
            }
            push @{$arrParamsBusc{$key}}, uri_unescape($value);
        }
    }
    my $searchAgain = 0;
    my $count = C4::Context->preference('OPACnumSearchResults') || 20;
    my $results_per_page = ($arrParamsBusc{'count'} && $arrParamsBusc{'count'} =~ /^[0-9]+?/)?$arrParamsBusc{'count'}:$count;
    $arrParamsBusc{'count'} = $results_per_page;
    my $offset = ($arrParamsBusc{'offset'} && $arrParamsBusc{'offset'} =~ /^[0-9]+?/)?$arrParamsBusc{'offset'}:0;
    # The value OPACnumSearchResults has changed and the search has to be rebuild
    if ($count != $results_per_page) {
        if (exists($arrParamsBusc{'listBiblios'}) && $arrParamsBusc{'listBiblios'} =~ /^[0-9]+(?:,[0-9]+)*$/) {
            my $indexBiblio = 0;
            my @arrBibliosAux = split(',', $arrParamsBusc{'listBiblios'});
            for (@arrBibliosAux) {
                last if ($_ == $biblionumber);
                $indexBiblio++;
            }
            $indexBiblio += $offset;
            $offset = int($indexBiblio / $count) * $count;
            $arrParamsBusc{'offset'} = $offset;
        }
        $arrParamsBusc{'count'} = $count;
        $results_per_page = $count;
        my $newresultsRef = searchAgain(\%arrParamsBusc, $offset, $results_per_page, $patron);
        $arrParamsBusc{'listBiblios'} = buildListBiblios($newresultsRef, $results_per_page);
        delete $arrParamsBusc{'previous'} if (exists($arrParamsBusc{'previous'}));
        delete $arrParamsBusc{'next'} if (exists($arrParamsBusc{'next'}));
        delete $arrParamsBusc{'offsetSearch'} if (exists($arrParamsBusc{'offsetSearch'}));
        delete $arrParamsBusc{'newlistBiblios'} if (exists($arrParamsBusc{'newlistBiblios'}));
        my $newbusc = rebuildBuscParam(\%arrParamsBusc);
        $session->param("busc" => $newbusc);
        @arrBusc = split(/\&(?:amp;)?/, $newbusc);
    } else {
        my $modifyListBiblios = 0;
        # We come from a previous click
        if (exists($arrParamsBusc{'previous'})) {
            $modifyListBiblios = 1 if ($biblionumber == $arrParamsBusc{'previous'});
            delete $arrParamsBusc{'previous'};
        } elsif (exists($arrParamsBusc{'next'})) { # We come from a next click
            $modifyListBiblios = 2 if ($biblionumber == $arrParamsBusc{'next'});
            delete $arrParamsBusc{'next'};
        }
        if ($modifyListBiblios) {
            if (exists($arrParamsBusc{'newlistBiblios'})) {
                my $listBibliosAux = $arrParamsBusc{'listBiblios'};
                $arrParamsBusc{'listBiblios'} = $arrParamsBusc{'newlistBiblios'};
                my @arrAux = split(',', $listBibliosAux);
                $arrParamsBusc{'newlistBiblios'} = $listBibliosAux;
                if ($modifyListBiblios == 1) {
                    $arrParamsBusc{'next'} = $arrAux[0];
                    $paging{'next'}->{biblionumber} = $arrAux[0];
                }else {
                    $arrParamsBusc{'previous'} = $arrAux[$#arrAux];
                    $paging{'previous'}->{biblionumber} = $arrAux[$#arrAux];
                }
            } else {
                delete $arrParamsBusc{'listBiblios'};
            }
            my $offsetAux = $arrParamsBusc{'offset'};
            $arrParamsBusc{'offset'} = $arrParamsBusc{'offsetSearch'};
            $arrParamsBusc{'offsetSearch'} = $offsetAux;
            $offset = $arrParamsBusc{'offset'};
            my $newbusc = rebuildBuscParam(\%arrParamsBusc);
            $session->param("busc" => $newbusc);
            @arrBusc = split(/\&(?:amp;)?/, $newbusc);
        }
    }
    my $buscParam = '';
    my $j = 0;
    # Rebuild the query for the button "back to results"
    for (@arrBusc) {
        unless ($_ =~ /^(?:query|listBiblios|newlistBiblios|query_type|simple_query|next|previous|total|count|offsetSearch)/) {
            $buscParam .= '&amp;' unless ($j == 0);
            $buscParam .= $_; # string already URI encoded
            $j++;
        }
    }
    $template->param('busc' => $buscParam);
    my $offsetSearch;
    my @arrBiblios;
    # We are inside the list of biblios and we don't have to search
    if (exists($arrParamsBusc{'listBiblios'}) && $arrParamsBusc{'listBiblios'} =~ /^[0-9]+(?:,[0-9]+)*$/) {
        @arrBiblios = split(',', $arrParamsBusc{'listBiblios'});
        if (@arrBiblios) {
            # We are at the first item of the list
            if ($arrBiblios[0] == $biblionumber) {
                if (@arrBiblios > 1) {
                    for (my $j = 1; $j < @arrBiblios; $j++) {
                        next unless ($arrBiblios[$j]);
                        $paging{'next'}->{biblionumber} = $arrBiblios[$j];
                        last;
                    }
                }
                # search again if we are not at the first searching list
                if ($offset && !$arrParamsBusc{'previous'}) {
                    $searchAgain = 1;
                    $offsetSearch = $offset - $results_per_page;
                }
            # we are at the last item of the list
            } elsif ($arrBiblios[$#arrBiblios] == $biblionumber) {
                for (my $j = $#arrBiblios - 1; $j >= 0; $j--) {
                    next unless ($arrBiblios[$j]);
                    $paging{'previous'}->{biblionumber} = $arrBiblios[$j];
                    last;
                }
                if (!$offset) {
                    # search again if we are at the first list and there is more results
                    $searchAgain = 1 if (!$arrParamsBusc{'next'} && $arrParamsBusc{'total'} != @arrBiblios);
                } else {
                    # search again if we aren't at the first list and there is more results
                    $searchAgain = 1 if (!$arrParamsBusc{'next'} && $arrParamsBusc{'total'} > ($offset + @arrBiblios));
                }
                $offsetSearch = $offset + $results_per_page if ($searchAgain);
            } else {
                for (my $j = 1; $j < $#arrBiblios; $j++) {
                    if ($arrBiblios[$j] == $biblionumber) {
                        for (my $z = $j - 1; $z >= 0; $z--) {
                            next unless ($arrBiblios[$z]);
                            $paging{'previous'}->{biblionumber} = $arrBiblios[$z];
                            last;
                        }
                        for (my $z = $j + 1; $z < @arrBiblios; $z++) {
                            next unless ($arrBiblios[$z]);
                            $paging{'next'}->{biblionumber} = $arrBiblios[$z];
                            last;
                        }
                        last;
                    }
                }
            }
        }
        $offsetSearch = 0 if (defined($offsetSearch) && $offsetSearch < 0);
    }
    if ($searchAgain) {
        my $newresultsRef = searchAgain(\%arrParamsBusc, $offsetSearch, $results_per_page, $patron);
        my @newresults = @$newresultsRef;
        # build the new listBiblios
        my $listBiblios = buildListBiblios(\@newresults, $results_per_page);
        unless (exists($arrParamsBusc{'listBiblios'})) {
            $arrParamsBusc{'listBiblios'} = $listBiblios;
            @arrBiblios = split(',', $arrParamsBusc{'listBiblios'});
        } else {
            $arrParamsBusc{'newlistBiblios'} = $listBiblios;
        }
        # From the new list we build again the next and previous result
        if (@arrBiblios) {
            if ($arrBiblios[0] == $biblionumber) {
                for (my $j = $#newresults; $j >= 0; $j--) {
                    next unless ($newresults[$j]);
                    $paging{'previous'}->{biblionumber} = $newresults[$j]->{biblionumber};
                    $arrParamsBusc{'previous'} = $paging{'previous'}->{biblionumber};
                    $arrParamsBusc{'offsetSearch'} = $offsetSearch;
                   last;
                }
            } elsif ($arrBiblios[$#arrBiblios] == $biblionumber) {
                for (my $j = 0; $j < @newresults; $j++) {
                    next unless ($newresults[$j]);
                    $paging{'next'}->{biblionumber} = $newresults[$j]->{biblionumber};
                    $arrParamsBusc{'next'} = $paging{'next'}->{biblionumber};
                    $arrParamsBusc{'offsetSearch'} = $offsetSearch;
                    last;
                }
            }
        }
        # build new busc param
        my $newbusc = rebuildBuscParam(\%arrParamsBusc);
        $session->param("busc" => $newbusc);
    }
    my ($numberBiblioPaging, $dataBiblioPaging);
    # Previous biblio
    $numberBiblioPaging = $paging{'previous'}->{biblionumber};
    if ($numberBiblioPaging) {
        $template->param( 'previousBiblionumber' => $numberBiblioPaging );
        $dataBiblioPaging = Koha::Biblios->find( $numberBiblioPaging );
        $template->param('previousTitle' => $dataBiblioPaging->title) if $dataBiblioPaging;
    }
    # Next biblio
    $numberBiblioPaging = $paging{'next'}->{biblionumber};
    if ($numberBiblioPaging) {
        $template->param( 'nextBiblionumber' => $numberBiblioPaging );
        $dataBiblioPaging = Koha::Biblios->find( $numberBiblioPaging );
        $template->param('nextTitle' => $dataBiblioPaging->title) if $dataBiblioPaging;
    }
    # Partial list of biblio results
    my @listResults;
    for (my $j = 0; $j < @arrBiblios; $j++) {
        next unless ($arrBiblios[$j]);
        $dataBiblioPaging = Koha::Biblios->find( $arrBiblios[$j] ) if ($arrBiblios[$j] != $biblionumber);
        next unless $dataBiblioPaging;
        push @listResults, {index => $j + 1 + $offset, biblionumber => $arrBiblios[$j], title => ($arrBiblios[$j] == $biblionumber)?'':$dataBiblioPaging->title, author => ($arrBiblios[$j] != $biblionumber && $dataBiblioPaging->author)?$dataBiblioPaging->author:'', part_number => ($arrBiblios[$j] == $biblionumber)?'':$dataBiblioPaging->part_number, part_name => ($arrBiblios[$j] == $biblionumber)?'':$dataBiblioPaging->part_name, url => ($arrBiblios[$j] == $biblionumber)?'':'opac-detail.pl?biblionumber=' . $arrBiblios[$j]};
    }
    $template->param('listResults' => \@listResults) if (@listResults);
    $template->param('indexPag' => 1 + $offset, 'totalPag' => $arrParamsBusc{'total'}, 'indexPagEnd' => scalar(@arrBiblios) + $offset);
    $template->param( 'offset' => $offset );
}
}

$items = Koha::Items->search_ordered(
    [
        'me.biblionumber' => $biblionumber,
        'me.itemnumber' => {
            -in => [
                $biblio->host_items->get_column('itemnumber')
            ]
        }
    ],
    { prefetch => [ 'issue', 'homebranch', 'holdingbranch' ] }
)->filter_by_visible_in_opac({ patron => $patron }) unless $specific_item;

my $dat = &GetBiblioData($biblionumber);
my $HideMARC = $record_processor->filters->[0]->should_hide_marc(
    {
        frameworkcode => $dat->{'frameworkcode'},
        interface     => 'opac',
    } );

my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };
# imageurl:
my $itemtype = $dat->{'itemtype'};
if ( $itemtype ) {
    $dat->{'imageurl'}    = getitemtypeimagelocation( 'opac', $itemtypes->{$itemtype}->{'imageurl'} );
    $dat->{'description'} = $itemtypes->{$itemtype}->{translated_description};
}

my $shelflocations =
  { map { $_->{authorised_value} => $_->{opac_description} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $dat->{frameworkcode}, kohafield => 'items.location' } ) };
my $collections =
  { map { $_->{authorised_value} => $_->{opac_description} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $dat->{frameworkcode}, kohafield => 'items.ccode' } ) };
my $copynumbers =
  { map { $_->{authorised_value} => $_->{opac_description} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => $dat->{frameworkcode}, kohafield => 'items.copynumber' } ) };

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       = SearchSubscriptions({ biblionumber => $biblionumber, orderby => 'title' });

my @subs;
$dat->{'serial'}=1 if $subscriptionsnumber;
foreach my $subscription (@subscriptions) {
    my $serials_to_display;
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};
    $cell{missinglist}       = $subscription->{missinglist};
    $cell{opacnote}          = $subscription->{opacnote};
    $cell{histstartdate}     = $subscription->{histstartdate};
    $cell{histenddate}       = $subscription->{histenddate};
    $cell{branchcode}        = $subscription->{branchcode};
    $cell{callnumber}        = $subscription->{callnumber};
    $cell{location}          = $subscription->{location};
    $cell{closed}            = $subscription->{closed};
    $cell{letter}            = $subscription->{letter};
    $cell{biblionumber}      = $subscription->{biblionumber};
    #get the three latest serials.
    $serials_to_display = $subscription->{opacdisplaycount};
    $serials_to_display = C4::Context->preference('OPACSerialIssueDisplayCount') unless $serials_to_display;
	$cell{opacdisplaycount} = $serials_to_display;
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, $serials_to_display );
    if ( $borrowernumber ) {
        my $subscription_object = Koha::Subscriptions->find( $subscription->{subscriptionid} );
        my $subscriber = $subscription_object->subscribers->find( $borrowernumber );
        $cell{hasalert} = 1 if $subscriber;
    }
    push @subs, \%cell;
}

$dat->{'count'} = $items->count;

my (%item_reserves, %priority);
my ($show_holds_count, $show_priority);
for ( C4::Context->preference("OPACShowHoldQueueDetails") ) {
    m/holds/o and $show_holds_count = 1;
    m/priority/ and $show_priority = 1;
}
my $has_hold;
if ( $show_holds_count || $show_priority) {
    my $holds = $biblio->holds;
    $template->param( holds_count  => $holds->count );
    while ( my $hold = $holds->next ) {
        $item_reserves{ $hold->itemnumber }++ if $hold->itemnumber;
        if ($show_priority && $hold->borrowernumber == $borrowernumber) {
            $has_hold = 1;
            $hold->itemnumber
                ? ($priority{ $hold->itemnumber } = $hold->priority)
                : ($template->param( priority => $hold->priority ));
        }
    }
}
$template->param( show_priority => $has_hold ) ;

my %itemfields;
my (@itemloop, @otheritemloop);
my $currentbranch = C4::Context->userenv ? C4::Context->userenv->{branch} : undef;
if ($currentbranch and C4::Context->preference('OpacSeparateHoldings')) {
    $template->param(SeparateHoldings => 1);
}
my $separatebranch = C4::Context->preference('OpacSeparateHoldingsBranch');
my $viewallitems = $query->param('viewallitems');
my $max_items_to_display = C4::Context->preference('OpacMaxItemsToDisplay') // 50;

# Get component parts details
my $showcomp = C4::Context->preference('ShowComponentRecords');
my ( $parts, $show_analytics );
if ( $showcomp eq 'both' || $showcomp eq 'opac' ) {
    if ( my $components = $biblio->get_marc_components(C4::Context->preference('MaxComponentRecords')) ) {
        $show_analytics = 1 if @{$components}; # just show link when having results
        for my $part ( @{$components} ) {
            $part = C4::Search::new_record_from_zebra( 'biblioserver', $part );
            my $id = Koha::SearchEngine::Search::extract_biblionumber( $part );

            push @{$parts},
              XSLTParse4Display(
                {
                    biblionumber => $id,
                    record       => $part,
                    xsl_syspref  => 'OPACXSLTResultsDisplay',
                    fix_amps     => 1,
                }
              );
        }
        $template->param( ComponentParts => $parts );
        my ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        my $cpq = $comp_query_str . "&sort_by=" . $comp_sort;
        $template->param( ComponentPartsQuery => $cpq );
    }
} else { # check if we should show analytics anyway
    $show_analytics = 1 if @{$biblio->get_marc_components(1)}; # count matters here, results does not
}

# XSLT processing of some stuff
my $variables = {};
my $lang = C4::Languages::getlanguage();
my @plugin_responses = Koha::Plugins->call(
    'opac_detail_xslt_variables',
    {
        biblio_id => $biblionumber,
        lang      => $lang,
        patron_id => $borrowernumber,
    },
);
for my $plugin_variables ( @plugin_responses ) {
    $variables = { %$variables, %$plugin_variables };
}
$variables->{anonymous_session} = $borrowernumber ? 0 : 1;
$variables->{show_analytics_link} = $show_analytics;
$template->param(
    XSLTBloc => XSLTParse4Display({
        biblionumber   => $biblionumber,
        record         => $record->clone(),
        xsl_syspref    => 'OPACXSLTDetailsDisplay',
        fix_amps       => 1,
        xslt_variables => $variables,
    }),
);

# Get items on order
if ( C4::Context->preference('OPACAcquisitionDetails' ) ) {
    my $orders = $biblio->orders->filter_by_active;
    my $total_quantity = 0;
    while ( my $order = $orders->next ) {
        $total_quantity += $order->quantity;
    }
    $template->{VARS}->{acquisition_details} = {
        total_quantity => $total_quantity,
    };
}

my $can_item_be_reserved = 0;
my ( $itemloop_has_images, $otheritemloop_has_images );
if ( not $viewallitems and $items->count > $max_items_to_display ) {
    $template->param(
        too_many_items => 1,
        items_count    => $items->count,
    );
}
else {
    my $library_info;
    while ( my $item = $items->next ) {
        my $item_info = $item->unblessed;
        $item_info->{holds_count} = $item_reserves{ $item->itemnumber };
        $item_info->{priority}    = $priority{ $item->itemnumber };

        # Get opac_info from Additional contents for home and holding library
        my ( $opac_info_home, $opac_info_holding );
        $opac_info_holding = $library_info->{ $item->holdingbranch } // $item->holding_branch->opac_info({ lang => $lang });
        $library_info->{ $item->holdingbranch } = $opac_info_holding;
        $opac_info_home = $library_info->{ $item->homebranch } // $item->home_branch->opac_info({ lang => $lang });
        $library_info->{ $item->homebranch } = $opac_info_home;
        $item_info->{holding_library_info} = $opac_info_holding->content if $opac_info_holding;
        $item_info->{home_library_info} = $opac_info_home->content if $opac_info_home;

        $can_item_be_reserved = $can_item_be_reserved || $patron && IsAvailableForItemLevelRequest($item, $patron, undef);

        # get collection code description, too
        my $ccode = $item->ccode;
        $item_info->{'ccode'} = $collections->{$ccode}
          if defined($ccode)
          && $collections
          && exists( $collections->{$ccode} );

        my $copynumber = $item->copynumber;
        $item_info->{copynumber} = $copynumbers->{$copynumber}
          if ( defined($copynumbers)
            && defined($copynumber)
            && exists( $copynumbers->{$copynumber} ) );

        if ( defined $item->location ) {
            $item_info->{'location_description'} =
              $shelflocations->{ $item->location };
        }

        my $itemtype = $item->itemtype;
        $item_info->{'imageurl'} = getitemtypeimagelocation( 'opac',
            $itemtypes->{ $itemtype->itemtype }->{'imageurl'} );
        $item_info->{'description'} =
          $itemtypes->{ $itemtype->itemtype }->{translated_description};

        foreach my $field (
            qw(ccode materials enumchron copynumber itemnotes location_description uri)
          )
        {
            $itemfields{$field} = 1 if $item_info->{$field};
        }

        # FIXME The following must be Koha::Item->serial
        my $serial_item = Koha::Serial::Items->find($item->itemnumber);
        if ( $serial_item ) {
            my $serial = Koha::Serials->find($serial_item->serialid);
            $item_info->{serial} = $serial if $serial;
        }

        $item_info->{checkout} = $item->checkout;
        $item_info->{object} = $item;


        if ( C4::Context->preference("OPACLocalCoverImages") == 1 ) {
            $item_info->{cover_images} = $item->cover_images;
        }


        if ( C4::Context->preference('UseCourseReserves') ) {
            $item_info->{course_reserves} = GetItemCourseReservesInfo( itemnumber => $item->itemnumber );
        }

        $item_info->{holding_branch} = $item->holding_branch;
        $item_info->{home_branch}    = $item->home_branch;

        my $itembranch = $item->$separatebranch;
        if ( $currentbranch
            and C4::Context->preference('OpacSeparateHoldings') )
        {
            if ( $itembranch and $itembranch eq $currentbranch ) {
                push @itemloop, $item_info;
                $itemloop_has_images++ if $item->cover_images->count;
            }
            else {
                push @otheritemloop, $item_info;
                $otheritemloop_has_images++ if $item->cover_images->count;
            }
        }
        else {
            push @itemloop, $item_info;
            $itemloop_has_images++ if $item->cover_images->count;
        }
    }
}

if( $can_item_be_reserved || CountItemsIssued($biblionumber) || $biblio->has_items_waiting_or_intransit ) {
    $template->param( ReservableItems => 1 );
}

$template->param(
    itemloop_has_images      => $itemloop_has_images,
    otheritemloop_has_images => $otheritemloop_has_images,
);

# Display only one tab if one items list is empty
if (scalar(@itemloop) == 0 || scalar(@otheritemloop) == 0) {
    $template->param(SeparateHoldings => 0);
    if (scalar(@itemloop) == 0) {
        @itemloop = @otheritemloop;
    }
}

my $marcnotesarray = $biblio->get_marc_notes({ opac => 1, record => $record });

if( C4::Context->preference('ArticleRequests') ) {
    my $patron = $borrowernumber ? Koha::Patrons->find($borrowernumber) : undef;
    my $itemtype = Koha::ItemTypes->find($biblio->itemtype);
    my $artreqpossible = $patron
        ? $biblio->can_article_request( $patron )
        : $itemtype
        ? $itemtype->may_article_request
        : q{};
    $template->param( artreqpossible => $artreqpossible );
}

my $norequests = ! $biblio->items->filter_by_for_hold->count;
    $template->param(
                     MARCNOTES               => $marcnotesarray,
                     norequests              => $norequests,
                     itemdata_ccode          => $itemfields{ccode},
                     itemdata_materials      => $itemfields{materials},
                     itemdata_enumchron      => $itemfields{enumchron},
                     itemdata_uri            => $itemfields{uri},
                     itemdata_copynumber     => $itemfields{copynumber},
                     itemdata_itemnotes      => $itemfields{itemnotes},
                     itemdata_location       => $itemfields{location_description},
                     OpacStarRatings         => C4::Context->preference("OpacStarRatings"),
    );

if (C4::Context->preference("AlternateHoldingsField") && $items->count == 0) {
    my $fieldspec = C4::Context->preference("AlternateHoldingsField");
    my $subfields = substr $fieldspec, 3;
    my $holdingsep = C4::Context->preference("AlternateHoldingsSeparator") || ' ';
    my @alternateholdingsinfo = ();
    my @holdingsfields = $record->field(substr $fieldspec, 0, 3);

    for my $field (@holdingsfields) {
        my %holding = ( holding => '' );
        my $havesubfield = 0;
        for my $subfield ($field->subfields()) {
            if ((index $subfields, $$subfield[0]) >= 0) {
                $holding{'holding'} .= $holdingsep if (length $holding{'holding'} > 0);
                $holding{'holding'} .= $$subfield[1];
                $havesubfield++;
            }
        }
        if ($havesubfield) {
            push(@alternateholdingsinfo, \%holding);
        }
    }

    $template->param(
        ALTERNATEHOLDINGS   => \@alternateholdingsinfo,
        );
}

# FIXME: The template uses this hash directly. Need to filter.
foreach ( keys %{$dat} ) {
    next if ( $HideMARC->{$_} );
    $template->param( "$_" => defined $dat->{$_} ? $dat->{$_} : '' );
}

# some useful variables for enhanced content;
# in each case, we're grabbing the first value we find in
# the record and normalizing it
my $upc = GetNormalizedUPC($record,$marcflavour);
my $oclc = GetNormalizedOCLCNumber($record,$marcflavour);
my $isbn = GetNormalizedISBN(undef,$record,$marcflavour);
my $content_identifier_exists;
if ( $isbn or $ean or $oclc or $upc ) {
    $content_identifier_exists = 1;
}
$template->param(
	normalized_upc => $upc,
	normalized_ean => $ean,
	normalized_oclc => $oclc,
	normalized_isbn => $isbn,
	content_identifier_exists =>  $content_identifier_exists,
);

# Catch the exception as Koha::Biblio::Metadata->record can explode if the MARCXML is invalid
# COinS format FIXME: for books Only
my $coins = eval { $biblio->get_coins };
$template->param( ocoins => $coins );

my ( $loggedincommenter, $reviews );
if ( C4::Context->preference('OPACComments') ) {
    $reviews = Koha::Reviews->search(
        {
            biblionumber => $biblionumber,
            -or => { approved => 1, borrowernumber => $borrowernumber }
        },
        {
            order_by => { -desc => 'datereviewed' }
        }
    )->unblessed;
    my $libravatar_enabled = 0;
    if ( C4::Context->preference('ShowReviewer') and C4::Context->preference('ShowReviewerPhoto') ) {
        eval {
            require Libravatar::URL;
            Libravatar::URL->import();
        };
        if ( !$@ ) {
            $libravatar_enabled = 1;
        }
    }
    for my $review (@$reviews) {
        my $review_patron = Koha::Patrons->find( $review->{borrowernumber} ); # FIXME Should be Koha::Review->reviewer or similar

        # setting some borrower info into this hash
        if ( $review_patron ) {
            $review->{patron} = $review_patron;
            if ( $libravatar_enabled and $review_patron->email ) {
                $review->{avatarurl} = libravatar_url( email => $review_patron->email, https => $ENV{HTTPS} );
            }

            if ( $review_patron->borrowernumber eq $borrowernumber ) {
                $loggedincommenter = 1;
            }
        }
    }
}

if ( C4::Context->preference("OPACISBD") ) {
    $template->param( ISBD => 1 );
}

$template->param(
    itemloop            => \@itemloop,
    otheritemloop       => \@otheritemloop,
    biblionumber        => $biblionumber,
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
    reviews             => $reviews,
    loggedincommenter   => $loggedincommenter
);

# Lists
if (C4::Context->preference("virtualshelves") ) {
    my $shelves = Koha::Virtualshelves->search(
        {
            biblionumber => $biblionumber,
            public       => 1,
        },
        {
            join => 'virtualshelfcontents',
        }
    );
    $template->param( shelves => $shelves );
}

# XISBN Stuff
if (C4::Context->preference("OPACFRBRizeEditions")==1) {
    eval {
        $template->param(
            XISBNS => scalar get_xisbns($isbn, $biblionumber)
        );
    };
    if ($@) { warn "XISBN Failed $@"; }
}

# Serial Collection
my @sc_fields = $record->field(955);
my @lc_fields = $marcflavour eq 'UNIMARC'
    ? $record->field(930)
    : $record->field(852);
my @serialcollections = ();

foreach my $sc_field (@sc_fields) {
    my %row_data;

    $row_data{text}    = $sc_field->subfield('r');
    $row_data{branch}  = $sc_field->subfield('9');
    foreach my $lc_field (@lc_fields) {
        $row_data{itemcallnumber} = $marcflavour eq 'UNIMARC'
            ? $lc_field->subfield('a') # 930$a
            : $lc_field->subfield('h') # 852$h
            if ($sc_field->subfield('5') eq $lc_field->subfield('5'));
    }

    if ($row_data{text} && $row_data{branch}) { 
        push (@serialcollections, \%row_data);
    }
}

if (scalar(@serialcollections) > 0) {
    $template->param(
	serialcollection  => 1,
	serialcollections => \@serialcollections);
}

# Local cover Images stuff
if (C4::Context->preference("OPACLocalCoverImages")){
		$template->param(OPACLocalCoverImages => 1);
}

# HTML5 Media
if ( (C4::Context->preference("HTML5MediaEnabled") eq 'both') or (C4::Context->preference("HTML5MediaEnabled") eq 'opac') ) {
    $template->param( C4::HTML5Media->gethtml5media($record));
}

my $syndetics_elements;

if ( C4::Context->preference("SyndeticsEnabled") ) {
    $template->param("SyndeticsEnabled" => 1);
    $template->param("SyndeticsClientCode" => C4::Context->preference("SyndeticsClientCode"));
	eval {
	    $syndetics_elements = &get_syndetics_index($isbn,$upc,$oclc);
	    for my $element (values %$syndetics_elements) {
		$template->param("Syndetics$element"."Exists" => 1 );
		#warn "Exists: "."Syndetics$element"."Exists";
	}
    };
    warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
        && C4::Context->preference("SyndeticsSummary")
        && ( exists($syndetics_elements->{'SUMMARY'}) || exists($syndetics_elements->{'AVSUMMARY'}) ) ) {
	eval {
	    my $syndetics_summary = &get_syndetics_summary($isbn,$upc,$oclc, $syndetics_elements);
	    $template->param( SYNDETICS_SUMMARY => $syndetics_summary );
	};
	warn $@ if $@;

}

if ( C4::Context->preference("SyndeticsEnabled")
        && C4::Context->preference("SyndeticsTOC")
        && exists($syndetics_elements->{'TOC'}) ) {
	eval {
    my $syndetics_toc = &get_syndetics_toc($isbn,$upc,$oclc);
    $template->param( SYNDETICS_TOC => $syndetics_toc );
	};
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsExcerpt")
    && exists($syndetics_elements->{'DBCHAPTER'}) ) {
    eval {
    my $syndetics_excerpt = &get_syndetics_excerpt($isbn,$upc,$oclc);
    $template->param( SYNDETICS_EXCERPT => $syndetics_excerpt );
    };
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsReviews")) {
    eval {
    my $syndetics_reviews = &get_syndetics_reviews($isbn,$upc,$oclc,$syndetics_elements);
    $template->param( SYNDETICS_REVIEWS => $syndetics_reviews );
    };
	warn $@ if $@;
}

if ( C4::Context->preference("SyndeticsEnabled")
    && C4::Context->preference("SyndeticsAuthorNotes")
	&& exists($syndetics_elements->{'ANOTES'}) ) {
    eval {
    my $syndetics_anotes = &get_syndetics_anotes($isbn,$upc,$oclc);
    $template->param( SYNDETICS_ANOTES => $syndetics_anotes );
    };
    warn $@ if $@;
}

# LibraryThingForLibraries ID Code and Tabbed View Option
if( C4::Context->preference('LibraryThingForLibrariesEnabled') ) 
{ 
$template->param(LibraryThingForLibrariesID =>
C4::Context->preference('LibraryThingForLibrariesID') ); 
$template->param(LibraryThingForLibrariesTabbedView =>
C4::Context->preference('LibraryThingForLibrariesTabbedView') );
} 

# Novelist Select
if( C4::Context->preference('NovelistSelectEnabled') ) 
{ 
$template->param(NovelistSelectProfile => C4::Context->preference('NovelistSelectProfile') ); 
$template->param(NovelistSelectPassword => C4::Context->preference('NovelistSelectPassword') ); 
$template->param(NovelistSelectView => C4::Context->preference('NovelistSelectView') ); 
} 


# Babelthèque
if ( C4::Context->preference("Babeltheque") ) {
    $template->param( 
        Babeltheque => 1,
        Babeltheque_url_js => C4::Context->preference("Babeltheque_url_js"),
    );
}

# Social Networks
if ( C4::Context->preference( "SocialNetworks" ) ) {
    $template->param( current_url => C4::Context->preference('OPACBaseURL') . "/cgi-bin/koha/opac-detail.pl?biblionumber=$biblionumber" );
    $template->param( SocialNetworks => 1 );
}

# Shelf Browser Stuff
if (C4::Context->preference("OPACShelfBrowser")) {
    my $starting_itemnumber = $query->param('shelfbrowse_itemnumber');
    if (defined($starting_itemnumber)) {
        $template->param( OpenOPACShelfBrowser => 1) if $starting_itemnumber;
        my $nearby = GetNearbyItems($starting_itemnumber);

        $template->param(
            starting_itemnumber => $starting_itemnumber,
            starting_homebranch => $nearby->{starting_homebranch}->{description},
            starting_location => $nearby->{starting_location}->{description},
            starting_ccode => $nearby->{starting_ccode}->{description},
            shelfbrowser_prev_item => $nearby->{prev_item},
            shelfbrowser_next_item => $nearby->{next_item},
            shelfbrowser_items => $nearby->{items},
        );

        # in which tab shelf browser should open ?
        if (grep { $starting_itemnumber == $_->{itemnumber} } @itemloop) {
            $template->param(shelfbrowser_tab => 'holdings');
        } else {
            $template->param(shelfbrowser_tab => 'otherholdings');
        }
    }
}

$template->param( AmazonTld => get_amazon_tld() ) if ( C4::Context->preference("OPACAmazonCoverImages"));

if (C4::Context->preference("BakerTaylorEnabled")) {
	$template->param(
		BakerTaylorEnabled  => 1,
		BakerTaylorImageURL => &image_url(),
		BakerTaylorLinkURL  => &link_url(),
		BakerTaylorBookstoreURL => C4::Context->preference('BakerTaylorBookstoreURL'),
	);
	my ($bt_user, $bt_pass);
	if ($isbn and
		$bt_user = C4::Context->preference('BakerTaylorUsername') and
		$bt_pass = C4::Context->preference('BakerTaylorPassword')    )
	{
		$template->param(
		BakerTaylorContentURL   =>
        sprintf("https://contentcafe2.btol.com/ContentCafeClient/ContentCafe.aspx?UserID=%s&Password=%s&ItemKey=%s&Options=Y",
				$bt_user,$bt_pass,$isbn)
		);
	}
}

my $tag_quantity;
if (C4::Context->preference('TagsEnabled') and $tag_quantity = C4::Context->preference('TagsShowOnDetail')) {
	$template->param(
		TagsEnabled => 1,
		TagsShowOnDetail => $tag_quantity,
		TagsInputOnDetail => C4::Context->preference('TagsInputOnDetail')
	);
	$template->param(TagLoop => get_tags({biblionumber=>$biblionumber, approved=>1,
								'sort'=>'-weight', limit=>$tag_quantity}));
}

if (C4::Context->preference("OPACURLOpenInNewWindow")) {
    # These values are going to be read by Javascript, at least in the case
    # of the google covers
    $template->param(covernewwindow => 'true');
} else {
    $template->param(covernewwindow => 'false');
}

$template->param(borrowernumber => $borrowernumber);

if ( C4::Context->preference('OpacStarRatings') !~ /disable/ ) {
    my $ratings = Koha::Ratings->search({ biblionumber => $biblionumber });
    my $my_rating = $borrowernumber ? $ratings->search({ borrowernumber => $borrowernumber })->next : undef;
    $template->param(
        ratings => $ratings,
        my_rating => $my_rating,
    );
}

#Search for title in links
my $marccontrolnumber   = GetMarcControlnumber ($record, $marcflavour);
my $marcissns = GetMarcISSN ( $record, $marcflavour );
my $issn = $marcissns->[0] || '';

if (my $search_for_title = C4::Context->preference('OPACSearchForTitleIn')){
    $dat->{title} =~ s/\/+$//; # remove trailing slash
    $dat->{title} =~ s/\s+$//; # remove trailing space
    my $oclc_no = Koha::Util::MARC::oclc_number( $record );
    $search_for_title = parametrized_url(
        $search_for_title,
        {
            TITLE         => $dat->{title},
            AUTHOR        => $dat->{author},
            ISBN          => $isbn,
            ISSN          => $issn,
            CONTROLNUMBER => $marccontrolnumber,
            BIBLIONUMBER  => $biblionumber,
            OCLC_NO       => $oclc_no,
        }
    );
    $template->param('OPACSearchForTitleIn' => $search_for_title);
}

#IDREF
if ( C4::Context->preference("IDREF") ) {
    # If the record comes from the SUDOC
    if ( $record->field('009') ) {
        my $unimarc3 = $record->field("009")->data;
        if ( $unimarc3 =~ /^\d+$/ ) {
            $template->param(
                IDREF => 1,
            );
        }
    }
}

# We try to select the best default tab to show, according to what
# the user wants, and what's available for display
my $opac_serial_default = C4::Context->preference('opacSerialDefaultTab');
my $defaulttab = 
    $viewallitems
        ? 'holdings' :
    $opac_serial_default eq 'subscriptions' && $subscriptionsnumber
        ? 'subscriptions' :
    $opac_serial_default eq 'serialcollection' && @serialcollections > 0
        ? 'serialcollection' :
    $opac_serial_default eq 'holdings' && scalar (@itemloop) > 0
        ? 'holdings' :
    ( $showcomp eq 'both' || $showcomp eq 'opac' ) && scalar (@itemloop) == 0 && $parts
        ? 'components' :
    scalar (@itemloop) == 0
        ? 'media' :
    $subscriptionsnumber
        ? 'subscriptions' :
    @serialcollections > 0 
        ? 'serialcollection' : 'subscriptions';
$template->param('defaulttab' => $defaulttab);

if (C4::Context->preference('OPACLocalCoverImages') == 1) {
    $template->param( localimages => $biblio->cover_images );
}

$template->{VARS}->{OPACPopupAuthorsSearch} = C4::Context->preference('OPACPopupAuthorsSearch');

if (C4::Context->preference('OpacHighlightedWords')) {
    $template->{VARS}->{query_desc} = $query->param('query_desc');
}
$template->{VARS}->{'trackclicks'} = C4::Context->preference('TrackClicks');

$template->param(
    'OpacLocationBranchToDisplay' => C4::Context->preference('OpacLocationBranchToDisplay'),
);

if ( C4::Context->preference('OPACAuthorIdentifiers') ) {
    my @author_identifiers;
    for my $author ( @{ $biblio->get_marc_authors } ) {
        my $authid    = $author->{authoritylink};
        my $authority = Koha::Authorities->find($authid);
        next unless $authority;
        my $identifiers = $authority->get_identifiers;
        next unless $identifiers && @$identifiers;
        my ($name) =
          map  { $_->{value} }
          grep { $_->{code} eq 'a' ? $_ : () }
          @{ $author->{MARCAUTHOR_SUBFIELDS_LOOP} };
        push @author_identifiers,
          { authid => $authid, name => $name, identifiers => $identifiers };
    }
    $template->param( author_identifiers => \@author_identifiers );
}

output_html_with_http_headers $query, $cookie, $template->output;
