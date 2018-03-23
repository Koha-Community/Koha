package t::db_dependent::opening_hours_context;

use Modern::Perl;

sub createContext {
  our $now = DateTime->now(
            time_zone => C4::Context->tz,
            ##Introduced as a infile-package
            formatter => HMFormatter->new()
  );
  sub start {
    my $suggested = $now->clone->subtract( hours => $_[0] );
    if ($suggested->day != $now->day) {
        return "00:00"
    } else {
        return $suggested;
    }
  };
  sub end {
    my $suggested = $now->clone->add( hours => $_[0] );
    if ($suggested->day != $now->day) {
        return "23:59"
    } else {
        return $suggested;
    }
  }
  my $hours = join("\n",
"---",
## Here we introduce 4 branches whose opening hours border values are tested with the current time.
"CPL:",
"  -", #Monday
"    - ".start(3), #start time
"    - ".end(3), #end time
"  -",
"    - ".start(3),
"    - ".end(3),
"  -",
"    - ".start(3),
"    - ".end(3),
"  -",
"    - ".start(3),
"    - ".end(3),
"  -",
"    - ".start(3),
"    - ".end(3),
"  -",
"    - ".start(3),
"    - ".end(3),
"  -",
"    - ".start(3),
"    - ".end(3),
"FFL:",
"  -",
"    - ".start(0),
"    - ".end(1),
"  -",
"    - ".start(0),
"    - ".end(1),
"  -",
"    - ".start(0),
"    - ".end(1),
"  -",
"    - ".start(0),
"    - ".end(1),
"  -",
"    - ".start(0),
"    - ".end(1),
"  -",
"    - ".start(0),
"    - ".end(1),
"  -",
"    - ".start(0),
"    - ".end(1),
"IPL:",
"  -",
"    - ".start(2),
"    - ".end(0),
"  -",
"    - ".start(2),
"    - ".end(0),
"  -",
"    - ".start(2),
"    - ".end(0),
"  -",
"    - ".start(2),
"    - ".end(0),
"  -",
"    - ".start(2),
"    - ".end(0),
"  -",
"    - ".start(2),
"    - ".end(0),
"  -",
"    - ".start(2),
"    - ".end(0),
"MPL:", #MPL is always closed
"  -",
"    - ".end(3),
"    - ".end(8),
"  -",
"    - ".end(3),
"    - ".end(8),
"  -",
"    - ".end(3),
"    - ".end(8),
"  -",
"    - ".end(3),
"    - ".end(8),
"  -",
"    - ".end(3),
"    - ".end(8),
"  -",
"    - ".end(3),
"    - ".end(8),
"  -",
"    - ".end(3),
"    - ".end(8),
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
"    - 00:00", #start time
"    - 23:59", #end time
"  -",
"    - 00:00",
"    - 23:59",
"  -",
"    - 00:00",
"    - 23:59",
"  -",
"    - 00:00",
"    - 23:59",
"  -", #Friday
"    - 00:00",
"    - 23:59",
"  -",
"    - 00:00",
"    - 23:59",
"  -", #Sunday
"    - 00:00",
"    - 23:59",
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
