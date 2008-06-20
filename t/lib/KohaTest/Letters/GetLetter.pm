package KohaTest::Letters::GetLetter;
use base qw( KohaTest::Letters );

use strict;
use warnings;

use C4::Letters;
use Test::More;

sub GetLetter : Test( 6 ) {
    my $self = shift;

    my $letter = getletter( 'circulation', 'ODUE' );

    isa_ok( $letter, 'HASH' )
      or diag( Data::Dumper->Dump( [ $letter ], [ 'letter' ] ) );

    is( $letter->{'code'},   'ODUE',        'code' );
    is( $letter->{'module'}, 'circulation', 'module' );
    ok( exists $letter->{'content'}, 'content' );
    ok( exists $letter->{'name'}, 'name' );
    ok( exists $letter->{'title'}, 'title' );


}

1;






