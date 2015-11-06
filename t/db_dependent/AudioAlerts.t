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

use Test::More tests => 33;

BEGIN {
    use_ok('Koha::AudioAlert');
    use_ok('Koha::AudioAlerts');
}

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

map { $_->delete() } Koha::AudioAlerts->search();

## Check the basics
# Creating 3 audio alerts named a, b and c
my $a = Koha::AudioAlert->new( { selector => 'A', sound => 'test.wav' } )->store();
is( $a->precedence, 1, "First alert has a precedence of 1" );

my $b = Koha::AudioAlert->new( { selector => 'B', sound => 'sound.mp3' } )->store();
is( $b->precedence, 2, "Second alert has a precedence of 2" );

my $c = Koha::AudioAlert->new( { selector => 'C', sound => 'test.ogg' } )->store();
is( $c->precedence, 3, "Third alert has a precedence of 3" );

## Check precedence getting methods
# Testing get_last_precedence and get_next_precedence

is( Koha::AudioAlerts->get_last_precedence(), 3, "Last prececence should be 3" );
is( Koha::AudioAlerts->get_next_precedence(), 4, "Next prececence should be 4" );

## Check edge cases
# Testing edge cases for moving ( up from 1, down from the last precedence )

$a->move('up');
is( $a->precedence, 1, "First alert still has a precedence of 1" );

$c->move('down');
is( $c->precedence, 3, "Third alert still has a precedence of 3" );

## Check moving
# Moving A down by one
$a->move('down');
$a = Koha::AudioAlerts->find( $a->id );
$b = Koha::AudioAlerts->find( $b->id );
$c = Koha::AudioAlerts->find( $c->id );
is( $a->precedence, 2, "Alert A has a precedence of 2" );
is( $b->precedence, 1, "Alert B has a precedence of 1" );
is( $c->precedence, 3, "Alert C has a precedence of 3" );

# Moving A up by one, should restore original order
$a->move('up');
$a = Koha::AudioAlerts->find( $a->id );
$b = Koha::AudioAlerts->find( $b->id );
$c = Koha::AudioAlerts->find( $c->id );
is( $a->precedence, 1, "Alert A has a precedence of 1" );
is( $b->precedence, 2, "Alert B has a precedence of 2" );
is( $c->precedence, 3, "Alert C has a precedence of 3" );

# Moving A to the bottom
$a->move('bottom');
$a = Koha::AudioAlerts->find( $a->id );
$b = Koha::AudioAlerts->find( $b->id );
$c = Koha::AudioAlerts->find( $c->id );
is( $a->precedence, 3, "Alert A has a precedence of 3" );
is( $b->precedence, 1, "Alert B has a precedence of 1" );
is( $c->precedence, 2, "Alert C has a precedence of 2" );

# Moving A to the top, should restore original order
$a->move('top');
$a = Koha::AudioAlerts->find( $a->id );
$b = Koha::AudioAlerts->find( $b->id );
$c = Koha::AudioAlerts->find( $c->id );
is( $a->precedence, 1, "Alert A has a precedence of 1" );
is( $b->precedence, 2, "Alert B has a precedence of 2" );
is( $c->precedence, 3, "Alert C has a precedence of 3" );

## Test searching, should be ordered by precedence by default
# Test searching, default search should be ordered by precedence
$a->move('bottom');
# Changed precedence order from database insert order
# Insert order was a, b, c. Precedence order is now b, c, a.
( $b, $c, $a ) = Koha::AudioAlerts->search();

is( $b->selector,   'B', 'First sound is indeed B' );
is( $b->precedence, 1,   "Alert B has a precedence of 1" );

is( $c->selector,   'C', "Second sound is indeed C" );
is( $c->precedence, 2,   "Alert C has a precedence of 2" );

is( $a->selector,   'A', 'Third sound is indeed A' );
is( $a->precedence, 3,   "Alert A has a precedence of 3" );

## Test fix precedences, should remove gaps in precedences
# Testing precedence fixing. Should remove gaps from precedence list.
$a->precedence( 0 )->store();
$b->precedence( 50 )->store();
$c->precedence( 100 )->store();
is( $a->precedence, 0, "Alert A has a precedence of 0" );
is( $b->precedence, 50, "Alert B has a precedence of 50" );
is( $c->precedence, 100, "Alert C has a precedence of 100" );

# Running fix_precedences()
Koha::AudioAlerts->fix_precedences();
$a = Koha::AudioAlerts->find( $a->id );
$b = Koha::AudioAlerts->find( $b->id );
$c = Koha::AudioAlerts->find( $c->id );
is( $a->precedence, 1, "Alert A has a precedence of 1" );
is( $b->precedence, 2, "Alert B has a precedence of 2" );
is( $c->precedence, 3, "Alert C has a precedence of 3" );


$schema->storage->txn_rollback();
