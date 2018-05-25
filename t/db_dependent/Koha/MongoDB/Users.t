#!/usr/bin/perl

# Copyright 2018 Koha-Suomi Oy
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

use Test::More tests => 2;

use t::lib::TestBuilder;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

use_ok('Koha::MongoDB::Users');

subtest 'test getUser()' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $users = new Koha::MongoDB::Users;

    my $patron = $builder->build({
        source => 'Borrower',
    });
    my $deleted_patron = $builder->build({
        source => 'Deletedborrower',
    });

    my $user = $users->getUser($patron->{borrowernumber});
    is($user->{borrowernumber}, $patron->{borrowernumber}, 'Got user');

    $user = $users->getUser($deleted_patron->{borrowernumber});
    is($user->{borrowernumber}, $deleted_patron->{borrowernumber},
       'Got deleted user');

    $user = $users->getUser(-999991);
    is($user->{borrowernumber}, 0, 'Got nonexistent user');
    like($user->{branchcode}, qr/.+/, 'Nonexistent user has some branchcode');
    like($user->{categorycode}, qr/.+/, 'Nonexistent user has some catcode');

    $schema->storage->txn_rollback;
};

1;
