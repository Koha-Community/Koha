#!/usr/bin/perl
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#
# for context, see http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=2691

use strict;
use warnings;

use Test::More tests => 2;

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
