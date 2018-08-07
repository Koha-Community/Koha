#!/usr/bin/perl

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

use Koha::Items;
use Koha::Biblioitems;
use Koha::ItemTypes;
use Koha::Authorities;

{
    my $items = Koha::Items->search({ -or => { homebranch => undef, holdingbranch => undef }});
    if ( $items->count ) { new_section("Not defined items.homebranch and/or items.holdingbranch")}
    while ( my $item = $items->next ) {
        if ( not $item->homebranch and not $item->holdingbranch ) {
            new_item(sprintf "Item with itemnumber=%s does not have homebranch and holdingbranch defined", $item->itemnumber);
        } elsif ( not $item->homebranch ) {
            new_item(sprintf "Item with itemnumber=%s does not have homebranch defined", $item->itemnumber);
        } else {
            new_item(sprintf "Item with itemnumber=%s does not have holdingbranch defined", $item->itemnumber);
        }
    }
    if ( $items->count ) { new_hint("Edit these items and set valid homebranch and/or holdingbranch")}
}

{
    # No join possible, FK is missing at DB level
    my @auth_types = Koha::Authority::Types->search->get_column('authtypecode');
    my $authorities = Koha::Authorities->search({authtypecode => { 'not in' => \@auth_types } });
    if ( $authorities->count ) {new_section("Invalid auth_header.authtypecode")}
    while ( my $authority = $authorities->next ) {
        new_item(sprintf "Authority with authid=%s does not have a code defined (%s)", $authority->authid, $authority->authtypecode);
    }
    if ( $authorities->count ) {new_hint("Go to 'Home › Administration › Authority types' to define them")}
}

{
    if ( C4::Context->preference('item-level_itypes') ) {
        my $items_without_itype = Koha::Items->search( { itype => undef } );
        if ( $items_without_itype->count ) {
            new_section("Items do not have itype defined");
            while ( my $item = $items_without_itype->next ) {
                new_item(
                    sprintf "Item with itemnumber=%s does not have a itype value, biblio's item type will be used (%s)",
                    $item->itemnumber, $item->biblioitem->itemtype
                );
            }
            new_hint("The system preference item-level_itypes expects item types to be defined at item level");
        }
    }
    else {
        my $biblioitems_without_itemtype = Koha::Biblioitems->search( { itemtype => undef } );
        if ( $biblioitems_without_itemtype->count ) {
            new_section("Biblioitems do not have itemtype defined");
            while ( my $biblioitem = $biblioitems_without_itemtype->next ) {
                new_item(
                    sprintf "Biblioitem with biblioitemnumber=%s does not have a itemtype value",
                    $biblioitem->biblioitemnumber
                );
            }
            new_hint("The system preference item-level_itypes expects item types to be defined at biblio level");
        }
    }

    my @itemtypes = Koha::ItemTypes->search->get_column('itemtype');
    if ( C4::Context->preference('item-level_itypes') ) {
        my $items_with_invalid_itype = Koha::Items->search( { itype => { not_in => \@itemtypes } } );
        if ( $items_with_invalid_itype->count ) {
            new_section("Items have invalid itype defined");
            while ( my $item = $items_with_invalid_itype->next ) {
                new_item(
                    sprintf "Item with itemnumber=%s, biblionumber=%s does not have a valid itype value (%s)",
                    $item->itemnumber, $item->biblionumber, $item->itype
                );
            }
            new_hint("The items must have a itype value that is defined in the item types of Koha (Home › Administration › Item types administration)");
        }
    }
    else {
        my $biblioitems_with_invalid_itemtype = Koha::Biblioitems->search(
            { itemtype => { not_in => \@itemtypes } }
        );
        if ( $biblioitems_with_invalid_itemtype->count ) {
            new_section("Biblioitems do not have itemtype defined");
            while ( my $biblioitem = $biblioitems_with_invalid_itemtype->next ) {
                new_item(
                    sprintf "Biblioitem with biblioitemnumber=%s does not have a valid itemtype value",
                    $biblioitem->biblioitemnumber
                );
            }
            new_hint("The biblioitems must have a itemtype value that is defined in the item types of Koha (Home › Administration › Item types administration)");
        }
    }
}

sub new_section {
    my ( $name ) = @_;
    say "\n== $name ==";
}

sub new_item {
    my ( $name ) = @_;
    say "\t* $name";
}
sub new_hint {
    my ( $name ) = @_;
    say "=> $name";
}

=head1 NAME

search_for_data_inconsistencies.pl

=head1 SYNOPSIS

    perl search_for_data_inconsistencies.pl

=head1 DESCRIPTION

Catch data inconsistencies in Koha database

* Items with undefined homebranch and/or holdingbranch
* Authorities with undefined authtypecodes/authority types
* Item types:
  * if item types are defined at item level (item-level_itypes=specific item),
    then items.itype must be set else biblioitems.itemtype must be set
  * Item types defined in items or biblioitems must be defined in the itemtypes table

=cut
