package Koha::CurrencyFormat;

# This file is part of Koha.
#
# Copyright 2018 Koha-Suomi Oy
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

our @EXPORT = qw( fix_currency_str );

sub fix_currency_str {
    my $amount = shift;
    $amount =~ s/\s+//g;
    if ($amount =~ /^(\d+)([,.](\d\d))?$/) {
	my $amount_a = $1 || "0";
	my $amount_b = $3 || "00";
	$amount = $amount_a.".".$amount_b;
    }
    return $amount;
}

1;
