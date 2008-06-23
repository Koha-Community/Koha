package KohaTest::Koha::getitemtypeimagedir;
use base qw( KohaTest::Koha );

use strict;
use warnings;

use Test::More;

use C4::Koha;

sub check_default : Test( 5 ) {
    my $self = shift;

    my $opac_directory     = C4::Koha::getitemtypeimagedir('opac');
    my $default_directory  = C4::Koha::getitemtypeimagedir('opac');
    my $intranet_directory = C4::Koha::getitemtypeimagedir('intranet');

    ok( $opac_directory,     'the opac directory is defined' );
    ok( $default_directory,  'the default directory is defined' );
    ok( $intranet_directory, 'the intranet directory is defined' );

    is( $opac_directory, $default_directory, 'the opac directory is returned as the default' );
    isnt( $intranet_directory, $default_directory, 'the intranet directory is not the same as the default' );

}

1;
