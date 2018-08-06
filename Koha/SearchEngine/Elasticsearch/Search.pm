package Koha::SearchEngine::Elasticsearch::Search;

# Copyright 2014 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::SearchEngine::Elasticsearch::Search - search functions for Elasticsearch

=head1 SYNOPSIS

    my $searcher =
      Koha::SearchEngine::Elasticsearch::Search->new( { index => $index } );
    my $builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new(
        { index => $index } );
    my $query = $builder->build_query('perl');
    my $results = $searcher->search($query);
    print "There were " . $results->total . " results.\n";
    $results->each(sub {
        push @hits, @_[0];
    });

=head1 METHODS

=cut

use Modern::Perl;

use base qw(Koha::SearchEngine::Elasticsearch);
use C4::Context;
use C4::AuthoritiesMarc;
use Koha::ItemTypes;
use Koha::AuthorisedValues;
use Koha::SearchEngine::QueryBuilder;
use Koha::SearchEngine::Search;
use MARC::Record;
use Catmandu::Store::ElasticSearch;

use Data::Dumper; #TODO remove
use Carp qw(cluck);

Koha::SearchEngine::Elasticsearch::Search->mk_accessors(qw( store ));

=head2 search

    my $results = $searcher->search($query, $page, $count, %options);

Run a search using the query. It'll return C<$count> results, starting at page
C<$page> (C<$page> counts from 1, anything less that, or C<undef> becomes 1.)
C<$count> is also the number of entries on a page.

C<%options> is a hash containing extra options:

=over 4

=item offset

If provided, this overrides the C<$page> value, and specifies the record as
an offset (i.e. the number of the record to start with), rather than a page.

=back

Returns

=cut

sub search {
    my ($self, $query, $page, $count, %options) = @_;

    my $params = $self->get_elasticsearch_params();
    my %paging;
    # 20 is the default number of results per page
    $paging{limit} = $count || 20;
    # ES/Catmandu doesn't want pages, it wants a record to start from.
    if (exists $options{offset}) {
        $paging{start} = $options{offset};
    } else {
        $page = (!defined($page) || ($page <= 0)) ? 0 : $page - 1;
        $paging{start} = $page * $paging{limit};
    }
    $self->store(
        Catmandu::Store::ElasticSearch->new(
            %$params,
        )
    ) unless $self->store;
    my $results = eval {
        $self->store->bag->search( %$query, %paging );
    };
    if ($@) {
        die $self->process_error($@);
    }
    return $results;
}

=head2 count

    my $count = $searcher->count($query);

This mimics a search request, but just gets the result count instead. That's
faster than pulling all the data in, usually.

=cut

sub count {
    my ( $self, $query ) = @_;

    my $params = $self->get_elasticsearch_params();
    $self->store(
        Catmandu::Store::ElasticSearch->new( %$params, trace_calls => 0, ) )
      unless $self->store;

    my $search = $self->store->bag->search( %$query);
    my $count = $search->total() || 0;
    return $count;
}

=head2 search_compat

    my ( $error, $results, $facets ) = $search->search_compat(
        $query,            $simple_query, \@sort_by,       \@servers,
        $results_per_page, $offset,       $expanded_facet, $branches,
        $query_type,       $scan
      )

A search interface somewhat compatible with L<C4::Search->getRecords>. Anything
that is returned in the query created by build_query_compat will probably
get ignored here, along with some other things (like C<@servers>.)

=cut

sub search_compat {
    my (
        $self,     $query,            $simple_query, $sort_by,
        $servers,  $results_per_page, $offset,       $expanded_facet,
        $branches, $query_type,       $scan
    ) = @_;
    my %options;
    if ( !defined $offset or $offset < 0 ) {
        $offset = 0;
    }
    $options{offset} = $offset;
    $options{expanded_facet} = $expanded_facet;
    my $results = $self->search($query, undef, $results_per_page, %options);

    # Convert each result into a MARC::Record
    my (@records, $index);
    $index = $offset; # opac-search expects results to be put in the
        # right place in the array, according to $offset
    $results->each(sub {
            # The results come in an array for some reason
            my $marc_json = $_[0]->{record};
            my $marc = $self->json2marc($marc_json);
            $records[$index++] = $marc;
        });
    # consumers of this expect a name-spaced result, we provide the default
    # configuration.
    my %result;
    $result{biblioserver}{hits} = $results->total;
    $result{biblioserver}{RECORDS} = \@records;
    return (undef, \%result, $self->_convert_facets($results->{aggregations}, $expanded_facet));
}

=head2 search_auth_compat

    my ( $results, $total ) =
      $searcher->search_auth_compat( $query, $page, $count, %options );

This has a similar calling convention to L<search>, however it returns its
results in a form the same as L<C4::AuthoritiesMarc::SearchAuthorities>.

=cut

sub search_auth_compat {
    my $self = shift;

    # TODO handle paging
    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $res      = $self->search(@_);
    my $bib_searcher = Koha::SearchEngine::Elasticsearch::Search->new({index => 'biblios'});
    my @records;
    $res->each(
        sub {
            my %result;
            my $record    = $_[0];
            my $marc_json = $record->{record};

            # I wonder if these should be real values defined in the mapping
            # rather than hard-coded conversions.
            # Handle legacy nested arrays indexed with splitting enabled.
            my $authid = $record->{ 'Local-number' }[0];
            $authid = @$authid[0] if (ref $authid eq 'ARRAY');
            $result{authid} = $authid;

            # TODO put all this info into the record at index time so we
            # don't have to go and sort it all out now.
            my $authtypecode = $record->{authtype};
            my $rs           = $schema->resultset('AuthType')
              ->search( { authtypecode => $authtypecode } );

            # FIXME there's an assumption here that we will get a result.
            # the original code also makes an assumption that some provided
            # authtypecode may sometimes be used instead of the one stored
            # with the record. It's not documented why this is the case, so
            # it's not reproduced here yet.
            my $authtype           = $rs->single;
            my $auth_tag_to_report = $authtype ? $authtype->auth_tag_to_report : "";
            my $marc               = $self->json2marc($marc_json);
            my $mainentry          = $marc->field($auth_tag_to_report);
            my $reported_tag;
            if ($mainentry) {
                foreach ( $mainentry->subfields() ) {
                    $reported_tag .= '$' . $_->[0] . $_->[1];
                }
            }
            # Turn the resultset into a hash
            $result{authtype}     = $authtype ? $authtype->authtypetext : $authtypecode;
            $result{reported_tag} = $reported_tag;

            # Reimplementing BuildSummary is out of scope because it'll be hard
            $result{summary} =
              C4::AuthoritiesMarc::BuildSummary( $marc, $result{authid},
                $authtypecode );
            $result{used} = $self->count_auth_use($bib_searcher, $authid);
            push @records, \%result;
        }
    );
    return ( \@records, $res->total );
}

=head2 count_auth_use

    my $count = $auth_searcher->count_auth_use($bib_searcher, $authid);

This runs a search to determine the number of records that reference the
specified authid. C<$bib_searcher> must be something compatible with
elasticsearch, as the query is built in this function.

=cut

sub count_auth_use {
    my ($self, $bib_searcher, $authid) = @_;

    my $query = {
        query => {
            bool => {
#                query  => { match_all => {} },
                filter => { term      => { an => $authid } }
            }
        }
    };
    $bib_searcher->count($query);
}

=head2 simple_search_compat

    my ( $error, $marcresults, $total_hits ) =
      $searcher->simple_search( $query, $offset, $max_results, %options );

This is a simpler interface to the searching, intended to be similar enough to
L<C4::Search::SimpleSearch>.

Arguments:

=over 4

=item C<$query>

A thing to search for. It could be a simple string, or something constructed
with the appropriate QueryBuilder module.

=item C<$offset>

How many results to skip from the start of the results.

=item C<$max_results>

The max number of results to return. The default is 100 (because unlimited
is a pretty terrible thing to do.)

=item C<%options>

These options are unused by Elasticsearch

=back

Returns:

=over 4

=item C<$error>

if something went wrong, this'll contain some kind of error
message.

=item C<$marcresults>

an arrayref of MARC::Records (note that this is different from the
L<C4::Search> version which will return plain XML, but too bad.)

=item C<$total_hits>

the total number of results that this search could have returned.

=back

=cut

sub simple_search_compat {
    my ($self, $query, $offset, $max_results) = @_;

    return ('No query entered', undef, undef) unless $query;

    my %options;
    $offset = 0 if not defined $offset or $offset < 0;
    $options{offset} = $offset;
    $max_results //= 100;

    unless (ref $query) {
        # We'll push it through the query builder to sanitise everything.
        my $qb = Koha::SearchEngine::QueryBuilder->new({index => $self->index});
        (undef,$query) = $qb->build_query_compat(undef, [$query]);
    }
    my $results = $self->search($query, undef, $max_results, %options);
    my @records;
    $results->each(sub {
            # The results come in an array for some reason
            my $marc_json = $_[0]->{record};
            my $marc = $self->json2marc($marc_json);
            push @records, $marc;
        });
    return (undef, \@records, $results->total);
}

=head2 extract_biblionumber

    my $biblionumber = $searcher->extract_biblionumber( $searchresult );

$searchresult comes from simple_search_compat.

Returns the biblionumber from the search result record.

=cut

sub extract_biblionumber {
    my ( $self, $searchresultrecord ) = @_;
    return Koha::SearchEngine::Search::extract_biblionumber( $searchresultrecord );
}

=head2 json2marc

    my $marc = $self->json2marc($marc_json);

Converts the form of marc (based on its JSON, but as a Perl structure) that
Catmandu stores into a MARC::Record object.

=cut

sub json2marc {
    my ( $self, $marcjson ) = @_;

    my $marc = MARC::Record->new();
    $marc->encoding('UTF-8');

    # fields are like:
    # [ '245', '1', '2', 'a' => 'Title', 'b' => 'Subtitle' ]
    # or
    # [ '001', undef, undef, '_', 'a value' ]
    # conveniently, this is the form that MARC::Field->new() likes
    foreach my $field (@$marcjson) {
        next if @$field < 5;
        if ( $field->[0] eq 'LDR' ) {
            $marc->leader( $field->[4] );
        }
        else {
            my $tag = $field->[0];
            my $marc_field;
            if ( MARC::Field->is_controlfield_tag( $field->[0] ) ) {
                $marc_field = MARC::Field->new($field->[0], $field->[4]);
            } else {
                $marc_field = MARC::Field->new(@$field);
            }
            $marc->append_fields($marc_field);
        }
    }
    return $marc;
}

=head2 max_result_window

Returns the maximum number of results that can be fetched

This directly requests Elasticsearch for the setting index.max_result_window (or
the default value for this setting in case it is not set)

=cut

sub max_result_window {
    my ($self) = @_;

    $self->store(
        Catmandu::Store::ElasticSearch->new(%{ $self->get_elasticsearch_params })
    ) unless $self->store;

    my $index_name = $self->store->index_name;
    my $settings = $self->store->es->indices->get_settings(
        index  => $index_name,
        params => { include_defaults => 1, flat_settings => 1 },
    );

    my $max_result_window = $settings->{$index_name}->{settings}->{'index.max_result_window'};
    $max_result_window //= $settings->{$index_name}->{defaults}->{'index.max_result_window'};

    return $max_result_window;
}

=head2 _convert_facets

    my $koha_facets = _convert_facets($es_facets, $expanded_facet);

Converts elasticsearch facets types to the form that Koha expects.
It expects the ES facet name to match the Koha type, for example C<itype>,
C<au>, C<su-to>, etc.

C<$expanded_facet> is the facet that we want to show FacetMaxCount entries for, rather
than just 5 like normal.

=cut

sub _convert_facets {
    my ( $self, $es, $exp_facet ) = @_;

    return if !$es;

    # These should correspond to the ES field names, as opposed to the CCL
    # things that zebra uses.
    # TODO let the library define the order using the interface.
    my %type_to_label = (
        author   => { order => 1, label => 'Authors', },
        itype    => { order => 2, label => 'ItemTypes', },
        location => { order => 3, label => 'Location', },
        'su-geo' => { order => 4, label => 'Places', },
        se       => { order => 5, label => 'Series', },
        subject  => { order => 6, label => 'Topics', },
        ccode    => { order => 7, label => 'CollectionCodes',},
        holdingbranch => { order => 8, label => 'HoldingLibrary' },
        homebranch => { order => 9, label => 'HomeLibrary' }
    );

    # We also have some special cases, e.g. itypes that need to show the
    # value rather than the code.
    my @itypes = Koha::ItemTypes->search;
    my @libraries = Koha::Libraries->search;
    my $library_names = { map { $_->branchcode => $_->branchname } @libraries };
    my @locations = Koha::AuthorisedValues->search( { category => 'LOC' } );
    my $opac = C4::Context->interface eq 'opac' ;
    my %special = (
        itype    => { map { $_->itemtype         => $_->description } @itypes },
        location => { map { $_->authorised_value => ( $opac ? ( $_->lib_opac || $_->lib ) : $_->lib ) } @locations },
        holdingbranch => $library_names,
        homebranch => $library_names
    );
    my @facets;
    $exp_facet //= '';
    while ( my ( $type, $data ) = each %$es ) {
        next if !exists( $type_to_label{$type} );

        # We restrict to the most popular $limit !results
        my $limit = ( $type eq $exp_facet ) ? C4::Context->preference('FacetMaxCount') : 5;
        my $facet = {
            type_id    => $type . '_id',
            expand     => $type,
            expandable => ( $type ne $exp_facet )
              && ( @{ $data->{buckets} } > $limit ),
            "type_label_$type_to_label{$type}{label}" => 1,
            type_link_value                    => $type,
            order      => $type_to_label{$type}{order},
        };
        $limit = @{ $data->{buckets} } if ( $limit > @{ $data->{buckets} } );
        foreach my $term ( @{ $data->{buckets} }[ 0 .. $limit - 1 ] ) {
            my $t = $term->{key};
            my $c = $term->{doc_count};
            my $label;
            if ( exists( $special{$type} ) ) {
                $label = $special{$type}->{$t} // $t;
            }
            else {
                $label = $t;
            }
            push @{ $facet->{facets} }, {
                facet_count       => $c,
                facet_link_value  => $t,
                facet_title_value => $t . " ($c)",
                facet_label_value => $label,        # TODO either truncate this,
                     # or make the template do it like it should anyway
                type_link_value => $type,
            };
        }
        push @facets, $facet if exists $facet->{facets};
    }

    @facets = sort { $a->{order} cmp $b->{order} } @facets;
    return \@facets;
}


1;
