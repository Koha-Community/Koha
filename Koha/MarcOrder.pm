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
    GetImportBatchRangeDesc
    GetNumberOfNonZ3950ImportBatches
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

    my $result = add_biblio_from_import_record(
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

=head3 _get_syspref_mappings

    my $syspref_info = _get_syspref_mappings( $marcrecord, $syspref_name );

    Fetches data from a marc record based on the mappings in the syspref MarcFieldsToOrder or MarcItemFieldsToOrder using the fields selected in $fields (array).

=cut

sub _get_syspref_mappings {
    my ($record, $syspref_to_read) = @_;
    my $syspref = C4::Context->yaml_preference($syspref_to_read);
    my @result;
    my @tags_list;

    # Check tags in syspref definition
    for my $field_name ( keys %$syspref ) {
        my @fields = split /\|/, $syspref->{$field_name};
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
            for my $field_name ( keys %$syspref ) {
                my @fields = split /\|/, $syspref->{$field_name};
                for my $field (@fields) {
                    my ( $f, $sf ) = split /\$/, $field;
                    next unless $f and $sf;
                    my $v = $fields_hash->{$f}[$i] ? $fields_hash->{$f}[$i]->subfield($sf) : undef;
                    $r->{$field_name} = $v if ( defined $v );
                    last if $syspref->{$field};
                }
            }
            push @result, $r;
        }
    }
    return \@result if $syspref_to_read eq 'MarcItemFieldsToOrder';
    return $result[0] if $syspref_to_read eq 'MarcFieldsToOrder';
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

=head3 add_biblio_from_import_record

    my ($record_results, $duplicates_in_batch) = add_biblio_from_import_record({
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

sub add_biblio_from_import_record {
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

    if ( $agent eq 'cron' ) {
        my $marc_fields_to_order      = _get_syspref_mappings( $marcrecord, 'MarcFieldsToOrder' );
        my $marc_item_fields_to_order = _get_syspref_mappings( $marcrecord, 'MarcItemFieldsToOrder' );

        my $item_fields = {
            homebranch       => $marc_item_fields_to_order->{homebranch},
            holdingbranch    => $marc_item_fields_to_order->{holdingbranch},
            itype            => $marc_item_fields_to_order->{itype},
            nonpublic_note   => $marc_item_fields_to_order->{nonpublic_note},
            public_note      => $marc_item_fields_to_order->{public_note},
            loc              => $marc_item_fields_to_order->{loc},
            ccode            => $marc_item_fields_to_order->{ccode},
            notforloan       => $marc_item_fields_to_order->{notforloan},
            uri              => $marc_item_fields_to_order->{uri},
            copyno           => $marc_item_fields_to_order->{copyno},
            quantity         => $marc_item_fields_to_order->{quantity},
            price            => $marc_item_fields_to_order->{price},
            replacementprice => $marc_item_fields_to_order->{replacementprice},
            itemcallnumber   => $marc_item_fields_to_order->{itemcallnumber},
            budget_code      => $marc_item_fields_to_order->{budget_code},
            c_quantity       => $marc_fields_to_order->{quantity},
            c_budget_code    => $marc_fields_to_order->{budget_code},
            c_price          => $marc_fields_to_order->{price},
            c_discount       => $marc_fields_to_order->{discount},
            c_sort1          => $marc_fields_to_order->{sort1},
            c_sort2          => $marc_fields_to_order->{sort2},
        };

        my $order_line_fields = parse_input_into_order_line_fields(
            {
                agent        => $agent,
                biblionumber => $biblionumber,
                budget_id    => $budget_id,
                basket_id    => $basket_id,
                fields       => $item_fields,
                marcrecord   => $marcrecord,
            }
        );

        my $order_line_details = create_items_and_generate_order_hash(
            {
                fields          => $order_line_fields,
                vendor          => $vendor,
                agent           => $agent,
                active_currency => $active_currency,
            }
        );

        return $order_line_details;
    }

    if ( $agent eq 'client' ) {
        my $order_line_fields = parse_input_into_order_line_fields(
            {
                agent        => $agent,
                biblionumber => $biblionumber,
                budget_id    => $budget_id,
                basket_id    => $basket_id,
                fields       => $client_item_fields,
                marcrecord   => $marcrecord,
            }
        );

        my $order_line_details = create_items_and_generate_order_hash(
            {
                fields          => $order_line_fields,
                vendor          => $vendor,
                agent           => $agent,
                active_currency => $active_currency,
            }
        );

        return $order_line_details;
    }
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

Fetches import batches matching the batch to be added to the basket and returns these to the template

Koha::MarcOrder->import_batches_list();

=cut

sub import_batches_list {
    my ($self) = @_;
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
    my $num_batches = GetNumberOfNonZ3950ImportBatches();

    return {
        list        => \@list,
        num_results => $num_batches
    };
}

=head3 import_biblios_list

For an import batch, this function reads the files and creates all the relevant data pertaining to that file
It then returns this to the template to be shown in the UI

Koha::MarcOrder->import_biblios_list( $cgiparams->{'import_batch_id'} );

=cut

sub import_biblios_list {
    my ( $self, $import_batch_id ) = @_;
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

        my $infos = _get_syspref_mappings( $marcrecord, 'MarcFieldsToOrder' );

        my $price            = $infos->{price} || undef;
        my $replacementprice = $infos->{replacementprice} || undef;
        my $quantity         = $infos->{quantity} || undef;
        my $budget_code      = $infos->{budget_code} || undef;
        my $discount         = $infos->{discount} || undef;
        my $sort1            = $infos->{sort1} || undef;
        my $sort2            = $infos->{sort2} || undef;
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
        my $alliteminfos = _get_syspref_mappings( $marcrecord, 'MarcItemFieldsToOrder' );

        if ( $alliteminfos != -1 ) {
            foreach my $iteminfos (@$alliteminfos) {
                # Quantity is required, default to one if not supplied
                my $quantity = delete $iteminfos->{quantity} || 1;

                # Handle incorrectly named original parameters for MarcItemFieldsToOrder
                $iteminfos->{location}   = delete $iteminfos->{loc}    if $iteminfos->{loc};
                $iteminfos->{copynumber} = delete $iteminfos->{copyno} if $iteminfos->{copyno};

                # Convert budget code to a budget id
                my $item_budget_code = delete $iteminfos->{budget_code};
                if ($item_budget_code) {
                    my $item_budget = GetBudgetByCode($item_budget_code);
                    $iteminfos->{budget_id} = $item_budget->{budget_id} || $budget_id;
                }

                # Clone the item data for the needed quantity
                # Add the incremented item id for each item in that quantity
                for ( my $i = 0 ; $i < $quantity ; $i++ ) {
                    my $itemrecord = {%$iteminfos};
                    $itemrecord->{item_id} = $item_id++;

                    $all_items_quantity++;
                    push @itemlist, $itemrecord;
                }
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
    my $result         = {
        import_biblio_list => \@list,
        num_results        => $num_records,
        import_batch_id    => $import_batch_id,
        overlay_action     => $overlay_action,
        nomatch_action     => $nomatch_action,
        item_action        => $item_action,
        item_error         => $item_error,
        locationloop       => \@locations,
        ccodeloop          => \@ccodes,
        notforloanloop     => \@notforloans,
        batch              => $batch,
    };

    if ( $batch->{'num_records'} > 0 ) {
        if ( $batch->{'import_status'} eq 'staged' or $batch->{'import_status'} eq 'reverted' ) {
            $result->{can_commit} = 1;
        }
        if ( $batch->{'import_status'} eq 'imported' ) {
            $result->{can_revert} = 1;
        }
    }
    if ( defined $batch->{'matcher_id'} ) {
        my $matcher = C4::Matcher->fetch( $batch->{'matcher_id'} );
        if ( defined $matcher ) {
            $result->{'current_matcher_id'}          = $batch->{'matcher_id'};
            $result->{'current_matcher_code'}        = $matcher->code();
            $result->{'current_matcher_description'} = $matcher->description();
        }
    }

    my @matchers = C4::Matcher::GetMatcherList();
    if ( defined $batch->{'matcher_id'} ) {
        for ( my $i = 0 ; $i <= $#matchers ; $i++ ) {
            if ( $matchers[$i]->{'matcher_id'} == $batch->{'matcher_id'} ) {
                $matchers[$i]->{'selected'} = 1;
            }
        }
    }
    $result->{available_matchers} = \@matchers;

    return $result;
}

=head3 parse_input_into_order_line_fields

This function takes inputs from either the cronjob or UI and then parses that into a single set of order line fields that can be used to create items and order lines

my $order_line_fields = parse_input_into_order_line_fields(
    {
        agent        => $agent,
        biblionumber => $biblionumber,
        budget_id    => $budget_id,
        basket_id    => $basket_id,
        fields       => $item_fields,
        marcrecord   => $marcrecord,
    }
);


=cut

sub parse_input_into_order_line_fields {
    my ($args) = @_;

    my $agent        = $args->{agent};
    my $client       = $agent eq 'client' ? 1 : 0;
    my $biblionumber = $args->{biblionumber};
    my $budget_id    = $args->{budget_id};
    my $basket_id    = $args->{basket_id};
    my $fields       = $args->{fields};
    my $marcrecord   = $args->{marcrecord};

    my $quantity        = $fields->{quantity} || 1;
    my @homebranches    = $client ? @{ $fields->{homebranches} }    : ( ( $fields->{homebranch} ) x $quantity );
    my @holdingbranches = $client ? @{ $fields->{holdingbranches} } : ( ( $fields->{holdingbranch} ) x $quantity );
    my @itypes          = $client ? @{ $fields->{itypes} }          : ( ( $fields->{itype} ) x $quantity );
    my @nonpublic_notes = $client ? @{ $fields->{nonpublic_notes} } : ( ( $fields->{nonpublic_note} ) x $quantity );
    my @public_notes    = $client ? @{ $fields->{public_notes} }    : ( ( $fields->{public_note} ) x $quantity );
    my @locs            = $client ? @{ $fields->{locs} }            : ( ( $fields->{loc} ) x $quantity );
    my @ccodes          = $client ? @{ $fields->{ccodes} }          : ( ( $fields->{ccode} ) x $quantity );
    my @notforloans     = $client ? @{ $fields->{notforloans} }     : ( ( $fields->{notforloan} ) x $quantity );
    my @uris            = $client ? @{ $fields->{uris} }            : ( ( $fields->{uri} ) x $quantity );
    my @copynos         = $client ? @{ $fields->{copynos} }         : ( ( $fields->{copyno} ) x $quantity );
    my @itemprices      = $client ? @{ $fields->{itemprices} }      : ( ( $fields->{price} ) x $quantity );
    my @replacementprices =
        $client ? @{ $fields->{replacementprices} } : ( ( $fields->{replacementprice} ) x $quantity );
    my @itemcallnumbers = $client ? @{ $fields->{itemcallnumbers} } : ( ( $fields->{itemcallnumber} ) x $quantity );
    my @coded_location_qualifiers =
        $client ? @{ $fields->{coded_location_qualifiers} } : ( ( $fields->{coded_location_qualifier} ) x $quantity );
    my @barcodes            = $client ? @{ $fields->{barcodes} }       : ( ( $fields->{barcode} ) x $quantity );
    my @enumchrons          = $client ? @{ $fields->{enumchrons} }     : ( ( $fields->{enumchron} ) x $quantity );
    my $c_quantity          = $client ? $fields->{c_quantity}          : $fields->{c_quantity};
    my $c_budget_id         = $client ? $fields->{c_budget_id}         : $fields->{c_budget_id};
    my $c_discount          = $client ? $fields->{c_discount}          : $fields->{c_discount};
    my $c_sort1             = $client ? $fields->{c_sort1}             : $fields->{c_sort1};
    my $c_sort2             = $client ? $fields->{c_sort2}             : $fields->{c_sort2};
    my $c_replacement_price = $client ? $fields->{c_replacement_price} : $fields->{c_replacement_price};
    my $c_price             = $client ? $fields->{c_price}             : $fields->{c_price};

    # If using the cronjob, we want to default to the account budget if not mapped on the record
    my $item_budget_id;
    if ( !$client && ( $fields->{budget_code} || $fields->{c_budget_code} ) ) {
        my $budget_code = $fields->{budget_code} || $fields->{c_budget_code};
        my $item_budget = GetBudgetByCode($budget_code);
        if ($item_budget) {
            $item_budget_id = $item_budget->{budget_id};
        } else {
            $item_budget_id = $budget_id;
        }
    } else {
        $item_budget_id = $budget_id;
    }
    my @budget_codes = $client ? @{ $fields->{budget_codes} } : ($item_budget_id);
    my $loop_limit   = $client ? scalar(@homebranches)        : $quantity;

    my $order_line_fields = {
        biblionumber             => $biblionumber,
        homebranch               => \@homebranches,
        holdingbranch            => \@holdingbranches,
        itemnotes_nonpublic      => \@nonpublic_notes,
        itemnotes                => \@public_notes,
        location                 => \@locs,
        ccode                    => \@ccodes,
        itype                    => \@itypes,
        notforloan               => \@notforloans,
        uri                      => \@uris,
        copynumber               => \@copynos,
        price                    => \@itemprices,
        replacementprice         => \@replacementprices,
        itemcallnumber           => \@itemcallnumbers,
        coded_location_qualifier => \@coded_location_qualifiers,
        barcode                  => \@barcodes,
        enumchron                => \@enumchrons,
        budget_code              => \@budget_codes,
        loop_limit               => $loop_limit,
        basket_id                => $basket_id,
        budget_id                => $budget_id,
        c_quantity               => $c_quantity,
        c_budget_id              => $c_budget_id,
        c_discount               => $c_discount,
        c_sort1                  => $c_sort1,
        c_sort2                  => $c_sort2,
        c_replacement_price      => $c_replacement_price,
        c_price                  => $c_price,
        marcrecord               => $marcrecord,
    };

    if($client) {
        $order_line_fields->{tags}               = $fields->{tags};
        $order_line_fields->{subfields}          = $fields->{subfields};
        $order_line_fields->{field_values}       = $fields->{field_values};
        $order_line_fields->{serials}            = $fields->{serials};
        $order_line_fields->{order_vendornote}   = $fields->{order_vendornote};
        $order_line_fields->{order_internalnote} = $fields->{order_internalnote};
        $order_line_fields->{all_currency}       = $fields->{all_currency};
    }

    return $order_line_fields;
}

=head3 create_items_and_generate_order_hash

This method is used from both the cronjob and the UI to create items and generate order line details for those new items

my $order_line_details = create_items_and_generate_order_hash(
    {
        fields          => $order_line_fields,
        vendor          => $vendor,
        agent           => $agent,
        active_currency => $active_currency,
    }
);

=cut

sub create_items_and_generate_order_hash {
    my ($args) = @_;

    my $agent           = $args->{agent};
    my $fields          = $args->{fields};
    my $loop_limit      = $fields->{loop_limit};
    my $basket_id       = $fields->{basket_id};
    my $budget_id       = $fields->{budget_id};
    my $vendor          = $args->{vendor};
    my $active_currency = $args->{active_currency};
    my @order_line_details;
    my $itemcreation = 0;
    my @itemnumbers;

    for ( my $i = 0 ; $i < $loop_limit ; $i++ ) {
        $itemcreation = 1;
        my $item = Koha::Item->new(
            {
                biblionumber             => $fields->{biblionumber},
                homebranch               => @{ $fields->{homebranch} }[$i],
                holdingbranch            => @{ $fields->{holdingbranch} }[$i],
                itemnotes_nonpublic      => @{ $fields->{itemnotes_nonpublic} }[$i],
                itemnotes                => @{ $fields->{itemnotes} }[$i],
                location                 => @{ $fields->{location} }[$i],
                ccode                    => @{ $fields->{ccode} }[$i],
                itype                    => @{ $fields->{itype} }[$i],
                notforloan               => @{ $fields->{notforloan} }[$i],
                uri                      => @{ $fields->{uri} }[$i],
                copynumber               => @{ $fields->{copynumber} }[$i],
                price                    => @{ $fields->{price} }[$i],
                replacementprice         => @{ $fields->{replacementprice} }[$i],
                itemcallnumber           => @{ $fields->{itemcallnumber} }[$i],
                coded_location_qualifier => @{ $fields->{coded_location_qualifier} }[$i],
                barcode                  => @{ $fields->{barcode} }[$i],
                enumchron                => @{ $fields->{enumchron} }[$i],
            }
        )->store;
        push( @itemnumbers, $item->itemnumber );
    }

    if ( $itemcreation == 1 ) {
        # Group orderlines from MarcItemFieldsToOrder
        my $budget_hash;
        my @budget_ids = @{ $fields->{budget_code} };
        for ( my $i = 0 ; $i < $loop_limit ; $i++ ) {
            $budget_ids[$i] = $budget_id if !$budget_ids[$i];   # Use default budget if no budget provided
            $budget_hash->{ $budget_ids[$i] }->{quantity} += 1;
            $budget_hash->{ $budget_ids[$i] }->{price} = @{ $fields->{price} }[$i];
            $budget_hash->{ $budget_ids[$i] }->{replacementprice} =
                @{ $fields->{replacementprice} }[$i];
            $budget_hash->{ $budget_ids[$i] }->{itemnumbers} //= [];
            push @{ $budget_hash->{ $budget_ids[$i] }->{itemnumbers} },
                $itemnumbers[$i];
        }

        # Create orderlines from MarcItemFieldsToOrder
        while ( my ( $budget_id, $infos ) = each %$budget_hash ) {
            if ($budget_id) {
                my %orderinfo = (
                    biblionumber => $fields->{biblionumber},
                    basketno     => $basket_id,
                    quantity     => $infos->{quantity},
                    budget_id    => $budget_id,
                    currency     => $active_currency->currency,
                );

                my $price = $infos->{price};
                if ($price) {
                    $price                            = _format_price_to_CurrencyFormat_syspref($price);
                    $price                            = Koha::Number::Price->new($price)->unformat;
                    $orderinfo{tax_rate_on_ordering}  = $vendor->tax_rate;
                    $orderinfo{tax_rate_on_receiving} = $vendor->tax_rate;
                    my $order_discount = $fields->{c_discount} ? $fields->{c_discount} : $vendor->discount;
                    $orderinfo{discount}  = $order_discount;
                    $orderinfo{rrp}       = $price;
                    $orderinfo{ecost}     = $order_discount ? $price * ( 1 - $order_discount / 100 ) : $price;
                    $orderinfo{listprice} = $orderinfo{rrp} / $active_currency->rate;
                    $orderinfo{unitprice} = $orderinfo{ecost};
                    $orderinfo{sort1}     = $fields->{c_sort1};
                    $orderinfo{sort2}     = $fields->{c_sort2};
                } else {
                    $orderinfo{listprice} = 0;
                }
                $orderinfo{replacementprice} = $infos->{replacementprice} || 0;

                # Remove uncertainprice flag if we have found a price in the MARC record
                $orderinfo{uncertainprice} = 0 if $orderinfo{listprice};

                my $order = Koha::Acquisition::Order->new( \%orderinfo );
                $order->populate_with_prices_for_ordering();
                $order->populate_with_prices_for_receiving();
                $order->store;
                $order->add_item($_) for @{ $budget_hash->{$budget_id}->{itemnumbers} };
            }
        }
    } else {
        # Add an orderline for each MARC record
        # Get quantity in the MARC record (1 if none)
        my $quantity  = GetMarcQuantity( $fields->{marcrecord}, C4::Context->preference('marcflavour') ) || 1;
        my %orderinfo = (
            biblionumber       => $fields->{biblionumber},
            basketno           => $basket_id,
            quantity           => $fields->{c_quantity},
            branchcode         => C4::Context->userenv()->{'branch'},
            budget_id          => $fields->{c_budget_id},
            uncertainprice     => 1,
            sort1              => $fields->{c_sort1},
            sort2              => $fields->{c_sort2},
            order_internalnote => $fields->{order_internalnote},
            order_vendornote   => $fields->{order_vendornote},
            currency           => $fields->{all_currency},
            replacementprice   => $fields->{c_replacement_price},
        );

        # Get the price if there is one.
        if ($fields->{c_price}) {
            $fields->{c_price} = _format_price_to_CurrencyFormat_syspref($fields->{c_price});
            $fields->{c_price}                = Koha::Number::Price->new( $fields->{c_price} )->unformat;
            $orderinfo{tax_rate_on_ordering}  = $vendor->tax_rate;
            $orderinfo{tax_rate_on_receiving} = $vendor->tax_rate;
            my $order_discount = $fields->{c_discount} ? $fields->{c_discount} : $vendor->discount;
            $orderinfo{discount} = $order_discount;
            $orderinfo{rrp}      = $fields->{c_price};
            $orderinfo{ecost} =
                $order_discount ? $fields->{c_price} * ( 1 - $order_discount / 100 ) : $fields->{c_price};
            $orderinfo{listprice} = $orderinfo{rrp} / $active_currency->rate;
            $orderinfo{unitprice} = $orderinfo{ecost};
        } else {
            $orderinfo{listprice} = 0;
        }

        # Remove uncertainprice flag if we have found a price in the MARC record
        $orderinfo{uncertainprice} = 0 if $orderinfo{listprice};

        my $order = Koha::Acquisition::Order->new( \%orderinfo );
        $order->populate_with_prices_for_ordering();
        $order->populate_with_prices_for_receiving();
        $order->store;

        my $basket = Koha::Acquisition::Baskets->find( $basket_id );
        if ( $basket->effective_create_items eq 'ordering' && !$basket->is_standing ) {
            my @tags         = @{ $fields->{tags} };
            my @subfields    = @{ $fields->{subfields} };
            my @field_values = @{ $fields->{field_values} };
            my @serials      = @{ $fields->{serials} };
            my $xml          = TransformHtmlToXml( \@tags, \@subfields, \@field_values );
            my $record       = MARC::Record::new_from_xml( $xml, 'UTF-8' );
            for ( my $qtyloop = 1 ; $qtyloop <= $fields->{c_quantity} ; $qtyloop++ ) {
                my ( $biblionumber, undef, $itemnumber ) = AddItemFromMarc( $fields->{marcrecord}, $fields->{biblionumber} );
                $order->add_item($itemnumber);
            }
        }
    }

    return \@order_line_details;
}

=head3 _format_price_to_CurrencyFormat_syspref

In France, the cents separator is the ',' but sometimes a '.' is used
In this case, the price will be x100 when unformatted
The '.' needs replacing by a ',' to get a proper price calculation

=cut

sub _format_price_to_CurrencyFormat_syspref {
    my ($price) = @_;

    $price =~ s/\./,/ if C4::Context->preference("CurrencyFormat") eq "FR";
    return $price;
}

1;
