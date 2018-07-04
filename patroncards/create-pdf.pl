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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use Graphics::Magick;
use XML::Simple;
use POSIX qw(ceil);
use Storable qw(dclone);
use autouse 'Data::Dumper' => qw(Dumper);

use C4::Debug;
use C4::Context;
use C4::Creators;
use C4::Patroncards;
use Koha::List::Patron;
use Koha::Patrons;
use Koha::Patron::Images;

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
my $layout_back_id   = $cgi->param('layout_back_id') || undef;
my $start_card = $cgi->param('start_card') || 1;
my @label_ids   = $cgi->multi_param('label_id') if $cgi->param('label_id');
my @borrower_numbers  = $cgi->multi_param('borrower_number') if $cgi->param('borrower_number');
my $patronlist_id = $cgi->param('patronlist_id');

my $items = undef; # items = cards
my $new_page = 0;

# Wrap pdf creation part into an eval, some vars need scope outside eval
my $pdf_ok;
my $pdf;
my $pdf_file;
my $cardscount = 0;

#Note fo bug 14138: Indenting follows in separate patch to ease review
eval {
$pdf_file = (@label_ids || @borrower_numbers ? "card_single_" . scalar(@label_ids || @borrower_numbers) : "card_batch_$batch_id");

$pdf = C4::Creators::PDF->new(InitVars => 0);
my $batch = C4::Patroncards::Batch->retrieve(batch_id => $batch_id);
my $pc_template = C4::Patroncards::Template->retrieve(template_id => $template_id, profile_id => 1);
my $layout = C4::Patroncards::Layout->retrieve(layout_id => $layout_id);
my $layout_back = C4::Patroncards::Layout->retrieve(layout_id => $layout_back_id) if ( $layout_back_id );

$| = 1;

# set the paper size
my $lower_left_x  = 0;
my $lower_left_y  = 0;
my $upper_right_x = $pc_template->get_attr('page_width');
my $upper_right_y = $pc_template->get_attr('page_height');

$pdf->Compress(1); # comment this out to debug pdf files, but be sure to uncomment it in production or you may be very sorry...
$pdf->Mbox($lower_left_x, $lower_left_y, $upper_right_x, $upper_right_y);

my ($llx, $lly) = 0,0;
(undef, undef, $llx, $lly) = $pc_template->get_label_position($start_card);

if (@label_ids) {
    my $batch_items = $batch->get_attr('items');
    grep {
        my $label_id = $_;
        push(@{$items}, grep{$_->{'label_id'} == $label_id;} @{$batch_items});
    } @label_ids;
}
elsif (@borrower_numbers) {
    grep {
        push(@{$items}, {borrower_number => $_});
    } @borrower_numbers;
}
elsif ( $patronlist_id  ) {
    my ($list) = GetPatronLists( { patron_list_id => $patronlist_id } );
    my @borrowerlist = $list->patron_list_patrons()->search_related('borrowernumber')
    ->get_column('borrowernumber')->all();
    grep {
        push(@{$items}, {borrower_number => $_});
    } @borrowerlist;
}
else {
    $items = $batch->get_attr('items');
}

my $layout_xml = XMLin($layout->get_attr('layout_xml'), ForceArray => 1);
my $layout_back_xml = XMLin($layout_back->get_attr('layout_xml'), ForceArray => 1) if ( defined $layout_back );

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

# WARNING: Referential nightmare ahead...

CARD_ITEMS:
foreach my $item (@{$items}) {
    if ($item) {
        my $print_layout_xml = (( ($cardscount % 2  == 1) && ( $layout_back_id ) ) ?
            dclone($layout_back_xml) : dclone($layout_xml) );   # We must have a true copy of the layout xml hash, otherwise
                                                                # we modify the original template and very bad things happen.

        $cardscount ++;
        my $borrower_number = $item->{'borrower_number'};
        my $card_number = Koha::Patrons->find( $borrower_number)->cardnumber;

#       Set barcode data
        $print_layout_xml->{'barcode'}->[0]->{'data'} = $card_number if $print_layout_xml->{'barcode'};

#       Create a new patroncard object
        my $patron_card = C4::Patroncards::Patroncard->new(
                batch_id                => 1,
                borrower_number         => $borrower_number,
                llx                     => $llx, # lower left corner of the card
                lly                     => $lly,
                height                  => $pc_template->get_attr('label_height'), # of the card
                width                   => $pc_template->get_attr('label_width'),
                layout                  => $print_layout_xml,
                text_wrap_cols          => 30, #FIXME: hardcoded,
        );

        $patron_card->draw_guide_box($pdf) if $print_layout_xml->{'guide_box'};
        $patron_card->draw_guide_grid($pdf) if $print_layout_xml->{'guide_grid'};
        $patron_card->draw_barcode($pdf) if $print_layout_xml->{'barcode'};

#       Do image foo and place binary image data into layout hash
        my $image_data = {};
        my $error = undef;
        my $images = $print_layout_xml->{'images'};
        PROCESS_IMAGES:
        foreach my $card_image (sort(keys %{$images})) {
            if (grep{m/(source)/} keys(%{$images->{$card_image}->{'data_source'}->[0]})) {
                if ($images->{$card_image}->{'data_source'}->[0]->{'image_source'} eq 'none') {
                }
                elsif ($images->{$card_image}->{'data_source'}->[0]->{'image_source'} eq 'patronimages') {
                    my $patron_image = Koha::Patron::Images->find($borrower_number);
                    if ($patron_image) {
                        $image_data->{'imagefile'} = $patron_image->imagefile;
                    }
                    else {
                        warn sprintf('No image exists for borrower number %s.', $borrower_number);
                    }
                }
                elsif ($images->{$card_image}->{'data_source'}->[0]->{'image_source'} eq 'creator_images') {
                    ## FIXME: The DB stuff here needs to be religated to a Koha::Creator::Images object -chris_n
                    my $dbh = C4::Context->dbh();
                    $dbh->{LongReadLen} = 1000000;      # allows us to read approx 1MB
                    $image_data = $dbh->selectrow_hashref("SELECT imagefile FROM creator_images WHERE image_name = \'$images->{$card_image}->{'data_source'}->[0]->{'image_name'}\'");
                    warn sprintf('Database returned the following error: %s.', $error) if $error;
                    unless($image_data){
                        warn sprintf('Image does not exists in db table %s.', $images->{$card_image}->{'data_source'}->[0]->{'image_name'});
                    }
                }
                else {
                    warn sprintf('No retrieval method for image source %s.', $images->{$card_image}->{'data_source'}->[0]->{'image_source'});
                }
            }
            else {
                warn sprintf("Unrecognized image data source: %s", $images->{$card_image}->{'data_source'});
            }

        my $binary_data = $image_data->{'imagefile'} || next PROCESS_IMAGES;

#       invoke the display image object...
        my $image = Graphics::Magick->new;
        $image->BlobToImage($binary_data);

#       invoke the alt (aka print) image object...
        my $alt_image = Graphics::Magick->new;
        $alt_image->BlobToImage($binary_data);
        $alt_image->Set(magick => 'jpg', quality => 100);

        #To avoid pixelation have the image 5 times bigger and
        #scale it down in PDF itself
        my $oversize_factor = 8;
        my $pdf_scale_factor = 1 / $oversize_factor;

        my $alt_width = ceil($image->Get('width')); # the rounding up is important: Adobe reader does not handle long decimal numbers well
        my $alt_height = ceil($image->Get('height'));
        my $ratio = $alt_width / $alt_height;
        my $display_height = ceil($images->{$card_image}->{'Dx'});
        my $display_width = ceil($ratio * $display_height);


        $image->Resize(width => $oversize_factor * $display_width, height => $oversize_factor * $display_height);
        $image->Set(magick => 'jpg', quality => 100);

#       Write param for downsizing in pdf
            $images->{$card_image}->{'scale'} = $pdf_scale_factor;

#       Write params for alt image...
            $images->{$card_image}->{'alt'}->{'Sx'} = $oversize_factor * $alt_width;
            $images->{$card_image}->{'alt'}->{'Sy'} = $oversize_factor * $alt_height;
            $images->{$card_image}->{'alt'}->{'data'} = $alt_image->ImageToBlob();

#       Write params for display image...
            $images->{$card_image}->{'Sx'} = $oversize_factor * $display_width;
            $images->{$card_image}->{'Sy'} = $oversize_factor * $display_height;
            $images->{$card_image}->{'data'} = $image->ImageToBlob();

            my $err = $patron_card->draw_image($pdf);
            warn sprintf ("Error encountered while attempting to draw image %s, %s", $card_image, $err) if $err;
            # Destroy all Graphics::Magick objects and related references
            # or bad things will happen.
            undef $image;
            undef $alt_image;
            undef $binary_data;
        }
        $patron_card->draw_text($pdf);
    }
    ($llx, $lly, $new_page) = $pc_template->get_next_label_pos();

    if ( ($cardscount % 2  == 1) && ( $layout_back_id ) ) {
        $pdf->Page();
        redo; # Use same patron data again for backside in card printer
    }

    $pdf->Page() if $new_page;
}
# No errors occurred within eval, we can issue the pdf
$pdf_ok = 1 if ($cardscount > 0);
}; # end of eval block

if ($pdf_ok) {
    #issue the pdf
    print $cgi->header( -type       => 'application/pdf',
                    -encoding   => 'utf-8',
                    -attachment => "$pdf_file.pdf",
                  );
    $pdf->End();
}
else {
    # warn user that pdf is not created
    my $errparams = '&pdferr=1';
    $errparams .= "&errba=$batch_id" if $batch_id;
    $errparams .= "&errpl=$patronlist_id" if $patronlist_id;
    $errparams =  $errparams.'&errpt='.$cgi->param('borrower_number') if $cgi->param('borrower_number');
    $errparams .= "&errlo=$layout_id" if $layout_id;
    $errparams .= "&errtpl=$template_id" if $template_id;
    $errparams .= "&errnocards=1" if !$cardscount;

    print $cgi->redirect("/cgi-bin/koha/patroncards/manage.pl?card_element=batch$errparams");
}

1;
