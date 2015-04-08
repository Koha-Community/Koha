#!/usr/bin/perl

#example script to print a basketgroup
#written 07/11/08 by john.soros@biblibre.com and paul.poulain@biblibre.com

# Copyright 2008-2009 BibLibre SARL
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

#you can use any PDF::API2 module, all you need to do is return the stringifyed pdf object from the printpdf sub.
package pdfformat::layout3pages;
use vars qw($VERSION @ISA @EXPORT);
use MIME::Base64;
use List::MoreUtils qw/uniq/;
use strict;
use warnings;
use utf8;

use C4::Branch qw(GetBranchDetail GetBranchName);

use Koha::Number::Price;

BEGIN {
         use Exporter   ();
         our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
	# set the version for version checking
         $VERSION     = 1.00;
	@ISA    = qw(Exporter);
	@EXPORT = qw(printpdf);
}


#be careful, all the sizes (height, width, etc...) are in mm, not PostScript points (the default measurment of PDF::API2).
#The constants exported tranform that into PostScript points (/mm for milimeter, /in for inch, pt is postscript point, and as so is there only to show what is happening.
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;

use PDF::API2;
#A4 paper specs
my ($height, $width) = (297, 210);
use PDF::Table;

sub printorders {
    my ($pdf, $basketgroup, $baskets, $orders) = @_;
    
    my $cur_format = C4::Context->preference("CurrencyFormat");

    $pdf->mediabox($height/mm, $width/mm);
    my $number = 3;
    for my $basket (@$baskets){
        my $page = $pdf->page();
        
        # print basket header (box)
        my $box = $page->gfx;
        $box->rectxy(($width - 10)/mm, ($height - 5)/mm, 10/mm, ($height - 25)/mm);
        $box->stroke;
#         $box->restore();
        
        # create a text
        my $text = $page->text;
        # add basketgroup number
        $text->font( $pdf->corefont("Times", -encoding => "utf8"), 6/mm );
        $text->translate(20/mm,  ($height-15)/mm);
        $text->text("Order no. ".$basketgroup->{'id'}.". Basket no. ".$basket->{basketno}.". ".$basket->{booksellernote});
        $text->translate(20/mm,  ($height-20)/mm);
        $text->font( $pdf->corefont("Times", -encoding => "utf8"), 4/mm );
        $text->text( ( $basket->{billingplace} ? "Billing at " . C4::Branch::GetBranchName( $basket->{billingplace} ) : "" )
            . ( $basket->{billingplace} and $basket->{deliveryplace} ? " and " : "" )
            . ( $basket->{deliveryplace} ? "delivery at " . C4::Branch::GetBranchName( $basket->{deliveryplace}) : "" )
        );

        my $pdftable = new PDF::Table();
        my $abaskets;
        my $arrbasket;
        my @keys = ('Document', 'Qty', 'RRP tax exc.', 'RRP tax inc.', 'Discount', 'Discount price', 'GST rate', 'Total tax exc.', 'Total tax inc.');
        for my $bkey (@keys) {
            push(@$arrbasket, $bkey);
        }
        push(@$abaskets, $arrbasket);

        my $titleinfo;
        foreach my $line (@{$orders->{$basket->{basketno}}}) {
            $arrbasket = undef;
            $titleinfo = "";
            if ( C4::Context->preference("marcflavour") eq 'UNIMARC' ) {
                $titleinfo =  $line->{title} . " / " . $line->{author} .
                    ( $line->{isbn} ? " ISBN: " . $line->{isbn} : '' ) .
                    ( $line->{en} ? " EN: " . $line->{en} : '' ) .
                    ( $line->{itemtype} ? ", " . $line->{itemtype} : '' ) .
                    ( $line->{edition} ? ", " . $line->{edition} : '' ) .
                    ( $line->{publishercode} ? ' published by '. $line->{publishercode} : '') .
                    ( $line->{publicationyear} ? ', '. $line->{publicationyear} : '');
            }
            else { # MARC21, NORMARC
                $titleinfo =  $line->{title} . " " . $line->{author} .
                    ( $line->{isbn} ? " ISBN: " . $line->{isbn} : '' ) .
                    ( $line->{en} ? " EN: " . $line->{en} : '' ) .
                    ( $line->{itemtype} ? " " . $line->{itemtype} : '' ) .
                    ( $line->{edition} ? ", " . $line->{edition} : '' ) .
                    ( $line->{publishercode} ? ' published by '. $line->{publishercode} : '') .
                    ( $line->{copyrightdate} ? ' '. $line->{copyrightdate} : '');
            }
            push( @$arrbasket,
                $titleinfo. ($line->{order_vendornote} ? "\n----------------\nNote for vendor : " . $line->{order_vendornote} : '' ),
                $line->{quantity},
                Koha::Number::Price->new( $line->{rrpgste} )->format,
                Koha::Number::Price->new( $line->{rrpgsti} )->format,
                Koha::Number::Price->new( $line->{discount} )->format . '%',
                Koha::Number::Price->new( $line->{rrpgste} - $line->{ecostgste})->format,
                Koha::Number::Price->new( $line->{gstrate} * 100 )->format . '%',
                Koha::Number::Price->new( $line->{totalgste} )->format,
                Koha::Number::Price->new( $line->{totalgsti} )->format,
            );
            push(@$abaskets, $arrbasket);
        }

        $pdftable->table($pdf, $page, $abaskets,
                                        x => 10/mm,
                                        w => ($width - 20)/mm,
                                        start_y => 270/mm,
                                        next_y  => 285/mm,
                                        start_h => 250/mm,
                                        next_h  => 250/mm,
                                        padding => 5,
                                        padding_right => 5,
                                        background_color_odd  => "lightgray",
                                        font       => $pdf->corefont("Times", -encoding => "utf8"),
                                        font_size => 3/mm,
                                        header_props   =>    {
                                            font       => $pdf->corefont("Times", -encoding => "utf8"),
                                            font_size  => 9,
                                            bg_color   => 'gray',
                                            repeat     => 1,
                                        },
                                        column_props => [
                                            {
                                                min_w => 85/mm,       # Minimum column width.
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                            {
                                                justify => 'right', # One of left|right ,
                                            },
                                        ],
             );
    }
    $pdf->mediabox($width/mm, $height/mm);
}

sub printbaskets {
    my ($pdf, $basketgroup, $hbaskets, $bookseller, $GSTrate, $orders) = @_;
    
    # get library name
    my $libraryname = C4::Context->preference("LibraryName");
    
    my $cur_format = C4::Context->preference("CurrencyFormat");

    $pdf->mediabox($width/mm, $height/mm);
    my $page = $pdf->openpage(2);
    # create a text
    my $text = $page->text;
    
    # add basketgroup number
    $text->font( $pdf->corefont("Times", -encoding => "utf8"), 6/mm );
    $text->translate(($width-40)/mm,  ($height-53)/mm);
    $text->text("".$basketgroup->{'id'});
    # print the libraryname in the header
    $text->font( $pdf->corefont("Times", -encoding => "utf8"), 6/mm );
    $text->translate(30/mm,  ($height-28.5)/mm);
    $text->text($libraryname);
    my $pdftable = new PDF::Table();
    my $abaskets;
    my $arrbasket;
    # header of the table
    my @keys = ('Lot',  'Basket (No.)','Total RRP tax exc.', 'Total RRP tax inc.', 'GST rate', 'GST', 'Total discount', 'Total tax exc.', 'Total tax inc.');
    for my $bkey (@keys) {
        push(@$arrbasket, $bkey);
    }
    my ($grandtotalrrpgsti, $grandtotalrrpgste, $grandtotalgsti, $grandtotalgste, $grandtotalgstvalue, $grandtotaldiscount);
    # calculate each basket total
    push(@$abaskets, $arrbasket);
    for my $basket (@$hbaskets) {
        my @gst;
        $arrbasket = undef;
        my ($totalrrpgste, $totalrrpgsti, $totalgste, $totalgsti, $totalgstvalue, $totaldiscount);
        my $ords = $orders->{$basket->{basketno}};
        my $ordlength = @$ords;
        foreach my $ord (@$ords) {
            $totalgste += $ord->{totalgste};
            $totalgsti += $ord->{totalgsti};
            $totalgstvalue += $ord->{gstvalue};
            $totaldiscount += ($ord->{rrpgste} - $ord->{ecostgste} ) * $ord->{quantity};
            $totalrrpgste += $ord->{rrpgste} * $ord->{quantity};
            $totalrrpgsti += $ord->{rrpgsti} * $ord->{quantity};
            push @gst, $ord->{gstrate};
        }
        @gst = uniq map { $_ * 100 } @gst;
        $grandtotalrrpgste += $totalrrpgste;
        $grandtotalrrpgsti += $totalrrpgsti;
        $grandtotalgsti += $totalgsti;
        $grandtotalgste += $totalgste;
        $grandtotalgstvalue += $totalgstvalue;
        $grandtotaldiscount += $totaldiscount;
        my @gst_string =
          map { Koha::Number::Price->new($_)->format . '%' } @gst;
        push(@$arrbasket,
            $basket->{contractname},
            $basket->{basketname} . ' (No. ' . $basket->{basketno} . ')',
            Koha::Number::Price->new( $totalrrpgste )->format,
            Koha::Number::Price->new( $totalrrpgsti )->format,
            "@gst_string",
            Koha::Number::Price->new( $totalgstvalue )->format,
            Koha::Number::Price->new( $totaldiscount )->format,
            Koha::Number::Price->new( $totalgste )->format,
            Koha::Number::Price->new( $totalgsti )->format,
        );
        push(@$abaskets, $arrbasket);
    }
    # now, push total
    undef $arrbasket;
    push @$arrbasket,
      '',
      'Total',
      Koha::Number::Price->new( $grandtotalrrpgste )->format,
      Koha::Number::Price->new( $grandtotalrrpgsti )->format,
      '',
      Koha::Number::Price->new( $grandtotalgstvalue )->format,
      Koha::Number::Price->new( $grandtotaldiscount )->format,
      Koha::Number::Price->new( $grandtotalgste )->format,
      Koha::Number::Price->new( $grandtotalgsti )->format;
    push @$abaskets,$arrbasket;
    # height is width and width is height in this function, as the pdf is in landscape mode for the Tables.

    $pdftable->table($pdf, $page, $abaskets,
                                    x => 5/mm,
                                    w => ($width - 10)/mm,
                                    start_y =>  230/mm,
                                    next_y  => 230/mm,
                                    start_h => 230/mm,
                                    next_h  => 230/mm,
                                    font       => $pdf->corefont("Times", -encoding => "utf8"),
                                    font_size => 3/mm,
                                    padding => 5,
                                    padding_right => 10,
                                    background_color_odd  => "lightgray",
                                    header_props   =>    {
                                        bg_color   => 'gray',
                                        repeat     => 1,
                                    },
                                    column_props => [
                                        {
                                        },
                                        {
                                        },
                                        {
                                            justify => 'right',
                                        },
                                        {
                                            justify => 'right',
                                        },
                                        {
                                            justify => 'right',
                                        },
                                        {
                                            justify => 'right',
                                        },
                                        {
                                            justify => 'right',
                                        },
                                    ],
    );
    $pdf->mediabox($height/mm, $width/mm);
}

sub printhead {
    my ($pdf, $basketgroup, $bookseller) = @_;

    # get library name
    my $libraryname = C4::Context->preference("LibraryName");
    # get branch details
    my $billingdetails  = GetBranchDetail( $basketgroup->{billingplace} );
    my $deliverydetails = GetBranchDetail( $basketgroup->{deliveryplace} );
    my $freedeliveryplace = $basketgroup->{freedeliveryplace};
    # get the subject
    my $subject;

    # open 1st page (with the header)
    my $page = $pdf->openpage(1);
    
    # create a text
    my $text = $page->text;
    
    # print the libraryname in the header
    $text->font( $pdf->corefont("Times", -encoding => "utf8"), 6/mm );
    $text->translate(30/mm,  ($height-28.5)/mm);
    $text->text($libraryname);

    # print order info, on the default PDF
    $text->font( $pdf->corefont("Times", -encoding => "utf8"), 8/mm );
    $text->translate(100/mm,  ($height-5-48)/mm);
    $text->text($basketgroup->{'id'});
    
    # print the date
    my $today = C4::Dates->today();
    $text->translate(130/mm,  ($height-5-48)/mm);
    $text->text($today);
    
    $text->font( $pdf->corefont("Times", -encoding => "utf8"), 4/mm );
    
    # print billing infos
    $text->translate(100/mm,  ($height-86)/mm);
    $text->text($libraryname);
    $text->translate(100/mm,  ($height-97)/mm);
    $text->text($billingdetails->{branchname});
    $text->translate(100/mm,  ($height-108.5)/mm);
    $text->text($billingdetails->{branchphone});
    $text->translate(100/mm,  ($height-115.5)/mm);
    $text->text($billingdetails->{branchfax});
    $text->translate(100/mm,  ($height-122.5)/mm);
    $text->text($billingdetails->{branchaddress1});
    $text->translate(100/mm,  ($height-127.5)/mm);
    $text->text($billingdetails->{branchaddress2});
    $text->translate(100/mm,  ($height-132.5)/mm);
    $text->text($billingdetails->{branchaddress3});
    $text->translate(100/mm,  ($height-137.5)/mm);
    $text->text(join(' ', $billingdetails->{branchzip}, $billingdetails->{branchcity}, $billingdetails->{branchcountry}));
    $text->translate(100/mm,  ($height-147.5)/mm);
    $text->text($billingdetails->{branchemail});
    
    # print subject
    $text->translate(100/mm,  ($height-145.5)/mm);
    $text->text($subject);
    
    # print bookseller infos
    $text->translate(100/mm,  ($height-180)/mm);
    $text->text($bookseller->{name});
    $text->translate(100/mm,  ($height-185)/mm);
    $text->text($bookseller->{postal});
    $text->translate(100/mm,  ($height-190)/mm);
    $text->text($bookseller->{address1});
    $text->translate(100/mm,  ($height-195)/mm);
    $text->text($bookseller->{address2});
    $text->translate(100/mm,  ($height-200)/mm);
    $text->text($bookseller->{address3});
    $text->translate(100/mm, ($height-205)/mm);
    $text->text($bookseller->{accountnumber});
    
    # print delivery infos
    $text->font( $pdf->corefont("Times-Bold", -encoding => "utf8"), 4/mm );
    $text->translate(50/mm,  ($height-237)/mm);
    if ($freedeliveryplace) {
        my $start = 242;
        my @fdp = split('\n', $freedeliveryplace);
        foreach (@fdp) {
            $text->text($_);
            $text->translate( 50 / mm, ( $height - $start ) / mm );
            $start += 5;
        }
    } else {
        $text->text($deliverydetails->{branchaddress1});
        $text->translate(50/mm,  ($height-242)/mm);
        $text->text($deliverydetails->{branchaddress2});
        $text->translate(50/mm,  ($height-247)/mm);
        $text->text($deliverydetails->{branchaddress3});
        $text->translate(50/mm,  ($height-252)/mm);
        $text->text(join(' ', $deliverydetails->{branchzip}, $deliverydetails->{branchcity}, $deliverydetails->{branchcountry}));
    }
    $text->translate(50/mm,  ($height-262)/mm);
    $text->text($basketgroup->{deliverycomment});
}

sub printfooters {
        my ($pdf) = @_;
        for (my $i=1;$i <= $pdf->pages;$i++) {
        my $page = $pdf->openpage($i);
        my $text = $page->text;
        $text->font( $pdf->corefont("Times", -encoding => "utf8"), 3/mm );
        $text->translate(10/mm,  10/mm);
        $text->text("Page $i / ".$pdf->pages);
        }
}

sub printpdf {
    my ($basketgroup, $bookseller, $baskets, $orders, $GST) = @_;
    # open the default PDF that will be used for base (1st page already filled)
    my $pdf_template = C4::Context->config('intrahtdocs') . '/' . C4::Context->preference('template') . '/pdf/layout3pages.pdf';
    my $pdf = PDF::API2->open($pdf_template);
    $pdf->pageLabel( 0, {
        -style => 'roman',
    } ); # start with roman numbering
    # fill the 1st page (basketgroup information)
    printhead($pdf, $basketgroup, $bookseller);
    # fill the 2nd page (orders summary)
    printbaskets($pdf, $basketgroup, $baskets, $bookseller, $GST, $orders);
    # fill other pages (orders)
    printorders($pdf, $basketgroup, $baskets, $orders);
    # print something on each page (usually the footer, but you could also put a header
    printfooters($pdf);
    return $pdf->stringify;
}

1;
