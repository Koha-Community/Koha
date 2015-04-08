#!/usr/bin/perl

#A script that lets the user populate a basket from an iso2709 file
#the script first displays a list of import batches, then when a batch is selected displays all the biblios in it.
#The user can then pick which biblios he wants to order

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
use CGI;
use Carp;
use YAML qw/Load/;

use C4::Context;
use C4::Auth;
use C4::Input;
use C4::Output;
use C4::ImportBatch;
use C4::Matcher;
use C4::Search qw/FindDuplicate/;
use C4::Acquisition;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Budgets;
use C4::Acquisition;
use C4::Bookseller qw/GetBookSellerFromId/;
use C4::Suggestions;    # GetSuggestion
use C4::Branch;         # GetBranches
use C4::Members;

use Koha::Number::Price;
use Koha::Acquisition::Order;

my $input = new CGI;
my ($template, $loggedinuser, $cookie, $userflags) = get_template_and_user({
    template_name => "acqui/addorderiso2709.tt",
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired   => { acquisition => 'order_manage' },
    debug => 1,
});

my $cgiparams = $input->Vars;
my $op = $cgiparams->{'op'} || '';
my $booksellerid  = $input->param('booksellerid');
my $bookseller = GetBookSellerFromId($booksellerid);
my $data;

$template->param(scriptname => "/cgi-bin/koha/acqui/addorderiso2709.pl",
                booksellerid => $booksellerid,
                booksellername => $bookseller->{name},
                );

if ($cgiparams->{'import_batch_id'} && $op eq ""){
    $op = "batch_details";
}

#Needed parameters:
if (! $cgiparams->{'basketno'}){
    die "Basketnumber required to order from iso2709 file import";
}

#
# 1st step = choose the file to import into acquisition
#
if ($op eq ""){
    $template->param("basketno" => $cgiparams->{'basketno'});
#display batches
    import_batches_list($template);
#
# 2nd step = display the content of the choosen file
#
} elsif ($op eq "batch_details"){
#display lines inside the selected batch
    # get currencies (for change rates calcs if needed)
    my $active_currency = GetCurrency();
    my $default_currency;
    if (! $data->{currency} ) { # New order no currency set
        if ( $bookseller->{listprice} ) {
            $default_currency = $bookseller->{listprice};
        }
        else {
            $default_currency = $active_currency->{currency};
        }
    }
    my @rates = GetCurrencies();

    # ## @rates

    my @loop_currency = ();
    for my $curr ( @rates ) {
        my $selected;
        if ($data->{currency} ) {
            $selected = $curr->{currency} eq $data->{currency};
        }
        else {
            $selected = $curr->{currency} eq $default_currency;
        }
        push @loop_currency, {
            currcode => $curr->{currency},
            rate     => $curr->{rate},
            selected => $selected,
        }
    }

    $template->param("batch_details" => 1,
                     "basketno"      => $cgiparams->{'basketno'},
                     loop_currencies  => \@loop_currency,
                     );
    import_biblios_list($template, $cgiparams->{'import_batch_id'});
    if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {
        # prepare empty item form
        my $cell = PrepareItemrecordDisplay( '', '', '', 'ACQ' );

        #     warn "==> ".Data::Dumper::Dumper($cell);
        unless ($cell) {
            $cell = PrepareItemrecordDisplay( '', '', '', '' );
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
    my $biblios = GetImportRecordsRange($import_batch_id);
    my @import_record_id_selected = $input->param("import_record_id");
    my @quantities = $input->param('quantity');
    my @prices = $input->param('price');
    my @budgets_id = $input->param('budget_id');
    my @discount = $input->param('discount');
    my @sort1 = $input->param('sort1');
    my @sort2 = $input->param('sort2');
    my $cur = GetCurrency();
    for my $biblio (@$biblios){
        # Check if this import_record_id was selected
        next if not grep { $_ eq $$biblio{import_record_id} } @import_record_id_selected;
        my ( $marcblob, $encoding ) = GetImportRecordMarc( $biblio->{'import_record_id'} );
        my $marcrecord = MARC::Record->new_from_usmarc($marcblob) || die "couldn't translate marc information";
        my $match = GetImportRecordMatches( $biblio->{'import_record_id'}, 1 );
        my $biblionumber=$#$match > -1?$match->[0]->{'biblionumber'}:0;
        my $c_quantity = shift( @quantities ) || GetMarcQuantity($marcrecord, C4::Context->preference('marcflavour') ) || 1;
        my $c_budget_id = shift( @budgets_id ) || $input->param('all_budget_id') || $budget_id;
        my $c_discount = shift ( @discount);
        $c_discount = $c_discount / 100 if $c_discount > 1;
        my $c_sort1 = shift( @sort1 ) || $input->param('all_sort1') || '';
        my $c_sort2 = shift( @sort2 ) || $input->param('all_sort2') || '';

        # 1st insert the biblio, or find it through matcher
        unless ( $biblionumber ) {
            # add the biblio
            my $bibitemnum;

            # remove ISBN -
            my ( $isbnfield, $isbnsubfield ) = GetMarcFromKohaField( 'biblioitems.isbn', '' );
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
            SetImportRecordStatus( $biblio->{'import_record_id'}, 'imported' );
            # 2nd add authorities if applicable
            if (C4::Context->preference("BiblioAddsAuthorities")){
                my $headings_linked =BiblioAutoLink($marcrecord, $cgiparams->{'frameworkcode'});
            }
        } else {
            SetImportRecordStatus( $biblio->{'import_record_id'}, 'imported' );
        }
        # 3rd add order
        my $patron = C4::Members::GetMember( borrowernumber => $loggedinuser );
        my $branch = C4::Branch->GetBranchDetail( $patron->{branchcode} );
        # get quantity in the MARC record (1 if none)
        my $quantity = GetMarcQuantity($marcrecord, C4::Context->preference('marcflavour')) || 1;
        my %orderinfo = (
            biblionumber       => $biblionumber,
            basketno           => $cgiparams->{'basketno'},
            quantity           => $c_quantity,
            branchcode         => $patron->{branchcode},
            budget_id          => $c_budget_id,
            uncertainprice     => 1,
            sort1              => $c_sort1,
            sort2              => $c_sort2,
            order_internalnote => $cgiparams->{'all_order_internalnote'},
            order_vendornote   => $cgiparams->{'all_order_vendornote'},
            currency           => $cgiparams->{'all_currency'},
        );
        # get the price if there is one.
        my $price= shift( @prices ) || GetMarcPrice($marcrecord, C4::Context->preference('marcflavour'));
        if ($price){
            # in France, the cents separator is the , but sometimes, ppl use a .
            # in this case, the price will be x100 when unformatted ! Replace the . by a , to get a proper price calculation
            $price =~ s/\./,/ if C4::Context->preference("CurrencyFormat") eq "FR";
            $price = Koha::Number::Price->new($price)->unformat;
            $orderinfo{gstrate} = $bookseller->{gstrate};
            my $c = $c_discount ? $c_discount : $bookseller->{discount} / 100;
            if ( $bookseller->{listincgst} ) {
                if ( $c_discount ) {
                    $orderinfo{ecost} = $price;
                    $orderinfo{rrp}   = $orderinfo{ecost} / ( 1 - $c );
                } else {
                    $orderinfo{ecost} = $price * ( 1 - $c );
                    $orderinfo{rrp}   = $price;
                }
            } else {
                if ( $c_discount ) {
                    $orderinfo{ecost} = $price / ( 1 + $orderinfo{gstrate} );
                    $orderinfo{rrp}   = $orderinfo{ecost} / ( 1 - $c );
                } else {
                    $orderinfo{rrp}   = $price / ( 1 + $orderinfo{gstrate} );
                    $orderinfo{ecost} = $orderinfo{rrp} * ( 1 - $c );
                }
            }
            $orderinfo{listprice} = $orderinfo{rrp} / $cur->{rate};
            $orderinfo{unitprice} = $orderinfo{ecost};
            $orderinfo{total} = $orderinfo{ecost} * $c_quantity;
        } else {
            $orderinfo{listprice} = 0;
        }

        # remove uncertainprice flag if we have found a price in the MARC record
        $orderinfo{uncertainprice} = 0 if $orderinfo{listprice};
        my $order = Koha::Acquisition::Order->new( \%orderinfo )->insert;

        # 4th, add items if applicable
        # parse the item sent by the form, and create an item just for the import_record_id we are dealing with
        # this is not optimised, but it's working !
        if ( C4::Context->preference('AcqCreateItem') eq 'ordering' ) {
            my @tags         = $input->param('tag');
            my @subfields    = $input->param('subfield');
            my @field_values = $input->param('field_value');
            my @serials      = $input->param('serial');
            my @ind_tag   = $input->param('ind_tag');
            my @indicator = $input->param('indicator');
            my $item;
            push @{ $item->{tags} },         $tags[0];
            push @{ $item->{subfields} },    $subfields[0];
            push @{ $item->{field_values} }, $field_values[0];
            push @{ $item->{ind_tag} },      $ind_tag[0];
            push @{ $item->{indicator} },    $indicator[0];
            my $xml = TransformHtmlToXml( \@tags, \@subfields, \@field_values, \@ind_tag, \@indicator );
            my $record = MARC::Record::new_from_xml( $xml, 'UTF-8' );
            for (my $qtyloop=1;$qtyloop <= $c_quantity;$qtyloop++) {
                my ( $biblionumber, $bibitemnum, $itemnumber ) = AddItemFromMarc( $record, $biblionumber );
                $order->add_item( $itemnumber );
            }
        } else {
            SetImportRecordStatus( $biblio->{'import_record_id'}, 'imported' );
        }
    }
    # go to basket page
    print $input->redirect("/cgi-bin/koha/acqui/basket.pl?basketno=".$cgiparams->{'basketno'});
    exit;
}

my $budgets = GetBudgets();
my $budget_id = @$budgets[0]->{'budget_id'};
# build bookfund list
my $borrower = GetMember( 'borrowernumber' => $loggedinuser );
my ( $flags, $homebranch ) = ( $borrower->{'flags'}, $borrower->{'branchcode'} );
my $budget = GetBudget($budget_id);

# build budget list
my $budget_loop = [];
my $budgets_hierarchy = GetBudgetHierarchy;
foreach my $r ( @{$budgets_hierarchy} ) {
    next unless (CanUserUseBudget($borrower, $r, $userflags));
    if ( !defined $r->{budget_amount} || $r->{budget_amount} == 0 ) {
        next;
    }
    push @{$budget_loop},
      { b_id  => $r->{budget_id},
        b_txt => $r->{budget_name},
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
        if ( $batch->{'import_status'} =~ /^staged$|^reverted$/ ) {
            # check if there is at least 1 line still staged
            my $stagedList=GetImportRecordsRange($batch->{'import_batch_id'}, undef, undef, $batch->{import_status}, { order_by_direction => 'ASC' });
            if (scalar @$stagedList) {
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
    my $biblios = GetImportRecordsRange($import_batch_id,'','',$batch->{import_status});
    my @list = ();

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
            match_citation     => $#$match > -1 ? $match->[0]->{'title'} || '' . ' ' . $match->[0]->{'author'} || '': '',
            match_score => $#$match > -1 ? $match->[0]->{'score'} : 0,
        );
        my ( $marcblob, $encoding ) = GetImportRecordMarc( $biblio->{'import_record_id'} );
        my $marcrecord = MARC::Record->new_from_usmarc($marcblob) || die "couldn't translate marc information";
        my $infos = get_infos_syspref($marcrecord, ['price', 'quantity', 'budget_code', 'discount', 'sort1', 'sort2']);
        my $price = $infos->{price};
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
        $cellrecord{price} = $price || '';
        $cellrecord{quantity} = $quantity || '';
        $cellrecord{budget_id} = $budget_id || '';
        $cellrecord{discount} = $discount || '';
        $cellrecord{sort1} = $sort1 || '';
        $cellrecord{sort2} = $sort2 || '';

        push @list, \%cellrecord;
    }
    my $num_records = $batch->{'num_records'};
    my $overlay_action = GetImportBatchOverlayAction($import_batch_id);
    my $nomatch_action = GetImportBatchNoMatchAction($import_batch_id);
    my $item_action = GetImportBatchItemAction($import_batch_id);
    $template->param(biblio_list => \@list,
                        num_results => $num_records,
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
    my ($record, $field_list) = @_;
    my $syspref = C4::Context->preference('MarcFieldsToOrder');
    $syspref = "$syspref\n\n"; # YAML is anal on ending \n. Surplus does not hurt
    my $yaml = eval {
        YAML::Load($syspref);
    };
    if ( $@ ) {
        warn "Unable to parse MarcFieldsToOrder syspref : $@";
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
