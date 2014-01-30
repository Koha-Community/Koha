#!/usr/bin/perl
#
# Copyright 2006 Katipo Communications.
# Parts Copyright 2009 Foundations Bible College.
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

package C4::Labels::OplibLabels;

use Modern::Perl;
use utf8;

use POSIX;

use C4::OPLIB::Labels;
use C4::Labels::OplibSheets::Sheet_6x1_1_2;
use C4::Biblio;
use C4::Items;
use C4::Context;

my $labelPdfDirectory = '/tmp/';

## Create a tricky label
sub populateAndCreateLabelSheets {
    my ($barcodes, $margins) = @_;
    my $labelsData; #Used to collect all the information needed to create a print label for a item. Empty elements denote a skipped sticker in a sheet.
    my $labelsMap = C4::OPLIB::Labels::getShelvingLabelsMap(); #Different label generation rules based on the homebranch and shelving location and itype and ccode.
    #Can be called like this: $labelsMap->{JOE_YMY}->{Kuvakirjat}->{''}->{''} to get the shortname 'LIYL' which is printed to a label;

    my $fileName = 'printLabel'.strftime('%Y%m%d%H%M%S',localtime).'.pdf';
    my $filePathAndName = $labelPdfDirectory.$fileName;

    ##Fetch the required data from our DB
    my $dbh = C4::Context->dbh;

    my $sql = "
    SELECT branches.branchcode AS homebranch, branchname, permanent_location, location,
           authorised_values.lib AS location_name, barcode, author, title, itemtypes.description AS itemtype,
           itemcallnumber, biblio.copyrightdate, items.ccode
    FROM items
    LEFT JOIN biblioitems USING ( biblioitemnumber )
    LEFT JOIN biblio ON (items.biblionumber = biblio.biblionumber)
    LEFT JOIN itemtypes ON (items.itype = itemtypes.itemtype)
    LEFT JOIN branches ON (branches.branchcode = items.homebranch)
    LEFT JOIN authorised_values ON (items.location = authorised_values.authorised_value)
    WHERE barcode = ? AND category = 'LOC'";

    my $sth = $dbh->prepare($sql);

    my $badBarcodeErrors; #Collect errors into this array.
    foreach(@$barcodes) {
        my $bc = $_;
        $bc =~ s/^\s*//; #Trim barcode for whitespace.
        $bc =~ s/\s*$//; #Otherwise very fucking hard to debug!?!!?!?!?

        if (defined $bc && length $bc > 1) {
            $sth->execute($bc);
            my $labelData = $sth->fetchrow_hashref();

            #Get the MARC::Record easily the Koha-way!
            my $itemnumber = C4::Items::GetItemnumberFromBarcode($bc);
            my $biblionumber = C4::Biblio::GetBiblionumberFromItemnumber($itemnumber);
            my $record = C4::Biblio::GetMarcBiblio($biblionumber);

            ##Check if we really have the needed data elements!
            if ($labelData && $record) {

                #Build the content_description out of $300a,e
                $labelData->{content_description} = '';
                if (my $f300 = $record->field('300')) {

                    my @sfA = $f300->subfield('a');
                    my $sfE = $f300->subfield('e');

                    if (@sfA) {
                        $labelData->{content_description} .= "@sfA";
                    }
                    if (@sfA && $sfE) {
                        $labelData->{content_description} .= ' ';
                    }
                    if ($sfE) {
                        $labelData->{content_description} .= $sfE;
                    }
                }

                #Get the correct sticker label based on the item's homebranch, location, itype and ccode
                $labelData->{location_code} = C4::OPLIB::Labels::getLabelFromMap( $labelsMap, $labelData->{homebranch}, $labelData->{permanent_location}, $labelData->{itype}, $labelData->{ccode} )  if $labelData->{permanent_location};
                $labelData->{location_code} = C4::OPLIB::Labels::getLabelFromMap( $labelsMap, $labelData->{homebranch}, $labelData->{location}, $labelData->{itype}, $labelData->{ccode} ) if !$labelData->{permanent_location};

                #Making sure that some kind of author is defined!
                if ((! defined($labelData->{author}))) {
                    if (my $f110 = $record->field('110')) {
                        my $sfA = $f110->subfield('a');
                        $labelData->{author} = $sfA;
                    }
                    elsif (my $f111 = $record->field('111')) {
                        my $sfA = $f111->subfield('a');
                        $labelData->{author} = $sfA;
                    }
                }

                #Making sure that some kind of title is defined!
                #if ((! defined($labelData->{title}))) {
                    if (my $f245 = $record->field('245')) {
                        my $sfA = $f245->subfield('a');
                        my $sfB = $f245->subfield('b');
                        my $sfN = $f245->subfield('n');
                        my $sfP = $f245->subfield('p');

                        $labelData->{title} = '';
                        $labelData->{title} .= $sfA if $sfA;
                        $labelData->{title} .= $sfB if $sfB;
                        $labelData->{title} .= $sfN if $sfN;
                        $labelData->{title} .= $sfP if $sfP;
                        $labelData->{title} = 'no subfields in $245' unless $labelData->{title};
                    }

                    elsif (my $f111 = $record->field('111')) {
                        my $sfA = $f111->subfield('a');
                        $labelData->{title} = $sfA;
                    }
                    elsif (my $f130 = $record->field('130')) {
                        my $sfA = $f130->subfield('a');
                        $labelData->{title} = $sfA;
                    }
                #}


                push @$labelsData, $labelData; #Push this item even if it might have errors. Errors become easily visible!
            }
            else {
                ##Error messages are better relayed to the UI rather than the web server log :)
                #warn "C4::Labels::OplibLabels> Given barcode '$bc' is not in use";
                push @$badBarcodeErrors, $bc;
            }


        }
        else {
            push @$labelsData, undef; #Push also empty results so we can skip label stickers when needed.
        }
    }

    C4::Labels::OplibSheets::Sheet_6x1_1_2::create($labelsData, $filePathAndName, $margins, 0);

    return ($labelPdfDirectory, $fileName, $badBarcodeErrors);
}

sub getSignum {
    my $record = shift; #A
    #Get the proper SIGNUM (important) Use one of the Main Entries or the Title Statement
    my $signumSource; #One of fields 100, 110, 111, 130, or 245 if 1XX is missing
    if (($signumSource = $record->subfield('100', 'a')) ||
        ($signumSource = $record->subfield('110', 'a')) ||
        ($signumSource = $record->subfield('111', 'a')) ||
        ($signumSource = $record->subfield('130', 'a')) ||
        ($signumSource = $record->subfield('245', 'a')) ) {
        return substr $signumSource, 0, 3;
    }
    return undef;
}
