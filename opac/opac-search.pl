#!/usr/bin/perl
# Script to perform searching
# Mostly copied from search.pl, see POD there
use strict;            # always use
use warnings;

## STEP 1. Load things that are used in both search page and
# results page and decide which template to load, operations 
# to perform, etc.
## load Koha modules
use C4::Context;
use C4::Output;
use C4::Auth qw(:DEFAULT get_session);
use C4::Search;
use C4::Biblio;  # GetBiblioData
use C4::Koha;
use C4::Tags qw(get_tags);
use POSIX qw(ceil floor strftime);
use C4::Branch; # GetBranches

# create a new CGI object
# FIXME: no_undef_params needs to be tested
use CGI qw('-no_undef_params');
my $cgi = new CGI;

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
	$template_name = 'opac-opensearch.tmpl';
}
elsif ($build_grouped_results) {
    $template_name = 'opac-results-grouped.tmpl';
}
elsif ((@params>=1) || ($cgi->param("q")) || ($cgi->param('multibranchlimit')) || ($cgi->param('limit-yr')) ) {
	$template_name = 'opac-results.tmpl';
}
else {
    $template_name = 'opac-advsearch.tmpl';
    $template_type = 'advsearch';
}
# load the template
($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $template_name,
    query => $cgi,
    type => "opac",
    authnotrequired => 1,
    }
);

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
my $mybranch = ( C4::Context->preference('SearchMyLibraryFirst') && C4::Context->userenv && C4::Context->userenv->{branch} ) ? C4::Context->userenv->{branch} : '';
my $branches = GetBranches();   # used later in *getRecords, probably should be internalized by those functions after caching in C4::Branch is established
$template->param(
    branchloop       => GetBranchesLoop($mybranch, 0),
    searchdomainloop => GetBranchCategories(undef,'searchdomain'),
);

# load the Type stuff
my $itemtypes = GetItemTypes;
# the index parameter is different for item-level itemtypes
my $itype_or_itemtype = (C4::Context->preference("item-level_itypes"))?'itype':'itemtype';
my @itemtypesloop;
my $selected=1;
my $cnt;
my $advanced_search_types = C4::Context->preference("AdvancedSearchTypes");

if (!$advanced_search_types or $advanced_search_types eq 'itemtypes') {
	foreach my $thisitemtype ( sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} } keys %$itemtypes ) {
        my %row =(  number=>$cnt++,
				ccl => $itype_or_itemtype,
                code => $thisitemtype,
                selected => $selected,
                description => $itemtypes->{$thisitemtype}->{'description'},
                count5 => $cnt % 4,
                imageurl=> getitemtypeimagelocation( 'opac', $itemtypes->{$thisitemtype}->{'imageurl'} ),
            );
    	$selected = 0; # set to zero after first pass through
    	push @itemtypesloop, \%row;
	}
} else {
    my $advsearchtypes = GetAuthorisedValues($advanced_search_types);
	for my $thisitemtype (@$advsearchtypes) {
		my %row =(
				number=>$cnt++,
				ccl => $advanced_search_types,
                code => $thisitemtype->{authorised_value},
                selected => $selected,
                description => $thisitemtype->{'lib'},
                count5 => $cnt % 4,
                imageurl=> getitemtypeimagelocation( 'opac', $thisitemtype->{'imageurl'} ),
            );
		push @itemtypesloop, \%row;
	}
}
$template->param(itemtypeloop => \@itemtypesloop);

# # load the itypes (Called item types in the template -- just authorized values for searching)
# my ($itypecount,@itype_loop) = GetCcodes();
# $template->param(itypeloop=>\@itype_loop,);

# The following should only be loaded if we're bringing up the advanced search template
if ( $template_type && $template_type eq 'advsearch' ) {

    # load the servers (used for searching -- to do federated searching, etc.)
    my $primary_servers_loop;# = displayPrimaryServers();
    $template->param(outer_servers_loop =>  $primary_servers_loop,);
    
    my $secondary_servers_loop;# = displaySecondaryServers();
    $template->param(outer_sup_servers_loop => $secondary_servers_loop,);

    # set the default sorting
    my $default_sort_by = C4::Context->preference('OPACdefaultSortField')."_".C4::Context->preference('OPACdefaultSortOrder') 
        if (C4::Context->preference('OPACdefaultSortField') && C4::Context->preference('OPACdefaultSortOrder'));
    $template->param($default_sort_by => 1);

    # determine what to display next to the search boxes (ie, boolean option
    # shouldn't appear on the first one, scan indexes should, adding a new
    # box should only appear on the last, etc.
    my @search_boxes_array;
    my $search_boxes_count = C4::Context->preference("OPACAdvSearchInputCount") || 3;
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
    $template->param(uc(C4::Context->preference("marcflavour")) => 1,   # we already did this for UNIMARC
					  advsearch => 1,
                      search_boxes_loop => \@search_boxes_array);

# use the global setting by default
	if ( C4::Context->preference("expandedSearchOption") ) {
		$template->param( expanded_options => C4::Context->preference("expandedSearchOption") );
	}
	# but let the user override it
   	if ( $cgi->param("expanded_options") && (($cgi->param('expanded_options') == 0) || ($cgi->param('expanded_options') == 1 )) ) {
    	$template->param( expanded_options => $cgi->param('expanded_options'));
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
$tag = $params->{tag} if $params->{tag};

# Params that can have more than one value
# sort by is used to sort the query
# in theory can have more than one but generally there's just one
my @sort_by;
my $default_sort_by = C4::Context->preference('OPACdefaultSortField')."_".C4::Context->preference('OPACdefaultSortOrder') 
    if (C4::Context->preference('OPACdefaultSortField') && C4::Context->preference('OPACdefaultSortOrder'));

@sort_by = split("\0",$params->{'sort_by'}) if $params->{'sort_by'};
$sort_by[0] = $default_sort_by if !$sort_by[0] && defined($default_sort_by);
foreach my $sort (@sort_by) {
    $template->param($sort => 1);   # FIXME: security hole.  can set any TMPL_VAR here
}
$template->param('sort_by' => $sort_by[0]);

# Use the servers defined, or just search our local catalog(default)
my @servers;
@servers = split("\0",$params->{'server'}) if $params->{'server'};
unless (@servers) {
    #FIXME: this should be handled using Context.pm
    @servers = ("biblioserver");
    # @servers = C4::Context->config("biblioserver");
}

# operators include boolean and proximity operators and are used
# to evaluate multiple operands
my @operators;
@operators = split("\0",$params->{'op'}) if $params->{'op'};

# indexes are query qualifiers, like 'title', 'author', etc. They
# can be single or multiple parameters separated by comma: kw,right-Truncation 
my @indexes;
@indexes = split("\0",$params->{'idx'}) if $params->{'idx'};

# if a simple index (only one)  display the index used in the top search box
if ($indexes[0] && !$indexes[1]) {
    $template->param("ms_".$indexes[0] => 1);
}
# an operand can be a single term, a phrase, or a complete ccl query
my @operands;
@operands = split("\0",$params->{'q'}) if $params->{'q'};

# if a simple search, display the value in the search box
if ($operands[0] && !$operands[1]) {
    $template->param(ms_value => $operands[0]);
}

# limits are use to limit to results to a pre-defined category such as branch or language
my @limits;
@limits = split("\0",$params->{'limit'}) if $params->{'limit'};

if($params->{'multibranchlimit'}) {
push @limits, join(" or ", map { "branch: $_ "}  @{GetBranchesInCategory($params->{'multibranchlimit'})}) ;
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
( $error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type) = buildQuery(\@operators,\@operands,\@indexes,\@limits,\@sort_by);

sub _input_cgi_parse ($) { 
    my @elements;
    for my $this_cgi ( split('&',shift) ) {
        next unless $this_cgi;
        $this_cgi =~ /(.*?)=(.*)/;
        push @elements, { input_name => $1, input_value => $2 };
    }
    return @elements;
}

## parse the query_cgi string and put it into a form suitable for <input>s
my @query_inputs = _input_cgi_parse($query_cgi);
$template->param ( QUERY_INPUTS => \@query_inputs );

## parse the limit_cgi string and put it into a form suitable for <input>s
my @limit_inputs = $limit_cgi ? _input_cgi_parse($limit_cgi) : ();

# add OPAC 'hidelostitems'
if (C4::Context->preference('hidelostitems') == 1) {
    # either lost ge 0 or no value in the lost register
    $query ="($query) and ( (lost,st-numeric <= 0) or ( allrecords,AlwaysMatches='' not lost,AlwaysMatches='') )";
}

# add OPAC suppression - requires at least one item indexed with Suppress
if (C4::Context->preference('OpacSuppression')) {
    $query = "($query) not Suppress=1";
}

$template->param ( LIMIT_INPUTS => \@limit_inputs );

## II. DO THE SEARCH AND GET THE RESULTS
my $total = 0; # the total results for the whole set
my $facets; # this object stores the faceted results that display on the left-hand of the results page
my @results_array;
my $results_hashref;
my @coins;

if ($tag) {
	my $taglist = get_tags({term=>$tag, approved=>1});
	$results_hashref->{biblioserver}->{hits} = scalar (@$taglist);
	my @biblist  = (map {GetBiblioData($_->{biblionumber})} @$taglist);
	my @marclist = (map {$_->{marc}} @biblist );
	$DEBUG and printf STDERR "taglist (%s biblionumber)\nmarclist (%s records)\n", scalar(@$taglist), scalar(@marclist);
	$results_hashref->{biblioserver}->{RECORDS} = \@marclist;
	# FIXME: tag search and standard search should work together, not exclusively
	# FIXME: No facets for tags search.
}
elsif (C4::Context->preference('NoZebra')) {
    eval {
        ($error, $results_hashref, $facets) = NZgetRecords($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,$expanded_facet,$branches,$query_type,$scan);
    };
} elsif ($build_grouped_results) {
    eval {
        ($error, $results_hashref, $facets) = C4::Search::pazGetRecords($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,$expanded_facet,$branches,$query_type,$scan);
    };
} else {
    eval {
        ($error, $results_hashref, $facets) = getRecords($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,$expanded_facet,$branches,$query_type,$scan);
    };
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
for (my $i=0;$i<=@servers;$i++) {
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
                my @group_results = searchResults( $query_desc, $group->{'group_count'},$results_per_page, 0, $scan,
                                                   @{ $group->{"RECORDS"} });
                push @newresults, { group_label => $group->{'group_label'}, GROUP_RESULTS => \@group_results };
            }
        } else {
            @newresults = searchResults( $query_desc,$hits,$results_per_page,$offset,$scan,@{$results_hashref->{$server}->{"RECORDS"}});
        }
		my $tag_quantity;
		if (C4::Context->preference('TagsEnabled') and
			$tag_quantity = C4::Context->preference('TagsShowOnList')) {
			foreach (@newresults) {
				my $bibnum = $_->{biblionumber} or next;
				$_ ->{'TagLoop'} = get_tags({biblionumber=>$bibnum, approved=>1, 'sort'=>'-weight',
										limit=>$tag_quantity });
			}
		}
		foreach (@newresults) {
		    $_->{coins} = GetCOinSBiblio($_->{'biblionumber'});
		}
      
	if ($results_hashref->{$server}->{"hits"}){
	    $total = $total + $results_hashref->{$server}->{"hits"};
	}
        ## If there's just one result, redirect to the detail page
        if ($total == 1) {         
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
            $template->param(total => $hits);
            my $limit_cgi_not_availablity = $limit_cgi;
            $limit_cgi_not_availablity =~ s/&limit=available//g if defined $limit_cgi_not_availablity;
            $template->param(limit_cgi_not_availablity => $limit_cgi_not_availablity);
            $template->param(limit_cgi => $limit_cgi);
            $template->param(query_cgi => $query_cgi);
            $template->param(query_desc => $query_desc);
            $template->param(limit_desc => $limit_desc);
            if ($query_desc || $limit_desc) {
                $template->param(searchdesc => 1);
            }
            $template->param(stopwords_removed => "@$stopwords_removed") if $stopwords_removed;
            $template->param(results_per_page =>  $results_per_page);
            $template->param(SEARCH_RESULTS => \@newresults,
                                OPACItemsResultsDisplay => (C4::Context->preference("OPACItemsResultsDisplay") eq "itemdetails"?1:0),
                            );
            ## Build the page numbers on the bottom of the page
            my @page_numbers;
            # total number of pages there will be
            my $pages = ceil($hits / $results_per_page);
            # default page number
            my $current_page_number = 1;
            $current_page_number = ($offset / $results_per_page + 1) if $offset;
            my $previous_page_offset = $offset - $results_per_page unless ($offset - $results_per_page <0);
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
                    # it should only be highlighted if it's the current page
                    my $highlight = 1 if ($this_page_number == $current_page_number);
                    # put it in the array
                    push @page_numbers, { offset => $this_offset, pg => $this_page_number, highlight => $highlight, sort_by => join " ",@sort_by };
                                
                }
                        
            }
            # now, show twenty pages, with the current one smack in the middle
            else {
                for ($i=$current_page_number; $i<=($current_page_number + 20 );$i++) {
                    my $this_offset = ((($i-9)*$results_per_page)-$results_per_page);
                    my $this_page_number = $i-9;
                    my $highlight = 1 if ($this_page_number == $current_page_number);
                    if ($this_page_number <= $pages) {
                        push @page_numbers, { offset => $this_offset, pg => $this_page_number, highlight => $highlight, sort_by => join " ",@sort_by };
                    }
                }
                        
            }
            $template->param(   PAGE_NUMBERS => \@page_numbers,
                                previous_page_offset => $previous_page_offset) unless $pages < 2;
            $template->param(next_page_offset => $next_page_offset) unless $pages eq $current_page_number;
         }
        # no hits
        else {
            $template->param(searchdesc => 1,query_desc => $query_desc,limit_desc => $limit_desc);
        }
    } # end of the if local
    # asynchronously search the authority server
    elsif ($server && $server =~/authorityserver/) { # this is the local authority server
        my @inner_sup_results_array;
        for my $sup_record ( @{$results_hashref->{$server}->{"RECORDS"}} ) {
            my $marc_record_object = MARC::Record->new_from_usmarc($sup_record);
            my $title_field = $marc_record_object->field(100);
             warn "Authority Found: ".$marc_record_object->as_formatted();
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

$template->param(
            #classlist => $classlist,
            total => $total,
            opacfacets => 1,
            facets_loop => $facets,
            scan => $scan,
            search_error => $error,
);

if ($query_desc || $limit_desc) {
    $template->param(searchdesc => 1);
}

## Now let's find out if we have any supplemental data to show the user
#  and in the meantime, save the current query for statistical purposes, etc.
my $koha_spsuggest; # a flag to tell if we've got suggestions coming from Koha
my @koha_spsuggest; # place we store the suggestions to be returned to the template as LOOP
my $phrases = $query_desc;
my $ipaddress;

if ( C4::Context->preference("kohaspsuggest") ) {
        my ($suggest_host, $suggest_dbname, $suggest_user, $suggest_pwd) = split(':', C4::Context->preference("kohaspsuggest"));
        eval {
            my $koha_spsuggest_dbh;
            # FIXME: this needs to be moved to Context.pm
            eval {
                $koha_spsuggest_dbh=DBI->connect("DBI:mysql:$suggest_dbname:$suggest_host","$suggest_user","$suggest_pwd");
            };
            if ($@) { 
                warn "can't connect to spsuggest db";
            }
            else {
                my $koha_spsuggest_insert = "INSERT INTO phrase_log(phr_phrase,phr_resultcount,phr_ip) VALUES(?,?,?)";
                my $koha_spsuggest_query = "SELECT display FROM distincts WHERE strcmp(soundex(suggestion), soundex(?)) = 0 order by soundex(suggestion) limit 0,5";
                my $koha_spsuggest_sth = $koha_spsuggest_dbh->prepare($koha_spsuggest_query);
                $koha_spsuggest_sth->execute($phrases);
                while (my $spsuggestion = $koha_spsuggest_sth->fetchrow_array) {
                    $spsuggestion =~ s/(:|\/)//g;
                    my %line;
                    $line{spsuggestion} = $spsuggestion;
                    push @koha_spsuggest,\%line;
                    $koha_spsuggest = 1;
                }

                # Now save the current query
                $koha_spsuggest_sth=$koha_spsuggest_dbh->prepare($koha_spsuggest_insert);
                #$koha_spsuggest_sth->execute($phrases,$results_per_page,$ipaddress);
                $koha_spsuggest_sth->finish;

                $template->param( koha_spsuggest => $koha_spsuggest ) unless $hits;
                $template->param( SPELL_SUGGEST => \@koha_spsuggest,
                );
            }
    };
    if ($@) {
            warn "Kohaspsuggest failure:".$@;
    }
}

# VI. BUILD THE TEMPLATE
# Build drop-down list for 'Add To:' menu...
my $session = get_session($cgi->cookie("CGISESSID"));
my @addpubshelves;
my $pubshelves = $session->param('pubshelves');
my $barshelves = $session->param('barshelves');
foreach my $shelf (@$pubshelves) {
	next if ( ($shelf->{'owner'} != ($borrowernumber ? $borrowernumber : -1)) && ($shelf->{'category'} < 3) );
	push (@addpubshelves, $shelf);
}

if (@addpubshelves) {
	$template->param( addpubshelves     => scalar (@addpubshelves));
	$template->param( addpubshelvesloop => \@addpubshelves);
}

if (defined $barshelves) {
	$template->param( addbarshelves     => scalar (@$barshelves));
	$template->param( addbarshelvesloop => $barshelves);
}

my $content_type = ($format eq 'rss' or $format eq 'atom') ? $format : 'html';

# If GoogleIndicTransliteration system preference is On Set paramter to load Google's javascript in OPAC search screens 
if (C4::Context->preference('GoogleIndicTransliteration')) {
        $template->param('GoogleIndicTransliteration' => 1);
}

output_with_http_headers $cgi, $cookie, $template->output, $content_type;
