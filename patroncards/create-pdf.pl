#!/usr/bin/perl
#
# Copyright 2009 Foundations Bible College.
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

use strict;
use warnings;

use CGI;
use C4::Auth;
use Graphics::Magick;
use XML::Simple;
use POSIX qw(ceil);
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Debug;
use C4::Context;
use autouse 'C4::Members' => qw(GetPatronImage GetMember);
use C4::Creators;
use C4::Patroncards;

my $cgi = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
                                                                     template_name   => "labels/label-home.tt",
                                                                     query           => $cgi,
                                                                     type            => "intranet",
                                                                     authnotrequired => 0,
                                                                     flagsrequired   => { tools => 'label_creator' },
                                                                     debug           => 1,
                                                                     });


my $batch_id    = $cgi->param('batch_id') if $cgi->param('batch_id');
my $template_id = $cgi->param('template_id') || undef;
my $layout_id   = $cgi->param('layout_id') || undef;
my $start_label = $cgi->param('start_label') || 1;
my @label_ids   = $cgi->param('label_id') if $cgi->param('label_id');
my @borrower_numbers  = $cgi->param('borrower_number') if $cgi->param('borrower_number');

my $items = undef; # items = cards
my $new_page = 0;

my $pdf_file = (@label_ids || @borrower_numbers ? "card_single_" . scalar(@label_ids || @borrower_numbers) : "card_batch_$batch_id");
print $cgi->header( -type       => 'application/pdf',
                    -encoding   => 'utf-8',
                    -attachment => "$pdf_file.pdf",
                  );

my $pdf = C4::Creators::PDF->new(InitVars => 0);
my $batch = C4::Patroncards::Batch->retrieve(batch_id => $batch_id);
my $template = C4::Patroncards::Template->retrieve(template_id => $template_id, profile_id => 1);
my $layout = C4::Patroncards::Layout->retrieve(layout_id => $layout_id);

$| = 1;

# set the paper size
my $lower_left_x  = 0;
my $lower_left_y  = 0;
my $upper_right_x = $template->get_attr('page_width');
my $upper_right_y = $template->get_attr('page_height');

$pdf->Compress(1); # comment this out to debug pdf files, but be sure to uncomment it in production or you may be very sorry...
$pdf->Mbox($lower_left_x, $lower_left_y, $upper_right_x, $upper_right_y);

my ($llx, $lly) = 0,0;
(undef, undef, $llx, $lly) = $template->get_label_position($start_label);

if (@label_ids) {
    my $batch_items = $batch->get_attr('items');
    grep {
        my $label_id = $_;
        push(@{$items}, grep{$_->{'label_id'} == $label_id;} @{$batch_items});
    } @label_ids;
}
elsif (@borrower_numbers) {
    grep {
        push(@{$items}, {item_number => $_});
    } @borrower_numbers;
}
else {
    $items = $batch->get_attr('items');
}

my $layout_xml = XMLin($layout->get_attr('layout_xml'), ForceArray => 1);

if ($layout_xml->{'page_side'} eq 'B') { # rearrange items on backside of page to swap columns
    my $even = 1;
    my $odd = 0;
    my @swap_array = ();
    while ($even <= (scalar(@{$items})+1)) {
        push (@swap_array, @{$items}[$even]);
        push (@swap_array, @{$items}[$odd]);
        $even += 2;
        $odd += 2;
    }
    @{$items} = @swap_array;
}

CARD_ITEMS:
foreach my $item (@{$items}) {
    if ($item) {
        my $borrower_number = $item->{'borrower_number'};
        my $card_number = GetMember(borrowernumber => $borrower_number)->{'cardnumber'};

#       Set barcode data
        $layout_xml->{'barcode'}->[0]->{'data'} = $card_number if $layout_xml->{'barcode'};

#       Create a new patroncard object
        my $patron_card = C4::Patroncards::Patroncard->new(
                batch_id                => 1,
                borrower_number         => $borrower_number,
                llx                     => $llx, # lower left corner of the card
                lly                     => $lly,
                height                  => $template->get_attr('label_height'), # of the card
                width                   => $template->get_attr('label_width'),
                layout                  => $layout_xml,
                text_wrap_cols          => 30, #FIXME: hardcoded
        );
        $patron_card->draw_guide_box($pdf) if $layout_xml->{'guide_box'};
        $patron_card->draw_barcode($pdf) if $layout_xml->{'barcode'};

#       Do image foo and place binary image data into layout hash
        my $image_data = {};
        my $error = undef;
        my $images = $layout_xml->{'images'};
        PROCESS_IMAGES:
        foreach (keys %{$images}) {
            if (grep{m/source/} keys(%{$images->{$_}->{'data_source'}->[0]})) {
                if ($images->{$_}->{'data_source'}->[0]->{'image_source'} eq 'none') {
                    next PROCESS_IMAGES;
                }
                elsif ($images->{$_}->{'data_source'}->[0]->{'image_source'} eq 'patronimages') {
                    ($image_data, $error) = GetPatronImage($borrower_number);
                    warn sprintf('No image exists for borrower number %s.', $borrower_number) if !$image_data;
                    next PROCESS_IMAGES if !$image_data;
                }
                elsif ($images->{$_}->{'data_source'}->[0]->{'image_source'} eq 'creator_images') {
                    my $dbh = C4::Context->dbh();
                    $dbh->{LongReadLen} = 1000000;      # allows us to read approx 1MB
                    $image_data = $dbh->selectrow_hashref("SELECT imagefile FROM creator_images WHERE image_name = \'$images->{$_}->{'data_source'}->[0]->{'image_name'}\'");
                    warn sprintf('Database returned the following error: %s.', $error) if $error;
                    warn sprintf('Image does not exists in db table %s.', $images->{$_}->{'data_source'}->[0]->{'image_name'}) if !$image_data;
                    next PROCESS_IMAGES if !$image_data;
                }
                else {
                    warn sprintf('No retrieval method for image source %s.', $images->{$_}->{'data_source'}->[0]->{'image_source'});
                    next PROCESS_IMAGES;
                }
            }
            else {
                warn sprintf("Unrecognized image data source: %s", $images->{$_}->{'data_source'});
                next PROCESS_IMAGES;
            }

        my $binary_data = $image_data->{'imagefile'};

#       invoke the display image object...
        my $image = Graphics::Magick->new;
        $image->BlobToImage($binary_data);

#       invoke the alt (aka print) image object...
        my $alt_image = Graphics::Magick->new;
        $alt_image->BlobToImage($binary_data);
        $alt_image->Set(magick => 'jpg', quality => 100);

        my $alt_width = ceil($image->Get('width')); # the rounding up is important: Adobe reader does not handle long decimal numbers well
        my $alt_height = ceil($image->Get('height'));
        my $ratio = $alt_width / $alt_height;
        my $display_height = ceil($images->{$_}->{'Dx'});
        my $display_width = ceil($ratio * $display_height);


        $image->Resize(width => $display_width, height => $display_height);
        $image->Set(magick => 'jpg', quality => 100);

#       Write params for alt image...
            $images->{$_}->{'alt'}->{'Sx'} = $alt_width;
            $images->{$_}->{'alt'}->{'Sy'} = $alt_height;
            $images->{$_}->{'alt'}->{'data'} = $alt_image->ImageToBlob();

#       Write params for display image...
            $images->{$_}->{'Sx'} = $display_width;
            $images->{$_}->{'Sy'} = $display_height;
            $images->{$_}->{'data'} = $image->ImageToBlob();

            my $err = $patron_card->draw_image($pdf);
            warn sprintf ("Error encountered while attempting to draw image %s, %s", $_, $err) if $err;
        }
        $patron_card->draw_text($pdf);
    }
    ($llx, $lly, $new_page) = $template->get_next_label_pos();
    $pdf->Page() if $new_page;
}

$pdf->End();

# FIXME: Possibly do a redirect here if there were error encountered during PDF creation.

1;
