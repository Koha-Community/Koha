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

use Test::More tests => 7;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::List::Patron
    qw( AddPatronList AddPatronsToList DelPatronList DelPatronsFromList GetPatronLists ModPatronList );

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

C4::Context->_new_userenv('DUMMY SESSION');
C4::Context->set_userenv( 0 ); # Koha::List::Patron only needs a number

# Create 10 sample borrowers
my @borrowers = ();
foreach (1..10) {
    push @borrowers, $builder->build({ source => 'Borrower' });
}

my $owner = $borrowers[0]->{borrowernumber};

my @lists = GetPatronLists( { owner => $owner } );
my $list_count_original = @lists;

my $list1 = AddPatronList( { name => 'Test List 1', owner => $owner } );
ok( $list1->name() eq 'Test List 1', 'AddPatronList works' );

my $list2 = AddPatronList( { name => 'Test List 2', owner => $owner } );

ModPatronList(
    {
        patron_list_id => $list2->patron_list_id(),
        name           => 'Test List 3',
        owner          => $owner
    }
);
$list2->discard_changes();
ok( $list2->name() eq 'Test List 3', 'ModPatronList works' );

AddPatronsToList(
    { list => $list1, cardnumbers => [ map { $_->{cardnumber} } @borrowers ] }
);
ok(
    scalar @borrowers ==
      $list1->patron_list_patrons()->search_related('borrowernumber')->all(),
    'AddPatronsToList works for cardnumbers'
);

AddPatronsToList(
    {
        list            => $list2,
        borrowernumbers => [ map { $_->{borrowernumber} } @borrowers ]
    }
);
ok(
    scalar @borrowers ==
      $list2->patron_list_patrons()->search_related('borrowernumber')->all(),
    'AddPatronsToList works for borrowernumbers'
);

my @ids =
  $list1->patron_list_patrons()->get_column('patron_list_patron_id')->all();
DelPatronsFromList(
    {
        list                => $list1,
        patron_list_patrons => \@ids,
    }
);
$list1->discard_changes();
ok( !$list1->patron_list_patrons()->count(), 'DelPatronsFromList works.' );

@lists = GetPatronLists( { owner => $owner } );
ok( @lists == $list_count_original + 2, 'GetPatronLists works' );

DelPatronList( { patron_list_id => $list1->patron_list_id(), owner => $owner } );
DelPatronList( { patron_list_id => $list2->patron_list_id(), owner => $owner } );

@lists =
  GetPatronLists( { patron_list_id => $list1->patron_list_id(), owner => $owner } );
ok( !@lists, 'DelPatronList works' );

$schema->storage->txn_rollback;

