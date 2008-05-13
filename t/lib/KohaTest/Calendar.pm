package KohaTest::Calendar;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Calendar;
sub testing_class { 'C4::Calendar' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( new
                      _init
                      change_branchcode
                      get_week_days_holidays
                      get_day_month_holidays
                      get_exception_holidays
                      get_single_holidays
                      insert_week_day_holiday
                      insert_day_month_holiday
                      insert_single_holiday
                      insert_exception_holiday
                      delete_holiday
                      isHoliday
                      addDate
                      daysBetween
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

