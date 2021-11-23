package Koha::SearchEngine::Elasticsearch::Search;

# Copyright 2014 Catalyst IT
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
use Koha::Exceptions::Elasticsearch;
use MARC::Record;
use MARC::File::XML;
use MIME::Base64 qw( decode_base64 );
use JSON;

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

    # 20 is the default number of results per page
    $query->{size} = $count // 20;
    # ES doesn't want pages, it wants a record to start from.
    if (exists $options{offset}) {
        $query->{from} = $options{offset};
    } else {
        $page = (!defined($page) || ($page <= 0)) ? 0 : $page - 1;
        $query->{from} = $page * $query->{size};
    }
    my $elasticsearch = $self->get_elasticsearch();
    my $results = eval {
        $elasticsearch->search(
            index => $self->index_name,
            track_total_hits => JSON::true,
            body => $query
        );
    };
    if ($@) {
        die $self->process_error($@);
    }
    if (ref $results->{hits}->{total} eq 'HASH') {
        $results->{hits}->{total} = $results->{hits}->{total}->{value};
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
    my $elasticsearch = $self->get_elasticsearch();

    # TODO: Probably possible to exclude results
    # and just return number of hits
    my $result = $elasticsearch->search(
        index => $self->index_name,
        track_total_hits => JSON::true,
        body => $query
    );

    if (ref $result->{hits}->{total} eq 'HASH') {
        return $result->{hits}->{total}->{value};
    }
    return $result->{hits}->{total};
}

=head2 search_compat

    my ( $error, $results, $facets ) = $search->search_compat(
        $query,            $simple_query, \@sort_by,       \@servers,
        $results_per_page, $offset,       undef,           $item_types,
        $query_type,       $scan
      )

A search interface somewhat compatible with L<C4::Search->getRecords>. Anything
that is returned in the query created by build_query_compat will probably
get ignored here, along with some other things (like C<@servers>.)

=cut

sub search_compat {
    my (
        $self,       $query,            $simple_query, $sort_by,
        $servers,    $results_per_page, $offset,       $branches,
        $item_types, $query_type,       $scan
    ) = @_;

    if ( $scan ) {
        return $self->_aggregation_scan( $query, $results_per_page, $offset );
    }

    my %options;
    if ( !defined $offset or $offset < 0 ) {
        $offset = 0;
    }
    $options{offset} = $offset;
    my $results = $self->search($query, undef, $results_per_page, %options);

    # Convert each result into a MARC::Record
    my @records;
    # opac-search expects results to be put in the
    # right place in the array, according to $offset
    my $index = $offset;
    my $hits = $results->{'hits'};
    foreach my $es_record (@{$hits->{'hits'}}) {
        $records[$index++] = $self->decode_record_from_result($es_record->{'_source'});
    }

    # consumers of this expect a name-spaced result, we provide the default
    # configuration.
    my %result;
    $result{biblioserver}{hits} = $hits->{'total'};
    $result{biblioserver}{RECORDS} = \@records;
    return (undef, \%result, $self->_convert_facets($results->{aggregations}));
}

=head2 search_auth_compat

    my ( $results, $total ) =
      $searcher->search_auth_compat( $query, $offset, $count, $skipmetadata, %options );

This has a similar calling convention to L<search>, however it returns its
results in a form the same as L<C4::AuthoritiesMarc::SearchAuthorities>.

=cut

sub search_auth_compat {
    my ($self, $query, $offset, $count, $skipmetadata, %options) = @_;

    if ( !defined $offset or $offset <= 0 ) {
        $offset = 1;
    }
    # Uh, authority search uses 1-based offset..
    $options{offset} = $offset - 1;
    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $res      = $self->search($query, undef, $count, %options);

    my $bib_searcher = Koha::SearchEngine::Elasticsearch::Search->new({index => 'biblios'});
    my @records;
    my $hits = $res->{'hits'};
    foreach my $es_record (@{$hits->{'hits'}}) {
        my $record = $es_record->{'_source'};
        my %result;

        # We are using the authid to create links, we should honor the authid as stored in the db, not
        # the 001 which, in some circumstances, can contain other data
        my $authid = $es_record->{_id};


        $result{authid} = $authid;

        if (!defined $skipmetadata || !$skipmetadata) {
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
            my $marc               = $self->decode_record_from_result($record);
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
        }
        push @records, \%result;
    }
    return ( \@records, $hits->{'total'} );
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
                filter => { term      => { 'koha-auth-number' => $authid } }
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

The max number of results to return.
The default is the result of method max_result_window().

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
    $max_results //= $self->max_result_window;

    unless (ref $query) {
        # We'll push it through the query builder to sanitise everything.
        my $qb = Koha::SearchEngine::QueryBuilder->new({index => $self->index});
        (undef,$query) = $qb->build_query_compat(undef, [$query]);
    }
    my $results = $self->search($query, undef, $max_results, %options);
    my @records;
    my $hits = $results->{'hits'};
    foreach my $es_record (@{$hits->{'hits'}}) {
        push @records, $self->decode_record_from_result($es_record->{'_source'});
    }
    return (undef, \@records, $hits->{'total'});
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

=head2 decode_record_from_result
    my $marc_record = $self->decode_record_from_result(@result);

Extracts marc data from Elasticsearch result and decodes to MARC::Record object

=cut

sub decode_record_from_result {
    # Result is passed in as array, will get flattened
    # and first element will be $result
    my ( $self, $result ) = @_;
    if ($result->{marc_format} eq 'base64ISO2709') {
        return MARC::Record->new_from_usmarc(decode_base64($result->{marc_data}));
    }
    elsif ($result->{marc_format} eq 'MARCXML') {
        return MARC::Record->new_from_xml($result->{marc_data}, 'UTF-8', uc C4::Context->preference('marcflavour'));
    }
    elsif ($result->{marc_format} eq 'ARRAY') {
        return $self->_array_to_marc($result->{marc_data_array});
    }
    else {
        Koha::Exceptions::Elasticsearch->throw("Missing marc_format field in Elasticsearch result");
    }
}

=head2 max_result_window

Returns the maximum number of results that can be fetched

This directly requests Elasticsearch for the setting index.max_result_window (or
the default value for this setting in case it is not set)

=cut

sub max_result_window {
    my ($self) = @_;

    my $elasticsearch = $self->get_elasticsearch();

    my $response = $elasticsearch->indices->get_settings(
        index => $self->index_name,
        flat_settings => 'true',
        include_defaults => 'true'
    );

    my $max_result_window = $response->{$self->index_name}->{settings}->{'index.max_result_window'};
    $max_result_window //= $response->{$self->index_name}->{defaults}->{'index.max_result_window'};

    return $max_result_window;
}

=head2 _convert_facets

    my $koha_facets = _convert_facets($es_facets);

Converts elasticsearch facets types to the form that Koha expects.
It expects the ES facet name to match the Koha type, for example C<itype>,
C<au>, C<su-to>, etc.

=cut

sub _convert_facets {
    my ( $self, $es, $exp_facet ) = @_;

    return if !$es;

    # These should correspond to the ES field names, as opposed to the CCL
    # things that zebra uses.
    my %type_to_label;
    my %label = (
        author         => 'Authors',
        itype          => 'ItemTypes',
        location       => 'Location',
        'su-geo'       => 'Places',
        'title-series' => 'Series',
        subject        => 'Topics',
        ccode          => 'CollectionCodes',
        holdingbranch  => 'HoldingLibrary',
        homebranch     => 'HomeLibrary',
        ln             => 'Language',
    );
    my @facetable_fields =
      Koha::SearchEngine::Elasticsearch->get_facetable_fields;
    for my $f (@facetable_fields) {
        next unless defined $f->facet_order;
        $type_to_label{ $f->name } =
          { order => $f->facet_order, label => $label{ $f->name } };
    }

    # We also have some special cases, e.g. itypes that need to show the
    # value rather than the code.
    my @itypes = Koha::ItemTypes->search->as_list;
    my @libraries = Koha::Libraries->search->as_list;
    my $library_names = { map { $_->branchcode => $_->branchname } @libraries };
    my @locations = Koha::AuthorisedValues->search( { category => 'LOC' } )->as_list;
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
        my $limit = C4::Context->preference('FacetMaxCount');
        my $facet = {
            type_id    => $type . '_id',
            "type_label_$type_to_label{$type}{label}" => 1,
            type_link_value                    => $type,
            order      => $type_to_label{$type}{order},
        };
        $limit = @{ $data->{buckets} } if ( $limit > @{ $data->{buckets} } );
        foreach my $term ( @{ $data->{buckets} }[ 0 .. $limit - 1 ] ) {
            my $t = $term->{key};
            next unless $t; # FIXME Currently we cannot search for an empty faceted field i.e. ln:"" to find records missing languages, though ES does count them correctly
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
        if( C4::Context->preference('FacetOrder') eq 'Alphabetical' ){
            @{ $facet->{facets} } =
                sort { $a->{facet_label_value} cmp $b->{facet_label_value} } @{ $facet->{facets} };
        }
        push @facets, $facet if exists $facet->{facets};
    }


    @facets = sort { $a->{order} <=> $b->{order} } @facets;
    return \@facets;
}

=head2 _aggregation_scan

    my $result = $self->_aggregration_scan($query, 10, 0);

Perform an aggregation request for scan purposes.

=cut

sub _aggregation_scan {
    my ($self, $query, $results_per_page, $offset) = @_;

    if (!scalar(keys %{$query->{aggregations}})) {
        my %result = {
            biblioserver => {
                hits => 0,
                RECORDS => undef
            }
        };
        return (undef, \%result, undef);
    }
    my ($field) = keys %{$query->{aggregations}};
    $query->{aggregations}{$field}{terms}{size} = 1000;
    my $results = $self->search($query, 1, 0);

    # Convert each result into a MARC::Record
    my (@records, $index);
    # opac-search expects results to be put in the
    # right place in the array, according to $offset
    $index = $offset - 1;

    my $count = scalar(@{$results->{aggregations}{$field}{buckets}});
    for (my $index = $offset; $index - $offset < $results_per_page && $index < $count; $index++) {
        my $bucket = $results->{aggregations}{$field}{buckets}->[$index];
        # Scan values are expressed as:
        # - MARC21: 100a (count) and 245a (term)
        # - UNIMARC: 200f (count) and 200a (term)
        my $marc = MARC::Record->new;
        $marc->encoding('UTF-8');
        if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
            $marc->append_fields(
                MARC::Field->new((200, ' ',  ' ', 'f' => $bucket->{doc_count}))
            );
            $marc->append_fields(
                MARC::Field->new((200, ' ',  ' ', 'a' => $bucket->{key}))
            );
        } else {
            $marc->append_fields(
                MARC::Field->new((100, ' ',  ' ', 'a' => $bucket->{doc_count}))
            );
            $marc->append_fields(
                MARC::Field->new((245, ' ',  ' ', 'a' => $bucket->{key}))
            );
        }
        $records[$index] = $marc->as_usmarc();
    };
    # consumers of this expect a namespaced result, we provide the default
    # configuration.
    my %result;
    $result{biblioserver}{hits} = $count;
    $result{biblioserver}{RECORDS} = \@records;
    return (undef, \%result, undef);
}

1;
