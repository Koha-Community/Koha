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
use Test::More tests => 4;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use C4::Members;

use Koha::Biblios;
use Koha::Database;
use Koha::Items;

use Koha::Availability::Checks::Checkout;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'invalid_due_date, invalid due date' => \&t_invalid_due_date;
sub t_invalid_due_date {
    plan tests => 1;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();

    my $duedate = 'invalid';
    my $checkoutcalc = Koha::Availability::Checks::Checkout->new;
    my $expecting = 'Koha::Exceptions::Checkout::InvalidDueDate';
    is(ref($checkoutcalc->invalid_due_date($item, $patron, $duedate)), $expecting,
       "When using duedate 'invalid', then exception $expecting is given.");
};

subtest 'invalid_due_date, due date before now' => \&t_invalid_due_date_before_now;
sub t_invalid_due_date_before_now {
    plan tests => 1;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();

    my $before = output_pref({ dt => dt_from_string()->subtract_duration(
                          DateTime::Duration->new(days => 100)), dateformat => 'iso', dateonly => 1 });
    my $checkoutcalc = Koha::Availability::Checks::Checkout->new;
    my $expecting = 'Koha::Exceptions::Checkout::DueDateBeforeNow';
    is(ref($checkoutcalc->invalid_due_date($item, $patron, $before)), $expecting,
       "When using duedate that is in the past, then exception $expecting is given.");
};

subtest 'invalid_due_date, good due date' => \&t_invalid_due_date_not_invalid;
sub t_invalid_due_date_not_invalid {
    plan tests => 1;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();

    my $before = output_pref({ dt => dt_from_string()->add_duration(
                          DateTime::Duration->new(days => 14)), dateformat => 'iso', dateonly => 1 });
    my $checkoutcalc = Koha::Availability::Checks::Checkout->new;
    is($checkoutcalc->invalid_due_date($item, $patron, $before), undef,
       'When using a duedate that is in two weeks from now, then no exception is given.');
};

subtest 'no_more_renewals' => \&t_no_more_renewals;
sub t_no_more_renewals {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $item = build_a_test_item();

    issue_item($item, $patron);
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => '*',
        categorycode => '*',
        renewalsallowed => 0,
    })->store;
    my $checkoutcalc = Koha::Availability::Checks::Checkout->new;
    my $expecting = 'Koha::Exceptions::Checkout::NoMoreRenewals';
    my $issue = Koha::Checkouts->find({ itemnumber => $item->itemnumber});
    is($issue->borrowernumber, $patron->borrowernumber, 'Item seems to be issued to me.');
    is(ref($checkoutcalc->no_more_renewals($issue)), $expecting,
       "When checking for no more renewals, then exception $expecting is given.");
};

$schema->storage->txn_rollback;

1;
