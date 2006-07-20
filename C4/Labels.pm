package C4::Labels;

# Copyright 2006 Katipo Communications.
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

use strict;
require Exporter;

use vars qw($VERSION @ISA @EXPORT);
#use Data::Dumper;
use PDF::Reuse;


$VERSION = 0.01;

=head1 NAME

C4::Labels - Functions for printing spine labels and barcodes in Koha

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
  	&get_label_options &get_label_items
  	&build_circ_barcode &draw_boundaries
	&draw_box
);

=item get_label_options;

	$options = get_label_options()


Return a pointer on a hash list containing info from labels_conf table in Koha DB.

=cut
#'
sub get_label_options {
    my $dbh    = C4::Context->dbh;
    my $query2 = " SELECT * FROM labels_conf LIMIT 1 ";
    my $sth    = $dbh->prepare($query2);
    $sth->execute();
    my $conf_data = $sth->fetchrow_hashref;
    $sth->finish;
    return $conf_data;
}

=item get_label_items;

        $options = get_label_items()


Returns an array of references-to-hash, whos keys are the field from the biblio, biblioitems, items and labels tables in the Koha database.

=cut
#'
sub get_label_items {
    my $dbh = C4::Context->dbh;

    # get the actual items to be printed.
    my @data;
    my $query3 = " Select * from labels ";
    my $sth    = $dbh->prepare($query3);
    $sth->execute();
    my @resultsloop;
    my $cnt = $sth->rows;
    my $i1  = 1;
    while ( my $data = $sth->fetchrow_hashref ) {

        # lets get some summary info from each item
        my $query1 =
          " select * from biblio, biblioitems, items where itemnumber = ? and
                                items.biblioitemnumber=biblioitems.biblioitemnumber and
                                biblioitems.biblionumber=biblio.biblionumber";

        my $sth1 = $dbh->prepare($query1);
        $sth1->execute( $data->{'itemnumber'} );
        my $data1 = $sth1->fetchrow_hashref();

        push( @resultsloop, $data1 );
        $sth1->finish;

        $i1++;
    }
    $sth->finish;
    return @resultsloop;
}

=item build_circ_barcode;

  build_circ_barcode( $x_pos, $y_pos, $barcode,
	        $barcodetype, \$item);

$item is the result of a previous call to get_label_items();

=cut
#'
sub build_circ_barcode {
    my ( $x_pos_circ, $y_pos, $value, $barcodetype, $item ) = @_;

#warn Dumper \$item;

    #warn "value = $value\n";

    #$DB::single = 1;

    if ( $barcodetype eq 'EAN13' ) {

        #testing EAN13 barcodes hack
        $value = $value . '000000000';
        $value =~ s/-//;
        $value = substr( $value, 0, 12 );

        #warn $value;
        eval {
            PDF::Reuse::Barcode::EAN13(
                x     => ( $x_pos_circ + 27 ),
                y     => ( $y_pos + 15 ),
                value => $value,

                #            prolong => 2.96,
                #            xSize   => 1.5,

                # ySize   => 1.2,

# added for xpdf compat. doesnt use type3 fonts., but increases filesize from 20k to 200k
# i think its embedding extra fonts in the pdf file.
#  mode => 'graphic',
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "EAN13BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }
    elsif ( $barcodetype eq 'Code39' ) {

        eval {
            PDF::Reuse::Barcode::Code39(
                x     => ( $x_pos_circ + 9 ),
                y     => ( $y_pos + 15 ),
                value => $value,

                #           prolong => 2.96,
                xSize => .85,

                ySize => 1.3,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "CODE39BARCODE $value FAILED:$@";
        }

        #warn $barcodetype;

    }

    elsif ( $barcodetype eq 'Matrix2of5' ) {

        #warn "MATRIX ELSE:";

        #testing MATRIX25  barcodes hack
        #    $value = $value.'000000000';
        $value =~ s/-//;

        #    $value = substr( $value, 0, 12 );
        #warn $value;

        eval {
            PDF::Reuse::Barcode::Matrix2of5(
                x     => ( $x_pos_circ + 27 ),
                y     => ( $y_pos + 15 ),
                value => $value,

                #        prolong => 2.96,
                #       xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }

    elsif ( $barcodetype eq 'EAN8' ) {

        #testing ean8 barcodes hack
        $value = $value . '000000000';
        $value =~ s/-//;
        $value = substr( $value, 0, 8 );

        #warn $value;

        #warn "EAN8 ELSEIF";
        eval {
            PDF::Reuse::Barcode::EAN8(
                x       => ( $x_pos_circ + 42 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }

    elsif ( $barcodetype eq 'UPC-E' ) {
        eval {
            PDF::Reuse::Barcode::UPCE(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }
    elsif ( $barcodetype eq 'NW7' ) {
        eval {
            PDF::Reuse::Barcode::NW7(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }
    elsif ( $barcodetype eq 'ITF' ) {
        eval {
            PDF::Reuse::Barcode::ITF(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };

        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }
    elsif ( $barcodetype eq 'Industrial2of5' ) {
        eval {
            PDF::Reuse::Barcode::Industrial2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }
    elsif ( $barcodetype eq 'IATA2of5' ) {
        eval {
            PDF::Reuse::Barcode::IATA2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }

    elsif ( $barcodetype eq 'COOP2of5' ) {
        eval {
            PDF::Reuse::Barcode::COOP2of5(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }
    elsif ( $barcodetype eq 'UPC-A' ) {

        eval {
            PDF::Reuse::Barcode::UPCA(
                x       => ( $x_pos_circ + 27 ),
                y       => ( $y_pos + 15 ),
                value   => $value,
                prolong => 2.96,
                xSize   => 1.5,

                # ySize   => 1.2,
            );
        };
        if ($@) {
            $item->{'barcodeerror'} = 1;
            #warn "BARCODE FAILED:$@";
        }

        #warn $barcodetype;

    }

}

=item draw_boundaries

 sub draw_boundaries ($x_pos_spine, $x_pos_circ1, $x_pos_circ2,
                $y_pos, $spine_width, $label_height, $circ_width)  

This sub draws boundary lines where the label outlines are, to aid in printer testing, and debugging.

=cut

#'
sub draw_boundaries {

	my ($x_pos_spine, $x_pos_circ1, $x_pos_circ2, 
		$y_pos, $spine_width, $label_height, $circ_width) = @_;

    my $y_pos_initial = ( ( 792 - 36 ) - 90 );
    my $y_pos         = $y_pos_initial;
    my $i             = 1;

    for ( $i = 1 ; $i <= 8 ; $i++ ) {

        &drawbox( $x_pos_spine, $y_pos, ($spine_width), ($label_height) );

   #warn "OLD BOXES  x=$x_pos_spine, y=$y_pos, w=$spine_width, h=$label_height";
        &drawbox( $x_pos_circ1, $y_pos, ($circ_width), ($label_height) );
        &drawbox( $x_pos_circ2, $y_pos, ($circ_width), ($label_height) );

        $y_pos = ( $y_pos - $label_height );

    }
}

=item drawbox

	sub drawbox { 	$lower_left_x, $lower_left_y, 
			$upper_right_x, $upper_right_y )

this is a low level sub, that draws a pdf box, it is called by draw_boxes

=cut

#'
sub drawbox {
    my ( $llx, $lly, $urx, $ury ) = @_;

    my $str = "q\n";    # save the graphic state
    $str .= "1.0 0.0 0.0  RG\n";           # border color red
    $str .= "1 1 1  rg\n";                 # fill color blue
    $str .= "$llx $lly $urx $ury re\n";    # a rectangle
    $str .= "B\n";                         # fill (and a little more)
    $str .= "Q\n";                         # save the graphic state

    prAdd($str);

}

END { }    # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Mason James <mason@katipo.co.nz>
=cut

