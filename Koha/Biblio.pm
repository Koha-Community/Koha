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
use List::MoreUtils qw(any);
use URI;
use URI::Escape;

use C4::Koha;
use C4::Biblio qw();

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use base qw(Koha::Object);

use Koha::Acquisition::Orders;
use Koha::ArticleRequest::Status;
use Koha::ArticleRequests;
use Koha::Biblio::Metadatas;
use Koha::Biblioitems;
use Koha::CirculationRules;
use Koha::Item::Transfer::Limits;
use Koha::Items;
use Koha::Libraries;
use Koha::Suggestions;
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

=head3 metadata

my $metadata = $biblio->metadata();

Returns a Koha::Biblio::Metadata object

=cut

sub metadata {
    my ( $self ) = @_;

    my $metadata = $self->_result->metadata;
    return Koha::Biblio::Metadata->_new_from_dbic($metadata);
}

=head3 orders

my $orders = $biblio->orders();

Returns a Koha::Acquisition::Orders object

=cut

sub orders {
    my ( $self ) = @_;

    my $orders = $self->_result->orders;
    return Koha::Acquisition::Orders->_new_from_dbic($orders);
}

=head3 active_orders

my $active_orders = $biblio->active_orders();

Returns the active acquisition orders related to this biblio.
An order is considered active when it is not cancelled (i.e. when datecancellation
is not undef).

=cut

sub active_orders {
    my ( $self ) = @_;

    return $self->orders->search({ datecancellationprinted => undef });
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
    foreach my $item_of_bib ($self->items->as_list) {
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


=head3 pickup_locations

@pickup_locations = $biblio->pickup_locations( {patron => $patron } )

Returns possible pickup locations for this biblio items, according to patron's home library (if patron is defined and holds are allowed only from hold groups)
and if item can be transferred to each pickup location.

=cut

sub pickup_locations {
    my ($self, $params) = @_;

    my $patron = $params->{patron};

    my @pickup_locations;
    foreach my $item_of_bib ($self->items->as_list) {
        push @pickup_locations, $item_of_bib->pickup_locations( {patron => $patron} );
    }

    my %seen;
    @pickup_locations =
      grep { !$seen{ $_->branchcode }++ } @pickup_locations;

    return wantarray ? @pickup_locations : \@pickup_locations;
}

=head3 hidden_in_opac

my $bool = $biblio->hidden_in_opac({ [ rules => $rules ] })

Returns true if the biblio matches the hidding criteria defined in $rules.
Returns false otherwise.

Takes HASHref that can have the following parameters:
    OPTIONAL PARAMETERS:
    $rules : { <field> => [ value_1, ... ], ... }

Note: $rules inherits its structure from the parsed YAML from reading
the I<OpacHiddenItems> system preference.

=cut

sub hidden_in_opac {
    my ( $self, $params ) = @_;

    my $rules = $params->{rules} // {};

    my @items = $self->items->as_list;

    return 0 unless @items; # Do not hide if there is no item

    return !(any { !$_->hidden_in_opac({ rules => $rules }) } @items);
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

    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            rule_name    => 'article_requests',
            categorycode => $borrowertype,
            itemtype     => $itemtype,
        }
    );

    return q{} unless $rule;
    return $rule->rule_value || q{}
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

my $items = $biblio->items();

Returns the related Koha::Items object for this biblio

=cut

sub items {
    my ($self) = @_;

    my $items_rs = $self->_result->items;

    return Koha::Items->_new_from_dbic( $items_rs );
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

=head3 suggestions

my $suggestions = $self->suggestions

Returns the related Koha::Suggestions object for this Biblio object

=cut

sub suggestions {
    my ($self) = @_;

    my $suggestions_rs = $self->_result->suggestions;
    return Koha::Suggestions->_new_from_dbic( $suggestions_rs );
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

    foreach my $item ( $self->items->as_list ) {
        return 1 if $item->get_transfer;
    }

    return 0;
}

=head2 get_coins

my $coins = $biblio->get_coins;

Returns the COinS (a span) which can be included in a biblio record

=cut

sub get_coins {
    my ( $self ) = @_;

    my $record = $self->metadata->record;

    my $pos7 = substr $record->leader(), 7, 1;
    my $pos6 = substr $record->leader(), 6, 1;
    my $mtx;
    my $genre;
    my ( $aulast, $aufirst ) = ( '', '' );
    my @authors;
    my $title;
    my $hosttitle;
    my $pubyear   = '';
    my $isbn      = '';
    my $issn      = '';
    my $publisher = '';
    my $pages     = '';
    my $titletype = '';

    # For the purposes of generating COinS metadata, LDR/06-07 can be
    # considered the same for UNIMARC and MARC21
    my $fmts6 = {
        'a' => 'book',
        'b' => 'manuscript',
        'c' => 'book',
        'd' => 'manuscript',
        'e' => 'map',
        'f' => 'map',
        'g' => 'film',
        'i' => 'audioRecording',
        'j' => 'audioRecording',
        'k' => 'artwork',
        'l' => 'document',
        'm' => 'computerProgram',
        'o' => 'document',
        'r' => 'document',
    };
    my $fmts7 = {
        'a' => 'journalArticle',
        's' => 'journal',
    };

    $genre = $fmts6->{$pos6} ? $fmts6->{$pos6} : 'book';

    if ( $genre eq 'book' ) {
            $genre = $fmts7->{$pos7} if $fmts7->{$pos7};
    }

    ##### We must transform mtx to a valable mtx and document type ####
    if ( $genre eq 'book' ) {
            $mtx = 'book';
            $titletype = 'b';
    } elsif ( $genre eq 'journal' ) {
            $mtx = 'journal';
            $titletype = 'j';
    } elsif ( $genre eq 'journalArticle' ) {
            $mtx   = 'journal';
            $genre = 'article';
            $titletype = 'a';
    } else {
            $mtx = 'dc';
    }

    if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {

        # Setting datas
        $aulast  = $record->subfield( '700', 'a' ) || '';
        $aufirst = $record->subfield( '700', 'b' ) || '';
        push @authors, "$aufirst $aulast" if ($aufirst or $aulast);

        # others authors
        if ( $record->field('200') ) {
            for my $au ( $record->field('200')->subfield('g') ) {
                push @authors, $au;
            }
        }

        $title     = $record->subfield( '200', 'a' );
        my $subfield_210d = $record->subfield('210', 'd');
        if ($subfield_210d and $subfield_210d =~ /(\d{4})/) {
            $pubyear = $1;
        }
        $publisher = $record->subfield( '210', 'c' ) || '';
        $isbn      = $record->subfield( '010', 'a' ) || '';
        $issn      = $record->subfield( '011', 'a' ) || '';
    } else {

        # MARC21 need some improve

        # Setting datas
        if ( $record->field('100') ) {
            push @authors, $record->subfield( '100', 'a' );
        }

        # others authors
        if ( $record->field('700') ) {
            for my $au ( $record->field('700')->subfield('a') ) {
                push @authors, $au;
            }
        }
        $title = $record->field('245')->as_string('ab');
        if ($titletype eq 'a') {
            $pubyear   = $record->field('008') || '';
            $pubyear   = substr($pubyear->data(), 7, 4) if $pubyear;
            $isbn      = $record->subfield( '773', 'z' ) || '';
            $issn      = $record->subfield( '773', 'x' ) || '';
            $hosttitle = $record->subfield( '773', 't' ) || $record->subfield( '773', 'a') || q{};
            my @rels = $record->subfield( '773', 'g' );
            $pages = join(', ', @rels);
        } else {
            $pubyear   = $record->subfield( '260', 'c' ) || '';
            $publisher = $record->subfield( '260', 'b' ) || '';
            $isbn      = $record->subfield( '020', 'a' ) || '';
            $issn      = $record->subfield( '022', 'a' ) || '';
        }

    }

    my @params = (
        [ 'ctx_ver', 'Z39.88-2004' ],
        [ 'rft_val_fmt', "info:ofi/fmt:kev:mtx:$mtx" ],
        [ ($mtx eq 'dc' ? 'rft.type' : 'rft.genre'), $genre ],
        [ "rft.${titletype}title", $title ],
    );

    # rft.title is authorized only once, so by checking $titletype
    # we ensure that rft.title is not already in the list.
    if ($hosttitle and $titletype) {
        push @params, [ 'rft.title', $hosttitle ];
    }

    push @params, (
        [ 'rft.isbn', $isbn ],
        [ 'rft.issn', $issn ],
    );

    # If it's a subscription, these informations have no meaning.
    if ($genre ne 'journal') {
        push @params, (
            [ 'rft.aulast', $aulast ],
            [ 'rft.aufirst', $aufirst ],
            (map { [ 'rft.au', $_ ] } @authors),
            [ 'rft.pub', $publisher ],
            [ 'rft.date', $pubyear ],
            [ 'rft.pages', $pages ],
        );
    }

    my $coins_value = join( '&amp;',
        map { $$_[1] ? $$_[0] . '=' . uri_escape_utf8( $$_[1] ) : () } @params );

    return $coins_value;
}

=head2 get_openurl

my $url = $biblio->get_openurl;

Returns url for OpenURL resolver set in OpenURLResolverURL system preference

=cut

sub get_openurl {
    my ( $self ) = @_;

    my $OpenURLResolverURL = C4::Context->preference('OpenURLResolverURL');

    if ($OpenURLResolverURL) {
        my $uri = URI->new($OpenURLResolverURL);

        if (not defined $uri->query) {
            $OpenURLResolverURL .= '?';
        } else {
            $OpenURLResolverURL .= '&amp;';
        }
        $OpenURLResolverURL .= $self->get_coins;
    }

    return $OpenURLResolverURL;
}

=head3 is_serial

my $serial = $biblio->is_serial

Return boolean true if this bibbliographic record is continuing resource

=cut

sub is_serial {
    my ( $self ) = @_;

    return 1 if $self->serial;

    my $record = $self->metadata->record;
    return 1 if substr($record->leader, 7, 1) eq 's';

    return 0;
}

=head3 custom_cover_image_url

my $image_url = $biblio->custom_cover_image_url

Return the specific url of the cover image for this bibliographic record.
It is built regaring the value of the system preference CustomCoverImagesURL

=cut

sub custom_cover_image_url {
    my ( $self ) = @_;
    my $url = C4::Context->preference('CustomCoverImagesURL');
    if ( $url =~ m|{isbn}| ) {
        my $isbn = $self->biblioitem->isbn;
        $url =~ s|{isbn}|$isbn|g;
    }
    if ( $url =~ m|{normalized_isbn}| ) {
        my $normalized_isbn = C4::Koha::GetNormalizedISBN($self->biblioitem->isbn);
        $url =~ s|{normalized_isbn}|$normalized_isbn|g;
    }
    if ( $url =~ m|{issn}| ) {
        my $issn = $self->biblioitem->issn;
        $url =~ s|{issn}|$issn|g;
    }

    my $re = qr|{(?<field>\d{3})\$(?<subfield>.)}|;
    if ( $url =~ $re ) {
        my $field = $+{field};
        my $subfield = $+{subfield};
        my $marc_record = $self->metadata->record;
        my $value = $marc_record->subfield($field, $subfield);
        $url =~ s|$re|$value|;
    }

    return $url;
}

=head3 to_api

    my $json = $biblio->to_api;

Overloaded method that returns a JSON representation of the Koha::Biblio object,
suitable for API output. The related Koha::Biblioitem object is merged as expected
on the API.

=cut

sub to_api {
    my ($self, $args) = @_;

    my @embeds = keys %{ $args->{embed} };
    my $remaining_embeds = {};

    foreach my $embed (@embeds) {
        $remaining_embeds = delete $args->{embed}->{$embed}
            unless $self->can($embed);
    }

    my $response = $self->SUPER::to_api( $args );
    my $biblioitem = $self->biblioitem->to_api({ embed => $remaining_embeds });

    return { %$response, %$biblioitem };
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Biblio object
on the API.

=cut

sub to_api_mapping {
    return {
        biblionumber     => 'biblio_id',
        frameworkcode    => 'framework_id',
        unititle         => 'uniform_title',
        seriestitle      => 'series_title',
        copyrightdate    => 'copyright_date',
        datecreated      => 'creation_date'
    };
}

=head2 Internal methods

=head3 type

=cut

sub _type {
    return 'Biblio';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
