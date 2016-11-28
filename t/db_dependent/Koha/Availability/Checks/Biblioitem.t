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
use Test::More tests => 2;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use Koha::Biblioitems;
use Koha::Database;
use Koha::DateUtils;
use Koha::Items;

use Koha::Availability::Checks::Biblioitem;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'age_restricted, given patron is old enough' => \&t_old_enough;
sub t_old_enough {
    plan tests => 3;

    my $item = build_a_test_item();
    my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
    $biblioitem->set({ agerestriction => 'PEGI 18' })->store;
    my $patron = build_a_test_patron();
    my $bibitemcalc = Koha::Availability::Checks::Biblioitem->new($biblioitem);

    is($patron->dateofbirth, '1950-10-10', 'Patron says he is born in the 1950s.');
    is($biblioitem->agerestriction, 'PEGI 18', 'Item is restricted for under 18.');
    ok(!$bibitemcalc->age_restricted($patron), 'When I check for age restriction, then no exception is given.');
};

subtest 'age_restricted, given patron is too young' => \&t_too_young;
sub t_too_young {
    plan tests => 4;

    my $item = build_a_test_item();
    my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
    $biblioitem->set({ agerestriction => 'PEGI 18' })->store;
    my $patron = build_a_test_patron();
    my $now = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });
    $patron->set({ dateofbirth => $now })->store;
    my $bibitemcalc = Koha::Availability::Checks::Biblioitem->new($biblioitem);
    my $expecting = 'Koha::Exceptions::Patron::AgeRestricted';

    is($patron->dateofbirth, $now, 'Patron says he is born today.');
    my $reason = $bibitemcalc->age_restricted($patron);
    is($biblioitem->agerestriction, 'PEGI 18', 'Biblio item is restricted for under 18.');
    is(ref($reason), $expecting,
       "When I check for age restriction, then exception $expecting is given.");
    is($reason->age_restriction, 'PEGI 18', 'The reason also specifies the'
       .' age restriction, PEGI 18.');
};

$schema->storage->txn_rollback;

1;
