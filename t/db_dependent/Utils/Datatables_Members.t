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

use Test::More tests => 11;

use C4::Context;
use C4::Branch;
use C4::Members;

use_ok( "C4::Utils::DataTables::Members" );

my $dbh = C4::Context->dbh;
my $res;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Pick a categorycode from the DB
my @categories   = C4::Category->all;
my $categorycode = $categories[0]->categorycode;
# Add a new branch so we control what borrowers it has
my $branchcode   = "UNC";
my $branch_data = {
    add            => 1,
    branchcode     => $branchcode,
    branchname     => 'Universidad Nacional de Cordoba',
    branchaddress1 => 'Haya de la Torre',
    branchaddress2 => 'S/N',
    branchzip      => '5000',
    branchcity     => 'Cordoba',
    branchstate    => 'Cordoba',
    branchcountry  => 'Argentina'
};
ModBranch( $branch_data );

my %john_doe = (
    cardnumber   => '123456',
    firstname    => 'John',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.doe'
);

my %john_smith = (
    cardnumber   => '234567',
    firstname    =>  'John',
    surname      => 'Smith',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'john.smith'
);

my %jane_doe = (
    cardnumber   => '345678',
    firstname    =>  'Jane',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'jane.doe'
);

$res = AddMember( %john_doe );
warn "Error adding John Doe, check your tests" unless $res;
$res = AddMember( %john_smith );
warn "Error adding John Smith, check your tests" unless $res;
$res = AddMember( %jane_doe );
warn "Error adding Jane Doe, check your tests" unless $res;

# Set common datatables params
my %dt_params = (
    iDisplayLength   => 10,
    iDisplayStart    => 0
);

# Search "John Doe"
my $search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "John Doe",
    searchfieldstype => 'standard',
    searchtype       => 'contains',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "John Doe has only one match on $branchcode (Bug 12595)");

ok( $search_results->{ patrons }[0]->{ cardnumber } eq $john_doe{ cardnumber }
    && ! $search_results->{ patrons }[1],
    "John Doe is the only match (Bug 12595)");

# Search "Jane Doe"
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Jane Doe",
    searchfieldstype => 'standard',
    searchtype       => 'contains',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "Jane Doe has only one match on $branchcode (Bug 12595)");

is( $search_results->{ patrons }[0]->{ cardnumber },
    $jane_doe{ cardnumber },
    "Jane Doe is the only match (Bug 12595)");

# Search "John"
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "John",
    searchfieldstype => 'standard',
    searchtype       => 'contains',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 2,
    "There are two John at $branchcode");

is( $search_results->{ patrons }[0]->{ cardnumber },
    $john_doe{ cardnumber },
    "John Doe is the first result");

is( $search_results->{ patrons }[1]->{ cardnumber },
    $john_smith{ cardnumber },
    "John Smith is the second result");

# Search "Doe"
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Doe",
    searchfieldstype => 'standard',
    searchtype       => 'contains',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 2,
    "There are two Doe at $branchcode");

is( $search_results->{ patrons }[0]->{ cardnumber },
    $john_doe{ cardnumber },
    "John Doe is the first result");

is( $search_results->{ patrons }[1]->{ cardnumber },
    $jane_doe{ cardnumber },
    "Jane Doe is the second result");

$dbh->rollback;

1;
