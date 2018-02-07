#!/usr/bin/perl
# Copyright 2000-2002 Katipo Communications
# copyright 2010 BibLibre
#
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
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Debug;
use Koha::DateUtils;
use Koha::Database;
use Koha::IssuingRule;
use Koha::IssuingRules;
use Koha::Logger;
use Koha::RefundLostItemFeeRule;
use Koha::RefundLostItemFeeRules;
use Koha::Libraries;
use Koha::CirculationRules;
use Koha::Patron::Categories;
use Koha::Caches;
use Koha::Patrons;

my $input = CGI->new;
my $dbh = C4::Context->dbh;

# my $flagsrequired;
# $flagsrequired->{circulation}=1;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/smart-rules.tt",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 'manage_circ_rules'},
                            debug => 1,
                            });

my $type=$input->param('type');

my $branch = $input->param('branch');
unless ( $branch ) {
    if ( C4::Context->preference('DefaultToLoggedInLibraryCircRules') ) {
        $branch = Koha::Libraries->search->count() == 1 ? undef : C4::Context::mybranch();
    }
    else {
        $branch = C4::Context::only_my_library() ? ( C4::Context::mybranch() || '*' ) : '*';
    }
}

my $logged_in_patron = Koha::Patrons->find( $loggedinuser );

my $can_edit_from_any_library = $logged_in_patron->has_permission( {parameters => 'manage_circ_rules_from_any_libraries' } );
$template->param( restricted_to_own_library => not $can_edit_from_any_library );
$branch = C4::Context::mybranch() unless $can_edit_from_any_library;

$branch = '*' if $branch eq 'NO_LIBRARY_SET';

my $op = $input->param('op') || q{};
my $language = C4::Languages::getlanguage();

my $cache = Koha::Caches->get_instance;
$cache->clear_from_cache( Koha::IssuingRules::GUESSED_ITEMTYPES_KEY );

if ($op eq 'delete') {
    my $itemtype     = $input->param('itemtype');
    my $categorycode = $input->param('categorycode');
    $debug and warn "deleting $1 $2 $branch";

    my $sth_Idelete = $dbh->prepare("delete from issuingrules where branchcode=? and categorycode=? and itemtype=?");
    $sth_Idelete->execute($branch, $categorycode, $itemtype);
}
elsif ($op eq 'delete-branch-cat') {
    my $categorycode  = $input->param('categorycode');
    if ($branch eq "*") {
        if ($categorycode eq "*") {
            my $sth_delete = $dbh->prepare("DELETE FROM default_circ_rules");
            $sth_delete->execute();
        } else {
            my $sth_delete = $dbh->prepare("DELETE FROM default_borrower_circ_rules
                                            WHERE categorycode = ?");
            $sth_delete->execute($categorycode);
        }
    } elsif ($categorycode eq "*") {
        my $sth_delete = $dbh->prepare("DELETE FROM default_branch_circ_rules
                                        WHERE branchcode = ?");
        $sth_delete->execute($branch);
    } else {
        my $sth_delete = $dbh->prepare("DELETE FROM branch_borrower_circ_rules
                                        WHERE branchcode = ?
                                        AND categorycode = ?");
        $sth_delete->execute($branch, $categorycode);
    }
    Koha::CirculationRules->set_rule(
        {
            branchcode   => $branch,
            categorycode => $categorycode,
            itemtype     => undef,
            rule_name    => 'max_holds',
            rule_value   => undef,
        }
    );
}
elsif ($op eq 'delete-branch-item') {
    my $itemtype  = $input->param('itemtype');
    if ($branch eq "*") {
        if ($itemtype eq "*") {
            my $sth_delete = $dbh->prepare("DELETE FROM default_circ_rules");
            $sth_delete->execute();
        } else {
            my $sth_delete = $dbh->prepare("DELETE FROM default_branch_item_rules
                                            WHERE itemtype = ?");
            $sth_delete->execute($itemtype);
        }
    } elsif ($itemtype eq "*") {
        my $sth_delete = $dbh->prepare("DELETE FROM default_branch_circ_rules
                                        WHERE branchcode = ?");
        $sth_delete->execute($branch);
    } else {
        my $sth_delete = $dbh->prepare("DELETE FROM branch_item_rules
                                        WHERE branchcode = ?
                                        AND itemtype = ?");
        $sth_delete->execute($branch, $itemtype);
    }
}
# save the values entered
elsif ($op eq 'add') {
    my $br = $branch; # branch
    my $bor  = $input->param('categorycode'); # borrower category
    my $itemtype  = $input->param('itemtype');     # item type
    my $fine = $input->param('fine');
    my $finedays     = $input->param('finedays');
    my $maxsuspensiondays = $input->param('maxsuspensiondays');
    $maxsuspensiondays = undef if $maxsuspensiondays eq q||;
    my $suspension_chargeperiod = $input->param('suspension_chargeperiod') || 1;
    my $firstremind  = $input->param('firstremind');
    my $chargeperiod = $input->param('chargeperiod');
    my $chargeperiod_charge_at = $input->param('chargeperiod_charge_at');
    my $maxissueqty  = $input->param('maxissueqty');
    my $maxonsiteissueqty  = $input->param('maxonsiteissueqty');
    my $renewalsallowed  = $input->param('renewalsallowed');
    my $renewalperiod    = $input->param('renewalperiod');
    my $norenewalbefore  = $input->param('norenewalbefore');
    $norenewalbefore = undef if $norenewalbefore =~ /^\s*$/;
    my $auto_renew = $input->param('auto_renew') eq 'yes' ? 1 : 0;
    my $no_auto_renewal_after = $input->param('no_auto_renewal_after');
    $no_auto_renewal_after = undef if $no_auto_renewal_after =~ /^\s*$/;
    my $no_auto_renewal_after_hard_limit = $input->param('no_auto_renewal_after_hard_limit') || undef;
    $no_auto_renewal_after_hard_limit = eval { dt_from_string( $input->param('no_auto_renewal_after_hard_limit') ) } if ( $no_auto_renewal_after_hard_limit );
    $no_auto_renewal_after_hard_limit = output_pref( { dt => $no_auto_renewal_after_hard_limit, dateonly => 1, dateformat => 'iso' } ) if ( $no_auto_renewal_after_hard_limit );
    my $reservesallowed  = $input->param('reservesallowed');
    my $holds_per_record = $input->param('holds_per_record');
    my $holds_per_day    = $input->param('holds_per_day');
    $holds_per_day =~ s/\s//g;
    $holds_per_day = undef if $holds_per_day !~ /^\d+/;
    my $onshelfholds     = $input->param('onshelfholds') || 0;
    $maxissueqty =~ s/\s//g;
    $maxissueqty = undef if $maxissueqty !~ /^\d+/;
    $maxonsiteissueqty =~ s/\s//g;
    $maxonsiteissueqty = undef if $maxonsiteissueqty !~ /^\d+/;
    my $issuelength  = $input->param('issuelength');
    $issuelength = $issuelength eq q{} ? undef : $issuelength;
    my $lengthunit  = $input->param('lengthunit');
    my $hardduedate = $input->param('hardduedate') || undef;
    $hardduedate = eval { dt_from_string( $input->param('hardduedate') ) } if ( $hardduedate );
    $hardduedate = output_pref( { dt => $hardduedate, dateonly => 1, dateformat => 'iso' } ) if ( $hardduedate );
    my $hardduedatecompare = $input->param('hardduedatecompare');
    my $rentaldiscount = $input->param('rentaldiscount');
    my $opacitemholds = $input->param('opacitemholds') || 0;
    my $article_requests = $input->param('article_requests') || 'no';
    my $overduefinescap = $input->param('overduefinescap') || undef;
    my $cap_fine_to_replacement_price = $input->param('cap_fine_to_replacement_price') eq 'on';
    $debug and warn "Adding $br, $bor, $itemtype, $fine, $maxissueqty, $maxonsiteissueqty, $cap_fine_to_replacement_price";

    my $params = {
        branchcode                    => $br,
        categorycode                  => $bor,
        itemtype                      => $itemtype,
        fine                          => $fine,
        finedays                      => $finedays,
        maxsuspensiondays             => $maxsuspensiondays,
        suspension_chargeperiod       => $suspension_chargeperiod,
        firstremind                   => $firstremind,
        chargeperiod                  => $chargeperiod,
        chargeperiod_charge_at        => $chargeperiod_charge_at,
        maxissueqty                   => $maxissueqty,
        maxonsiteissueqty             => $maxonsiteissueqty,
        renewalsallowed               => $renewalsallowed,
        renewalperiod                 => $renewalperiod,
        norenewalbefore               => $norenewalbefore,
        auto_renew                    => $auto_renew,
        no_auto_renewal_after         => $no_auto_renewal_after,
        no_auto_renewal_after_hard_limit => $no_auto_renewal_after_hard_limit,
        reservesallowed               => $reservesallowed,
        holds_per_record              => $holds_per_record,
        holds_per_day                 => $holds_per_day,
        issuelength                   => $issuelength,
        lengthunit                    => $lengthunit,
        hardduedate                   => $hardduedate,
        hardduedatecompare            => $hardduedatecompare,
        rentaldiscount                => $rentaldiscount,
        onshelfholds                  => $onshelfholds,
        opacitemholds                 => $opacitemholds,
        overduefinescap               => $overduefinescap,
        cap_fine_to_replacement_price => $cap_fine_to_replacement_price,
        article_requests              => $article_requests,
    };

    my $issuingrule = Koha::IssuingRules->find({categorycode => $bor, itemtype => $itemtype, branchcode => $br});
    if ($issuingrule) {
        $issuingrule->set($params)->store();
    } else {
        Koha::IssuingRule->new()->set($params)->store();
    }

}
elsif ($op eq "set-branch-defaults") {
    my $categorycode  = $input->param('categorycode');
    my $maxissueqty   = $input->param('maxissueqty');
    my $maxonsiteissueqty = $input->param('maxonsiteissueqty');
    my $holdallowed   = $input->param('holdallowed');
    my $hold_fulfillment_policy = $input->param('hold_fulfillment_policy');
    my $returnbranch  = $input->param('returnbranch');
    my $max_holds = $input->param('max_holds');
    $maxissueqty =~ s/\s//g;
    $maxissueqty = undef if $maxissueqty !~ /^\d+/;
    $maxonsiteissueqty =~ s/\s//g;
    $maxonsiteissueqty = undef if $maxonsiteissueqty !~ /^\d+/;
    $holdallowed =~ s/\s//g;
    $holdallowed = undef if $holdallowed !~ /^\d+/;
    $max_holds =~ s/\s//g;
    $max_holds = '' if $max_holds !~ /^\d+/;

    if ($branch eq "*") {
        my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                        FROM default_circ_rules");
        my $sth_insert = $dbh->prepare("INSERT INTO default_circ_rules
                                        (maxissueqty, maxonsiteissueqty, holdallowed, hold_fulfillment_policy, returnbranch)
                                        VALUES (?, ?, ?, ?, ?)");
        my $sth_update = $dbh->prepare("UPDATE default_circ_rules
                                        SET maxissueqty = ?, maxonsiteissueqty = ?, holdallowed = ?, hold_fulfillment_policy = ?, returnbranch = ?");

        $sth_search->execute();
        my $res = $sth_search->fetchrow_hashref();
        if ($res->{total}) {
            $sth_update->execute($maxissueqty, $maxonsiteissueqty, $holdallowed, $hold_fulfillment_policy, $returnbranch);
        } else {
            $sth_insert->execute($maxissueqty, $maxonsiteissueqty, $holdallowed, $hold_fulfillment_policy, $returnbranch);
        }
    } else {
        my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                        FROM default_branch_circ_rules
                                        WHERE branchcode = ?");
        my $sth_insert = $dbh->prepare("INSERT INTO default_branch_circ_rules
                                        (branchcode, maxissueqty, maxonsiteissueqty, holdallowed, hold_fulfillment_policy, returnbranch)
                                        VALUES (?, ?, ?, ?, ?, ?)");
        my $sth_update = $dbh->prepare("UPDATE default_branch_circ_rules
                                        SET maxissueqty = ?, maxonsiteissueqty = ?, holdallowed = ?, hold_fulfillment_policy = ?, returnbranch = ?
                                        WHERE branchcode = ?");
        $sth_search->execute($branch);
        my $res = $sth_search->fetchrow_hashref();
        if ($res->{total}) {
            $sth_update->execute($maxissueqty, $maxonsiteissueqty, $holdallowed, $hold_fulfillment_policy, $returnbranch, $branch);
        } else {
            $sth_insert->execute($branch, $maxissueqty, $maxonsiteissueqty, $holdallowed, $hold_fulfillment_policy, $returnbranch);
        }
    }
    Koha::CirculationRules->set_rule(
        {
            branchcode   => $branch,
            categorycode => undef,
            itemtype     => undef,
            rule_name    => 'max_holds',
            rule_value   => $max_holds,
        }
    );
}
elsif ($op eq "add-branch-cat") {
    my $categorycode  = $input->param('categorycode');
    my $maxissueqty   = $input->param('maxissueqty');
    my $maxonsiteissueqty = $input->param('maxonsiteissueqty');
    my $max_holds = $input->param('max_holds');
    $maxissueqty =~ s/\s//g;
    $maxissueqty = undef if $maxissueqty !~ /^\d+/;
    $maxonsiteissueqty =~ s/\s//g;
    $maxonsiteissueqty = undef if $maxonsiteissueqty !~ /^\d+/;
    $max_holds =~ s/\s//g;
    $max_holds = undef if $max_holds !~ /^\d+/;

    if ($branch eq "*") {
        if ($categorycode eq "*") {
            #FIXME This block is will probably be never used
            my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                            FROM default_circ_rules");
            my $sth_insert = $dbh->prepare(q|
                INSERT INTO default_circ_rules
                    (maxissueqty, maxonsiteissueqty)
                    VALUES (?, ?)
            |);
            my $sth_update = $dbh->prepare(q|
                UPDATE default_circ_rules
                SET maxissueqty = ?,
                    maxonsiteissueqty = ?,
            |);

            $sth_search->execute();
            my $res = $sth_search->fetchrow_hashref();
            if ($res->{total}) {
                $sth_update->execute( $maxissueqty, $maxonsiteissueqty );
            } else {
                $sth_insert->execute( $maxissueqty, $maxonsiteissueqty );
            }

            Koha::CirculationRules->set_rule(
                {
                    branchcode   => undef,
                    categorycode => undef,
                    itemtype     => undef,
                    rule_name    => 'max_holds',
                    rule_value   => $max_holds,
                }
            );
        } else {
            my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                            FROM default_borrower_circ_rules
                                            WHERE categorycode = ?");
            my $sth_insert = $dbh->prepare(q|
                INSERT INTO default_borrower_circ_rules
                    (categorycode, maxissueqty, maxonsiteissueqty)
                    VALUES ( ?, ?, ?)
            |);
            my $sth_update = $dbh->prepare(q|
                UPDATE default_borrower_circ_rules
                SET maxissueqty = ?,
                    maxonsiteissueqty = ?,
                WHERE categorycode = ?
            |);
            $sth_search->execute($categorycode);
            my $res = $sth_search->fetchrow_hashref();
            if ($res->{total}) {
                $sth_update->execute( $maxissueqty, $maxonsiteissueqty, $categorycode );
            } else {
                $sth_insert->execute( $categorycode, $maxissueqty, $maxonsiteissueqty );
            }

            Koha::CirculationRules->set_rule(
                {
                    branchcode   => undef,
                    categorycode => $categorycode,
                    itemtype     => undef,
                    rule_name    => 'max_holds',
                    rule_value   => $max_holds,
                }
            );
        }
    } elsif ($categorycode eq "*") {
        my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                        FROM default_branch_circ_rules
                                        WHERE branchcode = ?");
        my $sth_insert = $dbh->prepare(q|
            INSERT INTO default_branch_circ_rules
            (branchcode, maxissueqty, maxonsiteissueqty)
            VALUES (?, ?, ?)
        |);
        my $sth_update = $dbh->prepare(q|
            UPDATE default_branch_circ_rules
            SET maxissueqty = ?,
                maxonsiteissueqty = ?
            WHERE branchcode = ?
        |);
        $sth_search->execute($branch);
        my $res = $sth_search->fetchrow_hashref();
        if ($res->{total}) {
            $sth_update->execute($maxissueqty, $maxonsiteissueqty, $branch);
        } else {
            $sth_insert->execute($branch, $maxissueqty, $maxonsiteissueqty);
        }
    } else {
        my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                        FROM branch_borrower_circ_rules
                                        WHERE branchcode = ?
                                        AND   categorycode = ?");
        my $sth_insert = $dbh->prepare(q|
            INSERT INTO branch_borrower_circ_rules
            (branchcode, categorycode, maxissueqty, maxonsiteissueqty)
            VALUES (?, ?, ?, ?)
        |);
        my $sth_update = $dbh->prepare(q|
            UPDATE branch_borrower_circ_rules
            SET maxissueqty = ?,
                maxonsiteissueqty = ?
            WHERE branchcode = ?
            AND categorycode = ?
        |);

        $sth_search->execute($branch, $categorycode);
        my $res = $sth_search->fetchrow_hashref();
        if ($res->{total}) {
            $sth_update->execute($maxissueqty, $maxonsiteissueqty, $branch, $categorycode);
        } else {
            $sth_insert->execute($branch, $categorycode, $maxissueqty, $maxonsiteissueqty);
        }

        Koha::CirculationRules->set_rule(
            {
                branchcode   => $branch,
                categorycode => $categorycode,
                itemtype     => undef,
                rule_name    => 'max_holds',
                rule_value   => $max_holds,
            }
        );
    }
}
elsif ($op eq "add-branch-item") {
    my $itemtype                = $input->param('itemtype');
    my $holdallowed             = $input->param('holdallowed');
    my $hold_fulfillment_policy = $input->param('hold_fulfillment_policy');
    my $returnbranch            = $input->param('returnbranch');

    $holdallowed =~ s/\s//g;
    $holdallowed = undef if $holdallowed !~ /^\d+/;

    if ($branch eq "*") {
        if ($itemtype eq "*") {
            my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                            FROM default_circ_rules");
            my $sth_insert = $dbh->prepare("INSERT INTO default_circ_rules
                                            (holdallowed, hold_fulfillment_policy, returnbranch)
                                            VALUES (?, ?, ?)");
            my $sth_update = $dbh->prepare("UPDATE default_circ_rules
                                            SET holdallowed = ?, hold_fulfillment_policy = ?, returnbranch = ?");

            $sth_search->execute();
            my $res = $sth_search->fetchrow_hashref();
            if ($res->{total}) {
                $sth_update->execute($holdallowed, $hold_fulfillment_policy, $returnbranch);
            } else {
                $sth_insert->execute($holdallowed, $hold_fulfillment_policy, $returnbranch);
            }
        } else {
            my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                            FROM default_branch_item_rules
                                            WHERE itemtype = ?");
            my $sth_insert = $dbh->prepare("INSERT INTO default_branch_item_rules
                                            (itemtype, holdallowed, hold_fulfillment_policy, returnbranch)
                                            VALUES (?, ?, ?, ?)");
            my $sth_update = $dbh->prepare("UPDATE default_branch_item_rules
                                            SET holdallowed = ?, hold_fulfillment_policy = ?, returnbranch = ?
                                            WHERE itemtype = ?");
            $sth_search->execute($itemtype);
            my $res = $sth_search->fetchrow_hashref();
            if ($res->{total}) {
                $sth_update->execute($holdallowed, $hold_fulfillment_policy, $returnbranch, $itemtype);
            } else {
                $sth_insert->execute($itemtype, $holdallowed, $hold_fulfillment_policy, $returnbranch);
            }
        }
    } elsif ($itemtype eq "*") {
        my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                        FROM default_branch_circ_rules
                                        WHERE branchcode = ?");
        my $sth_insert = $dbh->prepare("INSERT INTO default_branch_circ_rules
                                        (branchcode, holdallowed, hold_fulfillment_policy, returnbranch)
                                        VALUES (?, ?, ?, ?)");
        my $sth_update = $dbh->prepare("UPDATE default_branch_circ_rules
                                        SET holdallowed = ?, hold_fulfillment_policy = ?, returnbranch = ?
                                        WHERE branchcode = ?");
        $sth_search->execute($branch);
        my $res = $sth_search->fetchrow_hashref();
        if ($res->{total}) {
            $sth_update->execute($holdallowed, $hold_fulfillment_policy, $returnbranch, $branch);
        } else {
            $sth_insert->execute($branch, $holdallowed, $hold_fulfillment_policy, $returnbranch);
        }
    } else {
        my $sth_search = $dbh->prepare("SELECT count(*) AS total
                                        FROM branch_item_rules
                                        WHERE branchcode = ?
                                        AND   itemtype = ?");
        my $sth_insert = $dbh->prepare("INSERT INTO branch_item_rules
                                        (branchcode, itemtype, holdallowed, hold_fulfillment_policy, returnbranch)
                                        VALUES (?, ?, ?, ?, ?)");
        my $sth_update = $dbh->prepare("UPDATE branch_item_rules
                                        SET holdallowed = ?, hold_fulfillment_policy = ?, returnbranch = ?
                                        WHERE branchcode = ?
                                        AND itemtype = ?");

        $sth_search->execute($branch, $itemtype);
        my $res = $sth_search->fetchrow_hashref();
        if ($res->{total}) {
            $sth_update->execute($holdallowed, $hold_fulfillment_policy, $returnbranch, $branch, $itemtype);
        } else {
            $sth_insert->execute($branch, $itemtype, $holdallowed, $hold_fulfillment_policy, $returnbranch);
        }
    }
}
elsif ( $op eq 'mod-refund-lost-item-fee-rule' ) {

    my $refund = $input->param('refund');

    if ( $refund eq '*' ) {
        if ( $branch ne '*' ) {
            # only do something for $refund eq '*' if branch-specific
            eval {
                # Delete it so it picks the default
                Koha::RefundLostItemFeeRules->find({
                    branchcode => $branch
                })->delete;
            };
        }
    } else {
        my $refundRule =
                Koha::RefundLostItemFeeRules->find({
                    branchcode => $branch
                }) // Koha::RefundLostItemFeeRule->new;
        $refundRule->set({
            branchcode => $branch,
                refund => $refund
        })->store;
    }
}

my $refundLostItemFeeRule = Koha::RefundLostItemFeeRules->find({ branchcode => $branch });
$template->param(
    refundLostItemFeeRule => $refundLostItemFeeRule,
    defaultRefundRule     => Koha::RefundLostItemFeeRules->_default_rule
);

my $patron_categories = Koha::Patron::Categories->search({}, { order_by => ['description'] });

my @row_loop;
my $itemtypes = Koha::ItemTypes->search_with_localization;

my $sth2 = $dbh->prepare("
    SELECT  issuingrules.*,
            itemtypes.description AS humanitemtype,
            categories.description AS humancategorycode,
            COALESCE( localization.translation, itemtypes.description ) AS translated_description
    FROM issuingrules
    LEFT JOIN itemtypes
        ON (itemtypes.itemtype = issuingrules.itemtype)
    LEFT JOIN categories
        ON (categories.categorycode = issuingrules.categorycode)
    LEFT JOIN localization ON issuingrules.itemtype = localization.code
        AND localization.entity = 'itemtypes'
        AND localization.lang = ?
    WHERE issuingrules.branchcode = ?
");
$sth2->execute($language, $branch);

while (my $row = $sth2->fetchrow_hashref) {
    $row->{'current_branch'} ||= $row->{'branchcode'};
    $row->{humanitemtype} ||= $row->{itemtype};
    $row->{default_translated_description} = 1 if $row->{humanitemtype} eq '*';
    $row->{'humancategorycode'} ||= $row->{'categorycode'};
    $row->{'default_humancategorycode'} = 1 if $row->{'humancategorycode'} eq '*';
    $row->{'fine'} = sprintf('%.2f', $row->{'fine'});
    if ($row->{'hardduedate'} && $row->{'hardduedate'} ne '0000-00-00') {
       my $harddue_dt = eval { dt_from_string( $row->{'hardduedate'} ) };
       $row->{'hardduedate'} = eval { output_pref( { dt => $harddue_dt, dateonly => 1 } ) } if ( $harddue_dt );
       $row->{'hardduedatebefore'} = 1 if ($row->{'hardduedatecompare'} == -1);
       $row->{'hardduedateexact'} = 1 if ($row->{'hardduedatecompare'} ==  0);
       $row->{'hardduedateafter'} = 1 if ($row->{'hardduedatecompare'} ==  1);
    } else {
       $row->{'hardduedate'} = 0;
    }
    if ($row->{no_auto_renewal_after_hard_limit}) {
       my $dt = eval { dt_from_string( $row->{no_auto_renewal_after_hard_limit} ) };
       $row->{no_auto_renewal_after_hard_limit} = eval { output_pref( { dt => $dt, dateonly => 1 } ) } if $dt;
    }

    push @row_loop, $row;
}

my @sorted_row_loop = sort by_category_and_itemtype @row_loop;

my $sth_branch_cat;
if ($branch eq "*") {
    $sth_branch_cat = $dbh->prepare("
        SELECT default_borrower_circ_rules.*, categories.description AS humancategorycode
        FROM default_borrower_circ_rules
        JOIN categories USING (categorycode)

    ");
    $sth_branch_cat->execute();
} else {
    $sth_branch_cat = $dbh->prepare("
        SELECT branch_borrower_circ_rules.*, categories.description AS humancategorycode
        FROM branch_borrower_circ_rules
        JOIN categories USING (categorycode)
        WHERE branch_borrower_circ_rules.branchcode = ?
    ");
    $sth_branch_cat->execute($branch);
}

my @branch_cat_rules = ();
while (my $row = $sth_branch_cat->fetchrow_hashref) {
    push @branch_cat_rules, $row;
}
my @sorted_branch_cat_rules = sort { $a->{'humancategorycode'} cmp $b->{'humancategorycode'} } @branch_cat_rules;

# note undef maxissueqty so that template can deal with them
foreach my $entry (@sorted_branch_cat_rules, @sorted_row_loop) {
    $entry->{unlimited_maxissueqty}       = 1 unless defined($entry->{maxissueqty});
    $entry->{unlimited_maxonsiteissueqty} = 1 unless defined($entry->{maxonsiteissueqty});
    $entry->{unlimited_max_holds}         = 1 unless defined($entry->{max_holds});
    $entry->{unlimited_holds_per_day}     = 1 unless defined($entry->{holds_per_day});
}

@sorted_row_loop = sort by_category_and_itemtype @row_loop;

my $sth_branch_item;
if ($branch eq "*") {
    $sth_branch_item = $dbh->prepare("
        SELECT default_branch_item_rules.*,
            COALESCE( localization.translation, itemtypes.description ) AS translated_description
        FROM default_branch_item_rules
        JOIN itemtypes USING (itemtype)
        LEFT JOIN localization ON itemtypes.itemtype = localization.code
            AND localization.entity = 'itemtypes'
            AND localization.lang = ?
    ");
    $sth_branch_item->execute($language);
} else {
    $sth_branch_item = $dbh->prepare("
        SELECT branch_item_rules.*,
            COALESCE( localization.translation, itemtypes.description ) AS translated_description
        FROM branch_item_rules
        JOIN itemtypes USING (itemtype)
        LEFT JOIN localization ON itemtypes.itemtype = localization.code
            AND localization.entity = 'itemtypes'
            AND localization.lang = ?
        WHERE branch_item_rules.branchcode = ?
    ");
    $sth_branch_item->execute($language, $branch);
}

my @branch_item_rules = ();
while (my $row = $sth_branch_item->fetchrow_hashref) {
    push @branch_item_rules, $row;
}
my @sorted_branch_item_rules = sort { lc $a->{translated_description} cmp lc $b->{translated_description} } @branch_item_rules;

# note undef holdallowed so that template can deal with them
foreach my $entry (@sorted_branch_item_rules) {
    $entry->{holdallowed_any}  = 1 if ( $entry->{holdallowed} == 2 );
    $entry->{holdallowed_same} = 1 if ( $entry->{holdallowed} == 1 );
}

$template->param(show_branch_cat_rule_form => 1);
$template->param(branch_item_rule_loop => \@sorted_branch_item_rules);
$template->param(branch_cat_rule_loop => \@sorted_branch_cat_rules);

my $sth_defaults;
if ($branch eq "*") {
    $sth_defaults = $dbh->prepare("
        SELECT *
        FROM default_circ_rules
    ");
    $sth_defaults->execute();
} else {
    $sth_defaults = $dbh->prepare("
        SELECT *
        FROM default_branch_circ_rules
        WHERE branchcode = ?
    ");
    $sth_defaults->execute($branch);
}

my $defaults = $sth_defaults->fetchrow_hashref;

if ($defaults) {
    $template->param( default_holdallowed_none => 1 ) if ( $defaults->{holdallowed} == 0 );
    $template->param( default_holdallowed_same => 1 ) if ( $defaults->{holdallowed} == 1 );
    $template->param( default_holdallowed_any  => 1 ) if ( $defaults->{holdallowed} == 2 );
    $template->param( default_hold_fulfillment_policy => $defaults->{hold_fulfillment_policy} );
    $template->param( default_maxissueqty      => $defaults->{maxissueqty} );
    $template->param( default_maxonsiteissueqty => $defaults->{maxonsiteissueqty} );
    $template->param( default_returnbranch      => $defaults->{returnbranch} );
}

$template->param(default_rules => ($defaults ? 1 : 0));

$template->param(
    patron_categories => $patron_categories,
                        itemtypeloop => $itemtypes,
                        rules => \@sorted_row_loop,
                        humanbranch => ($branch ne '*' ? $branch : ''),
                        current_branch => $branch,
                        definedbranch => scalar(@sorted_row_loop)>0
                        );
output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

# sort by patron category, then item type, putting
# default entries at the bottom
sub by_category_and_itemtype {
    unless (by_category($a, $b)) {
        return by_itemtype($a, $b);
    }
}

sub by_category {
    my ($a, $b) = @_;
    if ($a->{'default_humancategorycode'}) {
        return ($b->{'default_humancategorycode'} ? 0 : 1);
    } elsif ($b->{'default_humancategorycode'}) {
        return -1;
    } else {
        return $a->{'humancategorycode'} cmp $b->{'humancategorycode'};
    }
}

sub by_itemtype {
    my ($a, $b) = @_;
    if ($a->{default_translated_description}) {
        return ($b->{'default_translated_description'} ? 0 : 1);
    } elsif ($b->{'default_translated_description'}) {
        return -1;
    } else {
        return lc $a->{'translated_description'} cmp lc $b->{'translated_description'};
    }
}
