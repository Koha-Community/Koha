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
use Test::More tests => 20;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use C4::Members;

use Koha::Account::Lines;
use Koha::Biblioitems;
use Koha::Database;
use Koha::DateUtils;
use Koha::Items;

use Koha::Availability::Checks::Patron;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $builder = t::lib::TestBuilder->new;

set_default_system_preferences();
set_default_circulation_rules();

subtest 'debarred, given patron is not debarred' => \&t_not_debarred;
sub t_not_debarred {
    plan tests => 3;

    my $patron = build_a_test_patron();
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $expecting = 'Koha::Exceptions::Patron::Debarred';

    is($patron->debarred, undef, 'Patron is not debarred.');
    is($patron->debarredcomment, undef, 'Patron does not have debarment comment.');
    ok(!$patroncalc->debarred, 'When I check patron debarment, then no exception is given.');
};

subtest 'debarred, given patron is debarred' => \&t_debarred;
sub t_debarred {
    plan tests => 5;

    my $patron = build_a_test_patron();
    my $hundred_days = output_pref({ dt => dt_from_string()->add_duration(
                          DateTime::Duration->new(days => 100)), dateformat => 'iso', dateonly => 1 });
    $patron->set({ debarred => $hundred_days, debarredcomment => 'DONT EVER COME BACK' })->store;
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $expecting = 'Koha::Exceptions::Patron::Debarred';
    my $debarred = $patroncalc->debarred;

    is($patron->debarred, $hundred_days, "Patron is debarred until $hundred_days.");
    is($patron->debarredcomment, 'DONT EVER COME BACK', 'Library does not want them to ever come back.');
    is(ref($debarred), $expecting, "When I check patron debarment, then $expecting is given.");
    is($debarred->expiration, $patron->debarred, 'Then, from the status, I can see the expiration date.');
    is($debarred->comment, $patron->debarredcomment, 'Then, from the status, I can see that patron should never come back.');
};

subtest 'debt_checkout, given patron has less than noissuescharge' => \&t_fines_checkout_less_than_max;
sub t_fines_checkout_less_than_max {
    plan tests => 8;

    t::lib::Mocks::mock_preference('noissuescharge', 9001);
    t::lib::Mocks::mock_preference('AllFinesNeedOverride', 0);

    my $patron = build_a_test_patron();
    my $line = Koha::Account::Line->new({
        borrowernumber => $patron->borrowernumber,
        amountoutstanding => 9000,
    })->store;
    my ($outstanding) = C4::Members::GetMemberAccountRecords($patron->borrowernumber);
    my $maxoutstanding = C4::Context->preference('noissuescharge');
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_checkout;

    is(C4::Context->preference('AllFinesNeedOverride'), 0, 'Not all fines need override.');
    ok($maxoutstanding, 'When I look at system preferences, I see that maximum allowed outstanding fines is set.');
    ok($maxoutstanding > $outstanding, 'When I check patron\'s balance, I found out they have less outstanding fines than maximum allowed.');
    ok(!$debt, 'When I check patron debt, then no exception is given.');
    t::lib::Mocks::mock_preference('AllFinesNeedOverride', 1);
    is(C4::Context->preference('AllFinesNeedOverride'), 1, 'Given we configure'
       .' all fines needing override.');
    $debt = $patroncalc->debt_checkout;
    my $expecting = 'Koha::Exceptions::Patron::Debt';
    is(ref($debt), $expecting, "When I check patron debt, then $expecting is given.");
    is($debt->max_outstanding, $maxoutstanding, 'Then I can see the status showing me how much'
       .' outstanding total can be at maximum.');
    is($debt->current_outstanding, $outstanding, 'Then I can see the status showing me how much'
       .' outstanding fines patron has right now.');
};

subtest 'debt_checkout, given patron has more than noissuescharge' => \&t_fines_checkout_more_than_max;
sub t_fines_checkout_more_than_max {
    plan tests => 5;

    t::lib::Mocks::mock_preference('noissuescharge', 5);

    my $patron = build_a_test_patron();
    my $line = Koha::Account::Line->new({
        borrowernumber => $patron->borrowernumber,
        amountoutstanding => 9001,
    })->store;
    my ($outstanding) = C4::Members::GetMemberAccountRecords($patron->borrowernumber);
    my $maxoutstanding = C4::Context->preference('noissuescharge');
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_checkout;
    my $expecting = 'Koha::Exceptions::Patron::Debt';

    ok($maxoutstanding, 'When I look at system preferences, I see that maximum allowed outstanding fines is set.');
    ok($maxoutstanding < $outstanding, 'When I check patron\'s balance, I found out they have more outstanding fines than allowed.');
    is(ref($debt), $expecting, "When I check patron debt, then $expecting is given.");
    is($debt->max_outstanding, $maxoutstanding, 'Then I can see the status showing me how much'
       .' outstanding total can be at maximum.');
    is($debt->current_outstanding, $outstanding, 'Then I can see the status showing me how much'
       .' outstanding fines patron has right now.');
};

subtest 'debt_hold, given patron has less than maxoutstanding' => \&t_fines_hold_less_than_max;
sub t_fines_hold_less_than_max {
    plan tests => 3;

    t::lib::Mocks::mock_preference('maxoutstanding', 9001);

    my $patron = build_a_test_patron();
    my $line = Koha::Account::Line->new({
        borrowernumber => $patron->borrowernumber,
        amountoutstanding => 9000,
    })->store;
    my ($outstanding) = C4::Members::GetMemberAccountRecords($patron->borrowernumber);
    my $maxoutstanding = C4::Context->preference('maxoutstanding');
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_hold;

    ok($maxoutstanding, 'When I look at system preferences, I see that maximum allowed outstanding fines is set.');
    ok($maxoutstanding > $outstanding, 'When I check patron\'s balance, I found out they have less outstanding fines than maximum allowed.');
    ok(!$debt, 'When I check patron debt, then no exception is given.');
};

subtest 'debt_hold, given patron has more than maxoutstanding' => \&t_fines_hold_more_than_max;
sub t_fines_hold_more_than_max {
    plan tests => 5;

    t::lib::Mocks::mock_preference('maxoutstanding', 5);

    my $patron = build_a_test_patron();
    my $line = Koha::Account::Line->new({
        borrowernumber => $patron->borrowernumber,
        amountoutstanding => 9001,
    })->store;
    my ($outstanding) = C4::Members::GetMemberAccountRecords($patron->borrowernumber);
    my $maxoutstanding = C4::Context->preference('maxoutstanding');
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_hold;
    my $expecting = 'Koha::Exceptions::Patron::Debt';

    ok($maxoutstanding, 'When I look at system preferences, I see that maximum allowed outstanding fines is set.');
    ok($maxoutstanding < $outstanding, 'When I check patron\'s balance, I found out they have more outstanding fines than allowed.');
    is(ref($debt), $expecting, "When I check patron debt, then $expecting is given.");
    is($debt->max_outstanding, $maxoutstanding, 'Then I can see the status showing me how much'
       .' outstanding total can be at maximum.');
    is($debt->current_outstanding, $outstanding, 'Then I can see the status showing me how much'
       .' outstanding fines patron has right now.');
};

subtest 'debt_renew_opac, given patron has less than OPACFineNoRenewals' => \&t_fines_renew_opac_less_than_max;
sub t_fines_renew_opac_less_than_max {
    plan tests => 3;

    t::lib::Mocks::mock_preference('OPACFineNoRenewals', 9001);

    my $patron = build_a_test_patron();
    my $line = Koha::Account::Line->new({
        borrowernumber => $patron->borrowernumber,
        amountoutstanding => 9000,
    })->store;
    my ($outstanding) = C4::Members::GetMemberAccountRecords($patron->borrowernumber);
    my $maxoutstanding = C4::Context->preference('OPACFineNoRenewals');
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_renew_opac;

    ok($maxoutstanding, 'When I look at system preferences, I see that maximum allowed outstanding fines is set.');
    ok($maxoutstanding > $outstanding, 'When I check patron\'s balance, I found out they have less outstanding fines than maximum allowed.');
    ok(!$debt, 'When I check patron debt, then no exception is given.');
};

subtest 'debt_renew_opac, given patron has more than OPACFineNoRenewals' => \&t_fines_renew_opac_more_than_max;
sub t_fines_renew_opac_more_than_max {
    plan tests => 5;

    t::lib::Mocks::mock_preference('OPACFineNoRenewals', 5);

    my $patron = build_a_test_patron();
    my $line = Koha::Account::Line->new({
        borrowernumber => $patron->borrowernumber,
        amountoutstanding => 9001,
    })->store;
    my ($outstanding) = C4::Members::GetMemberAccountRecords($patron->borrowernumber);
    my $maxoutstanding = C4::Context->preference('OPACFineNoRenewals');
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_renew_opac;
    my $expecting = 'Koha::Exceptions::Patron::Debt';

    ok($maxoutstanding, 'When I look at system preferences, I see that maximum allowed outstanding fines is set.');
    ok($maxoutstanding < $outstanding, 'When I check patron\'s balance, I found out they have more outstanding fines than allowed.');
    is(ref($debt), $expecting, "When I check patron debt, then $expecting is given.");
    is($debt->max_outstanding, $maxoutstanding, 'Then I can see the status showing me how much'
       .' outstanding total can be at maximum.');
    is($debt->current_outstanding, $outstanding, 'Then I can see the status showing me how much'
       .' outstanding fines patron has right now.');
};

subtest 'debt_checkout_guarantees, given patron\'s guarantees have less than NoIssuesChargeGuarantees' => \&t_guarantees_fines_checkout_less_than_max;
sub t_guarantees_fines_checkout_less_than_max {
    plan tests => 3;

    t::lib::Mocks::mock_preference('NoIssuesChargeGuarantees', 5);

    my $patron = build_a_test_patron();
    my $guarantee1 = build_a_test_patron();
    $guarantee1->guarantorid($patron->borrowernumber)->store;
    my $guarantee2 = build_a_test_patron();
    $guarantee2->guarantorid($patron->borrowernumber)->store;
    my $line1 = Koha::Account::Line->new({
        borrowernumber => $guarantee1->borrowernumber,
        amountoutstanding => 2,
    })->store;
    my $line2 = Koha::Account::Line->new({
        borrowernumber => $guarantee2->borrowernumber,
        amountoutstanding => 2,
    })->store;
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_checkout_guarantees;

    ok($line1, 'We have added very small fines to patron\'s guarantees.');
    ok($line1->amountoutstanding+$line2->amountoutstanding < C4::Context->preference('NoIssuesChargeGuarantees'),
       'These fines total is less than NoIssuesChargeGuarantees');
    ok(!$debt,  'When I check patron guarantees debt, then no exception is given.');
};

subtest 'debt_checkout_guarantees, given patron\s guarantees have more than NoIssuesChargeGuarantees' => \&t_guarantees_fines_checkout_more_than_max;
sub t_guarantees_fines_checkout_more_than_max {
    plan tests => 5;

    t::lib::Mocks::mock_preference('NoIssuesChargeGuarantees', 5);

    my $patron = build_a_test_patron();
    my $guarantee1 = build_a_test_patron();
    $guarantee1->guarantorid($patron->borrowernumber)->store;
    my $guarantee2 = build_a_test_patron();
    $guarantee2->guarantorid($patron->borrowernumber)->store;
    my $line1 = Koha::Account::Line->new({
        borrowernumber => $guarantee1->borrowernumber,
        amountoutstanding => 3,
    })->store;
    my $line2 = Koha::Account::Line->new({
        borrowernumber => $guarantee2->borrowernumber,
        amountoutstanding => 3,
    })->store;
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $debt = $patroncalc->debt_checkout_guarantees;
    my $expecting = 'Koha::Exceptions::Patron::DebtGuarantees';

    ok($line1, 'We have added very small fines to patron\'s guarantees.');
    ok($line1->amountoutstanding+$line2->amountoutstanding > C4::Context->preference('NoIssuesChargeGuarantees'),
       'These fines total is more than NoIssuesChargeGuarantees');
    is(ref($debt), $expecting, "When I check patron guarantees debt, then $expecting is given.");
    is($debt->max_outstanding, 5, 'Then I can see the status showing me how much'
       .' outstanding total can be at maximum.');
    is($debt->current_outstanding, 6, 'Then I can see the status showing me how much'
       .' outstanding fines patron guarantees have right now.');
};

subtest 'exceeded_maxreserves, given patron not exceeding max reserves' => \&t_exceeded_maxreserves_not;
sub t_exceeded_maxreserves_not {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $holds = Koha::Holds->search({ borrowernumber => $patron->borrowernumber });

    is($holds->count, 0, 'Patron has no holds.');
    ok(!$patroncalc->exceeded_maxreserves, 'When I check if patron exceeded maxreserves, then no exception is given.');
};

subtest 'exceeded_maxreserves, given patron exceeding max reserves' => \&t_exceeded_maxreserves;
sub t_exceeded_maxreserves {
    plan tests => 5;

    t::lib::Mocks::mock_preference('maxreserves', 1);

    my $item = build_a_test_item();
    my $item2 = build_a_test_item();
    my $patron = build_a_test_patron();
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    add_biblio_level_hold($item, $patron, $patron->branchcode);
    add_biblio_level_hold($item2, $patron, $patron->branchcode);
    my $holds = Koha::Holds->search({ borrowernumber => $patron->borrowernumber });
    my $expecting = 'Koha::Exceptions::Hold::MaximumHoldsReached';
    my $exceeded = $patroncalc->exceeded_maxreserves;

    is(C4::Context->preference('maxreserves'), 1, 'Maximum number of holds allowed is one.');
    is($holds->count, 2, 'Patron has two holds.');
    is(ref($exceeded), $expecting, "When I check patron expiration, then $expecting is given.");
    is($exceeded->max_holds_allowed, 1, 'Then I can see the status showing me how many'
       .' holds are allowed at max.');
    is($exceeded->current_hold_count, 2, 'Then I can see the status showing me how many'
       .' holds patron has right now.');
};

subtest 'expired, given patron is not expired' => \&t_not_expired;
sub t_not_expired {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $dt_expiry = dt_from_string($patron->dateexpiry);
    my $now = DateTime->now(time_zone => C4::Context->tz);

    is(DateTime->compare($dt_expiry, $now), 1, 'Patron is not expired.');
    ok(!$patroncalc->expired, 'When I check patron expiration, then no exception is given.');
};

subtest 'expired, given patron is expired' => \&t_expired;
sub t_expired {
    plan tests => 2;

    my $patron = build_a_test_patron();
    $patron->dateexpiry('1999-10-10')->store;
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $dt_expiry = dt_from_string($patron->dateexpiry);
    my $now = DateTime->now(time_zone => C4::Context->tz);
    my $expecting = 'Koha::Exceptions::Patron::CardExpired';

    is(DateTime->compare($now, $dt_expiry), 1, 'Patron finds out their card is expired.');
    is(ref($patroncalc->expired), $expecting, "When I check patron expiration, then $expecting is given.");
};

subtest 'gonenoaddress, patron not gonenoaddress' => \&t_not_gonenoaddress;
sub t_not_gonenoaddress {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);

    ok(!$patron->gonenoaddress, 'Patron is not gonenoaddress.');
    ok(!$patroncalc->gonenoaddress, 'When I check patron gonenoaddress, then no exception is given.');
};

subtest 'gonenoaddress, patron gonenoaddress' => \&t_gonenoaddress;
sub t_gonenoaddress {
    plan tests => 2;

    my $patron = build_a_test_patron();
    $patron->gonenoaddress('1')->store;
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $expecting = 'Koha::Exceptions::Patron::GoneNoAddress';

    is($patron->gonenoaddress, 1, 'Patron is gonenoaddress.');
    is(ref($patroncalc->gonenoaddress), $expecting, "When I check patron gonenoaddress, then $expecting is given.");
};

subtest 'lost, patron card not lost' => \&t_not_lost;
sub t_not_lost {
    plan tests => 2;

    my $patron = build_a_test_patron();
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);

    ok(!$patron->lost, 'Patron card is not lost.');
    ok(!$patroncalc->lost, 'When I check if patron card is lost, then no exception is given.');
};

subtest 'lost, patron card lost' => \&t_lost;
sub t_lost {
    plan tests => 2;

    my $patron = build_a_test_patron();
    $patron->lost('1')->store;
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $expecting = 'Koha::Exceptions::Patron::CardLost';

    is($patron->lost, 1, 'Patron card is lost.');
    is(ref($patroncalc->lost), $expecting, "When I check if patron card is lost, then $expecting is given.");
};

subtest 'from_another_library, patron from same branch than me' => \&t_from_another_library_same_branch;
sub t_from_another_library_same_branch {
    plan tests => 2;

    t::lib::Mocks::mock_preference('IndependentBranches', 0);

    my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};

    C4::Context->_new_userenv('xxx');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode, 'Midway Public Library', '', '', '');

    my $patron = build_a_test_patron();
    $patron->branchcode($branchcode)->store;

    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);

    is(C4::Context->userenv->{branch}, $patron->branchcode, 'Patron is from same branch as me.');
    ok(!$patroncalc->from_another_library, 'When I check if patron is'
       .' from same branch as me, then no exception is given.');
}

subtest 'from_another_library, patron from different branch than me' => \&t_from_another_library;
sub t_from_another_library {
    plan tests => 2;

    t::lib::Mocks::mock_preference('IndependentBranches', 1);

    my $branchcode = $builder->build({ source => 'Branch' })->{'branchcode'};
    my $branchcode2 = $builder->build({ source => 'Branch' })->{'branchcode'};

    C4::Context->_new_userenv('xxx');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $branchcode, 'Midway Public Library', undef, '', '');

    my $patron = build_a_test_patron();
    $patron->branchcode($branchcode2)->store;

    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);
    my $expecting = 'Koha::Exceptions::Patron::FromAnotherLibrary';

    isnt(C4::Context->userenv->{branch}, $patron->branchcode, 'Patron is not from same branch as me.');
    is(ref($patroncalc->from_another_library), $expecting, "When I check if patron is"
       ." from same branch as me, then $expecting is given.");
}

$schema->storage->txn_rollback;

1;
