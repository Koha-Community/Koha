#!/usr/bin/perl

# Copyright 2008 Garry Collum and the Koha Development team
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

# Script to perform searching
# Mostly copied from search.pl, see POD there
use Modern::Perl;

## STEP 1. Load things that are used in both search page and
# results page and decide which template to load, operations 
# to perform, etc.
## load Koha modules
use C4::Context;
use List::MoreUtils q/any/;

use C4::Output;
use C4::Auth qw(:DEFAULT get_session);
use C4::Languages qw(getLanguages);
use C4::Search;
use C4::Search::History;
use C4::Biblio;  # GetBiblioData
use C4::Koha;
use C4::Tags qw(get_tags);
use C4::Branch; # GetBranches
use C4::SocialData;
use C4::Ratings;
use C4::External::OverDrive;

use POSIX qw(ceil floor strftime);
use URI::Escape;
use JSON qw/decode_json encode_json/;
use Business::ISBN;

my $DisplayMultiPlaceHold = C4::Context->preference("DisplayMultiPlaceHold");
# create a new CGI object
# FIXME: no_undef_params needs to be tested
use CGI qw('-no_undef_params');
my $cgi = new CGI;

my $branch_group_limit = $cgi->param("branch_group_limit");
if ( $branch_group_limit ) {
    if ( $branch_group_limit =~ /^multibranchlimit-/ ) {
        # For search groups we are going to convert this branch_group_limit CGI
        # parameter into a multibranchlimit CGI parameter for the purposes of
        # actually performing the query
        $cgi->param(
            -name => 'multibranchlimit',
            -values => substr($branch_group_limit, 17)
        );
    } else {
        $cgi->append(
            -name => 'limit',
            -values => [ $branch_group_limit ]
        );
    }
}

BEGIN {
    if (C4::Context->preference('BakerTaylorEnabled')) {
        require C4::External::BakerTaylor;
        import C4::External::BakerTaylor qw(&image_url &link_url);
    }
}

my ($template,$borrowernumber,$cookie);
# decide which template to use
my $template_name;
my $template_type = 'basic';
my @params = $cgi->param("limit");


my $format = $cgi->param("format") || '';
my $build_grouped_results = C4::Context->preference('OPACGroupResults');
if ($format =~ /(rss|atom|opensearchdescription)/) {
    $template_name = 'opac-opensearch.tt';
}
elsif (@params && $build_grouped_results) {
    $template_name = 'opac-results-grouped.tt';
}
elsif ((@params>=1) || ($cgi->param("q")) || ($cgi->param('multibranchlimit')) || ($cgi->param('limit-yr')) ) {
    $template_name = 'opac-results.tt';
}
else {
    $template_name = 'opac-advsearch.tt';
    $template_type = 'advsearch';
}
# load the template
($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $template_name,
    query => $cgi,
    type => "opac",
    authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $lang = C4::Languages::getlanguage($cgi);

if ($template_name eq 'opac-results.tt') {
   $template->param('COinSinOPACResults' => C4::Context->preference('COinSinOPACResults'));
}

# get biblionumbers stored in the cart
my @cart_list;

if($cgi->cookie("bib_list")){
    my $cart_list = $cgi->cookie("bib_list");
    @cart_list = split(/\//, $cart_list);
}

if ($format eq 'rss2' or $format eq 'opensearchdescription' or $format eq 'atom') {
    $template->param($format => 1);
    $template->param(timestamp => strftime("%Y-%m-%dT%H:%M:%S-00:00", gmtime)) if ($format eq 'atom'); 
    # FIXME - the timestamp is a hack - the biblio update timestamp should be used for each
    # entry, but not sure if that's worth an extra database query for each bib
}
if (C4::Context->preference("marcflavour") eq "UNIMARC" ) {
    $template->param('UNIMARC' => 1);
}
elsif (C4::Context->preference("marcflavour") eq "MARC21" ) {
    $template->param('usmarc' => 1);
}
$template->param( 'AllowOnShelfHolds' => C4::Context->preference('AllowOnShelfHolds') );
$template->param( 'OPACNoResultsFound' => C4::Context->preference('OPACNoResultsFound') );

$template->param(
    OpacStarRatings => C4::Context->preference("OpacStarRatings") );

if (C4::Context->preference('BakerTaylorEnabled')) {
    $template->param(
        BakerTaylorEnabled  => 1,
        BakerTaylorImageURL => &image_url(),
        BakerTaylorLinkURL  => &link_url(),
        BakerTaylorBookstoreURL => C4::Context->preference('BakerTaylorBookstoreURL'),
    );
}

if (C4::Context->preference('TagsEnabled')) {
    $template->param(TagsEnabled => 1);
    foreach (qw(TagsShowOnList TagsInputOnList)) {
        C4::Context->preference($_) and $template->param($_ => 1);
    }
}

## URI Re-Writing
# Deprecated, but preserved because it's interesting :-)
# The same thing can be accomplished with mod_rewrite in
# a more elegant way
#                  
#my $rewrite_flag;
#my $uri = $cgi->url(-base => 1);
#my $relative_url = $cgi->url(-relative=>1);
#$uri.="/".$relative_url."?";
#warn "URI:$uri";
#my @cgi_params_list = $cgi->param();
#my $url_params = $cgi->Vars;
#
#for my $each_param_set (@cgi_params_list) {
#    $uri.= join "",  map "\&$each_param_set=".$_, split("\0",$url_params->{$each_param_set}) if $url_params->{$each_param_set};
#}
#warn "New URI:$uri";
# Only re-write a URI if there are params or if it already hasn't been re-written
#unless (($cgi->param('r')) || (!$cgi->param()) ) {
#    print $cgi->redirect(     -uri=>$uri."&r=1",
#                            -cookie => $cookie);
#    exit;
#}

# load the branches

my $branches = GetBranches();   # used later in *getRecords, probably should be internalized by those functions after caching in C4::Branch is established
$template->param(
    searchdomainloop => GetBranchCategories('searchdomain'),
);

# load the language limits (for search)
my $languages_limit_loop = getLanguages($lang, 1);
$template->param(search_languages_loop => $languages_limit_loop,);

# load the Type stuff
my $itemtypes = GetItemTypes;
# the index parameter is different for item-level itemtypes
my $itype_or_itemtype = (C4::Context->preference("item-level_itypes"))?'itype':'itemtype';
my @advancedsearchesloop;
my $cnt;
my $advanced_search_types = C4::Context->preference("AdvancedSearchTypes") || "itemtypes";
my @advanced_search_types = split(/\|/, $advanced_search_types);

my $hidingrules = {};
my $yaml = C4::Context->preference('OpacHiddenItems');
if ( $yaml =~ /\S/ ) {
    $yaml = "$yaml\n\n"; # YAML expects trailing newline. Surplus does not hurt.
    eval {
        $hidingrules = YAML::Load($yaml);
    };
    if ($@) {
        warn "Unable to parse OpacHiddenItems syspref : $@";
    }
}

foreach my $advanced_srch_type (@advanced_search_types) {
    $advanced_srch_type =~ s/^\s*//;
    $advanced_srch_type =~ s/\s*$//;
   if ($advanced_srch_type eq 'itemtypes') {
   # itemtype is a special case, since it's not defined in authorized values
        my @itypesloop;
	foreach my $thisitemtype ( sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} } keys %$itemtypes ) {
            next if $hidingrules->{itype} && any { $_ eq $thisitemtype } @{$hidingrules->{itype}};
            next if $hidingrules->{itemtype} && any { $_ eq $thisitemtype } @{$hidingrules->{itemtype}};
	    my %row =(  number=>$cnt++,
		ccl => "$itype_or_itemtype,phr",
                code => $thisitemtype,
                description => $itemtypes->{$thisitemtype}->{'description'},
                imageurl=> getitemtypeimagelocation( 'opac', $itemtypes->{$thisitemtype}->{'imageurl'} ),
            );
	    push @itypesloop, \%row;
	}
        my %search_code = (  advanced_search_type => $advanced_srch_type,
                             code_loop => \@itypesloop );
        push @advancedsearchesloop, \%search_code;
    } else {
    # covers all the other cases: non-itemtype authorized values
       my $advsearchtypes = GetAuthorisedValues($advanced_srch_type, '', 'opac');
        my @authvalueloop;
	for my $thisitemtype (@$advsearchtypes) {
            my $hiding_key = lc $thisitemtype->{category};
            $hiding_key = "location" if $hiding_key eq 'loc';
            next if $hidingrules->{$hiding_key} && any { $_ eq $thisitemtype->{authorised_value} } @{$hidingrules->{$hiding_key}};
		my %row =(
				number=>$cnt++,
				ccl => $advanced_srch_type,
                code => $thisitemtype->{authorised_value},
                description => $thisitemtype->{'lib_opac'} || $thisitemtype->{'lib'},
                imageurl => getitemtypeimagelocation( 'opac', $thisitemtype->{'imageurl'} ),
                );
		push @authvalueloop, \%row;
	}
        my %search_code = (  advanced_search_type => $advanced_srch_type,
                             code_loop => \@authvalueloop );
        push @advancedsearchesloop, \%search_code;
    }
}
$template->param(advancedsearchesloop => \@advancedsearchesloop);

# The following should only be loaded if we're bringing up the advanced search template
if ( $template_type && $template_type eq 'advsearch' ) {
    # load the servers (used for searching -- to do federated searching, etc.)
    my $primary_servers_loop;# = displayPrimaryServers();
    $template->param(outer_servers_loop =>  $primary_servers_loop,);
    
    my $secondary_servers_loop;
    $template->param(outer_sup_servers_loop => $secondary_servers_loop,);

    # set the default sorting
    if (   C4::Context->preference('OPACdefaultSortField')
        && C4::Context->preference('OPACdefaultSortOrder') ) {
        my $default_sort_by =
            C4::Context->preference('OPACdefaultSortField') . '_'
          . C4::Context->preference('OPACdefaultSortOrder');
        $template->param( sort_by => $default_sort_by );
    }

    # determine what to display next to the search boxes (ie, boolean option
    # shouldn't appear on the first one, scan indexes should, adding a new
    # box should only appear on the last, etc.
    my @search_boxes_array;
    my $search_boxes_count = 3; # begin whith 3 boxes
    for (my $i=1;$i<=$search_boxes_count;$i++) {
        # if it's the first one, don't display boolean option, but show scan indexes
        if ($i==1) {
            push @search_boxes_array,
                {
                scan_index => 1,
                };
        
        }
        # if it's the last one, show the 'add field' box
        elsif ($i==$search_boxes_count) {
            push @search_boxes_array,
                {
                boolean => 1,
                add_field => 1,
                };
        }
        else {
            push @search_boxes_array,
                {
                boolean => 1,
                };
        }

    }

    my @advsearch_limits = split /,/, C4::Context->preference('OpacAdvSearchOptions');
    my @advsearch_more_limits = split /,/,
      C4::Context->preference('OpacAdvSearchMoreOptions');
    $template->param(
        uc( C4::Context->preference("marcflavour") ) => 1,    # we already did this for UNIMARC
        advsearch         => 1,
        search_boxes_loop => \@search_boxes_array,
        OpacAdvSearchOptions     => \@advsearch_limits,
        OpacAdvSearchMoreOptions => \@advsearch_more_limits,
    );

    # use the global setting by default
    if ( C4::Context->preference("expandedSearchOption") == 1 ) {
        $template->param( expanded_options => C4::Context->preference("expandedSearchOption") );
    }
    # but let the user override it
    if (defined $cgi->param('expanded_options')) {
        if ( ($cgi->param('expanded_options') == 0) || ($cgi->param('expanded_options') == 1 ) ) {
            $template->param( expanded_options => $cgi->param('expanded_options'));
        }
    }

    if (C4::Context->preference('OPACNumbersPreferPhrase')) {
        $template->param('numbersphr' => 1);
    }

    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

### OK, if we're this far, we're performing an actual search

# Fetch the paramater list as a hash in scalar context:
#  * returns paramater list as tied hash ref
#  * we can edit the values by changing the key
#  * multivalued CGI paramaters are returned as a packaged string separated by "\0" (null)
my $params = $cgi->Vars;
my $tag;
if ( $params->{tag} ) {
    $tag = $params->{tag};
    $template->param( tag => $tag );
}

# String with params with the search criteria for the paging in opac-detail
# param value is URI encoded and params separator is HTML encode (&amp;)
my $pasarParams = '';
my $j = 0;
for (keys %$params) {
    my @pasarParam = $cgi->param($_);
    for my $paramValue(@pasarParam) {
        $pasarParams .= '&amp;' if ($j > 0);
        $pasarParams .= $_ . '=' . uri_escape($paramValue);
        $j++;
    }
}

# Params that can have more than one value
# sort by is used to sort the query
# in theory can have more than one but generally there's just one
my @sort_by;
my $default_sort_by;
if (   C4::Context->preference('OPACdefaultSortField')
    && C4::Context->preference('OPACdefaultSortOrder') ) {
    $default_sort_by =
        C4::Context->preference('OPACdefaultSortField') . '_'
      . C4::Context->preference('OPACdefaultSortOrder');
}

my @allowed_sortby = qw /acqdate_asc acqdate_dsc author_az author_za call_number_asc call_number_dsc popularity_asc popularity_dsc pubdate_asc pubdate_dsc relevance title_az title_za/; 
@sort_by = $cgi->param('sort_by');
$sort_by[0] = $default_sort_by if !$sort_by[0] && defined($default_sort_by);
foreach my $sort (@sort_by) {
    if ( grep { /^$sort$/ } @allowed_sortby ) {
        $template->param($sort => 1);
    }
}
$template->param('sort_by' => $sort_by[0]);

# Use the servers defined, or just search our local catalog(default)
my @servers = $cgi->param('server');
unless (@servers) {
    #FIXME: this should be handled using Context.pm
    @servers = ("biblioserver");
    # @servers = C4::Context->config("biblioserver");
}

# operators include boolean and proximity operators and are used
# to evaluate multiple operands
my @operators = $cgi->param('op');
@operators = map { uri_unescape($_) } @operators;

# indexes are query qualifiers, like 'title', 'author', etc. They
# can be single or multiple parameters separated by comma: kw,right-Truncation 
my @indexes = $cgi->param('idx');
@indexes = map { uri_unescape($_) } @indexes;

# if a simple index (only one)  display the index used in the top search box
if ($indexes[0] && !$indexes[1]) {
    $template->param("ms_".$indexes[0] => 1);
}
# an operand can be a single term, a phrase, or a complete ccl query
my @operands = $cgi->param('q');
@operands = map { uri_unescape($_) } @operands;

$template->{VARS}->{querystring} = join(' ', @operands);

# if a simple search, display the value in the search box
if ($operands[0] && !$operands[1]) {
    my $ms_query = $operands[0];
    $ms_query =~ s/ #\S+//;
    $template->param(ms_value => $ms_query);
}

# limits are use to limit to results to a pre-defined category such as branch or language
my @limits = $cgi->param('limit');
@limits = map { uri_unescape($_) } @limits;
my @nolimits = $cgi->param('nolimit');
@nolimits = map { uri_unescape($_) } @nolimits;
my %is_nolimit = map { $_ => 1 } @nolimits;
@limits = grep { not $is_nolimit{$_} } @limits;

if($params->{'multibranchlimit'}) {
    my $multibranch = '('.join( " or ", map { "branch: $_ " } @{ GetBranchesInCategory( $params->{'multibranchlimit'} ) } ).')';
    push @limits, $multibranch if ($multibranch ne  '()');
}

my $available;
foreach my $limit(@limits) {
    if ($limit =~/available/) {
        $available = 1;
    }
}
$template->param(available => $available);

# append year limits if they exist
if ($params->{'limit-yr'}) {
    if ($params->{'limit-yr'} =~ /\d{4}-\d{4}/) {
        my ($yr1,$yr2) = split(/-/, $params->{'limit-yr'});
        push @limits, "yr,st-numeric,ge=$yr1 and yr,st-numeric,le=$yr2";
    }
    elsif ($params->{'limit-yr'} =~ /\d{4}/) {
        push @limits, "yr,st-numeric=$params->{'limit-yr'}";
    }
    else {
        #FIXME: Should return a error to the user, incorect date format specified
    }
}

# Params that can only have one value
my $scan = $params->{'scan'};
my $count = C4::Context->preference('OPACnumSearchResults') || 20;
my $countRSS         = C4::Context->preference('numSearchRSSResults') || 50;
my $results_per_page = $params->{'count'} || $count;
my $offset = $params->{'offset'} || 0;
my $page = $cgi->param('page') || 1;
$offset = ($page-1)*$results_per_page if $page>1;
my $hits;
my $expanded_facet = $params->{'expand'};

# Define some global variables
my ($error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type);

my @results;

## I. BUILD THE QUERY
( $error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type) = buildQuery(\@operators,\@operands,\@indexes,\@limits,\@sort_by, 0, $lang);

sub _input_cgi_parse {
    my @elements;
    for my $this_cgi ( split('&',shift) ) {
        next unless $this_cgi;
        $this_cgi =~ /(.*?)=(.*)/;
        push @elements, { input_name => $1, input_value => uri_unescape($2) };
    }
    return @elements;
}

## parse the query_cgi string and put it into a form suitable for <input>s
my @query_inputs = _input_cgi_parse($query_cgi);
$template->param ( QUERY_INPUTS => \@query_inputs );

## parse the limit_cgi string and put it into a form suitable for <input>s
my @limit_inputs = $limit_cgi ? _input_cgi_parse($limit_cgi) : ();

# add OPAC 'hidelostitems'
#if (C4::Context->preference('hidelostitems') == 1) {
#    # either lost ge 0 or no value in the lost register
#    $query ="($query) and ( (lost,st-numeric <= 0) or ( allrecords,AlwaysMatches='' not lost,AlwaysMatches='') )";
#}
#
# add OPAC suppression - requires at least one item indexed with Suppress
if (C4::Context->preference('OpacSuppression')) {
    # OPAC suppression by IP address
    if (C4::Context->preference('OpacSuppressionByIPRange')) {
        my $IPAddress = $ENV{'REMOTE_ADDR'};
        my $IPRange = C4::Context->preference('OpacSuppressionByIPRange');
        if ($IPAddress !~ /^$IPRange/)  {
            if ( $query_type eq 'pqf' ) {
                $query = '@not '.$query.' @attr 1=9011 1';
            } else {
                $query = "($query) not Suppress=1";
            }
        }
    }
    else {
        if ( $query_type eq 'pqf' ) {
            #$query = "($query) && -(suppress:1)"; #QP syntax
            $query = '@not '.$query.' @attr 1=9011 1'; #PQF syntax
        } else {
            $query = "($query) not Suppress=1";
        }
    }
}

$template->param ( LIMIT_INPUTS => \@limit_inputs );
$template->param ( OPACResultsSidebar => C4::Context->preference('OPACResultsSidebar'));

## II. DO THE SEARCH AND GET THE RESULTS
my $total = 0; # the total results for the whole set
my $facets; # this object stores the faceted results that display on the left-hand of the results page
my @results_array;
my $results_hashref;
my @coins;

if ($tag) {
    $query_cgi = "tag=" .$tag . "&" . $query_cgi;
    my $taglist = get_tags({term=>$tag, approved=>1});
    $results_hashref->{biblioserver}->{hits} = scalar (@$taglist);
    my @biblist  = (map {GetBiblioData($_->{biblionumber})} @$taglist);
    my @marclist = (map { (C4::Context->config('zebra_bib_index_mode') eq 'dom')? $_->{marcxml}: $_->{marc}; } @biblist);
    $DEBUG and printf STDERR "taglist (%s biblionumber)\nmarclist (%s records)\n", scalar(@$taglist), scalar(@marclist);
    $results_hashref->{biblioserver}->{RECORDS} = \@marclist;
    # FIXME: tag search and standard search should work together, not exclusively
    # FIXME: No facets for tags search.
} elsif ($build_grouped_results) {
    eval {
        ($error, $results_hashref, $facets) = C4::Search::pazGetRecords($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,$expanded_facet,$branches,$query_type,$scan);
    };
} else {
    $pasarParams .= '&amp;query=' . uri_escape($query);
    $pasarParams .= '&amp;count=' . uri_escape($results_per_page);
    $pasarParams .= '&amp;simple_query=' . uri_escape($simple_query);
    $pasarParams .= '&amp;query_type=' . uri_escape($query_type) if ($query_type);
    eval {
        ($error, $results_hashref, $facets) = getRecords($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,$expanded_facet,$branches,$itemtypes,$query_type,$scan,1);
    };
}
# This sorts the facets into alphabetical order
if ($facets) {
    foreach my $f (@$facets) {
        $f->{facets} = [ sort { uc($a->{facet_title_value}) cmp uc($b->{facet_title_value}) } @{ $f->{facets} } ];
    }
    @$facets = sort {$a->{expand} cmp $b->{expand}} @$facets;
}

# use Data::Dumper; print STDERR "-" x 25, "\n", Dumper($results_hashref);
if ($@ || $error) {
    $template->param(query_error => $error.$@);
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

# At this point, each server has given us a result set
# now we build that set for template display
my @sup_results_array;
for (my $i=0;$i<@servers;$i++) {
    my $server = $servers[$i];
    if ($server && $server =~/biblioserver/) { # this is the local bibliographic server
        $hits = $results_hashref->{$server}->{"hits"};
        my $page = $cgi->param('page') || 0;
        my @newresults;
        if ($build_grouped_results) {
            foreach my $group (@{ $results_hashref->{$server}->{"GROUPS"} }) {
                # because pazGetRecords handles retieving only the records
                # we want as specified by $offset and $results_per_page,
                # we need to set the offset parameter of searchResults to 0
                my @group_results = searchResults( 'opac', $query_desc, $group->{'group_count'},$results_per_page, 0, $scan,
                                                   $group->{"RECORDS"});
                push @newresults, { group_label => $group->{'group_label'}, GROUP_RESULTS => \@group_results };
            }
        } else {
            @newresults = searchResults('opac', $query_desc, $hits, $results_per_page, $offset, $scan,
                                        $results_hashref->{$server}->{"RECORDS"});
        }
        $hits = 0 unless @newresults;

        foreach my $res (@newresults) {

            # must define a value for size if not present in DB
            # in order to avoid problems generated by the default size value in TT
            if ( not exists $res->{'size'} ) { $res->{'size'} = "" }
            # while we're checking each line, see if item is in the cart
            if ( grep {$_ eq $res->{'biblionumber'}} @cart_list) {
                $res->{'incart'} = 1;
            }

            if (C4::Context->preference('COinSinOPACResults')) {
                my $record = GetMarcBiblio($res->{'biblionumber'});
                $res->{coins} = GetCOinSBiblio($record);
            }
            if ( C4::Context->preference( "Babeltheque" ) and $res->{normalized_isbn} ) {
                if( my $isbn = Business::ISBN->new( $res->{normalized_isbn} ) ) {
                    $isbn = $isbn->as_isbn13->as_string;
                    $isbn =~ s/-//g;
                    my $social_datas = C4::SocialData::get_data( $isbn );
                    if ( $social_datas ) {
                        for my $key ( keys %$social_datas ) {
                            $res->{$key} = $$social_datas{$key};
                            if ( $key eq 'score_avg' ){
                                $res->{score_int} = sprintf("%.0f", $$social_datas{score_avg} );
                            }
                        }
                    }
                }
            }

            if (C4::Context->preference('TagsEnabled') and
                C4::Context->preference('TagsShowOnList')) {
                if ( my $bibnum = $res->{biblionumber} ) {
                    $res->{itemsissued} = CountItemsIssued( $bibnum );
                    $res->{'TagLoop'} = get_tags({
                        biblionumber => $bibnum,
                        approved => 1,
                        sort => '-weight',
                        limit => C4::Context->preference('TagsShowOnList')
                    });
                }
            }

            if ( C4::Context->preference('OpacStarRatings') eq 'all' ) {
                my $rating = GetRating( $res->{'biblionumber'}, $borrowernumber );
                $res->{'rating_value'}  = $rating->{'rating_value'};
                $res->{'rating_total'}  = $rating->{'rating_total'};
                $res->{'rating_avg'}    = $rating->{'rating_avg'};
                $res->{'rating_avg_int'} = $rating->{'rating_avg_int'};
            }
        }

        if ($results_hashref->{$server}->{"hits"}){
            $total = $total + $hits;
        }

        # Opac search history
        if (C4::Context->preference('EnableOpacSearchHistory')) {
            unless ( $offset ) {
                my $path_info = $cgi->url(-path_info=>1);
                my $query_cgi_history = $cgi->url(-query=>1);
                $query_cgi_history =~ s/^$path_info\?//;
                $query_cgi_history =~ s/;/&/g;
                my $query_desc_history = join ", ", grep { defined $_ } $query_desc, $limit_desc;

                unless ( $borrowernumber ) {
                    my $new_searches = C4::Search::History::add_to_session({
                            cgi => $cgi,
                            query_desc => $query_desc_history,
                            query_cgi => $query_cgi_history,
                            total => $total,
                            type => "biblio",
                    });
                } else {
                    # To the session (the user is logged in)
                    C4::Search::History::add({
                        userid => $borrowernumber,
                        sessionid => $cgi->cookie("CGISESSID"),
                        query_desc => $query_desc_history,
                        query_cgi => $query_cgi_history,
                        total => $total,
                        type => "biblio",
                    });
                }
            }
            $template->param( EnableOpacSearchHistory => 1 );
        }

        ## If there's just one result, redirect to the detail page
        if ($total == 1 && $format ne 'rss2'
        && $format ne 'opensearchdescription' && $format ne 'atom') {
            my $biblionumber=$newresults[0]->{biblionumber};
            if (C4::Context->preference('BiblioDefaultView') eq 'isbd') {
                print $cgi->redirect("/cgi-bin/koha/opac-ISBDdetail.pl?biblionumber=$biblionumber");
            } elsif  (C4::Context->preference('BiblioDefaultView') eq 'marc') {
                print $cgi->redirect("/cgi-bin/koha/opac-MARCdetail.pl?biblionumber=$biblionumber");
            } else {
                print $cgi->redirect("/cgi-bin/koha/opac-detail.pl?biblionumber=$biblionumber");
            } 
            exit;
        }
        if ($hits) {
            if ( !$build_grouped_results ) {
                # We build the encrypted list of first OPACnumSearchResults biblios to pass with the search criteria for paging on opac-detail
                $pasarParams .= '&amp;listBiblios=';
                my $j = 0;
                foreach (@newresults) {
                    my $bibnum = ($_->{biblionumber})?$_->{biblionumber}:0;
                    $pasarParams .= uri_escape($bibnum) . ',';
                    $j++;
                    last if ($j == $results_per_page);
                }
                chop $pasarParams if ($pasarParams =~ /,$/);
                $pasarParams .= '&amp;total=' . uri_escape( int($total) ) if ($pasarParams !~ /total=(?:[0-9]+)?/);
                if ($pasarParams) {
                    my $session = get_session($cgi->cookie("CGISESSID"));
                    $session->param('busc' => $pasarParams);
                }
                #
            }
            $template->param(total => $hits);
            my $limit_cgi_not_availablity = $limit_cgi;
            $limit_cgi_not_availablity =~ s/&limit=available//g if defined $limit_cgi_not_availablity;
            $template->param(limit_cgi_not_availablity => $limit_cgi_not_availablity);
            $template->param(limit_cgi => $limit_cgi);
            $template->param(countrss  => $countRSS );
            $template->param(query_cgi => $query_cgi);
            $template->param(query_desc => $query_desc);
            $template->param(limit_desc => $limit_desc);
            $template->param(offset     => $offset);
            $template->param(DisplayMultiPlaceHold => $DisplayMultiPlaceHold);
            if ($query_desc || $limit_desc) {
                $template->param(searchdesc => 1);
            }
            $template->param(stopwords_removed => "@$stopwords_removed") if $stopwords_removed;
            $template->param(results_per_page =>  $results_per_page);
            my $hide = C4::Context->preference('OpacHiddenItems');
            $hide = ($hide =~ m/\S/) if $hide; # Just in case it has some spaces/new lines
            my $branch = '';
            if (C4::Context->userenv){
                $branch = C4::Context->userenv->{branch};
            }
            if ( C4::Context->preference('HighlightOwnItemsOnOPAC') ) {
                if (
                    ( ( C4::Context->preference('HighlightOwnItemsOnOPACWhich') eq 'PatronBranch' ) && $branch )
                    ||
                    C4::Context->preference('HighlightOwnItemsOnOPACWhich') eq 'OpacURLBranch'
                ) {
                    my $branchname;
                    if ( C4::Context->preference('HighlightOwnItemsOnOPACWhich') eq 'PatronBranch' ) {
                        $branchname = $branches->{$branch}->{'branchname'};
                    }
                    elsif (  C4::Context->preference('HighlightOwnItemsOnOPACWhich') eq 'OpacURLBranch' ) {
                        $branchname = $branches->{ $ENV{'BRANCHCODE'} }->{'branchname'};
                    }

                    foreach my $res ( @newresults ) {
                        my @new_loop;
                        my @top_loop;
                        my @old_loop = @{$res->{'available_items_loop'}};
                        foreach my $item ( @old_loop ) {
                            if ( $item->{'branchname'} eq $branchname ) {
                                $item->{'this_branch'} = 1;
                                push( @top_loop, $item );
                            } else {
                                push( @new_loop, $item );
                            }
                        }
                        my @complete_loop = ( @top_loop, @new_loop );
                        $res->{'available_items_loop'} = \@complete_loop;
                    }
                }
            }

            $template->param(
                SEARCH_RESULTS => \@newresults,
                OPACItemsResultsDisplay => (C4::Context->preference("OPACItemsResultsDisplay")),
                suppress_result_number => $hide,
                            );
	    if (C4::Context->preference("OPACLocalCoverImages")){
		$template->param(OPACLocalCoverImages => 1);
		$template->param(OPACLocalCoverImagesPriority => C4::Context->preference("OPACLocalCoverImagesPriority"));
	    }
            ## Build the page numbers on the bottom of the page
            my @page_numbers;
            # total number of pages there will be
            my $pages = ceil($hits / $results_per_page);
            # default page number
            my $current_page_number = 1;
            if ($offset) {
                $current_page_number = ( $offset / $results_per_page + 1 );
            }
            my $previous_page_offset;
            if ( $offset >= $results_per_page ) {
                $previous_page_offset = $offset - $results_per_page;
            }
            my $next_page_offset = $offset + $results_per_page;
            # If we're within the first 10 pages, keep it simple
            #warn "current page:".$current_page_number;
            if ($current_page_number < 10) {
                # just show the first 10 pages
                # Loop through the pages
                my $pages_to_show = 10;
                $pages_to_show = $pages if $pages<10;
                for ($i=1; $i<=$pages_to_show;$i++) {
                    # the offset for this page
                    my $this_offset = (($i*$results_per_page)-$results_per_page);
                    # the page number for this page
                    my $this_page_number = $i;
                    # put it in the array
                    push @page_numbers,
                      { offset    => $this_offset,
                        pg        => $this_page_number,
                        highlight => $this_page_number == $current_page_number,
                        sort_by   => join ' ', @sort_by
                      };

                }
                        
            }
            # now, show twenty pages, with the current one smack in the middle
            else {
                for ($i=$current_page_number; $i<=($current_page_number + 20 );$i++) {
                    my $this_offset = ((($i-9)*$results_per_page)-$results_per_page);
                    my $this_page_number = $i-9;
                    if ( $this_page_number <= $pages ) {
                        push @page_numbers,
                          { offset    => $this_offset,
                            pg        => $this_page_number,
                            highlight => $this_page_number == $current_page_number,
                            sort_by => join ' ', @sort_by
                          };
                    }
                }
                        
            }
            $template->param(   PAGE_NUMBERS => \@page_numbers,
                                previous_page_offset => $previous_page_offset) unless $pages < 2;
            $template->param(next_page_offset => $next_page_offset) unless $pages eq $current_page_number;
        }
        # no hits
        else {
            my $nohits = C4::Context->preference('OPACNoResultsFound');
            if ($nohits and $nohits=~/{QUERY_KW}/){
                # extracting keywords in case of relaunching search
                (my $query_kw=$query_desc)=~s/ and|or / /g;
                $query_kw = Encode::decode_utf8($query_kw);
                my @query_kw=($query_kw=~ /([-\w]+\b)(?:[^,:]|$)/g);
                $query_kw=join('+',@query_kw);
                $nohits=~s/{QUERY_KW}/$query_kw/g;
                $template->param('OPACNoResultsFound' =>$nohits);
            }
            $template->param(
                searchdesc => 1,
                query_desc => $query_desc,
                limit_desc => $limit_desc,
                query_cgi  => $query_cgi,
                limit_cgi  => $limit_cgi
            );
        }
    } # end of the if local
    # asynchronously search the authority server
    elsif ($server && $server =~/authorityserver/) { # this is the local authority server
        my @inner_sup_results_array;
        for my $sup_record ( @{$results_hashref->{$server}->{"RECORDS"}} ) {
            my $marc_record_object = MARC::Record->new_from_usmarc($sup_record);
            my $title_field = $marc_record_object->field(100);
            push @inner_sup_results_array, {
                'title' => $title_field->subfield('a'),
                'link' => "&amp;idx=an&amp;q=".$marc_record_object->field('001')->as_string(),
            };
        }
        my $servername = $server;
        push @sup_results_array, {  servername => $servername,
                                    inner_sup_results_loop => \@inner_sup_results_array} if @inner_sup_results_array;
    }
    # FIXME: can add support for other targets as needed here
    $template->param(           outer_sup_results_loop => \@sup_results_array);
} #/end of the for loop
#$template->param(FEDERATED_RESULTS => \@results_array);

my @input_values = map { Encode::decode_utf8($_->{input_value}) } @limit_inputs;
for my $facet ( @$facets ) {
    for my $entry ( @{ $facet->{facets} } ) {
        my $index = $entry->{type_link_value};
        my $value = $entry->{facet_link_value};
        $entry->{active} = grep { $_ eq qq{$index:$value} } @input_values;
    }
}


$template->param(
            #classlist => $classlist,
            total => $total,
            opacfacets => 1,
            facets_loop => $facets,
            displayFacetCount=> C4::Context->preference('displayFacetCount')||0,
            scan => $scan,
            search_error => $error,
);

if ($query_desc || $limit_desc) {
    $template->param(searchdesc => 1);
}

# VI. BUILD THE TEMPLATE
# Build drop-down list for 'Add To:' menu...
my ($totalref, $pubshelves, $barshelves)=
	C4::VirtualShelves::GetSomeShelfNames($borrowernumber,'COMBO',1);
$template->param(
	addbarshelves     => $totalref->{bartotal},
	addbarshelvesloop => $barshelves,
	addpubshelves     => $totalref->{pubtotal},
	addpubshelvesloop => $pubshelves,
	);

my $content_type = ($format eq 'rss' or $format eq 'atom') ? $format : 'html';

# If GoogleIndicTransliteration system preference is On Set paramter to load Google's javascript in OPAC search screens 
if (C4::Context->preference('GoogleIndicTransliteration')) {
        $template->param('GoogleIndicTransliteration' => 1);
}

$template->{VARS}->{DidYouMean} =
  ( defined C4::Context->preference('OPACdidyoumean')
      && C4::Context->preference('OPACdidyoumean') =~ m/enable/ );
$template->{VARS}->{IDreamBooksReviews} = C4::Context->preference('IDreamBooksReviews');
$template->{VARS}->{IDreamBooksReadometer} = C4::Context->preference('IDreamBooksReadometer');
$template->{VARS}->{IDreamBooksResults} = C4::Context->preference('IDreamBooksResults');

if ($offset == 0 && IsOverDriveEnabled()) {
    $template->param(OverDriveEnabled => 1);
    $template->param(OverDriveLibraryID => C4::Context->preference('OverDriveLibraryID'));
}

    $template->param( borrowernumber    => $borrowernumber);
output_with_http_headers $cgi, $cookie, $template->output, $content_type;
