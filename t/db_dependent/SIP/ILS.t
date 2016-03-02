#!/usr/bin/perl

# Tests for C4::SIP::ILS
# Please help to extend them!

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

use Test::More tests => 9;

BEGIN {
    use_ok('C4::SIP::ILS');
}

my $class = 'C4::SIP::ILS';
my $institution = { id => 'CPL', };

my $ils = $class->new( $institution );

isa_ok( $ils, $class );

# Check all methods required for interface are there
my @methods = qw(
    find_patron find_item checkout_ok checkin_ok offline_ok status_update_ok
    offline_ok checkout checkin end_patron_session pay_fee add_hold cancel_hold
    alter_hold renew renew_all
);

can_ok( $ils, @methods );

is( $ils->institution(), 'CPL', 'institution method returns id' );

is( $ils->institution_id(), 'CPL', 'institution_id method returns id' );

is( $ils->supports('checkout'), 1, 'checkout supported' );

is( $ils->supports('security_inhibit'),
    q{}, 'unsupported feature returns false' );

is( $ils->test_cardnumber_compare( 'A1234', 'a1234' ),
    1, 'borrower bc test is case insensitive' );

is( $ils->test_cardnumber_compare( 'A1234', 'b1234' ),
    q{}, 'borrower bc test identifies difference' );
