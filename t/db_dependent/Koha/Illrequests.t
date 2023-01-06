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
use t::lib::Mocks;

my $builder = t::lib::TestBuilder->new;
my $schema = Koha::Database->new->schema;

subtest 'filter_by_visible() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $req = $builder->build_object({ class => 'Koha::Illrequests', value => { status => 'REQ', biblio_id => undef } });
    my $chk = $builder->build_object({ class => 'Koha::Illrequests', value => { status => 'CHK', biblio_id => undef } });
    my $ret = $builder->build_object({ class => 'Koha::Illrequests', value => { status => 'RET', biblio_id => undef } });

    my $reqs_rs = Koha::Illrequests->search(
        {
            illrequest_id => [ $req->id, $chk->id, $ret->id ]
        }
    );

    is( $reqs_rs->count, 3, 'Count is correct' );

    t::lib::Mocks::mock_preference('ILLHiddenRequestStatuses', '');

    is( $reqs_rs->filter_by_visible->count, 3, 'No hidden statuses, same count' );

    t::lib::Mocks::mock_preference('ILLHiddenRequestStatuses', 'CHK|RET');

    my $filtered_reqs = $reqs_rs->filter_by_visible;

    is( $filtered_reqs->count, 1, 'Count is correct' );
    is( $filtered_reqs->next->status, 'REQ' );

    $schema->storage->txn_rollback;
};
