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

use Test::More tests => 26;

use C4::Context;

use_ok( 'C4::Circulation' );

C4::Context->_new_userenv(123456);
C4::Context->set_userenv(1,'kmkale' , 1, 'km', 'kale' , 'IMS', 'IMS Branch DEscription', 0, 'kmkale@anantcorp.com');

our %inputs = (
    cuecat     => ["26002315", '.C3nZC3nZC3nYD3b6ENnZCNnY.fHmc.C3D1Dxr2C3nZE3n7.', ".C3nZC3nZC3nYD3b6ENnZCNnY.fHmc.C3D1Dxr2C3nZE3n7.\r\n",
                    'q.C3nZC3nZC3nWDNzYDxf2CNnY.fHmc.C3DWC3nZCNjXD3nW.', '.C3nZC3nZC3nWCxjWE3D1C3nX.cGf2.ENr7C3v7D3T3ENj3C3zYDNnZ.' ],
    whitespace => [" 26002315", "26002315 ", "\n\t26002315\n"],
    'T-prefix' => [qw(T0031472 T32)],
    'libsuite8' => ['b000126', 'b12', 'B0126', 'IMS-B-126', 'ims-b-126','CD0000024','00123','11998'],
    EAN13      => [qw(892685001928 695152)],
    other      => [qw(26002315 T0031472 T32 Alphanum123), "Alpha Num 345"],
);
our %outputs = (
    cuecat     => ["26002315", "046675000808", "046675000808", "043000112403", "978068484914051500"],
    whitespace => [qw(26002315 26002315 26002315)],
    'T-prefix' => [qw(T0031472 T0000002         )],
    'libsuite8' => ['IMS-b-126', 'IMS-b-12', 'IMS-B-126', 'IMS-B-126', 'ims-b-126','IMS-CD-24','IMS-b-123','IMS-b-11998'],
    EAN13      => [qw(0892685001928 0000000695152)],
    other      => [qw(26002315 T0031472 T32 Alphanum123), "Alpha Num 345"],
);

my @filters = sort keys %inputs;
foreach my $filter (@filters) {
    foreach my $datum (@{$inputs{$filter}}) {
        my $expect = shift @{$outputs{$filter}}
            or die "Internal Test Error: missing expected output for filter '$filter' on input '$datum'";
        my $output = C4::Circulation::barcodedecode($datum, $filter);
        ok($output eq $expect, sprintf("%12s: %20s => %15s", $filter, "'$datum'", "'$expect'")); 
        ($output eq $expect) or diag  "Bad output: '$output'";
    }
}

# T-prefix style is derived from zero-padded "Follett Classic Code 3 of 9".  From:
#     www.fsc.follett.com/_file/File/pdf/Barcode%20Symbology%20Q%20%20A%203_05.pdf
#  ~ 1 to 7 characters
#  ~ T, P or X followed by numeric characters
#  ~ No checkdigit

1;
