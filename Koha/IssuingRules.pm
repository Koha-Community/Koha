package Koha::IssuingRules;

# Copyright Vaara-kirjastot 2015
# Copyright Koha Development Team 2016
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
use Koha::Caches;

use Koha::IssuingRule;

use base qw(Koha::Objects);

use constant GUESSED_ITEMTYPES_KEY => 'Koha_IssuingRules_last_guess';

=head1 NAME

Koha::IssuingRules - Koha IssuingRule Object set class

=head1 API

=head2 Class Methods

=cut

sub get_effective_issuing_rule {
    my ( $self, $params ) = @_;

    my $default      = '*';
    my $categorycode = $params->{categorycode};
    my $itemtype     = $params->{itemtype};
    my $branchcode   = $params->{branchcode};

    my $search_categorycode = $default;
    my $search_itemtype     = $default;
    my $search_branchcode   = $default;

    if ($categorycode) {
        $search_categorycode = { 'in' => [ $categorycode, $default ] };
    }
    if ($itemtype) {
        $search_itemtype = { 'in' => [ $itemtype, $default ] };
    }
    if ($branchcode) {
        $search_branchcode = { 'in' => [ $branchcode, $default ] };
    }

    my $rule = $self->search({
        categorycode => $search_categorycode,
        itemtype     => $search_itemtype,
        branchcode   => $search_branchcode,
    }, {
        order_by => {
            -desc => ['branchcode', 'categorycode', 'itemtype']
        },
        rows => 1,
    })->single;
    return $rule;
}

=head3 get_opacitemholds_policy

my $can_place_a_hold_at_item_level = Koha::IssuingRules->get_opacitemholds_policy( { patron => $patron, item => $item } );

Return 'Y' or 'F' if the patron can place a hold on this item according to the issuing rules
and the "Item level holds" (opacitemholds).
Can be 'N' - Don't allow, 'Y' - Allow, and 'F' - Force

=cut

sub get_opacitemholds_policy {
    my ( $class, $params ) = @_;

    my $item   = $params->{item};
    my $patron = $params->{patron};

    return unless $item or $patron;

    my $issuing_rule = Koha::IssuingRules->get_effective_issuing_rule(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->effective_itemtype,
            branchcode   => $item->homebranch,
        }
    );

    return $issuing_rule ? $issuing_rule->opacitemholds : undef;
}

=head3 get_onshelfholds_policy

    my $on_shelf_holds = Koha::IssuingRules->get_onshelfholds_policy({ item => $item, patron => $patron });

=cut

sub get_onshelfholds_policy {
    my ( $class, $params ) = @_;
    my $item = $params->{item};
    my $itemtype = $item->effective_itemtype;
    my $patron = $params->{patron};
    my $issuing_rule = Koha::IssuingRules->get_effective_issuing_rule(
        {
            ( $patron ? ( categorycode => $patron->categorycode ) : () ),
            itemtype   => $itemtype,
            branchcode => $item->holdingbranch
        }
    );
    return $issuing_rule ? $issuing_rule->onshelfholds : undef;
}

=head3 article_requestable_rules

    Return rules that allow article requests, optionally filtered by
    patron categorycode.

    Use with care; see guess_article_requestable_itemtypes.

=cut

sub article_requestable_rules {
    my ( $class, $params ) = @_;
    my $category = $params->{categorycode};

    return if !C4::Context->preference('ArticleRequests');
    return $class->search({
        $category ? ( categorycode => [ $category, '*' ] ) : (),
        article_requests => { '!=' => 'no' },
    });
}

=head3 guess_article_requestable_itemtypes

    Return item types in a hashref that are likely possible to be
    'article requested'. Constructed by an intelligent guess in the
    issuing rules (see article_requestable_rules).

    Note: pref ArticleRequestsLinkControl overrides the algorithm.

    Optional parameters: categorycode.

    Note: the routine is used in opac-search to obtain a reasonable
    estimate within performance borders (not looking at all items but
    just using default itemtype). Also we are not looking at the
    branchcode here, since home or holding branch of the item is
    leading and branch may be unknown too (anonymous opac session).

=cut

sub guess_article_requestable_itemtypes {
    my ( $class, $params ) = @_;
    my $category = $params->{categorycode};
    return {} if !C4::Context->preference('ArticleRequests');
    return { '*' => 1 } if C4::Context->preference('ArticleRequestsLinkControl') eq 'always';

    my $cache = Koha::Caches->get_instance;
    my $last_article_requestable_guesses = $cache->get_from_cache(GUESSED_ITEMTYPES_KEY);
    my $key = $category || '*';
    return $last_article_requestable_guesses->{$key}
        if $last_article_requestable_guesses && exists $last_article_requestable_guesses->{$key};

    my $res = {};
    my $rules = $class->article_requestable_rules({
        $category ? ( categorycode => $category ) : (),
    });
    return $res if !$rules;
    foreach my $rule ( $rules->as_list ) {
        $res->{ $rule->itemtype } = 1;
    }
    $cache->set_in_cache(GUESSED_ITEMTYPES_KEY, $res);
    return $res;
}

=head3 type

=cut

sub _type {
    return 'Issuingrule';
}

sub object_class {
    return 'Koha::IssuingRule';
}

1;
