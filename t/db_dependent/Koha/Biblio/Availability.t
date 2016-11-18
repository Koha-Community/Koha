#!/usr/bin/perl

# Copyright Koha-Suomi Oy 2016
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
use Test::More tests => 14;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Biblios;

use Koha::Exceptions;

use_ok('Koha::Biblio::Availability');

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $biblio = Koha::Biblios->find($builder->build({source => 'Biblio'})->{'biblionumber'});
my $patron = Koha::Patrons->find($builder->build({source => 'Borrower'})->{'borrowernumber'});

subtest 'Check Koha::Biblio::Availability -object default values' => \&check_default_values;

subtest 'Attempt to instantiate holdability class with valid biblio' => sub {
    plan tests => 1;

    my $availability = Koha::Biblio::Availability->new({ biblio => $biblio });
    ok($availability->available, 'When I instantiate class with a valid biblio, then it is available.');
};

subtest 'Attempt to instantiate holdability class with valid biblionumber' => sub {
    plan tests => 1;

    my $availability = Koha::Biblio::Availability->new({ biblionumber => $biblio->biblionumber });
    ok($availability->available, 'When I instantiate class with a valid biblionumber, then it is available.');
};

subtest 'Attempt to instantiate holdability class without specifying an biblio' => sub {
    plan tests => 2;

    my $availability = eval{Koha::Biblio::Availability->new};
    ok($@, 'When I instantiate class without giving an biblio,'
       .' an exception is thrown.');
    is(ref($@), 'Koha::Exceptions::MissingParameter',
       'Then I see that Koha::Exceptions::MissingParameter is thrown.');
};

subtest 'Attempt to instantiate holdability class with notfound biblionumber' => sub {
    plan tests => 2;

    my $availability = eval{Koha::Biblio::Availability->new({ biblionumber => -9001 })};
    ok($@, 'When I instantiate class with valid biblionumber that does not'
       .' refer to any stored biblio, an exception is thrown.');
    is(ref($@), 'Koha::Exceptions::Biblio::NotFound',
       'Then I see that Koha::Exceptions::Biblio::NotFound is thrown.');
};

subtest 'Attempt to instantiate holdability class with invalid biblionumber' => sub {
    plan tests => 2;

    my $availability = eval{Koha::Biblio::Availability->new({ biblionumber => 'lol' })};
    ok($@, 'When I instantiate class with invalid biblionumber that is not'
       .' a number, an exception is thrown.');
    is(ref($@), 'Koha::Exceptions::BadParameter',
       'Then I see that Koha::Exceptions::BadParameter is thrown.');
};

subtest 'Attempt to instantiate holdability class with invalid biblio' => sub {
    plan tests => 2;

    my $availability = eval{Koha::Biblio::Availability->new({ biblio => {'nonsense'=>'yeah'} })};
    ok($@, 'When I instantiate class with invalid biblio,'
       .' an exception is thrown.');
    is(ref($@), 'Koha::Exceptions::BadParameter',
       'Then I see that Koha::Exceptions::BadParameter is thrown.');
};

subtest 'Attempt to instantiate holdability class with valid patron' => sub {
    plan tests => 1;

    my $availability = Koha::Biblio::Availability->new({ biblio => $biblio, patron => $patron });
    ok($availability->available, 'When I instantiate class with a valid patron, then it is available.');
};

subtest 'Attempt to instantiate holdability class with valid borrowernumber' => sub {
    plan tests => 1;

    my $availability = Koha::Biblio::Availability->new({ biblio => $biblio, borrowernumber => $patron->borrowernumber });
    ok($availability->available, 'When I instantiate class with a valid borrowernumber, then it is available.');
};

subtest 'Attempt to instantiate holdability class without specifying a patron' => sub {
    plan tests => 2;

    my $availability = eval{Koha::Biblio::Availability->new({ biblio => $biblio })};
    is($availability->available, 1, 'When I request availability without specifying patron,'
       .' then the biblio is available.');
    is(ref($@), '', 'Then holdability can be checked without giving a patron.');
};

subtest 'Attempt to instantiate holdability class with notfound borrowernumber' => sub {
    plan tests => 2;

    my $availability = eval{Koha::Biblio::Availability->new({ biblio => $biblio, borrowernumber => -9001 })};
    ok($@, 'When I instantiate class with valid borrowernumber that does not'
       .' refer to any stored biblio, an exception is thrown.');
    is(ref($@), 'Koha::Exceptions::Patron::NotFound',
       'Then I see that Koha::Exceptions::Patron::NotFound is thrown.');
};

subtest 'Attempt to instantiate holdability class with invalid borrowernumber' => sub {
    plan tests => 2;

    my $availability = eval{Koha::Biblio::Availability->new({ biblio => $biblio, borrowernumber => 'lol' })};
    ok($@, 'When I instantiate class with invalid borrowernumber that is not'
       .' a number, an exception is thrown.');
    is(ref($@), 'Koha::Exceptions::BadParameter',
       'Then I see that Koha::Exceptions::BadParameter is thrown.');
};

subtest 'Attempt to instantiate holdability class with invalid patron' => sub {
    plan tests => 1;

    my $availability = eval{Koha::Biblio::Availability->new({ biblio => $biblio, patron => $biblio })};
    is(ref($@), 'Koha::Exceptions::BadParameter', 'Patron not found');
};

$schema->storage->txn_rollback;

sub check_default_values {
    plan tests => 7;

    my $availability = Koha::Biblio::Availability->new({ biblio => $biblio});
    is($availability->available, 1, 'Koha::Biblio::Availability -object is available.');
    is(keys %{$availability->unavailabilities}, 0, 'There are no unavailabilities.');
    is(keys %{$availability->confirmations}, 0, 'Nothing needs to be confirmed.');
    is(keys %{$availability->notes}, 0, 'There are no additional notes.');
    is(ref($availability->biblio), 'Koha::Biblio', 'This availability is related to an biblio.');
    is($availability->patron, undef, 'This availability is not related to any patron.');
    is($availability->expected_available, undef, 'There is no expectation of future availability');
}

1;
