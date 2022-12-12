#!/usr/bin/perl

#A script that lets the user populate a basket from an iso2709 file
#the script first displays a list of import batches, then when a batch is selected displays all the biblios in it.
#The user can then pick which biblios they want to order

# Copyright 2008 - 2011 BibLibre SARL
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
use CGI qw ( -utf8 );
use YAML::XS;
use List::MoreUtils;
use Encode;

use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::ImportBatch qw( SetImportBatchStatus GetImportBatch GetImportBatchRangeDesc GetNumberOfNonZ3950ImportBatches GetImportBatchOverlayAction GetImportBatchNoMatchAction GetImportBatchItemAction );
use C4::Matcher;
use C4::Search qw( FindDuplicate );
use C4::Biblio qw(
    AddBiblio
    GetMarcFromKohaField
    GetMarcPrice
    GetMarcQuantity
    TransformHtmlToXml
);
use C4::Items qw( PrepareItemrecordDisplay AddItemFromMarc );
use C4::Budgets qw( GetBudget GetBudgets GetBudgetHierarchy CanUserUseBudget GetBudgetByCode );
use C4::Suggestions;    # GetSuggestion
use C4::Members;

use Koha::Number::Price;
use Koha::Libraries;
use Koha::Acquisition::Baskets;
use Koha::Acquisition::Currencies;
use Koha::Acquisition::Orders;
use Koha::Acquisition::Booksellers;
use Koha::ImportBatches;
use Koha::Import::Records;
use Koha::Patrons;

my $input = CGI->new;
my ($template, $loggedinuser, $cookie, $userflags) = get_template_and_user({
    template_name => "acqui/addorderiso2709.tt",
    query => $input,
    type => "intranet",
    flagsrequired   => { acquisition => 'order_manage' },
});

my $cgiparams = $input->Vars;
my $op = $cgiparams->{'op'} || '';
my $booksellerid  = $input->param('booksellerid');
my $allmatch = $input->param('allmatch');
my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );

$template->param(scriptname => "/cgi-bin/koha/acqui/addorderiso2709.pl",
                booksellerid => $booksellerid,
                booksellername => $bookseller->name,
                );

if ($cgiparams->{'import_batch_id'} && $op eq ""){
    $op = "batch_details";
}

#Needed parameters:
if (! $cgiparams->{'basketno'}){
    die "Basketnumber required to order from iso2709 file import";
}
my $basket = Koha::Acquisition::Baskets->find( $cgiparams->{basketno} );

#
# 1st step = choose the file to import into acquisition
#
if ($op eq ""){
    $template->param("basketno" => $cgiparams->{'basketno'});
#display batches
    import_batches_list($template);
#
# 2nd step = display the content of the chosen file
#
} elsif ($op eq "batch_details"){
#display lines inside the selected batch

    $template->param("batch_details" => 1,
                     "basketno"      => $cgiparams->{'basketno'},
                     # get currencies (for change rates calcs if needed)
                     currencies => Koha::Acquisition::Currencies->search,
                     bookseller => $bookseller,
                     "allmatch" => $allmatch,
                     );
    import_biblios_list($template, $cgiparams->{'import_batch_id'});
    if ( $basket->effective_create_items eq 'ordering' && !$basket->is_standing ) {
        # prepare empty item form
        my $cell = PrepareItemrecordDisplay( '', '', undef, 'ACQ' );

        #     warn "==> ".Data::Dumper::Dumper($cell);
        unless ($cell) {
            $cell = PrepareItemrecordDisplay( '', '', undef, '' );
            $template->param( 'NoACQframework' => 1 );
        }
        my @itemloop;
        push @itemloop, $cell;

        $template->param( items => \@itemloop );
    }
#
# 3rd step = import the records
#
} elsif ( $op eq 'import_records' ) {
#import selected lines
    $template->param('basketno' => $cgiparams->{'basketno'});
# Budget_id is mandatory for adding an order, we just add a default, the user needs to modify this aftewards
    my $budgets = GetBudgets();
    if (scalar @$budgets == 0){
        die "No budgets defined, can't continue";
    }
    my $budget_id = @$budgets[0]->{'budget_id'};
#get all records from a batch, and check their import status to see if they are checked.
#(default values: quantity 1, uncertainprice yes, first budget)

    # retrieve the file you want to import
    my $import_batch_id = $cgiparams->{'import_batch_id'};
    my $import_batch = Koha::ImportBatches->find( $import_batch_id );
    my $overlay_action = $import_batch->overlay_action;
    my $import_records = Koha::Import::Records->search({
        import_batch_id => $import_batch_id,
    });
    my $duplinbatch;
    my $imported = 0;
    my @import_record_id_selected = $input->multi_param("import_record_id");
    my @quantities = $input->multi_param('quantity');
    my @prices = $input->multi_param('price');
    my @orderreplacementprices = $input->multi_param('replacementprice');
    my @budgets_id = $input->multi_param('budget_id');
    my @discount = $input->multi_param('discount');
    my @sort1 = $input->multi_param('sort1');
    my @sort2 = $input->multi_param('sort2');
    my $matcher_id = $input->param('matcher_id');
    my $active_currency = Koha::Acquisition::Currencies->get_active;
    my $biblio_count = 0;
    while( my $import_record = $import_records->next ){
        $biblio_count++;
        my $duplifound = 0;
        # Check if this import_record_id was selected
        next if not grep { $_ eq $import_record->import_record_id } @import_record_id_selected;
        my $marcrecord = $import_record->get_marc_record || die "couldn't translate marc information";
        my $matches = $import_record->get_import_record_matches({ chosen => 1 });
        my $match = $matches->count ? $matches->next : undef;
        my $biblionumber = $match ? $match->candidate_match_id : 0;
        my $c_quantity = shift( @quantities ) || GetMarcQuantity($marcrecord, C4::Context->preference('marcflavour') ) || 1;
        my $c_budget_id = shift( @budgets_id ) || $input->param('all_budget_id') || $budget_id;
        my $c_discount = shift ( @discount);
        my $c_sort1 = shift( @sort1 ) || $input->param('all_sort1') || '';
        my $c_sort2 = shift( @sort2 ) || $input->param('all_sort2') || '';
        my $c_replacement_price = shift( @orderreplacementprices );
        my $c_price = shift( @prices ) || GetMarcPrice($marcrecord, C4::Context->preference('marcflavour'));

        # Insert the biblio, or find it through matcher
        if ( $biblionumber ) { # If matched during staging we can continue
            $import_record->status('imported')->store;
            if( $overlay_action eq 'replace' ){
                my $biblio = Koha::Biblios->find( $biblionumber );
                $import_record->replace({ biblio => $biblio });
            }
        } else { # Otherwise we check for duplicates, and skip if they exist
            if ($matcher_id) {
                if ( $matcher_id eq '_TITLE_AUTHOR_' ) {
                    $duplifound = 1 if FindDuplicate($marcrecord);
                }
                else {
                    my $matcher = C4::Matcher->fetch($matcher_id);
                    my @matches = $matcher->get_matches( $marcrecord, my $max_matches = 1 );
                    $duplifound = 1 if @matches;
                }

                $duplinbatch = $import_batch_id and next if $duplifound;
            }

            # remove hyphens (-) from ISBN
            # FIXME: This should probably be optional
            my ( $isbnfield, $isbnsubfield ) = GetMarcFromKohaField( 'biblioitems.isbn' );
            if ( $marcrecord->field($isbnfield) ) {
                foreach my $field ( $marcrecord->field($isbnfield) ) {
                    foreach my $subfield ( $field->subfield($isbnsubfield) ) {
                        my $newisbn = $field->subfield($isbnsubfield);
                        $newisbn =~ s/-//g;
                        $field->update( $isbnsubfield => $newisbn );
                    }
                }
            }

            # add the biblio
            ( $biblionumber, undef ) = AddBiblio( $marcrecord, $cgiparams->{'frameworkcode'} || '' );
            $import_record->status('imported')->store;
        }

        $import_record->import_biblio->matched_biblionumber($biblionumber)->store;

        # Add items from MarcItemFieldsToOrder
        my @homebranches = $input->multi_param('homebranch_' . $import_record->import_record_id);
        my $count = scalar @homebranches;
        my @holdingbranches = $input->multi_param('holdingbranch_' . $import_record->import_record_id);
        my @itypes = $input->multi_param('itype_' . $import_record->import_record_id);
        my @nonpublic_notes = $input->multi_param('nonpublic_note_' . $import_record->import_record_id);
        my @public_notes = $input->multi_param('public_note_' . $import_record->import_record_id);
        my @locs = $input->multi_param('loc_' . $import_record->import_record_id);
        my @ccodes = $input->multi_param('ccode_' . $import_record->import_record_id);
        my @notforloans = $input->multi_param('notforloan_' . $import_record->import_record_id);
        my @uris = $input->multi_param('uri_' . $import_record->import_record_id);
        my @copynos = $input->multi_param('copyno_' . $import_record->import_record_id);
        my @budget_codes = $input->multi_param('budget_code_' . $import_record->import_record_id);
        my @itemprices = $input->multi_param('itemprice_' . $import_record->import_record_id);
        my @replacementprices = $input->multi_param('replacementprice_' . $import_record->import_record_id);
        my @itemcallnumbers = $input->multi_param('itemcallnumber_' . $import_record->import_record_id);
        my $itemcreation = 0;

        my @itemnumbers;
        for (my $i = 0; $i < $count; $i++) {
            $itemcreation = 1;
            my $item = Koha::Item->new(
                {
                    biblionumber        => $biblionumber,
                    homebranch          => $homebranches[$i],
                    holdingbranch       => $holdingbranches[$i],
                    itemnotes_nonpublic => $nonpublic_notes[$i],
                    itemnotes           => $public_notes[$i],
                    location            => $locs[$i],
                    ccode               => $ccodes[$i],
                    itype               => $itypes[$i],
                    notforloan          => $notforloans[$i],
                    uri                 => $uris[$i],
                    copynumber          => $copynos[$i],
                    price               => $itemprices[$i],
                    replacementprice    => $replacementprices[$i],
                    itemcallnumber      => $itemcallnumbers[$i],
                }
            )->store;
            push( @itemnumbers, $item->itemnumber );
        }
        if ($itemcreation == 1) {
            # Group orderlines from MarcItemFieldsToOrder
            my $budget_hash;
            for (my $i = 0; $i < $count; $i++) {
                $budget_hash->{$budget_codes[$i]}->{quantity} += 1;
                $budget_hash->{$budget_codes[$i]}->{price} = $itemprices[$i];
                $budget_hash->{$budget_codes[$i]}->{replacementprice} = $replacementprices[$i];
                $budget_hash->{$budget_codes[$i]}->{itemnumbers} //= [];
                push @{ $budget_hash->{$budget_codes[$i]}->{itemnumbers} }, $itemnumbers[$i];
            }

            # Create orderlines from MarcItemFieldsToOrder
            while(my ($budget_id, $infos) = each %$budget_hash) {
                if ($budget_id) {
                    my %orderinfo = (
                        biblionumber       => $biblionumber,
                        basketno           => $cgiparams->{'basketno'},
                        quantity           => $infos->{quantity},
                        budget_id          => $budget_id,
                        currency           => $cgiparams->{'all_currency'},
                    );

                    my $price = $infos->{price};
                    if ($price){
                        # in France, the cents separator is the , but sometimes, ppl use a .
                        # in this case, the price will be x100 when unformatted ! Replace the . by a , to get a proper price calculation
                        $price =~ s/\./,/ if C4::Context->preference("CurrencyFormat") eq "FR";
                        $price = Koha::Number::Price->new($price)->unformat;
                        $orderinfo{tax_rate_on_ordering} = $bookseller->tax_rate;
                        $orderinfo{tax_rate_on_receiving} = $bookseller->tax_rate;
                        my $order_discount = $c_discount ? $c_discount : $bookseller->discount;
                        $orderinfo{discount} = $order_discount;
                        $orderinfo{rrp} = $price;
                        $orderinfo{ecost} = $order_discount ? $price * ( 1 - $order_discount / 100 ) : $price;
                        $orderinfo{listprice} = $orderinfo{rrp} / $active_currency->rate;
                        $orderinfo{unitprice} = $orderinfo{ecost};
                    } else {
                        $orderinfo{listprice} = 0;
                    }
                    $orderinfo{replacementprice} = $infos->{replacementprice} || 0;

                    # remove uncertainprice flag if we have found a price in the MARC record
                    $orderinfo{uncertainprice} = 0 if $orderinfo{listprice};

                    my $order = Koha::Acquisition::Order->new( \%orderinfo );
                    $order->populate_with_prices_for_ordering();
                    $order->populate_with_prices_for_receiving();
                    $order->store;
                    $order->add_item( $_ ) for @{ $budget_hash->{$budget_id}->{itemnumbers} };
                }
            }
        } else {
            # 3rd add order
            my $patron = Koha::Patrons->find( $loggedinuser );
            # get quantity in the MARC record (1 if none)
            my $quantity = GetMarcQuantity($marcrecord, C4::Context->preference('marcflavour')) || 1;
            my %orderinfo = (
                biblionumber       => $biblionumber,
                basketno           => $cgiparams->{'basketno'},
                quantity           => $c_quantity,
                branchcode         => $patron->branchcode,
                budget_id          => $c_budget_id,
                uncertainprice     => 1,
                sort1              => $c_sort1,
                sort2              => $c_sort2,
                order_internalnote => $cgiparams->{'all_order_internalnote'},
                order_vendornote   => $cgiparams->{'all_order_vendornote'},
                currency           => $cgiparams->{'all_currency'},
                replacementprice   => $c_replacement_price,
            );
            # get the price if there is one.
            if ($c_price){
                # in France, the cents separator is the , but sometimes, ppl use a .
                # in this case, the price will be x100 when unformatted ! Replace the . by a , to get a proper price calculation
                $c_price =~ s/\./,/ if C4::Context->preference("CurrencyFormat") eq "FR";
                $c_price = Koha::Number::Price->new($c_price)->unformat;
                $orderinfo{tax_rate_on_ordering} = $bookseller->tax_rate;
                $orderinfo{tax_rate_on_receiving} = $bookseller->tax_rate;
                my $order_discount = $c_discount ? $c_discount : $bookseller->discount;
                $orderinfo{discount} = $order_discount;
                $orderinfo{rrp}   = $c_price;
                $orderinfo{ecost} = $order_discount ? $c_price * ( 1 - $order_discount / 100 ) : $c_price;
                $orderinfo{listprice} = $orderinfo{rrp} / $active_currency->rate;
                $orderinfo{unitprice} = $orderinfo{ecost};
            } else {
                $orderinfo{listprice} = 0;
            }

            # remove uncertainprice flag if we have found a price in the MARC record
            $orderinfo{uncertainprice} = 0 if $orderinfo{listprice};

            my $order = Koha::Acquisition::Order->new( \%orderinfo );
            $order->populate_with_prices_for_ordering();
            $order->populate_with_prices_for_receiving();
            $order->store;

            # 4th, add items if applicable
            # parse the item sent by the form, and create an item just for the import_record_id we are dealing with
            # this is not optimised, but it's working !
            if ( $basket->effective_create_items eq 'ordering' && !$basket->is_standing ) {
                my @tags         = $input->multi_param('tag');
                my @subfields    = $input->multi_param('subfield');
                my @field_values = $input->multi_param('field_value');
                my @serials      = $input->multi_param('serial');
                my $xml = TransformHtmlToXml( \@tags, \@subfields, \@field_values );
                my $record = MARC::Record::new_from_xml( $xml, 'UTF-8' );
                for (my $qtyloop=1;$qtyloop <= $c_quantity;$qtyloop++) {
                    my ( $biblionumber, undef, $itemnumber ) = AddItemFromMarc( $record, $biblionumber );
                    $order->add_item( $itemnumber );
                }
            }
        }
        $imported++;
    }

    # If all bibliographic records from the batch have been imported we modifying the status of the batch accordingly
    SetImportBatchStatus( $import_batch_id, 'imported' )
        if Koha::Import::Records->search({import_batch_id => $import_batch_id, status => 'imported' })->count
           == Koha::Import::Records->search({import_batch_id => $import_batch_id})->count;

    # go to basket page
    if ( $imported ) {
        print $input->redirect("/cgi-bin/koha/acqui/basket.pl?basketno=".$cgiparams->{'basketno'}."&amp;duplinbatch=$duplinbatch");
    } else {
        print $input->redirect("/cgi-bin/koha/acqui/addorderiso2709.pl?import_batch_id=$import_batch_id&amp;basketno=".$cgiparams->{'basketno'}."&amp;booksellerid=$booksellerid&amp;allmatch=1");
    }
    exit;
}

my $budgets = GetBudgets();
my $budget_id = @$budgets[0]->{'budget_id'};
# build bookfund list
my $patron = Koha::Patrons->find( $loggedinuser )->unblessed;
my $budget = GetBudget($budget_id);

# build budget list
my $budget_loop = [];
my $budgets_hierarchy = GetBudgetHierarchy;
foreach my $r ( @{$budgets_hierarchy} ) {
    next unless (CanUserUseBudget($patron, $r, $userflags));
    push @{$budget_loop},
      { b_id  => $r->{budget_id},
        b_txt => $r->{budget_name},
        b_code => $r->{budget_code},
        b_sort1_authcat => $r->{'sort1_authcat'},
        b_sort2_authcat => $r->{'sort2_authcat'},
        b_active => $r->{budget_period_active},
        b_sel => ( $r->{budget_id} == $budget_id ) ? 1 : 0,
      };
}

@{$budget_loop} =
  sort { uc( $a->{b_txt}) cmp uc( $b->{b_txt}) } @{$budget_loop};

$template->param( budget_loop    => $budget_loop,);

output_html_with_http_headers $input, $cookie, $template->output;


sub import_batches_list {
    my ($template) = @_;
    my $batches = GetImportBatchRangeDesc();

    my @list = ();
    foreach my $batch (@$batches) {
        if ( $batch->{'import_status'} =~ /^staged$|^reverted$/ && $batch->{'record_type'} eq 'biblio') {
            # check if there is at least 1 line still staged
            my $import_records_count = Koha::Import::Records->search({
                import_batch_id => $batch->{'import_batch_id'},
                status          => $batch->{import_status}
            })->count;
            if ( $import_records_count ) {
                push @list, {
                        import_batch_id => $batch->{'import_batch_id'},
                        num_records => $batch->{'num_records'},
                        num_items => $batch->{'num_items'},
                        staged_date => $batch->{'upload_timestamp'},
                        import_status => $batch->{'import_status'},
                        file_name => $batch->{'file_name'},
                        comments => $batch->{'comments'},
                };
            } else {
                # if there are no more line to includes, set the status to imported
                # FIXME This should be removed in the future.
                SetImportBatchStatus( $batch->{'import_batch_id'}, 'imported' );
            }
        }
    }
    $template->param(batch_list => \@list); 
    my $num_batches = GetNumberOfNonZ3950ImportBatches();
    $template->param(num_results => $num_batches);
}

sub import_biblios_list {
    my ($template, $import_batch_id) = @_;
    my $batch = GetImportBatch($import_batch_id,'staged');
    return () unless $batch and $batch->{import_status} =~ /^staged$|^reverted$/;
    my $import_records = Koha::Import::Records->search({
        import_batch_id => $import_batch_id,
        status => $batch->{import_status}
    });
    my @list = ();
    my $item_error = 0;

    my $ccodes = { map { $_->{authorised_value} => $_->{opac_description} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.ccode' } ) };
    my $locations = { map { $_->{authorised_value} => $_->{opac_description} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.location' } ) };
    my $notforloans = { map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field( { frameworkcode => '', kohafield => 'items.notforloan' } ) };
    # location list
    my @locations;
    foreach (sort keys %$locations) {
        push @locations, { code => $_, description => "$_ - " . $locations->{$_} };
    }
    my @ccodes;
    foreach (sort {$ccodes->{$a} cmp $ccodes->{$b}} keys %$ccodes) {
        push @ccodes, { code => $_, description => $ccodes->{$_} };
    }
    my @notforloans;
    foreach (sort {$notforloans->{$a} cmp $notforloans->{$b}} keys %$notforloans) {
        push @notforloans, { code => $_, description => $notforloans->{$_} };
    }

    my $biblio_count = 0;
    while ( my $import_record = $import_records->next ) {
        my $item_id = 1;
        $biblio_count++;
        my $matches = $import_record->get_import_record_matches({ chosen => 1 });
        my $match = $matches->count ? $matches->next : undef;
        my $match_biblio = $match ? Koha::Biblios->find({ biblionumber => $match->candidate_match_id }) : undef;
        my %cellrecord = (
            import_record_id => $import_record->import_record_id,
            import_biblio => $import_record->import_biblio,
            import  => 1,
            status => $import_record->status,
            record_sequence => $import_record->record_sequence,
            overlay_status => $import_record->overlay_status,
            match_biblionumber => $match ? $match->candidate_match_id : 0,
            match_citation     => $match_biblio ? ($match_biblio->title || '') . ' ' .( $match_biblio->author || ''): '',
            match_score => $match ? $match->score : 0,
        );
        my $marcrecord = $import_record->get_marc_record || die "couldn't translate marc information";

        my $infos = get_infos_syspref('MarcFieldsToOrder', $marcrecord, ['price', 'quantity', 'budget_code', 'discount', 'sort1', 'sort2','replacementprice']);
        my $price = $infos->{price};
        my $replacementprice = $infos->{replacementprice};
        my $quantity = $infos->{quantity};
        my $budget_code = $infos->{budget_code};
        my $discount = $infos->{discount};
        my $sort1 = $infos->{sort1};
        my $sort2 = $infos->{sort2};
        my $budget_id;
        if($budget_code) {
            my $biblio_budget = GetBudgetByCode($budget_code);
            if($biblio_budget) {
                $budget_id = $biblio_budget->{budget_id};
            }
        }

        # Items
        my @itemlist = ();
        my $all_items_quantity = 0;
        my $alliteminfos = get_infos_syspref_on_item('MarcItemFieldsToOrder', $marcrecord, ['homebranch', 'holdingbranch', 'itype', 'nonpublic_note', 'public_note', 'loc', 'ccode', 'notforloan', 'uri', 'copyno', 'price', 'replacementprice', 'itemcallnumber', 'quantity', 'budget_code']);
        if ($alliteminfos != -1) {
            foreach my $iteminfos (@$alliteminfos) {
                my $item_homebranch = $iteminfos->{homebranch};
                my $item_holdingbranch = $iteminfos->{holdingbranch};
                my $item_itype = $iteminfos->{itype};
                my $item_nonpublic_note = $iteminfos->{nonpublic_note};
                my $item_public_note = $iteminfos->{public_note};
                my $item_loc = $iteminfos->{loc};
                my $item_ccode = $iteminfos->{ccode};
                my $item_notforloan = $iteminfos->{notforloan};
                my $item_uri = $iteminfos->{uri};
                my $item_copyno = $iteminfos->{copyno};
                my $item_quantity = $iteminfos->{quantity} || 1;
                my $item_budget_code = $iteminfos->{budget_code};
                my $item_budget_id;
                if ( $iteminfos->{budget_code} ) {
                    my $item_budget = GetBudgetByCode( $iteminfos->{budget_code} );
                    if ( $item_budget ) {
                        $item_budget_id = $item_budget->{budget_id};
                    }
                }
                my $item_price = $iteminfos->{price};
                my $item_replacement_price = $iteminfos->{replacementprice};
                my $item_callnumber = $iteminfos->{itemcallnumber};

                for (my $i = 0; $i < $item_quantity; $i++) {

                    my %itemrecord = (
                        'item_id' => $item_id++,
                        'biblio_count' => $biblio_count,
                        'homebranch' => $item_homebranch,
                        'holdingbranch' => $item_holdingbranch,
                        'itype' => $item_itype,
                        'nonpublic_note' => $item_nonpublic_note,
                        'public_note' => $item_public_note,
                        'loc' => $item_loc,
                        'ccode' => $item_ccode,
                        'notforloan' => $item_notforloan,
                        'uri' => $item_uri,
                        'copyno' => $item_copyno,
                        'quantity' => $item_quantity,
                        'budget_id' => $item_budget_id || $budget_id,
                        'itemprice' => $item_price || $price,
                        'replacementprice' => $item_replacement_price || $replacementprice,
                        'itemcallnumber' => $item_callnumber,
                    );
                    $all_items_quantity++;
                    push @itemlist, \%itemrecord;

                }
            }

            $cellrecord{'iteminfos'} = \@itemlist;
        } else {
            $cellrecord{'item_error'} = 1;
        }
        push @list, \%cellrecord;

        if ($alliteminfos == -1 || scalar(@$alliteminfos) == 0) {
            $cellrecord{price} = $price || '';
            $cellrecord{replacementprice} = $replacementprice || '';
            $cellrecord{quantity} = $quantity || '';
            $cellrecord{budget_id} = $budget_id || '';
            $cellrecord{discount} = $discount || '';
            $cellrecord{sort1} = $sort1 || '';
            $cellrecord{sort2} = $sort2 || '';
        } else {
            $cellrecord{quantity} = $all_items_quantity;
        }

    }
    my $num_records = $batch->{'num_records'};
    my $overlay_action = GetImportBatchOverlayAction($import_batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($import_batch_id);
    my $item_action = GetImportBatchItemAction($import_batch_id);
    $template->param(import_biblio_list => \@list,
                        num_results => $num_records,
                        import_batch_id => $import_batch_id,
                        "overlay_action_${overlay_action}" => 1,
                        overlay_action => $overlay_action,
                        "nomatch_action_${nomatch_action}" => 1,
                        nomatch_action => $nomatch_action,
                        "item_action_${item_action}" => 1,
                        item_action => $item_action,
                        item_error => $item_error,
                        libraries => Koha::Libraries->search,
                        locationloop => \@locations,
                        itemtypes => Koha::ItemTypes->search,
                        ccodeloop => \@ccodes,
                        notforloanloop => \@notforloans,
                    );
    batch_info($template, $batch);
}

sub batch_info {
    my ($template, $batch) = @_;
    $template->param(batch_info => 1,
                                      file_name => $batch->{'file_name'},
                                          comments => $batch->{'comments'},
                                          import_status => $batch->{'import_status'},
                                          upload_timestamp => $batch->{'upload_timestamp'},
                                          num_records => $batch->{'num_records'},
                                          num_items => $batch->{'num_items'});
    if ($batch->{'num_records'} > 0) {
        if ($batch->{'import_status'} eq 'staged' or $batch->{'import_status'} eq 'reverted') {
            $template->param(can_commit => 1);
        }
        if ($batch->{'import_status'} eq 'imported') {
            $template->param(can_revert => 1);
        }
    }
    if (defined $batch->{'matcher_id'}) {
        my $matcher = C4::Matcher->fetch($batch->{'matcher_id'});
        if (defined $matcher) {
            $template->param('current_matcher_id' => $batch->{'matcher_id'},
                                              'current_matcher_code' => $matcher->code(),
                                              'current_matcher_description' => $matcher->description());
        }
    }
    add_matcher_list($batch->{'matcher_id'}, $template);
}

sub add_matcher_list {
    my ($current_matcher_id, $template) = @_;
    my @matchers = C4::Matcher::GetMatcherList();
    if (defined $current_matcher_id) {
        for (my $i = 0; $i <= $#matchers; $i++) {
            if ($matchers[$i]->{'matcher_id'} == $current_matcher_id) {
                $matchers[$i]->{'selected'} = 1;
            }
        }
    }
    $template->param(available_matchers => \@matchers);
}

sub get_infos_syspref {
    my ($syspref_name, $record, $field_list) = @_;
    my $syspref = C4::Context->preference($syspref_name);
    $syspref = "$syspref\n\n"; # YAML is anal on ending \n. Surplus does not hurt
    my $yaml = eval {
        YAML::XS::Load(Encode::encode_utf8($syspref));
    };
    if ( $@ ) {
        warn "Unable to parse $syspref syspref : $@";
        return ();
    }
    my $r;
    for my $field_name ( @$field_list ) {
        next unless exists $yaml->{$field_name};
        my @fields = split /\|/, $yaml->{$field_name};
        for my $field ( @fields ) {
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

sub equal_number_of_fields {
    my ($tags_list, $record) = @_;
    my $tag_fields_count;
    for my $tag (@$tags_list) {
        my @fields = $record->field($tag);
        $tag_fields_count->{$tag} = scalar @fields;
    }

    my $tags_count;
    foreach my $key ( keys %$tag_fields_count ) {
        if ( $tag_fields_count->{$key} > 0 ) { # Having 0 of a field is ok
            $tags_count //= $tag_fields_count->{$key}; # Start with the count from the first occurrence
            return -1 if $tag_fields_count->{$key} != $tags_count; # All counts of various fields should be equal if they exist
        }
    }

    return $tags_count;
}

sub get_infos_syspref_on_item {
    my ($syspref_name, $record, $field_list) = @_;
    my $syspref = C4::Context->preference($syspref_name);
    $syspref = "$syspref\n\n"; # YAML is anal on ending \n. Surplus does not hurt
    my $yaml = eval {
        YAML::XS::Load(Encode::encode_utf8($syspref));
    };
    if ( $@ ) {
        warn "Unable to parse $syspref syspref : $@";
        return ();
    }
    my @result;
    my @tags_list;

    # Check tags in syspref definition
    for my $field_name ( @$field_list ) {
        next unless exists $yaml->{$field_name};
        my @fields = split /\|/, $yaml->{$field_name};
        for my $field ( @fields ) {
            my ( $f, $sf ) = split /\$/, $field;
            next unless $f and $sf;
            push @tags_list, $f;
        }
    }
    @tags_list = List::MoreUtils::uniq(@tags_list);

    my $tags_count = equal_number_of_fields(\@tags_list, $record);
    # Return if the number of these fields in the record is not the same.
    return -1 if $tags_count == -1;

    # Gather the fields
    my $fields_hash;
    foreach my $tag (@tags_list) {
        my @tmp_fields;
        foreach my $field ($record->field($tag)) {
            push @tmp_fields, $field;
        }
        $fields_hash->{$tag} = \@tmp_fields;
    }

    for (my $i = 0; $i < $tags_count; $i++) {
        my $r;
        for my $field_name ( @$field_list ) {
            next unless exists $yaml->{$field_name};
            my @fields = split /\|/, $yaml->{$field_name};
            for my $field ( @fields ) {
                my ( $f, $sf ) = split /\$/, $field;
                next unless $f and $sf;
                my $v = $fields_hash->{$f}[$i] ? $fields_hash->{$f}[$i]->subfield( $sf ) : undef;
                $r->{$field_name} = $v if (defined $v);
                last if $yaml->{$field};
            }
        }
        push @result, $r;
    }
    return \@result;
}
