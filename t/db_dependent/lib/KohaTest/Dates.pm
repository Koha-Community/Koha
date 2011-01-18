package KohaTest::Dates;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Dates;
sub testing_class { 'C4::Dates' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( _prefformat
                      regexp
                      dmy_map
                      _check_date_and_time
                      _chron_to_ymd
                      _chron_to_hms
                      new
                      init
                      output
                      today
                      _recognize_format
                      DHTMLcalendar
                      format
                      visual
                      format_date
                      format_date_in_iso
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

