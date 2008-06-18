#!/usr/bin/perl
# Script to perform searching
# For documentation try 'perldoc /path/to/search'
#
# $Header$
#
# Copyright 2006 LibLime
#
# This file is part of Koha
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 NAME

search - a search script for finding records in a Koha system (Version 3)

=head1 OVERVIEW

This script utilizes a new search API for Koha 3. It is designed to be 
simple to use and configure, yet capable of performing feats like stemming,
field weighting, relevance ranking, support for multiple  query language
formats (CCL, CQL, PQF), full support for the bib1 attribute set, extended
attribute sets defined in Zebra profiles, access to the full range of Z39.50
and SRU query options, federated searches on Z39.50/SRU targets, etc.

The API as represented in this script is mostly sound, even if the individual
functions in Search.pm and Koha.pm need to be cleaned up. Of course, you are
free to disagree :-)

I will attempt to describe what is happening at each part of this script.
-- Joshua Ferraro <jmf AT liblime DOT com>

=head2 INTRO

This script performs two functions:

=over 

=item 1. interacts with Koha to retrieve and display the results of a search

=item 2. loads the advanced search page

=back

These two functions share many of the same variables and modules, so the first
task is to load what they have in common and determine which template to use.
Once determined, proceed to only load the variables and procedures necessary
for that function.

=head2 LOADING ADVANCED SEARCH PAGE

This is fairly straightforward, and I won't go into detail ;-)

=head2 PERFORMING A SEARCH

If we're performing a search, this script  performs three primary
operations:

=over 

=item 1. builds query strings (yes, plural)

=item 2. perform the search and return the results array

=item 3. build the HTML for output to the template

=back

There are several additional secondary functions performed that I will
not cover in detail.

=head3 1. Building Query Strings
    
There are several types of queries needed in the process of search and retrieve:

=over

=item 1 $query - the fully-built query passed to zebra

This is the most complex query that needs to be built. The original design goal 
was to use a custom CCL2PQF query parser to translate an incoming CCL query into
a multi-leaf query to pass to Zebra. It needs to be multi-leaf to allow field 
weighting, koha-specific relevance ranking, and stemming. When I have a chance 
I'll try to flesh out this section to better explain.

This query incorporates query profiles that aren't compatible with most non-Zebra 
Z39.50 targets to acomplish the field weighting and relevance ranking.

=item 2 $simple_query - a simple query that doesn't contain the field weighting,
stemming, etc., suitable to pass off to other search targets

This query is just the user's query expressed in CCL CQL, or PQF for passing to a 
non-zebra Z39.50 target (one that doesn't support the extended profile that Zebra does).

=item 3 $query_cgi - passed to the template / saved for future refinements of 
the query (by user)

This is a simple string that completely expresses the query as a CGI string that
can be used for future refinements of the query or as a part of a history feature.

=item 4 $query_desc - Human search description - what the user sees in search
feedback area

This is a simple string that is human readable. It will contain '=', ',', etc.

=back

=head3 2. Perform the Search

This section takes the query strings and performs searches on the named servers,
including the Koha Zebra server, stores the results in a deeply nested object, 
builds 'faceted results', and returns these objects.

=head3 3. Build HTML

The final major section of this script takes the objects collected thusfar and 
builds the HTML for output to the template and user.

=head3 Additional Notes

Not yet completed...

=cut

use strict;            # always use

## STEP 1. Load things that are used in both search page and
# results page and decide which template to load, operations 
# to perform, etc.

## load Koha modules
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Search;
use C4::Languages qw(getAllLanguages);
use C4::Koha;
use POSIX qw(ceil floor);
use C4::Branch; # GetBranches

# create a new CGI object
# FIXME: no_undef_params needs to be tested
use CGI qw('-no_undef_params');
my $cgi = new CGI;

my ($template,$borrowernumber,$cookie);

# decide which template to use
my $template_name;
my $template_type;
my @params = $cgi->param("limit");
if ((@params>=1) || ($cgi->param("q")) || ($cgi->param('multibranchlimit')) || ($cgi->param('limit-yr')) ) {
    $template_name = 'catalogue/results.tmpl';
}
else {
    $template_name = 'catalogue/advsearch.tmpl';
    $template_type = 'advsearch';
}
# load the template
($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => $template_name,
    query => $cgi,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired   => { catalogue => 1 },
    }
);
if (C4::Context->preference("marcflavour") eq "UNIMARC" ) {
    $template->param('UNIMARC' => 1);
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
my $branches = GetBranches();
my @branch_loop;

for my $branch_hash (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    push @branch_loop, {value => "$branch_hash" , branchname => $branches->{$branch_hash}->{'branchname'}, };
}

my $categories = GetBranchCategories(undef,'searchdomain');

$template->param(branchloop => \@branch_loop, searchdomainloop => $categories);

# load the Type stuff
# load the Type stuff
my $itemtypes = GetItemTypes;
# the index parameter is different for item-level itemtypes
my $itype_or_itemtype = (C4::Context->preference("item-level_itypes"))?'itype':'itemtype';
my @itemtypesloop;
my $selected=1;
my $cnt;
my $imgdir = getitemtypeimagesrc('intranet');
my $advanced_search_types = C4::Context->preference("AdvancedSearchTypes");

if (!$advanced_search_types or $advanced_search_types eq 'itemtypes') {                                                                 foreach my $thisitemtype ( sort {$itemtypes->{$a}->{'description'} cmp $itemtypes->{$b}->{'description'} } keys %$itemtypes ) {
    my %row =(  number=>$cnt++,
                imageurl=> $itemtypes->{$thisitemtype}->{'imageurl'}?($imgdir."/".$itemtypes->{$thisitemtype}->{'imageurl'}):"",
                ccl => $itype_or_itemtype,
                code => $thisitemtype,
                selected => $selected,
                description => $itemtypes->{$thisitemtype}->{'description'},
                count5 => $cnt % 4,
            );
        $selected = 0 if ($selected) ;
        push @itemtypesloop, \%row;
    }
    $template->param(itemtypeloop => \@itemtypesloop);
} else {
    my $advsearchtypes = GetAuthorisedValues($advanced_search_types);
    for my $thisitemtype (@$advsearchtypes) {
        my %row =(
                number=>$cnt++,
                imageurl=> $imgdir."/".$thisitemtype->{'imageurl'},
                ccl => $advanced_search_types,
                code => $thisitemtype->{authorised_value},
                selected => $selected,
                description => $thisitemtype->{'lib'},
                count5 => $cnt % 4,
            );
        push @itemtypesloop, \%row;
    }
    $template->param(itemtypeloop => \@itemtypesloop);
}

# The following should only be loaded if we're bringing up the advanced search template
if ( $template_type eq 'advsearch' ) {

    # load the servers (used for searching -- to do federated searching, etc.)
    my $primary_servers_loop;# = displayPrimaryServers();
    $template->param(outer_servers_loop =>  $primary_servers_loop,);
    
    my $secondary_servers_loop;# = displaySecondaryServers();
    $template->param(outer_sup_servers_loop => $secondary_servers_loop,);
    
    # determine what to display next to the search boxes (ie, boolean option
    # shouldn't appear on the first one, scan indexes should, adding a new
    # box should only appear on the last, etc.
    my @search_boxes_array;
    my $search_boxes_count = C4::Context->preference("OPACAdvSearchInputCount") | 3; # FIXME: should be a syspref
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
    $template->param(uc(C4::Context->preference("marcflavour")) => 1,
                      search_boxes_loop => \@search_boxes_array);

    # load the language limits (for search)
    my $languages_limit_loop = getAllLanguages();
    $template->param(search_languages_loop => $languages_limit_loop,);

    # use the global setting by default
    if ( C4::Context->preference("expandedSearchOption") == 1) {
        $template->param( expanded_options => C4::Context->preference("expandedSearchOption") );
    }
    # but let the user override it
    if ( ($cgi->param('expanded_options') == 0) || ($cgi->param('expanded_options') == 1 ) ) {
        $template->param( expanded_options => $cgi->param('expanded_options'));
    }

    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

### OK, if we're this far, we're performing a search, not just loading the advanced search page

# Fetch the paramater list as a hash in scalar context:
#  * returns paramater list as tied hash ref
#  * we can edit the values by changing the key
#  * multivalued CGI paramaters are returned as a packaged string separated by "\0" (null)
my $params = $cgi->Vars;

# Params that can have more than one value
# sort by is used to sort the query
# in theory can have more than one but generally there's just one
my @sort_by;
my $default_sort_by = C4::Context->preference('defaultSortField')."_".C4::Context->preference('defaultSortOrder') 
    if (C4::Context->preference('defaultSortField') && C4::Context->preference('defaultSortOrder'));

@sort_by = split("\0",$params->{'sort_by'}) if $params->{'sort_by'};
$sort_by[0] = $default_sort_by unless $sort_by[0];
foreach my $sort (@sort_by) {
    $template->param($sort => 1);
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
@indexes = split("\0",$params->{'idx'});

# an operand can be a single term, a phrase, or a complete ccl query
my @operands;
@operands = split("\0",$params->{'q'}) if $params->{'q'};

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
my $limit_yr;
my $limit_yr_value;
if ($params->{'limit-yr'}) {
    if ($params->{'limit-yr'} =~ /\d{4}-\d{4}/) {
        my ($yr1,$yr2) = split(/-/, $params->{'limit-yr'});
        $limit_yr = "yr,st-numeric,ge=$yr1 and yr,st-numeric,le=$yr2";
        $limit_yr_value = "$yr1-$yr2";
    }
    elsif ($params->{'limit-yr'} =~ /\d{4}/) {
        $limit_yr = "yr,st-numeric=$params->{'limit-yr'}";
        $limit_yr_value = $params->{'limit-yr'};
    }
    push @limits,$limit_yr;
    #FIXME: Should return a error to the user, incorect date format specified
}

# Params that can only have one value
my $scan = $params->{'scan'};
my $count = C4::Context->preference('numSearchResults') || 20;
my $results_per_page = $params->{'count'} || $count;
my $offset = $params->{'offset'} || 0;
my $page = $cgi->param('page') || 1;
#my $offset = ($page-1)*$results_per_page;
my $hits;
my $expanded_facet = $params->{'expand'};

# Define some global variables
my ( $error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type);

my @results;

## I. BUILD THE QUERY
( $error,$query,$simple_query,$query_cgi,$query_desc,$limit,$limit_cgi,$limit_desc,$stopwords_removed,$query_type) = buildQuery(\@operators,\@operands,\@indexes,\@limits,\@sort_by,$scan);

## parse the query_cgi string and put it into a form suitable for <input>s
my @query_inputs;
for my $this_cgi ( split('&',$query_cgi) ) {
    next unless $this_cgi;
    $this_cgi =~ m/(.*=)(.*)/;
    my $input_name = $1;
    my $input_value = $2;
    $input_name =~ s/=$//;
    push @query_inputs, { input_name => $input_name, input_value => $input_value };
}
$template->param ( QUERY_INPUTS => \@query_inputs );

## parse the limit_cgi string and put it into a form suitable for <input>s
my @limit_inputs;
for my $this_cgi ( split('&',$limit_cgi) ) {
    next unless $this_cgi;
    # handle special case limit-yr
    if ($this_cgi =~ /yr,st-numeric/) {
        push @limit_inputs, { input_name => 'limit-yr', input_value => $limit_yr_value };   
        next;
    }
    $this_cgi =~ m/(.*=)(.*)/;
    my $input_name = $1;
    my $input_value = $2;
    $input_name =~ s/=$//;
    push @limit_inputs, { input_name => $input_name, input_value => $input_value };
}
$template->param ( LIMIT_INPUTS => \@limit_inputs );

## II. DO THE SEARCH AND GET THE RESULTS
my $total; # the total results for the whole set
my $facets; # this object stores the faceted results that display on the left-hand of the results page
my @results_array;
my $results_hashref;

if (C4::Context->preference('NoZebra')) {
    $query=~s/yr(:|=)\s*([\d]{1,4})-([\d]{1,4})/(yr>=$2 and yr<=$3)/g;
    $simple_query=~s/yr\s*(:|=)([\d]{1,4})-([\d]{1,4})/(yr>=$2 and yr<=$3)/g;
    warn $query; 
    eval {
        ($error, $results_hashref, $facets) = NZgetRecords($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,$expanded_facet,$branches,$query_type,$scan);
    };
} else {
    eval {
        ($error, $results_hashref, $facets) = getRecords($query,$simple_query,\@sort_by,\@servers,$results_per_page,$offset,$expanded_facet,$branches,$query_type,$scan);
    };
}
if ($@ || $error) {
    $template->param(query_error => $error.$@);

    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

# FIXME: This belongs in tools/ not in the primary search results page
my $op=$cgi->param("operation");
if ($op eq "bulkedit"){
    my ($countchanged,$listunchanged)=
    ModBiblios($results_hashref->{'biblioserver'}->{"RECORDS"},
                      $params->{"tagsubfield"},
                      $params->{"inputvalue"},
                      $params->{"targetvalue"},
                      $params->{"test"}
                      );
    $template->param(bulkeditresults=>1,
                      tagsubfield=>$params->{"tagsubfield"},
                      inputvalue=>$params->{"inputvalue"},
                      targetvalue=>$params->{"targetvalue"},
                      countchanged=>$countchanged,
                      countunchanged=>scalar(@$listunchanged),
                      listunchanged=>$listunchanged);

    if (C4::Context->userenv->{'flags'}==1 ||(C4::Context->userenv->{'flags'} & ( 2**9 ) )){
    #Edit Catalogue Permissions
        my $editable_subfields = GetManagedTagSubfields();
        # change '--' to '&mdash;' to avoid escaping issues
        for (my $i = 0; $i <= $#{$editable_subfields}; $i++) {
            $editable_subfields->[$i]->{subfielddesc} =~ s/--/&mdash;/g;
            $editable_subfields->[$i]->{tagdesc} =~ s/--/&mdash;/g;
        }
        $template->param(bulkedit => 1);
        $template->param(tagsubfields=>$editable_subfields);
    }
}

# At this point, each server has given us a result set
# now we build that set for template display
my @sup_results_array;
for (my $i=0;$i<@servers;$i++) {
    my $server = $servers[$i];
    if ($server =~/biblioserver/) { # this is the local bibliographic server
        $hits = $results_hashref->{$server}->{"hits"};
        my $page = $cgi->param('page') || 0;
        my @newresults = searchResults( $query_desc,$hits,$results_per_page,$offset,@{$results_hashref->{$server}->{"RECORDS"}});
        $total = $total + $results_hashref->{$server}->{"hits"};
        ## If there's just one result, redirect to the detail page
        if ($total == 1) {         
            my $biblionumber=@newresults[0]->{biblionumber};
            if (C4::Context->preference('IntranetBiblioDefaultView') eq 'isbd') {
                print $cgi->redirect("/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=$biblionumber");
            } elsif  (C4::Context->preference('IntranetBiblioDefaultView') eq 'marc') {
                print $cgi->redirect("/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=$biblionumber");
            } else {
                print $cgi->redirect("/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber");
            } 
            exit;
        }
        if ($hits) {
            $template->param(total => $hits);
            my $limit_cgi_not_availablity = $limit_cgi;
            $limit_cgi_not_availablity =~ s/&limit=available//g;
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
            $template->param(SEARCH_RESULTS => \@newresults);

            ## FIXME: add a global function for this, it's better than the current global one
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
                for (my $i=1; $i<=$pages_to_show;$i++) {
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
                for (my $i=$current_page_number; $i<=($current_page_number + 20 );$i++) {
                    my $this_offset = ((($i-9)*$results_per_page)-$results_per_page);
                    my $this_page_number = $i-9;
                    my $highlight = 1 if ($this_page_number == $current_page_number);
                    if ($this_page_number <= $pages) {
                        push @page_numbers, { offset => $this_offset, pg => $this_page_number, highlight => $highlight, sort_by => join " ",@sort_by };
                    }
                }
                        
            }
            # FIXME: no previous_page_offset when pages < 2
            $template->param(   PAGE_NUMBERS => \@page_numbers,
                                previous_page_offset => $previous_page_offset) unless $pages < 2;
            $template->param(   next_page_offset => $next_page_offset) unless $pages eq $current_page_number;
        }
        # no hits
        else {
            $template->param(searchdesc => 1,query_desc => $query_desc,limit_desc => $limit_desc);
        }
    } # end of the if local

    # asynchronously search the authority server
    elsif ($server =~/authorityserver/) { # this is the local authority server
        my @inner_sup_results_array;
        for my $sup_record ( @{$results_hashref->{$server}->{"RECORDS"}} ) {
            my $marc_record_object = MARC::Record->new_from_usmarc($sup_record);
            # warn "Authority Found: ".$marc_record_object->as_formatted();
            push @inner_sup_results_array, {
                'title' => $marc_record_object->field(100)->subfield('a'),
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
output_html_with_http_headers $cgi, $cookie, $template->output;
