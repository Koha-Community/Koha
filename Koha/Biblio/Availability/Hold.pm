package Koha::Biblio::Availability::Hold;

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

use base qw(Koha::Biblio::Availability);

use Koha::Item::Availability::Hold;

=head1 NAME

Koha::Biblio::Availability::Hold - Koha Biblio Availability Hold object class

=head1 SYNOPSIS

my $holdability = Koha::Biblio::Availability::Hold->new({
    biblio => $biblio,      # which biblio this availability is for
    patron => $patron,      # check biblio availability for this patron
})

=head1 DESCRIPTION

Class for checking biblio hold availability.

This class contains different levels of "recipes" that determine whether or not
a biblio should be considered available.

=head2 Class Methods

=cut

=head3 new

Constructs an biblio hold availability object. Biblio is always required.

MANDATORY PARAMETERS

    biblio (or biblionumber)

Biblio is a Koha::Biblio -object.

OPTIONAL PARAMETERS

    patron (or borrowernumber)
    to_branch
    limit (check only first n available items)

Patron is a Koha::Patron -object. To_branch is a branchcode of pickup location.

Returns a Koha::Biblio::Availability::Hold -object.

=cut

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    # Additionally, consider any transfer limits to pickup library by
    # providing to_branch parameter with branchcode of pickup library
    $self->{'to_branch'} = $params->{'to_branch'};
    # Check only first n available items by providing the value of n
    # in parameter 'limit'.
    $self->{'limit'} = $params->{'limit'};

    return $self;
}

sub in_intranet {
    my ($self, $params) = @_;

    $self->reset;

    my $patron;
    unless ($patron = $self->patron) {
        Koha::Exceptions::MissingParameter->throw(
            error => 'Missing parameter patron. This level of availability query '
            .'requires Koha::Biblio::Availability::Hold to have a patron parameter.'
        );
    }

    $params->{'intranet'} = 1;
    # Item looper
    $self->_item_looper($params);

    return $self;
}

sub in_opac {
    my ($self, $params) = @_;

    $self->reset;

    my $patron;

    # Check if holds are allowed in OPAC
    if (!C4::Context->preference('RequestOnOpac')) {
        $self->unavailable(Koha::Exceptions::Hold::NotAllowedInOPAC->new);
        return $self;
    } else {
        # Item looper
        $self->_item_looper($params);
    }

    return $self;
}

sub _item_looper {
    my ($self, $params) = @_;

    my $patron = $self->patron;
    my $biblio = $self->biblio;
    my $biblioitem = $self->biblio->biblioitem;
    my @items = $self->biblio->items;
    my @hostitemnumbers = C4::Items::get_hostitemnumbers_of($biblio->biblionumber);
    if (@hostitemnumbers) {
        my @hostitems = Koha::Items->search({
            itemnumber => { 'in' => @hostitemnumbers }
        });
        push @items, @hostitems;
    }

    if (scalar(@items) == 0) {
        $self->unavailable(Koha::Exceptions::Biblio::NoAvailableItems->new);
        return;
    }

    # Since we only need to check some patron and biblio related availability
    # checks once, do it outside the actual loop. To avoid code duplication,
    # use same checks as item availability calculation is using. Use the first
    # item to check these.
    my $first_item = $items[0];
    my $first_item_avail = Koha::Item::Availability::Hold->new({
        item => $first_item,
        patron => $patron,
    });
    $first_item_avail->common_biblio_checks($biblio);
    $first_item_avail->common_biblioitem_checks($biblioitem);
    $first_item_avail->common_patron_checks;
    if (keys %{$first_item_avail->unavailabilities} > 0) {
        $self->available(0);
    }
    $self->unavailabilities($first_item_avail->unavailabilities);
    $self->confirmations($first_item_avail->confirmations);
    $self->notes($first_item_avail->notes);

    # If we are looping in intranet, we can override any unavailabilities
    my $intranet = $params->{'intranet'} ? 1:0;
    my $override = 0;
    if ($intranet && C4::Context->preference('AllowHoldPolicyOverride')) {
        $override = 1;
    }

    # Stop calculating item availabilities after $limit available items are found.
    # E.g. parameter 'limit' with value 1 will find only one available item and
    # return biblio as available if no other unavailabilities are found. If you
    # want to calculate availability of every item in this biblio, do not give this
    # parameter.
    my $limit = $self->limit ? $self->limit : $params->{'limit'};
    my $count = 0;

    my @holds = Koha::Holds->search({
        biblionumber => $biblio->biblionumber,
        borrowernumber => $patron->borrowernumber,
    })->as_list if $patron;

    my @nonfound_holds = Koha::Holds->search({
        biblionumber => $biblio->biblionumber,
        found => undef,
        borrowernumber => $patron->borrowernumber,
    })->as_list if $patron;
    $self->{'hold_queue_length'} = scalar(@holds) || 0;
    foreach my $item (@items) {
        # Break out of loop after $limit items are found available
        if (defined $limit && @{$self->{'item_availabilities'}} >= $limit) {
            last;
        }
        my $item_availability = $self->_item_check($item, $patron, \@holds, \@nonfound_holds, $intranet, $override);
        if ($item_availability->available) {
            push @{$self->{'item_availabilities'}}, $item_availability;
            $count++;
        } else {
            my $unavails = $item_availability->unavailabilities;
            # If Item level hold is not allowed and it is the only unavailability
            # reason, push the item to item_availabilities.
            if ($item_availability->unavailable == 1 && exists
                $unavails->{'Koha::Exceptions::Hold::ItemLevelHoldNotAllowed'}){
                push @{$self->{'item_availabilities'}}, $item_availability;
            } else {
                push @{$self->{'item_unavailabilities'}}, $item_availability;
            }
        }
    }

    # After going through items, if none are found available, set the biblio
    # unavailable
    if (@{$self->{'item_availabilities'}} == 0) {
        $self->unavailable(Koha::Exceptions::Biblio::NoAvailableItems->new);
    }

    return $self;
}

sub _item_check {
    my ($self, $item, $patron, $holds, $nonfound_holds, $intranet, $override) = @_;

    my $item_availability = Koha::Item::Availability::Hold->new({
        item => $item,
        patron => $patron,
        to_branch => $self->to_branch,
    });

    # Check availability without considering patron, biblio and bibitem
    # restrictions, since they only need to be checked once.
    $item_availability->common_issuing_rule_checks({
        use_cache => 1,
        nonfound_holds => $nonfound_holds
    });
    $item_availability->common_item_checks({ holds => $holds });
    $item_availability->common_library_item_rule_checks;

    unless ($intranet) {
        $item_availability->opac_specific_issuing_rule_checks;
    }
    if ($override) {
        # If in intranet and AllowHoldPolicyOverride is enabled, convert
        # unavailabilities into confirmations.
        $item_availability->confirmations({
            %{$item_availability->unavailabilities},
            %{$item_availability->confirmations}
        });
        $item_availability->unavailabilities({});
        $item_availability->available(1);
    }
    return $item_availability;
}

1;
