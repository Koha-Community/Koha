#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014  Biblibre SARL
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

use C4::Context;
use C4::Bookseller;
use Koha::DateUtils;

use DateTime::Duration;

use Test::More tests => 43;

BEGIN {
    use_ok('C4::Contract');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$dbh->do(q|DELETE FROM aqbasket|);
$dbh->do(q|DELETE FROM aqcontract|);
$dbh->do(q|DELETE FROM aqbooksellers|);


my $bookseller_id1 = C4::Bookseller::AddBookseller( { name => 'My first bookseller' } );
isnt( $bookseller_id1, undef, 'AddBookseller does not return undef' );
my $bookseller_id2 = C4::Bookseller::AddBookseller( { name => 'My second bookseller' } );
isnt( $bookseller_id2, undef, 'AddBookseller does not return undef' );
my $contracts = GetContracts();
is( @$contracts, 0, 'GetContracts returns the correct number of contracts' );
my $contract = GetContract();
is( $contract, undef, 'GetContract without argument returns undef' );


my $my_contract1 = {
    contractstartdate   => '2014-06-01',
    contractenddate     => '2014-06-30',
    contractname        => 'My contract name',
    contractdescription => 'My contract description',
    booksellerid        => $bookseller_id1,
};
my $my_contract_id1 = AddContract();
is( $my_contract_id1, undef, 'AddContract without argument returns undef' );
$my_contract_id1 = AddContract($my_contract1);
isnt( $my_contract_id1, undef, 'AddContract does not return undef' );

$contracts = GetContracts();
is( @$contracts, 1, 'AddContract adds a contract' );

$contract = GetContract();
is( $contract, undef, 'GetContract without argument returns undef' );
$contract = GetContract( { contractnumber => $my_contract_id1 } );
is( $contract->{contractstartdate}, $my_contract1->{contractstartdate}, 'AddContract stores the contract start date correctly.' );
is( $contract->{contractenddate}, $my_contract1->{contractenddate}, 'AddContract stores the contract end date correctly.' );
is( $contract->{contractname}, $my_contract1->{contractname}, 'AddContract stores the contract name correctly.' );
is( $contract->{contractdescription}, $my_contract1->{contractdescription}, 'AddContract stores the contract description correctly.' );
is( $contract->{booksellerid}, $my_contract1->{booksellerid}, 'AddContract stores the bookseller id correctly.' );

my $now = dt_from_string;
my $three_more_days = $now + DateTime::Duration->new( days => 3 );

$my_contract1 = {
    contractstartdate   => $now->ymd,
    contractenddate     => $three_more_days->ymd,
    contractname        => 'My modified contract name',
    contractdescription => 'My modified contract description',
    booksellerid        => $bookseller_id2,
};
my $mod_status = ModContract($my_contract1);
is( $mod_status, undef, 'ModContract without the contract number returns 0E0' );

$my_contract1->{contractnumber} = $my_contract_id1;
$mod_status = ModContract($my_contract1);
is( $mod_status, 1, 'ModContract returns true' );
$contracts = GetContracts();
is( @$contracts, 1, 'ModContract does not modify the number of contracts' );
$contract = GetContract( { contractnumber => $my_contract_id1 } );
is( $contract->{contractstartdate}, $my_contract1->{contractstartdate}, 'ModContract updates the contract start date correctly.' );
is( $contract->{contractenddate}, $my_contract1->{contractenddate}, 'ModContract updates the contract end date correctly.' );
is( $contract->{contractname}, $my_contract1->{contractname}, 'ModContract updates the contract name correctly.' );
is( $contract->{contractdescription}, $my_contract1->{contractdescription}, 'ModContract updates the contract description correctly.' );
is( $contract->{booksellerid}, $my_contract1->{booksellerid}, 'ModContract updates the bookseller id correctly.' );


my $my_contract2 = {
    contractstartdate   => '2013-08-05',
    contractenddate     => '2013-09-25',
    contractname        => 'My other contract name',
    contractdescription => 'My other description contract name',
    booksellerid        => $bookseller_id1,
};
my $my_contract_id2 = AddContract($my_contract2);
$contracts = GetContracts( { booksellerid => $bookseller_id1 } );
is( @$contracts, 1, 'GetContracts returns the correct number of contracts' );
$contracts = GetContracts({
    activeonly => 1
});
is( @$contracts, 1, 'GetContracts with active only returns only current contracts' );
$contracts = GetContracts( { booksellerid => $bookseller_id2 } );
is( @$contracts, 1, 'GetContracts returns the correct number of contracts' );
$contracts = GetContracts();
is( @$contracts, 2, 'GetContracts returns the correct number of contracts' );

is( $contracts->[0]->{contractnumber}, $my_contract_id1, 'GetContracts returns the contract number correctly' );
is( $contracts->[0]->{contractstartdate}, $my_contract1->{contractstartdate}, 'GetContracts returns the contract start date correctly.' );
is( $contracts->[0]->{contractenddate}, $my_contract1->{contractenddate}, 'GetContracts returns the contract end date correctly.' );
is( $contracts->[0]->{contractname}, $my_contract1->{contractname}, 'GetContracts returns the contract name correctly.' );
is( $contracts->[0]->{contractdescription}, $my_contract1->{contractdescription}, 'GetContracts returns the contract description correctly.' );
is( $contracts->[0]->{booksellerid}, $my_contract1->{booksellerid}, 'GetContracts returns the bookseller id correctly.' );

is( $contracts->[1]->{contractnumber}, $my_contract_id2, 'GetContracts returns the contract number correctly' );
is( $contracts->[1]->{contractstartdate}, $my_contract2->{contractstartdate}, 'GetContracts returns the contract start date correctly.' );
is( $contracts->[1]->{contractenddate}, $my_contract2->{contractenddate}, 'GetContracts returns the contract end date correctly.' );
is( $contracts->[1]->{contractname}, $my_contract2->{contractname}, 'GetContracts returns the contract name correctly.' );
is( $contracts->[1]->{contractdescription}, $my_contract2->{contractdescription}, 'GetContracts returns the contract description correctly.' );
is( $contracts->[1]->{booksellerid}, $my_contract2->{booksellerid}, 'GetContracts returns the bookseller id correctly.' );


my $del_status = DelContract();
is( $del_status, undef, 'DelContract without contract number returns undef' );

$del_status = DelContract( { contractnumber => $my_contract_id1  } );
is( $del_status, 1, 'DelContract returns true' );
$contracts = GetContracts();
is( @$contracts, 1, 'DelContract deletes a contract' );

$del_status = DelContract( { contractnumber => $my_contract_id2 } );
is( $del_status, 1, 'DelContract returns true' );
$contracts = GetContracts();
is( @$contracts, 0, 'DelContract deletes a contract' );

$dbh->rollback;
