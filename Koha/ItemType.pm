package Koha::ItemType;

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


use C4::Koha qw( getitemtypeimagelocation );
use C4::Languages;
use Koha::Caches;
use Koha::Database;
use Koha::CirculationRules;
use Koha::Localizations;

use base qw(Koha::Object Koha::Object::Limit::Library);

=head1 NAME

Koha::ItemType - Koha Item type Object class

=head1 API

=head2 Class methods

=cut

=head3 store

ItemType specific store to ensure relevant caches are flushed on change

=cut

sub store {
    my ($self) = @_;

    my $flush = 0;

    if ( !$self->in_storage ) {
        $flush = 1;
    }
    else {
        my $self_from_storage = $self->get_from_storage;
        $flush = 1 if ( $self_from_storage->description ne $self->description );
    }

    $self = $self->SUPER::store;

    if ($flush) {
        my $cache = Koha::Caches->get_instance();
        my $key = "itemtype:description:en";
        $cache->clear_from_cache($key);
    }

    return $self;
}

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
    )->as_list;
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

    my $guess = Koha::CirculationRules->guess_article_requestable_itemtypes({
        $category ? ( categorycode => $category ) : (),
    });
    return ( $guess->{ $itemtype // q{} } || $guess->{ '*' } ) ? 1 : q{};
}

=head3 _library_limits

 configure library limits

=cut

sub _library_limits {
    return {
        class => "ItemtypesBranch",
        id => "itemtype",
        library => "branchcode",
    };
}

=head3 parent

    Returns the ItemType object of the parent_type or undef.

=cut

sub parent {
    my ( $self ) = @_;
    my $parent_rs = $self->_result->parent_type;
    return unless $parent_rs;
    return Koha::ItemType->_new_from_dbic( $parent_rs );

}

=head3 children_with_localization

    Returns the ItemType objects of the children of this type or undef.

=cut

sub children_with_localization {
    my ( $self ) = @_;
    return Koha::ItemTypes->search_with_localization({ parent_type => $self->itemtype });
}

=head3 type

=cut

sub _type {
    return 'Itemtype';
}

1;
