package KohaTest::Members::ModMember;
use base qw( KohaTest::Members );

use strict;
use warnings;

use Test::More;

use C4::Members;
sub testing_class { 'C4::Members' };


sub a_simple_usage : Test( 7 ) {
    my $self = shift;

    ok( $self->{'memberid'}, 'we have a valid memberid to test with' );

    my $details = C4::Members::GetMemberDetails( $self->{'memberid'} );
    ok( exists $details->{'dateofbirth'}, 'member details has a "dateofbirth" attribute');
    ok( $details->{'dateofbirth'},        '...and it is set to something' );

    my $new_date_of_birth = $self->random_date();
    like( $new_date_of_birth, qr(^\d\d\d\d-\d\d-\d\d$), 'The new date of birth is a yyyy-mm-dd' );

    my $success = C4::Members::ModMember(
        borrowernumber => $self->{'memberid'},
        dateofbirth    => $new_date_of_birth
    );

    ok( $success, 'we successfully called ModMember' );

    $details = C4::Members::GetMemberDetails( $self->{'memberid'} );
    ok( exists $details->{'dateofbirth'},              'member details still has a "dateofbirth" attribute');
    is( $details->{'dateofbirth'}, $new_date_of_birth, '...and it is set to the new_date_of_birth' );

}

sub incorrect_usage : Test( 1 ) {
    my $self = shift;

    local $TODO = 'ModMember does not fail gracefully yet';
    
    my $result = C4::Members::ModMember();
    ok( ! defined $result, 'ModMember returns false when passed no parameters' );

}

=head2 preserve_dates

In bug 2284, it was determined that a Member's dateofbirth could be
erased by a call to ModMember if no date_of_birth was passed in. Three
date fields (dateofbirth, dateexpiry ,and dateenrolled) are treated
differently than other fields by ModMember. This test method calls
ModMember with none of the date fields set to ensure that they are not
overwritten.

=cut


sub preserve_dates : Test( 18 ) {
    my $self = shift;

    ok( $self->{'memberid'}, 'we have a valid memberid to test with' );

    my %date_fields = (
        dateofbirth  => $self->random_date(),
        dateexpiry   => $self->random_date(),
        dateenrolled => $self->random_date(),
    );

    # stage our member with valid dates in all of the date fields
    my $success = C4::Members::ModMember(
        borrowernumber => $self->{'memberid'},
        %date_fields,
    );
    ok( $success, 'succefully set the date fields.' );
    
    # make sure that we successfully set the date fields. They're not undef.
    my $details = C4::Members::GetMemberDetails( $self->{'memberid'} );
    foreach my $date_field ( keys %date_fields ) {
        ok( exists $details->{$date_field},                     qq(member details has a "$date_field" attribute) );
        ok( $details->{$date_field},                            '...and it is set to something true' );
        is( $details->{$date_field}, $date_fields{$date_field}, '...and it is set to what we set it' );
    }

    # call ModMember to update the firstname. Notice that we're not
    # updating any date fields.
    $success = C4::Members::ModMember(
        borrowernumber => $self->{'memberid'},
        firstname      => $self->random_string,
    );
    ok( $success, 'we successfully called ModMember' );

    # make sure that none of the date fields have been molested by our call to ModMember.
    $details = C4::Members::GetMemberDetails( $self->{'memberid'} );
    foreach my $date_field ( keys %date_fields ) {
        ok( exists $details->{$date_field}, qq(member details still has a "$date_field" attribute) );
        is( $details->{$date_field}, $date_fields{$date_field}, '...and it is set to the expected value' );
    }

}

1;
