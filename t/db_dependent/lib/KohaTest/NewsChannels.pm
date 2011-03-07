package KohaTest::NewsChannels;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::NewsChannels;
sub testing_class { 'C4::NewsChannels' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw(
                      add_opac_new 
                      upd_opac_new 
                      del_opac_new 
                      get_opac_new 
                      get_opac_news 
                      GetNewsToDisplay 
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

