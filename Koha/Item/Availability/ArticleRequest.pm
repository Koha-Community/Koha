package Koha::Item::Availability::ArticleRequest;

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

use base qw(Koha::Item::Availability);

use Koha::Items;
use Koha::Patrons;

use Koha::Availability::Checks::Biblioitem;
use Koha::Availability::Checks::IssuingRule;
use Koha::Availability::Checks::Item;
use Koha::Availability::Checks::Patron;

=head1 NAME

Koha::Item::Availability::ArticleRequest - Koha Item Article Request Availability object class

=head1 SYNOPSIS

my $requestable = Koha::Item::Availability::ArticleRequest->new({
    item => $item,               # which item this availability is for
    patron => $patron,           # check item availability for this patron
})

=head1 DESCRIPTION

Class for checking item article request availability.

This class contains different levels of "recipes" that determine whether or not
an item should be considered available.

=head2 Class Methods

=cut

=head3 new

Constructs an item article request availability object. Item is always required. Patron is
required if patron related checks are needed.

MANDATORY PARAMETERS

    item (or itemnumber)

Item is a Koha::Item -object.

OPTIONAL PARAMETERS

    patron (or borrowernumber)
    to_branch

Patron is a Koha::Patron -object. To_branch is a branchcode of pickup library.

Returns a Koha::Item::Availability::ArticleRequest -object.

=cut

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    # Additionally, consider any transfer limits to pickup library by
    # providing to_branch parameter with branchcode of pickup library
    $self->{'to_branch'} = $params->{'to_branch'};

    return $self;
}

sub in_intranet {
    my ($self) = @_;
    my $reason;

    $self->reset;

    my $patron;
    unless ($patron = $self->patron) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'Missing parameter patron. This level of availability query '
            .'requires Koha::Item::Availability::ArticleRequest to have a patron parameter.'
        );
    }

    $self->common_biblio_checks;
    $self->common_biblioitem_checks;
    $self->common_issuing_rule_checks;
    $self->common_item_checks;
    $self->common_library_item_rule_checks;
    $self->common_patron_checks;

    return $self;
}

sub in_opac {
    my ($self) = @_;
    my $reason;

    $self->reset;

    $self->common_biblio_checks;
    $self->common_biblioitem_checks;
    $self->common_issuing_rule_checks;
    $self->common_item_checks;
    $self->common_library_item_rule_checks;
    $self->common_patron_checks;
    $self->opac_specific_issuing_rule_checks;

    return $self;
}

=head3 common_biblio_checks

Common checks for both OPAC and intranet.

=cut

sub common_biblio_checks {
    my ($self, $biblio) = @_;

    return $self;
}

=head3 common_biblioitem_checks

Common checks for both OPAC and intranet.

=cut

sub common_biblioitem_checks {
    my ($self, $bibitem) = @_;
    my $reason;

    unless ($bibitem) {
        $bibitem = Koha::Biblioitems->find($self->item->biblioitemnumber);
    }

    my $bibitemcalc = Koha::Availability::Checks::Biblioitem->new($bibitem);

    return $self unless $self->patron;

    if ($reason = $bibitemcalc->age_restricted($self->patron)) {
        $self->unavailable($reason);
    }

    return $self;
}

=head3 common_issuing_rule_checks

Common checks for both OPAC and intranet.

=cut

sub common_issuing_rule_checks {
    my ($self, $params) = @_;
    my $reason;

    my $item = $self->item;
    my $patron = $self->patron;
    my $branchcode = $params->{'branchcode'} ? $params->{'branchcode'}
                : $self->_get_reservescontrol_branchcode($item, $patron);
    my $args = {
        item => $item,
        branchcode => $branchcode,
        use_cache => $params->{'use_cache'},
    };
    $args->{patron} = $patron if $patron;
    my $rulecalc = Koha::Availability::Checks::IssuingRule->new($args);

    if ($reason = $rulecalc->no_article_requests_allowed) {
        $self->unavailable($reason);
    }

    return $self;
}

=head3 common_item_checks

Common checks for both OPAC and intranet.

=cut

sub common_item_checks {
    my ($self, $params) = @_;
    my $reason;

    return $self unless $self->item;

    my $item = $self->item;
    my $patron = $self->patron;
    my $itemcalc = Koha::Availability::Checks::Item->new($item);

    $self->unavailable($reason) if $reason = $itemcalc->checked_out;
    $self->unavailable($reason) if $reason = $itemcalc->damaged;
    $self->unavailable($reason) if $reason = $itemcalc->lost;
    $self->unavailable($reason) if $reason = $itemcalc->restricted;
    $self->unavailable($reason) if $reason = $itemcalc->withdrawn;
    if ($reason = $itemcalc->notforloan) {
        unless ($reason->status < 0) {
            $self->unavailable($reason);
        } else {
            $self->note($reason);
        }
    }

    $self->unavailable($reason) if $reason = $itemcalc->from_another_library;
    if ($self->to_branch && ($reason = $itemcalc->transfer_limit($self->to_branch))) {
        $self->unavailable($reason);
    }

    return $self;
}

=head3 common_library_item_rule_checks

Common checks for both OPAC and intranet.

=cut

sub common_library_item_rule_checks {
    my ($self) = @_;

    return $self;
}

=head3 common_patron_checks

Common checks for both OPAC and intranet.

=cut

sub common_patron_checks {
    my ($self) = @_;
    my $reason;

    return $self unless $self->patron;

    my $patron = $self->patron;
    my $patroncalc = Koha::Availability::Checks::Patron->new($patron);

    $self->unavailable($reason) if $reason = $patroncalc->debt_hold;
    $self->unavailable($reason) if $reason = $patroncalc->debarred;
    $self->unavailable($reason) if $reason = $patroncalc->gonenoaddress;
    $self->unavailable($reason) if $reason = $patroncalc->lost;
    if (($reason = $patroncalc->expired)
        && C4::Context->preference('BlockExpiredPatronOpacActions')) {
        $self->unavailable($reason);
    }

    return $self;
}

=head3 opac_specific_checks

OPAC-specific requestability checks.

=cut

sub opac_specific_issuing_rule_checks {
    my ($self, $branchcode) = @_;
    my $reason;

    my $item = $self->item;
    my $patron = $self->patron;
    $branchcode ||= $self->_get_reservescontrol_branchcode($item, $patron);
    my $args = {
        item => $item,
        branchcode => $branchcode,
    };
    $args->{patron} = $patron if $patron;
    my $rulecalc = Koha::Availability::Checks::IssuingRule->new($args);
    if ($reason = $rulecalc->opac_item_level_article_request_forbidden) {
        $self->unavailable($reason);
    }

    return $self;
}


sub _get_reservescontrol_branchcode {
    my ($self, $item, $patron) = @_;

    my $branchcode;
    my $controlbranch = C4::Context->preference('ReservesControlBranch');
    if ($patron && $controlbranch eq 'PatronLibrary') {
        $branchcode = $patron->branchcode;
    } elsif ($item && $controlbranch eq 'ItemHomeLibrary') {
        $branchcode = $item->homebranch;
    } elsif ($controlbranch eq 'PickupLibrary' && C4::Context->userenv
             && C4::Context->userenv->{'branch'}) {
        $branchcode = C4::Context->userenv->{'branch'}
    }
    return $branchcode;
}

1;
