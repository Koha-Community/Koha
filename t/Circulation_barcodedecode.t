#!/usr/bin/perl
#

use strict;
use warnings;

use Test::More tests => 16;

BEGIN {
    use_ok('C4::Circulation');
}

our %inputs = (
    cuecat     => ["26002315", '.C3nZC3nZC3nYD3b6ENnZCNnY.fHmc.C3D1Dxr2C3nZE3n7.', ".C3nZC3nZC3nYD3b6ENnZCNnY.fHmc.C3D1Dxr2C3nZE3n7.\r\n",
                    'q.C3nZC3nZC3nWDNzYDxf2CNnY.fHmc.C3DWC3nZCNjXD3nW.', '.C3nZC3nZC3nWCxjWE3D1C3nX.cGf2.ENr7C3v7D3T3ENj3C3zYDNnZ.' ],
    whitespace => [" 26002315", "26002315 ", "\n\t26002315\n"],
    'T-prefix' => [qw(T0031472 T32)],
    other      => [qw(26002315 T0031472 T32 Alphanum123), "Alpha Num 345"],
);
our %outputs = (
    cuecat     => ["26002315", "046675000808", "046675000808", "043000112403", "978068484914051500"],
    whitespace => [qw(26002315 26002315 26002315)],
    'T-prefix' => [qw(T0031472 T0000002         )],
    other      => [qw(26002315 T0031472 T32 Alphanum123), "Alpha Num 345"],
);
    
my @filters = sort keys %inputs;
foreach my $filter (@filters) {
    foreach my $datum (@{$inputs{$filter}}) {
        my $expect = shift @{$outputs{$filter}} or die "Internal Test Error: missing expected output for filter '$filter' on input '$datum'";
        my $output = C4::Circulation::barcodedecode($datum, $filter);
        ok($output eq $expect, sprintf("%12s: %20s => %15s", $filter, "'$datum'", "'$expect'")); 
        ($output eq $expect) or diag  "Bad output: '$output'";
    }
}

__END__

=head2 C4::Circulation::barcodedecode()

This tests avoids being dependent on the database by using the optional
second argument to barcodedecode.

T-prefix style is derived from zero-padded "Follett Classic Code 3 of 9".  From:
    www.fsc.follett.com/_file/File/pdf/Barcode%20Symbology%20Q%20%20A%203_05.pdf
 
 ~ 1 to 7 characters
 ~ T, P or X followed by numeric characters
 ~ No checkdigit

=cut
