package KohaTest::Search::SimpleSearch;
use base qw( KohaTest::Search );

use strict;
use warnings;

use Test::More;

use C4::Search;
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

=head2 STARTUP METHODS

standard test methods

=head3 basic_test

basic usage.

=cut

sub basic_test : Test( 2 ) {
    my $self = shift;

    my $query = 'test';

    my ( $error, $results ) = SimpleSearch( $query );
    ok( ! defined $error, 'no error found during search' );
    like( $results->[0], qr/$query/i, 'the result seems to match the query' )
      or diag( Data::Dumper->Dump( [ $results ], [ 'results' ] ) );
    
}

=head3 basic_test_with_server

Test the usage where we specify no limits, but we do specify a server.

=cut

sub basic_test_with_server : Test( 2 ) {
    my $self = shift;

    my $query = 'test';

    my ( $error, $results ) = SimpleSearch( $query, undef, undef, [ 'biblioserver' ] );
    ok( ! defined $error, 'no error found during search' );
    like( $results->[0], qr/$query/i, 'the result seems to match the query' )
      or diag( Data::Dumper->Dump( [ $results ], [ 'results' ] ) );
    
}


=head3 basic_test_no_results

Make sure we get back an empty listref when there are no results.

=cut

sub basic_test_no_results : Test( 3 ) {
    my $self = shift;

    my $query = 'This string is almost guaranteed to not match anything.';

    my ( $error, $results ) = SimpleSearch( $query );
    ok( ! defined $error, 'no error found during search' );
    isa_ok( $results, 'ARRAY' );
    is( scalar( @$results ), 0, 'an empty list was returned.' )
      or diag( Data::Dumper->Dump( [ $results ], [ 'results' ] ) );
}

=head3 limits

check that the SimpleTest method limits the number of results returned.

=cut

sub limits : Test( 8 ) {
    my $self = shift;

    my $query = 'Finn Test';

    {
        my ( $error, $results ) = SimpleSearch( $query );
        ok( ! defined $error, 'no error found during search' );
        is( scalar @$results, 10, 'found all 10 results.' )
          or diag( Data::Dumper->Dump( [ $results ], [ 'results' ] ) );
    }
    
    my $offset = 4;
    {
        my ( $error, $results ) = SimpleSearch( $query, $offset );
        ok( ! defined $error, 'no error found during search' );
        is( scalar @$results, 6, 'found 6 results.' )
          or diag( Data::Dumper->Dump( [ $results ], [ 'results' ] ) );
    }

    my $max_results = 2;
    {
        my ( $error, $results ) = SimpleSearch( $query, $offset, $max_results );
        ok( ! defined $error, 'no error found during search' );
        is( scalar @$results, $max_results, "found $max_results results." )
          or diag( Data::Dumper->Dump( [ $results ], [ 'results' ] ) );
    }
    
    {
        my ( $error, $results ) = SimpleSearch( $query, 0, $max_results );
        ok( ! defined $error, 'no error found during search' );
        is( scalar @$results, $max_results, "found $max_results results." )
          or diag( Data::Dumper->Dump( [ $results ], [ 'results' ] ) );
    }
    
       
}


1;
