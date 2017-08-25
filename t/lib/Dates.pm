package t::lib::Dates;

use Modern::Perl;
use Test::More;
use Koha::DateUtils;
use DateTime;
=head2 compare

  compare( $got_dt, $expected_dt, $test_description );

Will execute a test and compare the 2 dates given in parameters
The date will be compared truncated to minutes

=cut

sub compare {
    my ( $got, $expected, $description ) = @_;
    my $dt_got      = dt_from_string($got);
    my $dt_expected = dt_from_string($expected);
    $dt_got->set_time_zone('floating');
    $dt_expected->set_time_zone('floating');
    my $diff = $dt_got->epoch - $dt_expected->epoch;
    if ( abs($diff) < 60 ) { return 0 }
    return $diff > 0 ? 1 : -1;
}

1;
