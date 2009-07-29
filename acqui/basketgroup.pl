#!/usr/bin/perl

#script to group (closed) baskets into basket groups for easier order management
#written by john.soros@biblibre.com 01/10/2008

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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 NAME

basketgroup.pl

=head1 DESCRIPTION

 This script lets the user group (closed) baskets into basket groups for easier order management. Note that the grouped baskets have to be from the same bookseller and
 have to be closed.

=head1 CGI PARAMETERS

=over 4

=item $booksellerid

The bookseller who we want to display the baskets (and basketgroups) of.

=back

=cut

use strict;
use warnings;

use C4::Input;
use C4::Auth;
use C4::Output;
use CGI;

use C4::Bookseller qw/GetBookSellerFromId/;
use C4::Acquisition qw/GetOrders GetBasketsByBasketgroup GetBasketsByBookseller ModBasketgroup NewBasketgroup DelBasketgroup GetBasketgroups ModBasket GetBasketgroup/;
use C4::Bookseller qw/GetBookSellerFromId/;

my $input=new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui/basketgroup.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 'group_manage'},
			     debug => 1,
                });

sub parseinputbaskets {
    my $booksellerid = shift;
    my $baskets = &GetBasketsByBookseller($booksellerid);
    for(my $i=0; $i < scalar @$baskets; ++$i) {
        if( @$baskets[$i] && ! @$baskets[$i]->{'closedate'} ) {
            splice(@$baskets, $i, 1);
            --$i;
        }
    }
    foreach my $basket (@$baskets){
#perl DBI uses value "undef" for the mysql "NULL" value, so i need to check everywhere where $basket->{'basketgroupid'} is used for undef ☹
        $basket->{'basketgroupid'} = $input->param($basket->{'basketno'}.'-group') || undef;
    }
    return $baskets;
}



sub parseinputbasketgroups {
    my $booksellerid = shift;
    my $baskets = shift;
    my $basketgroups = &GetBasketgroups($booksellerid);
    my $newbasketgroups;
    foreach my $basket (@$baskets){
        my $basketgroup;
        my $i = 0;
        my $exists;
        if(! $basket->{'basketgroupid'} || $basket->{'basketgroupid'} == 0){
            $exists = "true";
        } else {
            foreach my $basketgroup (@$basketgroups){
                if($basket->{'basketgroupid'} == $basketgroup->{'id'}){
                    $exists = "true";
                    push(@{$basketgroup->{'basketlist'}}, $basket->{'basketno'});
                    last;
                }
            }
        }
        if (! $exists){
#if the basketgroup doesn't exist yet
            $basketgroup = $newbasketgroups->{$basket->{'basketgroupid'}} || undef;
            $basketgroup->{'booksellerid'} = $booksellerid;
        } else {
            while($i < scalar @$basketgroups && @$basketgroups[$i]->{'id'} != $basket->{'basketgroupid'}){
                ++$i;
            }
            $basketgroup = @$basketgroups[$i];
        }
        $basketgroup->{'id'}=$basket->{'basketgroupid'};
        $basketgroup->{'name'}=$input->param('basketgroup-'.$basketgroup->{'id'}.'-name') || "";
        $basketgroup->{'closed'}= $input->param('basketgroup-'.$basketgroup->{'id'}.'-closed');
        push(@{$basketgroup->{'basketlist'}}, $basket->{'basketno'});
        if (! $exists){
            $newbasketgroups->{$basket->{'basketgroupid'}} = $basketgroup;
        } else {
            if($basketgroup->{'id'}){
                @$basketgroups[$i] = $basketgroup;
            }
        }
    }
    return($basketgroups, $newbasketgroups);
}

sub BasketTotal {
    my $basketno = shift;
    my $bookseller = shift;
    my $total = 0;
    my @orders = GetOrders($basketno);
    for my $order (@orders){
        $total = $total + ( $order->{ecost} * $order->{quantity} );
        if ($bookseller->{invoiceincgst} && ! $bookseller->{listincgst} && ( $bookseller->{gstrate} || C4::Context->preference("gist") )) {
            my $gst = $bookseller->{gstrate} || C4::Context->preference("gist");
            $total = $total * ( $gst / 100 +1);
        }
    }
    $total .= $bookseller->{invoiceprice};
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
            while($i < scalar(@$baskets)){
                my $basket = @$baskets[$i];
                if($basket->{'basketgroupid'} && $basket->{'basketgroupid'} == $basketgroup->{'id'}){
                    $basket->{total} = BasketTotal($basket->{basketno}, $bookseller);
                    push(@{$basketgroup->{'baskets'}}, $basket);
                    splice(@$baskets, $i, 1);
                    --$i;
                }
                ++$i;
            }
        }
        $template->param(basketgroups => $basketgroups);
    }
    for(my $i=0; $i < scalar @$baskets; ++$i) {
        if( ! @$baskets[$i]->{'closedate'} ) {
            splice(@$baskets, $i, 1);
            --$i;
        }
    }
    $template->param(baskets => $baskets);
    $template->param( booksellername => $bookseller ->{'name'});
}


my $op = $input->param('op');
my $booksellerid = $input->param('booksellerid');

if (! $op ) {
    if(! $booksellerid){
        $template->param( ungroupedlist => 1);
        my @booksellers = GetBookSeller('');
       for (my $i=0; $i < scalar @booksellers; $i++) {
            my $baskets = &GetBasketsByBookseller($booksellers[$i]->{id});
            for (my $j=0; $j < scalar @$baskets; $j++) {
                if(! @$baskets[$i]->{closedate} || @$baskets[$i]->{basketgroupid}) {
                    splice(@$baskets, $j, 1);
                    $j--;
                }
            }
            if (scalar @$baskets == 0){
                splice(@booksellers, $i, 1);
                $i--;
            }
        }
    } else {
        $template->param( booksellerid => $booksellerid );
    }
    my $basketgroups = &GetBasketgroups($booksellerid);
    my $bookseller = &GetBookSellerFromId($booksellerid);
    my $baskets = &GetBasketsByBookseller($booksellerid);

    displaybasketgroups($basketgroups, $bookseller, $baskets);
} elsif ($op eq 'mod_basket') {
#we want to modify an individual basket's group
  my $basketno=$input->param('basketno');
  my $basketgroupid=$input->param('basketgroupid');
  ModBasket( { basketno => $basketno,
                         basketgroupid => $basketgroupid } );
  print $input->redirect("basket.pl?basketno=" . $basketno);
} elsif ($op eq 'validate') {
    if(! $booksellerid){
        $template->param( booksellererror => 1);
    } else {
        $template->param( booksellerid => $booksellerid );
    }
    my $baskets = parseinputbaskets($booksellerid);
    my ($basketgroups, $newbasketgroups) = parseinputbasketgroups($booksellerid, $baskets);
    foreach my $nbgid (keys %$newbasketgroups){
#javascript just picks an ID that's higher than anything else, the ID might not be correct..chenge it and change all the basket's basketgroupid as well
        my $bgid = NewBasketgroup($newbasketgroups->{$nbgid});
        ${$newbasketgroups->{$nbgid}}->{'id'} = $bgid;
        ${$newbasketgroups->{$nbgid}}->{'oldid'} = $nbgid;
    }
    foreach my $basket (@$baskets){
#if the basket was added to a new basketgroup, first change the groupid to the groupid of the basket in mysql, because it contains the id from javascript otherwise.
        if ( $basket->{'basketgroupid'} && $newbasketgroups->{$basket->{'basketgroupid'}} ){
            $basket->{'basketgroupid'} = ${$newbasketgroups->{$basket->{'basketgroupid'}}}->{'id'};
        }
        ModBasket($basket);
    }
    foreach my $basketgroup (@$basketgroups){
        if(! $basketgroup->{'id'}){
            foreach my $basket (@{$basketgroup->{'baskets'}}){
                if($input->param('basket'.$basket->{'basketno'}.'changed')){
                    ModBasket($basket);
                }
            }
        } elsif ($input->param('basketgroup-'.$basketgroup->{'id'}.'-changed')){
            ModBasketgroup($basketgroup);
        }
    }
    $basketgroups = &GetBasketgroups($booksellerid);
    my $bookseller = &GetBookSellerFromId($booksellerid);
    $baskets = &GetBasketsByBookseller($booksellerid);

    displaybasketgroups($basketgroups, $bookseller, $baskets);
} elsif ( $op eq 'printbgroup') {
    my $pdfformat = C4::Context->preference("pdfformat");
    eval "use $pdfformat" ;
    eval "use C4::Branch";
    my $basketgroupid = $input->param('bgroupid');
    my $basketgroup = GetBasketgroup($basketgroupid);
    my $bookseller = GetBookSellerFromId($basketgroup->{'booksellerid'});
    my $baskets = GetBasketsByBasketgroup($basketgroupid);
    my %orders;
    for my $basket (@$baskets) {
        my @ba_orders;
        my @ords = &GetOrders($basket->{basketno});
        for my $ord (@ords) {
            # ba_order is filled with : 
            # 0      1        2        3         4            5         6       7      8        9
            #isbn, itemtype, author, title, publishercode, quantity, listprice ecost discount gstrate
            my @ba_order;
            if ( $ord->{biblionumber} && $ord->{quantity}> 0 ) {
                eval "use C4::Biblio";
                eval "use C4::Koha";
                my $bib = GetBiblioData($ord->{biblionumber});
                my $itemtypes = GetItemTypes();
                if($ord->{isbn}){
                    push(@ba_order, $ord->{isbn});
                } else {
                    push(@ba_order, undef);
                }
                if ($ord->{itemtype}){
                    push(@ba_order, $itemtypes->{$bib->{itemtype}}->{description}) if $bib->{itemtype};
                } else {
                    push(@ba_order, undef);
                }
#             } else {
#                 push(@ba_order, undef, undef);
                for my $key (qw/author title publishercode quantity listprice ecost/) {
                    push(@ba_order, $ord->{$key});                                                  #Order lines
                }
                push(@ba_order, $bookseller->{discount});
                push(@ba_order, $bookseller->{gstrate}*100 || C4::Context->preference("gist") || 0);
                push(@ba_orders, \@ba_order);
                # Editor Number
                my $en;
                if (C4::Context->preference("marcflavour") eq 'UNIMARC') {
                    $en = MARC::Record::new_from_xml($ord->{marcxml},'UTF-8')->subfield('345',"b");
                } elsif (C4::Context->preference("marcflavour") eq 'MARC21') {
                    $en = MARC::Record::new_from_xml($ord->{marcxml},'UTF-8')->subfield('037',"a");
                }
                if($en){
                    push(@ba_order, $en);
                } else {
                    push(@ba_order, undef);
                }
            }
        }
        %orders->{$basket->{basketno}}=\@ba_orders;
    }
    print $input->header( -type => 'application/pdf', -attachment => 'basketgroup.pdf' );
    my $branch = GetBranchInfo(GetBranch($input, GetBranches()));
    $branch = @$branch[0];
    my $pdf = printpdf($basketgroup, $bookseller, $baskets, $branch, \%orders, $bookseller->{gstrate} || C4::Context->preference("gist")) || die "pdf generation failed";
    print $pdf;
    exit;
} elsif ( $op eq 'attachbasket') {
    # TODO: create basketgroup and attach basket to it?
    my $basketgroup = {};
    $basketgroup->{'name'} = $input->param('basketgroupname');
    $basketgroup->{'booksellerid'} = $input->param('booksellerid');
    my $basketgroupid;
    my $basketno = $input->param('basketno');
    warn "basketgroupname", $basketgroup->{'name'};
    if ($basketgroup->{'name'}) {
        $basketgroupid = NewBasketgroup($basketgroup);
    } else {
        $basketgroupid = $input->param('basketgroupid');
    }
    if ($input->param('closebasketgroup')){
        #we override $basketgroup on purpose here
        my $basketgroup= {};
        $basketgroup->{'closed'} = 1;
        $basketgroup->{'id'} = $basketgroupid;
        ModBasketgroup($basketgroup)
    }
    my $basket = {};
    $basket->{'basketno'} = $basketno;
    $basket->{'basketgroupid'} = $basketgroupid;
    ModBasket($basket);
    $basketgroup = GetBasketgroup($basketgroupid);
    my $baskets = GetBasketsByBasketgroup($basketgroupid);
    my $bookseller = &GetBookSellerFromId($booksellerid);
    my @basketgroups;
    push(@basketgroups, $basketgroup);
    $template->param(displayclosedbgs => 1,
                     booksellerid => $booksellerid);
    displaybasketgroups(\@basketgroups, $bookseller, $baskets);
}
#prolly won't use all these, maybe just use print, the rest can be done inside validate
output_html_with_http_headers $input, $cookie, $template->output;
