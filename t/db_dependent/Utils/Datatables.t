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

use Test::More tests => 1;

use C4::Utils::DataTables;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'dt_build_orderby' => sub {
    plan tests => 2;

    my $dt_params = {
        iSortCol_0  => 5,
        sSortDir_0  => "asc",
        mDataProp_5 => "branch",
        name_sorton => "borrowers.surname borrowers.firstname",

        iSortCol_1    => 2,
        sSortDir_1    => "desc",
        mDataProp_2   => "name",
        branch_sorton => "branches.branchname",
    };

    my $orderby = dt_build_orderby($dt_params);
    is( $orderby, " ORDER BY branches.branchname asc,borrowers.surname desc,borrowers.firstname desc ", 'ORDER BY has been correctly built' );

    $dt_params = {
        %$dt_params,
        iSortCol_2                    => 3,
        sSortDir_2                    => "asc",
        mDataProp_3                   => "branch,somethingelse",
    };

    $orderby = dt_build_orderby($dt_params);
    is( $orderby, " ORDER BY branches.branchname asc,borrowers.surname desc,borrowers.firstname desc ", 'ORDER BY has been correctly built, even with invalid stuff');
};
