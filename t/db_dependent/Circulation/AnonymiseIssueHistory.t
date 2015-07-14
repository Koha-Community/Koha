use Modern::Perl;
use Test::More tests => 3;

use C4::Context;
use C4::Circulation;
use t::lib::Mocks;
use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;

# TODO create a subroutine in t::lib::Mocks
my $userenv_patron = $builder->build( { source => 'Borrower', }, );
C4::Context->_new_userenv('DUMMY SESSION');
C4::Context->set_userenv(
    $userenv_patron->{borrowernumber},
    $userenv_patron->{userid},
    'usercnum', 'First name', 'Surname',
    $userenv_patron->{_fk}{branchcode}{branchcode},
    $userenv_patron->{_fk}{branchcode}{branchname}, 0
);

my $anonymous = $builder->build( { source => 'Borrower', }, );

t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous->{borrowernumber} );

subtest 'patron privacy is 1 (default)' => sub {
    plan tests => 4;
    my $patron = $builder->build(
        {   source => 'Borrower',
            value  => { privacy => 1, }
        }
    );
    my $item = $builder->build(
        {   source => 'Item',
            value  => {
                itemlost  => 0,
                withdrawn => 0,
            },
        }
    );
    my $issue = $builder->build(
        {   source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->{itemnumber},
            },
        }
    );

    my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );
    is( $returned, 1, 'The item should have been returned' );
    my ( $rows_affected, $err ) = C4::Circulation::AnonymiseIssueHistory('2010-10-11');
    ok( $rows_affected > 0, 'AnonymiseIssueHistory should affect at least 1 row' );
    is( $err, undef, 'AnonymiseIssueHistory should not return any error if success' );

    my $dbh = C4::Context->dbh;
    my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
        SELECT borrowernumber FROM old_issues where itemnumber = ?
    |, undef, $item->{itemnumber});
    is( $borrowernumber_used_to_anonymised, $anonymous->{borrowernumber}, 'With privacy=1, the issue should have been anonymised' );

};

subtest 'patron privacy is 0 (forever)' => sub {
    plan tests => 3;

    my $patron = $builder->build(
        {   source => 'Borrower',
            value  => { privacy => 0, }
        }
    );
    my $item = $builder->build(
        {   source => 'Item',
            value  => {
                itemlost  => 0,
                withdrawn => 0,
            },
        }
    );
    my $issue = $builder->build(
        {   source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->{itemnumber},
            },
        }
    );

    my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );
    is( $returned, 1, 'The item should have been returned' );
    my ( $rows_affected, $err ) = C4::Circulation::AnonymiseIssueHistory('2010-10-11');
    is( $err, undef, 'AnonymiseIssueHistory should not return any error if success' );

    my $dbh = C4::Context->dbh;
    my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
        SELECT borrowernumber FROM old_issues where itemnumber = ?
    |, undef, $item->{itemnumber});
    is( $borrowernumber_used_to_anonymised, $patron->{borrowernumber}, 'With privacy=0, the issue should not be anonymised' );
};

t::lib::Mocks::mock_preference( 'AnonymousPatron', '' );

subtest 'AnonymousPatron is not defined' => sub {
    plan tests => 4;
    my $patron = $builder->build(
        {   source => 'Borrower',
            value  => { privacy => 1, }
        }
    );
    my $item = $builder->build(
        {   source => 'Item',
            value  => {
                itemlost  => 0,
                withdrawn => 0,
            },
        }
    );
    my $issue = $builder->build(
        {   source => 'Issue',
            value  => {
                borrowernumber => $patron->{borrowernumber},
                itemnumber     => $item->{itemnumber},
            },
        }
    );

    my ( $returned, undef, undef ) = C4::Circulation::AddReturn( $item->{barcode}, undef, undef, undef, '2010-10-10' );
    is( $returned, 1, 'The item should have been returned' );
    my ( $rows_affected, $err ) = C4::Circulation::AnonymiseIssueHistory('2010-10-11');
    ok( $rows_affected > 0, 'AnonymiseIssueHistory should affect at least 1 row' );
    is( $err, undef, 'AnonymiseIssueHistory should not return any error if success' );

    my $dbh = C4::Context->dbh;
    my ($borrowernumber_used_to_anonymised) = $dbh->selectrow_array(q|
        SELECT borrowernumber FROM old_issues where itemnumber = ?
    |, undef, $item->{itemnumber});
    is( $borrowernumber_used_to_anonymised, undef, 'With AnonymousPatron is not defined, the issue should have been anonymised anyway' );
};
