package Koha::SearchEngine::Zebra::QueryBuilder;

use Modern::Perl;
use Moose::Role;
use C4::Search;

with 'Koha::SearchEngine::QueryBuilderRole';

sub build_query {
    shift;
    C4::Search::buildQuery @_;
}

1;
