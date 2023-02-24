package C4::Search;

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
use C4::Context;
use C4::Biblio qw( TransformMarcToKoha GetMarcFromKohaField GetFrameworkCode GetAuthorisedValueDesc GetBiblioData );
use C4::Koha qw( getFacets GetVariationsOfISBN GetNormalizedUPC GetNormalizedEAN GetNormalizedOCLCNumber GetNormalizedISBN getitemtypeimagelocation );
use Koha::DateUtils;
use Koha::Libraries;
use Lingua::Stem;
use XML::Simple;
use C4::XSLT qw( XSLTParse4Display );
use C4::Reserves qw( GetReserveStatus );
use C4::Charset qw( SetUTF8Flag );
use Koha::AuthorisedValues;
use Koha::ItemTypes;
use Koha::Libraries;
use Koha::Logger;
use Koha::Patrons;
use Koha::Recalls;
use Koha::RecordProcessor;
use URI::Escape;
use Business::ISBN;
use MARC::Record;
use MARC::Field;

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT_OK = qw(
      FindDuplicate
      SimpleSearch
      searchResults
      getRecords
      buildQuery
      GetDistinctValues
      enabled_staff_search_views
      new_record_from_zebra
      z3950_search_args
      getIndexes
    );
}

=head1 NAME

C4::Search - Functions for searching the Koha catalog.

=head1 SYNOPSIS

See opac/opac-search.pl or catalogue/search.pl for example of usage

=head1 DESCRIPTION

This module provides searching functions for Koha's bibliographic databases

=head1 FUNCTIONS

=cut

# make all your functions, whether exported or not;

=head2 FindDuplicate

($biblionumber,$biblionumber,$title) = FindDuplicate($record);

This function attempts to find duplicate records using a hard-coded, fairly simplistic algorithm

=cut

sub FindDuplicate {
    my ($record) = @_;
    my $dbh = C4::Context->dbh;
    my $result = TransformMarcToKoha( $record, '' );
    my $sth;
    my $query;

    # search duplicate on ISBN, easy and fast..
    # ... normalize first
    if ( $result->{isbn} ) {
        $result->{isbn} =~ s/\(.*$//;
        $result->{isbn} =~ s/\s+$//;
        $result->{isbn} =~ s/\|/OR/;
        $query = "isbn:$result->{isbn}";
    }
    else {

        my $titleindex = 'ti,ext';
        my $authorindex = 'au,ext';
        my $op = 'AND';

        $result->{title} =~ s /\\//g;
        $result->{title} =~ s /\"//g;
        $result->{title} =~ s /\(//g;
        $result->{title} =~ s /\)//g;

        $query = "$titleindex:\"$result->{title}\"";
        if   ( $result->{author} ) {
            $result->{author} =~ s /\\//g;
            $result->{author} =~ s /\"//g;
            $result->{author} =~ s /\(//g;
            $result->{author} =~ s /\)//g;

            $query .= " $op $authorindex:\"$result->{author}\"";
        }
    }

    my $searcher = Koha::SearchEngine::Search->new({index => $Koha::SearchEngine::BIBLIOS_INDEX});
    my ( $error, $searchresults, undef ) = $searcher->simple_search_compat($query,0,50);
    my @results;
    if (!defined $error) {
        foreach my $possible_duplicate_record (@{$searchresults}) {
            my $marcrecord = new_record_from_zebra(
                'biblioserver',
                $possible_duplicate_record
            );

            my $result = TransformMarcToKoha( $marcrecord, '' );

            # FIXME :: why 2 $biblionumber ?
            if ($result) {
                push @results, $result->{'biblionumber'};
                push @results, $result->{'title'};
            }
        }
    }
    return @results;
}

=head2 SimpleSearch

( $error, $results, $total_hits ) = SimpleSearch( $query, $offset, $max_results, [@servers], [%options] );

This function provides a simple search API on the bibliographic catalog

=over 2

=item C<input arg:>

    * $query can be a simple keyword or a complete CCL query
    * @servers is optional. Defaults to biblioserver as found in koha-conf.xml
    * $offset - If present, represents the number of records at the beginning to omit. Defaults to 0
    * $max_results - if present, determines the maximum number of records to fetch. undef is All. defaults to undef.
    * %options is optional. (e.g. "skip_normalize" allows you to skip changing : to = )


=item C<Return:>

    Returns an array consisting of three elements
    * $error is undefined unless an error is detected
    * $results is a reference to an array of records.
    * $total_hits is the number of hits that would have been returned with no limit

    If an error is returned the two other return elements are undefined. If error itself is undefined
    the other two elements are always defined

=item C<usage in the script:>

=back

my ( $error, $marcresults, $total_hits ) = SimpleSearch($query);

if (defined $error) {
    $template->param(query_error => $error);
    warn "error: ".$error;
    output_html_with_http_headers $input, $cookie, $template->output;
    exit;
}

my $hits = @{$marcresults};
my @results;

for my $r ( @{$marcresults} ) {
    my $marcrecord = MARC::File::USMARC::decode($r);
    my $biblio = TransformMarcToKoha($marcrecord,q{});

    #build the iarray of hashs for the template.
    push @results, {
        title           => $biblio->{'title'},
        subtitle        => $biblio->{'subtitle'},
        biblionumber    => $biblio->{'biblionumber'},
        author          => $biblio->{'author'},
        publishercode   => $biblio->{'publishercode'},
        publicationyear => $biblio->{'publicationyear'},
        };

}

$template->param(result=>\@results);

=cut

sub SimpleSearch {
    my ( $query, $offset, $max_results, $servers, %options )  = @_;

    return ( 'No query entered', undef, undef ) unless $query;
    # FIXME hardcoded value. See catalog/search.pl & opac-search.pl too.
    my @servers = defined ( $servers ) ? @$servers : ( 'biblioserver' );
    my @zoom_queries;
    my @tmpresults;
    my @zconns;
    my $results = [];
    my $total_hits = 0;

    # Initialize & Search Zebra
    for ( my $i = 0 ; $i < @servers ; $i++ ) {
        eval {
            $zconns[$i] = C4::Context->Zconn( $servers[$i], 1 );
            $query =~ s/:/=/g unless $options{skip_normalize};
            $zoom_queries[$i] = ZOOM::Query::CCL2RPN->new( $query, $zconns[$i]);
            $tmpresults[$i] = $zconns[$i]->search( $zoom_queries[$i] );

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
            warn $error." for query: $query";
            return ( $error, undef, undef );
        }
    }

    _ZOOM_event_loop(
        \@zconns,
        \@tmpresults,
        sub {
            my ($i, $size) = @_;
            my $first_record = defined($offset) ? $offset + 1 : 1;
            my $hits = $tmpresults[ $i - 1 ]->size();
            $total_hits += $hits;
            my $last_record = $hits;
            if ( defined $max_results && $offset + $max_results < $hits ) {
                $last_record = $offset + $max_results;
            }

            for my $j ( $first_record .. $last_record ) {
                my $record = eval {
                  $tmpresults[ $i - 1 ]->record( $j - 1 )->raw()
                  ;    # 0 indexed
                };
                push @{$results}, $record if defined $record;
            }
        }
    );

    foreach my $zoom_query (@zoom_queries) {
        $zoom_query->destroy();
    }

    return ( undef, $results, $total_hits );
}

=head2 getRecords

( undef, $results_hashref, \@facets_loop ) = getRecords (

        $koha_query,       $simple_query, $sort_by_ref,    $servers_ref,
        $results_per_page, $offset,       $branches,       $itemtypes,
        $query_type,       $scan,         $opac
    );

The all singing, all dancing, multi-server, asynchronous, scanning,
searching, record nabbing, facet-building

See verbose embedded documentation.

=cut

sub getRecords {
    my (
        $koha_query,       $simple_query, $sort_by_ref,    $servers_ref,
        $results_per_page, $offset,       $branches,         $itemtypes,
        $query_type,       $scan,         $opac
    ) = @_;

    my @servers = @$servers_ref;
    my @sort_by = @$sort_by_ref;
    $offset = 0 if $offset < 0;

    # Initialize variables for the ZOOM connection and results object
    my @zconns;
    my @results;
    my $results_hashref = ();

    # TODO simplify this structure ( { branchcode => $branchname } is enought) and remove this parameter
    $branches ||= { map { $_->branchcode => { branchname => $_->branchname } } Koha::Libraries->search->as_list };

    # Initialize variables for the faceted results objects
    my $facets_counter = {};
    my $facets_info    = {};
    my $facets         = getFacets();

    my @facets_loop;    # stores the ref to array of hashes for template facets loop

    ### LOOP THROUGH THE SERVERS
    for ( my $i = 0 ; $i < @servers ; $i++ ) {
        $zconns[$i] = C4::Context->Zconn( $servers[$i], 1 );

# perform the search, create the results objects
# if this is a local search, use the $koha-query, if it's a federated one, use the federated-query
        my $query_to_use = ($servers[$i] =~ /biblioserver/) ? $koha_query : $simple_query;

        Koha::Logger->get->debug($simple_query) if $scan;

        # Check if we've got a query_type defined, if so, use it
        eval {
            if ($query_type) {
                if ($query_type =~ /^ccl/) {
                    $query_to_use =~ s/\:/\=/g;    # change : to = last minute (FIXME)
                    $results[$i] = $zconns[$i]->search(ZOOM::Query::CCL2RPN->new($query_to_use, $zconns[$i]));
                } elsif ($query_type =~ /^cql/) {
                    $results[$i] = $zconns[$i]->search(ZOOM::Query::CQL->new($query_to_use, $zconns[$i]));
                } elsif ($query_type =~ /^pqf/) {
                    $results[$i] = $zconns[$i]->search(ZOOM::Query::PQF->new($query_to_use, $zconns[$i]));
                } else {
                    warn "Unknown query_type '$query_type'.  Results undetermined.";
                }
            } elsif ($scan) {
                    $results[$i] = $zconns[$i]->scan(  ZOOM::Query::CCL2RPN->new($query_to_use, $zconns[$i]));
            } else {
                    $results[$i] = $zconns[$i]->search(ZOOM::Query::CCL2RPN->new($query_to_use, $zconns[$i]));
            }
        };
        if ($@) {
            warn "WARNING: query problem with $query_to_use " . $@;
        }

        # Concatenate the sort_by limits and pass them to the results object
        # Note: sort will override rank
        my $sort_by;
        foreach my $sort (@sort_by) {
            if ( $sort eq "author_az" || $sort eq "author_asc" ) {
                $sort_by .= "1=1003 <i ";
            }
            elsif ( $sort eq "author_za" || $sort eq "author_dsc" ) {
                $sort_by .= "1=1003 >i ";
            }
            elsif ( $sort eq "popularity_asc" ) {
                $sort_by .= "1=9003 <i ";
            }
            elsif ( $sort eq "popularity_dsc" ) {
                $sort_by .= "1=9003 >i ";
            }
            elsif ( $sort eq "call_number_asc" ) {
                $sort_by .= "1=8007  <i ";
            }
            elsif ( $sort eq "call_number_dsc" ) {
                $sort_by .= "1=8007 >i ";
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
            elsif ( $sort eq "title_az" || $sort eq "title_asc" ) {
                $sort_by .= "1=4 <i ";
            }
            elsif ( $sort eq "title_za" || $sort eq "title_dsc" ) {
                $sort_by .= "1=4 >i ";
            }
            elsif ( $sort eq "biblionumber_az" || $sort eq "biblionumber_asc" ) {
                $sort_by .= "1=12 <i ";
            }
            elsif ( $sort eq "biblionumber_za" || $sort eq "biblionumber_dsc" ) {
                $sort_by .= "1=12 >i ";
            }
            else {
                warn "Ignoring unrecognized sort '$sort' requested" if $sort_by;
            }
        }
        if ( $sort_by && !$scan && $results[$i] ) {
            if ( $results[$i]->sort( "yaz", $sort_by ) < 0 ) {
                warn "WARNING sort $sort_by failed";
            }
        }
    }    # finished looping through servers

    # The big moment: asynchronously retrieve results from all servers
        _ZOOM_event_loop(
            \@zconns,
            \@results,
            sub {
                my ( $i, $size ) = @_;
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
                    my $record;

                    ## Check if it's an index scan
                    if ($scan) {
                        my ( $term, $occ ) = $results[ $i - 1 ]->display_term($j);

                 # here we create a minimal MARC record and hand it off to the
                 # template just like a normal result ... perhaps not ideal, but
                 # it works for now
                        my $tmprecord = MARC::Record->new();
                        $tmprecord->encoding('UTF-8');
                        my $tmptitle;
                        my $tmpauthor;

                # the minimal record in author/title (depending on MARC flavour)
                        if ( C4::Context->preference("marcflavour") eq
                            "UNIMARC" )
                        {
                            $tmptitle = MARC::Field->new(
                                '200', ' ', ' ',
                                a => $term,
                                f => $occ
                            );
                            $tmprecord->append_fields($tmptitle);
                        }
                        else {
                            $tmptitle =
                              MARC::Field->new( '245', ' ', ' ', a => $term, );
                            $tmpauthor =
                              MARC::Field->new( '100', ' ', ' ', a => $occ, );
                            $tmprecord->append_fields($tmptitle);
                            $tmprecord->append_fields($tmpauthor);
                        }
                        $results_hash->{'RECORDS'}[$j] =
                          $tmprecord->as_usmarc();
                    }

                    # not an index scan
                    else {
                        $record = $results[ $i - 1 ]->record($j)->raw();
                        # warn "RECORD $j:".$record;
                        $results_hash->{'RECORDS'}[$j] = $record;
                    }

                }
                $results_hashref->{ $servers[ $i - 1 ] } = $results_hash;

                # Fill the facets while we're looping, but only for the
                # biblioserver and not for a scan
                if ( !$scan && $servers[ $i - 1 ] =~ /biblioserver/ ) {
                    $facets_counter = GetFacets( $results[ $i - 1 ] );
                    $facets_info    = _get_facets_info( $facets );
                }

                # BUILD FACETS
                if ( $servers[ $i - 1 ] =~ /biblioserver/ ) {
                    for my $link_value (
                        sort { $a cmp $b } keys %$facets_counter
                      )
                    {
                        my @this_facets_array;
                        for my $one_facet (
                            sort {
                                $facets_counter->{$link_value}
                                  ->{$b} <=> $facets_counter->{$link_value}
                                  ->{$a}
                            } keys %{ $facets_counter->{$link_value} }
                          )
                        {
# Sanitize the link value : parenthesis, question and exclamation mark will cause errors with CCL
                            my $facet_link_value = $one_facet;
                            $facet_link_value =~ s/[()!?¡¿؟]/ /g;

                            # fix the length that will display in the label,
                            my $facet_label_value = $one_facet;
                            my $facet_max_length  = C4::Context->preference(
                                'FacetLabelTruncationLength')
                              || 20;
                            $facet_label_value =
                              substr( $one_facet, 0, $facet_max_length )
                              . "..."
                              if length($facet_label_value) >
                                  $facet_max_length;

                        # if it's a branch, label by the name, not the code,
                            if ( $link_value =~ /branch/ ) {
                                if (   defined $branches
                                    && ref($branches) eq "HASH"
                                    && defined $branches->{$one_facet}
                                    && ref( $branches->{$one_facet} ) eq
                                    "HASH" )
                                {
                                    $facet_label_value =
                                      $branches->{$one_facet}
                                      ->{'branchname'};
                                }
                                else {
                                    $facet_label_value = "*";
                                }
                            }

                      # if it's a itemtype, label by the name, not the code,
                            if ( $link_value =~ /itype/ ) {
                                if (   defined $itemtypes
                                    && ref($itemtypes) eq "HASH"
                                    && defined $itemtypes->{$one_facet}
                                    && ref( $itemtypes->{$one_facet} ) eq
                                    "HASH" )
                                {
                                    $facet_label_value =
                                      $itemtypes->{$one_facet}
                                      ->{translated_description};
                                }
                            }

           # also, if it's a location code, use the name instead of the code
                            if ( $link_value =~ /location/ ) {
                                # TODO Retrieve all authorised values at once, instead of 1 query per entry
                                my $av = Koha::AuthorisedValues->search({ category => 'LOC', authorised_value => $one_facet });
                                $facet_label_value = $av->count ? $av->next->opac_description : '';
                            }

                            # also, if it's a collection code, use the name instead of the code
                            if ( $link_value =~ /ccode/ ) {
                                # TODO Retrieve all authorised values at once, instead of 1 query per entry
                                my $av = Koha::AuthorisedValues->search({ category => 'CCODE', authorised_value => $one_facet });
                                $facet_label_value = $av->count ? $av->next->opac_description : '';
                            }

            # but we're down with the whole label being in the link's title.
                            push @this_facets_array,
                              {
                                facet_count =>
                                  $facets_counter->{$link_value}
                                  ->{$one_facet},
                                facet_label_value => $facet_label_value,
                                facet_title_value => $one_facet,
                                facet_link_value  => $facet_link_value,
                                type_link_value   => $link_value,
                              }
                              if ($facet_label_value);
                        }

                        push @facets_loop,
                          {
                            type_link_value => $link_value,
                            type_id         => $link_value . "_id",
                            "type_label_"
                              . $facets_info->{$link_value}->{'label_value'} =>
                              1,
                            facets     => \@this_facets_array,
                          }
                          unless (
                            (
                                $facets_info->{$link_value}->{'label_value'} =~
                                /Libraries/
                            )
                            and ( Koha::Libraries->search->count == 1 )
                          );
                    }
                }
            }
        );

    # This sorts the facets into alphabetical order
    if (@facets_loop) {
        foreach my $f (@facets_loop) {
            if( C4::Context->preference('FacetOrder') eq 'Alphabetical' ){
                $f->{facets} =
                    [ sort { uc($a->{facet_label_value}) cmp uc($b->{facet_label_value}) } @{ $f->{facets} } ];
            }
        }
    }

    return ( undef, $results_hashref, \@facets_loop );
}

sub GetFacets {

    my $rs = shift;
    my $facets;

    my $use_zebra_facets = C4::Context->config('use_zebra_facets') // 0;

    if ( $use_zebra_facets ) {
        $facets = _get_facets_from_zebra( $rs );
    } else {
        $facets = _get_facets_from_records( $rs );
    }

    return $facets;
}

sub _get_facets_from_records {

    my $rs = shift;

    my $facets_maxrecs = C4::Context->preference('maxRecordsForFacets') // 20;
    my $facets_config  = getFacets();
    my $facets         = {};
    my $size           = $rs->size();
    my $jmax           = $size > $facets_maxrecs
                            ? $facets_maxrecs
                            : $size;

    for ( my $j = 0 ; $j < $jmax ; $j++ ) {

        my $marc_record = new_record_from_zebra (
                'biblioserver',
                $rs->record( $j )->raw()
        );

        if ( ! defined $marc_record ) {
            warn "ERROR DECODING RECORD - $@: " .
                $rs->record( $j )->raw();
            next;
        }

        _get_facets_data_from_record( $marc_record, $facets_config, $facets );
    }

    return $facets;
}

=head2 _get_facets_data_from_record

    C4::Search::_get_facets_data_from_record( $marc_record, $facets, $facets_counter );

Internal function that extracts facets information from a MARC::Record object
and populates $facets_counter for using in getRecords.

$facets is expected to be filled with C4::Koha::getFacets output (i.e. the configured
facets for Zebra).

=cut

sub _get_facets_data_from_record {

    my ( $marc_record, $facets, $facets_counter ) = @_;

    for my $facet (@$facets) {

        my @used_datas = ();

        foreach my $tag ( @{ $facet->{ tags } } ) {

            # tag number is the first three digits
            my $tag_num          = substr( $tag, 0, 3 );
            # subfields are the remainder
            my $subfield_letters = substr( $tag, 3 );

            my @fields = $marc_record->field( $tag_num );
            foreach my $field (@fields) {
                # If $field->indicator(1) eq 'z', it means it is a 'see from'
                # field introduced because of IncludeSeeFromInSearches, so skip it
                next if $field->indicator(1) eq 'z';

                my $data = $field->as_string( $subfield_letters, $facet->{ sep } );
                $data =~ s/\s*(?<!\p{Uppercase})[.\-,;]*\s*$//;

                unless ( grep { $_ eq $data } @used_datas ) {
                    push @used_datas, $data;
                    $facets_counter->{ $facet->{ idx } }->{ $data }++;
                }
            }
        }
    }
}

=head2 _get_facets_from_zebra

    my $facets = _get_facets_from_zebra( $result_set )

Retrieves facets for a specified result set. It loops through the facets defined
in C4::Koha::getFacets and returns a hash with the following structure:

   {  facet_idx => {
            facet_value => count
      },
      ...
   }

=cut

sub _get_facets_from_zebra {

    my $rs = shift;

    # save current elementSetName
    my $elementSetName = $rs->option( 'elementSetName' );

    my $facets_loop = getFacets();
    my $facets_data  = {};
    # loop through defined facets and fill the facets hashref
    foreach my $facet ( @$facets_loop ) {

        my $idx = $facet->{ idx };
        my $sep = $facet->{ sep };
        my $facet_values = _get_facet_from_result_set( $idx, $rs, $sep );
        if ( $facet_values ) {
            # we've actually got a result
            $facets_data->{ $idx } = $facet_values;
        }
    }
    # set elementSetName to its previous value to avoid side effects
    $rs->option( elementSetName => $elementSetName );

    return $facets_data;
}

=head2 _get_facet_from_result_set

    my $facet_values =
        C4::Search::_get_facet_from_result_set( $facet_idx, $result_set, $sep )

Internal function that extracts facet information for a specific index ($facet_idx) and
returns a hash containing facet values and count:

    {
        $facet_value => $count ,
        ...
    }

Warning: this function has the side effect of changing the elementSetName for the result
set. It is a helper function for the main loop, which takes care of backing it up for
restoring.

=cut

sub _get_facet_from_result_set {

    my $facet_idx = shift;
    my $rs        = shift;
    my $sep       = shift;

    my $internal_sep  = '<*>';
    my $facetMaxCount = C4::Context->preference('FacetMaxCount') // 20;

    return if ( ! defined $facet_idx || ! defined $rs );
    # zebra's facet element, untokenized index
    my $facet_element = 'zebra::facet::' . $facet_idx . ':0:' . $facetMaxCount;
    # configure zebra results for retrieving the desired facet
    $rs->option( elementSetName => $facet_element );
    # get the facet record from result set
    my $facet = $rs->record( 0 )->raw;
    # if the facet has no restuls...
    return if !defined $facet;
    # TODO: benchmark DOM vs. SAX performance
    my $facet_dom = XML::LibXML->load_xml(
      string => ($facet)
    );
    my @terms = $facet_dom->getElementsByTagName('term');
    return if ! @terms;

    my $facets = {};
    foreach my $term ( @terms ) {
        my $facet_value = $term->textContent;
        $facet_value =~ s/\s*(?<!\p{Uppercase})[.\-,;]*\s*$//;
        $facet_value =~ s/\Q$internal_sep\E/$sep/ if defined $sep;
        $facets->{ $facet_value } += $term->getAttribute( 'occur' );
    }

    return $facets;
}

=head2 _get_facets_info

    my $facets_info = C4::Search::_get_facets_info( $facets )

Internal function that extracts facets information and properly builds
the data structure needed to render facet labels.

=cut

sub _get_facets_info {

    my $facets = shift;

    my $facets_info = {};

    for my $facet ( @$facets ) {
        $facets_info->{ $facet->{ idx } }->{ label_value } = $facet->{ label };
    }

    return $facets_info;
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
    my ($operand,$lang) = @_;
    require Lingua::Stem::Snowball ;
    my $stemmed_operand=q{};

    # Stemmer needs language
    return $operand unless $lang;

    # If operand contains a digit, it is almost certainly an identifier, and should
    # not be stemmed.  This is particularly relevant for ISBNs and ISSNs, which
    # can contain the letter "X" - for example, _build_stemmend_operand would reduce
    # "014100018X" to "x ", which for a MARC21 database would bring up irrelevant
    # results (e.g., "23 x 29 cm." from the 300$c).  Bug 2098.
    return $operand if $operand =~ /\d/;

# FIXME: the locale should be set based on the user's language and/or search choice
    #warn "$lang";
    # Make sure we only use the first two letters from the language code
    $lang = lc(substr($lang, 0, 2));
    # The language codes for the two variants of Norwegian will now be "nb" and "nn",
    # none of which Lingua::Stem::Snowball can use, so we need to "translate" them
    if ($lang eq 'nb' || $lang eq 'nn') {
      $lang = 'no';
    }
    my $stemmer = Lingua::Stem::Snowball->new( lang => $lang,
                                               encoding => "UTF-8" );

    my @words = split( / /, $operand );
    my @stems = $stemmer->stem(\@words);
    for my $stem (@stems) {
        $stemmed_operand .= "$stem";
        $stemmed_operand .= "?"
          unless ( $stem =~ /(and$|or$|not$)/ ) || ( length($stem) < 3 );
        $stemmed_operand .= " ";
    }

    Koha::Logger->get->debug("STEMMED OPERAND: $stemmed_operand");
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
    $operand =~ s/"/ /g;    # Bug 7518: searches with quotation marks don't work

    my $weighted_query = "(rk=(";    # Specifies that we're applying rank

    # Keyword, or, no index specified
    if ( ( $index eq 'kw' ) || ( !$index ) ) {
        $weighted_query .=
          "Title-cover,ext,r1=\"$operand\"";    # exact title-cover
        $weighted_query .= " or ti,ext,r2=\"$operand\"";    # exact title
        $weighted_query .= " or Title-cover,phr,r3=\"$operand\"";    # phrase title
        $weighted_query .= " or ti,wrdl,r4=\"$operand\"";    # words in title
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

    # If the index is numeric, don't autoquote it.
    elsif ( $index =~ /,st-numeric$/ ) {
        $weighted_query .= " $index=$operand";
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
        $weighted_query .= " or $index,wrdl,r6=\"$operand\"";    # word list index
        $weighted_query .= " or $index,wrdl,fuzzy,r8=\"$operand\""
          if $fuzzy_enabled;    # add fuzzy, word list
        $weighted_query .= " or $index,wrdl,rt,r9=\"$stemmed_operand\""
          if ( $stemming and $stemmed_operand );    # add stemming, right truncation
    }

    $weighted_query .= "))";                       # close rank specification
    return $weighted_query;
}

=head2 getIndexes

Return an array with available indexes.

=cut

sub getIndexes{
    my @indexes = (
                    # biblio indexes
                    'ab',
                    'Abstract',
                    'acqdate',
                    'allrecords',
                    'an',
                    'Any',
                    'at',
                    'arl',
                    'arp',
                    'au',
                    'aub',
                    'aud',
                    'audience',
                    'auo',
                    'aut',
                    'Author',
                    'Author-in-order ',
                    'Author-personal-bibliography',
                    'Authority-Number',
                    'authtype',
                    'bc',
		    'Bib-level',
                    'biblionumber',
                    'bio',
                    'biography',
                    'callnum',
                    'cfn',
                    'Chronological-subdivision',
                    'cn-bib-source',
                    'cn-bib-sort',
                    'cn-class',
                    'cn-item',
                    'cn-prefix',
                    'cn-suffix',
                    'cpn',
                    'Code-institution',
                    'Conference-name',
                    'Conference-name-heading',
                    'Conference-name-see',
                    'Conference-name-seealso',
                    'Content-type',
                    'Control-number',
                    'Control-number-identifier',
                    'cni',
                    'copydate',
                    'Corporate-name',
                    'Corporate-name-heading',
                    'Corporate-name-see',
                    'Corporate-name-seealso',
                    'Country-publication',
                    'ctype',
                    'curriculum',
                    'date-entered-on-file',
                    'Date-of-acquisition',
                    'Date-of-publication',
                    'Date-time-last-modified',
                    'Dewey-classification',
                    'Dissertation-information',
                    'diss',
                    'dtlm',
                    'EAN',
                    'extent',
                    'fic',
                    'fiction',
                    'Form-subdivision',
                    'format',
                    'Geographic-subdivision',
                    'he',
                    'Heading',
                    'Heading-use-main-or-added-entry',
                    'Heading-use-series-added-entry ',
                    'Heading-use-subject-added-entry',
                    'Host-item',
                    'id-other',
                    'ident',
                    'Identifier-standard',
                    'Illustration-code',
                    'Index-term-genre',
                    'Index-term-uncontrolled',
                    'Interest-age-level',
                    'Interest-grade-level',
                    'ISBN',
                    'isbn',
                    'ISSN',
                    'issn',
                    'itemtype',
                    'kw',
                    'Koha-Auth-Number',
                    'l-format',
                    'language',
                    'language-original',
                    'lc-card',
                    'LC-card-number',
                    'lcn',
                    'lex',
                    'lexile-number',
                    'llength',
                    'ln',
                    'ln-audio',
                    'ln-subtitle',
                    'Local-classification',
                    'Local-number',
                    'Match-heading',
                    'Match-heading-see-from',
                    'Material-type',
                    'mc-itemtype',
                    'mc-rtype',
                    'mus',
                    'Multipart-resource-level',
                    'mrl',
                    'name',
                    'Music-number',
                    'Name-geographic',
                    'Name-geographic-heading',
                    'Name-geographic-see',
                    'Name-geographic-seealso',
                    'nb',
                    'Note',
                    'notes',
                    'ns',
                    'nt',
                    'Other-control-number',
                    'pb',
                    'Personal-name',
                    'Personal-name-heading',
                    'Personal-name-see',
                    'Personal-name-seealso',
                    'pl',
                    'Place-publication',
                    'pn',
                    'popularity',
                    'pubdate',
                    'Publisher',
                    'Provider',
                    'pv',
                    'Reading-grade-level',
                    'Record-control-number',
                    'rcn',
                    'Record-type',
                    'rtype',
                    'se',
                    'See',
                    'See-also',
                    'sn',
                    'Stock-number',
                    'su',
                    'Subject',
                    'Subject-heading-thesaurus',
                    'Subject-name-personal',
                    'Subject-subdivision',
                    'Summary',
                    'Suppress',
                    'su-geo',
                    'su-na',
                    'su-to',
                    'su-ut',
                    'ut',
                    'Term-genre-form',
                    'Term-genre-form-heading',
                    'Term-genre-form-see',
                    'Term-genre-form-seealso',
                    'ti',
                    'Title',
                    'Title-cover',
                    'Title-series',
                    'Title-uniform',
                    'Title-uniform-heading',
                    'Title-uniform-see',
                    'Title-uniform-seealso',
                    'totalissues',
                    'yr',

                    # items indexes
                    'acqsource',
                    'barcode',
                    'bc',
                    'branch',
                    'ccode',
                    'classification-source',
                    'cn-sort',
                    'coded-location-qualifier',
                    'copynumber',
                    'damaged',
                    'datelastborrowed',
                    'datelastseen',
                    'holdingbranch',
                    'homebranch',
                    'issues',
                    'item',
                    'itemnumber',
                    'itype',
                    'Local-classification',
                    'location',
                    'lost',
                    'materials-specified',
                    'mc-ccode',
                    'mc-itype',
                    'mc-loc',
                    'notforloan',
                    'Number-local-acquisition',
                    'onloan',
                    'price',
                    'renewals',
                    'replacementprice',
                    'replacementpricedate',
                    'reserves',
                    'restricted',
                    'stack',
                    'stocknumber',
                    'inv',
                    'uri',
                    'withdrawn',

                    # subject related
                  );

    return \@indexes;
}

=head2 buildQuery

( $error, $query,
$simple_query, $query_cgi,
$query_desc, $limit,
$limit_cgi, $limit_desc,
$query_type ) = buildQuery ( $operators, $operands, $indexes, $limits, $sort_by, $scan, $lang);

Build queries and limits in CCL, CGI, Human,
handle truncation, stemming, field weighting, fuzziness, etc.

See verbose embedded documentation.


=cut

sub buildQuery {
    my ( $operators, $operands, $indexes, $limits, $sort_by, $scan, $lang) = @_;

    my $query_desc;

    # dereference
    my @operators = $operators ? @$operators : ();
    my @indexes   = $indexes   ? @$indexes   : ();
    my @operands  = $operands  ? @$operands  : ();
    my @limits    = $limits    ? @$limits    : ();
    my @sort_by   = $sort_by   ? @$sort_by   : ();

    my $stemming         = C4::Context->preference("QueryStemming")        || 0;
    my $auto_truncation  = C4::Context->preference("QueryAutoTruncate")    || 0;
    my $weight_fields    = C4::Context->preference("QueryWeightFields")    || 0;
    my $fuzzy_enabled    = C4::Context->preference("QueryFuzzy")           || 0;

    my $query        = $operands[0] // "";
    my $simple_query = $operands[0];

    # initialize the variables we're passing back
    my $query_cgi;
    my $query_type;

    my $limit = q{};
    my $limit_cgi;
    my $limit_desc;

    my $cclq       = 0;
    my $cclindexes = getIndexes();
    if ( $query !~ /\s*(ccl=|pqf=|cql=)/ ) {
        while ( !$cclq && $query =~ /(?:^|\W)([\w-]+)(,[\w-]+)*[:=]/g ) {
            my $dx = lc($1);
            $cclq = grep { lc($_) eq $dx } @$cclindexes;
        }
        $query = "ccl=$query" if $cclq;
    }

    # add limits
    my %group_OR_limits;
    my $availability_limit;
    foreach my $this_limit (@limits) {
        next unless $this_limit;
        if ( $this_limit =~ /available/ ) {
#
## 'available' is defined as (items.onloan is NULL) and (items.itemlost = 0)
## In English:
## all records not indexed in the onloan register (zebra) and all records with a value of lost equal to 0
            $availability_limit .=
"( (allrecords,AlwaysMatches='') and (not-onloan-count,st-numeric >= 1) and (lost,st-numeric=0) )";
            $limit_cgi  .= "&limit=available";
            $limit_desc .= "";
        }

        # group_OR_limits, prefixed by mc-
        # OR every member of the group
        elsif ( $this_limit =~ /mc/ ) {
            my ($k,$v) = split(/:/, $this_limit,2);
            if ( $k !~ /mc-i(tem)?type/ ) {
                # in case the mc-ccode value has complicating chars like ()'s inside it we wrap in quotes
                $this_limit =~ tr/"//d;
                $this_limit = $k.':"'.$v.'"';
            }

            $group_OR_limits{$k} .= " or " if $group_OR_limits{$k};
            $limit_desc      .= " or " if $group_OR_limits{$k};
            $group_OR_limits{$k} .= "$this_limit";
            $limit_cgi       .= "&limit=" . uri_escape_utf8($this_limit);
            $limit_desc      .= " $this_limit";
        }
        elsif ( $this_limit =~ '^multibranchlimit:|^branch:' ) {
            $limit_cgi  .= "&limit=" . uri_escape_utf8($this_limit);
            $limit .= " and " if $limit || $query;
            my $branchfield  = C4::Context->preference('SearchLimitLibrary');
            my @branchcodes;
            if(  $this_limit =~ '^multibranchlimit:' ){
                my ($group_id) = ( $this_limit =~ /^multibranchlimit:(.*)$/ );
                my $search_group = Koha::Library::Groups->find( $group_id );
                @branchcodes  = map { $_->branchcode } $search_group->all_libraries;
                @branchcodes = sort { $a cmp $b } @branchcodes;
            } else {
                @branchcodes = ( $this_limit =~ /^branch:(.*)$/ );
            }

            if (@branchcodes) {
                if ( $branchfield eq "homebranch" ) {
                    $this_limit = sprintf "(%s)", join " or ", map { 'homebranch: ' . $_ } @branchcodes;
                }
                elsif ( $branchfield eq "holdingbranch" ) {
                    $this_limit = sprintf "(%s)", join " or ", map { 'holdingbranch: ' . $_ } @branchcodes;
                }
                else {
                    $this_limit =  sprintf "(%s or %s)",
                      join( " or ", map { 'homebranch: ' . $_ } @branchcodes ),
                      join( " or ", map { 'holdingbranch: ' . $_ } @branchcodes );
                }
            }
            $limit .= "$this_limit";
            $limit_desc .= " $this_limit";
        } elsif ( $this_limit =~ '^search_filter:' ) {
            $limit_cgi  .= "&limit=" . uri_escape_utf8($this_limit);
            my ($filter_id) = ( $this_limit =~ /^search_filter:(.*)$/ );
            my $search_filter = Koha::SearchFilters->find( $filter_id );
            next unless $search_filter;
            my $expanded = $search_filter->expand_filter;
            my ( $error, undef, undef, undef, undef, $fixed_limit, undef, undef, undef ) = buildQuery ( undef, undef, undef, $expanded, undef, undef, $lang);
            $limit .= " and " if $limit || $query;
            $limit .= "$fixed_limit";
            $limit_desc .= " $limit";
        }

        # Regular old limits
        else {
            $limit .= " and " if $limit || $query;
            $limit      .= "$this_limit";
            $limit_cgi  .= "&limit=" . uri_escape_utf8($this_limit);
            $limit_desc .= " $this_limit";
        }
    }
    foreach my $k (keys (%group_OR_limits)) {
        $limit .= " and " if ( $query || $limit );
        $limit .= "($group_OR_limits{$k})";
    }
    if ($availability_limit) {
        $limit .= " and " if ( $query || $limit );
        $limit .= "($availability_limit)";
    }

# for handling ccl, cql, pqf queries in diagnostic mode, skip the rest of the steps
# DIAGNOSTIC ONLY!!
    if ( $query =~ /^ccl=/ ) {
        my $q=$';
        # This is needed otherwise ccl= and &limit won't work together, and
        # this happens when selecting a subject on the opac-detail page
        my $original_q = $q; # without available part
        $q .= $limit if $limit;
        return ( undef, $q, $q, "q=ccl=".uri_escape_utf8($q), $original_q, '', '', '', 'ccl' );
    }
    if ( $query =~ /^cql=/ ) {
        return ( undef, $', $', "q=cql=".uri_escape_utf8($'), $', '', '', '', 'cql' );
    }
    if ( $query =~ /^pqf=/ ) {
        $query_desc = $';
        $query_cgi = "q=pqf=".uri_escape_utf8($');
        return ( undef, $', $', $query_cgi, $query_desc, '', '', '', 'pqf' );
    }

    # pass nested queries directly
    # FIXME: need better handling of some of these variables in this case
    # Nested queries aren't handled well and this implementation is flawed and causes users to be
    # unable to search for anything containing () commenting out, will be rewritten for 3.4.0
#    if ( $query =~ /(\(|\))/ ) {
#        return (
#            undef,              $query, $simple_query, $query_cgi,
#            $query,             $limit, $limit_cgi,    $limit_desc,
#            'ccl'
#        );
#    }

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
            if ( ($operands[$i] // '') ne '' ) {
		$operands[$i]=~s/^\s+//;

              # A flag to determine whether or not to add the index to the query
                my $indexes_set;

# If the user is sophisticated enough to specify an index, turn off field weighting, and stemming handling
                if ( $operands[$i] =~ /\w(:|=)/ || $scan ) {
                    $weight_fields    = 0;
                    $stemming         = 0;
                } else {
                    $operands[$i] =~ s/\?/{?}/g; # need to escape question marks
                }
                my $operand = $operands[$i];
                my $index   = $indexes[$i] || 'kw';

                # Add index-specific attributes

                #Afaik, this 'yr' condition will only ever be met in the staff interface advanced search
                #for "Publication date", since typing 'yr:YYYY' into the search box produces a CCL query,
                #which is processed higher up in this sub. Other than that, year searches are typically
                #handled as limits which are not processed her either.

                # Search ranges: Date of Publication, st-numeric
                if ( $index =~ /(yr|st-numeric)/ ) {
                    #weight_fields/relevance search causes errors with date ranges
                    #In the case of YYYY-, it will only return records with a 'yr' of YYYY (not the range)
                    #In the case of YYYY-YYYY, it will return no results
                    $stemming = $auto_truncation = $weight_fields = $fuzzy_enabled = 0;
                }

                # Date of Acquisition
                elsif ( $index =~ /acqdate/ ) {
                    #stemming and auto_truncation would have zero impact since it already is YYYY-MM-DD format
                    #Weight_fields probably SHOULD be turned OFF, otherwise you'll get records floating to the
                      #top of the results just because they have lots of item records matching that date.
                    #Fuzzy actually only applies during _build_weighted_query, and is reset there anyway, so
                      #irrelevant here
                    $stemming = $auto_truncation = $weight_fields = $fuzzy_enabled = 0;
                }
                # ISBN,ISSN,Standard Number, don't need special treatment
                elsif ( $index eq 'nb' || $index eq 'ns' || $index eq 'hi' ) {
                    (
                        $stemming,      $auto_truncation,
                        $weight_fields, $fuzzy_enabled
                    ) = ( 0, 0, 0, 0 );

                    if ( $index eq 'nb' ) {
                        if ( C4::Context->preference("SearchWithISBNVariations") ) {
                            my @isbns = C4::Koha::GetVariationsOfISBN( $operand );
                            $operands[$i] = $operand =  '(nb=' . join(' OR nb=', @isbns) . ')';
                            $indexes[$i] = $index = 'kw';
                        }
                    }
                }

                # Set default structure attribute (word list)
                my $struct_attr = q{};
                unless ( $indexes_set || $index =~ /,(st-|phr|ext|wrdl)/ || $index =~ /^(nb|ns)$/ ) {
                    $struct_attr = ",wrdl";
                }

                # Some helpful index variants
                my $index_plus       = $index . $struct_attr . ':';
                my $index_plus_comma = $index . $struct_attr . ',';

                if ($auto_truncation){
                        unless ( $index =~ /,(st-|phr|ext)/ ) {
						#FIXME only valid with LTR scripts
						$operand=join(" ",map{
											(index($_,"*")>0?"$_":"$_*")
											 }split (/\s+/,$operand));
					}
				}

                # Detect Truncation
                my $truncated_operand = q{};
                my( $nontruncated, $righttruncated, $lefttruncated,
                    $rightlefttruncated, $regexpr
                ) = _detect_truncation( $operand, $index );

                Koha::Logger->get->debug(
                    "TRUNCATION: NON:>@$nontruncated< RIGHT:>@$righttruncated< LEFT:>@$lefttruncated< RIGHTLEFT:>@$rightlefttruncated< REGEX:>@$regexpr<");

                # Apply Truncation
                if (
                    scalar(@$righttruncated) + scalar(@$lefttruncated) +
                    scalar(@$rightlefttruncated) > 0 )
                {

               # Don't field weight or add the index to the query, we do it here
                    $indexes_set = 1;
                    undef $weight_fields;
                    my $previous_truncation_operand;
                    if (scalar @$nontruncated) {
                        $truncated_operand .= "$index_plus @$nontruncated ";
                        $previous_truncation_operand = 1;
                    }
                    if (scalar @$righttruncated) {
                        $truncated_operand .= "and " if $previous_truncation_operand;
                        $truncated_operand .= $index_plus_comma . "rtrn:@$righttruncated ";
                        $previous_truncation_operand = 1;
                    }
                    if (scalar @$lefttruncated) {
                        $truncated_operand .= "and " if $previous_truncation_operand;
                        $truncated_operand .= $index_plus_comma . "ltrn:@$lefttruncated ";
                        $previous_truncation_operand = 1;
                    }
                    if (scalar @$rightlefttruncated) {
                        $truncated_operand .= "and " if $previous_truncation_operand;
                        $truncated_operand .= $index_plus_comma . "rltrn:@$rightlefttruncated ";
                        $previous_truncation_operand = 1;
                    }
                }
                $operand = $truncated_operand if $truncated_operand;
                Koha::Logger->get->debug("TRUNCATED OPERAND: >$truncated_operand<");

                # Handle Stemming
                my $stemmed_operand = q{};
                $stemmed_operand = _build_stemmed_operand($operand, $lang)
										if $stemming;

                Koha::Logger->get->debug("STEMMED OPERAND: >$stemmed_operand<");

                # Handle Field Weighting
                my $weighted_operand = q{};
                if ($weight_fields) {
                    $weighted_operand = _build_weighted_query( $operand, $stemmed_operand, $index );
                    $operand = $weighted_operand;
                    $indexes_set = 1;
                }

                Koha::Logger->get->debug("FIELD WEIGHTED OPERAND: >$weighted_operand<");

                #Use relevance ranking when not using a weighted query (which adds relevance ranking of its own)

                #N.B. Truncation is mutually exclusive with Weighted Queries,
                #so even if QueryWeightFields is turned on, QueryAutoTruncate will turn it off, thus
                #the need for this relevance wrapper.
                $operand = "(rk=($operand))" unless $weight_fields;

                ($query,$query_cgi,$query_desc,$previous_operand) = _build_initial_query({
                    query => $query,
                    query_cgi => $query_cgi,
                    query_desc => $query_desc,
                    operator => ($operators[ $i - 1 ]) ? $operators[ $i - 1 ] : '',
                    parsed_operand => $operand,
                    original_operand => $operands[$i] // '',
                    index => $index,
                    index_plus => $index_plus,
                    indexes_set => $indexes_set,
                    previous_operand => $previous_operand,
                });

            }    #/if $operands
        }    # /for
    }
    Koha::Logger->get->debug("QUERY BEFORE LIMITS: >$query<");


    # Normalize the query and limit strings
    # This is flawed , means we can't search anything with : in it
    # if user wants to do ccl or cql, start the query with that
#    $query =~ s/:/=/g;
    #NOTE: We use several several different regexps here as you can't have variable length lookback assertions
    $query =~ s/(?<=(ti|au|pb|su|an|kw|mc|nb|ns)):/=/g;
    $query =~ s/(?<=(wrdl)):/=/g;
    $query =~ s/(?<=(trn|phr)):/=/g;
    $query =~ s/(?<=(st-numeric)):/=/g;
    $query =~ s/(?<=(st-year)):/=/g;
    $query =~ s/(?<=(st-date-normalized)):/=/g;

    # Removing warnings for later substitutions
    $query        //= q{};
    $query_desc   //= q{};
    $query_cgi    //= q{};
    $limit        //= q{};
    $limit_desc   //= q{};
    $limit_cgi    //= q{};
    $simple_query //= q{};
    $limit =~ s/:/=/g;
    for ( $query, $query_desc, $limit, $limit_desc ) {
        s/  +/ /g;    # remove extra spaces
        s/^ //g;     # remove any beginning spaces
        s/ $//g;     # remove any ending spaces
        s/==/=/g;    # remove double == from query
    }
    $query_cgi =~ s/^&//; # remove unnecessary & from beginning of the query cgi

    for ($query_cgi,$simple_query) {
        s/"//g;
    }
    # append the limit to the query
    $query .= " " . $limit;

    Koha::Logger->get->debug(
        sprintf "buildQuery returns\nQUERY:%s\nQUERY CGI:%s\nQUERY DESC:%s\nLIMIT:%s\nLIMIT CGI:%s\nLIMIT DESC:%s",
        $query, $query_cgi, $query_desc, $limit, $limit_cgi, $limit_desc );

    return (
        undef,              $query, $simple_query, $query_cgi,
        $query_desc,        $limit, $limit_cgi,    $limit_desc,
        $query_type
    );
}

=head2 _build_initial_query

  ($query, $query_cgi, $query_desc, $previous_operand) = _build_initial_query($initial_query_params);

  Build a section of the initial query containing indexes, operators, and operands.

=cut

sub _build_initial_query {
    my ($params) = @_;

    my $operator = "";
    if ($params->{previous_operand}){
        #If there is a previous operand, add a supplied operator or the default 'and'
        $operator = ($params->{operator}) ? ($params->{operator}) : 'AND';
    }

    #NOTE: indexes_set is typically set when doing truncation or field weighting
    my $operand = ($params->{indexes_set}) ? $params->{parsed_operand} : $params->{index_plus}.$params->{parsed_operand};

    #e.g. "kw,wrdl:test"
    #e.g. " and kw,wrdl:test"
    $params->{query} .= " " . $operator . " " . $operand;

    $params->{query_cgi} .= "&op=".uri_escape_utf8($operator) if $operator;
    $params->{query_cgi} .= "&idx=".uri_escape_utf8($params->{index}) if $params->{index};
    $params->{query_cgi} .= "&q=".uri_escape_utf8($params->{original_operand}) if ( $params->{original_operand} ne '' );

    #e.g. " and kw,wrdl: test"
    $params->{query_desc} .= " " . $operator . " " . ( $params->{index_plus} // q{} ) . " " . ( $params->{original_operand} // q{} );

    $params->{previous_operand} = 1 unless $params->{previous_operand}; #If there is no previous operand, mark this as one

    return ($params->{query}, $params->{query_cgi}, $params->{query_desc}, $params->{previous_operand});
}

=head2 searchResults

  my @search_results = searchResults($search_context, $searchdesc, $hits, 
                                     $results_per_page, $offset, $scan, 
                                     @marcresults);

Format results in a form suitable for passing to the template

=cut

# IMO this subroutine is pretty messy still -- it's responsible for
# building the HTML output for the template
sub searchResults {
    my ( $search_context, $searchdesc, $hits, $results_per_page, $offset, $scan, $marcresults, $xslt_variables ) = @_;
    my $dbh = C4::Context->dbh;
    my @newresults;

    require C4::Items;

    $search_context->{'interface'} = 'opac' if !$search_context->{'interface'} || $search_context->{'interface'} ne 'intranet';
    my ($is_opac, $hidelostitems);
    if ($search_context->{'interface'} eq 'opac') {
        $hidelostitems = C4::Context->preference('hidelostitems');
        $is_opac       = 1;
    }

    my $record_processor = Koha::RecordProcessor->new({
        filters => 'ViewPolicy'
    });

    #Build branchnames hash
    my %branches = map { $_->branchcode => $_->branchname } Koha::Libraries->search({}, { order_by => 'branchname' })->as_list;

# FIXME - We build an authorised values hash here, using the default framework
# though it is possible to have different authvals for different fws.

    my $shelflocations =
      { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.location' } ) };

    # get notforloan authorised value list (see $shelflocations  FIXME)
    my $av = Koha::MarcSubfieldStructures->search({ frameworkcode => '', kohafield => 'items.notforloan', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
    my $notforloan_authorised_value = $av->count ? $av->next->authorised_value : undef;

    #Get itemtype hash
    my $itemtypes = Koha::ItemTypes->search_with_localization;
    my %itemtypes = map { $_->{itemtype} => $_ } @{ $itemtypes->unblessed };

    #search item field code
    my ($itemtag, undef) = &GetMarcFromKohaField( "items.itemnumber" );

    ## find column names of items related to MARC
    my %subfieldstosearch;
    my @columns = Koha::Database->new()->schema()->resultset('Item')->result_source->columns;
    for my $column ( @columns ) {
        my ( $tagfield, $tagsubfield ) =
          &GetMarcFromKohaField( "items." . $column );
        if ( defined $tagsubfield ) {
            $subfieldstosearch{$column} = $tagsubfield;
        }
    }

    # handle which records to actually retrieve
    my $times; # Times is which record to process up to
    if ( $hits && $offset + $results_per_page <= $hits ) {
        $times = $offset + $results_per_page;
    }
    else {
        $times = $hits; # If less hits than results_per_page+offset we go to the end
    }

    my $marcflavour = C4::Context->preference("marcflavour");
    # We get the biblionumber position in MARC
    my ($bibliotag,$bibliosubf)=GetMarcFromKohaField( 'biblio.biblionumber' );

    # set stuff for XSLT processing here once, not later again for every record we retrieved

    my $userenv = C4::Context->userenv;
    my $logged_in_user
        = ( defined $userenv and $userenv->{number} )
        ? Koha::Patrons->find( $userenv->{number} )
        : undef;
    my $patron_category_hide_lost_items = ($logged_in_user) ? $logged_in_user->category->hidelostitems : 0;

    # loop through all of the records we've retrieved
    for ( my $i = $offset ; $i <= $times - 1 ; $i++ ) {

        my $marcrecord;
        if ($scan) {
            # For Scan searches we built USMARC data
            $marcrecord = MARC::Record->new_from_usmarc( $marcresults->[$i]);
        } else {
            # Normal search, render from Zebra's output
            $marcrecord = new_record_from_zebra(
                'biblioserver',
                $marcresults->[$i]
            );

            if ( ! defined $marcrecord ) {
                warn "ERROR DECODING RECORD - $@: " . $marcresults->[$i];
                next;
            }
        }

        my $fw = $scan
             ? undef
             : $bibliotag < 10
               ? GetFrameworkCode($marcrecord->field($bibliotag)->data)
               : GetFrameworkCode($marcrecord->subfield($bibliotag,$bibliosubf));

        SetUTF8Flag($marcrecord);
        my $oldbiblio = TransformMarcToKoha( $marcrecord, $fw, 'no_items' );
        $oldbiblio->{result_number} = $i + 1;

		$oldbiblio->{normalized_upc}  = GetNormalizedUPC(       $marcrecord,$marcflavour);
		$oldbiblio->{normalized_ean}  = GetNormalizedEAN(       $marcrecord,$marcflavour);
		$oldbiblio->{normalized_oclc} = GetNormalizedOCLCNumber($marcrecord,$marcflavour);
        $oldbiblio->{normalized_isbn} = GetNormalizedISBN($oldbiblio->{isbn},$marcrecord,$marcflavour); # Use existing ISBN from record if we got one
		$oldbiblio->{content_identifier_exists} = 1 if ($oldbiblio->{normalized_isbn} or $oldbiblio->{normalized_oclc} or $oldbiblio->{normalized_ean} or $oldbiblio->{normalized_upc});

		# edition information, if any
        $oldbiblio->{edition} = $oldbiblio->{editionstatement};

        my $itemtype = $oldbiblio->{itemtype} ? $itemtypes{$oldbiblio->{itemtype}} : undef;
        # add imageurl to itemtype if there is one
        $oldbiblio->{imageurl} = $itemtype ? getitemtypeimagelocation( $search_context->{'interface'}, $itemtype->{imageurl} ) : q{};
        # Build summary if there is one (the summary is defined in the itemtypes table)
        $oldbiblio->{description} = $itemtype ? $itemtype->{translated_description} : q{};

        # Pull out the items fields
        my @fields = $marcrecord->field($itemtag);
        $marcrecord->delete_fields( @fields ) unless C4::Context->preference('PassItemMarcToXSLT');
        my $marcflavor = C4::Context->preference("marcflavour");

        # adding linked items that belong to host records
        if ( C4::Context->preference('EasyAnalyticalRecords') ) {
            my $analyticsfield = '773';
            if ($marcflavor eq 'MARC21') {
                $analyticsfield = '773';
            } elsif ($marcflavor eq 'UNIMARC') {
                $analyticsfield = '461';
            }
            foreach my $hostfield ( $marcrecord->field($analyticsfield)) {
                my $hostbiblionumber = $hostfield->subfield("0");
                my $linkeditemnumber = $hostfield->subfield("9");
                if( $hostbiblionumber ) {
                    my $linkeditemmarc = C4::Items::GetMarcItem( $hostbiblionumber, $linkeditemnumber );
                    if ($linkeditemmarc) {
                        my $linkeditemfield = $linkeditemmarc->field($itemtag);
                        if ($linkeditemfield) {
                            push( @fields, $linkeditemfield );
                        }
                    }
                }
            }
        }

        # Setting item statuses for display
        my @available_items_loop;
        my @onloan_items_loop;
        my @other_items_loop;

        my $available_items;
        my $onloan_items;
        my $other_items;

        my $ordered_count         = 0;
        my $available_count       = 0;
        my $onloan_count          = 0;
        my $longoverdue_count     = 0;
        my $other_count           = 0;
        my $withdrawn_count        = 0;
        my $itemlost_count        = 0;
        my $hideatopac_count      = 0;
        my $itembinding_count     = 0;
        my $itemdamaged_count     = 0;
        my $item_in_transit_count = 0;
        my $item_onhold_count     = 0;
        my $notforloan_count      = 0;
        my $item_recalled_count   = 0;
        my $items_count           = scalar(@fields);
        my $maxitems_pref = C4::Context->preference('maxItemsinSearchResults');
        my $maxitems = $maxitems_pref ? $maxitems_pref - 1 : 1;
        my @hiddenitems; # hidden itemnumbers based on OpacHiddenItems syspref

        # loop through every item
        foreach my $field (@fields) {
            my $item;

            # populate the items hash
            foreach my $code ( keys %subfieldstosearch ) {
                $item->{$code} = $field->subfield( $subfieldstosearch{$code} );
            }
            $item->{description} = $itemtypes{ $item->{itype} }{translated_description} if $item->{itype};

	        # OPAC hidden items
            if ($is_opac) {
                # hidden because lost
                if ($hidelostitems && $item->{itemlost}) {
                    push @hiddenitems, $item->{itemnumber};
                    $hideatopac_count++;
                    next;
                }
                # hidden based on OpacHiddenItems syspref
                my @hi = C4::Items::GetHiddenItemnumbers({ items=> [ $item ], borcat => $search_context->{category} });
                if (scalar @hi) {
                    push @hiddenitems, @hi;
                    $hideatopac_count++;
                    next;
                }
            }

            my $hbranch     = C4::Context->preference('StaffSearchResultsDisplayBranch');
            my $otherbranch = $hbranch eq 'homebranch' ? 'holdingbranch' : 'homebranch';

            # set item's branch name, use HomeOrHoldingBranch syspref first, fall back to the other one
            if ($item->{$hbranch}) {
                $item->{'branchname'} = $branches{$item->{$hbranch}};
            }
            elsif ($item->{$otherbranch}) {	# Last resort
                $item->{'branchname'} = $branches{$item->{$otherbranch}};
            }

            my $prefix =
                ( $item->{$hbranch} ? $item->{$hbranch} . '--' : q{} )
              . ( $item->{location} ? $item->{location} : q{} )
              . ( $item->{itype}    ? $item->{itype}    : q{} )
              . ( $item->{itemcallnumber} ? $item->{itemcallnumber} : q{} );
# For each grouping of items (onloan, available, unavailable), we build a key to store relevant info about that item
            if ( $item->{onloan}
                and $logged_in_user
                and !( $patron_category_hide_lost_items and $item->{itemlost} ) )
            {
                $onloan_count++;
                my $key = $prefix . $item->{onloan} . $item->{barcode};
                $onloan_items->{$key}->{due_date} = $item->{onloan};
                $onloan_items->{$key}->{count}++ if $item->{$hbranch};
                $onloan_items->{$key}->{branchname}     = $item->{branchname};
                $onloan_items->{$key}->{location}       = $shelflocations->{ $item->{location} } if $item->{location};
                $onloan_items->{$key}->{itemcallnumber} = $item->{itemcallnumber};
                $onloan_items->{$key}->{description}    = $item->{description};
                $onloan_items->{$key}->{imageurl} =
                  getitemtypeimagelocation( $search_context->{'interface'}, $itemtypes{ $item->{itype} }->{imageurl} );

                # if something's checked out and lost, mark it as 'long overdue'
                if ( $item->{itemlost} ) {
                    $onloan_items->{$key}->{longoverdue}++;
                    $longoverdue_count++;
                }
            }

         # items not on loan, but still unavailable ( lost, withdrawn, damaged )
            else {

                my $itemtype = C4::Context->preference("item-level_itypes")? $item->{itype}: $oldbiblio->{itemtype};
                $item->{notforloan} = 1 if !$item->{notforloan} &&
                    $itemtype && $itemtypes{ $itemtype }->{notforloan};

                # item is on order
                if ( $item->{notforloan} < 0 ) {
                    $ordered_count++;
                } elsif ( $item->{notforloan} > 0 ) {
                    $notforloan_count++;
                }

                # is item in transit?
                my $transfertwhen = '';
                my ($transfertfrom, $transfertto);

                # is item on the reserve shelf?
                my $reservestatus = '';

                # is item a waiting recall?
                my $recallstatus = '';

                unless ($item->{withdrawn}
                        || $item->{itemlost}
                        || $item->{damaged}
                        || $item->{notforloan}
                        || ( C4::Context->preference('MaxSearchResultsItemsPerRecordStatusCheck')
                        && $items_count > C4::Context->preference('MaxSearchResultsItemsPerRecordStatusCheck') ) ) {

                    # A couple heuristics to limit how many times
                    # we query the database for item transfer information, sacrificing
                    # accuracy in some cases for speed;
                    #
                    # 1. don't query if item has one of the other statuses
                    # 2. don't check transit status if the bib has
                    #    more than 20 items
                    #
                    # FIXME: to avoid having the query the database like this, and to make
                    #        the in transit status count as unavailable for search limiting,
                    #        should map transit status to record indexed in Zebra.
                    #
                    ($transfertwhen, $transfertfrom, $transfertto) = C4::Circulation::GetTransfers($item->{itemnumber});
                    $reservestatus = C4::Reserves::GetReserveStatus( $item->{itemnumber} );
                    if ( C4::Context->preference('UseRecalls') ) {
                        if ( Koha::Recalls->search({ item_id => $item->{itemnumber}, status => 'waiting' })->count ) {
                            $recallstatus = 'Waiting';
                        }
                    }
                }

                # item is withdrawn, lost, damaged, not for loan, reserved or in transit
                if (   $item->{withdrawn}
                    || $item->{itemlost}
                    || $item->{damaged}
                    || $item->{notforloan}
                    || $reservestatus eq 'Waiting'
                    || $recallstatus eq 'Waiting'
                    || ($transfertwhen && $transfertwhen ne ''))
                {
                    $withdrawn_count++        if $item->{withdrawn};
                    $itemlost_count++        if $item->{itemlost};
                    $itemdamaged_count++     if $item->{damaged};
                    $item_in_transit_count++ if $transfertwhen && $transfertwhen ne '';
                    $item_onhold_count++     if $reservestatus eq 'Waiting';
                    $item_recalled_count++   if $recallstatus eq 'Waiting';
                    $item->{status} = ($item->{withdrawn}//q{}) . "-" . ($item->{itemlost}//q{}) . "-" . ($item->{damaged}//q{}) . "-" . ($item->{notforloan}//q{});

                    $other_count++;

                    my $key = $prefix . $item->{status};
                    foreach (qw(withdrawn itemlost damaged branchname itemcallnumber)) {
                        $other_items->{$key}->{$_} = $item->{$_};
                    }
                    $other_items->{$key}->{intransit} = ( $transfertwhen ne '' ) ? 1 : 0;
                    $other_items->{$key}->{recalled} = ($recallstatus) ? 1 : 0;
                    $other_items->{$key}->{onhold} = ($reservestatus) ? 1 : 0;
                    $other_items->{$key}->{notforloan} = GetAuthorisedValueDesc('','',$item->{notforloan},'','',$notforloan_authorised_value) if $notforloan_authorised_value and $item->{notforloan};
                    $other_items->{$key}->{count}++ if $item->{$hbranch};
                    $other_items->{$key}->{location} = $shelflocations->{ $item->{location} } if $item->{location};
                    $other_items->{$key}->{description} = $item->{description};
                    $other_items->{$key}->{imageurl} = getitemtypeimagelocation( $search_context->{'interface'}, $itemtypes{ $item->{itype}//q{} }->{imageurl} );
                }
                # item is available
                else {
                    $available_count++;
                    $available_items->{$prefix}->{count}++ if $item->{$hbranch};
                    foreach (qw(branchname itemcallnumber description)) {
                        $available_items->{$prefix}->{$_} = $item->{$_};
                    }
                    $available_items->{$prefix}->{location} = $shelflocations->{ $item->{location} } if $item->{location};
                    $available_items->{$prefix}->{imageurl} = getitemtypeimagelocation( $search_context->{'interface'}, $itemtypes{ $item->{itype}//q{} }->{imageurl} );
                }
            }
        }    # notforloan, item level and biblioitem level

        # if all items are hidden, do not show the record
        if ( C4::Context->preference('OpacHiddenItemsHidesRecord') && $items_count > 0 && $hideatopac_count == $items_count) {
            next;
        }

        my ( $availableitemscount, $onloanitemscount, $otheritemscount );
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
        # we fetched the sysprefs already before the loop through all retrieved record!
        if (!$scan) {
            $record_processor->options({
                frameworkcode => $fw,
                interface     => $search_context->{'interface'}
            });

            $record_processor->process($marcrecord);

            $oldbiblio->{XSLTResultsRecord} = XSLTParse4Display(
                {
                    biblionumber => $oldbiblio->{biblionumber},
                    record       => $marcrecord,
                    xsl_syspref  => (
                        $is_opac
                        ? 'OPACXSLTResultsDisplay'
                        : 'XSLTResultsDisplay'
                    ),
                    fix_amps       => 1,
                    hidden_items   => \@hiddenitems,
                    xslt_variables => $xslt_variables
                }
            );
        }

        my $biblio_object = Koha::Biblios->find( $oldbiblio->{biblionumber} );
        $oldbiblio->{biblio_object} = $biblio_object;

        my $can_place_holds = 1;
        # if biblio level itypes are used and itemtype is notforloan, it can't be reserved either
        if (!C4::Context->preference("item-level_itypes")) {
            if ($itemtype && $itemtype->{notforloan}) {
                $can_place_holds = 0;
            }
        } else {
            $can_place_holds = $biblio_object->items->filter_by_for_hold()->count if $biblio_object;
        }
        $oldbiblio->{norequests} = 1 unless $can_place_holds;
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
        $oldbiblio->{withdrawncount}        = $withdrawn_count;
        $oldbiblio->{itemlostcount}        = $itemlost_count;
        $oldbiblio->{damagedcount}         = $itemdamaged_count;
        $oldbiblio->{intransitcount}       = $item_in_transit_count;
        $oldbiblio->{onholdcount}          = $item_onhold_count;
        $oldbiblio->{recalledcount}        = $item_recalled_count;
        $oldbiblio->{orderedcount}         = $ordered_count;
        $oldbiblio->{notforloancount}      = $notforloan_count;

        if (C4::Context->preference("AlternateHoldingsField") && $items_count == 0) {
            my $fieldspec = C4::Context->preference("AlternateHoldingsField");
            my $subfields = substr $fieldspec, 3;
            my $holdingsep = C4::Context->preference("AlternateHoldingsSeparator") || ' ';
            my @alternateholdingsinfo = ();
            my @holdingsfields = $marcrecord->field(substr $fieldspec, 0, 3);

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

            $oldbiblio->{'ALTERNATEHOLDINGS'} = \@alternateholdingsinfo;
        }

        push( @newresults, $oldbiblio );
    }

    return @newresults;
}

=head2 enabled_staff_search_views

%hash = enabled_staff_search_views()

This function returns a hash that contains three flags obtained from the system
preferences, used to determine whether a particular staff search results view
is enabled.

=over 2

=item C<Output arg:>

    * $hash{can_view_MARC} is true only if the MARC view is enabled
    * $hash{can_view_ISBD} is true only if the ISBD view is enabled
    * $hash{can_view_labeledMARC} is true only if the Labeled MARC view is enabled

=item C<usage in the script:>

=back

$template->param ( C4::Search::enabled_staff_search_views );

=cut

sub enabled_staff_search_views
{
	return (
		can_view_MARC			=> C4::Context->preference('viewMARC'),			# 1 if the staff search allows the MARC view
		can_view_ISBD			=> C4::Context->preference('viewISBD'),			# 1 if the staff search allows the ISBD view
		can_view_labeledMARC	=> C4::Context->preference('viewLabeledMARC'),	# 1 if the staff search allows the Labeled MARC view
	);
}

=head2 z3950_search_args

$arrayref = z3950_search_args($matchpoints)

This function returns an array reference that contains the search parameters to be
passed to the Z39.50 search script (z3950_search.pl). The array elements
are hash refs whose keys are name and value, and whose values are the
name of a search parameter, the value of that search parameter and the URL encoded
value of that parameter.

The search parameter names are lccn, isbn, issn, title, author, dewey and subject.

The search parameter values are obtained from the bibliographic record whose
data is in a hash reference in $matchpoints, as returned by Biblio::GetBiblioData().

If $matchpoints is a scalar, it is assumed to be an unnamed query descriptor, e.g.
a general purpose search argument. In this case, the returned array contains only
entry: the key is 'title' and the value is derived from $matchpoints.

If a search parameter value is undefined or empty, it is not included in the returned
array.

The returned array reference may be passed directly to the template parameters.

=over 2

=item C<Output arg:>

    * $array containing hash refs as described above

=item C<usage in the script:>

=back

$data = Biblio::GetBiblioData($bibno);
$template->param ( MYLOOP => C4::Search::z3950_search_args($data) )

*OR*

$template->param ( MYLOOP => C4::Search::z3950_search_args($searchscalar) )

=cut

sub z3950_search_args {
    my $bibrec = shift;

    my $isbn_string = ref( $bibrec ) ? $bibrec->{title} : $bibrec;
    my $isbn = Business::ISBN->new( $isbn_string );

    if (defined $isbn && $isbn->is_valid)
    {
        if ( ref($bibrec) ) {
            $bibrec->{isbn} = $isbn_string;
            $bibrec->{title} = undef;
        } else {
            $bibrec = { isbn => $isbn_string };
        }
    }
    else {
        $bibrec = { title => $bibrec } if !ref $bibrec;
    }
    my $array = [];
    for my $field (qw/ lccn isbn issn title author dewey subject /)
    {
        push @$array, { name => $field, value => $bibrec->{$field} }
          if defined $bibrec->{$field};
    }
    return $array;
}

=head2 GetDistinctValues($field);

C<$field> is a reference to the fields array

=cut

sub GetDistinctValues {
    my ($fieldname,$string)=@_;
    # returns a reference to a hash of references to branches...
    if ($fieldname=~/\./){
			my ($table,$column)=split /\./, $fieldname;
			my $dbh = C4::Context->dbh;
			my $sth = $dbh->prepare("select DISTINCT($column) as value, count(*) as cnt from $table ".($string?" where $column like \"$string%\"":"")."group by value order by $column ");
			$sth->execute;
			my $elements=$sth->fetchall_arrayref({});
			return $elements;
   }
   else {
		$string||= qq("");
		my @servers=qw<biblioserver authorityserver>;
		my (@zconns,@results);
        for ( my $i = 0 ; $i < @servers ; $i++ ) {
        	$zconns[$i] = C4::Context->Zconn( $servers[$i], 1 );
			$results[$i] =
                      $zconns[$i]->scan(
                        ZOOM::Query::CCL2RPN->new( qq"$fieldname $string", $zconns[$i])
                      );
		}
		# The big moment: asynchronously retrieve results from all servers
		my @elements;
        _ZOOM_event_loop(
            \@zconns,
            \@results,
            sub {
                my ( $i, $size ) = @_;
                for ( my $j = 0 ; $j < $size ; $j++ ) {
                    my %hashscan;
                    @hashscan{qw(value cnt)} =
                      $results[ $i - 1 ]->display_term($j);
                    push @elements, \%hashscan;
                }
            }
        );
		return \@elements;
   }
}

=head2 _ZOOM_event_loop

    _ZOOM_event_loop(\@zconns, \@results, sub {
        my ( $i, $size ) = @_;
        ....
    } );

Processes a ZOOM event loop and passes control to a closure for
processing the results, and destroying the resultsets.

=cut

sub _ZOOM_event_loop {
    my ($zconns, $results, $callback) = @_;
    while ( ( my $i = ZOOM::event( $zconns ) ) != 0 ) {
        my $ev = $zconns->[ $i - 1 ]->last_event();
        if ( $ev == ZOOM::Event::ZEND ) {
            next unless $results->[ $i - 1 ];
            my $size = $results->[ $i - 1 ]->size();
            if ( $size > 0 ) {
                $callback->($i, $size);
            }
        }
    }

    foreach my $result (@$results) {
        $result->destroy();
    }
}

=head2 new_record_from_zebra

Given raw data from a searchengine result set, return a MARC::Record object

This helper function is needed to take into account all the involved
system preferences and configuration variables to properly create the
MARC::Record object.

If we are using GRS-1, then the raw data we get from Zebra should be USMARC
data. If we are using DOM, then it has to be MARCXML.

If we are using elasticsearch, it'll already be a MARC::Record and this
function needs a new name.

=cut

sub new_record_from_zebra {

    my $server   = shift;
    my $raw_data = shift;
    # Set the default indexing modes
    my $search_engine = C4::Context->preference("SearchEngine");
    if ($search_engine eq 'Elasticsearch') {
        return ref $raw_data eq 'MARC::Record' ? $raw_data : MARC::Record->new_from_xml( $raw_data, 'UTF-8' );
    }
    my $index_mode = ( $server eq 'biblioserver' )
                        ? C4::Context->config('zebra_bib_index_mode') // 'dom'
                        : C4::Context->config('zebra_auth_index_mode') // 'dom';

    my $marc_record =  eval {
        if ( $index_mode eq 'dom' ) {
            MARC::Record->new_from_xml( $raw_data, 'UTF-8' );
        } else {
            MARC::Record->new_from_usmarc( $raw_data );
        }
    };

    if ($@) {
        return;
    } else {
        return $marc_record;
    }

}

END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
