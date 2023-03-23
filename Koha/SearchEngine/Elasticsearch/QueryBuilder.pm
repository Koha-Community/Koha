package Koha::SearchEngine::Elasticsearch::QueryBuilder;

# This file is part of Koha.
#
# Copyright 2014 Catalyst IT Ltd.
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

Koha::SearchEngine::Elasticsearch::QueryBuilder - constructs elasticsearch
query objects from user-supplied queries

=head1 DESCRIPTION

This provides the functions that take a user-supplied search query, and
provides something that can be given to elasticsearch to get answers.

=head1 SYNOPSIS

    use Koha::SearchEngine::Elasticsearch::QueryBuilder;
    $builder = Koha::SearchEngine::Elasticsearch->new({ index => $index });
    my $simple_query = $builder->build_query("hello");
    # This is currently undocumented because the original code is undocumented
    my $adv_query = $builder->build_advanced_query($indexes, $operands, $operators);

=head1 METHODS

=cut

use base qw(Koha::SearchEngine::Elasticsearch);
use JSON;
use List::MoreUtils qw( each_array );
use Modern::Perl;
use URI::Escape qw( uri_escape_utf8 );

use C4::Context;
use Koha::Exceptions;
use Koha::Caches;

our %index_field_convert = (
    'kw' => '',
    'ab' => 'abstract',
    'au' => 'author',
    'lcn' => 'local-classification',
    'callnum' => 'local-classification',
    'record-type' => 'rtype',
    'mc-rtype' => 'rtype',
    'mus' => 'rtype',
    'lc-card' => 'lc-card-number',
    'sn' => 'local-number',
    'biblionumber' => 'local-number',
    'yr' => 'date-of-publication',
    'pubdate' => 'date-of-publication',
    'acqdate' => 'date-of-acquisition',
    'date/time-last-modified' => 'date-time-last-modified',
    'dtlm' => 'date-time-last-modified',
    'diss' => 'dissertation-information',
    'nb' => 'isbn',
    'ns' => 'issn',
    'music-number' => 'identifier-publisher-for-music',
    'number-music-publisher' => 'identifier-publisher-for-music',
    'music' => 'identifier-publisher-for-music',
    'ident' => 'identifier-standard',
    'cpn' => 'corporate-name',
    'cfn' => 'conference-name',
    'pn' => 'personal-name',
    'pb' => 'publisher',
    'pv' => 'provider',
    'nt' => 'note',
    'notes' => 'note',
    'rcn' => 'record-control-number',
    'cni' => 'control-number-identifier',
    'cnum' => 'control-number',
    'su' => 'subject',
    'su-to' => 'subject',
    #'su-geo' => 'subject',
    'su-ut' => 'subject',
    'ti' => 'title',
    'se' => 'title-series',
    'ut' => 'title-uniform',
    'an' => 'koha-auth-number',
    'authority-number' => 'koha-auth-number',
    'at' => 'authtype',
    'he' => 'heading',
    'rank' => 'relevance',
    'phr' => 'st-phrase',
    'wrdl' => 'st-word-list',
    'rt' => 'right-truncation',
    'rtrn' => 'right-truncation',
    'ltrn' => 'left-truncation',
    'rltrn' => 'left-and-right',
    'mc-itemtype' => 'itemtype',
    'mc-ccode' => 'ccode',
    'branch' => 'homebranch',
    'mc-loc' => 'location',
    'loc' => 'location',
    'stocknumber' => 'number-local-acquisition',
    'inv' => 'number-local-acquisition',
    'bc' => 'barcode',
    'mc-itype' => 'itype',
    'aub' => 'author-personal-bibliography',
    'auo' => 'author-in-order',
    'ff8-22' => 'ta',
    'aud' => 'ta',
    'audience' => 'ta',
    'frequency-code' => 'ff8-18',
    'illustration-code' => 'ff8-18-21',
    'regularity-code' => 'ff8-19',
    'type-of-serial' => 'ff8-21',
    'format' => 'ff8-23',
    'conference-code' => 'ff8-29',
    'festschrift-indicator' => 'ff8-30',
    'index-indicator' => 'ff8-31',
    'fiction' => 'lf',
    'fic' => 'lf',
    'literature-code' => 'lf',
    'biography' => 'bio',
    'ff8-34' => 'bio',
    'biography-code' => 'bio',
    'l-format' => 'ff7-01-02',
    'lex' => 'lexile-number',
    'hi' => 'host-item-number',
    'itu' => 'index-term-uncontrolled',
    'itg' => 'index-term-genre',
);
my $field_name_pattern = '[\w\-]+';
my $multi_field_pattern = "(?:\\.$field_name_pattern)*";

=head2 get_index_field_convert

    my @index_params = Koha::SearchEngine::Elasticsearch::QueryBuilder->get_index_field_convert();

Converts zebra-style search index notation into elasticsearch-style.

C<@indexes> is an array of index names, as presented to L<build_query_compat>,
and it returns something that can be sent to L<build_query>.

B<TODO>: this will pull from the elasticsearch mappings table to figure out
types.

=cut

sub get_index_field_convert() {
    return \%index_field_convert;
}

=head2 build_query

    my $simple_query = $builder->build_query("hello", %options)

This will build a query that can be issued to elasticsearch from the provided
string input. This expects a lucene style search form (see
L<http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html#query-string-syntax>
for details.)

It'll make an attempt to respect the various query options.

Additional options can be provided with the C<%options> hash.

=over 4

=item sort

This should be an arrayref of hashrefs, each containing a C<field> and an
C<direction> (optional, defaults to C<asc>.) The results will be sorted
according to these values. Valid values for C<direction> are 'asc' and 'desc'.

=back

=cut

sub build_query {
    my ( $self, $query, %options ) = @_;

    my $stemming         = C4::Context->preference("QueryStemming")        || 0;
    my $auto_truncation  = C4::Context->preference("QueryAutoTruncate")    || 0;
    my $fuzzy_enabled    = C4::Context->preference("QueryFuzzy")           || 0;

    $query = '*' unless defined $query;

    my $res;
    my $fields = $self->_search_fields({
        is_opac => $options{is_opac},
        weighted_fields => $options{weighted_fields},
    });
    if ($options{whole_record}) {
        push @$fields, 'marc_data_array.*';
    }
    $res->{query} = {
        query_string => {
            query            => $query,
            fuzziness        => $fuzzy_enabled ? 'auto' : '0',
            default_operator => 'AND',
            fields           => $fields,
            lenient          => JSON::true,
            analyze_wildcard => JSON::true,
        }
    };
    $res->{query}->{query_string}->{type} = 'cross_fields' if C4::Context->preference('ElasticsearchCrossFields');

    if ( $options{sort} ) {
        foreach my $sort ( @{ $options{sort} } ) {
            my ( $f, $d ) = @$sort{qw/ field direction /};
            die "Invalid sort direction, $d"
              if $d && ( $d ne 'asc' && $d ne 'desc' );
            $d = 'asc' unless $d;

            $f = $self->_sort_field($f);
            push @{ $res->{sort} }, { $f => { order => $d } };
        }
    }

    # See _convert_facets in Search.pm for how these get turned into
    # things that Koha can use.
    my $size = C4::Context->preference('FacetMaxCount');
    $res->{aggregations} = {
        author         => { terms => { field => "author__facet" , size => $size } },
        subject        => { terms => { field => "subject__facet", size => $size } },
        itype          => { terms => { field => "itype__facet", size => $size} },
        location       => { terms => { field => "location__facet", size => $size } },
        'su-geo'       => { terms => { field => "su-geo__facet", size => $size} },
        'title-series' => { terms => { field => "title-series__facet", size => $size } },
        ccode          => { terms => { field => "ccode__facet", size => $size } },
        ln             => { terms => { field => "ln__facet", size => $size } },
    };

    my $display_library_facets = C4::Context->preference('DisplayLibraryFacets');
    if (   $display_library_facets eq 'both'
        or $display_library_facets eq 'home' ) {
        $res->{aggregations}{homebranch} = { terms => { field => "homebranch__facet", size => $size } };
    }
    if (   $display_library_facets eq 'both'
        or $display_library_facets eq 'holding' ) {
        $res->{aggregations}{holdingbranch} = { terms => { field => "holdingbranch__facet", size => $size } };
    }
    return $res;
}

=head2 build_query_compat

    my (
        $error,             $query, $simple_query, $query_cgi,
        $query_desc,        $limit, $limit_cgi,    $limit_desc,
        $stopwords_removed, $query_type
      )
      = $builder->build_query_compat( \@operators, \@operands, \@indexes,
        \@limits, \@sort_by, $scan, $lang, $params );

This handles a search using the same api as L<C4::Search::buildQuery> does.

A very simple query will go in with C<$operands> set to ['query'], and
C<$sort_by> set to ['pubdate_dsc']. This simple case will return with
C<$query> set to something that can perform the search, C<$simple_query>
set to just the search term, C<$query_cgi> set to something that can
reproduce this search, and C<$query_desc> set to something else.

=cut

sub build_query_compat {
    my ( $self, $operators, $operands, $indexes, $orig_limits, $sort_by, $scan,
        $lang, $params )
      = @_;

    my $query;
    my $query_str = '';
    my $search_param_query_str = '';
    my $limits = ();
    if ( $scan ) {
        ($query, $query_str) = $self->_build_scan_query( $operands, $indexes );
        $search_param_query_str = $query_str;
    } else {
        my @sort_params  = $self->_convert_sort_fields(@$sort_by);
        my @index_params = $self->_convert_index_fields(@$indexes);
        $limits       = $self->_fix_limit_special_cases($orig_limits);
        if ( $params->{suppress} ) { push @$limits, "suppress:false"; }
        # Merge the indexes in with the search terms and the operands so that
        # each search thing is a handy unit.
        unshift @$operators, undef;    # The first one can't have an op
        my @search_params;
        my $truncate = C4::Context->preference("QueryAutoTruncate") || 0;
        my $ea = each_array( @$operands, @$operators, @index_params );
        while ( my ( $oand, $otor, $index ) = $ea->() ) {
            next if ( !defined($oand) || $oand eq '' );
            $oand = $self->clean_search_term($oand);
            $oand = $self->_truncate_terms($oand) if ($truncate);
            push @search_params, {
                operand => $oand,      # the search terms
                operator => defined($otor) ? uc $otor : undef,    # AND and so on
                $index ? %$index : (),
            };
        }

        # We build a string query from limits and the queries. An alternative
        # would be to pass them separately into build_query and let it build
        # them into a structured ES query itself. Maybe later, though that'd be
        # more robust.
        my @search_param_query_array = $self->_create_query_string(@search_params);
        $search_param_query_str = join( ' ', @search_param_query_array );
        my $search_param_limit_str =
          $self->_join_queries( $self->_convert_index_strings(@$limits) );
        if ( @search_param_query_array > 1 && $search_param_limit_str ) {
            $search_param_query_str = "($search_param_query_str)";
        }
        $query_str = join( ' AND ',
            $search_param_query_str || (),
            $search_param_limit_str || () );

        # If there's no query on the left, let's remove the junk left behind
        $query_str =~ s/^ AND //;
        my %options;
        $options{sort} = \@sort_params;
        $options{is_opac} = $params->{is_opac};
        $options{weighted_fields} = $params->{weighted_fields};
        $options{whole_record} = $params->{whole_record};
        $query = $self->build_query( $query_str, %options );
    }

    # We roughly emulate the CGI parameters of the zebra query builder
    my $query_cgi = '';
    shift @$operators; # Shift out the one we unshifted before
    my $ea = each_array( @$operands, @$operators, @$indexes );
    while ( my ( $oand, $otor, $index ) = $ea->() ) {
        $query_cgi .= '&' if $query_cgi;
        $query_cgi .= 'idx=' . uri_escape_utf8( $index // '') . '&q=' . uri_escape_utf8( $oand );
        $query_cgi .= '&op=' . uri_escape_utf8( $otor ) if $otor;
    }
    $query_cgi .= '&scan=1' if ( $scan );

    my $simple_query;
    $simple_query = $operands->[0] if @$operands == 1;
    my $query_desc;
    if ( $simple_query ) {
        $query_desc = $simple_query;
    } else {
        $query_desc = $search_param_query_str;
    }
    my $limit     = $self->_join_queries( $self->_convert_index_strings(@$limits));
    my $limit_cgi = ( $orig_limits and @$orig_limits )
      ? '&limit=' . join( '&limit=', map { uri_escape_utf8($_) } @$orig_limits )
      : '';
    my $limit_desc;
    $limit_desc = "$limit" if $limit;

    return (
        undef,  $query,     $simple_query, $query_cgi, $query_desc,
        $limit, $limit_cgi, $limit_desc,   undef,      undef
    );
}

=head2 build_authorities_query

    my $query = $builder->build_authorities_query(\%search);

This takes a nice description of an authority search and turns it into a black-box
query that can then be passed to the appropriate searcher.

The search description is a hashref that looks something like:

    {
        searches => [
            {
                where    => 'Heading',    # search the main entry
                operator => 'exact',        # require an exact match
                value    => 'frogs',        # the search string
            },
            {
                where    => '',             # search all entries
                operator => '',             # default keyword, right truncation
                value    => 'pond',
            },
        ],
        sort => {
            field => 'Heading',
            order => 'desc',
        },
        authtypecode => 'TOPIC_TERM',
    }

=cut

sub build_authorities_query {
    my ( $self, $search ) = @_;

    # Start by making the query parts
    my @query_parts;

    foreach my $s ( @{ $search->{searches} } ) {
        my ( $wh, $op, $val ) = @{$s}{qw(where operator value)};
        if ( defined $op && ($op eq 'is' || $op eq '=' || $op eq 'exact') ) {
            if ($wh) {
                # Match the whole field, case insensitive, UTF normalized.
                push @query_parts, { term => { "$wh.ci_raw" => $val } };
            }
            else {
                # Match the whole field for all searchable fields, case insensitive,
                # UTF normalized.
                # Given that field data is "The quick brown fox"
                # "The quick brown fox" and "the quick brown fox" will match
                # but not "quick brown fox".
                push @query_parts, {
                    multi_match => {
                        query => $val,
                        fields => $self->_search_fields({ subfield => 'ci_raw' }),
                    }
                };
            }
        }
        elsif ( defined $op && $op eq 'start') {
            # Match the prefix within a field for all searchable fields.
            # Given that field data is "The quick brown fox"
            # "The quick bro" will match, but not "quick bro"

            # Does not seems to be a multi prefix query
            # so we need to create one
            if ($wh) {
                # Match prefix of the field.
                push @query_parts, { prefix => {"$wh.ci_raw" => $val} };
            }
            else {
                my @prefix_queries;
                foreach my $field (@{$self->_search_fields()}) {
                    push @prefix_queries, {
                        prefix => { "$field.ci_raw" => $val }
                    };
                }
                push @query_parts, {
                    'bool' => {
                        'should' => \@prefix_queries,
                        'minimum_should_match' => 1
                    }
                };
            }
        }
        else {
            # Query all searchable fields.
            # Given that field data is "The quick brown fox"
            # a search containing any of the words will match, regardless
            # of order.

            my @tokens = $self->_split_query( $val );
            foreach my $token ( @tokens ) {
                $token = $self->_truncate_terms(
                    $self->clean_search_term( $token )
                );
            }
            my $query = $self->_join_queries( @tokens );
            my $query_string = {
                query            => $query,
                lenient          => JSON::true,
                analyze_wildcard => JSON::true,
            };
            if ($wh) {
                $query_string->{default_field} = $wh;
            }
            else {
                $query_string->{fields} = $self->_search_fields();
            }
            push @query_parts, { query_string => $query_string };
        }
    }

    # Merge the query parts appropriately
    # 'should' behaves like 'or'
    # 'must' behaves like 'and'
    # Zebra behaviour seem to match must so using that here
    my $elastic_query = {};
    $elastic_query->{bool}->{must} = \@query_parts;

    # Filter by authtypecode if set
    if ($search->{authtypecode}) {
        $elastic_query->{bool}->{filter} = {
            term => {
                "authtype.raw" => $search->{authtypecode}
            }
        };
    }

    my $query = {
        query => $elastic_query
    };

    # Add the sort stuff
    $query->{sort} = [ $search->{sort} ] if exists $search->{sort};

    return $query;
}

=head2 build_authorities_query_compat

    my ($query) =
      $builder->build_authorities_query_compat( \@marclist, \@and_or,
        \@excluding, \@operator, \@value, $authtypecode, $orderby );

This builds a query for searching for authorities, in the style of
L<C4::AuthoritiesMarc::SearchAuthorities>.

Arguments:

=over 4

=item marclist

An arrayref containing where the particular term should be searched for.
Options are: mainmainentry, mainentry, match, match-heading, see-from, and
thesaurus. If left blank, any field is used.

=item and_or

Totally ignored. It is never used in L<C4::AuthoritiesMarc::SearchAuthorities>.

=item excluding

Also ignored.

=item operator

What form of search to do. Options are: is (phrase, no truncation, whole field
must match), = (number exact match), exact (phrase, no truncation, whole field
must match). If left blank, then word list, right truncated, anywhere is used.

=item value

The actual user-provided string value to search for.

=item authtypecode

The authority type code to search within. If blank, then all will be searched.

=item orderby

The order to sort the results by. Options are Relevance, HeadingAsc,
HeadingDsc, AuthidAsc, AuthidDsc.

=back

marclist, operator, and value must be the same length, and the values at
index /i/ all relate to each other.

This returns a query, which is a black box object that can be passed to the
appropriate search object.

=cut

our $koha_to_index_name = {
    mainmainentry   => 'heading-main',
    mainentry       => 'heading',
    match           => 'match',
    'match-heading' => 'match-heading',
    'see-from'      => 'match-heading-see-from',
    thesaurus       => 'subject-heading-thesaurus',
    'thesaurus-conventions' => 'subject-heading-thesaurus-conventions',
    any             => '',
    all             => ''
};

# Note that sears and aat map to 008/11 values here
# but don't appear in C4/Headin/MARC21 thesaurus
# because they don't have values in controlled field indicators
# https://www.loc.gov/marc/authority/ad008.html
our $thesaurus_to_value = {
   lcsh  => 'a',
   lcac  => 'b',
   mesh  => 'c',
   nal   => 'd',
   notapplicable => 'n',
   cash  => 'k',
   rvm   => 'v',
   aat   => 'r',
   sears => 's',
   notdefined => 'z',
   notspecified => '|'
};

sub build_authorities_query_compat {
    my ( $self, $marclist, $and_or, $excluding, $operator, $value,
        $authtypecode, $orderby )
      = @_;

    # This turns the old-style many-options argument form into a more
    # extensible hash form that is understood by L<build_authorities_query>.
    my @searches;
    my $mappings = $self->get_elasticsearch_mappings();

    # Convert to lower case
    $marclist = [map(lc, @{$marclist})];
    $orderby  = lc $orderby;

    my @indexes;
    # Make sure everything exists
    foreach my $m (@$marclist) {

        $m = exists $koha_to_index_name->{$m} ? $koha_to_index_name->{$m} : $m;
        push @indexes, $m;
        warn "Unknown search field $m in marclist" unless (defined $mappings->{properties}->{$m} || $m eq '' || $m eq 'match-heading');
    }
    for ( my $i = 0 ; $i < @$value ; $i++ ) {
        next unless $value->[$i]; #clean empty form values, ES doesn't like undefined searches
        $value->[$i] = $thesaurus_to_value->{ $value->[$i] }
            if( defined $thesaurus_to_value->{ $value->[$i] } && $indexes[$i] eq 'subject-heading-thesaurus' );
        push @searches,
          {
            where    => $indexes[$i],
            operator => $operator->[$i],
            value    => $value->[$i],
          };
    }

    my %sort;
    my $sort_field =
        ( $orderby =~ /^heading/ ) ? 'heading__sort'
      : ( $orderby =~ /^auth/ )    ? 'local-number__sort'
      :                              undef;
    if ($sort_field) {
        my $sort_order = ( $orderby =~ /asc$/ ) ? 'asc' : 'desc';
        %sort = ( $sort_field => $sort_order, );
    }
    my %search = (
        searches     => \@searches,
        authtypecode => $authtypecode,
    );
    $search{sort} = \%sort if %sort;
    my $query = $self->build_authorities_query( \%search );
    return $query;
}

=head2 _build_scan_query

    my ($query, $query_str) = $builder->_build_scan_query(\@operands, \@indexes)

This will build an aggregation scan query that can be issued to elasticsearch from
the provided string input.

=cut

our %scan_field_convert = (
    'ti' => 'title',
    'au' => 'author',
    'su' => 'subject',
    'se' => 'title-series',
    'pb' => 'publisher',
);

sub _build_scan_query {
    my ( $self, $operands, $indexes ) = @_;

    my $term = scalar( @$operands ) == 0 ? '' : $operands->[0];
    my $index = scalar( @$indexes ) == 0 ? 'subject' : $indexes->[0];

    my ( $f, $d ) = split( /,/, $index);
    $index = $scan_field_convert{$f} || $f;

    my $res;
    $res->{query} = {
        query_string => {
            query => '*'
        }
    };
    $res->{aggregations} = {
        $index => {
            terms => {
                field => $index . '__facet',
                order => { '_key' => 'asc' },
                include => $self->_create_regex_filter($self->clean_search_term($term)) . '.*'
            }
        }
    };
    return ($res, $term);
}

=head2 _create_regex_filter

    my $filter = $builder->_create_regex_filter('term')

This will create a regex filter that can be used with an aggregation query.

=cut

sub _create_regex_filter {
    my ($self, $term) = @_;

    my $result = '';
    foreach my $c (split(//, quotemeta($term))) {
        my $lc = lc($c);
        my $uc = uc($c);
        $result .= $lc ne $uc ? '[' . $lc . $uc . ']' : $c;
    }
    return $result;
}

=head2 _convert_sort_fields

    my @sort_params = _convert_sort_fields(@sort_by)

Converts the zebra-style sort index information into elasticsearch-style.

C<@sort_by> is the same as presented to L<build_query_compat>, and it returns
something that can be sent to L<build_query>.

=cut

sub _convert_sort_fields {
    my ( $self, @sort_by ) = @_;

    # Turn the sorting into something we care about.
    my %sort_field_convert = (
        acqdate     => 'date-of-acquisition',
        author      => 'author',
        call_number => 'cn-sort',
        popularity  => 'issues',
        relevance   => undef,       # default
        title       => 'title',
        pubdate     => 'date-of-publication',
        biblionumber => 'local-number',
    );
    my %sort_order_convert =
      ( qw( desc desc ), qw( dsc desc ), qw( asc asc ), qw( az asc ), qw( za desc ) );

    # Convert the fields and orders, drop anything we don't know about.
    grep { $_->{field} } map {
        my ( $f, $d ) = /(.+)_(.+)/;
        {
            field     => $sort_field_convert{$f},
            direction => $sort_order_convert{$d}
        }
    } @sort_by;
}

sub _convert_index_fields {
    my ( $self, @indexes ) = @_;

    my %index_type_convert =
      ( __default => undef, phr => 'phrase', rtrn => 'right-truncate', 'st-year' => 'st-year' );

    @indexes = grep { $_ ne q{} } @indexes; # Remove any blank indexes, i.e. keyword

    # Convert according to our table, drop anything that doesn't convert.
    # If a field starts with mc- we save it as it's used (and removed) later
    # when joining things, to indicate we make it an 'OR' join.
    # (Sorry, this got a bit ugly after special cases were found.)
    map {
        # Lower case all field names
        my ( $f, $t ) = map(lc, split /,/);
        my $mc = '';
        if ($f =~ /^mc-/) {
            $mc = 'mc-';
            $f =~ s/^mc-//;
        }
        my $r = {
            field => exists $index_field_convert{$f} ? $index_field_convert{$f} : $f,
            type  => $index_type_convert{ $t // '__default' }
        };
        $r->{field} = ($mc . $r->{field}) if $mc && $r->{field};
        $r->{field} || $r->{type} ? $r : undef;
    } @indexes;
}

=head2 _convert_index_strings

    my @searches = $self->_convert_index_strings(@searches);

Similar to L<_convert_index_fields>, this takes strings of the form
B<field:search term> and rewrites the field from zebra-style to
elasticsearch-style. Anything it doesn't understand is returned verbatim.

=cut

sub _convert_index_strings {
    my ( $self, @searches ) = @_;
    my @res;
    foreach my $s (@searches) {
        next if $s eq '';
        my ( $field, $term ) = $s =~ /^\s*([\w,-]*?):(.*)/;
        unless ( defined($field) && defined($term) ) {
            push @res, $s;
            next;
        }
        my ($conv) = $self->_convert_index_fields($field);
        unless ( defined($conv) ) {
            push @res, $s;
            next;
        }
        push @res, ($conv->{field} ? $conv->{field} . ':' : '')
            . $self->_modify_string_by_type( %$conv, operand => $term );
    }
    return @res;
}

=head2 _convert_index_strings_freeform

    my $search = $self->_convert_index_strings_freeform($search);

This is similar to L<_convert_index_strings>, however it'll search out the
things to change within the string. So it can handle strings such as
C<(su:foo) AND (su:bar)>, converting the C<su> appropriately.

If there is something of the form "su,complete-subfield" or something, the
second part is stripped off as we can't yet handle that. Making it work
will have to wait for a real query parser.

=cut

sub _convert_index_strings_freeform {
    my ( $self, $search ) = @_;
    # @TODO: Currently will alter also fields contained within quotes:
    # `searching for "stuff cn:123"` for example will become
    # `searching for "stuff local-number:123"
    #
    # Fixing this is tricky, one possibility:
    # https://stackoverflow.com/questions/19193876/perl-regex-to-match-a-string-that-is-not-enclosed-in-quotes
    # Still not perfect, and will not handle escaped quotes within quotes and assumes balanced quotes.
    #
    # Another, not so elegant, solution could be to replace all quoted content with placeholders, and put
    # them back when processing is done.

    # Lower case field names
    $search =~ s/($field_name_pattern)(?:,[\w-]*)?($multi_field_pattern):/\L$1\E$2:/og;
    # Resolve possible field aliases
    $search =~ s/($field_name_pattern)($multi_field_pattern):/(exists $index_field_convert{$1} ? $index_field_convert{$1} : $1).($1 eq 'kw' ? "$2" : "$2:")/oge;
    return $search;
}

=head2 _modify_string_by_type

    my $str = $self->_modify_string_by_type(%index_field);

If you have a search term (operand) and a type (phrase, right-truncated), this
will convert the string to have the function in lucene search terms, e.g.
wrapping quotes around it.

=cut

sub _modify_string_by_type {
    my ( $self, %idx ) = @_;

    my $type = $idx{type} || '';
    my $str = $idx{operand};
    return $str unless $str;    # Empty or undef, we can't use it.

    $str .= '*' if $type eq 'right-truncate';
    $str = '"' . $str . '"' if $type eq 'phrase' && $str !~ /^".*"$/;
    if ($type eq 'st-year') {
        if ($str =~ /^(.*)-(.*)$/) {
            my $from = $1 || '*';
            my $until = $2 || '*';
            $str = "[$from TO $until]";
        }
    }
    return $str;
}

=head2 _join_queries

    my $query_str = $self->_join_queries(@query_parts);

This takes a list of query parts, that might be search terms on their own, or
booleaned together, or specifying fields, or whatever, wraps them in
parentheses, and ANDs them all together. Suitable for feeding to the ES
query string query.

Note: doesn't AND them together if they specify an index that starts with "mc"
as that was a special case in the original code for dealing with multiple
choice options (you can't search for something that has an itype of A and
and itype of B otherwise.)

=cut

sub _join_queries {
    my ( $self, @parts ) = @_;

    my @norm_parts = grep { defined($_) && $_ ne '' && $_ !~ /^mc-/ } @parts;
    my @mc_parts =
      map { s/^mc-//r } grep { defined($_) && $_ ne '' && $_ =~ /^mc-/ } @parts;
    return () unless @norm_parts + @mc_parts;
    return ( @norm_parts, @mc_parts )[0] if @norm_parts + @mc_parts == 1;

    # Group limits by field, so they can be OR'ed together
    my %mc_limits;
    foreach my $mc_part (@mc_parts) {
        my ($field, $value) = split /:/, $mc_part, 2;
        $mc_limits{$field} //= [];
        push @{ $mc_limits{$field} }, $value;
    }

    @mc_parts = map {
        sprintf('%s:(%s)', $_, join (' OR ', @{ $mc_limits{$_} }));
    } sort keys %mc_limits;

    @norm_parts = map { "($_)" } @norm_parts;

    return join( ' AND ', @norm_parts, @mc_parts);
}

=head2 _make_phrases

    my @phrased_queries = $self->_make_phrases(@query_parts);

This takes the supplied queries and forces them to be phrases by wrapping
quotes around them. It understands field prefixes, e.g. 'subject:' and puts
the quotes outside of them if they're there.

=cut

sub _make_phrases {
    my ( $self, @parts ) = @_;
    map { s/^\s*(\w*?:)(.*)$/$1"$2"/r } @parts;
}

=head2 _create_query_string

    my @query_strings = $self->_create_query_string(@queries);

Given a list of hashrefs, it will turn them into a lucene-style query string.
The hash should contain field, type (both for the indexes), operator, and
operand.

=cut

sub _create_query_string {
    my ( $self, @queries ) = @_;

    map {
        my $otor  = $_->{operator} ? $_->{operator} . ' ' : '';
        my $field = $_->{field}    ? $_->{field} . ':'    : '';

        my $oand = $self->_modify_string_by_type(%$_);
        $oand = "($oand)" if $field && scalar(split(/\s+/, $oand)) > 1 && (!defined $_->{type} || $_->{type} ne 'st-year');
        "$otor($field$oand)";
    } @queries;
}

=head2 clean_search_term

    my $term = $self->clean_search_term($term);

This cleans a search term by removing any funny characters that may upset
ES and give us an error. It also calls L<_convert_index_strings_freeform>
to ensure those parts are correct.

=cut

sub clean_search_term {
    my ( $self, $term ) = @_;

    # Lookahead for checking if we are inside quotes
    my $lookahead = '(?=(?:[^\"]*+\"[^\"]*+\")*+[^\"]*+$)';

    # Some hardcoded searches (like with authorities) produce things like
    # 'an=123', when it ought to be 'an:123' for our purposes.
    $term =~ s/=/:/g;

    $term = $self->_convert_index_strings_freeform($term);

    # Remove unbalanced quotes
    my $unquoted = $term;
    my $count = ($unquoted =~ tr/"/ /);
    if ($count % 2 == 1) {
        $term = $unquoted;
    }
    $term = $self->_query_regex_escape_process($term);

    # because of _truncate_terms and if QueryAutoTruncate enabled
    # we will have any special operators ruined by _truncate_terms:
    # for ex. search for "test [6 TO 7]" will be converted to "test* [6* TO* 7]"
    # so no reason to keep ranges in QueryAutoTruncate==true case:
    my $truncate = C4::Context->preference("QueryAutoTruncate") || 0;
    unless($truncate) {
        # replace all ranges with any square/curly brackets combinations to temporary substitutions (ex: "{a TO b]"" -> "~~LC~~a TO b~~RS~~")
        # (where L is for left and C is for Curly and so on)
        $term =~ s/
            (?<!\\)
            (?<backslashes>(?:[\\]{2})*)
            (?<leftbracket>\{|\[)
            (?<ranges>
                [^\s\[\]\{\}]+\ TO\ [^\s\[\]\{\}]+
                (?<!\\)
                (?:[\\]{2})*
            )
            (?<rightbracket>\}|\])
        /$+{backslashes}.'~~L'.($+{leftbracket} eq '[' ? 'S':'C').'~~'.$+{ranges}.'~~R'.($+{rightbracket} eq ']' ? 'S':'C').'~~'/gex;
    }
    # save all regex contents away before escaping brackets:
    # (same trick as with brackets above, just RE for 'RegularExpression')
    my @saved_regexes;
    my $rgx_i = 0;
    while(
            $term =~ s@(
                (?<!\\)(?:[\\]{2})*/
                (?:[^/]+|(?<=\\)(?:[\\]{2})*/)+
                (?<!\\)(?:[\\]{2})*/
            )$lookahead@~~RE$rgx_i~~@x
    ) {
        @saved_regexes[$rgx_i++] = $1;
    }

    # remove leading and trailing colons mixed with optional slashes and spaces
    $term =~ s/^([\s\\]*:\s*)+//;
    $term =~ s/([\s\\]*:\s*)+$//;
    # remove unquoted colons that have whitespace on either side of them
    $term =~ s/([\s\\]*:\s*)+(\s+)$lookahead/$2/g;
    $term =~ s/(\s+)([\s\\]*:\s*)+$lookahead/$1/g;
    # replace with spaces all repeated colons no matter how they surrounded with spaces and slashes
    $term =~ s/([\s\\]*:\s*){2,}$lookahead/ /g;
    # screen all followups for colons after first colon,
    # and correctly ignore unevenly backslashed:
    $term =~ s/((?<!\\)(?:[\\]{2})*:[^:\s]+(?<!\\)(?:[\\]{2})*)(?=:)/$1\\/g;

    # screen all exclamation signs that either are the last symbol or have white space after them
    # or are followed by close parentheses
    $term =~ s/(?:[\s\\]*!\s*)+(\s|$|\))/$1/g;

    # screen all brackets with backslash
    $term =~ s/(?<!\\)(?:[\\]{2})*([\{\}\[\]])$lookahead/\\$1/g;

    # restore all regex contents after escaping brackets:
    for (my $i = 0; $i < @saved_regexes; $i++) {
        $term =~ s/~~RE$i~~/$saved_regexes[$i]/;
    }
    unless($truncate) {
        # restore temporary weird substitutions back to normal brackets
        $term =~ s/~~L(C|S)~~([^\s\[\]\{\}]+ TO [^\s\[\]\{\}]+)~~R(C|S)~~/($1 eq 'S' ? '[':'{').$2.($3 eq 'S' ? ']':'}')/ge;
    }
    return $term;
}

=head2 _query_regex_escape_process

    my $query = $self->_query_regex_escape_process($query);

Processes query in accordance with current "QueryRegexEscapeOptions" system preference setting.

=cut

sub _query_regex_escape_process {
    my ($self, $query) = @_;
    my $regex_escape_options = C4::Context->preference("QueryRegexEscapeOptions");
    if ($regex_escape_options ne 'dont_escape') {
        if ($regex_escape_options eq 'escape') {
            # Will escape unescaped slashes (/) while preserving
            # unescaped slashes within quotes
            # @TODO: assumes quotes are always balanced and will
            # not handle escaped quotes properly, should perhaps be
            # replaced with a more general parser solution
            # so that this function is ever only provided with unquoted
            # query parts
            $query =~ s@(?:(?<!\\)((?:[\\]{2})*)(?=/))(?![^"]*"(?:[^"]*"[^"]*")*[^"]*$)@\\$1@g;
        }
        elsif($regex_escape_options eq 'unescape_escaped') {
            # Will unescape escaped slashes (\/) and escape
            # unescaped slashes (/) while preserving slashes within quotes
            # The same limitatations as above apply for handling of quotes
            $query =~ s@(?:(?<!\\)(?:((?:[\\]{2})*[\\])|((?:[\\]{2})*))(?=/))(?![^"]*"(?:[^"]*"[^"]*")*[^"]*$)@($1 ? substr($1, 0, -1) : ($2 . "\\"))@ge;
        }
    }
    return $query;
}

=head2 _fix_limit_special_cases

    my $limits = $self->_fix_limit_special_cases($limits);

This converts any special cases that the limit specifications have into things
that are more readily processable by the rest of the code.

The argument should be an arrayref, and it'll return an arrayref.

=cut

sub _fix_limit_special_cases {
    my ( $self, $limits ) = @_;

    my @new_lim;
    foreach my $l (@$limits) {

        # This is set up by opac-search.pl
        if ( $l =~ /^yr,st-numeric,ge[=:]/ ) {
            my ( $start, $end ) =
              ( $l =~ /^yr,st-numeric,ge[=:](.*) and yr,st-numeric,le[=:](.*)$/ );
            next unless defined($start) && defined($end);
            push @new_lim, "date-of-publication:[$start TO $end]";
        }
        elsif( $l =~ /^search_filter:/ ){
            # Here we are going to get the query as a string, clean it, and take care of the part of the limit
            # Calling build_query_compat here is avoided because we generate more complex query structures
            my ($filter_id) = ( $l =~ /^search_filter:(.*)$/ );
            my $search_filter = Koha::SearchFilters->find( $filter_id );
            next unless $search_filter;
            my ($expanded_lim,$query_lim) = $search_filter->expand_filter;
            # In the case of nested filters we need to expand them all
            foreach my $el ( @{$self->_fix_limit_special_cases($expanded_lim)} ){
                push @new_lim, $el;
            }
            # We need to clean the query part as we have built a string from the original search
            push @new_lim, $self->clean_search_term( $query_lim );
        }
        elsif ( $l =~ /^yr,st-numeric[=:]/ ) {
            my ($date) = ( $l =~ /^yr,st-numeric[=:](.*)$/ );
            next unless defined($date);
            $date = $self->_modify_string_by_type(type => 'st-year', operand => $date);
            push @new_lim, "date-of-publication:$date";
        }
        elsif ( $l =~ 'multibranchlimit|^branch' ) {
            my $branchfield  = C4::Context->preference('SearchLimitLibrary');
            my @branchcodes;
            if( $l =~ 'multibranchlimit' ) {
                my ($group_id) = ( $l =~ /^multibranchlimit:(.*)$/ );
                my $search_group = Koha::Library::Groups->find( $group_id );
                @branchcodes = map { $_->branchcode } $search_group->all_libraries;
                @branchcodes = sort { $a cmp $b } @branchcodes;
            } else {
                @branchcodes = ( $l =~ /^branch:(.*)$/ );
            }

            if (@branchcodes) {
                # We quote the branchcodes here to prevent issues when codes are reserved words in ES, e.g. OR, AND, NOT, etc.
                if ( $branchfield eq "homebranch" ) {
                    push @new_lim, sprintf "(%s)", join " OR ", map { 'homebranch: "' . $_ . '"' } @branchcodes;
                }
                elsif ( $branchfield eq "holdingbranch" ) {
                    push @new_lim, sprintf "(%s)", join " OR ", map { 'holdingbranch: "' . $_ . '"' } @branchcodes;
                }
                else {
                    push @new_lim, sprintf "(%s OR %s)",
                      join( " OR ", map { 'homebranch: "' . $_ . '"' } @branchcodes ),
                      join( " OR ", map { 'holdingbranch: "' . $_ . '"' } @branchcodes );
                }
            }
        }
        elsif ( $l =~ /^available$/ ) {
            push @new_lim, 'available:true';
        }
        elsif ( $l =~ /^\s*(kw\b[\w,-]*?):(.*)/) {
            my ( $field, $term ) = ($1, $2);
            if ( defined($field) && defined($term) && $field =~ /,phr$/) {
                push @new_lim, "(\"$term\")";
            }
            else {
                push @new_lim, $term;
            }
        }
        else {
            my ( $field, $term ) = $l =~ /^\s*([\w,-]*?):(.*)/;
            $field =~ s/,phr$//; #We are quoting all the limits as phrase, this prevents from quoting again later
            if ( defined($field) && defined($term) ) {
                push @new_lim, "$field:(\"$term\")";
            }
            else {
                push @new_lim, $l;
            }
        }
    }
    return \@new_lim;
}

=head2 _sort_field

    my $field = $self->_sort_field($field);

Given a field name, this works out what the actual name of the field to sort
on should be. A '__sort' suffix is added for fields with a sort version, and
for text fields either '.phrase' (for sortable versions) or '.raw' is appended
to avoid sorting on a tokenized value.

=cut

sub _sort_field {
    my ($self, $f) = @_;

    my $mappings = $self->get_elasticsearch_mappings();
    my $textField = defined $mappings->{properties}{$f}{type} && $mappings->{properties}{$f}{type} eq 'text';
    if (!defined $self->sort_fields()->{$f} || $self->sort_fields()->{$f}) {
        $f .= '__sort';
    } else {
        # We need to add '.raw' to text fields without a sort field,
        # otherwise it'll sort based on the tokenised form.
        $f .= '.raw' if $textField;
    }
    return $f;
}

=head2 _truncate_terms

    my $query = $self->_truncate_terms($query);

Given a string query this function appends '*' wildcard  to all terms except
operands and double quoted strings.

=cut

sub _truncate_terms {
    my ( $self, $query ) = @_;

    my @tokens = $self->_split_query( $query );

    # Filter out empty tokens
    my @words = grep { $_ !~ /^\s*$/ } @tokens;

    # Append '*' to words if needed, ie. if it ends in a word character and is not a keyword
    my @terms = map {
        my $w = $_;
        (/\W$/ or grep {lc($w) eq $_} qw/and or not/) ? $_ : "$_*";
    } @words;

    return join ' ', @terms;
}

=head2 _split_query

    my @token = $self->_split_query($query_str);

Given a string query this function splits it to tokens taking into account
any field prefixes and quoted strings.

=cut

my $tokenize_split_re = qr/((?:${field_name_pattern}${multi_field_pattern}:)?"[^"]+"|\s+)/;

sub _split_query {
    my ( $self, $query ) = @_;

    # '"donald duck" title:"the mouse" and peter" get split into
    # ['', '"donald duck"', '', ' ', '', 'title:"the mouse"', '', ' ', 'and', ' ', 'pete']
    my @tokens = split $tokenize_split_re, $query;

    # Filter out empty values
    @tokens = grep( /\S/, @tokens );

    return @tokens;
}

=head2 _search_fields
    my $weighted_fields = $self->_search_fields({
        is_opac => 0,
        weighted_fields => 1,
        subfield => 'raw'
    });

Generate a list of searchable fields to be used for Elasticsearch queries
applied to multiple fields.

Returns an arrayref of field names for either OPAC or staff interface, with
possible weights and subfield appended to each field name depending on the
options provided.

=over 4

=item C<$params>

Hashref with options. The parameter C<is_opac> indicates whether the searchable
fields for OPAC or staff interface should be retrieved. If C<weighted_fields> is set
fields weights will be applied on returned fields. C<subfield> can be used to
provide a subfield that will be appended to fields as "C<field_name>.C<subfield>".

=back

=cut

sub _search_fields {
    my ($self, $params) = @_;
    $params //= {
        is_opac => 0,
        weighted_fields => 0,
        whole_record => 0,
        # This is a hack for authorities build_authorities_query
        # can hopefully be removed in the future
        subfield => undef,
    };
    my $cache = Koha::Caches->get_instance();
    my $cache_key = 'elasticsearch_search_fields' . ($params->{is_opac} ? '_opac' : '_staff_client') . "_" . $self->index;
    my $search_fields = $cache->get_from_cache($cache_key, { unsafe => 1 });
    if (!$search_fields) {
        # The reason we don't use Koha::SearchFields->search here is we don't
        # want or need resultset wrapped as Koha::SearchField object.
        # It does not make any sense in this context and would cause
        # unnecessary overhead sice we are only querying for data
        # Also would not work, or produce strange results, with the "columns"
        # option.
        my $schema = Koha::Database->schema;
        my $result = $schema->resultset('SearchField')->search(
            {
                $params->{is_opac} ? (
                    'opac' => 1,
                ) : (
                    'staff_client' => 1
                ),
                'type' => { '!=' => 'boolean' },
                'search_marc_map.index_name' => $self->index,
                'search_marc_map.marc_type' => C4::Context->preference('marcflavour'),
                'search_marc_to_fields.search' => 1,
            },
            {
                columns => [qw/name weight/],
                collapse => 1,
                join => {search_marc_to_fields => 'search_marc_map'},
            }
        );
        my @search_fields;
        while (my $search_field = $result->next) {
            push @search_fields, [
                lc $search_field->name,
                $search_field->weight ? $search_field->weight : ()
            ];
        }
        $search_fields = \@search_fields;
        $cache->set_in_cache($cache_key, $search_fields);
    }
    if ($params->{subfield}) {
        my $subfield = $params->{subfield};
        $search_fields = [
            map {
                # Copy values to avoid mutating cached
                # data (since unsafe is used)
                my ($field, $weight) = @{$_};
                ["${field}.${subfield}", $weight];
            } @{$search_fields}
        ];
    }
    if ($params->{weighted_fields}) {
        return [map { join('^', @{$_}) } @{$search_fields}];
    }
    else {
        # Exclude weight from field
        return [map { $_->[0] } @{$search_fields}];
    }
}

1;
