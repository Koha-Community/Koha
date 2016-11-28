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
use Test::More tests => 3;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use C4::Members;

use Koha::Biblios;
use Koha::Database;
use Koha::Items;

use Koha::Availability::Checks::Biblio;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'checked_out' => \&t_checked_out;
sub t_checked_out {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $item2 = build_a_test_item();
    $item2->set({
        biblionumber => $item->biblionumber,
        biblioitemnumber => $item->biblioitemnumber,
    })->store;
    issue_item($item, $patron);
    my $bibcalc = Koha::Availability::Checks::Biblio->new($biblio);
    my $expecting = 'Koha::Exceptions::Biblio::CheckedOut';

    is(Koha::Checkouts->search({ itemnumber => $item->itemnumber })->count, 1,
       'I found out that item is checked out.');
    is(ref($bibcalc->checked_out($patron)), $expecting, $expecting);
};

subtest 'forbid_holds_on_patrons_possessions' => \&t_forbid_holds_on_patrons_possessions;
sub t_forbid_holds_on_patrons_possessions {
    plan tests => 5;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $item2 = build_a_test_item();
    $item2->set({
        biblionumber => $item->biblionumber,
        biblioitemnumber => $item->biblioitemnumber,
    })->store;
    issue_item($item, $patron);
    my $bibcalc = Koha::Availability::Checks::Biblio->new($biblio);
    my $expecting = 'Koha::Exceptions::Biblio::CheckedOut';

    t::lib::Mocks::mock_preference('AllowHoldsOnPatronsPossessions', 0);
    is(C4::Context->preference('AllowHoldsOnPatronsPossessions'), 0,
       'System preference AllowHoldsOnPatronsPossessions is disabled.');
    is(Koha::Checkouts->search({ itemnumber => $item->itemnumber })->count, 1,
       'I found out that item is checked out.');
    is(ref($bibcalc->forbid_holds_on_patrons_possessions($patron)), $expecting,
       $expecting);
    t::lib::Mocks::mock_preference('AllowHoldsOnPatronsPossessions', 1);
    is(C4::Context->preference('AllowHoldsOnPatronsPossessions'), 1,
       'Given system preference AllowHoldsOnPatronsPossessions is enabled,');
    ok(!$bibcalc->forbid_holds_on_patrons_possessions($patron), 'When I check'
       .' biblio forbid holds on patrons possesions, no exception is given.');
};

subtest 'forbid_multiple_issues' => \&t_forbid_multiple_issues;
sub t_forbid_multiple_issues {
    plan tests => 4;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $item2 = build_a_test_item();
    $item2->set({
        biblionumber => $item->biblionumber,
        biblioitemnumber => $item->biblioitemnumber,
    })->store;
    issue_item($item2, $patron);
    my $checkoutcalc = Koha::Availability::Checks::Biblio->new($biblio);

    is($item->biblionumber, $item2->biblionumber, 'Item one and item two belong'
        .' to the same biblio.');
    is(Koha::Checkouts->find({ itemnumber => $item2->itemnumber})->borrowernumber,
       $patron->borrowernumber, 'Item two seems to be issued to me.');

    subtest 'Given AllowMultipleIssuesOnABiblio is enabled' => sub {
        plan tests => 2;

        t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 1);
        is(C4::Context->preference('AllowMultipleIssuesOnABiblio'), 1,
           'System preference AllowMultipleIssuesOnABiblio is enabled.');
        is($checkoutcalc->forbid_multiple_issues($patron), undef,
           'When I ask if there is another biblio already checked out,'
           .' then no exception is returned.');
    };

    subtest 'Given AllowMultipleIssuesOnABiblio is disabled' => sub {
        plan tests => 3;

        my $expecting = 'Koha::Exceptions::Biblio::CheckedOut';
        my $returned;

        t::lib::Mocks::mock_preference('AllowMultipleIssuesOnABiblio', 0);
        is(C4::Context->preference('AllowMultipleIssuesOnABiblio'), 0,
           'System preference AllowMultipleIssuesOnABiblio is disabled.');
        ok($returned = ref($checkoutcalc->forbid_multiple_issues($patron)),
           'When I ask if there is another biblio already checked out,');
        is ($returned, $expecting, "then exception $expecting is returned.");
    };
};

$schema->storage->txn_rollback;

1;
