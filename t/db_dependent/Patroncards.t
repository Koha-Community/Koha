#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 1;
use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Patroncards::Layout;

subtest '->save' => sub {
    plan tests => 1;
    my $layout = C4::Patroncards::Layout->new(
        layout_name => "new patron card",
        layout_id   => '', # The interface send an empty string
        layout_xml  => 'some_xml'
    );
    my $layout_id = $layout->save;
    ok($layout_id > 0, 'A layout_id should have been returned on ->save');
};
