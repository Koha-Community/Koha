#!/usr/bin/perl

# Copyright 2015 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 7;
use Test::Warn;

use Koha::Authority::Types;
use Koha::Cities;
use Koha::Patrons;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

is( ref(Koha::Authority::Types->find('')), 'Koha::Authority::Type', 'Koha::Objects->find should work if the primary key is an empty string' );

my @columns = Koha::Patrons->columns;
my $borrowernumber_exists = grep { /^borrowernumber$/ } @columns;
is( $borrowernumber_exists, 1, 'Koha::Objects->columns should return the table columns' );

subtest 'update' => sub {
    plan tests => 2;
    my $builder = t::lib::TestBuilder->new;
    $builder->build( { source => 'City', value => { city_country => 'UK' } } );
    $builder->build( { source => 'City', value => { city_country => 'UK' } } );
    $builder->build( { source => 'City', value => { city_country => 'UK' } } );
    $builder->build( { source => 'City', value => { city_country => 'France' } } );
    $builder->build( { source => 'City', value => { city_country => 'France' } } );
    $builder->build( { source => 'City', value => { city_country => 'Germany' } } );
    Koha::Cities->search( { city_country => 'UK' } )->update( { city_country => 'EU' } );
    is( Koha::Cities->search( { city_country => 'EU' } )->count, 3, 'Koha::Objects->update should have updated the 3 rows' );
    is( Koha::Cities->search( { city_country => 'UK' } )->count, 0, 'Koha::Objects->update should have updated the 3 rows' );
};

subtest 'pager' => sub {
    plan tests => 1;
    my $pager = Koha::Patrons->search( {}, { page => 1, rows => 2 } )->pager;
    is( ref($pager), 'DBIx::Class::ResultSet::Pager', 'Koha::Objects->pager returns a valid DBIx::Class object' );
};

subtest 'reset' => sub {
    plan tests => 1;
    my $builder   = t::lib::TestBuilder->new;
    my $patrons = Koha::Patrons->search;
    my $first_borrowernumber = $patrons->next->borrowernumber;
    my $second_borrowernumber = $patrons->next->borrowernumber;
    is( $patrons->reset->next->borrowernumber, $first_borrowernumber, 'Koha::Objects->reset should work as expected');
};

subtest 'delete' => sub {
    plan tests => 2;
    my $builder   = t::lib::TestBuilder->new;
    my $patron_1 = $builder->build({source => 'Borrower'});
    my $patron_2 = $builder->build({source => 'Borrower'});
    is( Koha::Patrons->search({ -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber}]}})->delete, 2, '');
    is( Koha::Patrons->search({ -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber}]}})->count, 0, '');
};

subtest 'not_covered_yet' => sub {
    plan tests => 1;
    warning_is { Koha::Patrons->search->not_covered_yet } { carped => 'The method not_covered_yet is not covered by tests' }, "If a method is not covered by tests, the AUTOLOAD method won't execute the method";
};

$schema->storage->txn_rollback;
1;
