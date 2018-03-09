package C4::KohaSuomi::SendAcquisitionByXML;

# Copyright 2015 Koha Suomi
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
use Carp;
use C4::Context;
use C4::Debug;
use Koha::DateUtils;
use MARC::Record;
use Koha::Libraries;
use C4::Biblio;
use Koha::Acquisition::Bookseller;
use C4::Acquisition qw/GetOrders GetBasketsByBasketgroup GetBasketgroup GetBasket ModBasketgroup /;
use XML::Simple;
use XML::Writer;
use IO::File;
use Data::Dumper;
use C4::KohaSuomi::AcquisitionIntegration;

use Time::localtime;
use Time::Local;
use HTML::Entities;

use Encode;

=head3 sendBasketGroupAsXML

=over

&sendBasketGroupAsXML($basketgroupid);

Export a basket group as XML

$cgi parameter is needed for column name translation

=back

=cut


sub sendBasketGroupAsXml{
    my $basketgroupid = shift;
    my $filename = 'tilaus' . $basketgroupid . '.xml';
    my $baskets = GetBasketsByBasketgroup($basketgroupid);
    my $basketgroup = GetBasketgroup( $basketgroupid );
    my $bookseller = Koha::Acquisition::Booksellers->find($basketgroup->{booksellerid});

    my $output = new IO::File(">/tmp/".$filename);
    my $writer = new XML::Writer(OUTPUT => $output);

    my $branch = Koha::Libraries->find($basketgroup->{billingplace});

    my $cover = $bookseller->{contnotes} eq 'no_cover' ? 'n' : 'y';

    $writer->xmlDecl( 'UTF-8' );

    $writer->startTag('customer', 'name' => $branch->branchname, 'nr' => $bookseller->accountnumber);

    #Stuff starts here
    for my $basket (@$baskets) {
        my @orders     = GetOrders( $$basket{basketno} );

        foreach my $order (@orders) {
            my $bd = GetBiblioData( $order->{'biblionumber'} );
            my $marcxml = $bd->{marcxml};
            my $allfons = getField($marcxml, '001');

            my $field971 = getField($marcxml, '971');
            my $tnumber = getSubfield($field971, 'b');
            my $preorderdate = getSubfield($field971, 'c');
            my $isbn = $bd->{isbn};
            my $issn = $bd->{issn};
            my $field024 = getField($marcxml, '024');
            my $ean = getSubfield($field024, 'a');
            $ean =~ s/\D//g;
            $isbn =~ s/\D//g;
            my $year = substr($preorderdate, 0, 4);
            my $month = substr($preorderdate, 4, 2);
            my $day = substr($preorderdate, 6, 2);
            my $timestamp;
            if($year && $month && $day) {
                $timestamp = timelocal('59', '59', '23', $day, $month-1, $year);
            }
            my $sf972a = getSubfield(getField($marcxml, '972'), 'a');

            if(length $allfons > 10 && $sf972a){
                $allfons = $sf972a;
                $allfons =~ s/\D//g;
            }
            if ($timestamp > time && $field971 && $allfons) {
                warn "Allfons: $allfons\n";
                $writer->startTag('t-number', 'nr' => $tnumber);
                    $writer->startTag('order', 'artno' => $allfons,
                                      'no-of-items' => $order->{quantity}, 'record' => 'y', 'bind-code' => $cover);
                    $writer->endTag();
                $writer->endTag();
            }#If order type is not addition
            else{
                warn "ISBN: $isbn\n";
                warn "EAN: $ean\n";
                $writer->startTag('addition-order', 'no-of-items' => $order->{quantity}, 'record' => 'y', 'bind-code' => $cover);
                    $writer->startTag('author');
                        $writer->characters('<![CDATA['.encode('utf8', $bd->{author}).']]>');
                    $writer->endTag();
                    $writer->startTag('title');
                        $writer->characters('<![CDATA['.encode('utf8', $bd->{title}).']]>');
                    $writer->endTag();
                    $writer->startTag('isbn');
                        if($ean){
                            $writer->characters($ean);
                        }else{
                            $writer->characters($isbn);
                        }
                    $writer->endTag();
                    $writer->startTag('issn');
                        $writer->characters($issn);
                    $writer->endTag();
                $writer->endTag();
            }
         }#Foreach order ends here
    }#For baskets ends here
    #Stuff ends here
    $writer->endTag();
    $writer->end();

    my $msg = MIME::Lite->new(
        From    => $branch->branchemail,
        To      => 'edi-tilaukset@btj.fi',
        Subject => 'tilaus',
        Data => 'Tilaustiedot',
        Type    => 'multipart/mixed'
    );

    $msg->attach(
        Type     => 'text/xml',
        Filename => $filename,
        Path => '/tmp/'.$filename,
        Disposition => 'attachment'
    );

    $msg->send;
    C4::KohaSuomi::AcquisitionIntegration::markBasketgroupAsOrdered($basketgroup);
    return 0;
}

sub getField {
    my ($marcxml, $tag) = @_;

    if ($marcxml =~ /^\s{2}<(data|control)field tag="$tag".*?>(.*?)<\/(data|control)field>$/sm) {
        return $2;
    }
    return 0;
}

sub getSubfield {
    my ($fieldxml, $subfield) = @_;

    if ($fieldxml =~ /^\s{4}<subfield code="$subfield">(.*?)<\/subfield>$/sm) {
        return $1;
    }
    return 0;
}


return 1;