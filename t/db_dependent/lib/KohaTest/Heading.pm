package KohaTest::Heading;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Heading;
sub testing_class { 'C4::Heading' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( 
                    new_from_bib_field
                    display_form
                    authorities
                    preferred_authorities
                    _query_limiters
                    _marc_format_handler
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;
