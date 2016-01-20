package Koha::Edifact::Line;

# Copyright 2014, 2015 PTFS-Europe Ltd
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
use utf8;

use MARC::Record;
use MARC::Field;
use Carp;

sub new {
    my ( $class, $data_array_ref ) = @_;
    my $self = _parse_lines($data_array_ref);

    bless $self, $class;
    return $self;
}

# helper routine used by constructor
# creates the hashref used as a data structure by the Line object

sub _parse_lines {
    my $aref = shift;

    my $lin = shift @{$aref};

    my $id     = $lin->elem( 2, 0 );    # may be undef in ordrsp
    my $action = $lin->elem( 1, 0 );
    my $d      = {
        line_item_number       => $lin->elem(0),
        action_notification    => $action,
        item_number_id         => $id,
        additional_product_ids => [],
    };
    my @item_description;

    foreach my $s ( @{$aref} ) {
        if ( $s->tag eq 'PIA' ) {
            push @{ $d->{additional_product_ids} },
              {
                function_code => $s->elem(0),
                item_number   => $s->elem( 1, 0 ),
                number_type   => $s->elem( 1, 1 ),
              };
        }
        elsif ( $s->tag eq 'IMD' ) {
            push @item_description, $s;
        }
        elsif ( $s->tag eq 'QTY' ) {
            $d->{quantity} = $s->elem( 0, 1 );
        }
        elsif ( $s->tag eq 'DTM' ) {
            if ( $s->elem( 0, 0 ) eq '44' ) {
                $d->{availability_date} = $s->elem( 0, 1 );
            }
        }
        elsif ( $s->tag eq 'GIR' ) {

            # we may get a Gir for each copy if QTY > 1
            if ( !$d->{GIR} ) {
                $d->{GIR} = [];
                push @{ $d->{GIR} }, extract_gir($s);
            }
            else {
                my $gir = extract_gir($s);
                if ( $gir->{copy} ) {    # may have to merge
                    foreach my $g ( @{ $d->{GIR} } ) {
                        if ( $gir->{copy} eq $g->{copy} ) {
                            foreach my $field ( keys %{$gir} ) {
                                if ( !exists $g->{$field} ) {
                                    $g->{$field} = $gir->{$field};
                                }
                            }
                            undef $gir;
                            last;
                        }
                    }
                    if ( defined $gir ) {
                        push @{ $d->{GIR} }, $gir;
                    }
                }
            }
        }
        elsif ( $s->tag eq 'FTX' ) {

            my $type  = $s->elem(0);
            my $ctype = 'coded_free_text';
            if ( $type eq 'LNO' ) {    # Ingrams Oasis Internal Notes field
                $type  = 'internal_notes';
                $ctype = 'coded_internal_note';
            }
            elsif ( $type eq 'LIN' ) {
                $type  = 'orderline_free_text';
                $ctype = 'coded_orderline_text';
            }
            elsif ( $type eq 'SUB' ) {
                $type = 'coded_substitute_text';
            }
            else {
                $type = 'free_text';
            }

            my $coded_text = $s->elem(2);
            if ( ref $coded_text eq 'ARRAY' && $coded_text->[0] ) {
                $d->{$ctype}->{table} = $coded_text->[1];
                $d->{$ctype}->{code}  = $coded_text->[0];
            }

            my $ftx = $s->elem(3);
            if ( ref $ftx eq 'ARRAY' ) {   # it comes in 70 character components
                $ftx = join q{ }, @{$ftx};
            }
            if ( exists $d->{$type} ) {    # we can only catenate repeats
                $d->{$type} .= q{ };
                $d->{$type} .= $ftx;
            }
            else {
                $d->{$type} = $ftx;
            }
        }
        elsif ( $s->tag eq 'MOA' ) {

            $d->{monetary_amount} = $s->elem( 0, 1 );
        }
        elsif ( $s->tag eq 'PRI' ) {

            $d->{price} = $s->elem( 0, 1 );
        }
        elsif ( $s->tag eq 'RFF' ) {
            my $qualifier = $s->elem( 0, 0 );
            if ( $qualifier eq 'QLI' ) {  # Suppliers unique quotation reference
                $d->{reference} = $s->elem( 0, 1 );
            }
            elsif ( $qualifier eq 'LI' ) {    # Buyer's unique orderline number
                $d->{ordernumber} = $s->elem( 0, 1 );
            }
            elsif ( $qualifier eq 'SLI' )
            {    # Suppliers unique order line reference number
                $d->{orderline_reference_number} = $s->elem( 0, 1 );
            }
        }
    }
    $d->{item_description} = _format_item_description(@item_description);
    $d->{segs}             = $aref;

    return $d;
}

sub _format_item_description {
    my @imd    = @_;
    my $bibrec = {};

 # IMD : +Type code 'L' + characteristic code 3 char + Description in comp 3 & 4
    foreach my $imd (@imd) {
        my $type_code = $imd->elem(0);
        my $ccode     = $imd->elem(1);
        my $desc      = $imd->elem( 2, 3 );
        if ( $imd->elem( 2, 4 ) ) {
            $desc .= $imd->elem( 2, 4 );
        }
        if ( $type_code ne 'L' ) {
            carp
              "Only handles text item descriptions at present: code=$type_code";
            next;
        }
        if ( exists $bibrec->{$ccode} ) {
            $bibrec->{$ccode} .= q{ };
            $bibrec->{$ccode} .= $desc;
        }
        else {
            $bibrec->{$ccode} = $desc;
        }
    }
    return $bibrec;
}

sub marc_record {
    my $self = shift;
    my $b    = $self->{item_description};

    my $bib = MARC::Record->new();

    my @spec;
    my @fields;
    if ( exists $b->{'010'} ) {
        @spec = qw( 100 a 011 c 012 b 013 d 014 e );
        push @fields, new_field( $b, [ 100, 1, q{ } ], @spec );
    }
    if ( exists $b->{'020'} ) {
        @spec = qw( 020 a 021 c 022 b 023 d 024 e );
        push @fields, new_field( $b, [ 700, 1, q{ } ], @spec );
    }

    # corp conf
    if ( exists $b->{'030'} ) {
        push @fields, $self->corpcon(1);
    }
    if ( exists $b->{'040'} ) {
        push @fields, $self->corpcon(7);
    }
    if ( exists $b->{'050'} ) {
        @spec = qw( '050' a '060' b '065' c );
        push @fields, new_field( $b, [ 245, 1, 0 ], @spec );
    }
    if ( exists $b->{100} ) {
        @spec = qw( 100 a 101 b);
        push @fields, new_field( $b, [ 250, q{ }, q{ } ], @spec );
    }
    @spec = qw( 110 a 120 b 170 c );
    my $f = new_field( $b, [ 260, q{ }, q{ } ], @spec );
    if ($f) {
        push @fields, $f;
    }
    @spec = qw( 180 a 181 b 182 c 183 e);
    $f = new_field( $b, [ 300, q{ }, q{ } ], @spec );
    if ($f) {
        push @fields, $f;
    }
    if ( exists $b->{190} ) {
        @spec = qw( 190 a);
        push @fields, new_field( $b, [ 490, q{ }, q{ } ], @spec );
    }

    if ( exists $b->{200} ) {
        @spec = qw( 200 a);
        push @fields, new_field( $b, [ 490, q{ }, q{ } ], @spec );
    }
    if ( exists $b->{210} ) {
        @spec = qw( 210 a);
        push @fields, new_field( $b, [ 490, q{ }, q{ } ], @spec );
    }
    if ( exists $b->{300} ) {
        @spec = qw( 300 a);
        push @fields, new_field( $b, [ 500, q{ }, q{ } ], @spec );
    }
    if ( exists $b->{310} ) {
        @spec = qw( 310 a);
        push @fields, new_field( $b, [ 520, q{ }, q{ } ], @spec );
    }
    if ( exists $b->{320} ) {
        @spec = qw( 320 a);
        push @fields, new_field( $b, [ 521, q{ }, q{ } ], @spec );
    }
    if ( exists $b->{260} ) {
        @spec = qw( 260 a);
        push @fields, new_field( $b, [ 600, q{ }, q{ } ], @spec );
    }
    if ( exists $b->{270} ) {
        @spec = qw( 270 a);
        push @fields, new_field( $b, [ 650, q{ }, q{ } ], @spec );
    }
    if ( exists $b->{280} ) {
        @spec = qw( 280 a);
        push @fields, new_field( $b, [ 655, q{ }, q{ } ], @spec );
    }

    # class
    if ( exists $b->{230} ) {
        @spec = qw( 230 a);
        push @fields, new_field( $b, [ '082', q{ }, q{ } ], @spec );
    }
    if ( exists $b->{240} ) {
        @spec = qw( 240 a);
        push @fields, new_field( $b, [ '084', q{ }, q{ } ], @spec );
    }
    $bib->insert_fields_ordered(@fields);

    return $bib;
}

sub corpcon {
    my ( $self, $level ) = @_;
    my $test_these = {
        1 => [ '033', '032', '034' ],
        7 => [ '043', '042', '044' ],
    };
    my $conf = 0;
    foreach my $t ( @{ $test_these->{$level} } ) {
        if ( exists $self->{item_description}->{$t} ) {
            $conf = 1;
        }
    }
    my $tag;
    my @spec;
    my ( $i1, $i2 ) = ( q{ }, q{ } );
    if ($conf) {
        $tag = ( $level * 100 ) + 11;
        if ( $level == 1 ) {
            @spec = qw( 030 a 031 e 032 n 033 c 034 d);
        }
        else {
            @spec = qw( 040 a 041 e 042 n 043 c 044 d);
        }
    }
    else {
        $tag = ( $level * 100 ) + 10;
        if ( $level == 1 ) {
            @spec = qw( 030 a 031 b);
        }
        else {
            @spec = qw( 040 a 041 b);
        }
    }
    return new_field( $self->{item_description}, [ $tag, $i1, $i2 ], @spec );
}

sub new_field {
    my ( $b, $tag_ind, @sfd_elem ) = @_;
    my @sfd;
    while (@sfd_elem) {
        my $e = shift @sfd_elem;
        my $c = shift @sfd_elem;
        if ( exists $b->{$e} ) {
            push @sfd, $c, $b->{$e};
        }
    }
    if (@sfd) {
        my $field = MARC::Field->new( @{$tag_ind}, @sfd );
        return $field;
    }
    return;
}

# Accessor methods to line data

sub item_number_id {
    my $self = shift;
    return $self->{item_number_id};
}

sub line_item_number {
    my $self = shift;
    return $self->{line_item_number};
}

sub additional_product_ids {
    my $self = shift;
    return $self->{additional_product_ids};
}

sub action_notification {
    my $self = shift;
    my $a    = $self->{action_notification};
    if ($a) {
        $a = _translate_action($a);    # return the associated text string
    }
    return $a;
}

sub item_description {
    my $self = shift;
    return $self->{item_description};
}

sub monetary_amount {
    my $self = shift;
    return $self->{monetary_amount};
}

sub quantity {
    my $self = shift;
    return $self->{quantity};
}

sub price {
    my $self = shift;
    return $self->{price};
}

sub reference {
    my $self = shift;
    return $self->{reference};
}

sub orderline_reference_number {
    my $self = shift;
    return $self->{orderline_reference_number};
}

sub ordernumber {
    my $self = shift;
    return $self->{ordernumber};
}

sub free_text {
    my $self = shift;
    return $self->{free_text};
}

sub coded_free_text {
    my $self = shift;
    return $self->{coded_free_text}->{code};
}

sub internal_notes {
    my $self = shift;
    return $self->{internal_notes};
}

sub coded_internal_note {
    my $self = shift;
    return $self->{coded_internal_note}->{code};
}

sub orderline_free_text {
    my $self = shift;
    return $self->{orderline_free_text};
}

sub coded_orderline_text {
    my $self  = shift;
    my $code  = $self->{coded_orderline_text}->{code};
    my $table = $self->{coded_orderline_text}->{table};
    my $txt;
    if ( $table eq '8B' || $table eq '7B' ) {
        $txt = translate_8B($code);
    }
    elsif ( $table eq '12B' ) {
        $txt = translate_12B($code);
    }
    if ( !$txt || $txt eq 'no match' ) {
        $txt = $code;
    }
    return $txt;
}

sub substitute_free_text {
    my $self = shift;
    return $self->{substitute_free_text};
}

sub coded_substitute_text {
    my $self = shift;
    return $self->{coded_substitute_text}->{code};
}

# This will take a standard code as returned
# by (orderline|substitue)-free_text (FTX seg LIN)
# and expand it useing EditEUR code list 8B
sub translate_8B {
    my ($code) = @_;

    # list 7B is a subset of this
    my %code_list_8B = (
        AB => 'Publication abandoned',
        AD => 'Apply direct',
        AU => 'Publisher address unknown',
        CS => 'Status uncertain',
        FQ => 'Only available abroad',
        HK => 'Paperback OP: Hardback available',
        IB => 'In stock',
        IP => 'In print and in stock at publisher',
        MD => 'Manufactured on demand',
        NK => 'Item not known',
        NN => 'We do not supply this item',
        NP => 'Not yet published',
        NQ => 'Not stocked',
        NS => 'Not sold separately',
        OB => 'Temporarily out of stock',
        OF => 'This format out of print: other format available',
        OP => 'Out of print',
        OR => 'Out pf print; New Edition coming',
        PK => 'Hardback out of print: paperback available',
        PN => 'Publisher no longer in business',
        RE => 'Awaiting reissue',
        RF => 'refer to other publisher or distributor',
        RM => 'Remaindered',
        RP => 'Reprinting',
        RR => 'Rights restricted: cannot supply in this market',
        SD => 'Sold',
        SN => 'Our supplier cannot trace',
        SO => 'Pack or set not available: single items only',
        ST => 'Stocktaking: temporarily unavailable',
        TO => 'Only to order',
        TU => 'Temporarily unavailable',
        UB => 'Item unobtainable from our suppliers',
        UC => 'Unavailable@ reprint under consideration',
    );

    if ( exists $code_list_8B{$code} ) {
        return $code_list_8B{$code};
    }
    else {
        return 'no match';
    }
}

sub translate_12B {
    my ($code) = @_;

    my %code_list_12B = (
        100 => 'Order line accepted',
        101 => 'Price query: orderline will be held awaiting customer response',
        102 =>
          'Discount query: order line will be held awaiting customer response',
        103 => 'Minimum order value not reached: order line will be held',
        104 =>
'Firm order required: order line will be held awaiting customer response',
        110 => 'Order line accepted, substitute product will be supplied',
        200 => 'Order line not accepted',
        201 => 'Price query: order line not accepted',
        202 => 'Discount query: order line not accepted',
        203 => 'Minimum order value not reached: order line not accepted',
        205 => 'Order line not accepted: quoted promotion is invalid',
        206 => 'Order line not accepted: quoted promotion has ended',
        207 =>
          'Order line not accepted: customer ineligible for quoted promotion',
        210 => 'Order line not accepted: substitute product is offered',
        220 => 'Oustanding order line cancelled: reason unspecified',
        221 => 'Oustanding order line cancelled: past order expiry date',
        222 => 'Oustanding order line cancelled by customer request',
        223 => 'Oustanding order line cancelled: unable to supply',
        300 => 'Order line passed to new supplier',
        301 => 'Order line passed to secondhand department',
        400 => 'Backordered - awaiting supply',
        401 => 'On order from our supplier',
        402 => 'On order from abroad',
        403 => 'Backordered, waiting to reach minimum order value',
        404 => 'Despatched from our supplier, awaiting delivery',
        405 => 'Our supplier sent wrong item(s), re-ordered',
        406 => 'Our supplier sent short, re-ordered',
        407 => 'Our supplier sent damaged item(s), re-ordered',
        408 => 'Our supplier sent imperfect item(s), re-ordered',
        409 => 'Our supplier cannot trace order, re-ordered',
        410 => 'Ordered item(s) being processed by bookseller',
        411 =>
'Ordered item(s) being processed by bookseller, awaiting customer action',
        412 => 'Order line held awaiting customer instruction',
        500 => 'Order line on hold - contact customer service',
        800 => 'Order line already despatched',
        900 => 'Cannot trace order line',
        901 => 'Order line held: note title change',
        902 => 'Order line held: note availability date delay',
        903 => 'Order line held: note price change',
        999 => 'Temporary hold: order action not yet determined',
    );

    if ( exists $code_list_12B{$code} ) {
        return $code_list_12B{$code};
    }
    else {
        return 'no match';
    }
}

# item_desription_fields accessors

sub title {
    my $self       = shift;
    my $titlefield = q{050};
    if ( exists $self->{item_description}->{$titlefield} ) {
        return $self->{item_description}->{$titlefield};
    }
    return;
}

sub author {
    my $self  = shift;
    my $field = q{010};
    if ( exists $self->{item_description}->{$field} ) {
        my $a              = $self->{item_description}->{$field};
        my $forename_field = q{011};
        if ( exists $self->{item_description}->{$forename_field} ) {
            $a .= ', ';
            $a .= $self->{item_description}->{$forename_field};
        }
        return $a;
    }
    return;
}

sub series {
    my $self  = shift;
    my $field = q{190};
    if ( exists $self->{item_description}->{$field} ) {
        return $self->{item_description}->{$field};
    }
    return;
}

sub publisher {
    my $self  = shift;
    my $field = q{120};
    if ( exists $self->{item_description}->{$field} ) {
        return $self->{item_description}->{$field};
    }
    return;
}

sub publication_date {
    my $self  = shift;
    my $field = q{170};
    if ( exists $self->{item_description}->{$field} ) {
        return $self->{item_description}->{$field};
    }
    return;
}

sub dewey_class {
    my $self  = shift;
    my $field = q{230};
    if ( exists $self->{item_description}->{$field} ) {
        return $self->{item_description}->{$field};
    }
    return;
}

sub lc_class {
    my $self  = shift;
    my $field = q{240};
    if ( exists $self->{item_description}->{$field} ) {
        return $self->{item_description}->{$field};
    }
    return;
}

sub girfield {
    my ( $self, $field, $occ ) = @_;
    if ( $self->number_of_girs ) {

        # defaults to occurence 0 returns undef if occ requested > occs
        if ( defined $occ && $occ >= @{ $self->{GIR} } ) {
            return;
        }
        $occ ||= 0;
        return $self->{GIR}->[$occ]->{$field};
    }
    else {
        return;
    }
}

sub number_of_girs {
    my $self = shift;
    if ( $self->{GIR} ) {

        my $qty = @{ $self->{GIR} };

        return $qty;
    }
    else {
        return 0;
    }
}

sub extract_gir {
    my $s    = shift;
    my %qmap = (
        LAC => 'barcode',
        LAF => 'first_accession_number',
        LAL => 'last_accession_number',
        LCL => 'classification',
        LCO => 'item_unique_id',
        LCV => 'copy_value',
        LFH => 'feature_heading',
        LFN => 'fund_allocation',
        LFS => 'filing_suffix',
        LLN => 'loan_category',
        LLO => 'branch',
        LLS => 'label_sublocation',
        LQT => 'part_order_quantity',
        LRS => 'record_sublocation',
        LSM => 'shelfmark',
        LSQ => 'collection_code',
        LST => 'stock_category',
        LSZ => 'size_code',
        LVC => 'coded_servicing_instruction',
        LVT => 'servicing_instruction',
    );

    my $set_qualifier = $s->elem( 0, 0 );    # copy number
    my $gir_element = { copy => $set_qualifier, };
    my $element = 1;
    while ( my $e = $s->elem($element) ) {
        ++$element;
        if ( exists $qmap{ $e->[1] } ) {
            my $qualifier = $qmap{ $e->[1] };
            $gir_element->{$qualifier} = $e->[0];
        }
        else {

            carp "Unrecognized GIR code : $e->[1] for $e->[0]";
        }
    }
    return $gir_element;
}

# mainly for invoice processing amt_ will derive from MOA price_ from PRI and tax_ from TAX/MOA pairsn
sub moa_amt {
    my ( $self, $qualifier ) = @_;
    foreach my $s ( @{ $self->{segs} } ) {
        if ( $s->tag eq 'MOA' && $s->elem( 0, 0 ) eq $qualifier ) {
            return $s->elem( 0, 1 );
        }
    }
    return;
}

sub amt_discount {
    my $self = shift;
    return $self->moa_amt('52');
}

sub amt_prepayment {
    my $self = shift;
    return $self->moa_amt('113');
}

# total including allowances & tax
sub amt_total {
    my $self = shift;
    return $self->moa_amt('128');
}

# Used to give price in currency other than that given in price
sub amt_unitprice {
    my $self = shift;
    return $self->moa_amt('146');
}

# item amount after allowances excluding tax
sub amt_lineitem {
    my $self = shift;
    return $self->moa_amt('203');
}

sub pri_price {
    my ( $self, $price_qualifier ) = @_;
    foreach my $s ( @{ $self->{segs} } ) {
        if ( $s->tag eq 'PRI' && $s->elem( 0, 0 ) eq $price_qualifier ) {
            return {
                price          => $s->elem( 0, 1 ),
                type           => $s->elem( 0, 2 ),
                type_qualifier => $s->elem( 0, 3 ),
            };
        }
    }
    return;
}

# unit price that will be chaged excl tax
sub price_net {
    my $self = shift;
    my $p    = $self->pri_price('AAA');
    if ( defined $p ) {
        return $p->{price};
    }
    return;
}

# unit price excluding all allowances, charges and taxes
sub price_gross {
    my $self = shift;
    my $p    = $self->pri_price('AAB');
    if ( defined $p ) {
        return $p->{price};
    }
    return;
}

# information price incl tax excluding allowances, charges
sub price_info {
    my $self = shift;
    my $p    = $self->pri_price('AAE');
    if ( defined $p ) {
        return $p->{price};
    }
    return;
}

# information price incl tax,allowances, charges
sub price_info_inclusive {
    my $self = shift;
    my $p    = $self->pri_price('AAE');
    if ( defined $p ) {
        return $p->{price};
    }
    return;
}

sub tax {
    my $self = shift;
    return $self->moa_amt('124');
}

sub availability_date {
    my $self = shift;
    if ( exists $self->{availability_date} ) {
        return $self->{availability_date};
    }
    return;
}

# return text string representing action code
sub _translate_action {
    my $code   = shift;
    my %action = (
        2  => 'cancelled',
        3  => 'change_requested',
        4  => 'no_action',
        5  => 'accepted',
        10 => 'not_found',
        24 => 'recorded',           # Order accepted but a change notified
    );
    if ( $code && exists $action{$code} ) {
        return $action{$code};
    }
    return $code;

}
1;
__END__

=head1 NAME

Koha::Edifact::Line

=head1 SYNOPSIS

  Class to abstractly handle a Line in an Edifact Transmission

=head1 DESCRIPTION

  Allows access to Edifact line elements by name

=head1 BUGS

  None documented at present

=head1 Methods

=head2 new

   Called with an array ref of segments constituting the line

=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>

=head1 COPYRIGHT

   Copyright 2014,2015  PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License


=cut
