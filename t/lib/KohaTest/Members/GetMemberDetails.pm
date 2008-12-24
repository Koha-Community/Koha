package KohaTest::Members::GetMemberDetails;
use base qw( KohaTest::Members );

use strict;
use warnings;

use Test::More;

use C4::Members;

sub testing_class { 'C4::Members' }

=head3 STARTUP METHODS

These are run once, before the main test methods in this module.

=head2 startup_create_detailed_borrower

Creates a new borrower to be used by the testing methods.  Also
populates the class hash with values to be compared from the database
retrieval.

=cut

sub startup_create_detailed_borrower : Test( startup => 2 ) {
    my $self = shift;
    my ( $description, $type, $amount, $user );

    my $memberinfo = {
        surname      => 'surname' . $self->random_string(),
        firstname    => 'firstname' . $self->random_string(),
        address      => 'address' . $self->random_string(),
        city         => 'city' . $self->random_string(),
        cardnumber   => 'card' . $self->random_string(),
        branchcode   => 'CPL',
        categorycode => 'B',
        dateexpiry   => '2020-01-01',
        password     => 'testpassword',
        userid       => 'testuser',
        flags        => '0',
        dateofbirth  => $self->random_date(),
    };

    my $borrowernumber = AddMember( %$memberinfo );
    ok( $borrowernumber, "created member: $borrowernumber" );
    $self->{detail_borrowernumber} = $borrowernumber;
    $self->{detail_cardnumber}     = $memberinfo->{cardnumber};

    #values for adding a record to accounts
    $description = 'Test account';
    $type        = 'M';
    $amount      = 5.00;
    $user        = '';

    my $acct_added =
      C4::Accounts::manualinvoice( $borrowernumber, undef, $description, $type, $amount,
        $user );

    ok( $acct_added == 0, 'added account for borrower' );

    $self->{amountoutstanding} = $amount;

    return;
}

=head2 TESTING METHODS

=head3 borrower_detail_get

Tests the functionality of the GetMemberDetails method in C4::Members.
Validates the join on categories table works as well as the extra fields
the method gets from outside of either the borrowers and categories table like
amountoutstanding and user flags.

=cut

sub borrower_detail_get : Test( 8 ) {
    my $self = shift;

    ok( $self->{detail_borrowernumber},
        'we have a valid detailed borrower to test with' );

    my $details = C4::Members::GetMemberDetails( $self->{detail_borrowernumber} );
    ok( $details, 'we successfully called GetMemberDetails' );
    ok( exists $details->{categorycode},
        'member details has a "categorycode" attribute' );
    ok( $details->{categorycode}, '...and it is set to something' );

    ok( exists $details->{category_type}, "categories in the join returned values" );

    ok( $details->{category_type}, '...and category_type is valid' );

    ok( $details->{amountoutstanding}, 'an amountoutstanding exists' );
    is( $details->{amountoutstanding},
        $self->{amountoutstanding},
        '...and matches inserted account record'
    );

}

=head3 cardnumber_detail_get

This method tests the capability of GetMemberDetails to search on cardnumber.  There doesn't seem to be any
current calls to GetMemberDetail using cardnumber though, so this test may not be necessary.

=cut

sub cardnumber_detail_get : Test( 8 ) {
    my $self = shift;

    ok( $self->{detail_cardnumber},
        "we have a valid detailed borrower to test with $self->{detail_cardnumber}" );

    my $details = C4::Members::GetMemberDetails( undef, $self->{detail_cardnumber} );
    ok( $details, 'we successfully called GetMemberDetails' );
    ok( exists $details->{categorycode},
        "member details has a 'categorycode' attribute $details->{categorycode}" );
    ok( $details->{categorycode}, '...and it is set to something' );

    ok( exists $details->{category_type}, "categories in the join returned values" );

    ok( $details->{category_type}, '...and category_type is valid' );

#FIXME These 2 methods will fail as borrowernumber is not set in GetMemberDetails when cardnumber is used instead.
#ok( $details->{amountoutstanding}, 'an amountoutstanding exists' );
#is( $details->{amountoutstanding}, $self->{amountoutstanding}, '...and matches inserted account record' );
}

=head2 SHUTDOWN METHDOS

These get run once, after the main test methods in this module.

=head3 shutdown_remove_new_borrower

Removes references in the Class to the new borrower created
in the startup methods.

=cut

sub shutdown_remove_new_borrower : Test( shutdown => 0 ) {
    my $self = shift;

    delete $self->{detail_borrowernumber};
    delete $self->{detail_cardnumber};
    delete $self->{amountoutstanding};

    return;
}

1;
