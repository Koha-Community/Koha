package t::db_dependent::opening_hours_context;

use Modern::Perl;

sub createContext {
  my $now = DateTime->now(
            time_zone => C4::Context->tz,
            ##Introduced as a infile-package
            formatter => HMFormatter->new()
  );
  my $hours = join("\n",
"---",
## Here we introduce 4 branches whose opening hours border values are tested with the current time.
"CPL:",
"  -", #Monday
"    - ".$now->clone->subtract(hours => 3), #start time
"    - ".$now->clone->add(     hours => 3), #end time
"  -",
"    - ".$now->clone->subtract(hours => 3),
"    - ".$now->clone->add(     hours => 3),
"  -",
"    - ".$now->clone->subtract(hours => 3),
"    - ".$now->clone->add(     hours => 3),
"  -",
"    - ".$now->clone->subtract(hours => 3),
"    - ".$now->clone->add(     hours => 3),
"  -",
"    - ".$now->clone->subtract(hours => 3),
"    - ".$now->clone->add(     hours => 3),
"  -",
"    - ".$now->clone->subtract(hours => 3),
"    - ".$now->clone->add(     hours => 3),
"  -",
"    - ".$now->clone->subtract(hours => 3),
"    - ".$now->clone->add(     hours => 3),
"FFL:",
"  -",
"    - ".$now->clone->subtract(hours => 0),
"    - ".$now->clone->add(     hours => 1),
"  -",
"    - ".$now->clone->subtract(hours => 0),
"    - ".$now->clone->add(     hours => 1),
"  -",
"    - ".$now->clone->subtract(hours => 0),
"    - ".$now->clone->add(     hours => 1),
"  -",
"    - ".$now->clone->subtract(hours => 0),
"    - ".$now->clone->add(     hours => 1),
"  -",
"    - ".$now->clone->subtract(hours => 0),
"    - ".$now->clone->add(     hours => 1),
"  -",
"    - ".$now->clone->subtract(hours => 0),
"    - ".$now->clone->add(     hours => 1),
"  -",
"    - ".$now->clone->subtract(hours => 0),
"    - ".$now->clone->add(     hours => 1),
"IPL:",
"  -",
"    - ".$now->clone->subtract(hours => 2),
"    - ".$now->clone->add(     hours => 0),
"  -",
"    - ".$now->clone->subtract(hours => 2),
"    - ".$now->clone->add(     hours => 0),
"  -",
"    - ".$now->clone->subtract(hours => 2),
"    - ".$now->clone->add(     hours => 0),
"  -",
"    - ".$now->clone->subtract(hours => 2),
"    - ".$now->clone->add(     hours => 0),
"  -",
"    - ".$now->clone->subtract(hours => 2),
"    - ".$now->clone->add(     hours => 0),
"  -",
"    - ".$now->clone->subtract(hours => 2),
"    - ".$now->clone->add(     hours => 0),
"  -",
"    - ".$now->clone->subtract(hours => 2),
"    - ".$now->clone->add(     hours => 0),
"MPL:", #MPL is always closed
"  -",
"    - ".$now->clone->add(     hours => 3),
"    - ".$now->clone->add(     hours => 8),
"  -",
"    - ".$now->clone->add(     hours => 3),
"    - ".$now->clone->add(     hours => 8),
"  -",
"    - ".$now->clone->add(     hours => 3),
"    - ".$now->clone->add(     hours => 8),
"  -",
"    - ".$now->clone->add(     hours => 3),
"    - ".$now->clone->add(     hours => 8),
"  -",
"    - ".$now->clone->add(     hours => 3),
"    - ".$now->clone->add(     hours => 8),
"  -",
"    - ".$now->clone->add(     hours => 3),
"    - ".$now->clone->add(     hours => 8),
"  -",
"    - ".$now->clone->add(     hours => 3),
"    - ".$now->clone->add(     hours => 8),
##Here we introduce a branch to test using mocked weekday DateTimes
"IPT:",
"  -", #Monday
"    - 07:00", #start time
"    - 20:00", #end time
"  -",
"    - 07:00",
"    - 20:00",
"  -",
"    - 07:00",
"    - 20:00",
"  -",
"    - 07:00",
"    - 20:00",
"  -", #Friday
"    - 07:00", #Opening time is bigger than the closing time
"    - 20:00", #thus, the library is always closed during this day.
"  -",
"    - 10:00",
"    - 18:00",
#"  -", #Sunday is missing, we throw an exception
#"    - 12:00",
#"    - 16:00",
"UPL:",
"  -", #Monday
"    - 07:00", #Opening time is bigger than the closing time
"    - 06:00", #thus, the library is always closed during this day.
"  -",
"    - 07:00",
"    - 06:00",
"  -",
"    - 07:00",
"    - 06:00",
"  -",
"    - 07:00",
"    - 06:00",
"  -", #Friday
"    - 07:00",
"    - 06:00",
"  -",
"    - 07:00",
"    - 06:00",
"  -", #Sunday
"    - 07:00",
"    - 06:00",
"NPL:",
"  -", #Monday
"    - 07:00", #start time
"    - 20:00", #end time
"  -",
"    - 07:00",
"    - 20:00",
"  -",
"    - 07:00",
"    - 20:00",
"  -",
"    - 07:00",
"    - 20:00",
"  -", #Friday
"    - 07:00", #Opening time is bigger than the closing time
"    - 20:00", #thus, the library is always closed during this day.
"  -",
"    - 10:00",
"    - 18:00",
"  -", #Sunday
"    - 12:00",
"    - 16:00",
"",);

    return $hours;
}


{
## Simple formatter for DateTime to be used in test context generation
package HMFormatter;

sub new {
  return bless({}, __PACKAGE__);
}
sub format_datetime {
  return sprintf("%02d:%02d", $_[1]->hour, $_[1]->minute);
}
} ##EO package HMFormatter


1;
