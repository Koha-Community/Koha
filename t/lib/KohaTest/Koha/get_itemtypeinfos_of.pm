package KohaTest::Koha::get_itemtypeinfos_of;
use base qw( KohaTest::Koha );

use strict;
use warnings;

use Test::More;

use C4::Koha;

=head2 get_one

calls get_itemtypeinfos_of on one item type and checks that it gets
back something sane.

=cut

sub get_one : Test( 8 ) {
    my $self = shift;

    my $itemtype_info = C4::Koha::get_itemtypeinfos_of( 'BK' );
    ok( $itemtype_info, 'we got back something from get_itemtypeinfos_of' );
    isa_ok( $itemtype_info, 'HASH', '...and it' );
    ok( exists $itemtype_info->{'BK'}, '...and it has a BK key' )
      or diag( Data::Dumper->Dump( [ $itemtype_info ], [ 'itemtype_info' ] ) );
    is( scalar keys %$itemtype_info, 1, '...and it has 1 key' );
    foreach my $key ( qw( imageurl itemtype notforloan description ) ) {
        ok( exists $itemtype_info->{'BK'}{$key}, "...and the BK info has a $key key" );
    }
    
}

=head2 get_two

calls get_itemtypeinfos_of on a list of item types and verifies the
results.

=cut

sub get_two : Test( 13 ) {
    my $self = shift;

    my @itemtypes = qw( BK MU );
    my $itemtype_info = C4::Koha::get_itemtypeinfos_of( @itemtypes );
    ok( $itemtype_info, 'we got back something from get_itemtypeinfos_of' );
    isa_ok( $itemtype_info, 'HASH', '...and it' );
    is( scalar keys %$itemtype_info, scalar @itemtypes, '...and it has ' . scalar @itemtypes . ' keys' );
    foreach my $it ( @itemtypes ) {
        ok( exists $itemtype_info->{$it}, "...and it has a $it key" )
          or diag( Data::Dumper->Dump( [ $itemtype_info ], [ 'itemtype_info' ] ) );
        foreach my $key ( qw( imageurl itemtype notforloan description ) ) {
            ok( exists $itemtype_info->{$it}{$key}, "...and the $it info has a $key key" );
        }
    }
    
}

  
1;
