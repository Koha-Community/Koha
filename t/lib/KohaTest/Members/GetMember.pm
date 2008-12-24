package KohaTest::Members::GetMember;
use base qw( KohaTest::Members );

use strict;
use warnings;

use Test::More;

use C4::Members;

sub testing_class { 'C4::Members' }

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=head3 startup_create_borrower

Creates a new borrower to use for these tests.  Class variables that are
used to search by are stored for easy access by the methods.

=cut

sub startup_create_borrower : Test( startup => 1 ) {
    my $self = shift;

    my $memberinfo = {
        surname      => 'surname'   . $self->random_string(),
        firstname    => 'firstname' . $self->random_string(),
        address      => 'address'   . $self->random_string(),
        city         => 'city'      . $self->random_string(),
        cardnumber   => 'card'      . $self->random_string(),
        branchcode   => 'CPL',
        categorycode => 'B',    # B  => Board
        dateexpiry   => '2020-01-01',
        password     => 'testpassword',
        userid       => 'testuser',
        dateofbirth  => $self->random_date(),
    };

    my $borrowernumber = AddMember( %$memberinfo );
    ok( $borrowernumber, "created member: $borrowernumber" );
    $self->{get_new_borrowernumber} = $borrowernumber;
    $self->{get_new_cardnumber}     = $memberinfo->{cardnumber};
    $self->{get_new_firstname}      = $memberinfo->{firstname};
    $self->{get_new_userid}         = $memberinfo->{userid};

    return;
}

=head2 TESTING METHODS

Standard test methods

=head3 borrowernumber_get

Validates that GetMember can search by borrowernumber

=cut

sub borrowernumber_get : Test( 6 ) {
    my $self = shift;

    ok( $self->{get_new_borrowernumber},
        "we have a valid memberid $self->{get_new_borrowernumber} to test with" );

    #search by borrowernumber
    my $results =
      C4::Members::GetMember( $self->{get_new_borrowernumber}, 'borrowernumber' );
    ok( $results, 'we successfully called GetMember searching by borrowernumber' );

    ok( exists $results->{borrowernumber},
        'member details has a "borrowernumber" attribute' );
    is( $results->{borrowernumber},
        $self->{get_new_borrowernumber},
        '...and it matches the created borrowernumber'
    );

    ok( exists $results->{'category_type'}, "categories in the join returned values" );
    ok( $results->{description}, "...and description is valid: $results->{description}" );
}

=head3 cardnumber_get

Validates that GetMember can search by cardnumber

=cut

sub cardnumber_get : Test( 6 ) {
    my $self = shift;

    ok( $self->{get_new_cardnumber},
        "we have a valid cardnumber $self->{get_new_cardnumber} to test with" );

    #search by cardnumber
    my $results = C4::Members::GetMember( $self->{get_new_cardnumber}, 'cardnumber' );
    ok( $results, 'we successfully called GetMember searching by cardnumber' );

    ok( exists $results->{cardnumber}, 'member details has a "cardnumber" attribute' );
    is( $results->{cardnumber},
        $self->{get_new_cardnumber},
        '..and it matches the created cardnumber'
    );

    ok( exists $results->{'category_type'}, "categories in the join returned values" );
    ok( $results->{description}, "...and description is valid: $results->{description}" );
}

=head3 firstname_get

Validates that GetMember can search by firstname.
Note that only the first result is used.

=cut

sub firstname_get : Test( 6 ) {
    my $self = shift;

    ok( $self->{get_new_firstname},
        "we have a valid firstname $self->{get_new_firstname} to test with" );

    ##search by firstname
    my $results = C4::Members::GetMember( $self->{get_new_firstname}, 'firstname' );
    ok( $results, 'we successfully called GetMember searching by firstname' );

    ok( exists $results->{firstname}, 'member details has a "firstname" attribute' );
    is( $results->{'firstname'},
        $self->{get_new_firstname},
        '..and it matches the created firstname'
    );

    ok( exists $results->{'category_type'}, "categories in the join returned values" );
    ok( $results->{description}, "...and description is valid: $results->{description}" );
}

=head3 userid_get

Validates that GetMember can search by userid.

=cut

sub userid_get : Test( 6 ) {
    my $self = shift;

    ok( $self->{get_new_userid},
        "we have a valid userid $self->{get_new_userid} to test with" );

    #search by userid
    my $results = C4::Members::GetMember( $self->{get_new_userid}, 'userid' );
    ok( $results, 'we successfully called GetMember searching by userid' );

    ok( exists $results->{'userid'}, 'member details has a "userid" attribute' );
    is( $results->{userid},
        $self->{get_new_userid},
        '..and it matches the created userid'
    );

    ok( exists $results->{'category_type'}, "categories in the join returned values" );
    ok( $results->{description}, "...and description is valid: $results->{description}" );
}

=head3 missing_params

Validates that GetMember returns undef when no parameters are passed to it

=cut

sub missing_params : Test( 1 ) {
    my $self = shift;

    my $results = C4::Members::GetMember();

    ok( !defined $results, 'returned undef when no parameters passed' );

}

=head2 SHUTDOWN METHODS

These get run once, after the main test methods in this module

=head3 shutdown_remove_borrower

Remove the new borrower information that was created in the startup method

=cut

sub shutdown_remove_borrower : Test( shutdown => 0 ) {
    my $self = shift;

    delete $self->{get_new_borrowernumber};
    delete $self->{get_new_cardnumber};
    delete $self->{get_new_firstname};
    delete $self->{get_new_userid};

}

1;
