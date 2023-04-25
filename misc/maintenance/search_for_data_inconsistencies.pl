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

use Koha::Script;
use Koha::AuthorisedValues;
use Koha::Authorities;
use Koha::Biblios;
use Koha::BiblioFrameworks;
use Koha::Biblioitems;
use Koha::Items;
use Koha::ItemTypes;
use C4::Biblio qw( GetMarcFromKohaField );

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
        my $items_without_itype = Koha::Items->search( { -or => [itype => undef,itype => ''] } );
        if ( $items_without_itype->count ) {
            new_section("Items do not have itype defined");
            while ( my $item = $items_without_itype->next ) {
                if (defined $item->biblioitem->itemtype && $item->biblioitem->itemtype ne '' ) {
                    new_item(
                        sprintf "Item with itemnumber=%s does not have a itype value, biblio's item type will be used (%s)",
                        $item->itemnumber, $item->biblioitem->itemtype
                    );
                } else {
                    new_item(
                        sprintf "Item with itemnumber=%s does not have a itype value, additionally no item type defined for biblionumber=%s",
                        $item->itemnumber, $item->biblioitem->biblionumber
                    );
               }
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
        my $items_with_invalid_itype = Koha::Items->search( { -and => [itype => { not_in => \@itemtypes }, itype => { '!=' => '' }] } );
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

    my @decoding_errors;
    my $biblios = Koha::Biblios->search;
    while ( my $biblio = $biblios->next ) {
        my $record = eval{$biblio->metadata->record;};
        if ($@) {
            push @decoding_errors, $@;
            next;
        }
        my ( $biblionumber, $biblioitemnumber );
        if ( $biblio_tag < 10 ) {
            my $biblio_control_field = $record->field($biblio_tag);
            $biblionumber = $biblio_control_field->data if $biblio_control_field;
        } else {
            $biblionumber = $record->subfield( $biblio_tag, $biblio_subfield );
        }
        if ( $biblioitem_tag < 10 ) {
            my $biblioitem_control_field = $record->field($biblioitem_tag);
            $biblioitemnumber = $biblioitem_control_field->data if $biblioitem_control_field;
        } else {
            $biblioitemnumber = $record->subfield( $biblioitem_tag, $biblioitem_subfield );
        }
        if ( $biblionumber != $biblio->biblionumber ) {
            push @ids_not_in_marc,
              {
                biblionumber         => $biblio->biblionumber,
                biblionumber_in_marc => $biblionumber,
              };
        }
        if ( $biblioitemnumber != $biblio->biblioitem->biblioitemnumber ) {
            push @ids_not_in_marc,
            {
                biblionumber     => $biblio->biblionumber,
                biblioitemnumber => $biblio->biblioitem->biblioitemnumber,
                biblioitemnumber_in_marc => $biblionumber,
            };
        }
    }
    if ( @decoding_errors ) {
        new_section("Bibliographic records have invalid MARCXML");
        new_item($_) for @decoding_errors;
        new_hint("The bibliographic records must have a valid MARCXML or you will face encoding issues or wrong displays");
    }
}

{
    my @framework_codes = Koha::BiblioFrameworks->search()->get_column('frameworkcode');
    push @framework_codes,""; # The default is not stored in frameworks, we need to force it

    my $invalid_av_per_framework = {};
    foreach my $frameworkcode ( @framework_codes ) {
        # We are only checking fields that are mapped to DB fields
        my $msss = Koha::MarcSubfieldStructures->search({
            frameworkcode => $frameworkcode,
            authorised_value => {
                '!=' => [ -and => ( undef, '' ) ]
            },
            kohafield => {
                '!=' => [ -and => ( undef, '' ) ]
            }
        });
        while ( my $mss = $msss->next ) {
            my $kohafield = $mss->kohafield;
            my $av = $mss->authorised_value;
            next if grep {$_ eq $av} qw( branches itemtypes cn_source ); # internal categories

            my $avs = Koha::AuthorisedValues->search_by_koha_field(
                {
                    frameworkcode => $frameworkcode,
                    kohafield     => $kohafield,
                }
            );
            my $tmp_kohafield = $kohafield;
            if ( $tmp_kohafield =~ /^biblioitems/ ) {
                $tmp_kohafield =~ s|biblioitems|biblioitem|;
            } else {
                $tmp_kohafield =~ s|items|me|;
            }
            # replace items.attr with me.attr

            # We are only checking biblios with items
            my $items = Koha::Items->search(
                {
                    $tmp_kohafield =>
                      {
                          -not_in => [ $avs->get_column('authorised_value'), '' ],
                          '!='    => undef,
                      },
                    'biblio.frameworkcode' => $frameworkcode
                },
                { join => [ 'biblioitem', 'biblio' ] }
            );
            if ( $items->count ) {
                $invalid_av_per_framework->{ $frameworkcode }->{$av} =
                  { items => $items, kohafield => $kohafield };
            }
        }
    }
    if (%$invalid_av_per_framework) {
        new_section('Wrong values linked to authorised values');
        for my $frameworkcode ( keys %$invalid_av_per_framework ) {
            while ( my ( $av_category, $v ) = each %{$invalid_av_per_framework->{$frameworkcode}} ) {
                my $items     = $v->{items};
                my $kohafield = $v->{kohafield};
                my ( $table, $column ) = split '\.', $kohafield;
                my $output;
                while ( my $i = $items->next ) {
                    my $value = $table eq 'items'
                        ? $i->$column
                        : $table eq 'biblio'
                        ? $i->biblio->$column
                        : $i->biblioitem->$column;
                    $output .= " {" . $i->itemnumber . " => " . $value . "}\n";
                }
                new_item(
                    sprintf(
                        "The Framework *%s* is using the authorised value's category *%s*, "
                        . "but the following %s do not have a value defined ({itemnumber => value }):\n%s",
                        $frameworkcode, $av_category, $kohafield, $output
                    )
                );
            }
        }
    }
}

{
    my $biblios = Koha::Biblios->search({
        -or => [
            title => '',
            title => undef,
        ]
    });
    if ( $biblios->count ) {
        my ( $title_tag, $title_subtag ) = C4::Biblio::GetMarcFromKohaField( 'biblio.title' );
        my $title_field = $title_tag // '';
        $title_field .= '$'.$title_subtag if $title_subtag;
        new_section("Biblio without title $title_field");
        while ( my $biblio = $biblios->next ) {
            new_item(sprintf "Biblio with biblionumber=%s does not have title defined", $biblio->biblionumber);
        }
        new_hint("Edit these biblio records to defined a title");
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
* Invalid MARCXML in bibliographic records

=cut
