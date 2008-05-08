package KohaTest::Suggestions;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Suggestions;
sub testing_class { 'C4::Suggestions' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( SearchSuggestion
                      GetSuggestion
                      GetSuggestionFromBiblionumber
                      GetSuggestionByStatus
                      CountSuggestion
                      NewSuggestion
                      ModStatus
                      ConnectSuggestionAndBiblio
                      DelSuggestion
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

