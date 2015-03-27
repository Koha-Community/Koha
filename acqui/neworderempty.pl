#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

# Copyright 2000-2002 Katipo Communications
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


=head1 NAME

neworderempty.pl

=head1 DESCRIPTION

this script allows to create a new record to order it. This record shouldn't exist
on database.

=head1 CGI PARAMETERS

=over 4

=item booksellerid
the bookseller the librarian has to buy a new book.

=item title
the title of this new record.

=item author
the author of this new record.

=item publication year
the publication year of this new record.

=item ordernumber
the number of this order.

=item biblio

=item basketno
the basket number for this new order.

=item suggestionid
if this order comes from a suggestion.

=item breedingid
the item's id in the breeding reservoir

=item close

=back

=cut

use warnings;
use strict;
use CGI;
use C4::Context;
use C4::Input;

use C4::Auth;
use C4::Budgets;
use C4::Input;

use C4::Bookseller  qw/ GetBookSellerFromId /;
use C4::Acquisition;
use C4::Contract;
use C4::Suggestions;	# GetSuggestion
use C4::Biblio;			# GetBiblioData GetMarcPrice
use C4::Items; #PrepareItemRecord
use C4::Output;
use C4::Input;
use C4::Koha;
use C4::Branch;			# GetBranches
use C4::Members;
use C4::Search qw/FindDuplicate/;

#needed for z3950 import:
use C4::ImportBatch qw/GetImportRecordMarc SetImportRecordStatus/;

our $input           = new CGI;
my $booksellerid    = $input->param('booksellerid');	# FIXME: else ERROR!
my $budget_id       = $input->param('budget_id') || 0;
my $title           = $input->param('title');
my $author          = $input->param('author');
my $publicationyear = $input->param('publicationyear');
my $ordernumber          = $input->param('ordernumber') || '';
our $biblionumber    = $input->param('biblionumber');
our $basketno        = $input->param('basketno');
my $suggestionid    = $input->param('suggestionid');
my $close           = $input->param('close');
my $uncertainprice  = $input->param('uncertainprice');
my $import_batch_id = $input->param('import_batch_id'); # if this is filled, we come from a staged file, and we will return here after saving the order !
my $subscriptionid  = $input->param('subscriptionid');
my $data;
my $new = 'no';

my $budget_name;

our ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name   => "acqui/neworderempty.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
        debug           => 1,
    }
);

our $marcflavour = C4::Context->preference('marcflavour');

if(!$basketno) {
    my $order = GetOrder($ordernumber);
    $basketno = $order->{'basketno'};
}

our $basket = GetBasket($basketno);
$booksellerid = $basket->{booksellerid} unless $booksellerid;
my $bookseller = GetBookSellerFromId($booksellerid);

my $contract = GetContract({
    contractnumber => $basket->{contractnumber}
});

#simple parameters reading (all in one :-)
our $params = $input->Vars;
my $listprice=0; # the price, that can be in MARC record if we have one
if ( $ordernumber eq '' and defined $params->{'breedingid'}){
#we want to import from the breeding reservoir (from a z3950 search)
    my ($marcrecord, $encoding) = MARCfindbreeding($params->{'breedingid'});
    die("Could not find the selected record in the reservoir, bailing") unless $marcrecord;

    # Remove all the items (952) from the imported record
    foreach my $item ($marcrecord->field('952')) {
        $marcrecord->delete_field($item);
    }

    my $duplicatetitle;
#look for duplicates
    ($biblionumber,$duplicatetitle) = FindDuplicate($marcrecord);
    if($biblionumber && !$input->param('use_external_source')) {
	#if duplicate record found and user did not decide yet, first warn user
	#and let him choose between using new record or existing record
	Load_Duplicate($duplicatetitle);
	exit;
    }
    #from this point: add a new record
        if (C4::Context->preference("BiblioAddsAuthorities")){
            my $headings_linked=BiblioAutoLink($marcrecord, $params->{'frameworkcode'});
        }
        my $bibitemnum;
        $params->{'frameworkcode'} or $params->{'frameworkcode'} = "";
        ( $biblionumber, $bibitemnum ) = AddBiblio( $marcrecord, $params->{'frameworkcode'} );
        # get the price if there is one.
        $listprice = GetMarcPrice($marcrecord, $marcflavour);
        SetImportRecordStatus($params->{'breedingid'}, 'imported');
}



if ( $ordernumber eq '' ) {    # create order
    $new = 'yes';

    # 	$ordernumber=newordernum;
    if ( $biblionumber && !$suggestionid ) {
        $data = GetBiblioData($biblionumber);
    }

# get suggestion fields if applicable. If it's a subscription renewal, then the biblio already exists
# otherwise, retrieve suggestion information.
    if ($suggestionid) {
        $data = ($biblionumber) ? GetBiblioData($biblionumber) : GetSuggestion($suggestionid);
        $budget_id ||= $data->{'budgetid'} // 0;
    }
}
else {    #modify order
    $data   = GetOrder($ordernumber);
    $biblionumber = $data->{'biblionumber'};
    $budget_id = $data->{'budget_id'};

    $basket   = GetBasket( $data->{'basketno'} );
    $basketno = $basket->{'basketno'};
}

my $suggestion;
$suggestion = GetSuggestionInfo($suggestionid) if $suggestionid;

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

# build branches list
my $onlymine =
     C4::Context->preference('IndependentBranches')
  && C4::Context->userenv
  && !C4::Context->IsSuperLibrarian()
  && C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my @branchloop;
foreach my $thisbranch ( sort {$branches->{$a}->{'branchname'} cmp $branches->{$b}->{'branchname'}} keys %$branches ) {
    my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
    $row{'selected'} = 1 if( $thisbranch && $data->{branchcode} && $thisbranch eq $data->{branchcode}) ;
    push @branchloop, \%row;
}
$template->param( branchloop => \@branchloop );

# build bookfund list
my $borrower= GetMember('borrowernumber' => $loggedinuser);
my ( $flags, $homebranch )= ($borrower->{'flags'},$borrower->{'branchcode'});

my $budget =  GetBudget($budget_id);
# build budget list
my $budget_loop = [];
my $budgets = GetBudgetHierarchy;
foreach my $r (@{$budgets}) {
    next unless (CanUserUseBudget($borrower, $r, $userflags));
    if (!defined $r->{budget_amount} || $r->{budget_amount} == 0) {
        next;
    }
    push @{$budget_loop}, {
        b_id  => $r->{budget_id},
        b_txt => $r->{budget_name},
        b_sort1_authcat => $r->{'sort1_authcat'},
        b_sort2_authcat => $r->{'sort2_authcat'},
        b_active => $r->{budget_period_active},
        b_sel => ( $r->{budget_id} == $budget_id ) ? 1 : 0,
    };
}

@{$budget_loop} =
  sort { uc( $a->{b_txt}) cmp uc( $b->{b_txt}) } @{$budget_loop};

if ($close) {
    $budget_id      =  $data->{'budget_id'};
    $budget_name    =   $budget->{'budget_name'};

}

$template->param( sort1 => $data->{'sort1'} );
$template->param( sort2 => $data->{'sort2'} );

if (C4::Context->preference('AcqCreateItem') eq 'ordering' && !$ordernumber) {
    # Check if ACQ framework exists
    my $marc = GetMarcStructure(1, 'ACQ');
    unless($marc) {
        $template->param('NoACQframework' => 1);
    }
    $template->param(
        AcqCreateItemOrdering => 1,
        UniqueItemFields => C4::Context->preference('UniqueItemFields'),
    );
}
# Get the item types list, but only if item_level_itype is YES. Otherwise, it will be in the item, no need to display it in the biblio
my @itemtypes;
@itemtypes = C4::ItemType->all unless C4::Context->preference('item-level_itypes');

if ( defined $subscriptionid ) {
    my $lastOrderReceived = GetLastOrderReceivedFromSubscriptionid $subscriptionid;
    if ( defined $lastOrderReceived ) {
        $budget_id              = $lastOrderReceived->{budgetid};
        $data->{listprice}      = $lastOrderReceived->{listprice};
        $data->{uncertainprice} = $lastOrderReceived->{uncertainprice};
        $data->{gstrate}        = $lastOrderReceived->{gstrate};
        $data->{discount}       = $lastOrderReceived->{discount};
        $data->{rrp}            = $lastOrderReceived->{rrp};
        $data->{ecost}          = $lastOrderReceived->{ecost};
        $data->{quantity}       = $lastOrderReceived->{quantity};
        $data->{unitprice}      = $lastOrderReceived->{unitprice};
        $data->{order_internalnote} = $lastOrderReceived->{order_internalnote};
        $data->{order_vendornote}   = $lastOrderReceived->{order_vendornote};
        $data->{sort1}          = $lastOrderReceived->{sort1};
        $data->{sort2}          = $lastOrderReceived->{sort2};

        $basket = GetBasket( $input->param('basketno') );
    }
}

# Find the items.barcode subfield for barcode validations
my (undef, $barcode_subfield) = GetMarcFromKohaField('items.barcode', '');

# fill template
$template->param(
    close        => $close,
    budget_id    => $budget_id,
    budget_name  => $budget_name
) if ($close);

# get option values for gist syspref
my @gst_values = map {
    option => $_ + 0.0
}, split( '\|', C4::Context->preference("gist") );

my $quantity = $input->param('rr_quantity_to_order') ?
      $input->param('rr_quantity_to_order') :
      $data->{'quantity'};
$quantity //= 0;

$template->param(
    existing         => $biblionumber,
    ordernumber           => $ordernumber,
    # basket informations
    basketno             => $basketno,
    basketname           => $basket->{'basketname'},
    basketnote           => $basket->{'note'},
    booksellerid         => $basket->{'booksellerid'},
    basketbooksellernote => $basket->{booksellernote},
    basketcontractno     => $basket->{contractnumber},
    basketcontractname   => $contract->{contractname},
    creationdate         => $basket->{creationdate},
    authorisedby         => $basket->{'authorisedby'},
    authorisedbyname     => $basket->{'authorisedbyname'},
    closedate            => $basket->{'closedate'},
    # order details
    suggestionid         => $suggestion->{suggestionid},
    surnamesuggestedby   => $suggestion->{surnamesuggestedby},
    firstnamesuggestedby => $suggestion->{firstnamesuggestedby},
    biblionumber         => $biblionumber,
    uncertainprice       => $data->{'uncertainprice'},
    discount_2dp         => sprintf( "%.2f",  $bookseller->{'discount'} ) ,   # for display
    discount             => $bookseller->{'discount'},
    orderdiscount_2dp    => sprintf( "%.2f", $data->{'discount'} || 0 ),
    orderdiscount        => $data->{'discount'},
    order_internalnote   => $data->{'order_internalnote'},
    order_vendornote     => $data->{'order_vendornote'},
    listincgst       => $bookseller->{'listincgst'},
    invoiceincgst    => $bookseller->{'invoiceincgst'},
    name             => $bookseller->{'name'},
    cur_active_sym   => $active_currency->{'symbol'},
    cur_active       => $active_currency->{'currency'},
    loop_currencies  => \@loop_currency,
    orderexists      => ( $new eq 'yes' ) ? 0 : 1,
    title            => $data->{'title'},
    author           => $data->{'author'},
    publicationyear  => $data->{'publicationyear'} ? $data->{'publicationyear'} : $data->{'copyrightdate'},
    editionstatement => $data->{'editionstatement'},
    budget_loop      => $budget_loop,
    isbn             => $data->{'isbn'},
    ean              => $data->{'ean'},
    seriestitle      => $data->{'seriestitle'},
    itemtypeloop     => \@itemtypes,
    quantity         => $quantity,
    quantityrec      => $quantity,
    rrp              => $data->{'rrp'},
    gst_values       => \@gst_values,
    gstrate          => $data->{gstrate} ? $data->{gstrate}+0.0 : $bookseller->{gstrate} ? $bookseller->{gstrate}+0.0 : 0,
    listprice        => sprintf( "%.2f", $data->{listprice} || $data->{price} || $listprice),
    total            => sprintf( "%.2f", ($data->{ecost} || 0) * ($data->{'quantity'} || 0) ),
    ecost            => sprintf( "%.2f", $data->{ecost} || 0),
    unitprice        => sprintf( "%.2f", $data->{unitprice} || 0),
    publishercode    => $data->{'publishercode'},
    barcode_subfield => $barcode_subfield,
    import_batch_id  => $import_batch_id,
    subscriptionid   => $subscriptionid,
    acqcreate        => C4::Context->preference("AcqCreateItem") eq "ordering" ? 1 : "",
    (uc(C4::Context->preference("marcflavour"))) => 1
);

output_html_with_http_headers $input, $cookie, $template->output;


=head2 MARCfindbreeding

  $record = MARCfindbreeding($breedingid);

Look up the import record repository for the record with
record with id $breedingid.  If found, returns the decoded
MARC::Record; otherwise, -1 is returned (FIXME).
Returns as second parameter the character encoding.

=cut

sub MARCfindbreeding {
    my ( $id ) = @_;
    my ($marc, $encoding) = GetImportRecordMarc($id);
    # remove the - in isbn, koha store isbn without any -
    if ($marc) {
        my $record = MARC::Record->new_from_usmarc($marc);
        my ($isbnfield,$isbnsubfield) = GetMarcFromKohaField('biblioitems.isbn','');
        if ( $record->field($isbnfield) ) {
            foreach my $field ( $record->field($isbnfield) ) {
                foreach my $subfield ( $field->subfield($isbnsubfield) ) {
                    my $newisbn = $field->subfield($isbnsubfield);
                    $newisbn =~ s/-//g;
                    $field->update( $isbnsubfield => $newisbn );
                }
            }
        }
        # fix the unimarc 100 coded field (with unicode information)
        if ($marcflavour eq 'UNIMARC' && $record->subfield(100,'a')) {
            my $f100a=$record->subfield(100,'a');
            my $f100 = $record->field(100);
            my $f100temp = $f100->as_string;
            $record->delete_field($f100);
            if ( length($f100temp) > 28 ) {
                substr( $f100temp, 26, 2, "50" );
                $f100->update( 'a' => $f100temp );
                my $f100 = MARC::Field->new( '100', '', '', 'a' => $f100temp );
                $record->insert_fields_ordered($f100);
            }
        }
        
        if ( !defined(ref($record)) ) {
            return -1;
        }
        else {
            # normalize author : probably UNIMARC specific...
            if (    C4::Context->preference("z3950NormalizeAuthor")
                and C4::Context->preference("z3950AuthorAuthFields") )
            {
                my ( $tag, $subfield ) = GetMarcFromKohaField("biblio.author", '');

#                 my $summary = C4::Context->preference("z3950authortemplate");
                my $auth_fields =
                C4::Context->preference("z3950AuthorAuthFields");
                my @auth_fields = split /,/, $auth_fields;
                my $field;

                if ( $record->field($tag) ) {
                    foreach my $tmpfield ( $record->field($tag)->subfields ) {

    #                        foreach my $subfieldcode ($tmpfield->subfields){
                        my $subfieldcode  = shift @$tmpfield;
                        my $subfieldvalue = shift @$tmpfield;
                        if ($field) {
                            $field->add_subfields(
                                "$subfieldcode" => $subfieldvalue )
                            if ( $subfieldcode ne $subfield );
                        }
                        else {
                            $field =
                            MARC::Field->new( $tag, "", "",
                                $subfieldcode => $subfieldvalue )
                            if ( $subfieldcode ne $subfield );
                        }
                    }
                }
                $record->delete_field( $record->field($tag) );
                foreach my $fieldtag (@auth_fields) {
                    next unless ( $record->field($fieldtag) );
                    my $lastname  = $record->field($fieldtag)->subfield('a');
                    my $firstname = $record->field($fieldtag)->subfield('b');
                    my $title     = $record->field($fieldtag)->subfield('c');
                    my $number    = $record->field($fieldtag)->subfield('d');
                    if ($title) {

#                         $field->add_subfields("$subfield"=>"[ ".ucfirst($title).ucfirst($firstname)." ".$number." ]");
                        $field->add_subfields(
                                "$subfield" => ucfirst($title) . " "
                            . ucfirst($firstname) . " "
                            . $number );
                    }
                    else {

#                       $field->add_subfields("$subfield"=>"[ ".ucfirst($firstname).", ".ucfirst($lastname)." ]");
                        $field->add_subfields(
                            "$subfield" => ucfirst($firstname) . ", "
                            . ucfirst($lastname) );
                    }
                }
                $record->insert_fields_ordered($field);
            }
            return $record, $encoding;
        }
    }
    return -1;
}

sub Load_Duplicate {
  my ($duplicatetitle)= @_;
  ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => "acqui/neworderempty_duplicate.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
#        debug           => 1,
    }
  );

  $template->param(
    biblionumber        => $biblionumber,
    basketno            => $basketno,
    booksellerid        => $basket->{'booksellerid'},
    breedingid          => $params->{'breedingid'},
    duplicatetitle      => $duplicatetitle,
    (uc(C4::Context->preference("marcflavour"))) => 1
  );

  output_html_with_http_headers $input, $cookie, $template->output;
}
