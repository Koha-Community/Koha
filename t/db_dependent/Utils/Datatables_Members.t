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

use Test::More tests => 29;

use C4::Context;
use C4::Members;

use C4::Members::Attributes;
use C4::Members::AttributeTypes;

use Koha::Library;
use Koha::Patron::Categories;

use t::lib::Mocks;

use_ok( "C4::Utils::DataTables::Members" );

my $dbh = C4::Context->dbh;

# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

# Pick a categorycode from the DB
my @categories   = Koha::Patron::Categories->search_limited;
my $categorycode = $categories[0]->categorycode;
# Add a new branch so we control what borrowers it has
my $branchcode   = "UNC";
my $branch_data = {
    branchcode     => $branchcode,
    branchname     => 'Universidad Nacional de Cordoba',
    branchaddress1 => 'Haya de la Torre',
    branchaddress2 => 'S/N',
    branchzip      => '5000',
    branchcity     => 'Cordoba',
    branchstate    => 'Cordoba',
    branchcountry  => 'Argentina'
};
Koha::Library->new( $branch_data )->store;

my %john_doe = (
    cardnumber   => '123456',
    firstname    => 'John',
    surname      => 'Doe',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '2010-10-15',
    dateexpiry   => '9999-12-31',
    userid       => 'john.doe'
);

my %john_smith = (
    cardnumber   => '234567',
    firstname    =>  'John',
    surname      => 'Smith',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '2010-01-31',
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

my %jeanpaul_dupont = (
    cardnumber   => '456789',
    firstname    => 'Jean Paul',
    surname      => 'Dupont',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'jeanpaul.dupont'
);

my %dupont_brown = (
    cardnumber   => '567890',
    firstname    => 'Dupont',
    surname      => 'Brown',
    categorycode => $categorycode,
    branchcode   => $branchcode,
    dateofbirth  => '',
    dateexpiry   => '9999-12-31',
    userid       => 'dupont.brown'
);

$john_doe{borrowernumber} = AddMember( %john_doe );
warn "Error adding John Doe, check your tests" unless $john_doe{borrowernumber};
$john_smith{borrowernumber} = AddMember( %john_smith );
warn "Error adding John Smith, check your tests" unless $john_smith{borrowernumber};
$jane_doe{borrowernumber} = AddMember( %jane_doe );
warn "Error adding Jane Doe, check your tests" unless $jane_doe{borrowernumber};
$jeanpaul_dupont{borrowernumber} = AddMember( %jeanpaul_dupont );
warn "Error adding Jean Paul Dupont, check your tests" unless $jeanpaul_dupont{borrowernumber};
$dupont_brown{borrowernumber} = AddMember( %dupont_brown );
warn "Error adding Dupont Brown, check your tests" unless $dupont_brown{borrowernumber};

# Set common datatables params
my %dt_params = (
    iDisplayLength   => 10,
    iDisplayStart    => 0
);

# Search "John Doe"
my $search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "John Doe",
    searchfieldstype => 'standard',
    searchtype       => 'contain',
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
    searchtype       => 'contain',
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
    searchtype       => 'contain',
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
    searchtype       => 'contain',
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

# Search "Smith" as surname - there is only one occurrence of Smith
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Smith",
    searchfieldstype => 'surname',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "There is one Smith at $branchcode when searching for surname");

is( $search_results->{ patrons }[0]->{ cardnumber },
    $john_smith{ cardnumber },
    "John Smith is the first result");

# Search "Dupont" as surname - Dupont is used both as firstname and surname, we
# Should only fin d the user with Dupont as surname
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Dupont",
    searchfieldstype => 'surname',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "There is one Dupont at $branchcode when searching for surname");

is( $search_results->{ patrons }[0]->{ cardnumber },
    $jeanpaul_dupont{ cardnumber },
    "Jean Paul Dupont is the first result");

# Search "Doe" as surname - Doe is used twice as surname
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Doe",
    searchfieldstype => 'surname',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 2,
    "There are two Doe at $branchcode when searching for surname");

is( $search_results->{ patrons }[0]->{ cardnumber },
    $john_doe{ cardnumber },
    "John Doe is the first result");

is( $search_results->{ patrons }[1]->{ cardnumber },
    $jane_doe{ cardnumber },
    "Jane Doe is the second result");

# Search by userid
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "john.doe",
    searchfieldstype => 'standard',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "John Doe is found by userid, standard search (Bug 14782)");

$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "john.doe",
    searchfieldstype => 'userid',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "John Doe is found by userid, userid search (Bug 14782)");

$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "john.doe",
    searchfieldstype => 'surname',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 0,
    "No members are found by userid, surname search");

my $attribute_type = C4::Members::AttributeTypes->new( 'ATM_1', 'my attribute type' );
$attribute_type->{staff_searchable} = 1;
$attribute_type->store;


C4::Members::Attributes::SetBorrowerAttributes(
    $john_doe{borrowernumber}, [ { code => $attribute_type->{code}, value => 'the default value for a common user' } ]
);
C4::Members::Attributes::SetBorrowerAttributes(
    $jane_doe{borrowernumber}, [ { code => $attribute_type->{code}, value => 'the default value for another common user' } ]
);

t::lib::Mocks::mock_preference('ExtendedPatronAttributes', 1);
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "common user",
    searchfieldstype => 'standard',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords}, 2, "There are 2 common users" );

t::lib::Mocks::mock_preference('ExtendedPatronAttributes', 0);
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "common user",
    searchfieldstype => 'standard',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});
is( $search_results->{ iTotalDisplayRecords}, 0, "There are still 2 common users, but the patron attribute is not searchable " );

$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Jean Paul",
    searchfieldstype => 'standard',
    searchtype       => 'start_with',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "Jean Paul Dupont is found using start with and two terms search 'Jean Paul' (Bug 15252)");

$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Jean Pau",
    searchfieldstype => 'standard',
    searchtype       => 'start_with',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "Jean Paul Dupont is found using start with and two terms search 'Jean Pau' (Bug 15252)");

$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Jea Pau",
    searchfieldstype => 'standard',
    searchtype       => 'start_with',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 0,
    "Jean Paul Dupont is not found using start with and two terms search 'Jea Pau' (Bug 15252)");

$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "Jea Pau",
    searchfieldstype => 'standard',
    searchtype       => 'contain',
    branchcode       => $branchcode,
    dt_params        => \%dt_params
});

is( $search_results->{ iTotalDisplayRecords }, 1,
    "Jean Paul Dupont is found using contains and two terms search 'Jea Pau' (Bug 15252)");

# Date of birth formatting
t::lib::Mocks::mock_preference('dateformat', 'metric');
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "15/10/2010",
    searchfieldstype => 'dateofbirth',
    dt_params        => \%dt_params
});
is( $search_results->{ iTotalDisplayRecords }, 1,
    "Sarching by date of birth should handle date formatted given the dateformat pref");
$search_results = C4::Utils::DataTables::Members::search({
    searchmember     => "2010-10-15",
    searchfieldstype => 'dateofbirth',
    dt_params        => \%dt_params
});
is( $search_results->{ iTotalDisplayRecords }, 1,
    "Sarching by date of birth should handle date formatted in iso");

# End
$dbh->rollback;

1;
