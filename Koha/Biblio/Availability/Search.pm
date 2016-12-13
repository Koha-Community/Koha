package Koha::Biblio::Availability::Search;

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

use Koha::Item::Availability::Search;

=head1 NAME

Koha::Biblio::Availability::Search - Koha Biblio Availability Search object class

=head1 SYNOPSIS

my $searchability = Koha::Biblio::Availability::Search->new({
    biblio => $biblio,      # which biblio this availability is for
})

=head1 DESCRIPTION

Class for checking biblio search availability.

This class contains subroutines to determine biblio's availability for search
result in different contexts.

=head2 Class Methods

=cut

=head3 new

Constructs an biblio search availability object. Biblio is always required.

MANDATORY PARAMETERS

    biblio (or biblionumber)

Biblio is a Koha::Biblio -object.

OPTIONAL PARAMETERS

Returns a Koha::Biblio::Availability::Search -object.

=cut

sub new {
    my ($class, $params) = @_;

    my $self = $class->SUPER::new($params);

    return $self;
}

sub in_intranet {
    my ($self, $params) = @_;

    $self->reset;

    # Item looper
    $self->_item_looper($params);

    return $self;
}

sub in_opac {
    my ($self, $params) = @_;

    $self->reset;

    $params->{'opac'} = 1;

    # Item looper
    $self->_item_looper($params);

    return $self;
}

sub _item_looper {
    my ($self, $params) = @_;

    my @items = $self->biblio->items;
    my @hostitemnumbers = C4::Items::get_hostitemnumbers_of($self->biblio->biblionumber);
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

    my $opac = $params->{'opac'} ? 1:0;
    my $hidelostitems = 0;
    if (!$opac) {
        $hidelostitems = C4::Context->preference('hidelostitems');
    }

    # Stop calculating item availabilities after $limit available items are found.
    # E.g. parameter 'limit' with value 1 will find only one available item and
    # return biblio as available if no other unavailabilities are found. If you
    # want to calculate availability of every item in this biblio, do not give this
    # parameter.
    my $limit = $params->{'limit'};
    my $avoid_queries_after = $params->{'MaxSearchResultsItemsPerRecordStatusCheck'}
    ? C4::Context->preference('MaxSearchResultsItemsPerRecordStatusCheck') : undef;
    my $count = 0;
    foreach my $item (@items) {
        # Break out of loop after $limit items are found available
        if (defined $limit && @{$self->{'item_availabilities'}} >= $limit) {
            last;
        }

        my $item_availability = Koha::Item::Availability::Search->new({
            item => $item,
        });
        if ($params->{'MaxSearchResultsItemsPerRecordStatusCheck'} &&
                $count >= $avoid_queries_after) {
            # A couple heuristics to limit how many times
            # we query the database for item transfer information, sacrificing
            # accuracy in some cases for speed;
            #
            # 1. don't query if item has one of the other statuses (done inside
            #    item availability calculation)
            # 2. don't check holds status if ignore_holds parameter is given
            # 3. don't check transfer status if ignore_transfer parameter is given
            $params->{'ignore_holds'} = 1;
            $params->{'ignore_transfer'} = 1;
        }
        if ($opac) {
            $item_availability = $item_availability->in_opac($params);
            my $unavails = $item_availability->unavailabilities;
            # Hide item in OPAC context if system preference hidelostitems is
            # enabled.
            my $lost = exists $unavails->{'Koha::Exceptions::Item::Lost'};
            if ($hidelostitems && $lost) {
                next;
            }
        } else {
            $item_availability = $item_availability->in_intranet($params);
        }
        if ($item_availability->available) {
            push @{$self->{'item_availabilities'}}, $item_availability;
        } else {
            push @{$self->{'item_unavailabilities'}}, $item_availability;
        }
        $count++;
    }

    # After going through items, if none are found available, set the biblio
    # unavailable
    if (@{$self->{'item_availabilities'}} == 0) {
        $self->unavailable(Koha::Exceptions::Biblio::NoAvailableItems->new);
    }

    return $self;
}

1;
