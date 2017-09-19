package Koha::Biblio;

# Copyright ByWater Solutions 2014
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

use Carp;

use C4::Biblio qw();

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use base qw(Koha::Object);

use Koha::Items;
use Koha::Biblioitems;
use Koha::ArticleRequests;
use Koha::ArticleRequest::Status;
use Koha::IssuingRules;
use Koha::Item::Transfer::Limits;
use Koha::Libraries;
use Koha::Subscriptions;

=head1 NAME

Koha::Biblio - Koha Biblio Object class

=head1 API

=head2 Class Methods

=cut

=head3 store

Overloaded I<store> method to set default values

=cut

sub store {
    my ( $self ) = @_;

    $self->datecreated( dt_from_string ) unless $self->datecreated;

    return $self->SUPER::store;
}

=head3 subtitles

my @subtitles = $biblio->subtitles();

Returns list of subtitles for a record.

Keyword to MARC mapping for subtitle must be set for this method to return any possible values.

=cut

sub subtitles {
    my ( $self ) = @_;

    return map { $_->{subfield} } @{
        C4::Biblio::GetRecordValue(
            'subtitle',
            C4::Biblio::GetMarcBiblio({ biblionumber => $self->id }),
            $self->frameworkcode ) };
}

=head3 can_article_request

my $bool = $biblio->can_article_request( $borrower );

Returns true if article requests can be made for this record

$borrower must be a Koha::Patron object

=cut

sub can_article_request {
    my ( $self, $borrower ) = @_;

    my $rule = $self->article_request_type($borrower);
    return q{} if $rule eq 'item_only' && !$self->items()->count();
    return 1 if $rule && $rule ne 'no';

    return q{};
}

=head3 can_be_transferred

$biblio->can_be_transferred({ to => $to_library, from => $from_library })

Checks if at least one item of a biblio can be transferred to given library.

This feature is controlled by two system preferences:
UseBranchTransferLimits to enable / disable the feature
BranchTransferLimitsType to use either an itemnumber or ccode as an identifier
                         for setting the limitations

Performance-wise, it is recommended to use this method for a biblio instead of
iterating each item of a biblio with Koha::Item->can_be_transferred().

Takes HASHref that can have the following parameters:
    MANDATORY PARAMETERS:
    $to   : Koha::Library
    OPTIONAL PARAMETERS:
    $from : Koha::Library # if given, only items from that
                          # holdingbranch are considered

Returns 1 if at least one of the item of a biblio can be transferred
to $to_library, otherwise 0.

=cut

sub can_be_transferred {
    my ($self, $params) = @_;

    my $to   = $params->{to};
    my $from = $params->{from};

    return 1 unless C4::Context->preference('UseBranchTransferLimits');
    my $limittype = C4::Context->preference('BranchTransferLimitsType');

    my $items;
    foreach my $item_of_bib ($self->items) {
        next unless $item_of_bib->holdingbranch;
        next if $from && $from->branchcode ne $item_of_bib->holdingbranch;
        return 1 if $item_of_bib->holdingbranch eq $to->branchcode;
        my $code = $limittype eq 'itemtype'
            ? $item_of_bib->effective_itemtype
            : $item_of_bib->ccode;
        return 1 unless $code;
        $items->{$code}->{$item_of_bib->holdingbranch} = 1;
    }

    # At this point we will have a HASHref containing each itemtype/ccode that
    # this biblio has, inside which are all of the holdingbranches where those
    # items are located at. Then, we will query Koha::Item::Transfer::Limits to
    # find out whether a transfer limits for such $limittype from any of the
    # listed holdingbranches to the given $to library exist. If at least one
    # holdingbranch for that $limittype does not have a transfer limit to given
    # $to library, then we know that the transfer is possible.
    foreach my $code (keys %{$items}) {
        my @holdingbranches = keys %{$items->{$code}};
        return 1 if Koha::Item::Transfer::Limits->search({
            toBranch => $to->branchcode,
            fromBranch => { 'in' => \@holdingbranches },
            $limittype => $code
        }, {
            group_by => [qw/fromBranch/]
        })->count == scalar(@holdingbranches) ? 0 : 1;
    }

    return 0;
}

=head3 article_request_type

my $type = $biblio->article_request_type( $borrower );

Returns the article request type based on items, or on the record
itself if there are no items.

$borrower must be a Koha::Patron object

=cut

sub article_request_type {
    my ( $self, $borrower ) = @_;

    return q{} unless $borrower;

    my $rule = $self->article_request_type_for_items( $borrower );
    return $rule if $rule;

    # If the record has no items that are requestable, go by the record itemtype
    $rule = $self->article_request_type_for_bib($borrower);
    return $rule if $rule;

    return q{};
}

=head3 article_request_type_for_bib

my $type = $biblio->article_request_type_for_bib

Returns the article request type 'yes', 'no', 'item_only', 'bib_only', for the given record

=cut

sub article_request_type_for_bib {
    my ( $self, $borrower ) = @_;

    return q{} unless $borrower;

    my $borrowertype = $borrower->categorycode;
    my $itemtype     = $self->itemtype();

    my $issuing_rule = Koha::IssuingRules->get_effective_issuing_rule({ categorycode => $borrowertype, itemtype => $itemtype });

    return q{} unless $issuing_rule;
    return $issuing_rule->article_requests || q{}
}

=head3 article_request_type_for_items

my $type = $biblio->article_request_type_for_items

Returns the article request type 'yes', 'no', 'item_only', 'bib_only', for the given record's items

If there is a conflict where some items are 'bib_only' and some are 'item_only', 'bib_only' will be returned.

=cut

sub article_request_type_for_items {
    my ( $self, $borrower ) = @_;

    my $counts;
    foreach my $item ( $self->items()->as_list() ) {
        my $rule = $item->article_request_type($borrower);
        return $rule if $rule eq 'bib_only';    # we don't need to go any further
        $counts->{$rule}++;
    }

    return 'item_only' if $counts->{item_only};
    return 'yes'       if $counts->{yes};
    return 'no'        if $counts->{no};
    return q{};
}

=head3 article_requests

my @requests = $biblio->article_requests

Returns the article requests associated with this Biblio

=cut

sub article_requests {
    my ( $self, $borrower ) = @_;

    $self->{_article_requests} ||= Koha::ArticleRequests->search( { biblionumber => $self->biblionumber() } );

    return wantarray ? $self->{_article_requests}->as_list : $self->{_article_requests};
}

=head3 article_requests_current

my @requests = $biblio->article_requests_current

Returns the article requests associated with this Biblio that are incomplete

=cut

sub article_requests_current {
    my ( $self, $borrower ) = @_;

    $self->{_article_requests_current} ||= Koha::ArticleRequests->search(
        {
            biblionumber => $self->biblionumber(),
            -or          => [
                { status => Koha::ArticleRequest::Status::Pending },
                { status => Koha::ArticleRequest::Status::Processing }
            ]
        }
    );

    return wantarray ? $self->{_article_requests_current}->as_list : $self->{_article_requests_current};
}

=head3 article_requests_finished

my @requests = $biblio->article_requests_finished

Returns the article requests associated with this Biblio that are completed

=cut

sub article_requests_finished {
    my ( $self, $borrower ) = @_;

    $self->{_article_requests_finished} ||= Koha::ArticleRequests->search(
        {
            biblionumber => $self->biblionumber(),
            -or          => [
                { status => Koha::ArticleRequest::Status::Completed },
                { status => Koha::ArticleRequest::Status::Canceled }
            ]
        }
    );

    return wantarray ? $self->{_article_requests_finished}->as_list : $self->{_article_requests_finished};
}

=head3 items

my @items = $biblio->items();
my $items = $biblio->items();

Returns the related Koha::Items object for this biblio in scalar context,
or list of Koha::Item objects in list context.

=cut

sub items {
    my ($self) = @_;

    $self->{_items} ||= Koha::Items->search( { biblionumber => $self->biblionumber() } );

    return wantarray ? $self->{_items}->as_list : $self->{_items};
}

=head3 itemtype

my $itemtype = $biblio->itemtype();

Returns the itemtype for this record.

=cut

sub itemtype {
    my ( $self ) = @_;

    return $self->biblioitem()->itemtype();
}

=head3 holds

my $holds = $biblio->holds();

return the current holds placed on this record

=cut

sub holds {
    my ( $self, $params, $attributes ) = @_;
    $attributes->{order_by} = 'priority' unless exists $attributes->{order_by};
    my $hold_rs = $self->_result->reserves->search( $params, $attributes );
    return Koha::Holds->_new_from_dbic($hold_rs);
}

=head3 current_holds

my $holds = $biblio->current_holds

Return the holds placed on this bibliographic record.
It does not include future holds.

=cut

sub current_holds {
    my ($self) = @_;
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    return $self->holds(
        { reservedate => { '<=' => $dtf->format_date(dt_from_string) } } );
}

=head3 biblioitem

my $field = $self->biblioitem()->itemtype

Returns the related Koha::Biblioitem object for this Biblio object

=cut

sub biblioitem {
    my ($self) = @_;

    $self->{_biblioitem} ||= Koha::Biblioitems->find( { biblionumber => $self->biblionumber() } );

    return $self->{_biblioitem};
}

=head3 subscriptions

my $subscriptions = $self->subscriptions

Returns the related Koha::Subscriptions object for this Biblio object

=cut

sub subscriptions {
    my ($self) = @_;

    $self->{_subscriptions} ||= Koha::Subscriptions->search( { biblionumber => $self->biblionumber } );

    return $self->{_subscriptions};
}

=head3 has_items_waiting_or_intransit

my $itemsWaitingOrInTransit = $biblio->has_items_waiting_or_intransit

Tells if this bibliographic record has items waiting or in transit.

=cut

sub has_items_waiting_or_intransit {
    my ( $self ) = @_;

    if ( Koha::Holds->search({ biblionumber => $self->id,
                               found => ['W', 'T'] })->count ) {
        return 1;
    }

    foreach my $item ( $self->items ) {
        return 1 if $item->get_transfer;
    }

    return 0;
}

=head3 type

=cut

sub _type {
    return 'Biblio';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
