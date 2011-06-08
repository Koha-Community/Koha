use strict;
use warnings;
use 5.010;
use DateTime;

use Test::More tests => 8;                      # last test to print

use_ok('Koha::DateUtils');

my $dt_metric = dt_from_string('01/02/2010', 'metric', 'Europe/London');
isa_ok $dt_metric, 'DateTime', 'metric returns a DateTime object';
cmp_ok $dt_metric->ymd(), 'eq', '2010-02-01', 'metric date correct';

my $dt_us = dt_from_string('02/01/2010', 'us', 'Europe/London');
isa_ok $dt_us, 'DateTime', 'us returns a DateTime object';
cmp_ok $dt_us->ymd(), 'eq', '2010-02-01', 'us date correct';

my $dt_iso = dt_from_string('2010-02-01', 'iso', 'Europe/London');
isa_ok $dt_iso, 'DateTime', 'iso returns a DateTime object';
cmp_ok $dt_iso->ymd(), 'eq', '2010-02-01', 'iso date correct';



my $dt = dt_from_string( undef );

isa_ok $dt, 'DateTime', 'No string returns a DateTime object';
