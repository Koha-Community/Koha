package KohaTest::Installer::get_file_path_from_name;
use base qw( KohaTest::Installer );

use strict;
use warnings;

use Test::More;
use C4::Languages;
use C4::Installer;

sub startup_50_get_installer : Test( startup => 1 ) {
    my $self = shift;
    my $installer = C4::Installer->new();
    is(ref($installer), "C4::Installer", "created installer");
    $self->{installer} = $installer;
}

sub search_for_known_scripts : Tests( 2 ) {
    my $self = shift;

    skip "did not create installer" unless ref($self->{installer}) eq 'C4::Installer';

    foreach my $script ( 'installer/data/mysql/en/mandatory/message_transport_types.sql',
                         'installer/data/mysql/en/optional/sample_notices_message_attributes.sql', ) {

        ok( $self->{'installer'}->get_file_path_from_name( $script ), "found $script" );
    }
    
}

sub shutdown_50_clear_installer : Tests( shutdown ) {
    my $self = shift;
    delete $self->{installer};
}

1;
