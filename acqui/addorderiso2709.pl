#!/usr/bin/perl

#A script that lets the user populate a basket from an iso2709 file
#the script first displays a list of import batches, then when a batch is selected displays all the biblios in it.
#The user can then pick which biblios he wants to order
#written by john.soros@biblibre.com 01/12/2008

# Copyright 2008 - 2009 BibLibre SARL
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Input;
use C4::Output;
use C4::ImportBatch qw/GetImportBatchRangeDesc GetNumberOfNonZ3950ImportBatches GetImportRecordMatches GetImportBibliosRange GetImportBatchOverlayAction GetImportBatchNoMatchAction GetImportBatchItemAction GetImportRecordMarc GetImportBatch/;
use C4::Matcher;
use C4::Search qw/FindDuplicate BiblioAddAuthorities/;
use C4::Acquisition qw/NewOrder/;
use C4::Biblio;
use C4::Items;
use C4::Koha qw/GetItemTypes/;
use C4::Budgets qw/GetBudgets/;
use C4::Acquisition qw/NewOrderItem/;
use C4::Bookseller qw/GetBookSellerFromId/;

my $input = new CGI;
my ($template, $loggedinuser, $cookie) = get_template_and_user({
                                        template_name => "acqui/addorderiso2709.tmpl",
                                        query => $input,
                                        type => "intranet",
                                        authnotrequired => 0,
                                        flagsrequired   => { acquisition => 'order_manage' },
                                        debug => 1,
                                        });
my $cgiparams = $input->Vars;
my $op = $cgiparams->{'op'};
my $booksellerid  = $input->param('booksellerid');
my $bookseller = GetBookSellerFromId($booksellerid);

$template->param(scriptname => "/cgi-bin/koha/acqui/addorderiso2709.pl",
                booksellerid => $booksellerid,
                booksellername => $bookseller->{name},
                );
my $ordernumber;

if ($cgiparams->{'import_batch_id'} && $op eq ""){
    $op = "batch_details";
}

#Needed parameters:
if (! $cgiparams->{'basketno'}){
    die "Basketnumber required to order from iso2709 file import";
}

if ($op eq ""){
    $template->param("basketno" => $cgiparams->{'basketno'});
#display batches
    import_batches_list($template);
} elsif ($op eq "batch_details"){
#display lines inside the selected batch
    $template->param("batch_details" => 1,
                     "basketno"      => $cgiparams->{'basketno'});
    import_biblios_list($template, $cgiparams->{'import_batch_id'});
    
} elsif ($op eq 'import_records'){
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
    my $biblios = GetImportBibliosRange($import_batch_id);
    for my $biblio (@$biblios){
        if($cgiparams->{'order-'.$biblio->{'import_record_id'}}){
            my ($marcblob, $encoding) = GetImportRecordMarc($biblio->{'import_record_id'});
            my $marcrecord = MARC::Record->new_from_usmarc($marcblob) || die "couldn't translate marc information";
            my ($duplicatetitle, $biblionumber);
            if(!(($biblionumber,$duplicatetitle) = FindDuplicate($marcrecord))){
#FIXME: missing: marc21 support (should be same with different field)
                if ( C4::Context->preference("marcflavour") eq 'UNIMARC' ) {
                    my $itemtypeid = "itemtype-" . $biblio->{'import_record_id'};
                    $marcrecord->field(200)->update("b" => $cgiparams->{$itemtypeid});
                }
                # add the biblio
                my $bibitemnum;
                # remove ISBN -
                my ($isbnfield,$isbnsubfield) = GetMarcFromKohaField('biblioitems.isbn','');
                if ( $marcrecord->field($isbnfield) ) {
                    foreach my $field ( $marcrecord->field($isbnfield) ) {
                        foreach my $subfield ( $field->subfield($isbnsubfield) ) {
                            my $newisbn = $field->subfield($isbnsubfield);
                            $newisbn =~ s/-//g;
                            $field->update( $isbnsubfield => $newisbn );
                        }
                    }
                }

                ( $biblionumber, $bibitemnum ) = AddBiblio( $marcrecord, $cgiparams->{'frameworkcode'} || '' );
            } else {
                warn("Duplicate item found: ", $biblionumber, "; Duplicate: ", $duplicatetitle);
            }
            if (C4::Context->preference("BiblioAddsAuthorities")){
                my ($countlinked,$countcreated)=BiblioAddAuthorities($marcrecord, $cgiparams->{'frameworkcode'});
            }
            my $patron = C4::Members->GetMember(borrowernumber => $loggedinuser);
            my $branch = C4::Branch->GetBranchDetail($patron->{branchcode});
            my ($invoice);
            my %orderinfo = ("biblionumber", $biblionumber,
                            "basketno", $cgiparams->{'basketno'},
                            "quantity", $cgiparams->{'quantityrec-' . $biblio->{'import_record_id'}},
                            "branchcode", $branch,
                            "booksellerinvoicenumber", $invoice,
                            "budget_id", $budget_id,
                            "uncertainprice", 1,
                            );
            # get the price if there is one.
            # filter by storing only the 1st number
            # we suppose the currency is correct, as we have no possibilities to get it.
            if ($marcrecord->subfield("345","d")) {
              $orderinfo{'listprice'} = $marcrecord->subfield("345","d");
              if ($orderinfo{'listprice'} =~ /^([\d\.,]*)/) {
                  $orderinfo{'listprice'} = $1;
                  $orderinfo{'listprice'} =~ s/,/\./;
                  eval "use C4::Acquisition qw/GetBasket/;";
                  eval "use C4::Bookseller qw/GetBookSellerFromId/;";
                  my $basket = GetBasket($orderinfo{basketno});
                  my $bookseller = GetBookSellerFromId($basket->{booksellerid});
                  my $gst = $bookseller->{gstrate} || C4::Context->preference("gist") || 0;
                  $orderinfo{'unitprice'} = $orderinfo{listprice} - ($orderinfo{listprice} * ($bookseller->{discount} / 100));
                  $orderinfo{'ecost'} = $orderinfo{unitprice};
              } else {
                  $orderinfo{'listprice'} = 0;
              }
              $orderinfo{'rrp'} = $orderinfo{'listprice'};
            }
            elsif ($marcrecord->subfield("010","d")) {
              $orderinfo{'listprice'} = $marcrecord->subfield("010","d");
              if ($orderinfo{'listprice'} =~ /^([\d\.,]*)/) {
                  $orderinfo{'listprice'} = $1;
                  $orderinfo{'listprice'} =~ s/,/\./;
                  eval "use C4::Acquisition qw/GetBasket/;";
                  eval "use C4::Bookseller qw/GetBookSellerFromId/;";
                  my $basket = GetBasket($orderinfo{basketno});
                  my $bookseller = GetBookSellerFromId($basket->{booksellerid});
                  my $gst = $bookseller->{gstrate} || C4::Context->preference("gist") || 0;
                  $orderinfo{'unitprice'} = $orderinfo{listprice} - ($orderinfo{listprice} * ($bookseller->{discount} / 100));
                  $orderinfo{'ecost'} = $orderinfo{unitprice};
              } else {
                  $orderinfo{'listprice'} = 0;
              }
              $orderinfo{'rrp'} = $orderinfo{'listprice'};
            }
            # remove uncertainprice flag if we have found a price in the MARC record
            $orderinfo{uncertainprice} = 0 if $orderinfo{listprice};
            my $basketno;
            ( $basketno, $ordernumber ) = NewOrder(\%orderinfo);

            # now, add items if applicable
            # parse all items sent by the form, and create an item just for the import_record_id we are dealing with
            # this is not optimised, but it's working !
            if (C4::Context->preference('AcqCreateItem') eq 'ordering') {
                my @tags         = $input->param('tag');
                my @subfields    = $input->param('subfield');
                my @field_values = $input->param('field_value');
                my @serials      = $input->param('serial');
                my @itemids       = $input->param('itemid'); # hint : in iso2709, the itemid contains the import_record_id, not an item id. It is used to get the right item, as we have X biblios.
                my @ind_tag      = $input->param('ind_tag');
                my @indicator    = $input->param('indicator');
                #Rebuilding ALL the data for items into a hash
                # parting them on $itemid.
                my %itemhash;
                my $range=scalar(@itemids);
                
                my $i = 0;
                my @items;
                for my $itemid (@itemids){
                    my $realitemid;     #javascript generated random itemids, in the form itemid-randomnumber, $realitemid is the itemid, while $itemid is the itemide parsed from the html
                    if ($itemid =~ m/(\d+)-.*/){
                        my @splits = split(/-/, $itemid);
                        $realitemid = $splits[0];
                    }
                    if ( ( $realitemid && $cgiparams->{'order-'. $realitemid} && $realitemid eq $biblio->{import_record_id}) || ($itemid && $cgiparams->{'order-'. $itemid} && $itemid eq $biblio->{import_record_id}) ){
                        my ($item, $found);
                        for my $tmpitem (@items){
                            if ($tmpitem->{itemid} eq $itemid){
                                $item = $tmpitem;
                                $found = 1;
                            }
                        }
                        push @{$item->{tags}}, $tags[$i];
                        push @{$item->{subfields}}, $subfields[$i];
                        push @{$item->{field_values}}, $field_values[$i];
                        push @{$item->{ind_tag}}, $ind_tag[$i];
                        push @{$item->{indicator}}, $indicator[$i];
                        $item->{itemid} = $itemid;
                        if (! $found){
                             push @items, $item;
                        }
                    }
                    ++$i
                }
                foreach my $item (@items){
                        my $xml = TransformHtmlToXml( $item->{'tags'},
                                                $item->{'subfields'},
                                                $item->{'field_values'},
                                                $item->{'ind_tag'},
                                                $item->{'indicator'});
                        my $record=MARC::Record::new_from_xml($xml, 'UTF-8');
                        my ($biblionumber,$bibitemnum,$itemnumber) = AddItemFromMarc($record,$biblionumber);
                        NewOrderItem( $itemnumber, $ordernumber);
                }
            }
        }
    }
    # go to basket page
    print $input->redirect("/cgi-bin/koha/acqui/basket.pl?basketno=".$cgiparams->{'basketno'});
    exit;
}
output_html_with_http_headers $input, $cookie, $template->output;


sub import_batches_list {
    my ($template) = @_;
    my $batches = GetImportBatchRangeDesc();

    my @list = ();
    foreach my $batch (@$batches) {
        if ($batch->{'import_status'} eq "staged") {
        push @list, {
                import_batch_id => $batch->{'import_batch_id'},
                num_biblios => $batch->{'num_biblios'},
                num_items => $batch->{'num_items'},
                upload_timestamp => $batch->{'upload_timestamp'},
                import_status => $batch->{'import_status'},
                file_name => $batch->{'file_name'},
                comments => $batch->{'comments'},
            };
        }
    }
    $template->param(batch_list => \@list); 
    my $num_batches = GetNumberOfNonZ3950ImportBatches();
    $template->param(num_results => $num_batches);
}

sub import_biblios_list {
    my ($template, $import_batch_id) = @_;
    my $batch = GetImportBatch($import_batch_id,'staged');
    my $biblios = GetImportBibliosRange($import_batch_id,'','','staged');
    my @list = ();
# # Itemtype is mandatory for adding a biblioitem, we just add a default, the user needs to modify this aftewards
#     my $itemtypehash = GetItemTypes();
#     my @itemtypes;
#     for my $key (sort { $itemtypehash->{$a}->{description} cmp $itemtypehash->{$b}->{description} } keys %$itemtypehash) {
#         push(@itemtypes, $itemtypehash->{$key});
#     }
    foreach my $biblio (@$biblios) {
        my $citation = $biblio->{'title'};
        $citation .= " $biblio->{'author'}" if $biblio->{'author'};
        $citation .= " (" if $biblio->{'issn'} or $biblio->{'isbn'};
        $citation .= $biblio->{'isbn'} if $biblio->{'isbn'};
        $citation .= ", " if $biblio->{'issn'} and $biblio->{'isbn'};
        $citation .= $biblio->{'issn'} if $biblio->{'issn'};
        $citation .= ")" if $biblio->{'issn'} or $biblio->{'isbn'};
        my $match = GetImportRecordMatches($biblio->{'import_record_id'}, 1);
        my %cellrecord = (
            import_record_id => $biblio->{'import_record_id'},
            citation => $citation,
            import  => 1,
            status => $biblio->{'status'},
            record_sequence => $biblio->{'record_sequence'},
            overlay_status => $biblio->{'overlay_status'},
            match_biblionumber => $#$match > -1 ? $match->[0]->{'biblionumber'} : 0,
            match_citation => $#$match > -1 ? $match->[0]->{'title'} . ' ' . $match->[0]->{'author'} : '',
            match_score => $#$match > -1 ? $match->[0]->{'score'} : 0,
#             itemtypes => \@itemtypes,
        );
#         if (C4::Context->preference('AcqCreateItem') eq 'ordering' && !$ordernumber) {
#             # prepare empty item form
#             my $cell = PrepareItemrecordDisplay();
#             my @itemloop;
#             push @itemloop,$cell;
#             $cellrecord{'items'} = \@itemloop;
#         }
        push @list, \%cellrecord;


    }
    my $num_biblios = $batch->{'num_biblios'};
    my $overlay_action = GetImportBatchOverlayAction($import_batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($import_batch_id);
    my $item_action = GetImportBatchItemAction($import_batch_id);
    $template->param(biblio_list => \@list,
                        num_results => $num_biblios,
                        import_batch_id => $import_batch_id,
                        "overlay_action_${overlay_action}" => 1,
                        overlay_action => $overlay_action,
                        "nomatch_action_${nomatch_action}" => 1,
                        nomatch_action => $nomatch_action,
                        "item_action_${item_action}" => 1,
                        item_action => $item_action
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
                                          num_biblios => $batch->{'num_biblios'},
                                          num_items => $batch->{'num_biblios'});
    if ($batch->{'num_biblios'} > 0) {
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
    add_matcher_list($batch->{'matcher_id'});
}

sub add_matcher_list {
    my $current_matcher_id = shift;
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
