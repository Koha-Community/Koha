package Koha::RefundLostItemFeeRules;

# Copyright Theke Solutions 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Koha::Database;
use Koha::Exceptions;

use base qw(Koha::Objects);

=head1 NAME

Koha::RefundLostItemFeeRules - Koha RefundLostItemFeeRules object set class

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'RefundLostItemFeeRule';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::RefundLostItemFeeRule';
}

=head3 should_refund

Koha::RefundLostItemFeeRules->should_refund()

Returns a boolean telling if the fee needs to be refund given the
passed params, and the current rules/sysprefs configuration.

=cut

sub should_refund {

    my $self = shift;
    my $params = shift;

    return $self->_effective_branch_rule( $self->_choose_branch( $params ) );
}


=head3 _effective_branch_rule

Koha::RefundLostItemFeeRules->_effective_branch_rule

Given a branch, returns a boolean representing the resulting rule.
It tries the branch-specific first. Then falls back to the defined default.

=cut

sub _effective_branch_rule {

    my $self   = shift;
    my $branch = shift;

    my $specific_rule = $self->find({ branchcode => $branch });

    return ( defined $specific_rule )
                ? $specific_rule->refund
                : $self->_default_rule;
}

=head3 _choose_branch

my $branch = Koha::RefundLostItemFeeRules->_choose_branch({
                current_branch => 'current_branch_code',
                item_home_branch => 'item_home_branch',
                item_holding_branch => 'item_holding_branch'
});

Helper function that determines the branch to be used to apply the rule.

=cut

sub _choose_branch {

    my $self = shift;
    my $param = shift;

    my $behaviour = C4::Context->preference( 'RefundLostOnReturnControl' ) // 'CheckinLibrary';

    my $param_mapping = {
           CheckinLibrary => 'current_branch',
           ItemHomeBranch => 'item_home_branch',
        ItemHoldingBranch => 'item_holding_branch'
    };

    my $branch = $param->{ $param_mapping->{ $behaviour } };

    if ( !defined $branch ) {
        Koha::Exceptions::MissingParameter->throw(
            "$behaviour requires the " .
            $param_mapping->{ $behaviour } .
            " param"
        );
    }

    return $branch;
}

=head3 _default_rule (internal)

This function returns the default rule defined for refunding lost
item fees on return.

=cut

sub _default_rule {
    my $self = shift;

    return $self->find({ branchcode => '*' })->refund;
}

1;
