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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Script;
use Koha::AuthorisedValues;
use Koha::Authorities;
use Koha::Biblios;
use Koha::BiblioFrameworks;
use Koha::Biblioitems;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;
use C4::Biblio qw( GetMarcFromKohaField );
use Koha::Database::DataInconsistency;

{
    my $items  = Koha::Items->search;
    my @errors = Koha::Database::DataInconsistency->item_library($items);
    if (@errors) {
        new_section("Not defined items.homebranch and/or items.holdingbranch");
        for my $error (@errors) {
            new_item($error);
        }
    }
    if (@errors) { new_hint("Edit these items and set valid homebranch and/or holdingbranch") }
}

{
    # No join possible, FK is missing at DB level
    my @auth_types  = Koha::Authority::Types->search->get_column('authtypecode');
    my $authorities = Koha::Authorities->search( { authtypecode => { 'not in' => \@auth_types } } );
    if ( $authorities->count ) { new_section("Invalid auth_header.authtypecode") }
    while ( my $authority = $authorities->next ) {
        new_item(
            sprintf "Authority with authid=%s does not have a code defined (%s)", $authority->authid,
            $authority->authtypecode
        );
    }
    if ( $authorities->count ) { new_hint("Go to 'Home › Administration › Authority types' to define them") }
}

{
    if ( C4::Context->preference('item-level_itypes') ) {
        my $items_without_itype = Koha::Items->search( { -or => [ itype => undef, itype => '' ] } );
        if ( $items_without_itype->count ) {
            new_section("Items do not have itype defined");
            while ( my $item = $items_without_itype->next ) {
                if ( defined $item->biblioitem->itemtype && $item->biblioitem->itemtype ne '' ) {
                    new_item(
                        sprintf
                            "Item with itemnumber=%s does not have a itype value, biblio's item type will be used (%s)",
                        $item->itemnumber, $item->biblioitem->itemtype
                    );
                } else {
                    new_item(
                        sprintf
                            "Item with itemnumber=%s does not have a itype value, additionally no item type defined for biblionumber=%s",
                        $item->itemnumber, $item->biblioitem->biblionumber
                    );
                }
            }
            new_hint("The system preference item-level_itypes expects item types to be defined at item level");
        }
    } else {
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
        my $items_with_invalid_itype =
            Koha::Items->search( { -and => [ itype => { not_in => \@itemtypes }, itype => { '!=' => '' } ] } );
        if ( $items_with_invalid_itype->count ) {
            new_section("Items have invalid itype defined");
            while ( my $item = $items_with_invalid_itype->next ) {
                new_item(
                    sprintf "Item with itemnumber=%s, biblionumber=%s does not have a valid itype value (%s)",
                    $item->itemnumber, $item->biblionumber, $item->itype
                );
            }
            new_hint(
                "The items must have a itype value that is defined in the item types of Koha (Home › Administration › Item types administration)"
            );
        }
    } else {
        my $biblioitems_with_invalid_itemtype = Koha::Biblioitems->search( { itemtype => { not_in => \@itemtypes } } );
        if ( $biblioitems_with_invalid_itemtype->count ) {
            new_section("Biblioitems do not have itemtype defined");
            while ( my $biblioitem = $biblioitems_with_invalid_itemtype->next ) {
                new_item(
                    sprintf "Biblioitem with biblioitemnumber=%s does not have a valid itemtype value",
                    $biblioitem->biblioitemnumber
                );
            }
            new_hint(
                "The biblioitems must have a itemtype value that is defined in the item types of Koha (Home › Administration › Item types administration)"
            );
        }
    }

    my @item_fields_in_marc;
    my ( $item_tag, $item_subfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");
    my $search_string                     = q{ExtractValue(metadata,'count(//datafield[@tag="} . $item_tag . q{"])')>0};
    my $biblio_metadatas_with_item_fields = Koha::Biblio::Metadatas->search( \$search_string );
    if ( $biblio_metadatas_with_item_fields->count ) {
        while ( my $biblio_metadata_with_item_fields = $biblio_metadatas_with_item_fields->next ) {
            push @item_fields_in_marc,
                {
                biblionumber => $biblio_metadata_with_item_fields->biblionumber,
                };
        }
    }

    my ( @decoding_errors, @ids_not_in_marc );
    my $biblios = Koha::Biblios->search;
    my ( $biblio_tag,     $biblio_subfield )     = C4::Biblio::GetMarcFromKohaField("biblio.biblionumber");
    my ( $biblioitem_tag, $biblioitem_subfield ) = C4::Biblio::GetMarcFromKohaField("biblioitems.biblioitemnumber");
    while ( my $biblio = $biblios->next ) {
        my $record = eval { $biblio->metadata->record; };
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
                biblionumber             => $biblio->biblionumber,
                biblioitemnumber         => $biblio->biblioitem->biblioitemnumber,
                biblioitemnumber_in_marc => $biblionumber,
                };
        }
    }
    if (@decoding_errors) {
        new_section("Bibliographic records have invalid MARCXML");
        new_item($_) for @decoding_errors;
        new_hint(
            "The bibliographic records must have a valid MARCXML or you will face encoding issues or wrong displays");
    }
    if (@ids_not_in_marc) {
        new_section("Bibliographic records have MARCXML without biblionumber or biblioitemnumber");
        for my $id (@ids_not_in_marc) {
            if ( exists $id->{biblioitemnumber} ) {
                new_item(
                    sprintf(
                        q{Biblionumber %s has biblioitemnumber '%s' but should be '%s' in %s$%s},
                        $id->{biblionumber},
                        $id->{biblioitemnumber},
                        $id->{biblioitemnumber_in_marc},
                        $biblioitem_tag,
                        $biblioitem_subfield,
                    )
                );
            } else {
                new_item(
                    sprintf(
                        q{Biblionumber %s has '%s' in %s$%s},
                        $id->{biblionumber},
                        $id->{biblionumber_in_marc},
                        $biblio_tag,
                        $biblio_subfield,
                    )
                );
            }
        }
        new_hint("The bibliographic records must have the biblionumber and biblioitemnumber in MARCXML");
    }
    if (@item_fields_in_marc) {
        new_section("Bibliographic records have item fields in the MARC");
        for my $biblionumber (@item_fields_in_marc) {
            new_item(
                sprintf(
                    q{Biblionumber %s has item fields (%s) in the marc record},
                    $biblionumber->{biblionumber},
                    $item_tag,
                )
            );
        }
        new_hint("You can fix these by running misc/maintenance/touch_all_biblios.pl");
    }
}

{
    my @framework_codes = Koha::BiblioFrameworks->search()->get_column('frameworkcode');
    push @framework_codes, "";    # The default is not stored in frameworks, we need to force it

    my $invalid_av_per_framework = {};
    foreach my $frameworkcode (@framework_codes) {

        # We are only checking fields that are mapped to DB fields
        my $msss = Koha::MarcSubfieldStructures->search(
            {
                frameworkcode    => $frameworkcode,
                authorised_value => { '!=' => [ -and => ( undef, '' ) ] },
                kohafield        => { '!=' => [ -and => ( undef, '' ) ] }
            }
        );
        while ( my $mss = $msss->next ) {
            my $kohafield = $mss->kohafield;
            my $av        = $mss->authorised_value;
            next if grep { $_ eq $av } qw( branches itemtypes cn_source );    # internal categories

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
                    $tmp_kohafield => {
                        -not_in => [ $avs->get_column('authorised_value'), '' ],
                        '!='    => undef,
                    },
                    'biblio.frameworkcode' => $frameworkcode
                },
                { join => [ 'biblioitem', 'biblio' ] }
            );
            if ( $items->count ) {
                $invalid_av_per_framework->{$frameworkcode}->{$av} =
                    { items => $items, kohafield => $kohafield };
            }
        }
    }
    if (%$invalid_av_per_framework) {
        new_section('Wrong values linked to authorised values');
        for my $frameworkcode ( keys %$invalid_av_per_framework ) {
            while ( my ( $av_category, $v ) = each %{ $invalid_av_per_framework->{$frameworkcode} } ) {
                my $items     = $v->{items};
                my $kohafield = $v->{kohafield};
                my ( $table, $column ) = split '\.', $kohafield;
                my $output;
                while ( my $i = $items->next ) {
                    my $value =
                          $table eq 'items'  ? $i->$column
                        : $table eq 'biblio' ? $i->biblio->$column
                        :                      $i->biblioitem->$column;
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
    my $biblios = Koha::Biblios->search(
        {
            -or => [
                title => '',
                title => undef,
            ]
        }
    );
    if ( $biblios->count ) {
        my ( $title_tag, $title_subtag ) = C4::Biblio::GetMarcFromKohaField('biblio.title');
        my $title_field = $title_tag // '';
        $title_field .= '$' . $title_subtag if $title_subtag;
        new_section("Biblio without title $title_field");
        while ( my $biblio = $biblios->next ) {
            new_item( sprintf "Biblio with biblionumber=%s does not have title defined", $biblio->biblionumber );
        }
        new_hint("Edit these bibliographic records to define a title");
    }
}

{
    my $aging_patrons = Koha::Patrons->search(
        {
            -not => {
                -or => {
                    'me.dateofbirth' => undef,
                    -and             => {
                        'categorycode.dateofbirthrequired' => undef,
                        'categorycode.upperagelimit'       => undef,
                    }
                }
            }
        },
        { prefetch => ['categorycode'] },
        { order_by => [ 'me.categorycode', 'me.borrowernumber' ] },
    );
    my @invalid_patrons;
    while ( my $aging_patron = $aging_patrons->next ) {
        push @invalid_patrons, $aging_patron unless $aging_patron->is_expired || $aging_patron->is_valid_age;
    }
    if (@invalid_patrons) {
        new_section("Patrons with invalid age for category");
        foreach my $invalid_patron (@invalid_patrons) {
            my $category = $invalid_patron->category;
            new_item(
                sprintf "Patron borrowernumber=%s has an invalid age of %s for their category '%s' (%s to %s)",
                $invalid_patron->borrowernumber,       $invalid_patron->get_age, $category->categorycode,
                $category->dateofbirthrequired // '0', $category->upperagelimit // 'unlimited'
            );
        }
        new_hint("You may change the patron's category automatically with misc/cronjobs/update_patrons_category.pl");
    }
}

{
    use Koha::Database;
    my $schema = Koha::Database->new->schema;

    # Loop over all the DBIx::Class classes
    for my $class ( sort values %{ $schema->{class_mappings} } ) {

        # Retrieve the resultset so we can access the columns info
        my $rs      = $schema->resultset($class);
        my $columns = $rs->result_source->columns_info;

        # Loop over the columns
        while ( my ( $column, $info ) = each %$columns ) {

            # Next if data type is not date/datetime/timestamp
            my $data_type = $info->{data_type};
            next unless grep { $data_type =~ m{^$_$} } qw( timestamp datetime date );

            # Count the invalid dates
            my $invalid_dates = $rs->search( { $column => '0000-00-00' } )->count;

            next unless $invalid_dates;

            new_section(
                "Column " . $rs->result_source->name . "." . $column . " contains $invalid_dates invalid dates" );

            if ( $invalid_dates > 0 ) {
                new_hint("You may change the dates with script: misc/maintenance/fix_invalid_dates.pl (-c -v)");
            }

        }
    }
}

{
    my @loop_borrowers_relationships;
    my @guarantor_ids = Koha::Patron::Relationships->_resultset->get_column('guarantor_id')->all();
    my @guarantee_ids = Koha::Patron::Relationships->_resultset->get_column('guarantee_id')->all();

    foreach my $guarantor_id (@guarantor_ids) {
        foreach my $guarantee_id (@guarantee_ids) {
            if ( $guarantor_id == $guarantee_id ) {

                my $relation_guarantor_id;
                my $relation_guarantee_id;
                my $size_list;
                my $tmp_garantor_id = $guarantor_id;
                my @guarantor_ids;

                do {
                    my @relationship_for_go = Koha::Patron::Relationships->search(
                        {
                            -or => [
                                'guarantor_id' => { '=', $tmp_garantor_id },
                            ]
                        },
                    )->as_list;
                    $size_list = scalar @relationship_for_go;

                    foreach my $relation (@relationship_for_go) {
                        $relation_guarantor_id = $relation->guarantor_id;
                        unless ( grep { $_ == $relation_guarantor_id } @guarantor_ids ) {
                            push @guarantor_ids, $relation_guarantor_id;
                        }
                        $relation_guarantee_id = $relation->guarantee_id;

                        my @relationship_for_go = Koha::Patron::Relationships->search(
                            {
                                -or => [
                                    'guarantor_id' => { '=', $relation_guarantee_id },
                                ]
                            },
                        )->as_list;
                        $size_list = scalar @relationship_for_go;

                        if ( $guarantor_id == $relation_guarantee_id ) {
                            last;
                        }

                        foreach my $relation (@relationship_for_go) {
                            $relation_guarantor_id = $relation->guarantor_id;
                            unless ( grep { $_ == $relation_guarantor_id } @guarantor_ids ) {
                                push @guarantor_ids, $relation_guarantor_id;
                            }
                            $relation_guarantee_id = $relation->guarantee_id;

                            if ( $guarantor_id == $relation_guarantee_id ) {
                                last;
                            }
                        }
                        if ( $guarantor_id == $relation_guarantee_id ) {
                            last;
                        }
                    }

                    $tmp_garantor_id = $relation_guarantee_id;
                } while ( $guarantor_id != $relation_guarantee_id && $size_list > 0 );

                if ( $guarantor_id == $relation_guarantee_id ) {
                    unless ( grep { join( "", sort @$_ ) eq join( "", sort @guarantor_ids ) }
                        @loop_borrowers_relationships )
                    {
                        push @loop_borrowers_relationships, \@guarantor_ids;
                    }
                }
            }
        }
    }

    if ( scalar @loop_borrowers_relationships > 0 ) {
        new_section("The list of guarantors who are also guarantee.");
        my $count = 0;
        foreach my $table (@loop_borrowers_relationships) {
            $count++;
            print "Loop $count, borrowers id  : ";
            foreach my $borrower_id (@$table) {
                print "$borrower_id , ";
            }
            print "\n";
        }
        new_hint("Relationships that form guarantor loops must be deleted");
    }
}

sub new_section {
    my ($name) = @_;
    say "\n== $name ==";
}

sub new_item {
    my ($name) = @_;
    say "\t* $name";
}

sub new_hint {
    my ($name) = @_;
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
* Patrons with invalid category types due to lower and upper age limits
* Any date fields in the database (timestamp, datetime, date) set to 0000-00-00

=cut
