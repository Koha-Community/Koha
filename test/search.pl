#!/usr/bin/perl -w

use C4::Search;

my @SEARCH = (
    { operators => [
          'and',
          'and'
      ],
      operands => [
          'shakespeare, "(william)"',
          'dream'
      ],
      indexes => [
          'au,wrdl',
          'ti',
          'kw'
      ],
      limits => [
          'yr,st-numeric=2000-'
      ],
      sort_by => [
          'relevance'
      ],
      lang => 'en',
    },
);


foreach ( @SEARCH ) {
    my ($expected, @mismatch);
    my( $error,
        $query,
        $simple_query,
        $query_cgi,
        $query_desc,
        $limit,
        $limit_cgi,
        $limit_desc,
        $query_type )
      = buildQuery( $_->{operators}, $_->{operands}, $_->{indexes}, $_->{limits}, $_->{sort_by}, 0,  $_->{lang} );

    die $error if $error;

    $expected = $_->{query};
    push @mismatch, "Query: $query (not: $expected)" unless $query eq $expected;

    $expected = $_->{simple_query};
    push @mismatch, "Simple Query: $simple_query (not: $expected)" unless $simple_query eq $expected;

    $expected = $_->{query_cgi};
    push @mismatch, "Query CGI: $query_cgi (not: $expected)" unless $query_cgi eq $expected;

    $expected = $_->{query_desc};
    push @mismatch, "Query desc: $query_desc (not: $expected)" unless $query_desc eq $expected;

    $expected = $_->{limit};
    push @mismatch, "Limit: $limit (not: $expected)" unless $limit eq $expected;

    $expected = $_->{limit_cgi};
    push @mismatch, "Limit CGI: $limit_cgi (not: $expected)" unless $limit_cgi eq $expected;

    $expected = $_->{limit_desc};
    push @mismatch, "Limit desc: $limit_desc (not: $expected)" unless $limit_desc eq $expected;

    $expected = $_->{query_type};
    push @mismatch, "Query Type: $query_type (not: $expected)" unless $query_type eq $expected;

    die map "$_\n", @mismatch if @mismatch;
}
