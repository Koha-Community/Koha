#!/usr/bin/perl

use Modern::Perl;

use C4::Members qw/AddMember GetMember GetBorrowercategory/;
use C4::Branch;
use CGI;

use Test::More tests => 15;

BEGIN {
    use_ok('C4::ILSDI::Services');
}

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Create patron
my %data = (
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => 'UT',
    branchcode => 'UT',
    cardnumber => 'ilsdi-cardnumber',
    userid => 'ilsdi-userid',
    password => 'ilsdi-password',
);

# Crate patron category
unless ( GetBorrowercategory('UT') ) {
    $dbh->do("INSERT INTO categories
    (categorycode,description,enrolmentperiod,upperagelimit,enrolmentfee,overduenoticerequired,reservefee,category_type)
        VALUES
    ('UT','Unit tester',99,99,0.000000,1,0.000000,'C');");
}

# Create branch
unless ( GetBranchDetail('DEMO') ) {
    $dbh->do("INSERT INTO branches (branchcode,branchname) VALUES ('UT','Unit test library');");
}


my $borrowernumber = AddMember(%data);
my $borrower = GetMember( borrowernumber => $borrowernumber );

{ # AuthenticatePatron test

    my $query = new CGI;
    $query->param('username',$borrower->{'userid'});
    $query->param('password','ilsdi-password');

    my $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is($reply->{'id'}, $borrowernumber, "userid and password - Patron authenticated");
    is($reply->{'code'}, undef, "Error code undef");

    $query->param('password','ilsdi-passworD');
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is($reply->{'code'}, 'PatronNotFound', "userid and wrong password - PatronNotFound");
    is($reply->{'id'}, undef, "id undef");

    $query->param('password','ilsdi-password');
    $query->param('username','wrong-ilsdi-useriD');
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is($reply->{'code'}, 'PatronNotFound', "non-existing userid - PatronNotFound");
    is($reply->{'id'}, undef, "id undef");

    $query->param('username',uc($borrower->{'userid'}));
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is($reply->{'id'}, $borrowernumber, "userid is not case sensitive - Patron authenticated");
    is($reply->{'code'}, undef, "Error code undef");

TODO: { local: $TODO = "Can't use cardnumber for authentication with ILS-DI yet.";
    $query->param('username',$borrower->{'cardnumber'});
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is($reply->{'id'}, $borrowernumber, "cardnumber and password - Patron authenticated");
    is($reply->{'code'}, undef, "Error code undef");

    $query->param('password','ilsdi-passworD');
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is($reply->{'code'}, 'PatronNotFound', "cardnumber and wrong password - PatronNotFount");
    is($reply->{'id'}, undef, "id undef");

    $query->param('username','randomcardnumber1234');
    $query->param('password','ilsdi-password');
    $reply = C4::ILSDI::Services::AuthenticatePatron($query);
    is($reply->{'code'}, 'PatronNotFound', "non-existing cardnumer/userid - PatronNotFound");
    is($reply->{'id'}, undef, "id undef");
    }

}
