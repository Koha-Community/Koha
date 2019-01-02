package Koha::Availability::Checks::IssuingRule;

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

use base qw(Koha::Availability::Checks);

use C4::Circulation;
use C4::Context;
use C4::Reserves;

use Koha::IssuingRules;
use Koha::Items;
use Koha::Logger;

use Koha::Exceptions;
use Koha::Exceptions::ArticleRequest;
use Koha::Exceptions::Checkout;
use Koha::Exceptions::Hold;

=head3 new

OPTIONAL PARAMETERS:

* categorycode      Attempts to match issuing rule with given categorycode
* rule_itemtype     Attempts to match issuing rule with given itemtype
* branchcode        Attempts to match issuing rule with given branchcode

* patron            Stores patron into the object for reusability. Also
                    attempts to match issuing rule with item's itemtype
                    unless specificed with "rule_itemtype" parameter.
* item              stores item into the object for reusability. Also
                    Attempts to match issuing rule with patron's categorycode
                    unless specified with "categorycode" parameter.
* biblioitem        Attempts to match issuing rule with itemtype from given
                    biblioitem as a fallback

Stores the effective issuing rule into class variable effective_issuing_rule
for reusability. This means the methods in this class are performed on the
stored effective issuing rule and multiple queries into issuingrules table
are avoided.

Caches issuing rule momentarily to help performance in biblio availability
calculation. This is helpful because a biblio may have multiple items matching
the same issuing rule and this lets us avoid multiple, unneccessary queries into
the issuingrule table.

=cut

sub new {
    my $class = shift;
    my ($params) = @_;

    my $self = $class->SUPER::new(@_);

    my $categorycode  = $params->{'categorycode'};
    my $rule_itemtype = $params->{'rule_itemtype'};
    my $branchcode    = $params->{'branchcode'};
    my $ccode         = $params->{'ccode'};
    my $permanent_location = $params->{'permanent_location'};
    my $sub_location  = $params->{'sub_location'};
    my $genre         = $params->{'genre'};
    my $circulation_level = $params->{'circulation_level'};
    my $reserve_level = $params->{'reserve_level'};

    my $patron     = $self->_validate_parameter($params,
                        'patron',     'Koha::Patron');
    my $item       = $self->_validate_parameter($params,
                        'item',       'Koha::Item');
    my $biblioitem = $self->_validate_parameter($params,
                        'biblioitem', 'Koha::Biblioitem');

    unless ($rule_itemtype) {
        $rule_itemtype = $item
            ? $item->effective_itemtype
            : $biblioitem
              ? $biblioitem->itemtype
              : undef;
    }
    unless ($categorycode) {
        $categorycode = $patron ? $patron->categorycode : undef;
    }
    unless ($ccode) {
        $ccode = $item ? $item->ccode : undef;
    }
    unless ($permanent_location) {
        $permanent_location = $item ? $item->permanent_location : undef;
    }
    unless ($sub_location) {
        $sub_location = $item ? $item->sub_location : undef;
    }
    unless ($genre) {
        $genre = $item ? $item->genre : undef;
    }
    unless ($circulation_level) {
        $circulation_level = $item ? $item->circulation_level : undef;
    }
    unless ($reserve_level) {
        $reserve_level = $item ? $item->reserve_level : undef;
    }

    if ($params->{'use_cache'}) {
        $self->{'use_cache'} = 1;
    } else {
        $self->{'use_cache'} = 0;
    }

    # Get a matching issuing rule
    my $rule;
    my $cache;
    if ($self->use_cache) {
        $cache = Koha::Caches->get_instance('availability');
        my $cached = $cache->get_from_cache('issuingrule-.'
                                .($categorycode?$categorycode:'*').'-'
                                .($rule_itemtype?$rule_itemtype:'*').'-'
                                .($branchcode?$branchcode:'*')
                                .($ccode?$ccode:'*').'-'
                                .($permanent_location?$permanent_location:'*').'-'
                                .($sub_location?$sub_location:'*').'-'
                                .($genre?$genre:'*').'-'
                                .($circulation_level?$circulation_level:'*').'-'
                                .($reserve_level?$reserve_level:'*'));
        if ($cached) {
            $rule = Koha::IssuingRule->new->set($cached);
        }
    }

    unless ($rule) {
        $rule = Koha::IssuingRules->get_effective_issuing_rule({
            categorycode => $categorycode,
            itemtype     => $rule_itemtype,
            branchcode   => $branchcode,
            ccode        => $ccode,
            permanent_location => $permanent_location,
            sub_location => $sub_location,
            genre        => $genre,
            circulation_level => $circulation_level,
            reserve_level => $reserve_level,
        });
        if ($rule && $self->use_cache) {
            $cache->set_in_cache('issuingrule-.'
                    .($categorycode?$categorycode:'*').'-'
                    .($rule_itemtype?$rule_itemtype:'*').'-'
                    .($branchcode?$branchcode:'*').'-'
                    .($ccode?$ccode:'*').'-'
                    .($permanent_location?$permanent_location:'*').'-'
                    .($sub_location?$sub_location:'*').'-'
                    .($genre?$genre:'*').'-'
                    .($circulation_level?$circulation_level:'*').'-'
                    .($reserve_level?$reserve_level:'*'),
                    $rule->unblessed, { expiry => 10 });
        }
    }

    my $logger = Koha::Logger->get;
    $logger->debug('Issuing Rule: ' . Data::Dumper::Dumper($rule->unblessed))
        if $rule;

    # Store effective issuing rule into object
    $self->{'effective_issuing_rule'} = $rule;
    # Store patron into object
    $self->{'patron'} = $patron;
    # Store item into object
    $self->{'item'} = $item;

    bless $self, $class;
}

=head3 maximum_checkouts_reached

Returns Koha::Exceptions::Checkout::MaximumCheckoutsReached if maximum number
of checkouts have been reached by patron.

=cut

sub maximum_checkouts_reached {
    my ($self, $item, $patron) = @_;

    return unless $patron ||= $self->patron;
    return unless $item ||= $self->item;

    my $item_unblessed = $item->unblessed;
    $item_unblessed->{'itemtype'} = $item->effective_itemtype;
    my $toomany = C4::Circulation::TooMany(
            $patron->unblessed,
            $item->biblionumber,
            $item_unblessed,
    );

    if ($toomany) {
        return Koha::Exceptions::Checkout::MaximumCheckoutsReached->new(
            error => $toomany->{reason},
            max_checkouts_allowed => 0+$toomany->{max_allowed},
            current_checkout_count => 0+$toomany->{count},
        );
    }
    return;
}

=head3 maximum_holds_for_record_reached

Returns Koha::Exceptions::Hold::MaximumHoldsForRecordReached if maximum number
of holds on biblio have been reached by patron.

Returns Koha::Exceptions::Hold::ZeroHoldsAllowed if no holds are allowed at all.

OPTIONAL PARAMETERS:
nonfound_holds      Allows you to pass Koha::Holds object to improve performance
                    by avoiding another query to reserves table.
                    (Found holds don't count against a patron's holds limit)
biblionumber        Allows you to specify biblionumber; if not given, item's
                    biblionumber will be used (recommended; but requires you to
                    provide item while instantiating this class).

=cut

sub maximum_holds_for_record_reached {
    my ($self, $params) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    return unless my $item = $self->item;

    my $biblionumber = $params->{'biblionumber'} ? $params->{'biblionumber'}
                : $item->biblionumber;
    if ($rule->holds_per_record > 0 && $rule->reservesallowed > 0) {
        my $holds_on_this_record;
        unless (exists $params->{'nonfound_holds'}) {
            $holds_on_this_record = Koha::Holds->search({
                borrowernumber => 0+$self->patron->borrowernumber,
                biblionumber   => 0+$biblionumber,
                found          => undef,
            })->count;
        } else {
            $holds_on_this_record = @{$params->{'nonfound_holds'}};
        }
        if ($holds_on_this_record >= $rule->holds_per_record) {
            return Koha::Exceptions::Hold::MaximumHoldsForRecordReached->new(
                max_holds_allowed => 0+$rule->holds_per_record,
                current_hold_count => 0+$holds_on_this_record,
            );
        }
    } else {
        return $self->zero_holds;
    }
    return;
}

=head3 maximum_holds_reached

Returns Koha::Exceptions::Hold::MaximumHoldsReached if maximum number
of holds have been reached by patron.

Returns Koha::Exceptions::Hold::ZeroHoldsAllowed if no holds are allowed at all.

=cut

sub maximum_holds_reached {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    my $rule_itemtype = $rule->itemtype;
    my $controlbranch = C4::Context->preference('ReservesControlBranch');
    if ($rule->holds_per_record > 0 && $rule->reservesallowed > 0) {
        # Get patron's hold count for holds that match the found issuing rule
        my $hold_count = $self->_patron_hold_count($rule_itemtype, $controlbranch);
        if ($hold_count >= $rule->reservesallowed) {
            return Koha::Exceptions::Hold::MaximumHoldsReached->new(
                max_holds_allowed => 0+$rule->reservesallowed,
                current_hold_count => 0+$hold_count,
            );
        }
    } else {
        return $self->zero_holds;
    }
    return;
}

=head3 on_shelf_holds_forbidden

Returns Koha::Exceptions::Hold::OnShelfNotAllowed if effective issuing rule
restricts on-shelf holds.

=cut

sub on_shelf_holds_forbidden {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    return unless my $item = $self->item;
    my $on_shelf_holds = $rule->onshelfholds;

    if ($on_shelf_holds == 0) {
        my $hold_waiting = Koha::Holds->search({
            found => 'W',
            itemnumber => 0+$item->itemnumber,
            priority => 0
        })->count;
        if (!$item->onloan && !$hold_waiting) {
            return Koha::Exceptions::Hold::OnShelfNotAllowed->new;
        }
        return;
    } elsif ($on_shelf_holds == 1) {
        return;
    } elsif ($on_shelf_holds == 2) {
        my @items = Koha::Items->search({ biblionumber => $item->biblionumber });

        my $any_available = 0;

        foreach my $i (@items) {
            unless ($i->itemlost
              || $i->notforloan > 0
              || $i->withdrawn
              || $i->onloan
              || C4::Reserves::IsItemOnHoldAndFound( $i->id )
              || ( $i->damaged
                && !C4::Context->preference('AllowHoldsOnDamagedItems') )
              || Koha::ItemTypes->find( $i->effective_itemtype() )->notforloan) {
                $any_available = 1;
                last;
            }
        }
        return Koha::Exceptions::Hold::OnShelfNotAllowed->new if $any_available;
    }
    return;
}

=head3 opac_item_level_hold_forbidden

Returns Koha::Exceptions::Hold::ItemLevelHoldNotAllowed if item-level holds are
forbidden in OPAC.

=cut

sub opac_item_level_hold_forbidden {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    if (defined $rule->opacitemholds && $rule->opacitemholds eq 'N') {
        return Koha::Exceptions::Hold::ItemLevelHoldNotAllowed->new;
    }
    return;
}

=head3 zero_checkouts_allowed

Returns Koha::Exceptions::Checkout::ZeroCheckoutsAllowed if checkouts are not
allowed at all.

=cut

sub zero_checkouts_allowed {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    if (defined $rule->maxissueqty && $rule->maxissueqty == 0) {
        return Koha::Exceptions::Checkout::ZeroCheckoutsAllowed->new;
    }
    return;
}

=head3 zero_holds_allowed

Returns Koha::Exceptions::Hold::ZeroHoldsAllowed if holds are not
allowed at all.

This will inspect both "reservesallowed" and "holds_per_record" value in effective
issuing rule.

=cut

sub zero_holds_allowed {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    if (defined $rule->reservesallowed && $rule->reservesallowed == 0
        || defined $rule->holds_per_record && $rule->holds_per_record == 0) {
        return Koha::Exceptions::Hold::ZeroHoldsAllowed->new;
    }
    return;
}

=head3 no_article_requests_allowed

Returns Koha::Exceptions::ArticleRequest::NotAllowed if article requests are not
allowed at all.

=cut

sub no_article_requests_allowed {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;

    if ($rule->article_requests eq 'no') {
        return Koha::Exceptions::ArticleRequest::NotAllowed->new;
    }

    return;
}

=head3 opac_bib_level_article_request_forbidden

Returns Koha::Exceptions::ArticleRequest::BibLevelRequestNotAllowed if biblio-level article requests are
forbidden in OPAC.

=cut

sub opac_bib_level_article_request_forbidden {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    if ($rule->article_requests ne 'yes' && $rule->article_requests ne 'bib_only') {
        return Koha::Exceptions::ArticleRequest::BibLevelRequestNotAllowed->new;
    }
    return;
}


=head3 opac_item_level_article_request_forbidden

Returns Koha::Exceptions::ArticleRequest::ItemLevelRequestNotAllowed if item-level article requests are
forbidden in OPAC.

=cut

sub opac_item_level_article_request_forbidden {
    my ($self) = @_;

    return unless my $rule = $self->effective_issuing_rule;
    if ($rule->article_requests ne 'yes' && $rule->article_requests ne 'item_only') {
        return Koha::Exceptions::ArticleRequest::ItemLevelRequestNotAllowed->new;
    }

    return;
}

sub _patron_hold_count {
    my ($self, $itemtype, $controlbranch) = @_;

    $itemtype ||= '*';
    my $branchcode;
    my $branchfield = 'me.branchcode';
    $controlbranch ||= C4::Context->preference('ReservesControlBranch');
    my $patron = $self->patron;
    if ($self->patron && $controlbranch eq 'PatronLibrary') {
        $branchfield = 'borrower.branchcode';
        $branchcode = $patron->branchcode;
    } elsif ($self->item && $controlbranch eq 'ItemHomeLibrary') {
        $branchfield = 'item.homebranch';
        $branchcode = $self->item->homebranch;
    }

    my $cache;
    if ($self->use_cache) {
        $cache = Koha::Caches->get_instance('availability');
        my $cached = $cache->get_from_cache('holds_of_'.$patron->borrowernumber.'-'
                                            .$itemtype.'-'.$branchcode);
        if (defined $cached) {
            return $cached;
        }
    }

    my $holds = Koha::Holds->search({
        'me.borrowernumber' => $patron->borrowernumber,
        $branchfield => $branchcode,
        '-and' => [
            '-or' => [
                $itemtype ne '*' && C4::Context->preference('item-level_itypes') == 1 ? [
                    { 'item.itype' => $itemtype },
                        { 'biblioitem.itemtype' => $itemtype }
                ] : [ { 'biblioitem.itemtype' => $itemtype } ]
            ]
        ]}, {
        join => ['borrower', 'biblioitem', 'item'],
        '+select' => [ 'borrower.branchcode', 'item.homebranch' ],
        '+as' => ['borrower.branchcode', 'item.homebranch' ]
    })->count;

    if ($self->use_cache) {
        $cache->set_in_cache('holds_of_'.$patron->borrowernumber.'-'
                    .$itemtype.'-'.$branchcode, $holds, { expiry => 10 });
    }

    return $holds;
}

sub _validate_parameter {
    my ($self, $params, $key, $ref) = @_;

    if (exists $params->{$key}) {
        if (ref($params->{$key}) eq $ref) {
            return $params->{$key};
        } else {
            Koha::Exceptions::BadParameter->throw(
                "Parameter $key must be a $ref object."
            );
        }
    }
}

1;
