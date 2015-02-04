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

    use Koha::SearchEngine::Elasticsearch;
    $builder = Koha::SearchEngine::Elasticsearch->new();
    my $simple_query = $builder->build_query("hello");
    # This is currently undocumented because the original code is undocumented
    my $adv_query = $builder->build_advanced_query($indexes, $operands, $operators);

=head1 METHODS

=cut

use base qw(Class::Accessor);
use Carp;
use List::MoreUtils qw/ each_array /;
use Modern::Perl;
use URI::Escape;

use Data::Dumper;    # TODO remove

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
    my $weight_fields    = C4::Context->preference("QueryWeightFields")    || 0;
    my $fuzzy_enabled    = C4::Context->preference("QueryFuzzy")           || 0;

    $query = '*' unless defined $query;

    my $res;
    $res->{query} = {
        query_string => {
            query            => $query,
            fuzziness        => $fuzzy_enabled ? 'auto' : '0',
            default_operator => "AND",
            default_field    => "_all",
        }
    };

    if ( $options{sort} ) {
        foreach my $sort ( @{ $options{sort} } ) {
            my ( $f, $d ) = @$sort{qw/ field direction /};
            die "Invalid sort direction, $d"
              if $d && ( $d ne 'asc' && $d ne 'desc' );
            $d = 'asc' unless $d;

            # TODO account for fields that don't have a 'phrase' type
            push @{ $res->{sort} }, { "$f.phrase" => { order => $d } };
        }
    }

    # See _convert_facets in Search.pm for how these get turned into
    # things that Koha can use.
    $res->{facets} = {
        author  => { terms => { field => "author__facet" } },
        subject => { terms => { field => "subject__facet" } },
        itype   => { terms => { field => "itype__facet" } },
    };
    return $res;
}

=head2 build_browse_query

    my $browse_query = $builder->build_browse_query($field, $query);

This performs a "starts with" style query on a particular field. The field
to be searched must have been indexed with an appropriate mapping as a
"phrase" subfield.

=cut
# XXX this isn't really a browse query like we want in the end
sub build_browse_query {
    my ( $self, $field, $query ) = @_;

    my $fuzzy_enabled = C4::Context->preference("QueryFuzzy") || 0;

    return { query => '*' } if !defined $query;

    # TODO this should come from Koha::Elasticsearch
    my %field_whitelist = (
        title  => 1,
        author => 1,
    );
    $field = 'title' if !exists $field_whitelist{$field};

    my $res = {
        query => {
            match_phrase_prefix => {
                "$field.phrase" => {
                    query     => $query,
                    operator  => 'or',
                    fuzziness => $fuzzy_enabled ? 'auto' : '0',
                }
            }
        },
        sort => [ { "$field.phrase" => { order => "asc" } } ],
    };
}

=head2 build_query_compat

    my (
        $error,             $query, $simple_query, $query_cgi,
        $query_desc,        $limit, $limit_cgi,    $limit_desc,
        $stopwords_removed, $query_type
      )
      = $builder->build_query_compat( \@operators, \@operands, \@indexes,
        \@limits, \@sort_by, $scan, $lang );

This handles a search using the same api as L<C4::Search::buildQuery> does.

A very simple query will go in with C<$operands> set to ['query'], and
C<$sort_by> set to ['pubdate_dsc']. This simple case will return with
C<$query> set to something that can perform the search, C<$simple_query>
set to just the search term, C<$query_cgi> set to something that can
reproduce this search, and C<$query_desc> set to something else.

=cut

sub build_query_compat {
    my ( $self, $operators, $operands, $indexes, $orig_limits, $sort_by, $scan,
        $lang )
      = @_;

#die Dumper ( $self, $operators, $operands, $indexes, $limits, $sort_by, $scan, $lang );
    my @sort_params  = $self->_convert_sort_fields(@$sort_by);
    my @index_params = $self->_convert_index_fields(@$indexes);
    my $limits       = $self->_fix_limit_special_cases($orig_limits);

    # Merge the indexes in with the search terms and the operands so that
    # each search thing is a handy unit.
    unshift @$operators, undef;    # The first one can't have an op
    my @search_params;
    my $ea = each_array( @$operands, @$operators, @index_params );
    while ( my ( $oand, $otor, $index ) = $ea->() ) {
        next if ( !defined($oand) || $oand eq '' );
        push @search_params, {
            operand => $self->_clean_search_term($oand),      # the search terms
            operator => defined($otor) ? uc $otor : undef,    # AND and so on
            $index ? %$index : (),
        };
    }

    # We build a string query from limits and the queries. An alternative
    # would be to pass them separately into build_query and let it build
    # them into a structured ES query itself. Maybe later, though that'd be
    # more robust.
    my $query_str = join( ' AND ',
        join( ' ', $self->_create_query_string(@search_params) ),
        $self->_join_queries( $self->_convert_index_strings(@$limits) ) );

    # If there's no query on the left, let's remove the junk left behind
    $query_str =~ s/^ AND //;
    my %options;
    $options{sort} = \@sort_params;
    my $query = $self->build_query( $query_str, %options );

    #die Dumper($query);
    # We roughly emulate the CGI parameters of the zebra query builder
    my $query_cgi = 'idx=kw&q=' . uri_escape( $operands->[0] ) if @$operands;
    my $simple_query = $operands->[0] if @$operands == 1;
    my $query_desc   = $simple_query;
    my $limit        = 'and ' . join( ' and ', @$limits );
    my $limit_cgi =
      '&limit=' . join( '&limit=', map { uri_escape($_) } @$orig_limits );
    my $limit_desc = "@$limits";

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
    my ($self, $search) = @_;

    # Start by making the query parts
    my @query_parts;
    my @filter_parts;
    foreach my $s ( @{ $search->{searches} } ) {
        my ($wh, $op, $val) = $s->{'where', 'operator', 'value'};
        my ($q_type);
        if ($op eq 'is' || $op eq '=') {
            # look for something that matches completely
            # note, '=' is about numerical vals. May need special handling.
            push @filter_parts, { term => { $wh => $val }};
        } elsif ($op eq 'exact') {
            # left and right truncation, otherwise an exact phrase
            push @query_parts, { match_phrase => { $wh => $val }};
        } else {
            # regular wordlist stuff
            # TODO truncation
            push @query_parts, { match => { $wh => $val }};
        }
    }
    # Merge the query and filter parts appropriately
    # 'should' behaves like 'or', if we want 'and', use 'must'
    my $query_part = { bool => { should => \@query_parts } };
    my $filter_part = { bool => { should => \@filter_parts }};
    my $query;
    if (@filter_parts) {
        $query = { query => { filtered => { filter => $filter_part, query => $query_part }}};
    } else {
        $query = { query => $query_part };
    }
    return $query;
}


=head2 build_authorities_query_compat

    my ($query) =
      $builder->build_authorities_query_compat( \@marclist, \@and_or,
        \@excluding, \@operator, \@value, $authtypecode, $orderby );

This builds a query for searching for authorities.

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

What form of search to do. Options are: is (phrase, no trunction, whole field
must match), = (number exact match), exact (phrase, but with left and right
truncation). If left blank, then word list, right truncted, anywhere is used.

=item value

The actual user-provided string value to search for.

=authtypecode

The authority type code to search within. If blank, then all will be searched.

=orderby

The order to sort the results by. Options are Relevance, HeadingAsc,
HeadingDsc, AuthidAsc, AuthidDsc.

=back

marclist, operator, and value must be the same length, and the values at
index /i/ all relate to each other.

This returns a query, which is a black box object that can be passed to the
appropriate search object.

=cut

sub build_authorities_query_compat {
    my ( $self, $marclist, $and_or, $excluding, $operator, $value,
        $authtypecode, $orderby )
      = @_;

    # This turns the old-style many-options argument form into a more
    # extensible hash form that is understood by L<build_authorities_query>.
    my @searches;

    my %koha_to_index_name = (
        mainmainentry   => 'Heading-Main',
        mainentry       => 'Heading',
        match           => 'Match',
        'match-heading' => 'Match-heading',
        'see-from'      => 'Match-heading-see-from',
        thesaurus       => 'Subject-heading-thesaurus',
        ''              => '',
    );

    # Make sure everything exists
    foreach my $m (@$marclist) {
        confess "Invalid marclist field provided: $m" unless exists $koha_to_index_name{$m};
    }
    for ( my $i = 0 ; $i < @$value ; $i++ ) {
        push @searches,
          {
            where    => $marclist->[$i],
            operator => $operator->[$i],
            value    => $value->[$i],
          };
    }

    my %sort;
    my $sort_field =
        ( $orderby =~ /^Heading/ ) ? 'Heading'
      : ( $orderby =~ /^Auth/ )    ? 'Local-Number'
      :                              undef;
    if ($sort_field) {
        my $sort_order = ( $orderby =~ /Asc$/ ) ? 'asc' : 'desc';
        %sort = ( $orderby => $sort_order, );
    }
    my %search = (
        searches     => \@searches,
        authtypecode => $authtypecode,
    );
    $search{sort} = \%sort if %sort;
    my $query = $self->build_authorities_query( \%search );
    return $query;
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
        acqdate     => 'acqdate',
        author      => 'author',
        call_number => 'callnum',
        popularity  => 'issues',
        relevance   => undef,       # default
        title       => 'title',
        pubdate     => 'pubdate',
    );
    my %sort_order_convert =
      ( qw( dsc desc ), qw( asc asc ), qw( az asc ), qw( za desc ) );

    # Convert the fields and orders, drop anything we don't know about.
    grep { $_->{field} } map {
        my ( $f, $d ) = split /_/;
        {
            field     => $sort_field_convert{$f},
            direction => $sort_order_convert{$d}
        }
    } @sort_by;
}

=head2 _convert_index_fields

    my @index_params = $self->_convert_index_fields(@indexes);

Converts zebra-style search index notation into elasticsearch-style.

C<@indexes> is an array of index names, as presented to L<build_query_compat>,
and it returns something that can be sent to L<build_query>.

B<TODO>: this will pull from the elasticsearch mappings table to figure out
types.

=cut

our %index_field_convert = (
    'kw'       => '_all',
    'ti'       => 'title',
    'au'       => 'author',
    'su'       => 'subject',
    'nb'       => 'isbn',
    'se'       => 'title-series',
    'callnum'  => 'callnum',
    'mc-itype' => 'itype',
    'ln'       => 'ln',
    'branch'   => 'homebranch',
    'fic'      => 'lf',
    'mus'      => 'rtype',
    'aud'      => 'ta',
);

sub _convert_index_fields {
    my ( $self, @indexes ) = @_;

    my %index_type_convert =
      ( __default => undef, phr => 'phrase', rtrn => 'right-truncate' );

    # Convert according to our table, drop anything that doesn't convert
    grep { $_->{field} } map {
        my ( $f, $t ) = split /,/;
        {
            field => $index_field_convert{$f},
            type  => $index_type_convert{ $t // '__default' }
        }
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
        push @res, $conv->{field} . ":"
          . $self->_modify_string_by_type( %$conv, operand => $term );
    }
    return @res;
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
    $str = '"' . $str . '"' if $type eq 'phrase';
    return $str;
}

=head2 _convert_index_strings_freeform

    my $search = $self->_convert_index_strings_freeform($search);

This is similar to L<_convert_index_strings>, however it'll search out the
things to change within the string. So it can handle strings such as
C<(su:foo) AND (su:bar)>, converting the C<su> appropriately.

=cut

sub _convert_index_strings_freeform {
    my ( $self, $search ) = @_;

    while ( my ( $zeb, $es ) = each %index_field_convert ) {
        $search =~ s/\b$zeb:/$es:/g;
    }
    return $search;
}

=head2 _join_queries

    my $query_str = $self->_join_queries(@query_parts);

This takes a list of query parts, that might be search terms on their own, or
booleaned together, or specifying fields, or whatever, wraps them in
parentheses, and ANDs them all together. Suitable for feeding to the ES
query string query.

=cut

sub _join_queries {
    my ( $self, @parts ) = @_;

    @parts = grep { defined($_) && $_ ne '' } @parts;
    return () unless @parts;
    return $parts[0] if @parts < 2;
    join ' AND ', map { "($_)" } @parts;
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
        "$otor($field$oand)";
    } @queries;
}

=head2 _clean_search_term

    my $term = $self->_clean_search_term($term);

This cleans a search term by removing any funny characters that may upset
ES and give us an error. It also calls L<_convert_index_strings_freeform>
to ensure those parts are correct.

=cut

sub _clean_search_term {
    my ( $self, $term ) = @_;

    $term = $self->_convert_index_strings_freeform($term);
    $term =~ s/[{}]/"/g;
    return $term;
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
        if ( $l =~ /^yr,st-numeric,ge=/ ) {
            my ( $start, $end ) =
              ( $l =~ /^yr,st-numeric,ge=(.*) and yr,st-numeric,le=(.*)$/ );
            next unless defined($start) && defined($end);
            push @new_lim, "copydate:[$start TO $end]";
        }
        elsif ( $l =~ /^yr,st-numeric=/ ) {
            my ($date) = ( $l =~ /^yr,st-numeric=(.*)$/ );
            next unless defined($date);
            push @new_lim, "copydate:$date";
        }
        elsif ( $l =~ /^available$/ ) {
            push @new_lim, 'onloan:false';
        }
        else {
            push @new_lim, $l;
        }
    }
    return \@new_lim;
}

1;
