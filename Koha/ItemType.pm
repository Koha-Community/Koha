package Koha::ItemType;

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

use C4::Koha;
use C4::Languages;
use Koha::Database;
use Koha::IssuingRules;
use Koha::Localizations;

use base qw(Koha::Object);

=head1 NAME

Koha::ItemType - Koha Item type Object class

=head1 API

=head2 Class Methods

=cut

=head3 image_location

=cut

sub image_location {
    my ( $self, $interface ) = @_;
    return C4::Koha::getitemtypeimagelocation( $interface, $self->SUPER::imageurl );
}

=head3 translated_description

=cut

sub translated_description {
    my ( $self, $lang ) = @_;
    if ( my $translated_description = eval { $self->get_column('translated_description') } ) {
        # If the value has already been fetched (eg. from sarch_with_localization),
        # do not search for it again
        # Note: This is a bit hacky but should be fast
        return $translated_description
             ? $translated_description
             : $self->description;
    }
    $lang ||= C4::Languages::getlanguage;
    my $translated_description = Koha::Localizations->search({
        code => $self->itemtype,
        entity => 'itemtypes',
        lang => $lang
    })->next;
    return $translated_description
         ? $translated_description->translation
         : $self->description;
}

=head3 translated_descriptions

=cut

sub translated_descriptions {
    my ( $self ) = @_;
    my @translated_descriptions = Koha::Localizations->search(
        {   entity => 'itemtypes',
            code   => $self->itemtype,
        }
    );
    return [ map {
        {
            lang => $_->lang,
            translation => $_->translation,
        }
    } @translated_descriptions ];
}



=head3 can_be_deleted

my $can_be_deleted = Koha::ItemType->can_be_deleted();

Counts up the number of biblioitems and items with itemtype (code) and hands back the combined number of biblioitems and items with the itemtype

=cut

sub can_be_deleted {
    my ($self) = @_;
    my $nb_items = Koha::Items->search( { itype => $self->itemtype } )->count;
    my $nb_biblioitems = Koha::Biblioitems->search( { itemtype => $self->itemtype } )->count;
    return $nb_items + $nb_biblioitems == 0 ? 1 : 0;
}

=head3 may_article_request

    Returns true if it is likely possible to make an article request for
    this item type.
    Optional parameter: categorycode (for patron).

=cut

sub may_article_request {
    my ( $self, $params ) = @_;
    return q{} if !C4::Context->preference('ArticleRequests');
    my $itemtype = $self->itemtype;
    my $category = $params->{categorycode};

    my $guess = Koha::IssuingRules->guess_article_requestable_itemtypes({
        $category ? ( categorycode => $category ) : (),
    });
    return ( $guess->{ $itemtype // q{} } || $guess->{ '*' } ) ? 1 : q{};
}

=head3 type

=cut

sub _type {
    return 'Itemtype';
}

1;
