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

# XXX This doesn't work because I need to figure out how to do transactions
# in a test-case with DBIx::Class

use Modern::Perl;

use Test::More tests => 8;
use Data::Dumper;

BEGIN {
    use_ok('Koha::ItemTypes');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $prep = $dbh->prepare('INSERT INTO itemtypes (itemtype, description, rentalcharge, imageurl, summary, checkinmsg, checkinmsgtype) VALUES (?,?,?,?,?,?,?)');
$prep->execute('type1', 'description', 'rentalcharge', 'imageurl', 'summary', 'checkinmsg', 'checkinmsgtype');
$prep->execute('type2', 'description', 'rentalcharge', 'imageurl', 'summary', 'checkinmsg', 'checkinmsgtype');

my $itypes = Koha::ItemTypes->new();

my @types = $itypes->get_itemtype('type1', 'type2');

die Dumper(\@types);
my $type = $types[0];
ok(defined($type), 'first result');
is( $type->code,           'type1',           'itemtype/code' );
is( $type->description,    'description',    'description' );
is( $type->rentalcharge,   'rentalcharge',   'rentalcharge' );
is( $type->imageurl,       'imageurl',       'imageurl' );
is( $type->summary,        'summary',        'summary' );
is( $type->checkinmsg,     'checkinmsg',     'checkinmsg' );
is( $type->checkinmsgtype, 'checkinmsgtype', 'checkinmsgtype' );

$type = $types[1];
ok(defined($type), 'second result');
is( $type->code,           'type2',           'itemtype/code' );
is( $type->description,    'description',    'description' );
is( $type->rentalcharge,   'rentalcharge',   'rentalcharge' );
is( $type->imageurl,       'imageurl',       'imageurl' );
is( $type->summary,        'summary',        'summary' );
is( $type->checkinmsg,     'checkinmsg',     'checkinmsg' );
is( $type->checkinmsgtype, 'checkinmsgtype', 'checkinmsgtype' );
