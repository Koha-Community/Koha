#!/usr/bin/perl

#script to group (closed) baskets into basket groups for easier order management
#written by john.soros@biblibre.com 01/10/2008

# Copyright 2008 - 2009 BibLibre SARL
# Parts Copyright Catalyst 2010
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

basketgroup.pl

=head1 DESCRIPTION

 This script lets the user group (closed) baskets into basket groups for easier order management. Note that the grouped baskets have to be from the same bookseller and
 have to be closed to be printed or exported.

=head1 CGI PARAMETERS

=over 4

=item $booksellerid

The bookseller who we want to display the baskets (and basketgroups) of.

=back

=cut

use Modern::Perl;
use Carp;

use C4::Auth;
use C4::Output;
use CGI qw ( -utf8 );

use C4::Acquisition qw/CloseBasketgroup ReOpenBasketgroup GetOrders GetBasketsByBasketgroup GetBasketsByBookseller ModBasketgroup NewBasketgroup DelBasketgroup GetBasketgroups ModBasket GetBasketgroup GetBasket GetBasketGroupAsCSV/;
use Koha::EDI qw/create_edi_order get_edifact_ean/;

use Koha::Biblioitems;
use Koha::Acquisition::Booksellers;
use Koha::ItemTypes;
use Koha::Patrons;

our $input=new CGI;

our ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/basketgroup.tt",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 'group_manage'},
			     debug => 1,
                });

sub BasketTotal {
    my $basketno = shift;
    my $bookseller = shift;
    my $total = 0;
    my @orders = GetOrders($basketno);
    for my $order (@orders){
        # FIXME The following is wrong
        if ( $bookseller->listincgst ) {
            $total = $total + ( $order->{ecost_tax_included} * $order->{quantity} );
        } else {
            $total = $total + ( $order->{ecost_tax_excluded} * $order->{quantity} );
        }
    }
    return $total;
}

#displays all basketgroups and all closed baskets (in their respective groups)
sub displaybasketgroups {
    my $basketgroups = shift;
    my $bookseller = shift;
    my $baskets = shift;
    if (scalar @$basketgroups != 0) {
        foreach my $basketgroup (@$basketgroups){
            my $i = 0;
            my $basketsqty = 0;
            while($i < scalar(@$baskets)){
                my $basket = @$baskets[$i];
                if($basket->{'basketgroupid'} && $basket->{'basketgroupid'} == $basketgroup->{'id'}){
                    $basket->{total} = BasketTotal($basket->{basketno}, $bookseller);
                    push(@{$basketgroup->{'baskets'}}, $basket);
                    splice(@$baskets, $i, 1);
                    ++$basketsqty;
                    --$i;
                }
                ++$i;
            }
            $basketgroup -> {'basketsqty'} = $basketsqty;
        }
        $template->param(basketgroups => $basketgroups);
    }
    for(my $i=0; $i < scalar @$baskets; ++$i) {
        if( ! @$baskets[$i]->{'closedate'} ) {
            splice(@$baskets, $i, 1);
            --$i;
        }else{
            @$baskets[$i]->{total} = BasketTotal(@$baskets[$i]->{basketno}, $bookseller);
        }
    }
    $template->param(baskets => $baskets);
    $template->param( booksellername => $bookseller->name);
}

sub printbasketgrouppdf{
    my ($basketgroupid) = @_;
    
    my $pdfformat = C4::Context->preference("OrderPdfFormat");
    if ($pdfformat eq 'pdfformat::layout3pages' || $pdfformat eq 'pdfformat::layout2pages' || $pdfformat eq 'pdfformat::layout3pagesfr'
        || $pdfformat eq 'pdfformat::layout2pagesde'){
	eval {
        eval "require $pdfformat";
	    import $pdfformat;
	};
	if ($@){
	}
    }
    else {
	print $input->header;  
	print $input->start_html;  # FIXME Should do a nicer page
	print "<h1>Invalid PDF Format set</h1>";
	print "Please go to the systempreferences and set a valid pdfformat";
	exit;
    }
    
    my $basketgroup = GetBasketgroup($basketgroupid);
    my $bookseller = Koha::Acquisition::Booksellers->find( $basketgroup->{booksellerid} );
    my $baskets = GetBasketsByBasketgroup($basketgroupid);
    
    my %orders;
    for my $basket (@$baskets) {
        my @ba_orders;
        my @ords = &GetOrders($basket->{basketno});
        for my $ord (@ords) {

            next unless ( $ord->{biblionumber} or $ord->{quantity}> 0 );
            eval {
                require C4::Biblio;
                import C4::Biblio;
            };
            if ($@){
                croak $@;
            }
            eval {
                require C4::Koha;
                import C4::Koha;
            };
            if ($@){
                croak $@;
            }

            $ord->{tax_value} = $ord->{tax_value_on_ordering};
            $ord->{tax_rate} = $ord->{tax_rate_on_ordering};
            $ord->{total_tax_included} = $ord->{ecost_tax_included} * $ord->{quantity};
            $ord->{total_tax_excluded} = $ord->{ecost_tax_excluded} * $ord->{quantity};

            my $biblioitem = Koha::Biblioitems->search({ biblionumber => $ord->{biblionumber} })->next;

            #FIXME DELETE ME
            # 0      1        2        3         4            5         6       7      8        9
            #isbn, itemtype, author, title, publishercode, quantity, listprice ecost discount tax_rate

            # Editor Number
            my $en;
            my $edition;
            $ord->{marcxml} = C4::Biblio::GetXmlBiblio( $ord->{biblionumber} );
            my $marcrecord=eval{MARC::Record::new_from_xml( $ord->{marcxml},'UTF-8' )};
            if ($marcrecord){
                if ( C4::Context->preference("marcflavour") eq 'UNIMARC' ) {
                    $en = $marcrecord->subfield( '345', "b" );
                    $edition = $marcrecord->subfield( '205', 'a' );
                } elsif ( C4::Context->preference("marcflavour") eq 'MARC21' ) {
                    $en = $marcrecord->subfield( '037', "a" );
                    $edition = $marcrecord->subfield( '250', 'a' );
                }
            }

            $ord->{itemtype} = ( $ord->{itemtype} and $biblioitem->itemtype ) ? Koha::ItemTypes->find( $biblioitem->itemtype )->description : undef;
            $ord->{en} = $en ? $en : undef;
            $ord->{edition} = $edition ? $edition : undef;

            push(@ba_orders, $ord);
        }
        $orders{$basket->{basketno}} = \@ba_orders;
    }
    print $input->header(
        -type       => 'application/pdf',
        -attachment => ( $basketgroup->{name} || $basketgroupid ) . '.pdf'
    );
    my $pdf = printpdf($basketgroup, $bookseller, $baskets, \%orders, $bookseller->tax_rate // C4::Context->preference("gist")) || die "pdf generation failed";
    print $pdf;

}

sub generate_edifact_orders {
    my $basketgroupid = shift;
    my $baskets       = GetBasketsByBasketgroup($basketgroupid);
    my $ean           = get_edifact_ean();

    for my $basket ( @{$baskets} ) {
        create_edi_order( { ean => $ean, basketno => $basket->{basketno}, } );
    }
    return;
}

my $op = $input->param('op') || 'display';
# possible values of $op :
# - add : adds a new basketgroup, or edit an open basketgroup, or display a closed basketgroup
# - mod_basket : modify an individual basket of the basketgroup
# - closeandprint : close and print an closed basketgroup in pdf. called by clicking on "Close and print" button in closed basketgroups list
# - print : print a closed basketgroup. called by clicking on "Print" button in closed basketgroups list
# - ediprint : generate edi order messages for the baskets in the group
# - export : export in CSV a closed basketgroup. called by clicking on "Export" button in closed basketgroups list
# - delete : delete an open basketgroup. called by clicking on "Delete" button in open basketgroups list
# - reopen : reopen a closed basketgroup. called by clicking on "Reopen" button in closed basketgroup list
# - attachbasket : save a modified basketgroup, or creates a new basketgroup when a basket is closed. called from basket page
# - display : display the list of all basketgroups for a vendor
my $booksellerid = $input->param('booksellerid');
$template->param(booksellerid => $booksellerid);

if ( $op eq "add" ) {
#
# if no param('basketgroupid') is not defined, adds a new basketgroup
# else, edit (if it is open) or display (if it is close) the basketgroup basketgroupid
# the template will know if basketgroup must be displayed or edited, depending on the value of closed key
#
    my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );
    my $basketgroupid = $input->param('basketgroupid');
    my $billingplace;
    my $deliveryplace;
    my $freedeliveryplace;
    if ( $basketgroupid ) {
        # Get the selected baskets in the basketgroup to display them
        my $selecteds = GetBasketsByBasketgroup($basketgroupid);
        foreach my $basket(@{$selecteds}){
            $basket->{total} = BasketTotal($basket->{basketno}, $bookseller);
        }
        $template->param(basketgroupid => $basketgroupid,
                         selectedbaskets => $selecteds);

        # Get general informations about the basket group to prefill the form
        my $basketgroup = GetBasketgroup($basketgroupid);
        $template->param(
            name            => $basketgroup->{name},
            deliverycomment => $basketgroup->{deliverycomment},
            freedeliveryplace => $basketgroup->{freedeliveryplace},
        );
        $billingplace  = $basketgroup->{billingplace};
        $deliveryplace = $basketgroup->{deliveryplace};
        $freedeliveryplace = $basketgroup->{freedeliveryplace};
        $template->param( closedbg => ($basketgroup ->{'closed'}) ? 1 : 0);
    } else {
        $template->param( closedbg => 0);
    }
    # determine default billing and delivery places depending on librarian homebranch and existing basketgroup data
    my $patron = Koha::Patrons->find( $loggedinuser ); # FIXME Not needed if billingplace and deliveryplace are set
    $billingplace  = $billingplace  || $patron->branchcode;
    $deliveryplace = $deliveryplace || $patron->branchcode;

    $template->param( billingplace => $billingplace );
    $template->param( deliveryplace => $deliveryplace );
    $template->param( booksellerid => $booksellerid );

    # the template will display a unique basketgroup
    $template->param(grouping => 1);
    my $basketgroups = &GetBasketgroups($booksellerid);
    my $baskets = &GetBasketsByBookseller($booksellerid);
    displaybasketgroups($basketgroups, $bookseller, $baskets);
} elsif ($op eq 'mod_basket') {
#
# edit an individual basket contained in this basketgroup
#
  my $basketno=$input->param('basketno');
  my $basketgroupid=$input->param('basketgroupid');
  ModBasket( { basketno => $basketno,
                         basketgroupid => $basketgroupid } );
  print $input->redirect("basket.pl?basketno=" . $basketno);
} elsif ( $op eq 'closeandprint') {
#
# close an open basketgroup and generates a pdf
#
    my $basketgroupid = $input->param('basketgroupid');
    CloseBasketgroup($basketgroupid);
    printbasketgrouppdf($basketgroupid);
    exit;
}elsif ($op eq 'print'){
#
# print a closed basketgroup
#
    my $basketgroupid = $input->param('basketgroupid');
    printbasketgrouppdf($basketgroupid);
    exit;
}elsif ( $op eq "export" ) {
#
# export a closed basketgroup in csv
#
    my $basketgroupid = $input->param('basketgroupid');
    print $input->header(
        -type       => 'text/csv',
        -attachment => 'basketgroup' . $basketgroupid . '.csv',
    );
    print GetBasketGroupAsCSV( $basketgroupid, $input );
    exit;
}elsif( $op eq "delete"){
#
# delete an closed basketgroup
#
    my $basketgroupid = $input->param('basketgroupid');
    DelBasketgroup($basketgroupid);
    print $input->redirect('/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=' . $booksellerid.'&amp;listclosed=1');
}elsif ( $op eq 'reopen'){
#
# reopen a closed basketgroup
#
    my $basketgroupid   = $input->param('basketgroupid');
    my $booksellerid    = $input->param('booksellerid');
    ReOpenBasketgroup($basketgroupid);
    my $redirectpath = ((defined $input->param('mode'))&& ($input->param('mode') eq 'singlebg')) ?'/cgi-bin/koha/acqui/basketgroup.pl?op=add&amp;basketgroupid='.$basketgroupid.'&amp;booksellerid='.$booksellerid : '/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=' .$booksellerid.'&amp;listclosed=1';
    print $input->redirect($redirectpath);
} elsif ( $op eq 'attachbasket') {
#
# save a modified basketgroup, or creates a new basketgroup when a basket is closed. called from basket page
#
    # Getting parameters
    my $basketgroup       = {};
    my @baskets           = $input->multi_param('basket');
    my $basketgroupid     = $input->param('basketgroupid');
    my $basketgroupname   = $input->param('basketgroupname');
    my $booksellerid      = $input->param('booksellerid');
    my $billingplace      = $input->param('billingplace');
    my $deliveryplace     = $input->param('deliveryplace');
    my $freedeliveryplace = $input->param('freedeliveryplace');
    my $deliverycomment   = $input->param('deliverycomment');
    my $closedbg          = $input->param('closedbg') ? 1 : 0;
    if ($basketgroupid) {
    # If we have a basketgroupid we edit the basketgroup
        $basketgroup = {
              name              => $basketgroupname,
              id                => $basketgroupid,
              basketlist        => \@baskets,
              billingplace      => $billingplace,
              deliveryplace     => $deliveryplace,
              freedeliveryplace => $freedeliveryplace,
              deliverycomment   => $deliverycomment,
              closed            => $closedbg,
        };
        ModBasketgroup($basketgroup);
        if($closedbg){
# FIXME
        }
    }else{
    # we create a new basketgroup (with a closed basket)
        $basketgroup = {
            name              => $basketgroupname,
            booksellerid      => $booksellerid,
            basketlist        => \@baskets,
            billingplace      => $billingplace,
            deliveryplace     => $deliveryplace,
            freedeliveryplace => $freedeliveryplace,
            deliverycomment   => $deliverycomment,
            closed            => $closedbg,
        };
        $basketgroupid = NewBasketgroup($basketgroup);
    }
    my $redirectpath = ((defined $input->param('mode')) && ($input->param('mode') eq 'singlebg')) ?'/cgi-bin/koha/acqui/basketgroup.pl?op=add&amp;basketgroupid='.$basketgroupid.'&amp;booksellerid='.$booksellerid : '/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=' . $booksellerid;
    $redirectpath .=  "&amp;listclosed=1" if $closedbg ;
    print $input->redirect($redirectpath );
    
} elsif ( $op eq 'ediprint') {
    my $basketgroupid = $input->param('basketgroupid');
    generate_edifact_orders( $basketgroupid );
    exit;
}else{
# no param : display the list of all basketgroups for a given vendor
    my $basketgroups = &GetBasketgroups($booksellerid);
    my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );
    my $baskets = &GetBasketsByBookseller($booksellerid);

    displaybasketgroups($basketgroups, $bookseller, $baskets);
}
$template->param(listclosed => ((defined $input->param('listclosed')) && ($input->param('listclosed') eq '1'))? 1:0 );
#prolly won't use all these, maybe just use print, the rest can be done inside validate
output_html_with_http_headers $input, $cookie, $template->output;
