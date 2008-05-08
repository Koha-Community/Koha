package KohaTest::NewsChannels;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::NewsChannels;
sub testing_class { 'C4::NewsChannels' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( news_channels 
                      news_channels_by_category 
                      get_new_channel 
                      del_channels 
                      add_channel 
                      update_channel 
                      news_channels_categories 
                      get_new_channel_category 
                      del_channels_categories 
                      add_channel_category 
                      update_channel_category 
                      add_opac_new 
                      upd_opac_new 
                      del_opac_new 
                      get_opac_new 
                      get_opac_news 
                      GetNewsToDisplay 
                      add_opac_electronic 
                      upd_opac_electronic 
                      del_opac_electronic 
                      get_opac_electronic 
                      get_opac_electronics 
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

