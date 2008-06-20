package KohaTest::Letters::GetLetters;
use base qw( KohaTest::Letters );

use strict;
use warnings;

use C4::Letters;
use Test::More;

sub GetDefaultLetters : Test( 2 ) {
    my $self = shift;

    my $letters = GetLetters();

    # the default install includes several entries in the letter table.
    isa_ok( $letters, 'HASH' )
      or diag( Data::Dumper->Dump( [ $letters ], [ 'letters' ] ) );

  ok( scalar keys( %$letters ) > 0, 'we got some letters' );


}

1;






