package Koha::pdfformat::layout1page;

# Copyright 2022 Catalyst IT <aleisha@catalyst.net.nz>
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
use vars qw(@ISA @EXPORT);
use Modern::Perl;
use utf8;

use Koha::Number::Price;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Libraries;

BEGIN {
    use Exporter   ();
    our (@ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);
    @ISA    = qw(Exporter);
    @EXPORT = qw(printpdf);
}


#be careful, all the sizes (height, width, etc...) are in mm, not PostScript points (the default measurement of PDF::API2).
#The constants exported transform that into PostScript points (/mm for millimeter, /in for inch, pt is postscript point, and as so is there only to show what is happening.
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
    my $page = $pdf->openpage(1);

    my $pdftable = PDF::Table->new();

    my $abaskets;
    my $arrbasket;
    my @keys = ('Qty', 'Document', 'RRP tax inc.', 'Discount', 'Tax', 'Total tax exc.', 'Total tax inc.');
    for my $bkey (@keys) {
        push(@$arrbasket, $bkey);
    }
    push(@$abaskets, $arrbasket);

    my $titleinfo;
    for my $basket (@$baskets){
        for my $line (@{$orders->{$basket->{basketno}}}) {
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
            else { # MARC21
                $titleinfo =  $line->{title} . " " . $line->{author} .
                    ( $line->{isbn} ? " ISBN: " . $line->{isbn} : '' ) .
                    ( $line->{en} ? " EN: " . $line->{en} : '' ) .
                    ( $line->{itemtype} ? " " . $line->{itemtype} : '' ) .
                    ( $line->{edition} ? ", " . $line->{edition} : '' ) .
                    ( $line->{publishercode} ? ' published by '. $line->{publishercode} : '') .
                    ( $line->{copyrightdate} ? ' '. $line->{copyrightdate} : '');
            }
            push( @$arrbasket,
                $line->{quantity},
                $titleinfo. ($line->{order_vendornote} ? "\n----------------\nNote for vendor: " . $line->{order_vendornote} : '' ),
                Koha::Number::Price->new( $line->{rrp_tax_included} )->format,
                Koha::Number::Price->new( $line->{discount} )->format . '%',
                Koha::Number::Price->new( $line->{tax_rate} * 100 )->format . '%',
                Koha::Number::Price->new( $line->{total_tax_excluded} )->format,
                Koha::Number::Price->new( $line->{total_tax_included} )->format,
            );
            push(@$abaskets, $arrbasket);
        }
    }

    $pdftable->table($pdf, $page, $abaskets,
        x => 10/mm,
        w => ($width - 20)/mm,
        start_y => 170/mm,
        next_y  => 280/mm,
        start_h => 150/mm,
        next_h  => 260/mm,
        padding => 5,
        padding_right => 5,
        background_color_odd  => "lightgray",
        font       => $pdf->corefont("Times", -encoding => "utf8"),
        font_size => 3/mm,
        header_props   => {
            font       => $pdf->corefont("Times", -encoding => "utf8"),
            font_size  => 10,
            bg_color   => 'gray',
            repeat     => 1,
        },
        column_props => [
            { justify => 'left'  },
            { min_w   => 90/mm   },
            { justify => 'right' },
            { justify => 'right' },
            { justify => 'right' },
            { justify => 'right' },
            { justify => 'right' },
            { justify => 'right' },
        ],
    );

    $pdf->mediabox($width/mm, $height/mm);
}

sub printhead {
    my ($pdf, $basketgroup, $bookseller) = @_;

    # get library name
    my $libraryname = C4::Context->preference("LibraryName");
    my $billing_library  = Koha::Libraries->find( $basketgroup->{billingplace} );
    my $delivery_library = Koha::Libraries->find( $basketgroup->{deliveryplace} );
    my $freedeliveryplace = $basketgroup->{freedeliveryplace};

    # open 1st page (with the header)
    my $page = $pdf->openpage(1);

    # create a text
    my $text = $page->text;
    $text->font( $pdf->corefont("Times", -encoding => "utf8"), 4/mm );

    # print order info, on the default PDF
    $text->translate(42/mm, ($height-62)/mm);
    $text->text($basketgroup->{'id'});

    # print the date
    my $today = output_pref({ dt => dt_from_string, dateonly => 1 });
    $text->translate(41/mm, ($height-67)/mm);
    $text->text($today);

    # print billing infos
    $text->font( $pdf->corefont("Times-Bold", -encoding => "utf8"), 4/mm );
    $text->translate(107/mm, ($height-67)/mm);
    $text->text($libraryname);

    $text->font( $pdf->corefont("Times", -encoding => "utf8"), 4/mm );
    $text->translate(107/mm, ($height-71)/mm);
    $text->text($billing_library->branchname);
    $text->translate(116/mm, ($height-97)/mm);
    $text->text($billing_library->branchphone);
    $text->translate(155/mm, ($height-97)/mm);
    $text->text($billing_library->branchfax);

    # print bookseller infos
    $text->translate(20/mm, ($height-33)/mm);
    $text->text($bookseller->name);
    $text->translate(20/mm, ($height-37)/mm);
    if ( $bookseller->postal ) {
        my $start = 41;
        my @postal = split('\n', $bookseller->postal);
        foreach (@postal) {
            $text->text($_);
            $text->translate( 20 / mm, ( $height - $start ) / mm );
            $start += 4;
        }
    }
    $text->translate(20/mm, ($height-57)/mm);
    $text->text($bookseller->accountnumber);

    # print delivery infos
    $text->translate(107/mm, ($height-75)/mm);
    if ($freedeliveryplace) {
        my $start = 79;
        my @fdp = split('\n', $freedeliveryplace);
        foreach (@fdp) {
            $text->text($_);
            $text->translate( 107 / mm, ( $height - $start ) / mm );
            $start += 4;
        }
    } else {
        $text->text( $delivery_library->branchaddress1 );
        $text->translate( 107 / mm, ( $height - 75 ) / mm );
        $text->text( $delivery_library->branchaddress2 );
        $text->translate( 107 / mm, ( $height - 79 ) / mm );
        $text->text( $delivery_library->branchaddress3 );
        $text->translate( 107 / mm, ( $height - 83 ) / mm );
        $text->text( join( ' ', $delivery_library->branchcity, $delivery_library->branchzip, $delivery_library->branchcountry ) );
    }
    $text->translate( 20 / mm, ( $height - 120 ) / mm );
    $text->text($basketgroup->{deliverycomment});
}

sub printfooters {
    my $pdf = shift;
    for ( 1..$pdf->pages ) {
        my $page = $pdf->openpage($_);
        my $text = $page->text;
        $text->font( $pdf->corefont("Times", -encoding => "utf8"), 3/mm );
        $text->translate(10/mm,  10/mm);
        $text->text("Page $_ / ".$pdf->pages);
    }
}

sub printpdf {
    my ($basketgroup, $bookseller, $baskets, $orders, $GST) = @_;
    # open the default PDF that will be used for base (1st page already filled)
    my $pdf_template = C4::Context->config('intrahtdocs') . '/' . C4::Context->preference('template') . '/pdf/layout1page.pdf';
    my $pdf = PDF::API2->open($pdf_template);
    $pdf->pageLabel( 0, {
        -style => 'roman',
    } ); # start with roman numbering
    # fill the 1st page (basketgroup information)
    printhead($pdf, $basketgroup, $bookseller);
    # fill other pages (orders)
    printorders($pdf, $basketgroup, $baskets, $orders);
    # print something on each page (usually the footer, but you could also put a header
    printfooters($pdf);
    return $pdf->stringify;
}

1;
