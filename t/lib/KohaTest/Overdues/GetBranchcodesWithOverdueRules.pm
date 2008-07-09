package KohaTest::Overdues::GetBranchcodesWithOverdueRules;
use base qw( KohaTest::Overdues );

use strict;
use warnings;

use C4::Overdues;
use Test::More;

sub my_branch_has_no_rules : Tests( 2 ) {
    my $self = shift;

    ok( $self->{'branchcode'}, "we're looking for branch $self->{'branchcode'}" );

    my @branches = C4::Overdues::GetBranchcodesWithOverdueRules;
    my @found_branches = grep { $_ eq $self->{'branchcode'} } @branches;
    is( scalar @found_branches, 0, '...and it is not in the list of branches')
    
}

sub my_branch_has_overdue_rules : Tests( 3 ) {
    my $self = shift;

    ok( $self->{'branchcode'}, "we're looking for branch $self->{'branchcode'}" );

    my $dbh = C4::Context->dbh();
    my $sql = <<'END_SQL';
INSERT INTO overduerules
(branchcode,    categorycode,
delay1,        letter1,       debarred1,
delay2,        letter2,       debarred2,
delay3,        letter3,       debarred3)
VALUES
( ?, ?,
?, ?, ?,
?, ?, ?,
?, ?, ?)
END_SQL

    my $sth = $dbh->prepare($sql);
    my $success = $sth->execute( $self->{'branchcode'}, $self->random_string(2),
                                 1, $self->random_string(), 0,
                                 5, $self->random_string(), 0,
                                 9, $self->random_string(), 1, );
    ok( $success, '...and we have successfully given it an overdue rule' );

    my @branches = C4::Overdues::GetBranchcodesWithOverdueRules;
    my @found_branches = grep { $_ eq $self->{'branchcode'} } @branches;
    is( scalar @found_branches, 1, '...and it IS in the list of branches.')
    
}

1;






