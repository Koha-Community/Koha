package KohaTest::Calendar::New;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Calendar;
sub testing_class { 'C4::Calendar' };


=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut

=head2 TEST METHODS

standard test methods

=head3 instantiation

  just test to see if I can instantiate an object

=cut

sub instantiation : Test( 14 ) {
    my $self = shift;

    my $calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );

    ok( exists $calendar->{'day_month_holidays'}, 'day_month_holidays' );
    ok( exists $calendar->{'single_holidays'},    'single_holidays' );
    ok( exists $calendar->{'week_days_holidays'}, 'week_days_holidays' );
    ok( exists $calendar->{'exception_holidays'}, 'exception_holidays' );

    # sample data has Sundays as a holiday
    ok( exists $calendar->{'week_days_holidays'}->{'0'} );
    is( $calendar->{'week_days_holidays'}->{'0'}->{'title'},       '',        'Sunday title' );
    is( $calendar->{'week_days_holidays'}->{'0'}->{'description'}, 'Sundays', 'Sunday description' );
    
    # sample data has Christmas as a holiday
    ok( exists $calendar->{'day_month_holidays'}->{'12/25'} );
    is( $calendar->{'day_month_holidays'}->{'12/25'}->{'title'},       '',          'Christmas title' );
    is( $calendar->{'day_month_holidays'}->{'12/25'}->{'description'}, 'Christmas', 'Christmas description' );
    
    # sample data has New Year's Day as a holiday
    ok( exists $calendar->{'day_month_holidays'}->{'1/1'} );
    is( $calendar->{'day_month_holidays'}->{'1/1'}->{'title'},       '',                'New Year title' );
    is( $calendar->{'day_month_holidays'}->{'1/1'}->{'description'}, q(New Year's Day), 'New Year description' );
    
}

sub week_day_holidays : Test( 8 ) {
    my $self = shift;

    my $calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );

    ok( exists $calendar->{'week_days_holidays'}, 'week_days_holidays' );

    my %new_holiday = ( weekday     => 1,
                        title       => 'example week_day_holiday',
                        description => 'This is an example week_day_holiday used for testing' );
    my $new_calendar = $calendar->insert_week_day_holiday( %new_holiday );

    # the calendar object returned from insert_week_day_holiday should be updated
    isa_ok( $new_calendar, 'C4::Calendar' );
    is( $new_calendar->{'week_days_holidays'}->{ $new_holiday{'weekday'} }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'week_days_holidays'}->{ $new_holiday{'weekday'} }->{'description'}, $new_holiday{'description'}, 'description' );

    # new calendar objects should have the newly inserted holiday.
    my $refreshed_calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $refreshed_calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );
    is( $new_calendar->{'week_days_holidays'}->{ $new_holiday{'weekday'} }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'week_days_holidays'}->{ $new_holiday{'weekday'} }->{'description'}, $new_holiday{'description'}, 'description' );

}
  

sub day_month_holidays : Test( 8 ) {
    my $self = shift;

    my $calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );

    ok( exists $calendar->{'day_month_holidays'}, 'day_month_holidays' );

    my %new_holiday = ( day        => 4,
                        month       => 5,
                        title       => 'example day_month_holiday',
                        description => 'This is an example day_month_holiday used for testing' );
    my $new_calendar = $calendar->insert_day_month_holiday( %new_holiday );

    # the calendar object returned from insert_week_day_holiday should be updated
    isa_ok( $new_calendar, 'C4::Calendar' );
    my $mmdd = sprintf('%s/%s', $new_holiday{'month'}, $new_holiday{'day'} ) ;
    is( $new_calendar->{'day_month_holidays'}->{ $mmdd }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'day_month_holidays'}->{ $mmdd }->{'description'}, $new_holiday{'description'}, 'description' );

    # new calendar objects should have the newly inserted holiday.
    my $refreshed_calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $refreshed_calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );
    is( $new_calendar->{'day_month_holidays'}->{ $mmdd }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'day_month_holidays'}->{ $mmdd }->{'description'}, $new_holiday{'description'}, 'description' );

}
  


sub exception_holidays : Test( 8 ) {
    my $self = shift;

    my $calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );

    ok( exists $calendar->{'exception_holidays'}, 'exception_holidays' );

    my %new_holiday = ( day        => 4,
                        month       => 5,
                        year        => 2010,
                        title       => 'example exception_holiday',
                        description => 'This is an example exception_holiday used for testing' );
    my $new_calendar = $calendar->insert_exception_holiday( %new_holiday );
    # diag( Data::Dumper->Dump( [ $new_calendar ], [ 'newcalendar' ] ) );

    # the calendar object returned from insert_week_day_holiday should be updated
    isa_ok( $new_calendar, 'C4::Calendar' );
    my $yyyymmdd = sprintf('%s/%s/%s', $new_holiday{'year'}, $new_holiday{'month'}, $new_holiday{'day'} ) ;
    is( $new_calendar->{'exception_holidays'}->{ $yyyymmdd }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'exception_holidays'}->{ $yyyymmdd }->{'description'}, $new_holiday{'description'}, 'description' );

    # new calendar objects should have the newly inserted holiday.
    my $refreshed_calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $refreshed_calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );
    is( $new_calendar->{'exception_holidays'}->{ $yyyymmdd }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'exception_holidays'}->{ $yyyymmdd }->{'description'}, $new_holiday{'description'}, 'description' );

}


sub single_holidays : Test( 8 ) {
    my $self = shift;

    my $calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );

    ok( exists $calendar->{'single_holidays'}, 'single_holidays' );

    my %new_holiday = ( day        => 4,
                        month       => 5,
                        year        => 2011,
                        title       => 'example single_holiday',
                        description => 'This is an example single_holiday used for testing' );
    my $new_calendar = $calendar->insert_single_holiday( %new_holiday );
    # diag( Data::Dumper->Dump( [ $new_calendar ], [ 'newcalendar' ] ) );

    # the calendar object returned from insert_week_day_holiday should be updated
    isa_ok( $new_calendar, 'C4::Calendar' );
    my $yyyymmdd = sprintf('%s/%s/%s', $new_holiday{'year'}, $new_holiday{'month'}, $new_holiday{'day'} ) ;
    is( $new_calendar->{'single_holidays'}->{ $yyyymmdd }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'single_holidays'}->{ $yyyymmdd }->{'description'}, $new_holiday{'description'}, 'description' );

    # new calendar objects should have the newly inserted holiday.
    my $refreshed_calendar = C4::Calendar->new( branchcode => '' );
    isa_ok( $refreshed_calendar, 'C4::Calendar' );
    # diag( Data::Dumper->Dump( [ $calendar ], [ 'calendar' ] ) );
    is( $new_calendar->{'single_holidays'}->{ $yyyymmdd }->{'title'}, $new_holiday{'title'}, 'title' );
    is( $new_calendar->{'single_holidays'}->{ $yyyymmdd }->{'description'}, $new_holiday{'description'}, 'description' );

}
  

1;

