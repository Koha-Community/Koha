#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2023 ByWater Solutions
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
use Test::More tests => 3;

use utf8;

use_ok('Koha::TemplateUtils');

subtest 'Process arbitrary var' => sub {
    plan tests => 2;

    is(
        Koha::TemplateUtils::process_tt(
            "This is a test.",
            { test => 'simple test' }
        ),
        "This is a test.",
        "Processing template toolkit with no TT markup works"
    );

    is(
        Koha::TemplateUtils::process_tt(
            "This is a [% test %].",
            { test => 'simple test' }
        ),
        "This is a simple test.",
        "Processing template toolkit with a var works"
    );
};

subtest 'Plugin related tests' => sub {
    plan tests => 1;

    is(
        Koha::TemplateUtils::process_tt(
            q{[% USE raw %]This is a [% test | $raw %].},
            { test => 'simple test' }
        ),
        "This is a simple test.",
        "Processing template toolkit with a Koha plugin works"
    );
};
