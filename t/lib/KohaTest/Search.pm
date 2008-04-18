package KohaTest::Search;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Search;
sub testing_class { 'C4::Search' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( findseealso
                      FindDuplicate
                      SimpleSearch
                      getRecords
                      pazGetRecords
                      _remove_stopwords
                      _detect_truncation
                      _build_stemmed_operand
                      _build_weighted_query
                      buildQuery
                      searchResults
                      NZgetRecords
                      NZanalyse
                      NZoperatorAND
                      NZoperatorOR
                      NZoperatorNOT
                      NZorder
                      ModBiblios
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;
