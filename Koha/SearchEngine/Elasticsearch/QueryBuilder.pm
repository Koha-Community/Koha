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
use Carp;
use JSON;
use List::MoreUtils qw/ each_array /;
use Modern::Perl;
use URI::Escape;

use C4::Context;
use Koha::Exceptions;

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
            default_operator => 'AND',
            default_field    => '_all',
            lenient          => JSON::true,
        }
    };

    if ( $options{sort} ) {
        foreach my $sort ( @{ $options{sort} } ) {
            my ( $f, $d ) = @$sort{qw/ field direction /};
            die "Invalid sort direction, $d"
              if $d && ( $d ne 'asc' && $d ne 'desc' );
            $d = 'asc' unless $d;

            # TODO account for fields that don't have a 'phrase' type

            $f = $self->_sort_field($f);
            push @{ $res->{sort} }, { "$f.phrase" => { order => $d } };
        }
    }

    # See _convert_facets in Search.pm for how these get turned into
    # things that Koha can use.
    $res->{aggregations} = {
        author   => { terms => { field => "author__facet" } },
        subject  => { terms => { field => "subject__facet" } },
        itype    => { terms => { field => "itype__facet" } },
        location => { terms => { field => "location__facet" } },
        'su-geo' => { terms => { field => "su-geo__facet" } },
        se       => { terms => { field => "se__facet" } },
        ccode    => { terms => { field => "ccode__facet" } },
    };

    my $display_library_facets = C4::Context->preference('DisplayLibraryFacets');
    if (   $display_library_facets eq 'both'
        or $display_library_facets eq 'home' ) {
        $res->{aggregations}{homebranch} = { terms => { field => "homebranch__facet" } };
    }
    if (   $display_library_facets eq 'both'
        or $display_library_facets eq 'holding' ) {
        $res->{aggregations}{holdingbranch} = { terms => { field => "holdingbranch__facet" } };
    }
    if ( my $ef = $options{expanded_facet} ) {
        $res->{aggregations}{$ef}{terms}{size} = C4::Context->preference('FacetMaxCount');
    };
    return $res;
}

=head2 build_browse_query

    my $browse_query = $builder->build_browse_query($field, $query);

This performs a "starts with" style query on a particular field. The field
to be searched must have been indexed with an appropriate mapping as a
"phrase" subfield, which pretty much everything has.

=cut

# XXX this isn't really a browse query like we want in the end
sub build_browse_query {
    my ( $self, $field, $query ) = @_;

    my $fuzzy_enabled = C4::Context->preference("QueryFuzzy") || 0;

    return { query => '*' } if !defined $query;

    # TODO this should come from Koha::SearchEngine::Elasticsearch
    my %field_whitelist = (
        title  => 1,
        author => 1,
    );
    $field = 'title' if !exists $field_whitelist{$field};
    my $sort = $self->_sort_field($field);
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
        sort => [ { "$sort.phrase" => { order => "asc" } } ],
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
        $lang, $params )
      = @_;

#die Dumper ( $self, $operators, $operands, $indexes, $orig_limits, $sort_by, $scan, $lang );
    my @sort_params  = $self->_convert_sort_fields(@$sort_by);
    my @index_params = $self->_convert_index_fields(@$indexes);
    my $limits       = $self->_fix_limit_special_cases($orig_limits);
    if ( $params->{suppress} ) { push @$limits, "suppress:0"; }

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
        join( ' ', $self->_create_query_string(@search_params) ) || (),
        $self->_join_queries( $self->_convert_index_strings(@$limits) ) || () );

    # If there's no query on the left, let's remove the junk left behind
    $query_str =~ s/^ AND //;
    my %options;
    $options{sort} = \@sort_params;
    $options{expanded_facet} = $params->{expanded_facet};
    my $query = $self->build_query( $query_str, %options );

    #die Dumper($query);
    # We roughly emulate the CGI parameters of the zebra query builder
    my $query_cgi;
    $query_cgi = 'idx=kw&q=' . uri_escape_utf8( $operands->[0] ) if @$operands;
    my $simple_query;
    $simple_query = $operands->[0] if @$operands == 1;
    my $query_desc   = $simple_query;
    my $limit        = $self->_join_queries( $self->_convert_index_strings(@$limits));
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
        $wh = '_all' if $wh eq '';
        if ( $op eq 'is' || $op eq '=' ) {

            # look for something that matches a term completely
            # note, '=' is about numerical vals. May need special handling.
            # Also, we lowercase our search because the ES
            # index lowercases its values, and term searches don't get the
            # search analyzer applied to them.
            push @query_parts, { term => {"$wh.phrase" => lc $val} };
        }
        elsif ( $op eq 'exact' ) {
            # left and right truncation, otherwise an exact phrase
            push @query_parts, { match_phrase => {"$wh.phrase" => lc $val} };
        }
        elsif ( $op eq 'start' ) {
            # startswith search, uses lowercase untokenized version of heading
            push @query_parts, { prefix => {"$wh.lc_raw" => lc $val} };
        }
        else {
            # regular wordlist stuff
#            push @query_parts, { match => {$wh => { query => $val, operator => 'and' }} };
            my @values = split(' ',$val);
            foreach my $v (@values) {
                push @query_parts, { wildcard => { "$wh.phrase" => "*" . lc $v . "*" } };
            }
        }
    }

    # Merge the query parts appropriately
    # 'should' behaves like 'or'
    # 'must' behaves like 'and'
    # Zebra results seem to match must so using that here
    my $query = { query=>
                 { bool =>
                     { must => \@query_parts  }
                 }
             };

    # We need to add '.phrase' to all the sort headings otherwise it'll sort
    # based on the tokenised form.
    my %s;
    if ( exists $search->{sort} ) {
        foreach my $k ( keys %{ $search->{sort} } ) {
            my $f = $self->_sort_field($k);
            $s{"$f.phrase"} = $search->{sort}{$k};
        }
        $search->{sort} = \%s;
    }

    # add the sort stuff
    $query->{sort} = [ $search->{sort} ]  if exists $search->{sort};

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

What form of search to do. Options are: is (phrase, no trunction, whole field
must match), = (number exact match), exact (phrase, but with left and right
truncation). If left blank, then word list, right truncted, anywhere is used.

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
    mainmainentry   => 'Heading-Main',
    mainentry       => 'Heading',
    match           => 'Match',
    'match-heading' => 'Match-heading',
    'see-from'      => 'Match-heading-see-from',
    thesaurus       => 'Subject-heading-thesaurus',
    all              => ''
};

sub build_authorities_query_compat {
    my ( $self, $marclist, $and_or, $excluding, $operator, $value,
        $authtypecode, $orderby )
      = @_;

    # This turns the old-style many-options argument form into a more
    # extensible hash form that is understood by L<build_authorities_query>.
    my @searches;

    # Make sure everything exists
    foreach my $m (@$marclist) {
        Koha::Exceptions::WrongParameter->throw("Invalid marclist field provided: $m")
            unless exists $koha_to_index_name->{$m};
    }
    for ( my $i = 0 ; $i < @$value ; $i++ ) {
        next unless $value->[$i]; #clean empty form values, ES doesn't like undefined searches
        push @searches,
          {
            where    => $koha_to_index_name->{$marclist->[$i]},
            operator => $operator->[$i],
            value    => $value->[$i],
          };
    }

    my %sort;
    my $sort_field =
        ( $orderby =~ /^Heading/ ) ? 'Heading__sort'
      : ( $orderby =~ /^Auth/ )    ? 'Local-Number'
      :                              undef;
    if ($sort_field) {
        my $sort_order = ( $orderby =~ /Asc$/ ) ? 'asc' : 'desc';
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

=head2 _convert_index_fields

    my @index_params = $self->_convert_index_fields(@indexes);

Converts zebra-style search index notation into elasticsearch-style.

C<@indexes> is an array of index names, as presented to L<build_query_compat>,
and it returns something that can be sent to L<build_query>.

B<TODO>: this will pull from the elasticsearch mappings table to figure out
types.

=cut

our %index_field_convert = (
    'kw'      => '_all',
    'ti'      => 'title',
    'au'      => 'author',
    'su'      => 'subject',
    'nb'      => 'isbn',
    'se'      => 'title-series',
    'callnum' => 'callnum',
    'itype'   => 'itype',
    'ln'      => 'ln',
    'branch'  => 'homebranch',
    'fic'     => 'lf',
    'mus'     => 'rtype',
    'aud'     => 'ta',
    'hi'      => 'Host-Item-Number',
);

sub _convert_index_fields {
    my ( $self, @indexes ) = @_;

    my %index_type_convert =
      ( __default => undef, phr => 'phrase', rtrn => 'right-truncate' );

    # Convert according to our table, drop anything that doesn't convert.
    # If a field starts with mc- we save it as it's used (and removed) later
    # when joining things, to indicate we make it an 'OR' join.
    # (Sorry, this got a bit ugly after special cases were found.)
    grep { $_->{field} } map {
        my ( $f, $t ) = split /,/;
        my $mc = '';
        if ($f =~ /^mc-/) {
            $mc = 'mc-';
            $f =~ s/^mc-//;
        }
        my $r = {
            field => $index_field_convert{$f},
            type  => $index_type_convert{ $t // '__default' }
        };
        $r->{field} = ($mc . $r->{field}) if $mc && $r->{field};
        $r;
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
    while ( my ( $zeb, $es ) = each %index_field_convert ) {
        $search =~ s/\b$zeb(?:,[\w\-]*)?:/$es:/g;
    }
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
    $str = '"' . $str . '"' if $type eq 'phrase';
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
    my $grouped_mc =
      @mc_parts ? '(' . ( join ' OR ', map { "($_)" } @mc_parts ) . ')' : ();

    # Handy trick: $x || () inside a join means that if $x ends up as an
    # empty string, it gets replaced with (), which makes join ignore it.
    # (bad effect: this'll also happen to '0', this hopefully doesn't matter
    # in this case.)
    join( ' AND ',
        join( ' AND ', map { "($_)" } @norm_parts ) || (),
        $grouped_mc || () );
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

    my $auto_truncation = C4::Context->preference("QueryAutoTruncate") || 0;

    # Some hardcoded searches (like with authorities) produce things like
    # 'an=123', when it ought to be 'an:123' for our purposes.
    $term =~ s/=/:/g;
    $term = $self->_convert_index_strings_freeform($term);
    $term =~ s/[{}]/"/g;
    $term = $self->_truncate_terms($term) if ($auto_truncation);
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
            push @new_lim, 'onloan:0';
        }
        else {
            push @new_lim, $l;
        }
    }
    return \@new_lim;
}

=head2 _sort_field

    my $field = $self->_sort_field($field);

Given a field name, this works out what the actual name of the version to sort
on should be. Often it's the same, sometimes it involves sticking "__sort" on
the end. Maybe it'll be something else in the future, who knows?

=cut

sub _sort_field {
    my ($self, $f) = @_;
    if ($self->sort_fields()->{$f}) {
        $f .= '__sort';
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

    # '"donald duck" title:"the mouse" and peter" get split into
    # ['', '"donald duck"', '', ' ', '', 'title:"the mouse"', '', ' ', 'and', ' ', 'pete']
    my @tokens = split /((?:[\w\-.]+:)?"[^"]+"|\s+)/, $query;

    # Filter out empty tokens
    my @words = grep { $_ !~ /^\s*$/ } @tokens;

    # Append '*' to words if needed, ie. if it's not surrounded by quotes, not
    # terminated by '*' and not a keyword
    my @terms = map {
        my $w = $_;
        (/"$/ or /\*$/ or grep {lc($w) eq $_} qw/and or not/) ? $_ : "$_*";
    } @words;

    return join ' ', @terms;
}

1;
