#!/usr/bin/perl
#
use Modern::Perl;

use Test::More tests => 9;

BEGIN {
    use_ok('C4::Context');
    use_ok('Koha::List::Patron');
}

C4::Context->_new_userenv('DUMMY SESSION');
C4::Context->set_userenv(0,0,0,'firstname','surname', 'BRANCH1', 'Library 1', 0, ', ');

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare("SELECT * FROM borrowers ORDER BY RAND() LIMIT 10");
$sth->execute();
my @borrowers = @{ $sth->fetchall_arrayref( {} ) };

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
