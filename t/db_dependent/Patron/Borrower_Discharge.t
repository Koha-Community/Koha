#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 23;

use Test::MockModule;
use Test::Warn;

use IPC::Cmd qw(can_run);
use MARC::Record;

use C4::Circulation qw( AddIssue AddReturn );
use C4::Biblio qw( AddBiblio );
use C4::Context;

use Koha::Patrons;
use Koha::Patron::Discharge;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do(q|DELETE FROM discharges|);

my $library         = $builder->build({ source => 'Branch' });
my $another_library = $builder->build({ source => 'Branch' });
my $itemtype        = $builder->build({ source => 'Itemtype' })->{itemtype};

C4::Context->_new_userenv('xxx');
my $patron = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library->{branchcode},
        flags      => 1, # superlibrarian
    }
});
my $p = Koha::Patrons->find( $patron->{borrowernumber} );
t::lib::Mocks::mock_userenv({ patron => $p });

my $patron2 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $library->{branchcode},
    }
});
my $patron3 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode => $another_library->{branchcode},
        flags => undef,
    }
});
my $p3 = Koha::Patrons->find( $patron3->{borrowernumber} );

# Discharge not possible with issues
my ( $biblionumber ) = AddBiblio( MARC::Record->new, '');
my $barcode = 'BARCODE42';
$builder->build_sample_item(
    {
        biblionumber => $biblionumber,
        library      => $library->{branchcode},
        barcode      => $barcode,
        itype        => $itemtype
    }
);

AddIssue( $patron, $barcode );
is( Koha::Patron::Discharge::can_be_discharged({ borrowernumber => $patron->{borrowernumber} }), 0, 'A patron with issues cannot be discharged' );

is( Koha::Patron::Discharge::request({ borrowernumber => $patron->{borrowernumber} }), undef, 'No request done if patron has issues' );
is( Koha::Patron::Discharge::discharge({ borrowernumber => $patron->{borrowernumber} }), undef, 'No discharge done if patron has issues' );
is_deeply( [ Koha::Patron::Discharge::get_pendings ], [], 'There is no pending discharge request' );
is_deeply( [ Koha::Patron::Discharge::get_validated ], [], 'There is no validated discharge' );

AddReturn( $barcode );

# Discharge possible without issue
is( Koha::Patron::Discharge::can_be_discharged({ borrowernumber => $patron->{borrowernumber} }), 1, 'A patron without issues can be discharged' );

is(Koha::Patron::Discharge::generate_as_pdf,undef,"Confirm failure when lacking borrower number");

# Verify that the user is not discharged anymore if the restriction has been lifted
Koha::Patron::Discharge::discharge( { borrowernumber => $patron->{borrowernumber} } );
Koha::Patron::Discharge::discharge( { borrowernumber => $patron2->{borrowernumber} } );
Koha::Patron::Discharge::discharge( { borrowernumber => $patron3->{borrowernumber} } );
is( Koha::Patron::Discharge::is_discharged( { borrowernumber => $patron->{borrowernumber} } ), 1, 'The patron has been discharged' );
is( Koha::Patrons->find( $patron->{borrowernumber} )->is_debarred, '9999-12-31', 'The patron has been debarred after discharge' );
is( scalar( Koha::Patron::Discharge::get_validated ),             3,            'There are 3 validated discharges' );
is( scalar( Koha::Patron::Discharge::get_validated( { borrowernumber => $patron->{borrowernumber} } ) ), 1, 'There is 1 validated discharge for a given patron' );
is( scalar( Koha::Patron::Discharge::get_validated( { branchcode => $library->{branchcode} } ) ), 2, 'There is 2 validated discharges for a given branchcode' );    # This is not used in the code yet
Koha::Patron::Debarments::DelUniqueDebarment( { 'borrowernumber' => $patron->{borrowernumber}, 'type' => 'DISCHARGE' } );
ok( !Koha::Patrons->find( $patron->{borrowernumber} )->is_debarred, 'The debarment has been lifted' );
ok( !Koha::Patron::Discharge::is_discharged( { borrowernumber => $patron->{borrowernumber} } ), 'The patron is not discharged after the restriction has been lifted' );

# Verify that the discharge works multiple times
Koha::Patron::Discharge::request({ borrowernumber => $patron->{borrowernumber} });
is(scalar( Koha::Patron::Discharge::get_pendings ), 1, 'There is a pending discharge request (second time)');
Koha::Patron::Discharge::discharge( { borrowernumber => $patron->{borrowernumber} } );
is_deeply( [ Koha::Patron::Discharge::get_pendings ], [], 'There is no pending discharge request (second time)');

SKIP: {
    skip "Skipping because weasyprint is not installed",
        5 unless can_run('weasyprint');

    isnt(
        Koha::Patron::Discharge::generate_as_pdf( { borrowernumber => $patron->{borrowernumber} } ),
        undef,
        "Temporary PDF generated."
    );

    my $mocked_ipc = Test::MockModule->new('IPC::Cmd');

    $mocked_ipc->mock( 'run', sub { return 0, 'Some error' } );

    my $result;
    warning_is
        { $result = Koha::Patron::Discharge::generate_as_pdf( { borrowernumber => $patron->{borrowernumber} } ); }
        'Some error',
        'Failed call to run() prints the generated error';

    is( $result, undef, 'undef returned if failed run' );

    $mocked_ipc->mock( 'can_run', undef );

    warning_is
        { $result = Koha::Patron::Discharge::generate_as_pdf( { borrowernumber => $patron->{borrowernumber} } ); }
        'weasyprint not found!',
        'Expected failure because of missing weasyprint';

    is( $result, undef, 'undef returned if missing weasyprint' );
}

# FIXME Should be a Koha::Object object
is( ref(Koha::Patron::Discharge::request({ borrowernumber => $patron->{borrowernumber} })), 'Koha::Schema::Result::Discharge', 'Discharge request sent' );

subtest 'search_limited' => sub {
    plan tests => 4;
    $dbh->do(q|DELETE FROM discharges|);
    my $group_1 = Koha::Library::Group->new( { title => 'TEST Group 1' } )->store;
    my $group_2 = Koha::Library::Group->new( { title => 'TEST Group 2' } )->store;
    # $patron and $patron2 are from the same library, $patron3 from another one
    # Logged in user is $patron, superlibrarian
    t::lib::Mocks::mock_userenv({ patron => $p });
    Koha::Library::Group->new({ parent_id => $group_1->id,  branchcode => $patron->{branchcode} })->store();
    Koha::Library::Group->new({ parent_id => $group_2->id,  branchcode => $patron3->{branchcode} })->store();
    Koha::Patron::Discharge::request({ borrowernumber => $patron->{borrowernumber} });
    Koha::Patron::Discharge::request({ borrowernumber => $patron2->{borrowernumber} });
    Koha::Patron::Discharge::request({ borrowernumber => $patron3->{borrowernumber} });
    is( scalar( Koha::Patron::Discharge::get_pendings), 3, 'With permission, all discharges are visible' );
    is( Koha::Patron::Discharge::count({pending => 1}), 3, 'With permission, all discharges are visible' );

    # With patron 3 logged in, only discharges from their group are visible
    t::lib::Mocks::mock_userenv({ patron => $p3 });
    is( scalar( Koha::Patron::Discharge::get_pendings), 1, 'Without permission, only discharge from our group are visible' );
    is( Koha::Patron::Discharge::count({pending => 1}), 1, 'Without permission, only discharge from our group are visible' );
};

$schema->storage->txn_rollback;
