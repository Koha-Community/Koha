#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use DateTime;
use Time::HiRes qw/gettimeofday/;
use C4::Members;
use Koha::DateUtils;
use t::lib::TestBuilder;
use Test::More tests => 1;

subtest 'Tests for CanBookBeIssued related to dateexpiry' => sub {
    plan tests => 4;
    date_expiry();
};

sub date_expiry {
    my $builder = t::lib::TestBuilder->new();
    my $item    = $builder->build( { source => 'Item' } );
    my $patron  = $builder->build(
        {   source => 'Borrower',
            value  => { dateexpiry => '9999-12-31' }
        }
    );
    $patron->{flags} = C4::Members::patronflags( $patron );
    my $duration = gettimeofday();
    my ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
    $duration = gettimeofday() - $duration;
    cmp_ok $duration, '<', 1, "CanBookBeIssued should not be take more than 1s if the patron is expired";
    is( not( exists $issuingimpossible->{EXPIRED} ), 1, 'The patron should not be considered as expired if dateexpiry is 9999-*' );

    $item = $builder->build( { source => 'Item' } );
    $patron = $builder->build(
        {   source => 'Borrower',
            value  => { dateexpiry => '0000-00-00' }
        }
    );
    $patron->{flags} = C4::Members::patronflags( $patron );
    ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
    is( $issuingimpossible->{EXPIRED}, 1, 'The patron should be considered as expired if dateexpiry is 0000-00-00' );

    my $tomorrow = dt_from_string->add_duration( DateTime::Duration->new( days => 1 ) );
    $item = $builder->build( { source => 'Item' } );
    $patron = $builder->build(
        {   source => 'Borrower',
            value  => { dateexpiry => output_pref( { dt => $tomorrow, dateonly => 1, dateformat => 'sql' } ) },
        }
    );
    $patron->{flags} = C4::Members::patronflags( $patron );
    ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $patron, $item->{barcode} );
    is( not( exists $issuingimpossible->{EXPIRED} ), 1, 'The patron should not be considered as expired if dateexpiry is tomorrow' );

}
