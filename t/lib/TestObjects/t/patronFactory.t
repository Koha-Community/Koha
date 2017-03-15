#!/usr/bin/perl

# Copyright KohaSuomi 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use Modern::Perl;
use Test::More;

use t::lib::TestObjects::PatronFactory;
use Koha::Patrons;

my $subtestContext = {};
##Create and Delete. Add one
my $f = t::lib::TestObjects::PatronFactory->new();
my $objects = $f->createTestGroup([
                    {firstname => 'Olli-Antti',
                     surname   => 'Kivi',
                     cardnumber => '11A001',
                     branchcode     => 'CPL',
                    },
                ], undef, $subtestContext);
is($objects->{'11A001'}->cardnumber, '11A001', "Borrower '11A001'.");
##Add one more to test incrementing the subtestContext.
$objects = $f->createTestGroup([
                    {firstname => 'Olli-Antti2',
                     surname   => 'Kivi2',
                     cardnumber => '11A002',
                     branchcode     => 'FFL',
                    },
                ], undef, $subtestContext);
is($subtestContext->{patron}->{'11A001'}->cardnumber, '11A001', "Borrower '11A001' from \$subtestContext."); #From subtestContext
is($objects->{'11A002'}->branchcode,                  'FFL',    "Borrower '11A002'."); #from just created hash.

##Delete objects
t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
foreach my $cn (('11A001', '11A002')) {
    ok (not(Koha::Patrons->find({cardnumber => $cn})),
        "Borrower '11A001' deleted");
}

done_testing();
