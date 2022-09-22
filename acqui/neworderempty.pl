#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

# Copyright 2000-2002 Katipo Communications
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

=back

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;

use C4::Auth qw( get_template_and_user );
use C4::Budgets qw( GetBudget GetBudgetHierarchy CanUserUseBudget );

use C4::Acquisition qw( GetOrder GetBasket FillWithDefaultValues GetOrderUsers );
use C4::Contract qw( GetContract );
use C4::Suggestions qw( GetSuggestion GetSuggestionInfo );
use C4::Biblio qw(
    AddBiblio
    GetBiblioData
    GetMarcFromKohaField
    GetMarcPrice
    GetMarcStructure
    IsMarcStructureInternal
);
use C4::Output qw( output_and_exit output_html_with_http_headers );
use C4::Members;
use C4::Search qw( FindDuplicate );

#needed for z3950 import:
use C4::ImportBatch qw( SetImportRecordStatus SetMatchedBiblionumber GetImportRecordMarc );

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Currencies qw( get_active );
use Koha::Biblios;
use Koha::BiblioFrameworks;
use Koha::DateUtils qw( dt_from_string );
use Koha::MarcSubfieldStructures;
use Koha::ItemTypes;
use Koha::Patrons;
use Koha::RecordProcessor;
use Koha::Subscriptions;
use Koha::UI::Form::Builder::Biblio;

our $input           = CGI->new;
my $booksellerid    = $input->param('booksellerid');	# FIXME: else ERROR!
my $budget_id       = $input->param('budget_id') || 0;
my $title           = $input->param('title');
my $author          = $input->param('author');
my $publicationyear = $input->param('publicationyear');
my $ordernumber          = $input->param('ordernumber') || '';
our $biblionumber    = $input->param('biblionumber');
our $basketno        = $input->param('basketno');
my $suggestionid    = $input->param('suggestionid');
my $uncertainprice  = $input->param('uncertainprice');
my $import_batch_id = $input->param('import_batch_id'); # if this is filled, we come from a staged file, and we will return here after saving the order !
my $from_subscriptionid  = $input->param('from_subscriptionid');
my $data;
my $new = 'no';

our ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name   => "acqui/neworderempty.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { acquisition => 'order_manage' },
    }
);

our $marcflavour = C4::Context->preference('marcflavour');

if(!$basketno) {
    my $order = GetOrder($ordernumber);
    $basketno = $order->{'basketno'};
}

our $basket = GetBasket($basketno);
my $basketobj = Koha::Acquisition::Baskets->find( $basketno );
$booksellerid = $basket->{booksellerid} unless $booksellerid;
my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );

output_and_exit( $input, $cookie, $template, 'unknown_basket') unless $basketobj;
output_and_exit( $input, $cookie, $template, 'unknown_vendor') unless $bookseller;

$template->param(
    ordernumber  => $ordernumber,
    basketno     => $basketno,
    basket       => $basket,
    booksellerid => $basket->{'booksellerid'},
    name         => $bookseller->name,
);
output_and_exit( $input, $cookie, $template, 'order_cannot_be_edited' )
    if $ordernumber and $basketobj->closedate;

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
        #and let them choose between using a new record or an existing record
        Load_Duplicate($duplicatetitle);
        exit;
    }
    #from this point: add a new record
    C4::Acquisition::FillWithDefaultValues($marcrecord, {only_mandatory => 1});
    my $bibitemnum;
    $params->{'frameworkcode'} or $params->{'frameworkcode'} = "";
    ( $biblionumber, $bibitemnum ) = AddBiblio( $marcrecord, $params->{'frameworkcode'} );
    # get the price if there is one.
    $listprice = GetMarcPrice($marcrecord, $marcflavour);
    SetImportRecordStatus($params->{'breedingid'}, 'imported');

    SetMatchedBiblionumber( $params->{breedingid}, $biblionumber );
}



my ( @order_user_ids, @order_users, @catalog_details );
our $tagslib = GetMarcStructure(1, 'ACQ', { unsafe => 1 } );
my ( $itemnumber_tag, $itemnumber_subtag ) = GetMarcFromKohaField( 'items.itemnumber' );
if ( not $ordernumber ) {    # create order
    $new = 'yes';

    if ( $biblionumber ) {
        $data = GetBiblioData($biblionumber);
    }
    # get suggestion fields if applicable. If it's a subscription renewal, then the biblio already exists
    # otherwise, retrieve suggestion information.
    elsif ($suggestionid) {
        $data = GetSuggestion($suggestionid);
        $budget_id ||= $data->{'budgetid'} // 0;
    }

    if ( not $biblionumber and Koha::BiblioFrameworks->find('ACQ') ) {
        my $biblio_form_builder = Koha::UI::Form::Builder::Biblio->new();
        foreach my $tag ( sort keys %{$tagslib} ) {
            next if $tag eq '';
            next if $tag eq $itemnumber_tag;    # skip items fields
            my $index_tag = int(rand(1000000));
            foreach my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
                my $mss = $tagslib->{$tag}{$subfield};
                next if IsMarcStructureInternal($mss);
                next if $mss->{tab} == -1;
                my $value = $mss->{defaultvalue};

                if ($suggestionid and $mss->{kohafield}) {
                    # Reading suggestion info if ordering from a suggestion
                    if ( $mss->{kohafield} eq 'biblio.title' ) {
                        $value = $data->{title};
                    }
                    elsif ( $mss->{kohafield} eq 'biblio.author' ) {
                        $value = $data->{author};
                    }
                    elsif ( $mss->{kohafield} eq 'biblioitems.publishercode' ) {
                        $value = $data->{publishercode};
                    }
                    elsif ( $mss->{kohafield} eq 'biblioitems.editionstatement' ) {
                        $value = $data->{editionstatement};
                    }
                    elsif ( $mss->{kohafield} eq 'biblioitems.publicationyear' ) {
                        $value = $data->{publicationyear};
                    }
                    elsif ( $mss->{kohafield} eq 'biblioitems.isbn' ) {
                        $value = $data->{isbn};
                    }
                    elsif ( $mss->{kohafield} eq 'biblio.seriestitle' ) {
                        $value = $data->{seriestitle};
                    }
                }

                push @catalog_details, $biblio_form_builder->generate_subfield_form(
                    {
                        tag => $tag,
                        subfield => $subfield,
                        value => $value,
                        index_tag => $index_tag,
                        tagslib => $tagslib,
                    }
                );
            }
        }
    }
}
else {    #modify order
    $data   = GetOrder($ordernumber);
    $budget_id = $data->{'budget_id'};

    $template->param(
        subscriptionid => $data->{subscriptionid},
    );

    $basket   = GetBasket( $data->{'basketno'} );
    $basketno = $basket->{'basketno'};

    @order_user_ids = GetOrderUsers($ordernumber);
    foreach my $order_user_id (@order_user_ids) {
        # FIXME Could be improved with search -in
        my $order_patron = Koha::Patrons->find( $order_user_id );
        push @order_users, $order_patron if $order_patron;
    }
}
$biblionumber = $data->{biblionumber};

# We can have:
# - no ordernumber but a biblionumber: from a subscription, from an existing record
# - no ordernumber, no biblionumber: from a suggestion, from a new order
if ( not $ordernumber or $biblionumber ) {
    if ( C4::Context->preference('UseACQFrameworkForBiblioRecords') ) {
        my $biblio = Koha::Biblios->find($biblionumber);
        my $record = $biblio ? $biblio->metadata->record : undef;
        my $biblio_form_builder = Koha::UI::Form::Builder::Biblio->new(
            {
                biblionumber => $biblionumber,
            }
        );
        foreach my $tag ( sort keys %{$tagslib} ) {
            next if $tag eq '';
            next if $tag eq $itemnumber_tag; # skip items fields
            my @fields = $biblionumber ? $record->field($tag) : ();
            my $index_tag = int(rand(1000000));
            foreach my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
                my $mss = $tagslib->{$tag}{$subfield};
                next if IsMarcStructureInternal($mss);
                next if $mss->{tab} == -1;
                # We only need to display the values
                my $value = join '; ', map { $tag < 10 ? $_->data : $_->subfield( $subfield ) } @fields;
                if ( $value ) {
                    push @catalog_details, $biblio_form_builder->generate_subfield_form(
                        {
                            tag => $tag,
                            subfield => $subfield,
                            value => $value,
                            index_tag => $index_tag,
                            record => $record,
                            tagslib => $tagslib,
                        }
                    );
                }
            }
        }
    }
}

$template->param( catalog_details => \@catalog_details, );

my $suggestion;
$suggestion = GetSuggestionInfo($suggestionid) if $suggestionid;

my $active_currency = Koha::Acquisition::Currencies->get_active;

# build bookfund list
my $patron = Koha::Patrons->find( $loggedinuser )->unblessed;

my $budget =  GetBudget($budget_id);
# build budget list
my $budget_loop = [];
my $budgets = GetBudgetHierarchy;
foreach my $r (@{$budgets}) {
    next unless (CanUserUseBudget($patron, $r, $userflags));
    push @{$budget_loop}, {
        b_id  => $r->{budget_id},
        b_txt => $r->{budget_name},
        b_sort1_authcat => $r->{'sort1_authcat'},
        b_sort2_authcat => $r->{'sort2_authcat'},
        b_active => $r->{budget_period_active},
        b_sel => ( $r->{budget_id} == $budget_id ) ? 1 : 0,
        b_level => $r->{budget_level},
    };
}


$template->param( sort1 => $data->{'sort1'} );
$template->param( sort2 => $data->{'sort2'} );

if ($basketobj->effective_create_items eq 'ordering' && !$ordernumber) {
    # Check if ACQ framework exists
    my $marc = GetMarcStructure(1, 'ACQ', { unsafe => 1 } );
    unless($marc) {
        $template->param('NoACQframework' => 1);
    }
    $template->param(
        AcqCreateItemOrdering => 1,
        UniqueItemFields => C4::Context->preference('UniqueItemFields'),
    );
}

my @itemtypes = Koha::ItemTypes->search->as_list;

if ( defined $from_subscriptionid ) {
    # Get the last received order for this subscription
    my $lastOrderReceived = Koha::Acquisition::Orders->search(
        {
            subscriptionid => $from_subscriptionid,
            datereceived   => { '!=' => undef }
        },
        {
            order_by =>
              [ { -desc => 'datereceived' }, { -desc => 'ordernumber' } ]
        }
    );
    if ( $lastOrderReceived->count ) {
        $lastOrderReceived = $lastOrderReceived->next->unblessed; # FIXME We should send the object to the template
        $budget_id              = $lastOrderReceived->{budgetid};
        $data->{listprice}      = $lastOrderReceived->{listprice};
        $data->{uncertainprice} = $lastOrderReceived->{uncertainprice};
        $data->{tax_rate}       = $lastOrderReceived->{tax_rate_on_ordering};
        $data->{discount}       = $lastOrderReceived->{discount};
        $data->{rrp}            = $lastOrderReceived->{rrp};
        $data->{replacementprice} = $lastOrderReceived->{replacementprice};
        $data->{ecost}          = $lastOrderReceived->{ecost};
        $data->{quantity}       = $lastOrderReceived->{quantity};
        $data->{unitprice}       = $lastOrderReceived->{unitprice};
        $data->{order_internalnote} = $lastOrderReceived->{order_internalnote};
        $data->{order_vendornote}   = $lastOrderReceived->{order_vendornote};
        $data->{sort1}          = $lastOrderReceived->{sort1};
        $data->{sort2}          = $lastOrderReceived->{sort2};

        $basket = GetBasket( $input->param('basketno') );
    }

    my $subscription = Koha::Subscriptions->find($from_subscriptionid);
    $template->param(
        subscriptionid => $from_subscriptionid,
        subscription   => $subscription,
    );
}

# Find the items.barcode subfield for barcode validations
my (undef, $barcode_subfield) = GetMarcFromKohaField( 'items.barcode' );


# get option values for TaxRates syspref
my @gst_values = map {
    option => $_ + 0.0
}, split( '\|', C4::Context->preference("TaxRates") );

my $quantity = $input->param('rr_quantity_to_order') ?
      $input->param('rr_quantity_to_order') :
      $data->{'quantity'};
$quantity //= 0;

# fill template
$template->param(
    existing         => $biblionumber,
    # basket informations
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
    discount_2dp         => sprintf( "%.2f",  $bookseller->discount ) ,   # for display
    discount             => $bookseller->discount,
    orderdiscount_2dp    => sprintf( "%.2f", $data->{'discount'} || 0 ),
    orderdiscount        => $data->{'discount'},
    order_internalnote   => $data->{'order_internalnote'},
    order_vendornote     => $data->{'order_vendornote'},
    listincgst       => $bookseller->listincgst,
    invoiceincgst    => $bookseller->invoiceincgst,
    cur_active_sym   => $active_currency->symbol,
    cur_active       => $active_currency->currency,
    currencies       => Koha::Acquisition::Currencies->search,
    currency         => $data->{currency},
    vendor_currency  => $bookseller->listprice,
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
    replacementprice => $data->{'replacementprice'},
    gst_values       => \@gst_values,
    tax_rate         => $data->{tax_rate_on_ordering} ? $data->{tax_rate_on_ordering}+0.0 : $bookseller->tax_rate ? $bookseller->tax_rate+0.0 : 0,
    listprice        => sprintf( "%.2f", $data->{listprice} || $data->{price} || $listprice),
    total            => sprintf( "%.2f", ($data->{ecost} || 0) * ($data->{'quantity'} || 0) ),
    ecost            => sprintf( "%.2f", $data->{ecost} || 0),
    unitprice        => sprintf( "%.2f", $data->{unitprice} || 0),
    publishercode    => $data->{'publishercode'},
    barcode_subfield => $barcode_subfield,
    import_batch_id  => $import_batch_id,
    acqcreate        => $basketobj->effective_create_items eq "ordering" ? 1 : "",
    users_ids        => join(':', @order_user_ids),
    users            => \@order_users,
    (uc(C4::Context->preference("marcflavour"))) => 1,
    estimated_delivery_date => $data->{estimated_delivery_date},
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
        my ($isbnfield,$isbnsubfield) = GetMarcFromKohaField( 'biblioitems.isbn' );
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
                my ( $tag, $subfield ) = GetMarcFromKohaField( "biblio.author" );

                my $auth_fields =
                C4::Context->preference("z3950AuthorAuthFields");
                my @auth_fields = split /,/, $auth_fields;
                my $field;

                if ( $record->field($tag) ) {
                    foreach my $tmpfield ( $record->field($tag)->subfields ) {

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
                        $field->add_subfields(
                                "$subfield" => ucfirst($title) . " "
                            . ucfirst($firstname) . " "
                            . $number );
                    }
                    else {
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
        flagsrequired   => { acquisition => 'order_manage' },
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
