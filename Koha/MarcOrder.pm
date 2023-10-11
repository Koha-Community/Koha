package Koha::MarcOrder;

# Copyright 2023, PTFS-Europe Ltd
#
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
use Try::Tiny qw( catch try );

use base qw(Koha::Object);

use C4::Matcher;
use C4::ImportBatch qw(
    RecordsFromMARCXMLFile
    RecordsFromISO2709File
    RecordsFromMarcPlugin
    BatchStageMarcRecords
    BatchFindDuplicates
    SetImportBatchMatcher
    SetImportBatchOverlayAction
    SetImportBatchNoMatchAction
    SetImportBatchItemAction
    SetImportBatchStatus
    GetImportBatchOverlayAction
    GetImportBatchNoMatchAction
    GetImportBatchItemAction
    GetImportBatch
);
use C4::Search      qw( FindDuplicate );
use C4::Acquisition qw( NewBasket );
use C4::Biblio      qw(
    AddBiblio
    GetMarcFromKohaField
    TransformHtmlToXml
    GetMarcQuantity
);
use C4::Items   qw( AddItemFromMarc );
use C4::Budgets qw( GetBudgetByCode );

use Koha::Database;
use Koha::ImportBatchProfiles;
use Koha::ImportBatches;
use Koha::Import::Records;
use Koha::Acquisition::Currencies;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Baskets;

=head1 NAME

Koha::MarcOrder - Koha Marc Order Object class

=head1 API

=head2 Class methods

=cut

=head3 import_record_and_create_order_lines

    my $result = Koha::MarcOrder->import_record_and_create_order_lines($args);

    Controller for record import and order line creation when using the interface in addorderiso2709.pl

=cut

sub import_record_and_create_order_lines {
    my ( $self, $args ) = @_;

    my $import_batch_id           = $args->{import_batch_id};
    my $import_record_id_selected = $args->{import_record_id_selected} || ();
    my $matcher_id                = $args->{matcher_id};
    my $overlay_action            = $args->{overlay_action};
    my $import_record             = $args->{import_record};
    my $client_item_fields        = $args->{client_item_fields};
    my $agent                     = $args->{agent};
    my $basket_id                 = $args->{basket_id};
    my $budget_id                 = $args->{budget_id};
    my $vendor                    = $args->{vendor};

    my $result = add_biblios_from_import_record(
        {
            import_batch_id           => $import_batch_id,
            import_record             => $import_record,
            matcher_id                => $matcher_id,
            overlay_action            => $overlay_action,
            agent                     => $agent,
            import_record_id_selected => $import_record_id_selected,
        }
    );

    return {
        duplicates_in_batch => $result->{duplicates_in_batch},
        skip                => $result->{skip}
    } if $result->{skip};

    my $order_line_details = add_items_from_import_record(
        {
            record_result      => $result->{record_result},
            basket_id          => $basket_id,
            vendor             => $vendor,
            budget_id          => $budget_id,
            agent              => $agent,
            client_item_fields => $client_item_fields
        }
    );

    my $order_lines = create_order_lines( { order_line_details => $order_line_details } );

    return {
        duplicates_in_batch => 0,
        skip                => 0
    };
}

=head3 _get_MarcFieldsToOrder_syspref_data

    my $marc_fields_to_order = _get_MarcFieldsToOrder_syspref_data('MarcFieldsToOrder', $marcrecord, $fields);

    Fetches data from a marc record based on the mappings in the syspref MarcFieldsToOrder using the fields selected in $fields (array).

=cut

sub _get_MarcFieldsToOrder_syspref_data {
    my ( $syspref_name, $record, $field_list ) = @_;
    my $syspref = C4::Context->preference($syspref_name);
    $syspref = "$syspref\n\n";
    my $yaml = eval { YAML::XS::Load( Encode::encode_utf8($syspref) ); };
    if ($@) {
        warn "Unable to parse $syspref syspref : $@";
        return ();
    }
    my $r;
    for my $field_name (@$field_list) {
        next unless exists $yaml->{$field_name};
        my @fields = split /\|/, $yaml->{$field_name};
        for my $field (@fields) {
            my ( $f, $sf ) = split /\$/, $field;
            next unless $f and $sf;
            if ( my $v = $record->subfield( $f, $sf ) ) {
                $r->{$field_name} = $v;
            }
            last if $yaml->{$field};
        }
    }
    return $r;
}

=head3 _get_MarcItemFieldsToOrder_syspref_data

    my $marc_item_fields_to_order = _get_MarcItemFieldsToOrder_syspref_data('MarcItemFieldsToOrder', $marcrecord, $fields);

    Fetches data from a marc record based on the mappings in the syspref MarcItemFieldsToOrder using the fields selected in $fields (array).

=cut

sub _get_MarcItemFieldsToOrder_syspref_data {
    my ( $syspref_name, $record, $field_list ) = @_;
    my $syspref = C4::Context->preference($syspref_name);
    $syspref = "$syspref\n\n";
    my $yaml = eval { YAML::XS::Load( Encode::encode_utf8($syspref) ); };
    if ($@) {
        warn "Unable to parse $syspref syspref : $@";
        return ();
    }
    my @result;
    my @tags_list;

    # Check tags in syspref definition
    for my $field_name (@$field_list) {
        next unless exists $yaml->{$field_name};
        my @fields = split /\|/, $yaml->{$field_name};
        for my $field (@fields) {
            my ( $f, $sf ) = split /\$/, $field;
            next unless $f and $sf;
            push @tags_list, $f;
        }
    }
    @tags_list = List::MoreUtils::uniq(@tags_list);

    my $tags_count = _verify_number_of_fields( \@tags_list, $record );

    # Return if the number of these fields in the record is not the same.
    die "Invalid number of fields detected on field $tags_count->{key}, please check this file" if $tags_count->{error};

    # Gather the fields
    my $fields_hash;
    foreach my $tag (@tags_list) {
        my @tmp_fields;
        foreach my $field ( $record->field($tag) ) {
            push @tmp_fields, $field;
        }
        $fields_hash->{$tag} = \@tmp_fields;
    }

    if ( $tags_count->{count} ) {
        for ( my $i = 0 ; $i < $tags_count->{count} ; $i++ ) {
            my $r;
            for my $field_name (@$field_list) {
                next unless exists $yaml->{$field_name};
                my @fields = split /\|/, $yaml->{$field_name};
                for my $field (@fields) {
                    my ( $f, $sf ) = split /\$/, $field;
                    next unless $f and $sf;
                    my $v = $fields_hash->{$f}[$i] ? $fields_hash->{$f}[$i]->subfield($sf) : undef;
                    $r->{$field_name} = $v if ( defined $v );
                    last if $yaml->{$field};
                }
            }
            push @result, $r;
        }
    }

    return $result[0];
}

=head3 _verify_number_of_fields

    my $tags_count = _verify_number_of_fields(\@tags_list, $record);

    Verifies that the number of fields in the record is consistent for each field

=cut

sub _verify_number_of_fields {
    my ( $tags_list, $record ) = @_;
    my $tag_fields_count;
    for my $tag (@$tags_list) {
        my @fields = $record->field($tag);
        $tag_fields_count->{$tag} = scalar @fields;
    }

    my $tags_count;
    foreach my $key ( keys %$tag_fields_count ) {
        if ( $tag_fields_count->{$key} > 0 ) {    # Having 0 of a field is ok
            $tags_count //= $tag_fields_count->{$key};    # Start with the count from the first occurrence
            return { error => 1, key => $key }
                if $tag_fields_count->{$key} !=
                $tags_count;                              # All counts of various fields should be equal if they exist
        }
    }
    return { error => 0, count => $tags_count };
}

=head3 add_biblios_from_import_record

    my ($record_results, $duplicates_in_batch) = add_biblios_from_import_record({
        import_record             => $import_record,
        matcher_id                => $matcher_id,
        overlay_action            => $overlay_action,
        import_record_id_selected => $import_record_id_selected,
        agent                     => $agent,
        import_batch_id           => $import_batch_id
    });

    Takes a set of import records and adds biblio records based on the file content.
    Params matcher_id and overlay_action are taken from the marc ordering account.
    Returns the new or matched biblionumber and the marc record for each import record.

=cut

sub add_biblios_from_import_record {
    my ($args) = @_;

    my $import_batch_id           = $args->{import_batch_id};
    my $import_record_id_selected = $args->{import_record_id_selected} || ();
    my $matcher_id                = $args->{matcher_id};
    my $overlay_action            = $args->{overlay_action};
    my $import_record             = $args->{import_record};
    my $agent                     = $args->{agent} || "";
    my $duplicates_in_batch;

    my $duplicates_found = 0;
    if ( $agent eq 'client' ) {
        return {
            record_result       => 0,
            duplicates_in_batch => 0,
            skip                => 1
        } if not grep { $_ eq $import_record->import_record_id } @{$import_record_id_selected};
    }

    my $marcrecord   = $import_record->get_marc_record || die "Couldn't translate marc information";
    my $matches      = $import_record->get_import_record_matches( { chosen => 1 } );
    my $match        = $matches->count ? $matches->next             : undef;
    my $biblionumber = $match          ? $match->candidate_match_id : 0;

    if ($biblionumber) {
        $import_record->status('imported')->store;
        if ( $overlay_action eq 'replace' ) {
            my $biblio = Koha::Biblios->find($biblionumber);
            $import_record->replace( { biblio => $biblio } );
        }
    } else {
        if ($matcher_id) {
            if ( $matcher_id eq '_TITLE_AUTHOR_' ) {
                my @matches = FindDuplicate($marcrecord);
                $duplicates_found = 1 if @matches;
            } else {
                my $matcher = C4::Matcher->fetch($matcher_id);
                my @matches = $matcher->get_matches( $marcrecord, my $max_matches = 1 );
                $duplicates_found = 1 if @matches;
            }
            return {
                record_result       => 0,
                duplicates_in_batch => $import_batch_id,
                skip                => 1
            } if $duplicates_found;
        }

        # add the biblio if no matches were found
        if ( !$duplicates_found ) {
            ( $biblionumber, undef ) = AddBiblio( $marcrecord, '' );
            $import_record->status('imported')->store;
        }
    }
    $import_record->import_biblio->matched_biblionumber($biblionumber)->store;

    my $record_result = {
        biblionumber     => $biblionumber,
        marcrecord       => $marcrecord,
        import_record_id => $import_record->import_record_id,
    };

    return {
        record_result       => $record_result,
        duplicates_in_batch => $duplicates_in_batch,
        skip                => 0
    };
}

=head3 add_items_from_import_record

    my $order_line_details = add_items_from_import_record({
        record_result      => $record_result,
        basket_id          => $basket_id,
        vendor             => $vendor,
        budget_id          => $budget_id,
        agent              => $agent,
        client_item_fields => $client_item_fields
    });

    Adds items to biblio records based on mappings in MarcItemFieldsToOrder.
    Returns an array of order line details based on newly added items.
    If being called from addorderiso2709.pl then client_item_fields is a hash of all the UI form inputs needed by the script.

=cut

sub add_items_from_import_record {
    my ($args) = @_;

    my $record_result      = $args->{record_result};
    my $basket_id          = $args->{basket_id};
    my $budget_id          = $args->{budget_id};
    my $vendor             = $args->{vendor};
    my $agent              = $args->{agent};
    my $client_item_fields = $args->{client_item_fields} || undef;
    my $active_currency    = Koha::Acquisition::Currencies->get_active;
    my $biblionumber       = $record_result->{biblionumber};
    my $marcrecord         = $record_result->{marcrecord};
    my @order_line_details;

    if ( $agent eq 'cron' ) {
        my $marc_fields_to_order = _get_MarcFieldsToOrder_syspref_data(
            'MarcFieldsToOrder', $marcrecord,
            [ 'price', 'quantity', 'budget_code', 'discount', 'sort1', 'sort2' ]
        );
        my $quantity = $marc_fields_to_order->{quantity};
        my $budget_code =
            $marc_fields_to_order->{budget_code} || $budget_id;    # Use fallback from ordering profile if not mapped
        my $price    = $marc_fields_to_order->{price};
        my $discount = $marc_fields_to_order->{discount};
        my $sort1    = $marc_fields_to_order->{sort1};
        my $sort2    = $marc_fields_to_order->{sort2};
        my $mapped_budget;

        if ($budget_code) {
            my $biblio_budget = GetBudgetByCode($budget_code);
            if ($biblio_budget) {
                $mapped_budget = $biblio_budget->{budget_id};
            } else {
                $mapped_budget = $budget_id;
            }
        }

        my $marc_item_fields_to_order = _get_MarcItemFieldsToOrder_syspref_data(
            'MarcItemFieldsToOrder',
            $marcrecord,
            [
                'homebranch', 'holdingbranch', 'itype', 'nonpublic_note',   'public_note', 'loc', 'ccode', 'notforloan',
                'uri',        'copyno',        'price', 'replacementprice', 'itemcallnumber', 'quantity', 'budget_code'
            ]
        );
        my $item_homebranch     = $marc_item_fields_to_order->{homebranch};
        my $item_holdingbranch  = $marc_item_fields_to_order->{holdingbranch};
        my $item_itype          = $marc_item_fields_to_order->{itype};
        my $item_nonpublic_note = $marc_item_fields_to_order->{nonpublic_note};
        my $item_public_note    = $marc_item_fields_to_order->{public_note};
        my $item_loc            = $marc_item_fields_to_order->{loc};
        my $item_ccode          = $marc_item_fields_to_order->{ccode};
        my $item_notforloan     = $marc_item_fields_to_order->{notforloan};
        my $item_uri            = $marc_item_fields_to_order->{uri};
        my $item_copyno         = $marc_item_fields_to_order->{copyno};
        my $item_quantity       = $marc_item_fields_to_order->{quantity} || 0;
        my $item_budget_code    = $marc_item_fields_to_order->{budget_code};
        my $item_budget_id;

        if ( $marc_item_fields_to_order->{budget_code} ) {
            my $item_budget = GetBudgetByCode( $marc_item_fields_to_order->{budget_code} );
            if ($item_budget) {
                $item_budget_id = $item_budget->{budget_id};
            } else {
                $item_budget_id = $budget_id;
            }
        } else {
            $item_budget_id = $budget_id;
        }
        my $item_price             = $marc_item_fields_to_order->{price};
        my $item_replacement_price = $marc_item_fields_to_order->{replacementprice};
        my $item_callnumber        = $marc_item_fields_to_order->{itemcallnumber};
        my $itemcreation           = 0;

        for ( my $i = 0 ; $i < $item_quantity ; $i++ ) {
            $itemcreation = 1;
            my $item = Koha::Item->new(
                {
                    biblionumber        => $biblionumber,
                    homebranch          => $item_homebranch,
                    holdingbranch       => $item_holdingbranch,
                    itype               => $item_itype,
                    itemnotes_nonpublic => $item_nonpublic_note,
                    itemnotes           => $item_public_note,
                    location            => $item_loc,
                    ccode               => $item_ccode,
                    notforloan          => $item_notforloan,
                    uri                 => $item_uri,
                    copynumber          => $item_copyno,
                    price               => $item_price,
                    replacementprice    => $item_replacement_price,
                    itemcallnumber      => $item_callnumber,
                }
            )->store;

            my %order_detail_hash = (
                biblionumber => $biblionumber,
                basketno     => $basket_id,
                itemnumbers  => ( $item->itemnumber ),
                quantity     => 1,
                budget_id    => $item_budget_id,
                currency     => $vendor->listprice,
            );

            if ($item_price) {
                $order_detail_hash{tax_rate_on_ordering}  = $vendor->tax_rate;
                $order_detail_hash{tax_rate_on_receiving} = $vendor->tax_rate;
                $order_detail_hash{discount}              = $vendor->discount;
                $order_detail_hash{rrp}                   = $item_price;
                $order_detail_hash{ecost} =
                    $vendor->discount ? $item_price * ( 1 - $vendor->discount / 100 ) : $item_price;
                $order_detail_hash{listprice} = $order_detail_hash{rrp} / $active_currency->rate;
                $order_detail_hash{unitprice} = $order_detail_hash{ecost};
            } else {
                $order_detail_hash{listprice} = 0;
            }
            $order_detail_hash{replacementprice} = $item_replacement_price || 0;
            $order_detail_hash{uncertainprice}   = 0 if $order_detail_hash{listprice};

            push @order_line_details, \%order_detail_hash;
        }

        if ( !$itemcreation ) {
            my %order_detail_hash = (
                biblionumber   => $biblionumber,
                basketno       => $basket_id,
                quantity       => $quantity,
                budget_id      => $mapped_budget,
                uncertainprice => 1,
                sort1          => $sort1,
                sort2          => $sort2,
            );

            if ($price) {
                $order_detail_hash{tax_rate_on_ordering}  = $vendor->tax_rate;
                $order_detail_hash{tax_rate_on_receiving} = $vendor->tax_rate;
                my $order_discount = $discount ? $discount : $vendor->discount;
                $order_detail_hash{discount}  = $order_discount;
                $order_detail_hash{rrp}       = $price;
                $order_detail_hash{ecost}     = $order_discount ? $price * ( 1 - $order_discount / 100 ) : $price;
                $order_detail_hash{listprice} = $order_detail_hash{rrp} / $active_currency->rate;
                $order_detail_hash{unitprice} = $order_detail_hash{ecost};
            } else {
                $order_detail_hash{listprice} = 0;
            }

            $order_detail_hash{uncertainprice} = 0 if $order_detail_hash{listprice};
            push @order_line_details, \%order_detail_hash;
        }
    }

    if ( $agent eq 'client' ) {
        my $homebranches      = $client_item_fields->{homebranches};
        my $count             = scalar @$homebranches;
        my $holdingbranches   = $client_item_fields->{holdingbranches};
        my $itypes            = $client_item_fields->{itypes};
        my $nonpublic_notes   = $client_item_fields->{nonpublic_notes};
        my $public_notes      = $client_item_fields->{public_notes};
        my $locs              = $client_item_fields->{locs};
        my $ccodes            = $client_item_fields->{ccodes};
        my $notforloans       = $client_item_fields->{notforloans};
        my $uris              = $client_item_fields->{uris};
        my $copynos           = $client_item_fields->{copynos};
        my $budget_codes      = $client_item_fields->{budget_codes};
        my $itemprices        = $client_item_fields->{itemprices};
        my $replacementprices = $client_item_fields->{replacementprices};
        my $itemcallnumbers   = $client_item_fields->{itemcallnumbers};

        my $itemcreation;
        for ( my $i = 0 ; $i < $count ; $i++ ) {
            $itemcreation = 1;
            my $item = Koha::Item->new(
                {
                    biblionumber        => $biblionumber,
                    homebranch          => @$homebranches[$i],
                    holdingbranch       => @$holdingbranches[$i],
                    itemnotes_nonpublic => @$nonpublic_notes[$i],
                    itemnotes           => @$public_notes[$i],
                    location            => @$locs[$i],
                    ccode               => @$ccodes[$i],
                    itype               => @$itypes[$i],
                    notforloan          => @$notforloans[$i],
                    uri                 => @$uris[$i],
                    copynumber          => @$copynos[$i],
                    price               => @$itemprices[$i],
                    replacementprice    => @$replacementprices[$i],
                    itemcallnumber      => @$itemcallnumbers[$i],
                }
            )->store;

            my %order_detail_hash = (
                biblionumber => $biblionumber,
                itemnumbers  => ( $item->itemnumber ),
                basketno     => $basket_id,
                quantity     => 1,
                budget_id    => @$budget_codes[$i]
                    || $budget_id,    # If no budget selected in the UI, default to the budget on the ordering account
                currency => $vendor->listprice,
            );

            if ( @$itemprices[$i] ) {
                $order_detail_hash{tax_rate_on_ordering}  = $vendor->tax_rate;
                $order_detail_hash{tax_rate_on_receiving} = $vendor->tax_rate;
                my $order_discount =
                    $client_item_fields->{c_discount} ? $client_item_fields->{c_discount} : $vendor->discount;
                $order_detail_hash{discount} = $order_discount;
                $order_detail_hash{rrp}      = @$itemprices[$i];
                $order_detail_hash{ecost} =
                    $order_discount ? @$itemprices[$i] * ( 1 - $order_discount / 100 ) : @$itemprices[$i];
                $order_detail_hash{listprice} = $order_detail_hash{rrp} / $active_currency->rate;
                $order_detail_hash{unitprice} = $order_detail_hash{ecost};
            } else {
                $order_detail_hash{listprice} = 0;
            }
            $order_detail_hash{replacementprice} = @$replacementprices[$i] || 0;
            $order_detail_hash{uncertainprice}   = 0 if $order_detail_hash{listprice};

            push @order_line_details, \%order_detail_hash;
        }

        if ( !$itemcreation ) {
            my $quantity          = GetMarcQuantity( $marcrecord, C4::Context->preference('marcflavour') ) || 1;
            my %order_detail_hash = (
                biblionumber       => $biblionumber,
                basketno           => $basket_id,
                quantity           => $client_item_fields->{c_quantity},
                budget_id          => $client_item_fields->{c_budget_id},
                uncertainprice     => 1,
                sort1              => $client_item_fields->{c_sort1},
                sort2              => $client_item_fields->{c_sort2},
                order_internalnote => $client_item_fields->{all_order_internalnote},
                order_vendornote   => $client_item_fields->{all_order_vendornote},
                currency           => $client_item_fields->{all_currency},
                replacementprice   => $client_item_fields->{c_replacement_price},
            );
            if ( $client_item_fields->{c_price} ) {
                $order_detail_hash{tax_rate_on_ordering}  = $vendor->tax_rate;
                $order_detail_hash{tax_rate_on_receiving} = $vendor->tax_rate;
                my $order_discount =
                    $client_item_fields->{c_discount} ? $client_item_fields->{c_discount} : $vendor->discount;
                $order_detail_hash{discount} = $order_discount;
                $order_detail_hash{rrp}      = $client_item_fields->{c_price};
                $order_detail_hash{ecost} =
                      $order_discount
                    ? $client_item_fields->{c_price} * ( 1 - $order_discount / 100 )
                    : $client_item_fields->{c_price};
                $order_detail_hash{listprice} = $order_detail_hash{rrp} / $active_currency->rate;
                $order_detail_hash{unitprice} = $order_detail_hash{ecost};
            } else {
                $order_detail_hash{listprice} = 0;
            }

            $order_detail_hash{uncertainprice} = 0 if $order_detail_hash{listprice};

            # Add items if applicable parsing the item sent by the form, and create an item just for the import_record_id we are dealing with
            my $basket = Koha::Acquisition::Baskets->find($basket_id);
            $order_detail_hash{itemnumbers} = ();
            if ( $basket->effective_create_items eq 'ordering' && !$basket->is_standing ) {
                my @tags         = $client_item_fields->{tag};
                my @subfields    = $client_item_fields->{subfield};
                my @field_values = $client_item_fields->{field_value};
                my @serials      = $client_item_fields->{serial};
                my $xml          = TransformHtmlToXml( \@tags, \@subfields, \@field_values );
                my $record       = MARC::Record::new_from_xml( $xml, 'UTF-8' );
                for ( my $qtyloop = 1 ; $qtyloop <= $client_item_fields->{c_quantity} ; $qtyloop++ ) {
                    my ( $biblionumber, undef, $itemnumber ) = AddItemFromMarc( $record, $biblionumber );
                    push @{ $order_detail_hash{itemnumbers} }, $itemnumber;
                }
            }
            push @order_line_details, \%order_detail_hash;
        }
    }
    return \@order_line_details;
}

=head3 create_order_lines

    my $order_lines = create_order_lines({
        order_line_details => $order_line_details
    });

    Creates order lines based on an array of order line details

=cut

sub create_order_lines {
    my ($args) = @_;

    my $order_line_details = $args->{order_line_details};

    foreach my $order_detail ( @{$order_line_details} ) {
        my @itemnumbers = $order_detail->{itemnumbers} || ();
        delete( $order_detail->{itemnumbers} );
        my $order = Koha::Acquisition::Order->new( \%{$order_detail} );
        $order->populate_with_prices_for_ordering();
        $order->populate_with_prices_for_receiving();
        $order->store;
        foreach my $itemnumber (@itemnumbers) {
            $order->add_item($itemnumber);
        }
    }
    return;
}

=head3 import_batches_list

Fetches import batches matching the batch to be added to the basket and adds these to the $template

Koha::MarcOrder->import_batches_list($template);

=cut

sub import_batches_list {
    my ( $self, $template ) = @_;
    my $batches = GetImportBatchRangeDesc();

    my @list = ();
    foreach my $batch (@$batches) {
        if ( $batch->{'import_status'} =~ /^staged$|^reverted$/ && $batch->{'record_type'} eq 'biblio' ) {

            # check if there is at least 1 line still staged
            my $import_records_count = Koha::Import::Records->search(
                {
                    import_batch_id => $batch->{'import_batch_id'},
                    status          => $batch->{import_status}
                }
            )->count;
            if ($import_records_count) {
                push @list, {
                    import_batch_id => $batch->{'import_batch_id'},
                    num_records     => $batch->{'num_records'},
                    num_items       => $batch->{'num_items'},
                    staged_date     => $batch->{'upload_timestamp'},
                    import_status   => $batch->{'import_status'},
                    file_name       => $batch->{'file_name'},
                    comments        => $batch->{'comments'},
                };
            } else {

                # if there are no more line to includes, set the status to imported
                # FIXME This should be removed in the future.
                SetImportBatchStatus( $batch->{'import_batch_id'}, 'imported' );
            }
        }
    }
    $template->param( batch_list => \@list );
    my $num_batches = GetNumberOfNonZ3950ImportBatches();
    $template->param( num_results => $num_batches );
}

=head3

For an import batch, this function reads the files and creates all the relevant data pertaining to that file
It then passes this to the $template variable to be shown in the UI

Koha::MarcOrder->import_biblios_list( $template, $cgiparams->{'import_batch_id'} );

=cut

sub import_biblios_list {
    my ( $self, $template, $import_batch_id ) = @_;
    my $batch = GetImportBatch( $import_batch_id, 'staged' );
    return () unless $batch and $batch->{import_status} =~ /^staged$|^reverted$/;
    my $import_records = Koha::Import::Records->search(
        {
            import_batch_id => $import_batch_id,
            status          => $batch->{import_status}
        }
    );
    my @list       = ();
    my $item_error = 0;

    my $ccodes = {
        map { $_->{authorised_value} => $_->{opac_description} }
            Koha::AuthorisedValues->get_descriptions_by_koha_field(
            { frameworkcode => '', kohafield => 'items.ccode' }
            )
    };
    my $locations = {
        map { $_->{authorised_value} => $_->{opac_description} }
            Koha::AuthorisedValues->get_descriptions_by_koha_field(
            { frameworkcode => '', kohafield => 'items.location' }
            )
    };
    my $notforloans = {
        map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field(
            { frameworkcode => '', kohafield => 'items.notforloan' }
        )
    };

    # location list
    my @locations;
    foreach ( sort keys %$locations ) {
        push @locations, { code => $_, description => "$_ - " . $locations->{$_} };
    }
    my @ccodes;
    foreach ( sort { $ccodes->{$a} cmp $ccodes->{$b} } keys %$ccodes ) {
        push @ccodes, { code => $_, description => $ccodes->{$_} };
    }
    my @notforloans;
    foreach ( sort { $notforloans->{$a} cmp $notforloans->{$b} } keys %$notforloans ) {
        push @notforloans, { code => $_, description => $notforloans->{$_} };
    }

    my $biblio_count = 0;
    while ( my $import_record = $import_records->next ) {
        my $item_id = 1;
        $biblio_count++;
        my $matches      = $import_record->get_import_record_matches( { chosen => 1 } );
        my $match        = $matches->count ? $matches->next                                               : undef;
        my $match_biblio = $match ? Koha::Biblios->find( { biblionumber => $match->candidate_match_id } ) : undef;
        my %cellrecord   = (
            import_record_id   => $import_record->import_record_id,
            import_biblio      => $import_record->import_biblio,
            import             => 1,
            status             => $import_record->status,
            record_sequence    => $import_record->record_sequence,
            overlay_status     => $import_record->overlay_status,
            match_biblionumber => $match ? $match->candidate_match_id : 0,
            match_citation     => $match_biblio
            ? ( $match_biblio->title || '' ) . ' ' . ( $match_biblio->author || '' )
            : '',
            match_score => $match ? $match->score : 0,
        );
        my $marcrecord = $import_record->get_marc_record || die "couldn't translate marc information";

        my $infos = _get_MarcFieldsToOrder_syspref_data(
            'MarcFieldsToOrder', $marcrecord,
            [ 'price', 'quantity', 'budget_code', 'discount', 'sort1', 'sort2', 'replacementprice' ]
        );
        my $price            = $infos->{price};
        my $replacementprice = $infos->{replacementprice};
        my $quantity         = $infos->{quantity};
        my $budget_code      = $infos->{budget_code};
        my $discount         = $infos->{discount};
        my $sort1            = $infos->{sort1};
        my $sort2            = $infos->{sort2};
        my $budget_id;

        if ($budget_code) {
            my $biblio_budget = GetBudgetByCode($budget_code);
            if ($biblio_budget) {
                $budget_id = $biblio_budget->{budget_id};
            }
        }

        # Items
        my @itemlist           = ();
        my $all_items_quantity = 0;
        my $alliteminfos       = _get_MarcItemFieldsToOrder_syspref_data(
            'MarcItemFieldsToOrder',
            $marcrecord,
            [
                'homebranch', 'holdingbranch', 'itype', 'nonpublic_note',   'public_note', 'loc', 'ccode', 'notforloan',
                'uri',        'copyno',        'price', 'replacementprice', 'itemcallnumber', 'quantity', 'budget_code'
            ]
        );
        if ( !$alliteminfos || %$alliteminfos != -1 ) {
            my $item_homebranch     = $alliteminfos->{homebranch};
            my $item_holdingbranch  = $alliteminfos->{holdingbranch};
            my $item_itype          = $alliteminfos->{itype};
            my $item_nonpublic_note = $alliteminfos->{nonpublic_note};
            my $item_public_note    = $alliteminfos->{public_note};
            my $item_loc            = $alliteminfos->{loc};
            my $item_ccode          = $alliteminfos->{ccode};
            my $item_notforloan     = $alliteminfos->{notforloan};
            my $item_uri            = $alliteminfos->{uri};
            my $item_copyno         = $alliteminfos->{copyno};
            my $item_quantity       = $alliteminfos->{quantity} || 1;
            my $item_budget_code    = $alliteminfos->{budget_code};
            my $item_budget_id;

            if ( $alliteminfos->{budget_code} ) {
                my $item_budget = GetBudgetByCode( $alliteminfos->{budget_code} );
                if ($item_budget) {
                    $item_budget_id = $item_budget->{budget_id};
                }
            }
            my $item_price             = $alliteminfos->{price};
            my $item_replacement_price = $alliteminfos->{replacementprice};
            my $item_callnumber        = $alliteminfos->{itemcallnumber};

            for ( my $i = 0 ; $i < $item_quantity ; $i++ ) {

                my %itemrecord = (
                    'item_id'          => $item_id++,
                    'biblio_count'     => $biblio_count,
                    'homebranch'       => $item_homebranch,
                    'holdingbranch'    => $item_holdingbranch,
                    'itype'            => $item_itype,
                    'nonpublic_note'   => $item_nonpublic_note,
                    'public_note'      => $item_public_note,
                    'loc'              => $item_loc,
                    'ccode'            => $item_ccode,
                    'notforloan'       => $item_notforloan,
                    'uri'              => $item_uri,
                    'copyno'           => $item_copyno,
                    'quantity'         => $item_quantity,
                    'budget_id'        => $item_budget_id         || $budget_id,
                    'itemprice'        => $item_price             || $price,
                    'replacementprice' => $item_replacement_price || $replacementprice,
                    'itemcallnumber'   => $item_callnumber,
                );
                $all_items_quantity++;
                push @itemlist, \%itemrecord;

            }

            $cellrecord{'iteminfos'} = \@itemlist;
        } else {
            $cellrecord{'item_error'} = 1;
        }
        push @list, \%cellrecord;

        # If MarcItemFieldsToOrder is not set, we use MarcFieldsToOrder to populate the order form.
        if ( $alliteminfos || %$alliteminfos == -1 ) {
            $cellrecord{price}            = $price            || '';
            $cellrecord{replacementprice} = $replacementprice || '';
            $cellrecord{quantity}         = $quantity         || '';
            $cellrecord{budget_id}        = $budget_id        || '';
        } else {

            # When using MarcItemFields to order we want the order to have the same quantity as total items
            $cellrecord{quantity} = $all_items_quantity;
        }

        # The fields discount, sort1, and sort2 only exist at the order level, so always use MarcItemFieldsToOrder
        $cellrecord{discount} = $discount || '';
        $cellrecord{sort1}    = $sort1    || '';
        $cellrecord{sort2}    = $sort2    || '';

    }
    my $num_records    = $batch->{'num_records'};
    my $overlay_action = GetImportBatchOverlayAction($import_batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($import_batch_id);
    my $item_action    = GetImportBatchItemAction($import_batch_id);
    $template->param(
        import_biblio_list                 => \@list,
        num_results                        => $num_records,
        import_batch_id                    => $import_batch_id,
        "overlay_action_${overlay_action}" => 1,
        overlay_action                     => $overlay_action,
        "nomatch_action_${nomatch_action}" => 1,
        nomatch_action                     => $nomatch_action,
        "item_action_${item_action}"       => 1,
        item_action                        => $item_action,
        item_error                         => $item_error,
        libraries                          => Koha::Libraries->search,
        locationloop                       => \@locations,
        itemtypes                          => Koha::ItemTypes->search,
        ccodeloop                          => \@ccodes,
        notforloanloop                     => \@notforloans,
    );
    _batch_info( $template, $batch );
}

=head3

Creates a hash of information to be used about an import batch in the template

=cut

sub _batch_info {
    my ( $template, $batch ) = @_;
    $template->param(
        batch_info       => 1,
        file_name        => $batch->{'file_name'},
        comments         => $batch->{'comments'},
        import_status    => $batch->{'import_status'},
        upload_timestamp => $batch->{'upload_timestamp'},
        num_records      => $batch->{'num_records'},
        num_items        => $batch->{'num_items'}
    );
    if ( $batch->{'num_records'} > 0 ) {
        if ( $batch->{'import_status'} eq 'staged' or $batch->{'import_status'} eq 'reverted' ) {
            $template->param( can_commit => 1 );
        }
        if ( $batch->{'import_status'} eq 'imported' ) {
            $template->param( can_revert => 1 );
        }
    }
    if ( defined $batch->{'matcher_id'} ) {
        my $matcher = C4::Matcher->fetch( $batch->{'matcher_id'} );
        if ( defined $matcher ) {
            $template->param(
                'current_matcher_id'          => $batch->{'matcher_id'},
                'current_matcher_code'        => $matcher->code(),
                'current_matcher_description' => $matcher->description()
            );
        }
    }
    _add_matcher_list( $batch->{'matcher_id'}, $template );
}

=head3

Adds a list of available matchers based on an import batch

=cut

sub _add_matcher_list {
    my ( $current_matcher_id, $template ) = @_;
    my @matchers = C4::Matcher::GetMatcherList();
    if ( defined $current_matcher_id ) {
        for ( my $i = 0 ; $i <= $#matchers ; $i++ ) {
            if ( $matchers[$i]->{'matcher_id'} == $current_matcher_id ) {
                $matchers[$i]->{'selected'} = 1;
            }
        }
    }
    $template->param( available_matchers => \@matchers );
}

1;
