package KohaTest::Biblio::get_biblio_authorised_values;
use base qw( KohaTest::Biblio );

use strict;
use warnings;

use Test::More;

use C4::Biblio;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=head3 insert_test_data

=cut

sub insert_test_data : Test( startup => 71 ) {
    my $self = shift;
    
    # I'm going to add a bunch of biblios so that I can search for them.
    $self->add_biblios( count     => 10,
                        add_items => 1 );
    

}

=head2 TEST METHODS

standard test methods

=head3 basic_test

basic usage.

=cut

sub basic_test : Test( 1 ) {
    my $self = shift;

    ok( $self->{'biblios'}[0], 'we have a biblionumber' );
    my $authorised_values = C4::Biblio::get_biblio_authorised_values( $self->{'biblios'}[0] );
    diag( Data::Dumper->Dump( [ $authorised_values ], [ 'authorised_values' ] ) );
    
}

1;
