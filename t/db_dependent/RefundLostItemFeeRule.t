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

use Test::More tests => 8;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::RefundLostItemFeeRule');
    use_ok('Koha::RefundLostItemFeeRules');
}

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Koha::RefundLostItemFeeRule::delete() tests' => sub {

    plan tests => 7;

    # Start transaction
    $schema->storage->txn_begin;

    # Clean the table
    $schema->resultset('RefundLostItemFeeRule')->search()->delete;

    my $generated_default_rule = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            branchcode => '*'
        }
    });
    my $generated_other_rule = $builder->build({
        source => 'RefundLostItemFeeRule'
    });

    my $default_rule = Koha::RefundLostItemFeeRules->find({
            branchcode => '*' });
    ok( defined $default_rule, 'Default rule created' );
    ok( $default_rule->in_storage, 'Default rule actually in storage');

    my $other_rule = Koha::RefundLostItemFeeRules->find({
            branchcode => $generated_other_rule->{ branchcode }
    });
    ok( defined $other_rule, 'Other rule created' );
    ok( $other_rule->in_storage, 'Other rule actually in storage');

    # deleting the regular rule
    $other_rule->delete;
    ok( !$other_rule->in_storage, 'Other rule deleted from storage' );

    # deleting the default rule
    eval {
        $default_rule->delete;
    };
    is( ref($@), 'Koha::Exceptions::CannotDeleteDefault',
        'Exception on deleting default' );
    ok( $default_rule->in_storage, 'Default rule still in storage' );

    # Rollback transaction
    $schema->storage->txn_rollback;
};

subtest 'Koha::RefundLostItemFeeRules::_default_rule() tests' => sub {

    plan tests => 4;

    # Start transaction
    $schema->storage->txn_begin;

    # Clean the table
    $schema->resultset('RefundLostItemFeeRule')->search()->delete;

    my $generated_default_rule = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            branchcode => '*',
            refund     => 1
        }
    });
    my $generated_other_rule = $builder->build({
        source => 'RefundLostItemFeeRule'
    });

    my $default_rule = Koha::RefundLostItemFeeRules->find({
            branchcode => '*' });
    ok( defined $default_rule, 'Default rule created' );
    ok( $default_rule->in_storage, 'Default rule actually in storage');
    ok( Koha::RefundLostItemFeeRules->_default_rule, 'Default rule is set to refund' );

    # Change default rule to "Don't refund"
    $default_rule->refund(0);
    $default_rule->store;
    # Re-read from DB, to be sure
    $default_rule = Koha::RefundLostItemFeeRules->find({
            branchcode => '*' });
    ok( !Koha::RefundLostItemFeeRules->_default_rule, 'Default rule is set to not refund' );

    # Rollback transaction
    $schema->storage->txn_rollback;
};

subtest 'Koha::RefundLostItemFeeRules::_effective_branch_rule() tests' => sub {

    plan tests => 3;

    # Start transaction
    $schema->storage->txn_begin;

    # Clean the table
    $schema->resultset('RefundLostItemFeeRule')->search()->delete;

    my $default_rule = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            branchcode => '*',
            refund     => 1
        }
    });
    my $specific_rule_false = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            refund => 0
        }
    });
    my $specific_rule_true = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            refund => 1
        }
    });

    is( Koha::RefundLostItemFeeRules->_effective_branch_rule( $specific_rule_true->{ branchcode } ),
          1,'Specific rule is applied (true)');
    is( Koha::RefundLostItemFeeRules->_effective_branch_rule( $specific_rule_false->{ branchcode } ),
          0,'Specific rule is applied (false)');
    # Delete specific rules
    Koha::RefundLostItemFeeRules->find({ branchcode => $specific_rule_false->{ branchcode } })->delete;
    is( Koha::RefundLostItemFeeRules->_effective_branch_rule( $specific_rule_false->{ branchcode } ),
          1,'No specific rule defined, fallback to global (true)');

    # Rollback transaction
    $schema->storage->txn_rollback;
};

subtest 'Koha::RefundLostItemFeeRules::_choose_branch() tests' => sub {

    plan tests => 9;

    # Start transaction
    $schema->storage->txn_begin;

    my $params = {
        current_branch => 'current_branch_code',
        item_holding_branch => 'item_holding_branch_code',
        item_home_branch => 'item_home_branch_code'
    };

    my $syspref = Koha::Config::SysPrefs->find_or_create({
                        variable => 'RefundLostOnReturnControl',
                        value => 'CheckinLibrary' });

    is( Koha::RefundLostItemFeeRules->_choose_branch( $params ),
        'current_branch_code', 'CheckinLibrary is honoured');

    $syspref->value( 'ItemHomeBranch' )->store;
    is( Koha::RefundLostItemFeeRules->_choose_branch( $params ),
        'item_home_branch_code', 'ItemHomeBranch is honoured');

    $syspref->value( 'ItemHoldingBranch' )->store;
    is( Koha::RefundLostItemFeeRules->_choose_branch( $params ),
        'item_holding_branch_code', 'ItemHoldingBranch is honoured');

    $syspref->value( 'CheckinLibrary' )->store;
    eval {
        Koha::RefundLostItemFeeRules->_choose_branch();
    };
    is( ref($@), 'Koha::Exceptions::MissingParameter',
        'Missing parameter exception' );
    is( $@->message, 'CheckinLibrary requires the current_branch param',
        'Exception message is correct' );

    $syspref->value( 'ItemHomeBranch' )->store;
    eval {
        Koha::RefundLostItemFeeRules->_choose_branch();
    };
    is( ref($@), 'Koha::Exceptions::MissingParameter',
        'Missing parameter exception' );
    is( $@->message, 'ItemHomeBranch requires the item_home_branch param',
        'Exception message is correct' );

    $syspref->value( 'ItemHoldingBranch' )->store;
    eval {
        Koha::RefundLostItemFeeRules->_choose_branch();
    };
    is( ref($@), 'Koha::Exceptions::MissingParameter',
        'Missing parameter exception' );
    is( $@->message, 'ItemHoldingBranch requires the item_holding_branch param',
        'Exception message is correct' );

    # Rollback transaction
    $schema->storage->txn_rollback;
};

subtest 'Koha::RefundLostItemFeeRules::should_refund() tests' => sub {

    plan tests => 3;

    # Start transaction
    $schema->storage->txn_begin;

    my $syspref = Koha::Config::SysPrefs->find_or_create({
                        variable => 'RefundLostOnReturnControl',
                        value => 'CheckinLibrary' });

    $schema->resultset('RefundLostItemFeeRule')->search()->delete;

    my $default_rule = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            branchcode => '*',
            refund     => 1
        }
    });
    my $specific_rule_false = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            refund => 0
        }
    });
    my $specific_rule_true = $builder->build({
        source => 'RefundLostItemFeeRule',
        value  => {
            refund => 1
        }
    });
    # Make sure we have an unused branchcode
    my $specific_rule_dummy = $builder->build({
        source => 'RefundLostItemFeeRule'
    });
    my $branch_without_rule = $specific_rule_dummy->{ branchcode };
    Koha::RefundLostItemFeeRules
        ->find({ branchcode => $branch_without_rule })
        ->delete;

    my $params = {
        current_branch => $specific_rule_true->{ branchcode },
        # patron_branch  => $specific_rule_false->{ branchcode },
        item_holding_branch => $branch_without_rule,
        item_home_branch => $branch_without_rule
    };

    $syspref->value( 'CheckinLibrary' )->store;
    is( Koha::RefundLostItemFeeRules->should_refund( $params ),
          1,'Specific rule is applied (true)');

    $syspref->value( 'ItemHomeBranch' )->store;
    is( Koha::RefundLostItemFeeRules->should_refund( $params ),
         1,'No rule for branch, global rule applied (true)');

    # Change the default value just to try
    Koha::RefundLostItemFeeRules->find({ branchcode => '*' })->refund(0)->store;
    $syspref->value( 'ItemHoldingBranch' )->store;
    is( Koha::RefundLostItemFeeRules->should_refund( $params ),
         0,'No rule for branch, global rule applied (false)');

    # Rollback transaction
    $schema->storage->txn_rollback;
};

1;
