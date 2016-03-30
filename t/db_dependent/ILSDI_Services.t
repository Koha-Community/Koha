#!/usr/bin/perl

use Modern::Perl;

use C4::Members qw/AddMember GetMember GetBorrowercategory/;
use Koha::Libraries;
use CGI qw ( -utf8 );

use Test::More tests => 16;
use t::lib::Mocks;
use t::lib::TestBuilder;

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
    (categorycode,description,enrolmentperiod,upperagelimit,enrolmentfee,overduenoticerequired,reservefee,category_type,default_privacy)
        VALUES
    ('UT','Unit tester',99,99,0.000000,1,0.000000,'C','default');");
}

# Create library
unless ( Koha::Libraries->find('UT') ) {
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

# End transaction
$dbh->rollback;
$dbh->{AutoCommit} = 1;
$dbh->{RaiseError} = 0;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;

$schema->resultset( 'Issue' )->delete_all;
$schema->resultset( 'Borrower' )->delete_all;
$schema->resultset( 'BorrowerAttribute' )->delete_all;
$schema->resultset( 'BorrowerAttributeType' )->delete_all;
$schema->resultset( 'Category' )->delete_all;
$schema->resultset( 'Item' )->delete_all; # 'Branch' deps. on this
$schema->resultset( 'Branch' )->delete_all;


{ # GetPatronInfo/GetBorrowerAttributes test for extended patron attributes:

    # Configure Koha to enable ILS-DI server and extended attributes:
    t::lib::Mocks::mock_preference( 'ILS-DI', 1 );
    t::lib::Mocks::mock_preference( 'ExtendedPatronAttributes', 1 );

    my $builder = t::lib::TestBuilder->new;

    # Set up a library/branch for our user to belong to:
    my $lib = $builder->build( {
        source => 'Branch',
        value => {
            branchcode => 'T_ILSDI',
        }
    } );

    # Create a new category for user to belong to:
    my $cat = $builder->build( {
        source => 'Category',
        value  => {
            category_type                 => 'A',
            BlockExpiredPatronOpacActions => -1,
        }
    } );

    # Create a new attribute type:
    my $attr_type = $builder->build( {
        source => 'BorrowerAttributeType',
        value  => {
            code                      => 'DOORCODE',
            opac_display              => 0,
            authorised_value_category => '',
            class                     => '',
        }
    } );

    # Create a new user:
    my $brwr = $builder->build( {
        source => 'Borrower',
        value  => {
            categorycode => $cat->{'categorycode'},
            branchcode   => $lib,
        }
    } );

    # Authorised value:
    my $auth = $builder->build( {
        source => 'AuthorisedValue',
        value  => {
            category => $cat->{'categorycode'}
        }
    } );

    # Set the new attribute for our user:
    my $attr = $builder->build( {
        source => 'BorrowerAttribute',
        value  => {
            borrowernumber => $brwr->{'borrowernumber'},
            code           => $attr_type->{'code'},
            attribute      => '1337',
            password       => undef,
        }
    } );

    # Prepare and send web request for IL-SDI server:
    my $query = new CGI;
    $query->param( 'service', 'GetPatronInfo' );
    $query->param( 'patron_id', $brwr->{'borrowernumber'} );
    $query->param( 'show_attributes', '1' );

    my $reply = C4::ILSDI::Services::GetPatronInfo( $query );

    # Build a structure for comparison:
    my $cmp = {
        category_code     => $attr_type->{'category_code'},
        class             => $attr_type->{'class'},
        code              => $attr->{'code'},
        description       => $attr_type->{'description'},
        display_checkout  => $attr_type->{'display_checkout'},
        password          => undef,
        value             => $attr->{'attribute'},
        value_description => undef,
    };

    # Check results:
    is_deeply( $reply->{'attributes'}, [ $cmp ], 'Test GetPatronInfo - show_attributes parameter' );
}

# Cleanup
$schema->storage->txn_rollback;
