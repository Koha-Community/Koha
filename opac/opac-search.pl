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
use Try::Tiny;
use Encode;

use Data::Dumper; # TODO remove

use Koha::SearchEngine::Search;
use Koha::SearchEngine::QueryBuilder;

my $searchengine = C4::Context->preference("SearchEngine");
my ($builder, $searcher);
#$searchengine = 'Zebra'; # XXX
$builder  = Koha::SearchEngine::QueryBuilder->new({index => 'biblios'});
$searcher = Koha::SearchEngine::Search->new({index => 'biblios'});

use C4::Output qw( output_html_with_http_headers pagination_bar output_with_http_headers );
use C4::Auth qw( get_template_and_user get_session );
use C4::Languages qw( getlanguage getLanguages );
use C4::Search qw( searchResults );
use C4::Search::History;
use C4::Biblio qw( GetXmlBiblio CountItemsIssued );
use C4::Koha qw( GetItemTypesCategorized getitemtypeimagelocation GetAuthorisedValues );
use C4::Tags qw( get_tags get_tag );
use C4::SocialData;
use C4::External::OverDrive;
use C4::External::BakerTaylor qw( image_url link_url );

use Koha::CirculationRules;
use Koha::Libraries;
use Koha::ItemTypes;
use Koha::Ratings;
use Koha::Virtualshelves;
use Koha::Library::Groups;
use Koha::Patrons;
use Koha::Plugins;
use Koha::SearchFields;

use POSIX qw(ceil floor strftime);
use URI::Escape;
use JSON qw/decode_json encode_json/;
use Business::ISBN;

my $DisplayMultiPlaceHold = C4::Context->preference("DisplayMultiPlaceHold");
# create a new CGI object
# FIXME: no_undef_params needs to be tested
use CGI qw('-no_undef_params' -utf8);
my $cgi = CGI->new;

my $branch_group_limit = $cgi->param("branch_group_limit");
if ( $branch_group_limit ) {
    if ( $branch_group_limit =~ /^multibranchlimit-/ ) {
        # branch_group_limit is deprecated, it should no longer be used
        # For search groups we are going to convert this branch_group_limit CGI
        # parameter into a multibranchlimit limit CGI parameter for the purposes of
        # actually performing the query
        $cgi->param(
            -name => 'limit',
            -values => 'multibranchlimit:' . substr($branch_group_limit, 17)
        );
    } else {
        $cgi->append(
            -name => 'limit',
            -values => [ $branch_group_limit ]
        );
    }
}

my ($template,$borrowernumber,$cookie);
# decide which template to use
my $template_name;
my $template_type = 'basic';
my @params = $cgi->multi_param("limit");
my @searchCategories = $cgi->multi_param('searchcat');

my $format = $cgi->param("format") || '';
if ($format =~ /(rss|atom|opensearchdescription)/) {
    $template_name = 'opac-opensearch.tt';
}
elsif ((@params>=1) || (defined $cgi->param("q") && $cgi->param("q") ne "") || ($cgi->param('multibranchlimit')) || ($cgi->param('limit-yr')) || @searchCategories ) {
    $template_name = 'opac-results.tt';
}
else {
    $template_name = 'opac-advsearch.tt';
    $template_type = 'advsearch';
}

$format = 'rss' if $format =~ /^rss2?$/;

# load the template
($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $template_name,
    query => $cgi,
    type => "opac",
    authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);
my $patron = Koha::Patrons->find( $borrowernumber );

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

if ($format eq 'rss' or $format eq 'opensearchdescription' or $format eq 'atom') {
    $template->param($format => 1);
    #NOTE: opensearchdescription doesn't actually use timestamp...
    $template->param(timestamp => strftime("%Y-%m-%dT%H:%M:%S-00:00", gmtime)) if ($format eq 'atom'); 
    # FIXME - the timestamp is a hack - the biblio update timestamp should be used for each
    # entry, but not sure if that's worth an extra database query for each bib
}

#NOTE: Return now for 'opensearchdescription' BZ 32639
if ( $format && $format eq 'opensearchdescription' ){
    my $content_type = $format;
    output_with_http_headers $cgi, $cookie, $template->output, $content_type;
    exit;
}

if (C4::Context->preference("marcflavour") eq "UNIMARC" ) {
    $template->param('UNIMARC' => 1);
}
elsif (C4::Context->preference("marcflavour") eq "MARC21" ) {
    $template->param('usmarc' => 1);
}

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

if ($cgi->param("returntosearch")) {
    $template->param('ReturnToSearch' => 1);
}
if ($cgi->cookie("search_path_code")) {
    my $pathcode = $cgi->cookie("search_path_code");
    if ($pathcode eq 'ads') {
        $template->param('ReturnPath' => '/cgi-bin/koha/opac-search.pl?returntosearch=1');
    }
    elsif ($pathcode eq 'exs') {
         $template->param('ReturnPath' => '/cgi-bin/koha/opac-search.pl?expanded_options=1&returntosearch=1');
    }
    else {
        warn "ReturnPath switch error";
    }
}

my @search_groups = Koha::Library::Groups->get_search_groups( { interface => 'opac' } )->as_list;
$template->param( search_groups => \@search_groups );

# load the language limits (for search)
my $languages_limit_loop = getLanguages($lang, 1);
$template->param(search_languages_loop => $languages_limit_loop,);

# load the Type stuff
my $itemtypes = GetItemTypesCategorized;
# add translated_description to itemtypes
foreach my $itemtype ( keys %{$itemtypes} ) {
    # Itemtypes search categories don't have (yet) translated descriptions, they are auth values (and could still have no descriptions too BZ 18400)
    # If 'iscat' (see ITEMTYPECAT) then there is no itemtype and the description is not translated
    my $translated_description = $itemtypes->{$itemtype}->{iscat}
      ? $itemtypes->{$itemtype}->{description}
      : Koha::ItemTypes->find($itemtype)->translated_description;
    $itemtypes->{$itemtype}->{translated_description} = $translated_description || $itemtypes->{$itemtype}->{description} || q{};
}

# the index parameter is different for item-level itemtypes
my $itype_or_itemtype = (C4::Context->preference("item-level_itypes"))?'itype':'itemtype';
my @advancedsearchesloop;
my $cnt;
my $advanced_search_types = C4::Context->preference("OpacAdvancedSearchTypes") || "itemtypes";
my @advanced_search_types = split(/\|/, $advanced_search_types);

my $hidingrules = C4::Context->yaml_preference('OpacHiddenItems') // {};

my @sorted_itemtypes = sort { $itemtypes->{$a}->{translated_description} cmp $itemtypes->{$b}->{translated_description} } keys %$itemtypes;
foreach my $advanced_srch_type (@advanced_search_types) {
    $advanced_srch_type =~ s/^\s*//;
    $advanced_srch_type =~ s/\s*$//;
   if ($advanced_srch_type eq 'itemtypes') {
   # itemtype is a special case, since it's not defined in authorized values
        my @itypesloop;
        foreach my $thisitemtype ( @sorted_itemtypes ) {
            next if $hidingrules->{itype} && any { $_ eq $thisitemtype } @{$hidingrules->{itype}};
            next if $hidingrules->{itemtype} && any { $_ eq $thisitemtype } @{$hidingrules->{itemtype}};
	    my %row =(  number=>$cnt++,
		ccl => "$itype_or_itemtype,phr",
                code => $thisitemtype,
                description => $itemtypes->{$thisitemtype}->{translated_description},
                imageurl=> getitemtypeimagelocation( 'opac', $itemtypes->{$thisitemtype}->{'imageurl'} ),
                cat => $itemtypes->{$thisitemtype}->{'iscat'},
                hideinopac => $itemtypes->{$thisitemtype}->{'hideinopac'},
                searchcategory => $itemtypes->{$thisitemtype}->{'searchcategory'},
            );
            if ( !$itemtypes->{$thisitemtype}->{'hideinopac'} ) {
                push @itypesloop, \%row;
            }
	}
        my %search_code = (  advanced_search_type => $advanced_srch_type,
                             code_loop => \@itypesloop );
        push @advancedsearchesloop, \%search_code;
    } else {
    # covers all the other cases: non-itemtype authorized values
       my $advsearchtypes = GetAuthorisedValues($advanced_srch_type, 'opac');
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
                searchcategory => $itemtypes->{$thisitemtype}->{'searchcategory'},
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

    my @advsearch_limits = split /,/, C4::Context->preference('OpacAdvSearchOptions');
    my @advsearch_more_limits = split /,/,
      C4::Context->preference('OpacAdvSearchMoreOptions');
    $template->param(
        uc( C4::Context->preference("marcflavour") ) => 1,    # we already did this for UNIMARC
        advsearch         => 1,
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
            $template->param( expanded_options => scalar $cgi->param('expanded_options'));
        }
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
    my @pasarParam = $cgi->multi_param($_);
    for my $paramValue(@pasarParam) {
        $pasarParams .= '&amp;' if ($j > 0);
        $pasarParams .= uri_escape_utf8($_) . '=' . uri_escape_utf8($paramValue);
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
@sort_by = $cgi->multi_param('sort_by');
$sort_by[0] = $default_sort_by if !$sort_by[0] && defined($default_sort_by);
foreach my $sort (@sort_by) {
    if ( grep { $_ eq $sort } @allowed_sortby ) {
        $template->param($sort => 1);
    }
}
$template->param('sort_by' => $sort_by[0]);

# Use the servers defined, or just search our local catalog(default)
my @servers = $cgi->multi_param('server');
unless (@servers) {
    #FIXME: this should be handled using Context.pm
    @servers = ("biblioserver");
    # @servers = C4::Context->config("biblioserver");
}

# operators include boolean and proximity operators and are used
# to evaluate multiple operands
my @operators = $cgi->multi_param('op');
@operators = map { uri_unescape($_) } @operators;

# indexes are query qualifiers, like 'title', 'author', etc. They
# can be single or multiple parameters separated by comma: kw,right-Truncation 
my @indexes = $cgi->multi_param('idx');
@indexes = map { uri_unescape($_) } @indexes;

# if a simple index (only one)  display the index used in the top search box
if ($indexes[0] && !$indexes[1]) {
    my $idx = "ms_".$indexes[0];
    $idx =~ s/\,/comma/g;  # template toolkit doesn't like variables with a , in it
    $idx =~ s/-/dash/g;  # template toolkit doesn't like variables with a dash in it
    $template->param($idx => 1);
}
# an operand can be a single term, a phrase, or a complete ccl query
my @operands = $cgi->multi_param('q');
@operands = map { uri_unescape($_) } @operands;

$template->{VARS}->{querystring} = join(' ', @operands);

# if a simple search, display the value in the search box
my $basic_search = 0;
if ($operands[0] && !$operands[1]) {
    my $ms_query = $operands[0];
    $ms_query =~ s/ #\S+//;
    $template->param(ms_value => $ms_query);
    $basic_search=1;
}

# limits are use to limit to results to a pre-defined category such as branch or language
my @limits = $cgi->multi_param('limit');
@limits = map { uri_unescape($_) } @limits;
my @nolimits = $cgi->multi_param('nolimit');
@nolimits = map { uri_unescape($_) } @nolimits;
my %is_nolimit = map { $_ => 1 } @nolimits;
@limits = grep { not $is_nolimit{$_} } @limits;

if (@searchCategories > 0) {
    my @tabcat;
    foreach my $typecategory (@searchCategories) {
        push @tabcat, Koha::ItemTypes->search({ searchcategory => $typecategory })->get_column('itemtype');
    }

    foreach my $itemtypeInCategory (@tabcat) {
        push (@limits, "mc-$itype_or_itemtype,phr:".$itemtypeInCategory);
    }
}

@limits = map { uri_unescape($_) } @limits;


my $available;
foreach my $limit(@limits) {
    if ($limit =~/available/) {
        $available = 1;
    }
}
$template->param(available => $available);

# append year limits if they exist
if ($params->{'limit-yr'}) {
    if ($params->{'limit-yr'} =~ /\d{4}/) {
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
$offset = 0 if $offset < 0;
my $page = $cgi->param('page') || 1;
$offset = ($page-1)*$results_per_page if $page>1;
my $hits;
my $weight_search = $cgi->param('advsearch') ? $cgi->param('weight_search') || 0 : 1;

# Define some global variables
my ($error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$query_type);

my $suppress = 0;
if (C4::Context->preference('OpacSuppression')) {
    # OPAC suppression by IP address
    if (C4::Context->preference('OpacSuppressionByIPRange')) {
        my $IPAddress = $ENV{'REMOTE_ADDR'};
        my $IPRange = C4::Context->preference('OpacSuppressionByIPRange');
        $suppress = ($IPAddress !~ /^$IPRange/);
    }
    else {
        $suppress = 1;
    }
}

## I. BUILD THE QUERY
( $error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$query_type)
  = $builder->build_query_compat(
    \@operators,
    \@operands,
    \@indexes,
    \@limits,
    \@sort_by,
    0,
    $lang,
    {
        suppress => $suppress,
        is_opac => 1,
        weighted_fields => $weight_search
    }
);

$template->param( search_query => $query ) if C4::Context->preference('DumpSearchQueryTemplate');

sub _input_cgi_parse {
    my @elements;
    my $query_cgi = shift or return @elements;
    for my $this_cgi ( split('&',$query_cgi) ) {
        next unless $this_cgi;
        $this_cgi =~ /(.*?)=(.*)/;
        push @elements, { input_name => $1, input_value => Encode::decode_utf8( uri_unescape($2) ) };
    }
    return @elements;
}

## parse the query_cgi string and put it into a form suitable for <input>s
my @query_inputs = _input_cgi_parse($query_cgi);
$template->param ( QUERY_INPUTS => \@query_inputs );

## parse the limit_cgi string and put it into a form suitable for <input>s
my @limit_inputs = $limit_cgi ? _input_cgi_parse($limit_cgi) : ();

# OpenURL
my @OpenURL_itypes;
if (C4::Context->preference('OPACShowOpenURL')) {
    @OpenURL_itypes = split( /\s/, C4::Context->preference('OPACOpenURLItemTypes') );
    $template->param(
        OPACShowOpenURL => 1,
        OpenURLResolverURL => C4::Context->preference('OpenURLResolverURL'),
        OpenURLText => C4::Context->preference('OpenURLText'),
        OpenURLImageLocation => C4::Context->preference('OpenURLImageLocation')
    );
}

$template->param ( LIMIT_INPUTS => \@limit_inputs );
$template->param ( OPACResultsSidebar => C4::Context->preference('OPACResultsSidebar'));

## II. DO THE SEARCH AND GET THE RESULTS
my $total = 0; # the total results for the whole set
my $facets; # this object stores the faceted results that display on the left-hand of the results page
my $results_hashref;

if ($tag) {
    $query_cgi = "tag=" .  uri_escape_utf8( $tag ) . "&" . $query_cgi;
    my $taglist = get_tags({term=>$tag, approved=>1});
    $results_hashref->{biblioserver}->{hits} = scalar (@$taglist);
    my @marclist = map { C4::Biblio::GetXmlBiblio( $_->{biblionumber} ) } @$taglist;
    $results_hashref->{biblioserver}->{RECORDS} = \@marclist;
    # FIXME: tag search and standard search should work together, not exclusively
    # FIXME: Because search and standard search don't work together OpacHiddenItems
    #        displays search results which should be hidden.
    # FIXME: No facets for tags search.
} else {
    my $json = JSON->new->utf8->allow_nonref(1);
    $pasarParams .= '&amp;query=' . uri_escape_utf8($json->encode($query));
    $pasarParams .= '&amp;count=' . uri_escape_utf8($results_per_page);
    $pasarParams .= '&amp;simple_query=' . uri_escape_utf8($simple_query);
    $pasarParams .= '&amp;query_type=' . uri_escape_utf8($query_type) if ($query_type);
    my $itemtypes_nocategory = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };
    eval {
        ($error, $results_hashref, $facets) = $searcher->search_compat($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,undef,$itemtypes_nocategory,$query_type,$scan,1);
};
}

# use Data::Dumper; print STDERR "-" x 25, "\n", Dumper($results_hashref);
if (not $tag and ( $@ || $error)) {
    my $query_error = q{};
    $query_error .= $error if $error;
    $query_error .= $@ if $@;
    $template->param(query_error => $query_error);
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

# At this point, each server has given us a result set
# now we build that set for template display
my @sup_results_array;
my $search_context = {};
$search_context->{'interface'} = 'opac';
if (C4::Context->preference('OpacHiddenItemsExceptions')){
    $search_context->{'category'} = $patron ? $patron->categorycode : q{};
}

my $variables = { anonymous_session => ($borrowernumber) ? 0 : 1 };

my @plugin_responses = Koha::Plugins->call(
    'opac_results_xslt_variables',
    {
        lang       => $lang,
        patron_id  => $borrowernumber
    }
);
for my $plugin_variables ( @plugin_responses ) {
    $variables = { %$variables, %$plugin_variables };
}

for (my $i=0;$i<@servers;$i++) {
    my $server = $servers[$i];
    if ($server && $server =~/biblioserver/) { # this is the local bibliographic server
        $hits = $results_hashref->{$server}->{"hits"};
        if ( $hits == 0 && $basic_search ){
            $operands[0] = '"'.$operands[0].'"'; #quote it
            ## I. BUILD THE QUERY
            ( $error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$query_type)
              = $builder->build_query_compat(
                \@operators,
                \@operands,
                \@indexes,
                \@limits,
                \@sort_by,
                0,
                $lang,
                {
                    suppress => $suppress,
                    is_opac => 1,
                    weighted_fields => $weight_search
                }
            );
            my $quoted_results_hashref;
            my $itemtypes_nocategory = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };
            eval {
                ($error, $quoted_results_hashref, $facets) = $searcher->search_compat($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,undef,$itemtypes_nocategory,$query_type,$scan,1);
            };
            my $quoted_hits = $quoted_results_hashref->{$server}->{"hits"} // 0;
            if ( $quoted_hits ){
                $results_hashref->{'biblioserver'} = $quoted_results_hashref->{'biblioserver'};
                $hits = $quoted_hits;
            }
        }
        my $page = $cgi->param('page') || 0;
        my @newresults = searchResults( $search_context, $query_desc, $hits, $results_per_page, $offset, $scan,
                                        $results_hashref->{$server}->{"RECORDS"}, $variables);
        $hits = 0 unless @newresults;

        my $art_req_itypes;
        if( C4::Context->preference('ArticleRequests') ) {
            $art_req_itypes = Koha::CirculationRules->guess_article_requestable_itemtypes({ $patron ? ( categorycode => $patron->categorycode ) : () });
        }

        foreach my $res (@newresults) {

            # must define a value for size if not present in DB
            # in order to avoid problems generated by the default size value in TT
            if ( not exists $res->{'size'} ) { $res->{'size'} = "" }
            # while we're checking each line, see if item is in the cart
            if ( grep {$_ eq $res->{'biblionumber'}} @cart_list) {
                $res->{'incart'} = 1;
            }

            if (C4::Context->preference('COinSinOPACResults')) {
                my $biblio = Koha::Biblios->find( $res->{'biblionumber'} );
                # Catch the exception as Koha::Biblio::Metadata->record can explode if the MARCXML is invalid
                $res->{coins} = $biblio ? eval {$biblio->get_coins} : q{}; # FIXME This should be moved at the beginning of the @newresults loop
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

            $res->{shelves} = Koha::Virtualshelves->get_shelves_containing_record(
                {
                    biblionumber   => $res->{biblionumber},
                    borrowernumber => $borrowernumber
                }
            );

            if ( C4::Context->preference('OpacStarRatings') eq 'all' ) {
                my $ratings = Koha::Ratings->search({ biblionumber => $res->{biblionumber} });
                $res->{ratings} = $ratings;
                $res->{my_rating} = $borrowernumber ? $ratings->search({ borrowernumber => $borrowernumber })->next : undef;
            }

            # BZ17530: 'Intelligent' guess if result can be article requested
            $res->{artreqpossible} = ( $art_req_itypes->{ $res->{itemtype} // q{} } || $art_req_itypes->{ '*' } ) ? 1 : q{};
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
        if ($total == 1 && $format ne 'rss'
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
            # We build the encrypted list of first OPACnumSearchResults biblios to pass with the search criteria for paging on opac-detail
            $pasarParams .= '&amp;listBiblios=';
            my $j = 0;
            foreach (@newresults) {
                my $bibnum = ($_->{biblionumber})?$_->{biblionumber}:0;
                $pasarParams .= uri_escape_utf8($bibnum) . ',';
                $j++;
                last if ($j == $results_per_page);
            }
            chop $pasarParams if ($pasarParams =~ /,$/);
            $pasarParams .= '&amp;total=' . uri_escape_utf8( int($total) ) if ($pasarParams !~ /total=(?:[0-9]+)?/);
            if ($pasarParams) {
                my $session = get_session($cgi->cookie("CGISESSID"));
                $session->param('busc' => $pasarParams);
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
            $template->param(results_per_page =>  $results_per_page);
            my $hide = keys %$hidingrules ? 1 : 0;

            $template->param(
                SEARCH_RESULTS => \@newresults,
                suppress_result_number => $hide,
                            );
            if (C4::Context->preference("OPACLocalCoverImages")){
            $template->param(OPACLocalCoverImages => 1);
            $template->param(OPACLocalCoverImagesPriority => C4::Context->preference("OPACLocalCoverImagesPriority"));
            }
            ## Build the page numbers on the bottom of the page
            my ( $page_numbers, $hits_to_paginate, $pages, $current_page_number, $previous_page_offset, $next_page_offset, $last_page_offset ) =
                Koha::SearchEngine::Search->pagination_bar(
                    {
                        hits              => $hits,
                        max_result_window => $searcher->max_result_window,
                        results_per_page  => $results_per_page,
                        offset            => $offset,
                        sort_by           => \@sort_by
                    }
                );
            $template->param( hits_to_paginate => $hits_to_paginate );
            $template->param(   PAGE_NUMBERS => $page_numbers,
                                last_page_offset => $last_page_offset,
                                previous_page_offset => $previous_page_offset) unless $pages < 2;
            $template->param(next_page_offset => $next_page_offset) unless $pages eq $current_page_number;
        }
        # no hits
        else {
            my $nohits = C4::Context->preference('OPACNoResultsFound');
            if ($nohits and $nohits=~/{QUERY_KW}/){
                # extracting keywords in case of relaunching search
                (my $query_kw=$query_desc)=~s/ and|or / /g;
                my @query_kw=($query_kw=~ /([-\w]+\b)(?:[^:]|$)/g);
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

for my $facet ( @$facets ) {
    for my $entry ( @{ $facet->{facets} } ) {
        my $index = $entry->{type_link_value};
        my $value = $entry->{facet_link_value};
        $entry->{active} = grep { $_->{input_value} eq qq{$index:$value} } @limit_inputs;
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
my $some_private_shelves = Koha::Virtualshelves->get_some_shelves(
    {
        borrowernumber => $borrowernumber,
        add_allowed    => 1,
        public         => 0,
    }
);
my $some_public_shelves = Koha::Virtualshelves->get_some_shelves(
    {
        borrowernumber => $borrowernumber,
        add_allowed    => 1,
        public         => 1,
    }
);

$template->param(
    add_to_some_private_shelves => $some_private_shelves,
    add_to_some_public_shelves  => $some_public_shelves,
);

my $content_type = ($format eq 'rss' or $format eq 'atom' or $format eq 'opensearchdescription') ? $format : 'html';

$template->{VARS}->{DidYouMean} =
  ( defined C4::Context->preference('OPACdidyoumean')
      && C4::Context->preference('OPACdidyoumean') =~ m/enable/ );

if ($offset == 0) {
    $template->param(firstPage => 1);
}

    $template->param( borrowernumber    => $borrowernumber);
output_with_http_headers $cgi, $cookie, $template->output, $content_type;
