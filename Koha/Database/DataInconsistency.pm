package Koha::Database::DataInconsistency;

use Modern::Perl;
use C4::Context;
use C4::Biblio;
use Koha::Biblioitems;
use Koha::Biblio::Metadatas;
use Koha::BiblioFrameworks;
use Koha::Items;
use Koha::ItemTypes;
use Koha::I18N qw( __x );

sub invalid_item_library {
    my ( $self, $items ) = @_;

    $items = $items->search( { -or => { homebranch => undef, holdingbranch => undef } } );
    my @errors;
    while ( my $item = $items->next ) {
        if ( not $item->homebranch and not $item->holdingbranch ) {
            push @errors,
                __x(
                "Item with itemnumber={itemnumber} does not have home and holding library defined",
                itemnumber => $item->itemnumber
                );
        } elsif ( not $item->homebranch ) {
            push @errors,
                __x(
                "Item with itemnumber={itemnumber} does not have a home library defined",
                itemnumber => $item->itemnumber
                );
        } else {
            push @errors,
                __x(
                "Item with itemnumber={itemnumber} does not have a holding library defined",
                itemnumber => $item->itemnumber
                );
        }
    }
    return @errors;
}

sub ids {
    my ( $self, $object ) = @_;
    if ( $object->can('_resultset') ) {

        # It's a Koha::Objects
        return [ $object->get_column('biblionumber') ];
    } else {

        # It's a single Koha::Object
        return [ $object->biblionumber ];
    }
}

sub no_item_type {
    my ( $self, $biblios ) = @_;
    my $ids = $self->ids($biblios);
    my @errors;
    if ( C4::Context->preference('item-level_itypes') ) {
        my $items_without_itype = Koha::Items->search(
            {
                biblionumber => $ids,
                -or          => [ itype => undef, itype => '' ]
            }
        );
        if ( $items_without_itype->count ) {
            while ( my $item = $items_without_itype->next ) {
                if ( defined $item->biblioitem->itemtype && $item->biblioitem->itemtype ne '' ) {
                    push @errors, __x(
                        "Item with itemnumber={itemnumber} does not have an itype value, biblio's item type will be used ({itemtype})",
                        itemnumber => $item->itemnumber,
                        itemtype   => $item->biblioitem->itemtype,
                    );
                } else {
                    push @errors, __x(
                        "Item with itemnumber={itemnumber} does not have an itype value, additionally no item type defined for biblionumber={biblionumber}",
                        itemnumber   => $item->itemnumber,
                        biblionumber => $item->biblioitem->biblionumber,
                    );
                }
            }
        }
    } else {
        my $biblioitems_without_itemtype = Koha::Biblioitems->search(
            {
                biblionumber => $ids,
                -or          => [ itemtype => undef, itemtype => '' ]
            }
        );
        if ( $biblioitems_without_itemtype->count ) {
            while ( my $biblioitem = $biblioitems_without_itemtype->next ) {
                push @errors, __x(
                    "Biblioitem with biblioitemnumber={biblioitemnumber} does not have an itemtype value",
                    biblioitemnumber => $biblioitem->biblioitemnumber,
                );
            }
        }
    }
    return @errors;
}

sub invalid_item_type {
    my ( $self, $biblios ) = @_;
    my $ids = $self->ids($biblios);
    my @errors;
    my @itemtypes = Koha::ItemTypes->search->get_column('itemtype');
    if ( C4::Context->preference('item-level_itypes') ) {
        my $items_with_invalid_itype = Koha::Items->search(
            {
                biblionumber => $ids,
                -and         => [ itype => { not_in => \@itemtypes }, itype => { '!=' => '' } ]
            }
        );
        if ( $items_with_invalid_itype->count ) {
            while ( my $item = $items_with_invalid_itype->next ) {
                push @errors, __x(
                    "Item with itemnumber={itemnumber}, biblionumber={biblionumber} does not have a valid itype value ({itype})",
                    itemnumber   => $item->itemnumber,
                    biblionumber => $item->biblionumber,
                    itype        => $item->itype,
                );
            }
        }
    } else {
        my $biblioitems_with_invalid_itemtype = Koha::Biblioitems->search(
            {
                biblionumber => $ids,
                -and         => [ itemtype => { not_in => \@itemtypes }, itemtype => { '!=' => '' } ]
            }
        );
        if ( $biblioitems_with_invalid_itemtype->count ) {
            while ( my $biblioitem = $biblioitems_with_invalid_itemtype->next ) {
                push @errors, __x(
                    "Biblioitem with biblioitemnumber={biblioitemnumber} does not have a valid itemtype value ({itemtype})",
                    biblioitemnumber => $biblioitem->biblioitemnumber,
                    itemtype         => $biblioitem->itemtype,
                );
            }
        }
    }
    return @errors;
}

sub errors_in_marc {
    my ( $self, $biblios ) = @_;
    my $ids = $self->ids($biblios);
    my @item_fields_in_marc;
    my $errors;
    my ( $item_tag, $item_subfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");
    my $search_string = q{ExtractValue(metadata,'count(//datafield[@tag="} . $item_tag . q{"])')>0};
    my $biblio_metadatas_with_item_fields =
        Koha::Biblio::Metadatas->search( { biblionumber => $ids } )->search( \$search_string );
    if ( $biblio_metadatas_with_item_fields->count ) {
        while ( my $biblio_metadata_with_item_fields = $biblio_metadatas_with_item_fields->next ) {
            push @item_fields_in_marc,
                {
                biblionumber => $biblio_metadata_with_item_fields->biblionumber,
                };
        }
    }

    my ( $biblio_tag,      $biblio_subfield )     = C4::Biblio::GetMarcFromKohaField("biblio.biblionumber");
    my ( $biblioitem_tag,  $biblioitem_subfield ) = C4::Biblio::GetMarcFromKohaField("biblioitems.biblioitemnumber");
    $biblios = Koha::Biblios->search( { biblionumber => $ids } );
    while ( my $biblio = $biblios->next ) {
        my $record = eval { $biblio->metadata->record; };
        if ($@) {
            push @{ $errors->{decoding_errors} }, $@;
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
                push @{ $errors->{ids_not_in_marc} },
                    __x(
                    q{Biblionumber {biblionumber} has '{biblionumber_in_marc}' in {biblio_tag}${biblio_subfield}},
                    biblionumber         => $biblio->biblionumber,
                    biblionumber_in_marc => $biblionumber,
                    biblio_tag           => $biblio_tag,
                    biblio_subfield      => $biblio_subfield,
                    );

        }
        if ( $biblioitemnumber != $biblio->biblioitem->biblioitemnumber ) {
                push @{ $errors->{ids_not_in_marc} },
                    __x(
                    q{Biblionumber {biblionumber} has biblioitemnumber '{biblioitemnumber}' but should be '{biblioitemnumber_in_marc}' in {biblioitem_tag}${biblioitem_subfield}},
                    biblionumber             => $biblio->biblionumber,
                    biblioitemnumber         => $biblio->biblioitem->biblioitemnumber,
                    biblioitemnumber_in_marc => $biblionumber,
                    biblioitem_tag           => $biblioitem_tag,
                    biblioitem_subfield      => $biblioitem_subfield,
                    );
            }
        }
    }
    if (@item_fields_in_marc) {
        for my $biblionumber (@item_fields_in_marc) {
            push @{ $errors->{item_fields_in_marc} },
                __x(
                q{Biblionumber {biblionumber} has item fields ({item_tag}) in the marc record},
                biblionumber => $biblionumber->{biblionumber},
                item_tag     => $item_tag,
                );
        }
    }

    return $errors;
}

sub nonexistent_AV {
    my ( $self, $biblios ) = @_;
    my $ids = $self->ids($biblios);
    my @errors;
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
                    'me.biblionumber' => $ids,
                    $tmp_kohafield    => {
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
                push @errors, __x(
                          "The Framework *{frameworkcode}* is using the authorised value's category *{av_category}*, "
                        . "but the following {kohafield} do not have a value defined ({itemnumber => value }):\n{output}",
                    frameworkcode => $frameworkcode,
                    av_category   => $av_category,
                    kohafield     => $kohafield,
                    output        => $output,
                );
            }
        }
    }
    return @errors;
}

sub empty_title {
    my ( $self, $biblios ) = @_;
    my $ids = $self->ids($biblios);
    my @errors;
    $biblios = Koha::Biblios->search(
        {
            biblionumber => $ids,
            -or          => [
                title => '',
                title => undef,
            ]
        }
    );
    if ( $biblios->count ) {
        while ( my $biblio = $biblios->next ) {
            push @errors,
                __x(
                "Biblio with biblionumber={biblionumber} does not have title defined",
                biblionumber => $biblio->biblionumber
                );
        }
    }
    return @errors;
}

sub for_biblio {
    my ( $self, $biblio ) = @_;
    my @invalid_item_library = $self->invalid_item_library( $biblio->items );
    my @no_item_type         = $self->no_item_type($biblio);
    my @invalid_item_type    = $self->invalid_item_type($biblio);
    my $errors_in_marc       = $self->errors_in_marc($biblio);
    my @nonexistent_AV       = $self->nonexistent_AV($biblio);
    my @empty_title          = $self->empty_title($biblio);
    return {
        invalid_item_library => \@invalid_item_library,
        no_item_type         => \@no_item_type,
        invalid_item_type    => \@invalid_item_type,
        decoding_errors      => $errors_in_marc->{decoding_errors}     || [],
        ids_not_in_marc      => $errors_in_marc->{ids_not_in_marc}     || [],
        item_fields_in_marc  => $errors_in_marc->{item_fields_in_marc} || [],
        nonexistent_AV       => \@nonexistent_AV,
        empty_title          => \@empty_title,
    };
}

1;
