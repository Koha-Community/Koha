package C4::Search;

# This file is part of Koha.
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

use strict;
require Exporter;
use C4::Context;
use C4::Biblio;    # GetMarcFromKohaField
use C4::Koha;      # getFacets
use Lingua::Stem;
use C4::Search::PazPar2;
use XML::Simple;
use C4::Dates qw(format_date);
use C4::XSLT;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $DEBUG);

# set the version for version checking
BEGIN {
    $VERSION = 3.01;
    $DEBUG = ($ENV{DEBUG}) ? 1 : 0;
}

=head1 NAME

C4::Search - Functions for searching the Koha catalog.

=head1 SYNOPSIS

See opac/opac-search.pl or catalogue/search.pl for example of usage

=head1 DESCRIPTION

This module provides searching functions for Koha's bibliographic databases

=head1 FUNCTIONS

=cut

@ISA    = qw(Exporter);
@EXPORT = qw(
  &findseealso
  &FindDuplicate
  &SimpleSearch
  &searchResults
  &getRecords
  &buildQuery
  &NZgetRecords
  &ModBiblios
);

# make all your functions, whether exported or not;

=head2 findseealso($dbh,$fields);

C<$dbh> is a link to the DB handler.

use C4::Context;
my $dbh =C4::Context->dbh;

C<$fields> is a reference to the fields array

This function modifies the @$fields array and adds related fields to search on.

FIXME: this function is probably deprecated in Koha 3

=cut

sub findseealso {
    my ( $dbh, $fields ) = @_;
    my $tagslib = GetMarcStructure(1);
    for ( my $i = 0 ; $i <= $#{$fields} ; $i++ ) {
        my ($tag)      = substr( @$fields[$i], 1, 3 );
        my ($subfield) = substr( @$fields[$i], 4, 1 );
        @$fields[$i] .= ',' . $tagslib->{$tag}->{$subfield}->{seealso}
          if ( $tagslib->{$tag}->{$subfield}->{seealso} );
    }
}

=head2 FindDuplicate

($biblionumber,$biblionumber,$title) = FindDuplicate($record);

This function attempts to find duplicate records using a hard-coded, fairly simplistic algorithm

=cut

sub FindDuplicate {
    my ($record) = @_;
    my $dbh = C4::Context->dbh;
    my $result = TransformMarcToKoha( $dbh, $record, '' );
    my $sth;
    my $query;
    my $search;
    my $type;
    my ( $biblionumber, $title );

    # search duplicate on ISBN, easy and fast..
    # ... normalize first
    if ( $result->{isbn} ) {
        $result->{isbn} =~ s/\(.*$//;
        $result->{isbn} =~ s/\s+$//;
        $query = "isbn=$result->{isbn}";
    }
    else {
        $result->{title} =~ s /\\//g;
        $result->{title} =~ s /\"//g;
        $result->{title} =~ s /\(//g;
        $result->{title} =~ s /\)//g;

        # FIXME: instead of removing operators, could just do
        # quotes around the value
        $result->{title} =~ s/(and|or|not)//g;
        $query = "ti,ext=$result->{title}";
        $query .= " and itemtype=$result->{itemtype}"
          if ( $result->{itemtype} );
        if   ( $result->{author} ) {
            $result->{author} =~ s /\\//g;
            $result->{author} =~ s /\"//g;
            $result->{author} =~ s /\(//g;
            $result->{author} =~ s /\)//g;

            # remove valid operators
            $result->{author} =~ s/(and|or|not)//g;
            $query .= " and au,ext=$result->{author}";
        }
    }

    # FIXME: add error handling
    my ( $error, $searchresults ) = SimpleSearch($query); # FIXME :: hardcoded !
    my @results;
    foreach my $possible_duplicate_record (@$searchresults) {
        my $marcrecord =
          MARC::Record->new_from_usmarc($possible_duplicate_record);
        my $result = TransformMarcToKoha( $dbh, $marcrecord, '' );

        # FIXME :: why 2 $biblionumber ?
        if ($result) {
            push @results, $result->{'biblionumber'};
            push @results, $result->{'title'};
        }
    }
    return @results;
}

=head2 SimpleSearch

($error,$results) = SimpleSearch( $query, $offset, $max_results, [ @servers ] );

This function provides a simple search API on the bibliographic catalog

=over 2

=item C<input arg:>

    * $query can be a simple keyword or a complete CCL query
    * @servers is optional. Defaults to biblioserver as found in koha-conf.xml
    * $offset - If present, represents the number of records at the beggining to omit. Defaults to 0
    * $max_results - if present, determines the maximum number of records to fetch. undef is All. defaults to undef.


=item C<Output arg:>
    * $error is a empty unless an error is detected
    * \@results is an array of records.

=item C<usage in the script:>

=back

my ($error, $marcresults) = SimpleSearch($query);

if (defined $error) {
    $template->param(query_error => $error);
    warn "error: ".$error;
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my $hits = scalar @$marcresults;
my @results;

for(my $i=0;$i<$hits;$i++) {
    my %resultsloop;
    my $marcrecord = MARC::File::USMARC::decode($marcresults->[$i]);
    my $biblio = TransformMarcToKoha(C4::Context->dbh,$marcrecord,'');

    #build the hash for the template.
    $resultsloop{highlight}       = ($i % 2)?(1):(0);
    $resultsloop{title}           = $biblio->{'title'};
    $resultsloop{subtitle}        = $biblio->{'subtitle'};
    $resultsloop{biblionumber}    = $biblio->{'biblionumber'};
    $resultsloop{author}          = $biblio->{'author'};
    $resultsloop{publishercode}   = $biblio->{'publishercode'};
    $resultsloop{publicationyear} = $biblio->{'publicationyear'};

    push @results, \%resultsloop;
}

$template->param(result=>\@results);

=cut

sub SimpleSearch {
    my ( $query, $offset, $max_results, $servers )  = @_;
    
    if ( C4::Context->preference('NoZebra') ) {
        my $result = NZorder( NZanalyse($query) )->{'biblioserver'};
        my $search_result =
          (      $result->{hits}
              && $result->{hits} > 0 ? $result->{'RECORDS'} : [] );
        return ( undef, $search_result, scalar($search_result) );
    }
    else {
        # FIXME hardcoded value. See catalog/search.pl & opac-search.pl too.
        my @servers = defined ( $servers ) ? @$servers : ( "biblioserver" );
        my @results;
        my @tmpresults;
        my @zconns;
        my $total_hits;
        return ( "No query entered", undef, undef ) unless $query;

        # Initialize & Search Zebra
        for ( my $i = 0 ; $i < @servers ; $i++ ) {
            eval {
                $zconns[$i] = C4::Context->Zconn( $servers[$i], 1 );
                $tmpresults[$i] =
                  $zconns[$i]
                  ->search( new ZOOM::Query::CCL2RPN( $query, $zconns[$i] ) );

                # error handling
                my $error =
                    $zconns[$i]->errmsg() . " ("
                  . $zconns[$i]->errcode() . ") "
                  . $zconns[$i]->addinfo() . " "
                  . $zconns[$i]->diagset();

                return ( $error, undef, undef ) if $zconns[$i]->errcode();
            };
            if ($@) {

                # caught a ZOOM::Exception
                my $error =
                    $@->message() . " ("
                  . $@->code() . ") "
                  . $@->addinfo() . " "
                  . $@->diagset();
                warn $error;
                return ( $error, undef, undef );
            }
        }
        while ( ( my $i = ZOOM::event( \@zconns ) ) != 0 ) {
            my $event = $zconns[ $i - 1 ]->last_event();
            if ( $event == ZOOM::Event::ZEND ) {

                my $first_record = defined( $offset ) ? $offset+1 : 1;
                my $hits = $tmpresults[ $i - 1 ]->size();
                $total_hits += $hits;
                my $last_record = $hits;
                if ( defined $max_results && $offset + $max_results < $hits ) {
                    $last_record  = $offset + $max_results;
                }

                for my $j ( $first_record..$last_record ) {
                    my $record = $tmpresults[ $i - 1 ]->record( $j-1 )->raw(); # 0 indexed
                    push @results, $record;
                }
            }
        }

        return ( undef, \@results, $total_hits );
    }
}

=head2 getRecords

( undef, $results_hashref, \@facets_loop ) = getRecords (

        $koha_query,       $simple_query, $sort_by_ref,    $servers_ref,
        $results_per_page, $offset,       $expanded_facet, $branches,
        $query_type,       $scan
    );

The all singing, all dancing, multi-server, asynchronous, scanning,
searching, record nabbing, facet-building 

See verbse embedded documentation.

=cut

sub getRecords {
    my (
        $koha_query,       $simple_query, $sort_by_ref,    $servers_ref,
        $results_per_page, $offset,       $expanded_facet, $branches,
        $query_type,       $scan
    ) = @_;

    my @servers = @$servers_ref;
    my @sort_by = @$sort_by_ref;

    # Initialize variables for the ZOOM connection and results object
    my $zconn;
    my @zconns;
    my @results;
    my $results_hashref = ();

    # Initialize variables for the faceted results objects
    my $facets_counter = ();
    my $facets_info    = ();
    my $facets         = getFacets();

    my @facets_loop
      ;    # stores the ref to array of hashes for template facets loop

    ### LOOP THROUGH THE SERVERS
    for ( my $i = 0 ; $i < @servers ; $i++ ) {
        $zconns[$i] = C4::Context->Zconn( $servers[$i], 1 );

# perform the search, create the results objects
# if this is a local search, use the $koha-query, if it's a federated one, use the federated-query
        my $query_to_use = ($servers[$i] =~ /biblioserver/) ? $koha_query : $simple_query;

        #$query_to_use = $simple_query if $scan;
        warn $simple_query if ( $scan and $DEBUG );

        # Check if we've got a query_type defined, if so, use it
        eval {
            if ($query_type)
            {
                if ( $query_type =~ /^ccl/ ) {
                    $query_to_use =~
                      s/\:/\=/g;    # change : to = last minute (FIXME)
                    $results[$i] =
                      $zconns[$i]->search(
                        new ZOOM::Query::CCL2RPN( $query_to_use, $zconns[$i] )
                      );
                }
                elsif ( $query_type =~ /^cql/ ) {
                    $results[$i] =
                      $zconns[$i]->search(
                        new ZOOM::Query::CQL( $query_to_use, $zconns[$i] ) );
                }
                elsif ( $query_type =~ /^pqf/ ) {
                    $results[$i] =
                      $zconns[$i]->search(
                        new ZOOM::Query::PQF( $query_to_use, $zconns[$i] ) );
                }
            }
            else {
                if ($scan) {
                    $results[$i] =
                      $zconns[$i]->scan(
                        new ZOOM::Query::CCL2RPN( $query_to_use, $zconns[$i] )
                      );
                }
                else {
                    $results[$i] =
                      $zconns[$i]->search(
                        new ZOOM::Query::CCL2RPN( $query_to_use, $zconns[$i] )
                      );
                }
            }
        };
        if ($@) {
            warn "WARNING: query problem with $query_to_use " . $@;
        }

        # Concatenate the sort_by limits and pass them to the results object
        # Note: sort will override rank
        my $sort_by;
        foreach my $sort (@sort_by) {
            if ( $sort eq "author_az" ) {
                $sort_by .= "1=1003 <i ";
            }
            elsif ( $sort eq "author_za" ) {
                $sort_by .= "1=1003 >i ";
            }
            elsif ( $sort eq "popularity_asc" ) {
                $sort_by .= "1=9003 <i ";
            }
            elsif ( $sort eq "popularity_dsc" ) {
                $sort_by .= "1=9003 >i ";
            }
            elsif ( $sort eq "call_number_asc" ) {
                $sort_by .= "1=20  <i ";
            }
            elsif ( $sort eq "call_number_dsc" ) {
                $sort_by .= "1=20 >i ";
            }
            elsif ( $sort eq "pubdate_asc" ) {
                $sort_by .= "1=31 <i ";
            }
            elsif ( $sort eq "pubdate_dsc" ) {
                $sort_by .= "1=31 >i ";
            }
            elsif ( $sort eq "acqdate_asc" ) {
                $sort_by .= "1=32 <i ";
            }
            elsif ( $sort eq "acqdate_dsc" ) {
                $sort_by .= "1=32 >i ";
            }
            elsif ( $sort eq "title_az" ) {
                $sort_by .= "1=4 <i ";
            }
            elsif ( $sort eq "title_za" ) {
                $sort_by .= "1=4 >i ";
            }
        }
        if ($sort_by) {
            if ( $results[$i]->sort( "yaz", $sort_by ) < 0 ) {
                warn "WARNING sort $sort_by failed";
            }
        }
    }    # finished looping through servers

    # The big moment: asynchronously retrieve results from all servers
    while ( ( my $i = ZOOM::event( \@zconns ) ) != 0 ) {
        my $ev = $zconns[ $i - 1 ]->last_event();
        if ( $ev == ZOOM::Event::ZEND ) {
            next unless $results[ $i - 1 ];
            my $size = $results[ $i - 1 ]->size();
            if ( $size > 0 ) {
                my $results_hash;

                # loop through the results
                $results_hash->{'hits'} = $size;
                my $times;
                if ( $offset + $results_per_page <= $size ) {
                    $times = $offset + $results_per_page;
                }
                else {
                    $times = $size;
                }
                for ( my $j = $offset ; $j < $times ; $j++ ) {
                    my $records_hash;
                    my $record;
                    my $facet_record;

                    ## Check if it's an index scan
                    if ($scan) {
                        my ( $term, $occ ) = $results[ $i - 1 ]->term($j);

                 # here we create a minimal MARC record and hand it off to the
                 # template just like a normal result ... perhaps not ideal, but
                 # it works for now
                        my $tmprecord = MARC::Record->new();
                        $tmprecord->encoding('UTF-8');
                        my $tmptitle;
                        my $tmpauthor;

                # the minimal record in author/title (depending on MARC flavour)
                        if (C4::Context->preference("marcflavour") eq "UNIMARC") {
                            $tmptitle = MARC::Field->new('200',' ',' ', a => $term, f => $occ);
                            $tmprecord->append_fields($tmptitle);
                        } else {
                            $tmptitle  = MARC::Field->new('245',' ',' ', a => $term,);
                            $tmpauthor = MARC::Field->new('100',' ',' ', a => $occ,);
                            $tmprecord->append_fields($tmptitle);
                            $tmprecord->append_fields($tmpauthor);
                        }
                        $results_hash->{'RECORDS'}[$j] = $tmprecord->as_usmarc();
                    }

                    # not an index scan
                    else {
                        $record = $results[ $i - 1 ]->record($j)->raw();

                        # warn "RECORD $j:".$record;
                        $results_hash->{'RECORDS'}[$j] = $record;

            # Fill the facets while we're looping, but only for the biblioserver
                        $facet_record = MARC::Record->new_from_usmarc($record)
                          if $servers[ $i - 1 ] =~ /biblioserver/;

                    #warn $servers[$i-1]."\n".$record; #.$facet_record->title();
                        if ($facet_record) {
                            for ( my $k = 0 ; $k <= @$facets ; $k++ ) {

                                if ( $facets->[$k] ) {
                                    my @fields;
                                    for my $tag ( @{ $facets->[$k]->{'tags'} } )
                                    {
                                        push @fields,
                                          $facet_record->field($tag);
                                    }
                                    for my $field (@fields) {
                                        my @subfields = $field->subfields();
                                        for my $subfield (@subfields) {
                                            my ( $code, $data ) = @$subfield;
                                            if ( $code eq
                                                $facets->[$k]->{'subfield'} )
                                            {
                                                $facets_counter->{ $facets->[$k]
                                                      ->{'link_value'} }
                                                  ->{$data}++;
                                            }
                                        }
                                    }
                                    $facets_info->{ $facets->[$k]
                                          ->{'link_value'} }->{'label_value'} =
                                      $facets->[$k]->{'label_value'};
                                    $facets_info->{ $facets->[$k]
                                          ->{'link_value'} }->{'expanded'} =
                                      $facets->[$k]->{'expanded'};
                                }
                            }
                        }
                    }
                }
                $results_hashref->{ $servers[ $i - 1 ] } = $results_hash;
            }

            # warn "connection ", $i-1, ": $size hits";
            # warn $results[$i-1]->record(0)->render() if $size > 0;

            # BUILD FACETS
            if ( $servers[ $i - 1 ] =~ /biblioserver/ ) {
                for my $link_value (
                    sort { $facets_counter->{$b} <=> $facets_counter->{$a} }
                    keys %$facets_counter )
                {
                    my $expandable;
                    my $number_of_facets;
                    my @this_facets_array;
                    for my $one_facet (
                        sort {
                            $facets_counter->{$link_value}
                              ->{$b} <=> $facets_counter->{$link_value}->{$a}
                        } keys %{ $facets_counter->{$link_value} }
                      )
                    {
                        $number_of_facets++;
                        if (   ( $number_of_facets < 6 )
                            || ( $expanded_facet eq $link_value )
                            || ( $facets_info->{$link_value}->{'expanded'} ) )
                        {

                      # Sanitize the link value ), ( will cause errors with CCL,
                            my $facet_link_value = $one_facet;
                            $facet_link_value =~ s/(\(|\))/ /g;

                            # fix the length that will display in the label,
                            my $facet_label_value = $one_facet;
                            $facet_label_value =
                              substr( $one_facet, 0, 20 ) . "..."
                              unless length($facet_label_value) <= 20;

                            # if it's a branch, label by the name, not the code,
                            if ( $link_value =~ /branch/ ) {
                                $facet_label_value =
                                  $branches->{$one_facet}->{'branchname'};
                            }

                # but we're down with the whole label being in the link's title.
                            my $facet_title_value = $one_facet;

                            push @this_facets_array,
                              (
                                {
                                    facet_count =>
                                      $facets_counter->{$link_value}
                                      ->{$one_facet},
                                    facet_label_value => $facet_label_value,
                                    facet_title_value => $facet_title_value,
                                    facet_link_value  => $facet_link_value,
                                    type_link_value   => $link_value,
                                },
                              );
                        }
                    }

                    # handle expanded option
                    unless ( $facets_info->{$link_value}->{'expanded'} ) {
                        $expandable = 1
                          if ( ( $number_of_facets > 6 )
                            && ( $expanded_facet ne $link_value ) );
                    }
                    push @facets_loop,
                      (
                        {
                            type_link_value => $link_value,
                            type_id         => $link_value . "_id",
                            type_label =>
                              $facets_info->{$link_value}->{'label_value'},
                            facets     => \@this_facets_array,
                            expandable => $expandable,
                            expand     => $link_value,
                        }
                      );
                }
            }
        }
    }
    return ( undef, $results_hashref, \@facets_loop );
}

sub pazGetRecords {
    my (
        $koha_query,       $simple_query, $sort_by_ref,    $servers_ref,
        $results_per_page, $offset,       $expanded_facet, $branches,
        $query_type,       $scan
    ) = @_;

    my $paz = C4::Search::PazPar2->new(C4::Context->config('pazpar2url'));
    $paz->init();
    $paz->search($simple_query);
    sleep 1;

    # do results
    my $results_hashref = {};
    my $stats = XMLin($paz->stat);
    my $results = XMLin($paz->show($offset, $results_per_page, 'work-title:1'), forcearray => 1);
   
    # for a grouped search result, the number of hits
    # is the number of groups returned; 'bib_hits' will have
    # the total number of bibs. 
    $results_hashref->{'biblioserver'}->{'hits'} = $results->{'merged'}->[0];
    $results_hashref->{'biblioserver'}->{'bib_hits'} = $stats->{'hits'};

    HIT: foreach my $hit (@{ $results->{'hit'} }) {
        my $recid = $hit->{recid}->[0];

        my $work_title = $hit->{'md-work-title'}->[0];
        my $work_author;
        if (exists $hit->{'md-work-author'}) {
            $work_author = $hit->{'md-work-author'}->[0];
        }
        my $group_label = (defined $work_author) ? "$work_title / $work_author" : $work_title;

        my $result_group = {};
        $result_group->{'group_label'} = $group_label;
        $result_group->{'group_merge_key'} = $recid;

        my $count = 1;
        if (exists $hit->{count}) {
            $count = $hit->{count}->[0];
        }
        $result_group->{'group_count'} = $count;

        for (my $i = 0; $i < $count; $i++) {
            # FIXME -- may need to worry about diacritics here
            my $rec = $paz->record($recid, $i);
            push @{ $result_group->{'RECORDS'} }, $rec;
        }

        push @{ $results_hashref->{'biblioserver'}->{'GROUPS'} }, $result_group;
    }
    
    # pass through facets
    my $termlist_xml = $paz->termlist('author,subject');
    my $terms = XMLin($termlist_xml, forcearray => 1);
    my @facets_loop = ();
    #die Dumper($results);
#    foreach my $list (sort keys %{ $terms->{'list'} }) {
#        my @facets = ();
#        foreach my $facet (sort @{ $terms->{'list'}->{$list}->{'term'} } ) {
#            push @facets, {
#                facet_label_value => $facet->{'name'}->[0],
#            };
#        }
#        push @facets_loop, ( {
#            type_label => $list,
#            facets => \@facets,
#        } );
#    }

    return ( undef, $results_hashref, \@facets_loop );
}

# STOPWORDS
sub _remove_stopwords {
    my ( $operand, $index ) = @_;
    my @stopwords_removed;

    # phrase and exact-qualified indexes shouldn't have stopwords removed
    if ( $index !~ m/phr|ext/ ) {

# remove stopwords from operand : parse all stopwords & remove them (case insensitive)
#       we use IsAlpha unicode definition, to deal correctly with diacritics.
#       otherwise, a French word like "leçon" woudl be split into "le" "çon", "le"
#       is a stopword, we'd get "çon" and wouldn't find anything...
        foreach ( keys %{ C4::Context->stopwords } ) {
            next if ( $_ =~ /(and|or|not)/ );    # don't remove operators
            if ( $operand =~
                /(\P{IsAlpha}$_\P{IsAlpha}|^$_\P{IsAlpha}|\P{IsAlpha}$_$)/ )
            {
                $operand =~ s/\P{IsAlpha}$_\P{IsAlpha}/ /gi;
                $operand =~ s/^$_\P{IsAlpha}/ /gi;
                $operand =~ s/\P{IsAlpha}$_$/ /gi;
                push @stopwords_removed, $_;
            }
        }
    }
    return ( $operand, \@stopwords_removed );
}

# TRUNCATION
sub _detect_truncation {
    my ( $operand, $index ) = @_;
    my ( @nontruncated, @righttruncated, @lefttruncated, @rightlefttruncated,
        @regexpr );
    $operand =~ s/^ //g;
    my @wordlist = split( /\s/, $operand );
    foreach my $word (@wordlist) {
        if ( $word =~ s/^\*([^\*]+)\*$/$1/ ) {
            push @rightlefttruncated, $word;
        }
        elsif ( $word =~ s/^\*([^\*]+)$/$1/ ) {
            push @lefttruncated, $word;
        }
        elsif ( $word =~ s/^([^\*]+)\*$/$1/ ) {
            push @righttruncated, $word;
        }
        elsif ( index( $word, "*" ) < 0 ) {
            push @nontruncated, $word;
        }
        else {
            push @regexpr, $word;
        }
    }
    return (
        \@nontruncated,       \@righttruncated, \@lefttruncated,
        \@rightlefttruncated, \@regexpr
    );
}

# STEMMING
sub _build_stemmed_operand {
    my ($operand) = @_;
    my $stemmed_operand;

# FIXME: the locale should be set based on the user's language and/or search choice
    my $stemmer = Lingua::Stem->new( -locale => 'EN-US' );

# FIXME: these should be stored in the db so the librarian can modify the behavior
    $stemmer->add_exceptions(
        {
            'and' => 'and',
            'or'  => 'or',
            'not' => 'not',
        }
    );
    my @words = split( / /, $operand );
    my $stems = $stemmer->stem(@words);
    for my $stem (@$stems) {
        $stemmed_operand .= "$stem";
        $stemmed_operand .= "?"
          unless ( $stem =~ /(and$|or$|not$)/ ) || ( length($stem) < 3 );
        $stemmed_operand .= " ";
    }
    warn "STEMMED OPERAND: $stemmed_operand" if $DEBUG;
    return $stemmed_operand;
}

# FIELD WEIGHTING
sub _build_weighted_query {

# FIELD WEIGHTING - This is largely experimental stuff. What I'm committing works
# pretty well but could work much better if we had a smarter query parser
    my ( $operand, $stemmed_operand, $index ) = @_;
    my $stemming      = C4::Context->preference("QueryStemming")     || 0;
    my $weight_fields = C4::Context->preference("QueryWeightFields") || 0;
    my $fuzzy_enabled = C4::Context->preference("QueryFuzzy")        || 0;

    my $weighted_query .= "(rk=(";    # Specifies that we're applying rank

    # Keyword, or, no index specified
    if ( ( $index eq 'kw' ) || ( !$index ) ) {
        $weighted_query .=
          "Title-cover,ext,r1=\"$operand\"";    # exact title-cover
        $weighted_query .= " or ti,ext,r2=\"$operand\"";    # exact title
        $weighted_query .= " or ti,phr,r3=\"$operand\"";    # phrase title
          #$weighted_query .= " or any,ext,r4=$operand";               # exact any
          #$weighted_query .=" or kw,wrdl,r5=\"$operand\"";            # word list any
        $weighted_query .= " or wrdl,fuzzy,r8=\"$operand\""
          if $fuzzy_enabled;    # add fuzzy, word list
        $weighted_query .= " or wrdl,right-Truncation,r9=\"$stemmed_operand\""
          if ( $stemming and $stemmed_operand )
          ;                     # add stemming, right truncation
        $weighted_query .= " or wrdl,r9=\"$operand\"";

        # embedded sorting: 0 a-z; 1 z-a
        # $weighted_query .= ") or (sort1,aut=1";
    }

    # Barcode searches should skip this process
    elsif ( $index eq 'bc' ) {
        $weighted_query .= "bc=\"$operand\"";
    }

    # Authority-number searches should skip this process
    elsif ( $index eq 'an' ) {
        $weighted_query .= "an=\"$operand\"";
    }

    # If the index already has more than one qualifier, wrap the operand
    # in quotes and pass it back (assumption is that the user knows what they
    # are doing and won't appreciate us mucking up their query
    elsif ( $index =~ ',' ) {
        $weighted_query .= " $index=\"$operand\"";
    }

    #TODO: build better cases based on specific search indexes
    else {
        $weighted_query .= " $index,ext,r1=\"$operand\"";    # exact index
          #$weighted_query .= " or (title-sort-az=0 or $index,startswithnt,st-word,r3=$operand #)";
        $weighted_query .= " or $index,phr,r3=\"$operand\"";    # phrase index
        $weighted_query .=
          " or $index,rt,wrdl,r3=\"$operand\"";    # word list index
    }

    $weighted_query .= "))";                       # close rank specification
    return $weighted_query;
}

=head2 buildQuery

( $error, $query,
$simple_query, $query_cgi,
$query_desc, $limit,
$limit_cgi, $limit_desc,
$stopwords_removed, $query_type ) = getRecords ( $operators, $operands, $indexes, $limits, $sort_by, $scan);

Build queries and limits in CCL, CGI, Human,
handle truncation, stemming, field weighting, stopwords, fuzziness, etc.

See verbose embedded documentation.


=cut

sub buildQuery {
    my ( $operators, $operands, $indexes, $limits, $sort_by, $scan ) = @_;

    warn "---------\nEnter buildQuery\n---------" if $DEBUG;

    # dereference
    my @operators = @$operators if $operators;
    my @indexes   = @$indexes   if $indexes;
    my @operands  = @$operands  if $operands;
    my @limits    = @$limits    if $limits;
    my @sort_by   = @$sort_by   if $sort_by;

    my $stemming         = C4::Context->preference("QueryStemming")        || 0;
    my $auto_truncation  = C4::Context->preference("QueryAutoTruncate")    || 0;
    my $weight_fields    = C4::Context->preference("QueryWeightFields")    || 0;
    my $fuzzy_enabled    = C4::Context->preference("QueryFuzzy")           || 0;
    my $remove_stopwords = C4::Context->preference("QueryRemoveStopwords") || 0;

    # no stemming/weight/fuzzy in NoZebra
    if ( C4::Context->preference("NoZebra") ) {
        $stemming      = 0;
        $weight_fields = 0;
        $fuzzy_enabled = 0;
    }

    my $query        = $operands[0];
    my $simple_query = $operands[0];

    # initialize the variables we're passing back
    my $query_cgi;
    my $query_desc;
    my $query_type;

    my $limit;
    my $limit_cgi;
    my $limit_desc;

    my $stopwords_removed;    # flag to determine if stopwords have been removed

# for handling ccl, cql, pqf queries in diagnostic mode, skip the rest of the steps
# DIAGNOSTIC ONLY!!
    if ( $query =~ /^ccl=/ ) {
        return ( undef, $', $', $', $', '', '', '', '', 'ccl' );
    }
    if ( $query =~ /^cql=/ ) {
        return ( undef, $', $', $', $', '', '', '', '', 'cql' );
    }
    if ( $query =~ /^pqf=/ ) {
        return ( undef, $', $', $', $', '', '', '', '', 'pqf' );
    }

    # pass nested queries directly
    # FIXME: need better handling of some of these variables in this case
    if ( $query =~ /(\(|\))/ ) {
        return (
            undef,              $query, $simple_query, $query_cgi,
            $query,             $limit, $limit_cgi,    $limit_desc,
            $stopwords_removed, 'ccl'
        );
    }

# Form-based queries are non-nested and fixed depth, so we can easily modify the incoming
# query operands and indexes and add stemming, truncation, field weighting, etc.
# Once we do so, we'll end up with a value in $query, just like if we had an
# incoming $query from the user
    else {
        $query = ""
          ; # clear it out so we can populate properly with field-weighted, stemmed, etc. query
        my $previous_operand
          ;    # a flag used to keep track if there was a previous query
               # if there was, we can apply the current operator
               # for every operand
        for ( my $i = 0 ; $i <= @operands ; $i++ ) {

            # COMBINE OPERANDS, INDEXES AND OPERATORS
            if ( $operands[$i] ) {

              # A flag to determine whether or not to add the index to the query
                my $indexes_set;

# If the user is sophisticated enough to specify an index, turn off field weighting, stemming, and stopword handling
                if ( $operands[$i] =~ /(:|=)/ || $scan ) {
                    $weight_fields    = 0;
                    $stemming         = 0;
                    $remove_stopwords = 0;
                }
                my $operand = $operands[$i];
                my $index   = $indexes[$i];

                # Add index-specific attributes
                # Date of Publication
                if ( $index eq 'yr' ) {
                    $index .= ",st-numeric";
                    $indexes_set++;
					$stemming = $auto_truncation = $weight_fields = $fuzzy_enabled = $remove_stopwords = 0;
                }

                # Date of Acquisition
                elsif ( $index eq 'acqdate' ) {
                    $index .= ",st-date-normalized";
                    $indexes_set++;
					$stemming = $auto_truncation = $weight_fields = $fuzzy_enabled = $remove_stopwords = 0;
                }
                # ISBN,ISSN,Standard Number, don't need special treatment
                elsif ( $index eq 'nb' || $index eq 'ns' ) {
                    $indexes_set++;
                    (   
                        $stemming,      $auto_truncation,
                        $weight_fields, $fuzzy_enabled,
                        $remove_stopwords
                    ) = ( 0, 0, 0, 0, 0 );

                }
                # Set default structure attribute (word list)
                my $struct_attr;
                unless ( $indexes_set || !$index || $index =~ /(st-|phr|ext|wrdl)/ ) {
                    $struct_attr = ",wrdl";
                }

                # Some helpful index variants
                my $index_plus       = $index . $struct_attr . ":" if $index;
                my $index_plus_comma = $index . $struct_attr . "," if $index;

                # Remove Stopwords
                if ($remove_stopwords) {
                    ( $operand, $stopwords_removed ) =
                      _remove_stopwords( $operand, $index );
                    warn "OPERAND w/out STOPWORDS: >$operand<" if $DEBUG;
                    warn "REMOVED STOPWORDS: @$stopwords_removed"
                      if ( $stopwords_removed && $DEBUG );
                }

                # Detect Truncation
                my ( $nontruncated, $righttruncated, $lefttruncated,
                    $rightlefttruncated, $regexpr );
                my $truncated_operand;
                (
                    $nontruncated, $righttruncated, $lefttruncated,
                    $rightlefttruncated, $regexpr
                ) = _detect_truncation( $operand, $index );
                warn
"TRUNCATION: NON:>@$nontruncated< RIGHT:>@$righttruncated< LEFT:>@$lefttruncated< RIGHTLEFT:>@$rightlefttruncated< REGEX:>@$regexpr<"
                  if $DEBUG;

                # Apply Truncation
                if (
                    scalar(@$righttruncated) + scalar(@$lefttruncated) +
                    scalar(@$rightlefttruncated) > 0 )
                {

               # Don't field weight or add the index to the query, we do it here
                    $indexes_set = 1;
                    undef $weight_fields;
                    my $previous_truncation_operand;
                    if ( scalar(@$nontruncated) > 0 ) {
                        $truncated_operand .= "$index_plus @$nontruncated ";
                        $previous_truncation_operand = 1;
                    }
                    if ( scalar(@$righttruncated) > 0 ) {
                        $truncated_operand .= "and "
                          if $previous_truncation_operand;
                        $truncated_operand .=
                          "$index_plus_comma" . "rtrn:@$righttruncated ";
                        $previous_truncation_operand = 1;
                    }
                    if ( scalar(@$lefttruncated) > 0 ) {
                        $truncated_operand .= "and "
                          if $previous_truncation_operand;
                        $truncated_operand .=
                          "$index_plus_comma" . "ltrn:@$lefttruncated ";
                        $previous_truncation_operand = 1;
                    }
                    if ( scalar(@$rightlefttruncated) > 0 ) {
                        $truncated_operand .= "and "
                          if $previous_truncation_operand;
                        $truncated_operand .=
                          "$index_plus_comma" . "rltrn:@$rightlefttruncated ";
                        $previous_truncation_operand = 1;
                    }
                }
                $operand = $truncated_operand if $truncated_operand;
                warn "TRUNCATED OPERAND: >$truncated_operand<" if $DEBUG;

                # Handle Stemming
                my $stemmed_operand;
                $stemmed_operand = _build_stemmed_operand($operand)
                  if $stemming;
                warn "STEMMED OPERAND: >$stemmed_operand<" if $DEBUG;

                # Handle Field Weighting
                my $weighted_operand;
                $weighted_operand =
                  _build_weighted_query( $operand, $stemmed_operand, $index )
                  if $weight_fields;
                warn "FIELD WEIGHTED OPERAND: >$weighted_operand<" if $DEBUG;
                $operand = $weighted_operand if $weight_fields;
                $indexes_set = 1 if $weight_fields;

                # If there's a previous operand, we need to add an operator
                if ($previous_operand) {

                    # User-specified operator
                    if ( $operators[ $i - 1 ] ) {
                        $query     .= " $operators[$i-1] ";
                        $query     .= " $index_plus " unless $indexes_set;
                        $query     .= " $operand";
                        $query_cgi .= "&op=$operators[$i-1]";
                        $query_cgi .= "&idx=$index" if $index;
                        $query_cgi .= "&q=$operands[$i]" if $operands[$i];
                        $query_desc .=
                          " $operators[$i-1] $index_plus $operands[$i]";
                    }

                    # Default operator is and
                    else {
                        $query      .= " and ";
                        $query      .= "$index_plus " unless $indexes_set;
                        $query      .= "$operand";
                        $query_cgi  .= "&op=and&idx=$index" if $index;
                        $query_cgi  .= "&q=$operands[$i]" if $operands[$i];
                        $query_desc .= " and $index_plus $operands[$i]";
                    }
                }

                # There isn't a pervious operand, don't need an operator
                else {

                    # Field-weighted queries already have indexes set
                    $query .= " $index_plus " unless $indexes_set;
                    $query .= $operand;
                    $query_desc .= " $index_plus $operands[$i]";
                    $query_cgi  .= "&idx=$index" if $index;
                    $query_cgi  .= "&q=$operands[$i]" if $operands[$i];
                    $previous_operand = 1;
                }
            }    #/if $operands
        }    # /for
    }
    warn "QUERY BEFORE LIMITS: >$query<" if $DEBUG;

    # add limits
    my $group_OR_limits;
    my $availability_limit;
    foreach my $this_limit (@limits) {
        if ( $this_limit =~ /available/ ) {

# 'available' is defined as (items.onloan is NULL) and (items.itemlost = 0)
# In English:
# all records not indexed in the onloan register (zebra) and all records with a value of lost equal to 0
            $availability_limit .=
"( ( allrecords,AlwaysMatches='' not onloan,AlwaysMatches='') and (lost,st-numeric=0) )"; #or ( allrecords,AlwaysMatches='' not lost,AlwaysMatches='')) )";
            $limit_cgi  .= "&limit=available";
            $limit_desc .= "";
        }

        # group_OR_limits, prefixed by mc-
        # OR every member of the group
        elsif ( $this_limit =~ /mc/ ) {
            $group_OR_limits .= " or " if $group_OR_limits;
            $limit_desc      .= " or " if $group_OR_limits;
            $group_OR_limits .= "$this_limit";
            $limit_cgi       .= "&limit=$this_limit";
            $limit_desc      .= " $this_limit";
        }

        # Regular old limits
        else {
            $limit .= " and " if $limit || $query;
            $limit      .= "$this_limit";
            $limit_cgi  .= "&limit=$this_limit";
            $limit_desc .= " $this_limit";
        }
    }
    if ($group_OR_limits) {
        $limit .= " and " if ( $query || $limit );
        $limit .= "($group_OR_limits)";
    }
    if ($availability_limit) {
        $limit .= " and " if ( $query || $limit );
        $limit .= "($availability_limit)";
    }

    # Normalize the query and limit strings
    $query =~ s/:/=/g;
    $limit =~ s/:/=/g;
    for ( $query, $query_desc, $limit, $limit_desc ) {
        $_ =~ s/  / /g;    # remove extra spaces
        $_ =~ s/^ //g;     # remove any beginning spaces
        $_ =~ s/ $//g;     # remove any ending spaces
        $_ =~ s/==/=/g;    # remove double == from query
    }
    $query_cgi =~ s/^&//; # remove unnecessary & from beginning of the query cgi

    for ($query_cgi,$simple_query) {
        $_ =~ s/"//g;
    }
    # append the limit to the query
    $query .= " " . $limit;

    # Warnings if DEBUG
    if ($DEBUG) {
        warn "QUERY:" . $query;
        warn "QUERY CGI:" . $query_cgi;
        warn "QUERY DESC:" . $query_desc;
        warn "LIMIT:" . $limit;
        warn "LIMIT CGI:" . $limit_cgi;
        warn "LIMIT DESC:" . $limit_desc;
        warn "---------\nLeave buildQuery\n---------";
    }
    return (
        undef,              $query, $simple_query, $query_cgi,
        $query_desc,        $limit, $limit_cgi,    $limit_desc,
        $stopwords_removed, $query_type
    );
}

=head2 searchResults

Format results in a form suitable for passing to the template

=cut

# IMO this subroutine is pretty messy still -- it's responsible for
# building the HTML output for the template
sub searchResults {
    my ( $searchdesc, $hits, $results_per_page, $offset, @marcresults ) = @_;
    my $dbh = C4::Context->dbh;
    my $even = 1;
    my @newresults;

    # add search-term highlighting via <span>s on the search terms
    my $span_terms_hashref;
    for my $span_term ( split( / /, $searchdesc ) ) {
        $span_term =~ s/(.*=|\)|\(|\+|\.|\*)//g;
        $span_terms_hashref->{$span_term}++;
    }

    #Build branchnames hash
    #find branchname
    #get branch information.....
    my %branches;
    my $bsth =
      $dbh->prepare("SELECT branchcode,branchname FROM branches")
      ;    # FIXME : use C4::Koha::GetBranches
    $bsth->execute();
    while ( my $bdata = $bsth->fetchrow_hashref ) {
        $branches{ $bdata->{'branchcode'} } = $bdata->{'branchname'};
    }
# FIXME - We build an authorised values hash here, using the default framework
# though it is possible to have different authvals for different fws.

    my $shelflocations =GetKohaAuthorisedValues('items.location','');

    # get notforloan authorised value list (see $shelflocations  FIXME)
    my $notforloan_authorised_value = GetAuthValCode('items.notforloan','');

    #Build itemtype hash
    #find itemtype & itemtype image
    my %itemtypes;
    $bsth =
      $dbh->prepare(
        "SELECT itemtype,description,imageurl,summary,notforloan FROM itemtypes"
      );
    $bsth->execute();
    while ( my $bdata = $bsth->fetchrow_hashref ) {
		foreach (qw(description imageurl summary notforloan)) {
        	$itemtypes{ $bdata->{'itemtype'} }->{$_} = $bdata->{$_};
		}
    }

    #search item field code
    my $sth =
      $dbh->prepare(
"SELECT tagfield FROM marc_subfield_structure WHERE kohafield LIKE 'items.itemnumber'"
      );
    $sth->execute;
    my ($itemtag) = $sth->fetchrow;

    ## find column names of items related to MARC
    my $sth2 = $dbh->prepare("SHOW COLUMNS FROM items");
    $sth2->execute;
    my %subfieldstosearch;
    while ( ( my $column ) = $sth2->fetchrow ) {
        my ( $tagfield, $tagsubfield ) =
          &GetMarcFromKohaField( "items." . $column, "" );
        $subfieldstosearch{$column} = $tagsubfield;
    }

    # handle which records to actually retrieve
    my $times;
    if ( $hits && $offset + $results_per_page <= $hits ) {
        $times = $offset + $results_per_page;
    }
    else {
        $times = $hits;	 # FIXME: if $hits is undefined, why do we want to equal it?
    }

    # loop through all of the records we've retrieved
    for ( my $i = $offset ; $i <= $times - 1 ; $i++ ) {
        my $marcrecord = MARC::File::USMARC::decode( $marcresults[$i] );
        my $oldbiblio = TransformMarcToKoha( $dbh, $marcrecord, '' );
        $oldbiblio->{result_number} = $i + 1;

        # add imageurl to itemtype if there is one
        if ( $itemtypes{ $oldbiblio->{itemtype} }->{imageurl} =~ /^http:/ ) {
            $oldbiblio->{imageurl} =
              $itemtypes{ $oldbiblio->{itemtype} }->{imageurl};
        } else {
            $oldbiblio->{imageurl} =
              getitemtypeimagesrc() . "/"
              . $itemtypes{ $oldbiblio->{itemtype} }->{imageurl}
              if ( $itemtypes{ $oldbiblio->{itemtype} }->{imageurl} );
        }
        my $aisbn = $oldbiblio->{'isbn'};
        $aisbn =~ /(\d*[X]*)/;
        $oldbiblio->{amazonisbn} = $1;
		$oldbiblio->{description} = $itemtypes{ $oldbiblio->{itemtype} }->{description};
 # Build summary if there is one (the summary is defined in the itemtypes table)
 # FIXME: is this used anywhere, I think it can be commented out? -- JF
        if ( $itemtypes{ $oldbiblio->{itemtype} }->{summary} ) {
            my $summary = $itemtypes{ $oldbiblio->{itemtype} }->{summary};
            my @fields  = $marcrecord->fields();
            foreach my $field (@fields) {
                my $tag      = $field->tag();
                my $tagvalue = $field->as_string();
                $summary =~
                  s/\[(.?.?.?.?)$tag\*(.*?)]/$1$tagvalue$2\[$1$tag$2]/g;
                unless ( $tag < 10 ) {
                    my @subf = $field->subfields;
                    for my $i ( 0 .. $#subf ) {
                        my $subfieldcode  = $subf[$i][0];
                        my $subfieldvalue = $subf[$i][1];
                        my $tagsubf       = $tag . $subfieldcode;
                        $summary =~
s/\[(.?.?.?.?)$tagsubf(.*?)]/$1$subfieldvalue$2\[$1$tagsubf$2]/g;
                    }
                }
            }
            # FIXME: yuk
            $summary =~ s/\[(.*?)]//g;
            $summary =~ s/\n/<br\/>/g;
            $oldbiblio->{summary} = $summary;
        }

        # save an author with no <span> tag, for the <a href=search.pl?q=<!--tmpl_var name="author"-->> link
        $oldbiblio->{'author_nospan'} = $oldbiblio->{'author'};
        $oldbiblio->{'title_nospan'} = $oldbiblio->{'title'};
        # Add search-term highlighting to the whole record where they match using <span>s
        if (C4::Context->preference("OpacHighlightedWords")){
            my $searchhighlightblob;
            for my $highlight_field ( $marcrecord->fields ) {
    
    # FIXME: need to skip title, subtitle, author, etc., as they are handled below
                next if $highlight_field->tag() =~ /(^00)/;    # skip fixed fields
                for my $subfield ($highlight_field->subfields()) {
                    my $match;
                    next if $subfield->[0] eq '9';
                    my $field = $subfield->[1];
                    for my $term ( keys %$span_terms_hashref ) {
                        if ( ( $field =~ /$term/i ) && (( length($term) > 3 ) || ($field =~ / $term /i)) ) {
                            $field =~ s/$term/<span class=\"term\">$&<\/span>/gi;
                        $match++;
                        }
                    }
                    $searchhighlightblob .= $field . " ... " if $match;
                }
    
            }
            $searchhighlightblob = ' ... '.$searchhighlightblob if $searchhighlightblob;
            $oldbiblio->{'searchhighlightblob'} = $searchhighlightblob;
        }

        # Add search-term highlighting to the title, subtitle, etc. fields
        for my $term ( keys %$span_terms_hashref ) {
            my $old_term = $term;
            if ( length($term) > 3 ) {
                $term =~ s/(.*=|\)|\(|\+|\.|\?|\[|\]|\\|\*)//g;
				foreach(qw(title subtitle author publishercode place pages notes size)) {
                	$oldbiblio->{$_} =~ s/$term/<span class=\"term\">$&<\/span>/gi;
				}
            }
        }

        ($i % 2) and $oldbiblio->{'toggle'} = 1;

        # Pull out the items fields
        my @fields = $marcrecord->field($itemtag);

        # Setting item statuses for display
        my @available_items_loop;
        my @onloan_items_loop;
        my @other_items_loop;

        my $available_items;
        my $onloan_items;
        my $other_items;

        my $ordered_count     = 0;
        my $available_count   = 0;
        my $onloan_count      = 0;
        my $longoverdue_count = 0;
        my $other_count       = 0;
        my $wthdrawn_count    = 0;
        my $itemlost_count    = 0;
        my $itembinding_count = 0;
        my $itemdamaged_count = 0;
        my $can_place_holds   = 0;
        my $items_count       = scalar(@fields);
        my $items_counter;
        my $maxitems =
          ( C4::Context->preference('maxItemsinSearchResults') )
          ? C4::Context->preference('maxItemsinSearchResults') - 1
          : 1;

        # loop through every item
        foreach my $field (@fields) {
            my $item;
            $items_counter++;

            # populate the items hash
            foreach my $code ( keys %subfieldstosearch ) {
                $item->{$code} = $field->subfield( $subfieldstosearch{$code} );
            }
			my $hbranch     = C4::Context->preference('HomeOrHoldingBranch') eq 'homebranch' ? 'homebranch'    : 'holdingbranch';
			my $otherbranch = C4::Context->preference('HomeOrHoldingBranch') eq 'homebranch' ? 'holdingbranch' : 'homebranch';
            # set item's branch name, use HomeOrHoldingBranch syspref first, fall back to the other one
            if ($item->{$hbranch}) {
                $item->{'branchname'} = $branches{$item->{$hbranch}};
            }
            elsif ($item->{$otherbranch}) {	# Last resort
                $item->{'branchname'} = $branches{$item->{$otherbranch}}; 
            }

			my $prefix = $item->{$hbranch} . '--' . $item->{location} . $item->{itype} . $item->{itemcallnumber};
# For each grouping of items (onloan, available, unavailable), we build a key to store relevant info about that item
            if ( $item->{onloan} ) {
                $onloan_count++;
				my $key = $prefix . $item->{due_date};
				$onloan_items->{$key}->{due_date} = format_date($item->{onloan});
				$onloan_items->{$key}->{count}++ if $item->{homebranch};
				$onloan_items->{$key}->{branchname} = $item->{branchname};
				$onloan_items->{$key}->{location} = $shelflocations->{ $item->{location} };
				$onloan_items->{$key}->{itemcallnumber} = $item->{itemcallnumber};
				$onloan_items->{$key}->{imageurl} = getitemtypeimagesrc() . "/" . $itemtypes{ $item->{itype} }->{imageurl};
                # if something's checked out and lost, mark it as 'long overdue'
                if ( $item->{itemlost} ) {
                    $onloan_items->{$prefix}->{longoverdue}++;
                    $longoverdue_count++;
                } else {	# can place holds as long as item isn't lost
                    $can_place_holds = 1;
                }
            }

         # items not on loan, but still unavailable ( lost, withdrawn, damaged )
            else {

                # item is on order
                if ( $item->{notforloan} == -1 ) {
                    $ordered_count++;
                }

                # item is withdrawn, lost or damaged
                if (   $item->{wthdrawn}
                    || $item->{itemlost}
                    || $item->{damaged}
                    || $item->{notforloan} )
                {
                    $wthdrawn_count++    if $item->{wthdrawn};
                    $itemlost_count++    if $item->{itemlost};
                    $itemdamaged_count++ if $item->{damaged};
                    $item->{status} = $item->{wthdrawn} . "-" . $item->{itemlost} . "-" . $item->{damaged} . "-" . $item->{notforloan};
                    $other_count++;

					my $key = $prefix . $item->{status};
					foreach (qw(wthdrawn itemlost damaged branchname itemcallnumber)) {
                    	$other_items->{$key}->{$_} = $item->{$_};
					}
					$other_items->{$key}->{notforloan} = GetAuthorisedValueDesc('','',$item->{notforloan},'','',$notforloan_authorised_value) if $notforloan_authorised_value;
					$other_items->{$key}->{count}++ if $item->{homebranch};
					$other_items->{$key}->{location} = $shelflocations->{ $item->{location} };
					$other_items->{$key}->{imageurl} = getitemtypeimagesrc() . "/" . $itemtypes{ $item->{itype} }->{imageurl};
                }
                # item is available
                else {
                    $can_place_holds = 1;
                    $available_count++;
					$available_items->{$prefix}->{count}++ if $item->{homebranch};
					foreach (qw(branchname itemcallnumber)) {
                    	$available_items->{$prefix}->{$_} = $item->{$_};
					}
					$available_items->{$prefix}->{location} = $shelflocations->{ $item->{location} };
					$available_items->{$prefix}->{imageurl} = getitemtypeimagesrc() . "/" . $itemtypes{ $item->{itype} }->{imageurl};
                }
            }
        }    # notforloan, item level and biblioitem level
        my ( $availableitemscount, $onloanitemscount, $otheritemscount );
        $maxitems =
          ( C4::Context->preference('maxItemsinSearchResults') )
          ? C4::Context->preference('maxItemsinSearchResults') - 1
          : 1;
        for my $key ( sort keys %$onloan_items ) {
            (++$onloanitemscount > $maxitems) and last;
            push @onloan_items_loop, $onloan_items->{$key};
        }
        for my $key ( sort keys %$other_items ) {
            (++$otheritemscount > $maxitems) and last;
            push @other_items_loop, $other_items->{$key};
        }
        for my $key ( sort keys %$available_items ) {
            (++$availableitemscount > $maxitems) and last;
            push @available_items_loop, $available_items->{$key}
        }

        # XSLT processing of some stuff
        if (C4::Context->preference("XSLTResultsDisplay") ) {
            my $newxmlrecord = XSLTParse4Display($oldbiblio->{biblionumber},C4::Context->config('opachtdocs')."/prog/en/xslt/MARC21slim2OPACResults.xsl");
            $oldbiblio->{XSLTResultsRecord} = $newxmlrecord;
        }

        # last check for norequest : if itemtype is notforloan, it can't be reserved either, whatever the items
        $can_place_holds = 0
          if $itemtypes{ $oldbiblio->{itemtype} }->{notforloan};
        $oldbiblio->{norequests} = 1 unless $can_place_holds;
        $oldbiblio->{itemsplural}          = 1 if $items_count > 1;
        $oldbiblio->{items_count}          = $items_count;
        $oldbiblio->{available_items_loop} = \@available_items_loop;
        $oldbiblio->{onloan_items_loop}    = \@onloan_items_loop;
        $oldbiblio->{other_items_loop}     = \@other_items_loop;
        $oldbiblio->{availablecount}       = $available_count;
        $oldbiblio->{availableplural}      = 1 if $available_count > 1;
        $oldbiblio->{onloancount}          = $onloan_count;
        $oldbiblio->{onloanplural}         = 1 if $onloan_count > 1;
        $oldbiblio->{othercount}           = $other_count;
        $oldbiblio->{otherplural}          = 1 if $other_count > 1;
        $oldbiblio->{wthdrawncount}        = $wthdrawn_count;
        $oldbiblio->{itemlostcount}        = $itemlost_count;
        $oldbiblio->{damagedcount}         = $itemdamaged_count;
        $oldbiblio->{orderedcount}         = $ordered_count;
        $oldbiblio->{isbn} =~
          s/-//g;    # deleting - in isbn to enable amazon content
        $oldbiblio->{'authorised_value_images'}  = C4::Items::get_authorised_value_images( C4::Biblio::get_biblio_authorised_values( $oldbiblio->{'biblionumber'} ) );
        push( @newresults, $oldbiblio );
    }
    return @newresults;
}

#----------------------------------------------------------------------
#
# Non-Zebra GetRecords#
#----------------------------------------------------------------------

=head2 NZgetRecords

  NZgetRecords has the same API as zera getRecords, even if some parameters are not managed

=cut

sub NZgetRecords {
    my (
        $query,            $simple_query, $sort_by_ref,    $servers_ref,
        $results_per_page, $offset,       $expanded_facet, $branches,
        $query_type,       $scan
    ) = @_;
    warn "query =$query" if $DEBUG;
    my $result = NZanalyse($query);
    warn "results =$result" if $DEBUG;
    return ( undef,
        NZorder( $result, @$sort_by_ref[0], $results_per_page, $offset ),
        undef );
}

=head2 NZanalyse

  NZanalyse : get a CQL string as parameter, and returns a list of biblionumber;title,biblionumber;title,...
  the list is built from an inverted index in the nozebra SQL table
  note that title is here only for convenience : the sorting will be very fast when requested on title
  if the sorting is requested on something else, we will have to reread all results, and that may be longer.

=cut

sub NZanalyse {
    my ( $string, $server ) = @_;
#     warn "---------"       if $DEBUG;
    warn " NZanalyse" if $DEBUG;
#     warn "---------"       if $DEBUG;

 # $server contains biblioserver or authorities, depending on what we search on.
 #warn "querying : $string on $server";
    $server = 'biblioserver' unless $server;

# if we have a ", replace the content to discard temporarily any and/or/not inside
    my $commacontent;
    if ( $string =~ /"/ ) {
        $string =~ s/"(.*?)"/__X__/;
        $commacontent = $1;
        warn "commacontent : $commacontent" if $DEBUG;
    }

# split the query string in 3 parts : X AND Y means : $left="X", $operand="AND" and $right="Y"
# then, call again NZanalyse with $left and $right
# (recursive until we find a leaf (=> something without and/or/not)
# delete repeated operator... Would then go in infinite loop
    while ( $string =~ s/( and| or| not| AND| OR| NOT)\1/$1/g ) {
    }

    #process parenthesis before.
    if ( $string =~ /^\s*\((.*)\)(( and | or | not | AND | OR | NOT )(.*))?/ ) {
        my $left     = $1;
        my $right    = $4;
        my $operator = lc($3);   # FIXME: and/or/not are operators, not operands
        warn
"dealing w/parenthesis before recursive sub call. left :$left operator:$operator right:$right"
          if $DEBUG;
        my $leftresult = NZanalyse( $left, $server );
        if ($operator) {
            my $rightresult = NZanalyse( $right, $server );

            # OK, we have the results for right and left part of the query
            # depending of operand, intersect, union or exclude both lists
            # to get a result list
            if ( $operator eq ' and ' ) {
                return NZoperatorAND($leftresult,$rightresult);      
            }
            elsif ( $operator eq ' or ' ) {

                # just merge the 2 strings
                return $leftresult . $rightresult;
            }
            elsif ( $operator eq ' not ' ) {
                return NZoperatorNOT($leftresult,$rightresult);      
            }
        }      
        else {
# this error is impossible, because of the regexp that isolate the operand, but just in case...
            return $leftresult;
        } 
    }
    warn "string :" . $string if $DEBUG;
    $string =~ /(.*?)( and | or | not | AND | OR | NOT )(.*)/;
    my $left     = $1;
    my $right    = $3;
    my $operator = lc($2);    # FIXME: and/or/not are operators, not operands
    warn "no parenthesis. left : $left operator: $operator right: $right"
      if $DEBUG;

    # it's not a leaf, we have a and/or/not
    if ($operator) {

        # reintroduce comma content if needed
        $right =~ s/__X__/"$commacontent"/ if $commacontent;
        $left  =~ s/__X__/"$commacontent"/ if $commacontent;
        warn "node : $left / $operator / $right\n" if $DEBUG;
        my $leftresult  = NZanalyse( $left,  $server );
        my $rightresult = NZanalyse( $right, $server );
        warn " leftresult : $leftresult" if $DEBUG;
        warn " rightresult : $rightresult" if $DEBUG;
        # OK, we have the results for right and left part of the query
        # depending of operand, intersect, union or exclude both lists
        # to get a result list
        if ( $operator eq ' and ' ) {
            warn "NZAND";
            return NZoperatorAND($leftresult,$rightresult);
        }
        elsif ( $operator eq ' or ' ) {

            # just merge the 2 strings
            return $leftresult . $rightresult;
        }
        elsif ( $operator eq ' not ' ) {
            return NZoperatorNOT($leftresult,$rightresult);
        }
        else {

# this error is impossible, because of the regexp that isolate the operand, but just in case...
            die "error : operand unknown : $operator for $string";
        }

        # it's a leaf, do the real SQL query and return the result
    }
    else {
        $string =~ s/__X__/"$commacontent"/ if $commacontent;
        $string =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|&|\+|\*|\// /g;
        #remove trailing blank at the beginning
        $string =~ s/^ //g;
        warn "leaf:$string" if $DEBUG;

        # parse the string in in operator/operand/value again
        $string =~ /(.*)(>=|<=)(.*)/;
        my $left     = $1;
        my $operator = $2;
        my $right    = $3;
#         warn "handling leaf... left:$left operator:$operator right:$right"
#           if $DEBUG;
        unless ($operator) {
            $string =~ /(.*)(>|<|=)(.*)/;
            $left     = $1;
            $operator = $2;
            $right    = $3;
            warn
"handling unless (operator)... left:$left operator:$operator right:$right"
              if $DEBUG;
        }
        my $results;

# strip adv, zebra keywords, currently not handled in nozebra: wrdl, ext, phr...
        $left =~ s/ .*$//;

        # automatic replace for short operators
        $left = 'title'            if $left =~ '^ti$';
        $left = 'author'           if $left =~ '^au$';
        $left = 'publisher'        if $left =~ '^pb$';
        $left = 'subject'          if $left =~ '^su$';
        $left = 'koha-Auth-Number' if $left =~ '^an$';
        $left = 'keyword'          if $left =~ '^kw$';
        warn "handling leaf... left:$left operator:$operator right:$right" if $DEBUG;
        if ( $operator && $left ne 'keyword' ) {

            #do a specific search
            my $dbh = C4::Context->dbh;
            $operator = 'LIKE' if $operator eq '=' and $right =~ /%/;
            my $sth =
              $dbh->prepare(
"SELECT biblionumbers,value FROM nozebra WHERE server=? AND indexname=? AND value $operator ?"
              );
            warn "$left / $operator / $right\n" if $DEBUG;

            # split each word, query the DB and build the biblionumbers result
            #sanitizing leftpart
            $left =~ s/^\s+|\s+$//;
            foreach ( split / /, $right ) {
                my $biblionumbers;
                $_ =~ s/^\s+|\s+$//;
                next unless $_;
                warn "EXECUTE : $server, $left, $_" if $DEBUG;
                $sth->execute( $server, $left, $_ )
                  or warn "execute failed: $!";
                while ( my ( $line, $value ) = $sth->fetchrow ) {

# if we are dealing with a numeric value, use only numeric results (in case of >=, <=, > or <)
# otherwise, fill the result
                    $biblionumbers .= $line
                      unless ( $right =~ /^\d+$/ && $value =~ /\D/ );
                    warn "result : $value "
                      . ( $right  =~ /\d/ ) . "=="
                      . ( $value =~ /\D/?$line:"" ) if $DEBUG;         #= $line";
                }

# do a AND with existing list if there is one, otherwise, use the biblionumbers list as 1st result list
                if ($results) {
                    warn "NZAND" if $DEBUG;
                    $results = NZoperatorAND($biblionumbers,$results);
                }
                else {
                    $results = $biblionumbers;
                }
            }
        }
        else {

      #do a complete search (all indexes), if index='kw' do complete search too.
            my $dbh = C4::Context->dbh;
            my $sth =
              $dbh->prepare(
"SELECT biblionumbers FROM nozebra WHERE server=? AND value LIKE ?"
              );

            # split each word, query the DB and build the biblionumbers result
            foreach ( split / /, $string ) {
                next if C4::Context->stopwords->{ uc($_) };   # skip if stopword
                warn "search on all indexes on $_" if $DEBUG;
                my $biblionumbers;
                next unless $_;
                $sth->execute( $server, $_ );
                while ( my $line = $sth->fetchrow ) {
                    $biblionumbers .= $line;
                }

# do a AND with existing list if there is one, otherwise, use the biblionumbers list as 1st result list
                if ($results) {
                    $results = NZoperatorAND($biblionumbers,$results);
                }
                else {
                    warn "NEW RES for $_ = $biblionumbers" if $DEBUG;
                    $results = $biblionumbers;
                }
            }
        }
        warn "return : $results for LEAF : $string" if $DEBUG;
        return $results;
    }
    warn "---------\nLeave NZanalyse\n---------" if $DEBUG;
}

sub NZoperatorAND{
    my ($rightresult, $leftresult)=@_;
    
    my @leftresult = split /;/, $leftresult;
    warn " @leftresult / $rightresult \n" if $DEBUG;
    
    #             my @rightresult = split /;/,$leftresult;
    my $finalresult;

# parse the left results, and if the biblionumber exist in the right result, save it in finalresult
# the result is stored twice, to have the same weight for AND than OR.
# example : TWO : 61,61,64,121 (two is twice in the biblio #61) / TOWER : 61,64,130
# result : 61,61,61,61,64,64 for two AND tower : 61 has more weight than 64
    foreach (@leftresult) {
        my $value = $_;
        my $countvalue;
        ( $value, $countvalue ) = ( $1, $2 ) if ($value=~/(.*)-(\d+)$/);
        if ( $rightresult =~ /\Q$value\E-(\d+);/ ) {
            $countvalue = ( $1 > $countvalue ? $countvalue : $1 );
            $finalresult .=
                "$value-$countvalue;$value-$countvalue;";
        }
    }
    warn "NZAND DONE : $finalresult \n" if $DEBUG;
    return $finalresult;
}
      
sub NZoperatorOR{
    my ($rightresult, $leftresult)=@_;
    return $rightresult.$leftresult;
}

sub NZoperatorNOT{
    my ($rightresult, $leftresult)=@_;
    
    my @leftresult = split /;/, $leftresult;

    #             my @rightresult = split /;/,$leftresult;
    my $finalresult;
    foreach (@leftresult) {
        my $value=$_;
        $value=$1 if $value=~m/(.*)-\d+$/;
        unless ($rightresult =~ "$value-") {
            $finalresult .= "$_;";
        }
    }
    return $finalresult;
}

=head2 NZorder

  $finalresult = NZorder($biblionumbers, $ordering,$results_per_page,$offset);
  
  TODO :: Description

=cut

sub NZorder {
    my ( $biblionumbers, $ordering, $results_per_page, $offset ) = @_;
    warn "biblionumbers = $biblionumbers and ordering = $ordering\n" if $DEBUG;

    # order title asc by default
    #     $ordering = '1=36 <i' unless $ordering;
    $results_per_page = 20 unless $results_per_page;
    $offset           = 0  unless $offset;
    my $dbh = C4::Context->dbh;

    #
    # order by POPULARITY
    #
    if ( $ordering =~ /popularity/ ) {
        my %result;
        my %popularity;

        # popularity is not in MARC record, it's builded from a specific query
        my $sth =
          $dbh->prepare("select sum(issues) from items where biblionumber=?");
        foreach ( split /;/, $biblionumbers ) {
            my ( $biblionumber, $title ) = split /,/, $_;
            $result{$biblionumber} = GetMarcBiblio($biblionumber);
            $sth->execute($biblionumber);
            my $popularity = $sth->fetchrow || 0;

# hint : the key is popularity.title because we can have
# many results with the same popularity. In this cas, sub-ordering is done by title
# we also have biblionumber to avoid bug for 2 biblios with the same title & popularity
# (un-frequent, I agree, but we won't forget anything that way ;-)
            $popularity{ sprintf( "%10d", $popularity ) . $title
                  . $biblionumber } = $biblionumber;
        }

    # sort the hash and return the same structure as GetRecords (Zebra querying)
        my $result_hash;
        my $numbers = 0;
        if ( $ordering eq 'popularity_dsc' ) {    # sort popularity DESC
            foreach my $key ( sort { $b cmp $a } ( keys %popularity ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{ $popularity{$key} }->as_usmarc();
            }
        }
        else {                                    # sort popularity ASC
            foreach my $key ( sort ( keys %popularity ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{ $popularity{$key} }->as_usmarc();
            }
        }
        my $finalresult = ();
        $result_hash->{'hits'}         = $numbers;
        $finalresult->{'biblioserver'} = $result_hash;
        return $finalresult;

        #
        # ORDER BY author
        #
    }
    elsif ( $ordering =~ /author/ ) {
        my %result;
        foreach ( split /;/, $biblionumbers ) {
            my ( $biblionumber, $title ) = split /,/, $_;
            my $record = GetMarcBiblio($biblionumber);
            my $author;
            if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
                $author = $record->subfield( '200', 'f' );
                $author = $record->subfield( '700', 'a' ) unless $author;
            }
            else {
                $author = $record->subfield( '100', 'a' );
            }

# hint : the result is sorted by title.biblionumber because we can have X biblios with the same title
# and we don't want to get only 1 result for each of them !!!
            $result{ $author . $biblionumber } = $record;
        }

    # sort the hash and return the same structure as GetRecords (Zebra querying)
        my $result_hash;
        my $numbers = 0;
        if ( $ordering eq 'author_za' ) {    # sort by author desc
            foreach my $key ( sort { $b cmp $a } ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{$key}->as_usmarc();
            }
        }
        else {                               # sort by author ASC
            foreach my $key ( sort ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{$key}->as_usmarc();
            }
        }
        my $finalresult = ();
        $result_hash->{'hits'}         = $numbers;
        $finalresult->{'biblioserver'} = $result_hash;
        return $finalresult;

        #
        # ORDER BY callnumber
        #
    }
    elsif ( $ordering =~ /callnumber/ ) {
        my %result;
        foreach ( split /;/, $biblionumbers ) {
            my ( $biblionumber, $title ) = split /,/, $_;
            my $record = GetMarcBiblio($biblionumber);
            my $callnumber;
            my ( $callnumber_tag, $callnumber_subfield ) =
              GetMarcFromKohaField( $dbh, 'items.itemcallnumber' );
            ( $callnumber_tag, $callnumber_subfield ) =
              GetMarcFromKohaField('biblioitems.callnumber')
              unless $callnumber_tag;
            if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
                $callnumber = $record->subfield( '200', 'f' );
            }
            else {
                $callnumber = $record->subfield( '100', 'a' );
            }

# hint : the result is sorted by title.biblionumber because we can have X biblios with the same title
# and we don't want to get only 1 result for each of them !!!
            $result{ $callnumber . $biblionumber } = $record;
        }

    # sort the hash and return the same structure as GetRecords (Zebra querying)
        my $result_hash;
        my $numbers = 0;
        if ( $ordering eq 'call_number_dsc' ) {    # sort by title desc
            foreach my $key ( sort { $b cmp $a } ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{$key}->as_usmarc();
            }
        }
        else {                                     # sort by title ASC
            foreach my $key ( sort { $a cmp $b } ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{$key}->as_usmarc();
            }
        }
        my $finalresult = ();
        $result_hash->{'hits'}         = $numbers;
        $finalresult->{'biblioserver'} = $result_hash;
        return $finalresult;
    }
    elsif ( $ordering =~ /pubdate/ ) {             #pub year
        my %result;
        foreach ( split /;/, $biblionumbers ) {
            my ( $biblionumber, $title ) = split /,/, $_;
            my $record = GetMarcBiblio($biblionumber);
            my ( $publicationyear_tag, $publicationyear_subfield ) =
              GetMarcFromKohaField( 'biblioitems.publicationyear', '' );
            my $publicationyear =
              $record->subfield( $publicationyear_tag,
                $publicationyear_subfield );

# hint : the result is sorted by title.biblionumber because we can have X biblios with the same title
# and we don't want to get only 1 result for each of them !!!
            $result{ $publicationyear . $biblionumber } = $record;
        }

    # sort the hash and return the same structure as GetRecords (Zebra querying)
        my $result_hash;
        my $numbers = 0;
        if ( $ordering eq 'pubdate_dsc' ) {    # sort by pubyear desc
            foreach my $key ( sort { $b cmp $a } ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{$key}->as_usmarc();
            }
        }
        else {                                 # sort by pub year ASC
            foreach my $key ( sort ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] =
                  $result{$key}->as_usmarc();
            }
        }
        my $finalresult = ();
        $result_hash->{'hits'}         = $numbers;
        $finalresult->{'biblioserver'} = $result_hash;
        return $finalresult;

        #
        # ORDER BY title
        #
    }
    elsif ( $ordering =~ /title/ ) {

# the title is in the biblionumbers string, so we just need to build a hash, sort it and return
        my %result;
        foreach ( split /;/, $biblionumbers ) {
            my ( $biblionumber, $title ) = split /,/, $_;

# hint : the result is sorted by title.biblionumber because we can have X biblios with the same title
# and we don't want to get only 1 result for each of them !!!
# hint & speed improvement : we can order without reading the record
# so order, and read records only for the requested page !
            $result{ $title . $biblionumber } = $biblionumber;
        }

    # sort the hash and return the same structure as GetRecords (Zebra querying)
        my $result_hash;
        my $numbers = 0;
        if ( $ordering eq 'title_az' ) {    # sort by title desc
            foreach my $key ( sort ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] = $result{$key};
            }
        }
        else {                              # sort by title ASC
            foreach my $key ( sort { $b cmp $a } ( keys %result ) ) {
                $result_hash->{'RECORDS'}[ $numbers++ ] = $result{$key};
            }
        }

        # limit the $results_per_page to result size if it's more
        $results_per_page = $numbers - 1 if $numbers < $results_per_page;

        # for the requested page, replace biblionumber by the complete record
        # speed improvement : avoid reading too much things
        for (
            my $counter = $offset ;
            $counter <= $offset + $results_per_page ;
            $counter++
          )
        {
            $result_hash->{'RECORDS'}[$counter] =
              GetMarcBiblio( $result_hash->{'RECORDS'}[$counter] )->as_usmarc;
        }
        my $finalresult = ();
        $result_hash->{'hits'}         = $numbers;
        $finalresult->{'biblioserver'} = $result_hash;
        return $finalresult;
    }
    else {

#
# order by ranking
#
# we need 2 hashes to order by ranking : the 1st one to count the ranking, the 2nd to order by ranking
        my %result;
        my %count_ranking;
        foreach ( split /;/, $biblionumbers ) {
            my ( $biblionumber, $title ) = split /,/, $_;
            $title =~ /(.*)-(\d)/;

            # get weight
            my $ranking = $2;

# note that we + the ranking because ranking is calculated on weight of EACH term requested.
# if we ask for "two towers", and "two" has weight 2 in biblio N, and "towers" has weight 4 in biblio N
# biblio N has ranking = 6
            $count_ranking{$biblionumber} += $ranking;
        }

# build the result by "inverting" the count_ranking hash
# hing : as usual, we don't order by ranking only, to avoid having only 1 result for each rank. We build an hash on concat(ranking,biblionumber) instead
#         warn "counting";
        foreach ( keys %count_ranking ) {
            $result{ sprintf( "%10d", $count_ranking{$_} ) . '-' . $_ } = $_;
        }

    # sort the hash and return the same structure as GetRecords (Zebra querying)
        my $result_hash;
        my $numbers = 0;
        foreach my $key ( sort { $b cmp $a } ( keys %result ) ) {
            $result_hash->{'RECORDS'}[ $numbers++ ] = $result{$key};
        }

        # limit the $results_per_page to result size if it's more
        $results_per_page = $numbers - 1 if $numbers < $results_per_page;

        # for the requested page, replace biblionumber by the complete record
        # speed improvement : avoid reading too much things
        for (
            my $counter = $offset ;
            $counter <= $offset + $results_per_page ;
            $counter++
          )
        {
            $result_hash->{'RECORDS'}[$counter] =
              GetMarcBiblio( $result_hash->{'RECORDS'}[$counter] )->as_usmarc
              if $result_hash->{'RECORDS'}[$counter];
        }
        my $finalresult = ();
        $result_hash->{'hits'}         = $numbers;
        $finalresult->{'biblioserver'} = $result_hash;
        return $finalresult;
    }
}

=head2 ModBiblios

($countchanged,$listunchanged) = ModBiblios($listbiblios, $tagsubfield,$initvalue,$targetvalue,$test);

this function changes all the values $initvalue in subfield $tag$subfield in any record in $listbiblios
test parameter if set donot perform change to records in database.

=over 2

=item C<input arg:>

    * $listbiblios is an array ref to marcrecords to be changed
    * $tagsubfield is the reference of the subfield to change.
    * $initvalue is the value to search the record for
    * $targetvalue is the value to set the subfield to
    * $test is to be set only not to perform changes in database.

=item C<Output arg:>
    * $countchanged counts all the changes performed.
    * $listunchanged contains the list of all the biblionumbers of records unchanged.

=item C<usage in the script:>

=back

my ($countchanged, $listunchanged) = EditBiblios($results->{RECORD}, $tagsubfield,$initvalue,$targetvalue);;
#If one wants to display unchanged records, you should get biblios foreach @$listunchanged 
$template->param(countchanged => $countchanged, loopunchanged=>$listunchanged);

=cut

sub ModBiblios {
    my ( $listbiblios, $tagsubfield, $initvalue, $targetvalue, $test ) = @_;
    my $countmatched;
    my @unmatched;
    my ( $tag, $subfield ) = ( $1, $2 )
      if ( $tagsubfield =~ /^(\d{1,3})([a-z0-9A-Z@])?$/ );
    if ( ( length($tag) < 3 ) && $subfield =~ /0-9/ ) {
        $tag = $tag . $subfield;
        undef $subfield;
    }
    my ( $bntag,   $bnsubf )   = GetMarcFromKohaField('biblio.biblionumber');
    my ( $itemtag, $itemsubf ) = GetMarcFromKohaField('items.itemnumber');
    if ($tag eq $itemtag) {
        # do not allow the embedded item tag to be 
        # edited from here
        warn "Attempting to edit item tag via C4::Search::ModBiblios -- not allowed";
        return (0, []);
    }
    foreach my $usmarc (@$listbiblios) {
        my $record;
        $record = eval { MARC::Record->new_from_usmarc($usmarc) };
        my $biblionumber;
        if ($@) {

            # usmarc is not a valid usmarc May be a biblionumber
            # FIXME - sorry, please let's figure out whether
            #         this function is to be passed a list of
            #         record numbers or a list of MARC::Record
            #         objects.  The former is probably better
            #         because the MARC records supplied by Zebra
            #         may be not current.
            $record       = GetMarcBiblio($usmarc);
            $biblionumber = $usmarc;
        }
        else {
            if ( $bntag >= 010 ) {
                $biblionumber = $record->subfield( $bntag, $bnsubf );
            }
            else {
                $biblionumber = $record->field($bntag)->data;
            }
        }

        #GetBiblionumber is to be written.
        #Could be replaced by TransformMarcToKoha (But Would be longer)
        if ( $record->field($tag) ) {
            my $modify = 0;
            foreach my $field ( $record->field($tag) ) {
                if ($subfield) {
                    if (
                        $field->delete_subfield(
                            'code'  => $subfield,
                            'match' => qr($initvalue)
                        )
                      )
                    {
                        $countmatched++;
                        $modify = 1;
                        $field->update( $subfield, $targetvalue )
                          if ($targetvalue);
                    }
                }
                else {
                    if ( $tag >= 010 ) {
                        if ( $field->delete_field($field) ) {
                            $countmatched++;
                            $modify = 1;
                        }
                    }
                    else {
                        $field->data = $targetvalue
                          if ( $field->data =~ qr($initvalue) );
                    }
                }
            }

            #       warn $record->as_formatted;
            if ($modify) {
                ModBiblio( $record, $biblionumber,
                    GetFrameworkCode($biblionumber) )
                  unless ($test);
            }
            else {
                push @unmatched, $biblionumber;
            }
        }
        else {
            push @unmatched, $biblionumber;
        }
    }
    return ( $countmatched, \@unmatched );
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
