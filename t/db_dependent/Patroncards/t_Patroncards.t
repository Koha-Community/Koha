#!/usr/bin/perl
#
# Copyright 2009 Foundations Bible College.
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

## NOTE: This is really broken at this point and needs updating... -chris_n

use strict;
use warnings;

#use Test::More;
use Graphics::Magick;
use XML::Simple;
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Context;
use autouse 'C4::Members' => qw(GetPatronImage);
use C4::Creators::PDF 1.000000;
use C4::Patroncards::Patroncard 1.000000;

#BEGIN {
#    use_ok('C4::Patroncards::Patroncard');
#}

my $borrower_number = 3;
my $pdf = C4::Creators::PDF->new(InitVars => 0);

#   All units are in PostScript points in this script
$pdf->Mbox(0, 0, 612, 792);

# Convert layout to XML and insert into db
#my $query = "INSERT INTO creator_layouts (layout_id,layout_xml) VALUES (1,?) ON DUPLICATE KEY UPDATE layout_xml=?;";
#my $sth = C4::Context->dbh->prepare($query);
my $layout =
{
        barcode                 => {
                                    type => 'CODE39',
                                    llx => 26,
                                    lly => 4.5,
                                    data => '0002120108',
                                    text => 1,  # controls text_under_barcode display: 1 => visible, 0 => not visible
        },
        text                    => [
                                    'John Doe' => {
                                                                font => 'TB',
                                                                font_size => 13,
                                                                llx => 63,      # llx & lly are relative to the llx & lly of the card NOT the page
                                                                lly => 103.5,
                                                                alignment => 'C',
                                    },
                                    'Anytown Public Library' => {
                                                                font => 'TR',
                                                                font_size => 8,
                                                                llx => 63,
                                                                lly => 85.5,
                                                                alignment => 'C',
                                    },
                                    'Line 3 Text' => {
                                                                font => 'TB',
                                                                font_size => 10,
                                                                llx => 63,
                                                                lly => 76.5,
                                                                alignment => 'C',
                                    },
        ],
        images                  => {
                                    patron_image   => {
                                                            data_source => {'db' => 'patronimages',
                                                                            'card_number' => '0002120108',
                                                            },
                                                            Sx          => 0,
                                                            Sy          => 0,
                                                            Ox          => 0,   # Ox,Oy should be set to 0 unless you want special effects  see http://www.adobe.com/devnet/pdf/pdf_reference.html ISO 32000-1
                                                            Oy          => 0,
                                                            Tx          => 4.5,  # Lower left corner of image relative to the lower left corner of the card
                                                            Ty          => 63,
                                                            Dx          => 72,  # point height of display image
                                    },
                                    image_1        => {
                                                            data_source => {'db' => 'pcards_images',
                                                                            'image_id' => 1,
                                                            },
                                                            Sx          => 0,
                                                            Sy          => 0,
                                                            Ox          => 0,   # Ox,Oy should be set to 0 unless you want special effects  see http://www.adobe.com/devnet/pdf/pdf_reference.html ISO 32000-1
                                                            Oy          => 0,
                                                            Tx          => 100,  # Lower left corner of image
                                                            Ty          => 50,
                                                            Dx          => 81,
                                    },
        },
};

#$sth->execute(XMLout($layout),XMLout($layout));

# Retrieve XML from database
my$query = "SELECT layout_xml FROM creator_layouts WHERE layout_id=20;";
my $xml = C4::Context->dbh->selectrow_array($query);

# Convert back to hash
$layout = XMLin($xml);

# Do image foo and place binary image data into layout hash
my $image_data = {};
my $alt_image_data = {};
my $error = undef;
foreach (keys %{$layout->{'images'}}) {
    warn "Processing key: $_\n";
    if (grep{m/db/} keys(%{$layout->{'images'}->{$_}->{'data_source'}})) {
        warn $layout->{'images'}->{$_}->{'data_source'}->{'db'};
        if ($layout->{'images'}->{$_}->{'data_source'}->{'db'} eq 'patronimages') {
            warn "Processing patron image data.\n";
            ($image_data, $error) = GetPatronImage($layout->{'images'}->{$_}->{'data_source'}->{'card_number'});
            warn sprintf('No image exists for borrower number %s.', $borrower_number) if !$image_data;
            next if !$image_data;
        }
        elsif ($layout->{'images'}->{$_}->{'data_source'}->{'db'} eq 'pcards_images') {
            warn "Processing pcards image data for image_id " . $$layout{'images'}{$_}{'data_source'}{'image_id'} . ".\n";
            my $dbh = C4::Context->dbh();
            $dbh->{LongReadLen} = 1000000;      # allows us to read approx 1MB
            $image_data = $dbh->selectrow_hashref("SELECT imagefile FROM pcards_images WHERE image_id = \'$$layout{'images'}{$_}{'data_source'}{'image_id'}\'");
            warn sprintf('Image does not exists in db table %s.', $$layout{'images'}{$_}{'data_source'}{'db'}) if !$image_data;
            next if !$image_data;
        #    $string =~ s/(.)/sprintf("%x",ord($1))/eg;
        }
        else {
            warn sprintf('No retrieval method for table %s.', $$layout{'images'}{$_}{'data_source'}{'db'}) if !$image_data;
        }
        warn sprintf('Database returned the following error: %s.', $error) if $error;
    }
    elsif (grep{m/foo/} keys(%{$layout->{'images'}->{$_}->{'data_source'}})) {
        # some other image storage/retrieval method
    }

my $binary_data = $image_data->{'imagefile'};
my $image = Graphics::Magick->new;
$image->BlobToImage($binary_data);
my $alt_image = Graphics::Magick->new;
$alt_image->BlobToImage($binary_data);
$alt_image->Set(magick => 'jpg', quality => 100);

warn "Print Image Dimensions: " . $image->Get('width') . " X " . $image->Get('height') . "\n";

my $alt_width = $image->Get('width');
my $alt_height = $image->Get('height');
my $ratio = $alt_width / $alt_height;
my $display_height = $layout->{'images'}->{$_}->{'Dx'};
my $display_width = $ratio * $display_height;
$image->Resize(width => $display_width, height => $display_height);
$image->Set(magick => 'jpg', quality => 100);

warn "Display Image dimensions: " . $image->Get('width') . " X " . $image->Get('height') . "\n";

#    Write params for alt image...
    $layout->{'images'}->{$_}->{'alt'}->{'Sx'} = $alt_width;
    $layout->{'images'}->{$_}->{'alt'}->{'Sy'} = $alt_height;
    $layout->{'images'}->{$_}->{'alt'}->{'data'} = $alt_image->ImageToBlob();
##    Write params for display image...
    $layout->{'images'}->{$_}->{'Sx'} = $display_width;
    $layout->{'images'}->{$_}->{'Sy'} = $display_height;
    $layout->{'images'}->{$_}->{'data'} = $image->ImageToBlob();
}
die "BREAKPOINT...";
# Create a new patroncard object
my $patron_card = C4::Patroncards::Patroncard->new(
        batch_id                => 1,
        borrower_number         => $borrower_number,
        llx                     => 36,#13.5        # lower left corner of the card
        lly                     => 639,
        height                  => 139.5,       # of the card
        width                   => 229.5,
        layout                  => $layout,
        text_wrap_cols          => 30,
);
$patron_card->draw_guide_box($pdf);
$patron_card->draw_barcode($pdf);
my $err = $patron_card->draw_image($pdf);
$patron_card->draw_text($pdf);
$pdf->End;
exit(1);
