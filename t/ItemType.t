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

use Test::More;
use t::lib::Mocks;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 25;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use_ok('C4::ItemType');

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'Itemtype' ;

sub fixtures {
    my ( $data ) = @_;
    fixtures_ok [
        Itemtype => [
            [
                'itemtype', 'description', 'rentalcharge', 'notforloan',
                'imageurl', 'summary', 'checkinmsg'
            ],
            @$data,
        ],
    ], 'add fixtures';
}

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

# Mock data
my $itemtypes = [
    [ 'BK', 'Books', 0, 0, '', '', 'foo' ],
    [ 'CD', 'CDRom', 0, 0, '', '', 'bar' ]
];

my @itemtypes = C4::ItemType->all();
is( @itemtypes, 0, 'Testing all itemtypes is empty' );

# Now lets mock some data
fixtures($itemtypes);

@itemtypes = C4::ItemType->all();

is( @itemtypes, 2, 'ItemType->all should return an array with 2 elements' );

is( $itemtypes[0]->fish, undef, 'Calling a bad descriptor gives undef' );

is( $itemtypes[0]->itemtype, 'BK', 'First itemtype is bk' );

is( $itemtypes[1]->itemtype, 'CD', 'second itemtype is cd' );

is( $itemtypes[0]->description, 'Books', 'First description is books' );

is( $itemtypes[1]->description, 'CDRom', 'second description is CDRom' );

is( $itemtypes[0]->rentalcharge, '0', 'first rental charge is 0' );

is( $itemtypes[1]->rentalcharge, '0', 'second rental charge is 0' );

is( $itemtypes[0]->notforloan, '0', 'first not for loan is 0' );

is( $itemtypes[1]->notforloan, '0', 'second not for loan is 0' );

is( $itemtypes[0]->imageurl, '', 'first imageurl is undef' );

is( $itemtypes[1]->imageurl, '', 'second imageurl is undef' );

is( $itemtypes[0]->checkinmsg, 'foo', 'first checkinmsg is foo' );

is( $itemtypes[1]->checkinmsg, 'bar', 'second checkinmsg is bar' );

# Test get(), which should return one itemtype
my $itemtype = C4::ItemType->get( 'BK' );

is( $itemtype->fish, undef, 'Calling a bad descriptor gives undef' );

is( $itemtype->itemtype, 'BK', 'itemtype is bk' );

is( $itemtype->description, 'Books', 'description is books' );

is( $itemtype->rentalcharge, '0', 'rental charge is 0' );

is( $itemtype->notforloan, '0', 'not for loan is 0' );

is( $itemtype->imageurl, '', ' not for loan is undef' );

is( $itemtype->checkinmsg, 'foo', 'checkinmsg is foo' );

$itemtype = C4::ItemType->get;
is( $itemtype, undef, 'C4::ItemType->get should return unless if no parameter is given' );

1;
