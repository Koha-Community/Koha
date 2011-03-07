package KohaTest::Koha::displayServers;
use base qw( KohaTest::Koha );

use strict;
use warnings;

use Test::More;

use C4::Koha;

=head2 basic_usage

call displayServers with no parameters and investigate the things that
it returns. This depends on there being at least one server defined,
as do some other tests in this module.

=cut

sub basic_usage : Test( 12 ) {
    my $self = shift;

    my $servers = C4::Koha::displayServers();
    isa_ok( $servers, 'ARRAY' );
    my $firstserver = $servers->[0];
    isa_ok( $firstserver, 'HASH' );

    my @keys = qw( opensearch icon value name checked zed label id encoding );
    is( scalar keys %$firstserver, scalar @keys, 'the hash has the right number of keys' );
    foreach my $key ( @keys ) {
        ok( exists $firstserver->{$key}, "There is a $key key" );
    }

    # diag( Data::Dumper->Dump( [ $servers ], [ 'servers' ] ) );
}

=head2 position_does_not_exist

call displayServers with a position that does not exist and make sure
that we get none back.

=cut

sub position_does_not_exist : Test( 2 ) {
    my $self = shift;

    my $servers = C4::Koha::displayServers( 'this does not exist' );
    isa_ok( $servers, 'ARRAY' );
    is( scalar @$servers, 0, 'received no servers' );

    # diag( Data::Dumper->Dump( [ $servers ], [ 'servers' ] ) );
}

=head2 position_does_exist

call displayServers with a position that does exist and make sure that
we get at least one back.

=cut

sub position_does_exist : Test( 3 ) {
    my $self = shift;

    my $position = $self->_get_a_position();
    ok( $position, 'We have a position that exists' );
    
    my $servers = C4::Koha::displayServers( $position );
    isa_ok( $servers, 'ARRAY' );
    ok( scalar @$servers, 'received at least one server' );

    # diag( Data::Dumper->Dump( [ $servers ], [ 'servers' ] ) );
}

=head2 type_does_not_exist

call displayServers with a type that does not exist and make sure
that we get none back.

=cut

sub type_does_not_exist : Test( 2 ) {
    my $self = shift;

    my $servers = C4::Koha::displayServers( undef, 'this does not exist' );
    isa_ok( $servers, 'ARRAY' );
    is( scalar @$servers, 0, 'received no servers' );

    # diag( Data::Dumper->Dump( [ $servers ], [ 'servers' ] ) );
}

=head2 type_does_exist

call displayServers with a type that does exist and make sure
that we get at least one back.

=cut

sub type_does_exist : Test( 3 ) {
    my $self = shift;

    my $type = $self->_get_a_type();
    ok( $type, 'We have a type that exists' );
    
    my $servers = C4::Koha::displayServers( undef, $type );
    isa_ok( $servers, 'ARRAY' );
    ok( scalar @$servers, 'received at least one server' );

    # diag( Data::Dumper->Dump( [ $servers ], [ 'servers' ] ) );
}

=head2 position_and_type

call displayServers with a variety of both positions and types and
verify that we get either something or nothing back.


=cut

sub position_and_type : Test( 8 ) {
    my $self = shift;

    my ( $position, $type ) = $self->_get_a_position_and_type();
    ok( $position, 'We have a type that exists' );
    ok( $type, 'We have a type that exists' );
    
    my $servers = C4::Koha::displayServers( $position, 'type does not exist' );
    isa_ok( $servers, 'ARRAY' );
    is( scalar @$servers, 0, 'received no servers' );

    $servers = C4::Koha::displayServers( 'position does not exist', $type );
    isa_ok( $servers, 'ARRAY' );
    is( scalar @$servers, 0, 'received no servers' );

    $servers = C4::Koha::displayServers( $position, $type );
    isa_ok( $servers, 'ARRAY' );
    ok( scalar @$servers, 'received at least one server' );

    # diag( Data::Dumper->Dump( [ $servers ], [ 'servers' ] ) );
}

=head1 INTERNAL METHODS

these are not test methods, but they help me write them.

=head2 _get_a_position

returns a position value for which at least one server exists

=cut

sub _get_a_position {
    my $self = shift;

    my ( $position, $type ) = $self->_get_a_position_and_type();
    return $position;

}

=head2 _get_a_type

returns a type value for which at least one server exists

=cut

sub _get_a_type {
    my $self = shift;

    my ( $position, $type ) = $self->_get_a_position_and_type();
    return $type;

}

=head2 _get_a_position_and_type

returns a position and type for a server

=cut

sub _get_a_position_and_type {
    my $self = shift;

    my $dbh    = C4::Context->dbh;
    my $sql = 'SELECT position, type FROM z3950servers';
    my $sth = $dbh->prepare($sql) or return;
    $sth->execute or return;

    my @row = $sth->fetchrow_array;
    return ( $row[0], $row[1] );

}

  
1;
