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
#
# for context, see http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2691

use strict;
use warnings;

use Test::More tests => 11;

BEGIN {
    use_ok('C4::Labels::Label');
}

my $format_string = "title, callnumber";
my $parsed_fields = C4::Labels::Label::_get_text_fields($format_string);
my $expected_fields = [
    { code => 'title', desc => 'title' }, 
    { code => 'itemcallnumber', desc => 'itemcallnumber' }, 
];
is_deeply($parsed_fields, $expected_fields, '"callnumber" in label layout alias for "itemcallnumber" per bug 5653');

is(C4::Labels::Label::_check_params(),"0",'test checking parameters');

my ($llx,$lly,$width,$height) = ( 0, 0, 10, 10 );
ok(!defined C4::Labels::Label::_guide_box(),
        "Test guide box with undefined parameters returns undef");
ok(!defined C4::Labels::Label::_guide_box(undef,$lly,$width,$height),
        "Test guide box with undefined 'x' coordinate returns undef");
ok(!defined C4::Labels::Label::_guide_box($llx,undef,$width,$height),
        "Test guide box with undefined 'y' coordinate returns undef");
ok(!defined C4::Labels::Label::_guide_box($llx,$lly,undef,$height),
        "Test guide box with undefined 'width' returns undef");
ok(!defined C4::Labels::Label::_guide_box($llx,$lly,$width,undef),
        "Test guide box with undefined 'height' returns undef");
is(
    C4::Labels::Label::_guide_box($llx, $lly, $width, $height),
    'q
0.5 w
1.0 0.0 0.0  RG
1.0 1.0 1.0  rg
0 0 10 10 re
B
Q
',
    'Return guide box if all four parameters are defined'
);

ok(C4::Labels::Label::_get_text_fields(), 'test getting textx fields');

is(C4::Labels::Label::_split_lccn(),"0", 'test when _split_lccn is null');
