#!/usr/bin/perl
#
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

use strict;
use warnings;

use Test::More tests => 3;

use t::lib::Mocks;

BEGIN {
    use_ok('C4::Heading');
}

subtest "MARC21 tests" => sub {
    plan tests => 9;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');

    ok(C4::Heading::valid_heading_subfield('100', 'a'), '100a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('100', 'e'), '100e not valid for bib');

    ok(C4::Heading::valid_heading_subfield('100', 'a', 1), '100a valid for authority');
    ok(!C4::Heading::valid_heading_subfield('100', 'e', 1), '100e not valid for authority');

    ok(C4::Heading::valid_heading_subfield('110', 'a'), '110a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('110', 'e'), '110e not valid for bib');

    ok(C4::Heading::valid_heading_subfield('600', 'a'), '600a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('600', 'e'), '600e not valid for bib');

    ok(!C4::Heading::valid_heading_subfield('012', 'a'), '012a invalid field for bib');
};

subtest "UNIMARC tests" => sub {
    plan tests => 7;

    t::lib::Mocks::mock_preference('marcflavour', 'UNIMARC');

    ok(C4::Heading::valid_heading_subfield('100', 'a'), '100a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('100', 'i'), '100i not valid fir bib');

    ok(C4::Heading::valid_heading_subfield('110', 'a'), '110a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('110', 'i'), '110i not valid for bib');

    ok(C4::Heading::valid_heading_subfield('600', 'a'), '600a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('600', 'i'), '600i not valid for bib');

    ok(!C4::Heading::valid_heading_subfield('012', 'a'), '012a invalid field for bib');
}
