#!/usr/bin/perl

# Copyright 2023 Koha Development team
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

use Test::More tests => 1;

use Koha::Illrequests;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'patron() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $request =
        $builder->build_object( { class => 'Koha::Illrequests', value => { borrowernumber => $patron->id } } );

    my $req_patron = $request->patron;
    is( ref($req_patron), 'Koha::Patron' );
    is( $req_patron->id,  $patron->id );

    $request = $builder->build_object( { class => 'Koha::Illrequests', value => { borrowernumber => undef } } );

    is( $request->patron, undef );

    $schema->storage->txn_rollback;
};
