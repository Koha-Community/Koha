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
use Test::More tests => 17;
use t::lib::Mocks;
use t::lib::TestBuilder;
require t::db_dependent::Koha::Availability::Helpers;

use Koha::Database;
use Koha::IssuingRules;
use Koha::Items;
use Koha::ItemTypes;

use Koha::Availability::Checks::IssuingRule;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'maximum_checkouts_reached' => \&t_maximum_checkouts_reached;
sub t_maximum_checkouts_reached {
    plan tests => 5;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        maxissueqty => 1,
    })->store;

    issue_item($item, $patron);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::Checkout::MaximumCheckoutsReached';
    my $max_checkouts_reached = $issuingcalc->maximum_checkouts_reached;
    is($rule->maxissueqty, 1, 'When I look at issuing rules, I see that'
       .' maxissueqty is 1 for this itemtype.');
    is(Koha::Checkouts->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one checkout.');
    is(ref($max_checkouts_reached), $expecting, "When I ask if"
       ." maximum checkouts is reached, exception $expecting is given.");
    is($max_checkouts_reached->max_checkouts_allowed, $rule->maxissueqty,
       'Exception says max checkouts allowed is same as maxissueqty.');
    is($max_checkouts_reached->current_checkout_count, 1,
       'Exception says I currently have one checkout.');
};

subtest 'maximum_checkouts_reached, not reached' => \&t_maximum_checkouts_not_reached;
sub t_maximum_checkouts_not_reached {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        maxissueqty => 2,
    })->store;

    issue_item($item, $patron);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });

    is($rule->maxissueqty, 2, 'When I look at issuing rules, I see that'
       .' maxissueqty is 2 for this itemtype.');
    is(Koha::Checkouts->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one checkout.');
    ok(!$issuingcalc->maximum_checkouts_reached, 'When I ask if'
       .' maximum checkouts is reached, no exception is given.');
};

subtest 'maximum_holds_reached' => \&t_maximum_holds_reached;
sub t_maximum_holds_reached {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 1,
        holds_per_record => 2,
    })->store;

    add_item_level_hold($item, $patron, $item->homebranch);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::Hold::MaximumHoldsReached';

    is($rule->reservesallowed, 1, 'When I look at issuing rules, I see that'
       .' reservesallowed is 1 for this itemtype.');
    is(Koha::Holds->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one hold.');
    is(ref($issuingcalc->maximum_holds_reached), $expecting, "When I ask if"
       ." maximum holds is reached, exception $expecting is given.");
};

subtest 'maximum_holds_reached, not reached' => \&t_maximum_holds_not_reached;
sub t_maximum_holds_not_reached {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 2,
    })->store;

    add_item_level_hold($item, $patron, $patron->branchcode);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::Hold::MaximumHoldsReached';
    is($rule->reservesallowed, 2, 'When I look at issuing rules, I see that'
       .' reservesallowed is 2 for this itemtype.');
    is(Koha::Holds->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one hold.');
    ok(!$issuingcalc->maximum_holds_reached, 'When I ask if'
       .' maximum holds is reached, no exception is given.');
};

subtest 'maximum_holds_for_record_reached' => \&t_maximum_holds_for_record_reached;
sub t_maximum_holds_for_record_reached {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 2,
        holds_per_record => 1,
    })->store;

    add_item_level_hold($item, $patron, $item->homebranch);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::Hold::MaximumHoldsForRecordReached';

    is($rule->holds_per_record, 1, 'When I look at issuing rules, I see that'
       .' holds_per_record is 1 for this itemtype.');
    is(Koha::Holds->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one hold.');
    is(ref($issuingcalc->maximum_holds_for_record_reached), $expecting, "When I ask if"
       ." maximum holds for record is reached, exception $expecting is given.");
};

subtest 'maximum_holds_for_record_reached, not reached' => \&t_maximum_holds_for_record_not_reached;
sub t_maximum_holds_for_record_not_reached {
    plan tests => 4;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 2,
        holds_per_record => 2,
    })->store;

    add_item_level_hold($item, $patron, $item->homebranch);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    is($rule->holds_per_record, 2, 'When I look at issuing rules, I see that'
       .' holds_per_record is 2 for this itemtype.');
    is(Koha::Holds->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one hold.');
    ok(!$issuingcalc->maximum_holds_for_record_reached, 'When I ask if'
       .' maximum holds for record is reached, no exception is given.');

    subtest 'nonfound_holds param' => sub {
        plan tests => 1;

        my $patron2 = build_a_test_patron();
        add_biblio_level_hold($item, $patron2, $item->homebranch);
        add_biblio_level_hold($item, $patron2, $item->homebranch);
        my @nonfound_holds = Koha::Holds->search({
            biblionumber => $item->biblionumber,
            found => undef,
            borrowernumber => $patron->borrowernumber,
        })->as_list;
        ok(!$issuingcalc->maximum_holds_for_record_reached({
            nonfound_holds => \@nonfound_holds }), 'When I ask if'
       .' maximum holds for record is reached, no exception is given.');
    };
};

subtest 'on_shelf_holds_forbidden while on shelf holds are allowed' => \&t_on_shelf_holds_forbidden;
sub t_on_shelf_holds_forbidden {
    plan tests => 2;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $item2 = build_a_test_item();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 1,
        reservesallowed => 1,
        onshelfholds => 1,
    })->store;

    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
    });
    is($rule->onshelfholds, 1, 'When I look at issuing rules, I see that'
       .' onshelfholds are allowed.');
    ok(!$issuingcalc->on_shelf_holds_forbidden, 'When I check availability calculation'
       .' to see if on shelf holds are forbidden, then no exception is given.');
};

subtest 'on_shelf_holds_forbidden if any available' => \&t_on_shelf_holds_forbidden_any_available;
sub t_on_shelf_holds_forbidden_any_available {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
    my $item2 = build_a_test_item($biblio, $biblioitem);
    $item2->itype($item->itype)->store;
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 1,
        reservesallowed => 1,
        onshelfholds => 2,
    })->store;

    my $expecting = 'Koha::Exceptions::Hold::OnShelfNotAllowed';
    subtest 'While there are available items' => sub {
        plan tests => 4;
        my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item,
        });
        is($rule->onshelfholds, 2, 'When I look at issuing rules, I see that'
           .' onshelfholds are allowed if all are unavailable.');
        ok(!$item->onloan && !$item2->onloan, 'Both items are available.');
        ok($issuingcalc->on_shelf_holds_forbidden, 'When I check '
           .'availability calculation to see if on shelf holds are forbidden,');
        is(ref($issuingcalc->on_shelf_holds_forbidden), $expecting, 'Then'
           ." exception $expecting is given.");
    };
    subtest 'While one of two items is available' => sub {
        plan tests => 7;
        is($rule->onshelfholds, 2, 'When I look at issuing rules, I see that'
           .' onshelfholds are allowed if all are unavailable.');
        ok(issue_item($item, $patron), 'We have issued one of two items.');
        my $issuingcalc;
        ok($issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item
        }), 'First, we will check on shelf hold restrictions for the item that is'
           .' unavailable.');
        ok($issuingcalc->on_shelf_holds_forbidden, 'When I check '
           .'availability calculation to see if on shelf holds are forbidden,');
        is(ref($issuingcalc->on_shelf_holds_forbidden), $expecting, 'Then'
           ." exception $expecting is given.");
        ok($issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item2
        }), 'Then, we will check on shelf hold restrictions for the item that is'
           .' available.');
        is(ref($issuingcalc->on_shelf_holds_forbidden), $expecting, 'When I check '
           .'availability calculation to see if on shelf holds are forbidden, then'
           ." exception $expecting is given.");
    };
    subtest 'While all are unavailable' => sub {
        plan tests => 3;
        my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item,
        });
        is($rule->onshelfholds, 2, 'When I look at issuing rules, I see that'
           .' onshelfholds are allowed if all are unavailable.');
        ok(issue_item($item2, $patron), 'Both items are now unavailable.');
        ok(!$issuingcalc->on_shelf_holds_forbidden, 'When I check availability calculation'
       .' to see if on shelf holds are forbidden, then no exception is given.');
    };
};

subtest 'on_shelf_holds_forbidden if all available' => \&t_on_shelf_holds_forbidden_all_available;
sub t_on_shelf_holds_forbidden_all_available {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    my $biblio = Koha::Biblios->find($item->biblionumber);
    my $biblioitem = Koha::Biblioitems->find($item->biblioitemnumber);
    my $item2 = build_a_test_item($biblio, $biblioitem);
    $item2->itype($item->itype)->store;
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 1,
        reservesallowed => 1,
        onshelfholds => 0,
    })->store;

    my $expecting = 'Koha::Exceptions::Hold::OnShelfNotAllowed';
    subtest 'While all items are available' => sub {
        plan tests => 3;
        my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item,
        });
        is($rule->onshelfholds, 0, 'When I look at issuing rules, I see that'
           .' onshelfholds are allowed if any is unavailable.');
        ok($issuingcalc->on_shelf_holds_forbidden,'When I check '
           .'availability calculation to see if on shelf holds are forbidden,');
        is(ref($issuingcalc->on_shelf_holds_forbidden), $expecting, 'Then'
           ." exception $expecting is given.");
    };
    subtest 'While one of two items is available' => sub {
        plan tests => 7;
        is($rule->onshelfholds, 0, 'When I look at issuing rules, I see that'
           .' onshelfholds are allowed if any is unavailable.');
        ok(issue_item($item, $patron), 'We have issued one of two items.');
        $item = Koha::Items->find($item->itemnumber); #refresh
        my $issuingcalc;
        ok($issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item
        }), 'First, we will check on shelf hold restrictions for the item that is'
           .' unavailable.');
        ok(!$issuingcalc->on_shelf_holds_forbidden, 'When I check availability calculation'
        .' to see if on shelf holds are forbidden, then no exception is given.');
        ok($issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item2
        }), 'Then, we will check on shelf hold restrictions for the item that is'
           .' available.');
        ok($issuingcalc->on_shelf_holds_forbidden, 'When I check '
           .'availability calculation to see if on shelf holds are forbidden,');
        is(ref($issuingcalc->on_shelf_holds_forbidden), $expecting, 'Then'
           ." exception $expecting is given.");
    };
    subtest 'While all are unavailable' => sub {
        plan tests => 3;
        my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
            item => $item,
        });
        is($rule->onshelfholds, 0, 'When I look at issuing rules, I see that'
           .' onshelfholds are allowed if all are unavailable.');
        ok(issue_item($item2, $patron), 'Both items are now unavailable.');
        ok(!$issuingcalc->on_shelf_holds_forbidden, 'When I check availability calculation'
       .' to see if on shelf holds are forbidden, then no exception is given.');
    };
};

subtest 'opac_item_level_hold_forbidden' => \&t_opac_item_level_hold_forbidden;
sub t_opac_item_level_hold_forbidden {
    plan tests => 2;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 1,
        reservesallowed => 1,
        opacitemholds => 'N',
    })->store;

    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
    });
    my $expecting = 'Koha::Exceptions::Hold::ItemLevelHoldNotAllowed';
    is($rule->opacitemholds, 'N', 'When I look at issuing rules, I see that'
       .' opacitemholds is disabled for this itemtype');
    is(ref($issuingcalc->opac_item_level_hold_forbidden), $expecting, "When I ask if"
       ." item level holds are allowed, exception $expecting is given.");
};

subtest 'opac_item_level_hold_forbidden, not forbidden' => \&t_opac_item_level_hold_not_forbidden;
sub t_opac_item_level_hold_not_forbidden {
    plan tests => 2;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        holds_per_record => 1,
        reservesallowed => 1,
        opacitemholds => 'Y',
    })->store;

    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
    });
    my $expecting = 'Koha::Exceptions::Hold::ItemLevelHoldNotAllowed';
    is($rule->opacitemholds, 'Y', 'When I look at issuing rules, I see that'
       .' opacitemholds is enabled for this itemtype');
    ok(!$issuingcalc->opac_item_level_hold_forbidden, 'When I ask if'
       .' item level holds are allowed, then no exception is given.');
};

subtest 'zero_holds_allowed' => \&t_zero_holds_allowed;
sub t_zero_holds_allowed {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 0,
    })->store;

    add_item_level_hold($item, $patron, $item->homebranch);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::Hold::ZeroHoldsAllowed';

    is($rule->reservesallowed, 0, 'When I look at issuing rules, I see that'
       .' zero holds are allowed for this itemtype.');
    is(Koha::Holds->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one hold.');
    is(ref($issuingcalc->zero_holds_allowed), $expecting, "When I ask if"
       ." zero holds are allowed, exception $expecting is given.");
};

subtest 'zero_checkouts_allowed' => \&t_zero_checkouts_allowed;
sub t_zero_checkouts_allowed {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        maxissueqty  => 0,
    })->store;

    issue_item($item, $patron);
    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::Checkout::ZeroCheckoutsAllowed';

    is($rule->maxissueqty, 0, 'When I look at issuing rules, I see that'
       .' zero checkouts are allowed for this itemtype.');
    is(Koha::Checkouts->search({borrowernumber=>$patron->borrowernumber})->count,
       1, 'I see that I have one checkout.');
    is(ref($issuingcalc->zero_checkouts_allowed), $expecting, "When I ask if"
       ." zero checkouts are allowed, exception $expecting is given.");
};

subtest 'no_article_requests_allowed' => \&t_no_article_requests_allowed;
sub t_no_article_requests_allowed {
    plan tests => 2;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 0,
        article_requests => 'no'
    })->store;

    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::ArticleRequest::NotAllowed';

    is($rule->article_requests, 'no', 'When I look at issuing rules, I see that'
       .' article requests are not allowed for this itemtype.');
    is(ref($issuingcalc->no_article_requests_allowed), $expecting, "When I ask if"
       ." no article requests are allowed, exception $expecting is given.");
};

subtest 'no_item_article_requests_allowed' => \&t_no_item_article_requests_allowed;
sub t_no_item_article_requests_allowed {
    plan tests => 2;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 0,
        article_requests => 'bib_only'
    })->store;

    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::ArticleRequest::ItemLevelRequestNotAllowed';

    is($rule->article_requests, 'bib_only', 'When I look at issuing rules, I see that'
       .' item level article requests are not allowed for this itemtype.');
    is(ref($issuingcalc->opac_item_level_article_request_forbidden), $expecting, "When I ask if"
       ." article requests are allowed, exception $expecting is given.");
};

subtest 'no_bib_article_requests_allowed' => \&t_no_bib_article_requests_allowed;
sub t_no_bib_article_requests_allowed {
    plan tests => 2;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 0,
        article_requests => 'item_only'
    })->store;

    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });
    my $expecting = 'Koha::Exceptions::ArticleRequest::BibLevelRequestNotAllowed';

    is($rule->article_requests, 'item_only', 'When I look at issuing rules, I see that'
       .' bib level article requests are not allowed for this itemtype.');
    is(ref($issuingcalc->opac_bib_level_article_request_forbidden), $expecting, "When I ask if"
       ." article requests are allowed, exception $expecting is given.");
};

subtest 'all_article_requests_allowed' => \&t_all_article_requests_allowed;
sub t_all_article_requests_allowed {
    plan tests => 3;

    set_default_system_preferences();
    set_default_circulation_rules();
    my $item = build_a_test_item();
    my $patron = build_a_test_patron();
    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => $item->effective_itemtype,
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        reservesallowed => 0,
        article_requests => 'yes'
    })->store;

    my $issuingcalc = Koha::Availability::Checks::IssuingRule->new({
        item => $item,
        patron => $patron,
    });

    is($rule->article_requests, 'yes', 'When I look at issuing rules, I see that'
       .' all article requests are allowed for this itemtype.');
    is(ref($issuingcalc->opac_bib_level_article_request_forbidden), '', "When I ask if"
       ." bib level article requests are allowed, no exception is returned.");
    is(ref($issuingcalc->opac_item_level_article_request_forbidden), '', "When I ask if"
       ." item level article requests are allowed, no exception is returned.");
};

$schema->storage->txn_rollback;

1;
