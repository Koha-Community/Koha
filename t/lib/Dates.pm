package t::lib::Dates;

use Modern::Perl;
use Test::More;
use Koha::DateUtils;
use DateTime;

=head1 NAME

t::lib::Dates.pm - test helper module for working with dates

=head1 METHODS

=head2 compare

  compare( $got_dt, $expected_dt, $test_description );

Will execute a test and compare the 2 dates given in parameters
The date will be compared truncated to minutes

=cut

sub compare {
    my ( $got, $expected, $description ) = @_;
    my $dt_got      = dt_from_string($got);
    my $dt_expected = dt_from_string($expected);
    my $diff = $dt_got->epoch - $dt_expected->epoch;
    if ( abs($diff) < 6 ) { return 0 }
    return $diff > 0 ? 1 : -1;
}

1;
