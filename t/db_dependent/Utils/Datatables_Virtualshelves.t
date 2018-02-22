#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 13;

use C4::Biblio;
use C4::Context;

use Koha::Library;
use Koha::Patrons;
use Koha::Patron::Categories;
use Koha::Virtualshelves;

use_ok( "C4::Utils::DataTables::VirtualShelves" );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM virtualshelves|);

# Pick a categorycode from the DB
my @categories   = Koha::Patron::Categories->search_limited;
my $categorycode = $categories[0]->categorycode;
my $branchcode   = "ABC";
my $branch_data = {
    branchcode     => $branchcode,
    branchname     => 'my branchname',
};
Koha::Library->new( $branch_data )->store;

my %john_doe = (
    cardnumber   => '123456',
    firstname    => 'John',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.doe',
);

my %jane_doe = (
    cardnumber   => '234567',
    firstname    =>  'Jane',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'jane.doe',
);
my %john_smith = (
    cardnumber   => '345678',
    firstname    =>  'John',
    surname      => 'Smith',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.smith',
);

$john_doe{borrowernumber} = Koha::Patron->new( \%john_doe )->store->borrowernumber;
$jane_doe{borrowernumber} = Koha::Patron->new( \%jane_doe )->store->borrowernumber;
$john_smith{borrowernumber} = Koha::Patron->new( \%john_smith )->store->borrowernumber;

my $shelf1 = Koha::Virtualshelf->new(
    {
        shelfname => 'my first private list (empty)',
        category  => 1, # private
        sortfield => 'author',
        owner     => $john_doe{borrowernumber},
    }
)->store;

my $shelf2 = Koha::Virtualshelf->new(
    {
        shelfname => 'my second private list',
        category  => 1, # private
        sortfield => 'title',
        owner     => $john_doe{borrowernumber},
    }
)->store;
my $biblionumber1 = _add_biblio('title 1');
my $biblionumber2 = _add_biblio('title 2');
my $biblionumber3 = _add_biblio('title 3');
my $biblionumber4 = _add_biblio('title 4');
my $biblionumber5 = _add_biblio('title 5');
$shelf2->add_biblio( $biblionumber1, $john_doe{borrowernumber} );
$shelf2->add_biblio( $biblionumber2, $john_doe{borrowernumber} );
$shelf2->add_biblio( $biblionumber3, $john_doe{borrowernumber} );
$shelf2->add_biblio( $biblionumber4, $john_doe{borrowernumber} );
$shelf2->add_biblio( $biblionumber5, $john_doe{borrowernumber} );

my $shelf3 = Koha::Virtualshelf->new(
    {
        shelfname => 'The first public list',
        category  => 2, # public
        sortfield => 'author',
        owner     => $jane_doe{borrowernumber},
    }
)->store;
my $biblionumber6 = _add_biblio('title 6');
my $biblionumber7 = _add_biblio('title 7');
my $biblionumber8 = _add_biblio('title 8');
$shelf3->add_biblio( $biblionumber6, $jane_doe{borrowernumber} );
$shelf3->add_biblio( $biblionumber7, $jane_doe{borrowernumber} );
$shelf3->add_biblio( $biblionumber8, $jane_doe{borrowernumber} );

my $shelf4 = Koha::Virtualshelf->new(
    {
        shelfname => 'my second public list',
        category  => 2, # public
        sortfield => 'title',
        owner     => $jane_doe{borrowernumber},
    }
)->store;
my $biblionumber9  = _add_biblio('title 9');
my $biblionumber10 = _add_biblio('title 10');
my $biblionumber11 = _add_biblio('title 11');
my $biblionumber12 = _add_biblio('title 12');
$shelf3->add_biblio( $biblionumber9, $jane_doe{borrowernumber} );
$shelf3->add_biblio( $biblionumber10, $jane_doe{borrowernumber} );
$shelf3->add_biblio( $biblionumber11, $jane_doe{borrowernumber} );
$shelf3->add_biblio( $biblionumber12, $jane_doe{borrowernumber} );

my $shelf5 = Koha::Virtualshelf->new(
    {
        shelfname => 'my third private list',
        category  => 1, # private
        sortfield => 'title',
        owner     => $jane_doe{borrowernumber},
    }
)->store;
my $biblionumber13 = _add_biblio('title 13');
my $biblionumber14 = _add_biblio('title 14');
my $biblionumber15 = _add_biblio('title 15');
my $biblionumber16 = _add_biblio('title 16');
my $biblionumber17 = _add_biblio('title 17');
my $biblionumber18 = _add_biblio('title 18');
$shelf5->add_biblio( $biblionumber13, $jane_doe{borrowernumber} );
$shelf5->add_biblio( $biblionumber14, $jane_doe{borrowernumber} );
$shelf5->add_biblio( $biblionumber15, $jane_doe{borrowernumber} );
$shelf5->add_biblio( $biblionumber16, $jane_doe{borrowernumber} );
$shelf5->add_biblio( $biblionumber17, $jane_doe{borrowernumber} );
$shelf5->add_biblio( $biblionumber18, $jane_doe{borrowernumber} );

for my $i ( 6 .. 15 ) {
    Koha::Virtualshelf->new(
        {
            shelfname => "another public list $i",
            category  => 2,
            owner     => $john_smith{borrowernumber},
        }
    )->store;
}

# Set common datatables params
my %dt_params = (
    iDisplayLength   => 10,
    iDisplayStart    => 0
);
my $search_results;

C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv($john_doe{borrowernumber}, $john_doe{userid}, 'usercnum', 'First name', 'Surname', 'MYLIBRARY', 'My Library', 0);

# Search private lists by title
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    shelfname => "ist",
    dt_params => \%dt_params,
    type => 1,
});

is( $search_results->{ iTotalRecords }, 2,
    "There should be 2 private shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 2,
    "There should be 2 private shelves with title like '%ist%" );

is( @{ $search_results->{ shelves } }, 2,
    "There should be 2 private shelves returned" );

# Search by type only
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    dt_params => \%dt_params,
    type => 2,
});
is( $search_results->{ iTotalRecords }, 12,
    "There should be 12 public shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 12,
    "There should be 12 private shelves" );

is( @{ $search_results->{ shelves } }, 10,
    "There should be 10 public shelves returned" );

# Search by owner
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    owner => "jane",
    dt_params => \%dt_params,
    type => 2,
});
is( $search_results->{ iTotalRecords }, 12,
    "There should be 12 public shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 2,
    "There should be 1 public shelves for jane" );

is( @{ $search_results->{ shelves } }, 2,
    "There should be 1 public shelf returned" );

# Search by owner and shelf name
$search_results = C4::Utils::DataTables::VirtualShelves::search({
    owner => "smith",
    shelfname => "public list 1",
    dt_params => \%dt_params,
    type => 2,
});
is( $search_results->{ iTotalRecords }, 12,
    "There should be 12 public shelves in total" );

is( $search_results->{ iTotalDisplayRecords }, 6,
    "There should be 6 public shelves for john with name like %public list 1%" );

is( @{ $search_results->{ shelves } }, 6,
    "There should be 6 public chalves returned" );

sub _add_biblio {
    my ( $title ) = @_;
    my $biblio = MARC::Record->new();
    $biblio->append_fields(
        MARC::Field->new('245', ' ', ' ', a => $title),
    );
    my ($biblionumber, $biblioitemnumber) = AddBiblio($biblio, '');
    return $biblionumber;
}

