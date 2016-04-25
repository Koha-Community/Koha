#!/usr/bin/perl
#
# Copyright 2014 Catalyst IT
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

use Modern::Perl;

use Test::More tests => 8;

BEGIN {
    use_ok('Koha::ItemType');
}

my $data = {
    itemtype       => 'CODE',
    description    => 'description',
    rentalcharge   => 'rentalcharge',
    imageurl       => 'imageurl',
    summary        => 'summary',
    checkinmsg     => 'checkinmsg',
    checkinmsgtype => 'checkinmsgtype',
};

my $type = Koha::ItemType->new($data);

is( $type->itemtype,       'CODE',           'itemtype/code' );
is( $type->description,    'description',    'description' );
is( $type->rentalcharge,   'rentalcharge',   'rentalcharge' );
is( $type->imageurl,       'imageurl',       'imageurl' );
is( $type->summary,        'summary',        'summary' );
is( $type->checkinmsg,     'checkinmsg',     'checkinmsg' );
is( $type->checkinmsgtype, 'checkinmsgtype', 'checkinmsgtype' );
