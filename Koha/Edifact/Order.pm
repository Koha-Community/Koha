package Koha::Edifact::Order;

use strict;
use warnings;
use utf8;

# Copyright 2014,2015 PTFS-Europe Ltd
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

use Carp;
use DateTime;
use Readonly;
use Business::ISBN;
use Koha::Database;
use C4::Budgets qw( GetBudget );

use Koha::Acquisition::Orders;

Readonly::Scalar my $seg_terminator      => q{'};
Readonly::Scalar my $separator           => q{+};
Readonly::Scalar my $component_separator => q{:};
Readonly::Scalar my $release_character   => q{?};

Readonly::Scalar my $NINES_12  => 999_999_999_999;
Readonly::Scalar my $NINES_14  => 99_999_999_999_999;
Readonly::Scalar my $CHUNKSIZE => 35;

sub new {
    my ( $class, $parameter_hashref ) = @_;

    my $self = {};
    if ( ref $parameter_hashref ) {
        $self->{orderlines}  = $parameter_hashref->{orderlines};
        $self->{recipient}   = $parameter_hashref->{vendor};
        $self->{sender}      = $parameter_hashref->{ean};
        $self->{is_response} = $parameter_hashref->{is_response};

        # convenient alias
        $self->{basket} = $self->{orderlines}->[0]->basketno;
        $self->{message_date} = DateTime->now( time_zone => 'local' );
    }

    # validate that its worth proceeding
    if ( !$self->{orderlines} ) {
        carp 'No orderlines passed to create order';
        return;
    }
    if ( !$self->{recipient} ) {
        carp 'No vendor passed to order creation: basket = '
          . $self->{basket}->basketno;
        return;
    }
    if ( !$self->{sender} ) {
        carp 'No sender ean passed to order creation: basket = '
          . $self->{basket}->basketno;
        return;
    }

    # do this once per object not once per orderline
    my $database = Koha::Database->new();
    $self->{schema} = $database->schema;

    bless $self, $class;
    return $self;
}

sub filename {
    my $self = shift;
    if ( !$self->{orderlines} ) {
        return;
    }
    my $filename = 'ordr' . $self->{basket}->basketno;
    $filename .= '.CEP';
    return $filename;
}

sub encode {
    my ($self) = @_;

    $self->{interchange_control_reference} = int rand($NINES_14);
    $self->{message_count}                 = 0;

    #    $self->{segs}; # Message segments

    $self->{transmission} = q{};

    $self->{transmission} .= $self->initial_service_segments();

    $self->{transmission} .= $self->user_data_message_segments();

    $self->{transmission} .= $self->trailing_service_segments();
    return $self->{transmission};
}

sub msg_date_string {
    my $self = shift;
    return $self->{message_date}->ymd();
}

sub initial_service_segments {
    my $self = shift;

    #UNA service string advice - specifies standard separators
    my $segs = _const('service_string_advice');

    #UNB interchange header
    $segs .= $self->interchange_header();

    #UNG functional group header NOT USED
    return $segs;
}

sub interchange_header {
    my $self = shift;

    # syntax identifier
    my $hdr =
      'UNB+UNOC:3';    # controlling agency character set syntax version number
                       # Interchange Sender
    $hdr .= _interchange_sr_identifier( $self->{sender}->ean,
        $self->{sender}->id_code_qualifier );    # interchange sender
    $hdr .= _interchange_sr_identifier( $self->{recipient}->san,
        $self->{recipient}->id_code_qualifier );    # interchange Recipient

    $hdr .= $separator;

    # DateTime of preparation
    $hdr .= $self->{message_date}->format_cldr('yyMMdd:HHmm');
    $hdr .= $separator;
    $hdr .= $self->interchange_control_reference();
    $hdr .= $separator;

    # Recipents reference password not usually used in edifact
    $hdr .= q{+ORDERS};                             # application reference

#Edifact does not usually include the following
#    $hdr .= $separator; # Processing priority  not usually used in edifact
#    $hdr .= $separator; # Acknowledgewment request : not usually used in edifact
#    $hdr .= q{+EANCOM} # Communications agreement id
#    $hdr .= q{+1} # Test indicator
#
    $hdr .= $seg_terminator;
    return $hdr;
}

sub user_data_message_segments {
    my $self = shift;

    #UNH message_header  :: seg count begins here
    $self->message_header();

    $self->order_msg_header();

    my $line_number = 0;
    foreach my $ol ( @{ $self->{orderlines} } ) {
        ++$line_number;
        $self->order_line( $line_number, $ol );
    }

    $self->message_trailer();

    my $data_segment_string = join q{}, @{ $self->{segs} };
    return $data_segment_string;
}

sub message_trailer {
    my $self = shift;

    # terminate the message
    $self->add_seg("UNS+S$seg_terminator");

    # CNT Control_Total
    # Could be (code  1) total value of QTY segments
    # or ( code = 2 ) number of lineitems
    my $num_orderlines = @{ $self->{orderlines} };
    $self->add_seg("CNT+2:$num_orderlines$seg_terminator");

    # UNT Message Trailer
    my $segments_in_message =
      1 + @{ $self->{segs} };    # count incl UNH & UNT (!!this one)
    my $reference = $self->message_reference('current');
    $self->add_seg("UNT+$segments_in_message+$reference$seg_terminator");
    return;
}

sub trailing_service_segments {
    my $self    = shift;
    my $trailer = q{};

    #UNE functional group trailer NOT USED
    #UNZ interchange trailer
    $trailer .= $self->interchange_trailer();

    return $trailer;
}

sub interchange_control_reference {
    my $self = shift;
    if ( $self->{interchange_control_reference} ) {
        return sprintf '%014d', $self->{interchange_control_reference};
    }
    else {
        carp 'calling for ref of unencoded order';
        return 'NONE ASSIGNED';
    }
}

sub message_reference {
    my ( $self, $function ) = @_;
    if ( $function eq 'new' || !$self->{message_reference_no} ) {

        # unique 14 char mesage ref
        $self->{message_reference_no} = sprintf 'ME%012d', int rand($NINES_12);
    }
    return $self->{message_reference_no};
}

sub message_header {
    my $self = shift;

    $self->{segs} = [];          # initialize the message
    $self->{message_count}++;    # In practice alwaya 1

    my $hdr = q{UNH+} . $self->message_reference('new');
    $hdr .= _const('message_identifier');
    $self->add_seg($hdr);
    return;
}

sub interchange_trailer {
    my $self = shift;

    my $t = "UNZ+$self->{message_count}+";
    $t .= $self->interchange_control_reference;
    $t .= $seg_terminator;
    return $t;
}

sub order_msg_header {
    my $self = shift;
    my @header;

    # UNH  see message_header
    # BGM
    push @header,
      beginning_of_message(
        $self->{basket}->basketno,
        $self->{recipient}->san,
        $self->{is_response}
      );

    # DTM
    push @header, message_date_segment( $self->{message_date} );

    # NAD-RFF buyer supplier ids
    push @header,
      name_and_address(
        'BUYER',
        $self->{sender}->ean,
        $self->{sender}->id_code_qualifier
      );
    push @header,
      name_and_address(
        'SUPPLIER',
        $self->{recipient}->san,
        $self->{recipient}->id_code_qualifier
      );

    # repeat for for other relevant parties

    # CUX currency
    # ISO 4217 code to show default currency prices are quoted in
    # e.g. CUX+2:GBP:9'
    # TBD currency handling

    $self->add_seg(@header);
    return;
}

sub beginning_of_message {
    my $basketno            = shift;
    my $supplier_san        = shift;
    my $response            = shift;
    my $document_message_no = sprintf '%011d', $basketno;

  # Peters & Bolinda use the BIC recommendation to use 22V a code not in Edifact
  # If the order is in response to a quote
    my %bic_sans = (
        '5013546025065' => 'Peters',
        '9377779308820' => 'Bolinda',
    );

    #    my $message_function = 9;    # original 7 = retransmission
    # message_code values
    #      220 prder
    #      224 rush order
    #      228 sample order :: order for approval / inspection copies
    #      22C continuation  order for volumes in a set etc.
    #    my $message_code = '220';
    if ( exists $bic_sans{$supplier_san} && $response ) {
        return "BGM+22V+$document_message_no+9$seg_terminator";
    }

    return "BGM+220+$document_message_no+9$seg_terminator";
}

sub name_and_address {
    my ( $party, $id_code, $id_agency ) = @_;
    my %qualifier_code = (
        BUYER    => 'BY',
        DELIVERY => 'DP',    # delivery location if != buyer
        INVOICEE => 'IV',    # if different from buyer
        SUPPLIER => 'SU',
    );
    if ( !exists $qualifier_code{$party} ) {
        carp "No qualifier code for $party";
        return;
    }
    if ( $id_agency eq '14' ) {
        $id_agency = '9';    # ean coded differently in this seg
    }

    return "NAD+$qualifier_code{$party}+${id_code}::$id_agency$seg_terminator";
}

sub order_line {
    my ( $self, $linenumber, $orderline ) = @_;

    my $basket = Koha::Acquisition::Orders->find( $orderline->ordernumber )->basket;

    my $schema = $self->{schema};
    if ( !$orderline->biblionumber )
    {                        # cannot generate an orderline without a bib record
        return;
    }
    my $biblionumber = $orderline->biblionumber->biblionumber;
    my @biblioitems  = $schema->resultset('Biblioitem')
      ->search( { biblionumber => $biblionumber, } );
    my $biblioitem = $biblioitems[0];    # makes the assumption there is 1 only
                                         # or else all have same details

    my $id_string = $orderline->line_item_id;

    # LIN line-number in msg :: if we had a 13 digit ean we could add
    $self->add_seg( lin_segment( $linenumber, $id_string ) );

    # PIA isbn or other id
    my @identifiers;
    foreach my $id ( $biblioitem->ean, $biblioitem->issn, $biblioitem->isbn ) {
        if ( $id && $id ne $id_string ) {
            push @identifiers, $id;
        }
    }
    $self->add_seg( additional_product_id( join( ' ', @identifiers ) ) );

    #  biblio description
    $self->add_seg( item_description( $orderline->biblionumber, $biblioitem ) );

    # QTY order quantity
    my $qty = join q{}, 'QTY+21:', $orderline->quantity, $seg_terminator;
    $self->add_seg($qty);

    # DTM Optional date constraints on delivery
    #     we dont currently support this in koha
    # GIR copy-related data
    my @items;
    if ( $basket->effective_create_items eq 'ordering' ) {
        my @linked_itemnumbers = $orderline->aqorders_items;

        foreach my $item (@linked_itemnumbers) {
            my $i_obj = $schema->resultset('Item')->find( $item->itemnumber );
            if ( defined $i_obj ) {
                push @items, $i_obj;
            }
        }
    }
    else {
        my $item_hash = {
            itemtype  => $biblioitem->itemtype,
            shelfmark => $biblioitem->cn_class,
        };
        my $branch = $orderline->basketno->deliveryplace;
        if ($branch) {
            $item_hash->{branch} = $branch;
        }
        for ( 1 .. $orderline->quantity ) {
            push @items, $item_hash;
        }
    }
    my $budget = GetBudget( $orderline->budget_id );
    my $ol_fields = { budget_code => $budget->{budget_code}, };
    if ( $orderline->order_vendornote ) {
        $ol_fields->{servicing_instruction} = $orderline->order_vendornote;
    }
    $self->add_seg(
        gir_segments(
            {
                basket    => $basket,
                ol_fields => $ol_fields,
                items     => \@items
            }
        )
    );

    # TBD what if #items exceeds quantity

    # FTX free text for current orderline TBD
    #    dont really have a special instructions field to encode here
    # Encode notes here
    # PRI-CUX-DTM unit price on which order is placed : optional
    # Coutts read this as 0.00 if not present
    if ( $orderline->listprice ) {
        my $price = sprintf 'PRI+AAE:%.2f:CA', $orderline->listprice;
        $price .= $seg_terminator;
        $self->add_seg($price);
    }

    # RFF unique orderline reference no
    my $rff = join q{}, 'RFF+LI:', $orderline->ordernumber, $seg_terminator;
    $self->add_seg($rff);

    # RFF : suppliers unique quotation reference number
    if ( $orderline->suppliers_reference_number ) {
        $rff = join q{}, 'RFF+', $orderline->suppliers_reference_qualifier,
          ':', $orderline->suppliers_reference_number, $seg_terminator;
        $self->add_seg($rff);
    }

    # LOC-QTY multiple delivery locations
    #TBD to specify extra delivery locs
    # NAD order line name and address
    #TBD Optionally indicate a name & address or order originator
    # TDT method of delivey ol-specific
    # TBD requests a special delivery option

    return;
}

sub item_description {
    my ( $bib, $biblioitem ) = @_;
    my $bib_desc = {
        author    => $bib->author,
        title     => $bib->title,
        publisher => $biblioitem->publishercode,
        year      => $biblioitem->publicationyear,
    };

    my @itm = ();

    # 009 Author
    # 050 Title   :: title
    # 080 Vol/Part no
    # 100 Edition statement
    # 109 Publisher  :: publisher
    # 110 place of pub
    # 170 Date of publication :: year
    # 220 Binding  :: binding
    my %code = (
        author    => '009',
        title     => '050',
        publisher => '109',
        year      => '170',
        binding   => '220',
    );
    for my $field (qw(author title publisher year binding )) {
        if ( $bib_desc->{$field} ) {
            my $data = encode_text( $bib_desc->{$field} );
            push @itm, imd_segment( $code{$field}, $data );
        }
    }

    return @itm;
}

sub imd_segment {
    my ( $code, $data ) = @_;

    my $seg_prefix = "IMD+L+$code+:::";

    # chunk_line
    my @chunks;
    while ( my $x = substr $data, 0, $CHUNKSIZE, q{} ) {
        if ( length $x == $CHUNKSIZE ) {
            if ( $x =~ s/([?]{1,2})$// ) {
                $data = "$1$data";    # dont breakup ?' ?? etc
            }
        }
        push @chunks, $x;
    }
    my @segs;
    my $odd = 1;
    foreach my $c (@chunks) {
        if ($odd) {
            push @segs, "$seg_prefix$c";
        }
        else {
            $segs[-1] .= ":$c$seg_terminator";
        }
        $odd = !$odd;
    }
    if ( @segs && $segs[-1] !~ m/$seg_terminator$/o ) {
        $segs[-1] .= $seg_terminator;
    }
    return @segs;
}

sub gir_segments {
    my ($params) = @_;

    my $basket       = $params->{basket};
    my $orderfields  = $params->{ol_fields};
    my @onorderitems = @{ $params->{items} };

    my $budget_code = $orderfields->{budget_code};
    my @segments;
    my $sequence_no = 1;
    foreach my $item (@onorderitems) {
        my $seg = sprintf 'GIR+%03d', $sequence_no;
        $seg .= add_gir_identity_number( 'LFN', $budget_code );
        if ( $basket->effective_create_items eq 'ordering' ) {
            $seg .=
              add_gir_identity_number( 'LLO', $item->homebranch->branchcode );
            $seg .= add_gir_identity_number( 'LST', $item->itype );
            $seg .= add_gir_identity_number( 'LSQ', $item->location );
            $seg .= add_gir_identity_number( 'LSM', $item->itemcallnumber );

            # itemcallnumber -> shelfmark
        }
        else {
            if ( $item->{branch} ) {
                $seg .= add_gir_identity_number( 'LLO', $item->{branch} );
            }
            $seg .= add_gir_identity_number( 'LST', $item->{itemtype} );
            $seg .= add_gir_identity_number( 'LSM', $item->{shelfmark} );
        }
        if ( $orderfields->{servicing_instruction} ) {
            $seg .= add_gir_identity_number( 'LVT',
                $orderfields->{servicing_instruction} );
        }
        $sequence_no++;
        push @segments, $seg;
    }
    return @segments;
}

sub add_gir_identity_number {
    my ( $number_qualifier, $number ) = @_;
    if ($number) {
        return "+${number}:${number_qualifier}";
    }
    return q{};
}

sub add_seg {
    my ( $self, @s ) = @_;
    foreach my $segment (@s) {
        if ( $segment !~ m/$seg_terminator$/o ) {
            $segment .= $seg_terminator;
        }
    }
    push @{ $self->{segs} }, @s;
    return;
}

sub lin_segment {
    my ( $line_number, $item_number_id ) = @_;

    if ($item_number_id) {
        $item_number_id = "++${item_number_id}:EN";
    }
    else {
        $item_number_id = q||;
    }

    return "LIN+$line_number$item_number_id$seg_terminator";
}

sub additional_product_id {
    my $isbn_field = shift;
    my ( $product_id, $product_code );
    if ( $isbn_field =~ m/(\d{13})/ ) {
        $product_id   = $1;
        $product_code = 'EN';
    }
    elsif ( $isbn_field =~ m/(\d{9}[Xx\d])/ ) {
        $product_id   = $1;
        $product_code = 'IB';
    }

    # TBD we could have a manufacturers no issn etc
    if ( !$product_id ) {
        return;
    }

    # function id set to 5 states this is the main product id
    return "PIA+5+$product_id:$product_code$seg_terminator";
}

sub message_date_segment {
    my $dt = shift;

    # qualifier:message_date:format_code

    my $message_date = $dt->ymd(q{});    # no sep in edifact format

    return "DTM+137:$message_date:102$seg_terminator";
}

sub _const {
    my $key = shift;
    Readonly my %S => {
        service_string_advice => q{UNA:+.? '},
        message_identifier    => q{+ORDERS:D:96A:UN:EAN008'},
    };
    return ( $S{$key} ) ? $S{$key} : q{};
}

sub _interchange_sr_identifier {
    my ( $identification, $qualifier ) = @_;

    if ( !$identification ) {
        $identification = 'RANDOM';
        $qualifier      = '92';
        carp 'undefined identifier';
    }

    # 14   EAN International
    # 31B   US SAN (preferred)
    # also 91 assigned by supplier
    # also 92 assigned by buyer
    if ( $qualifier !~ m/^(?:14|31B|91|92)/xms ) {
        $qualifier = '92';
    }

    return "+$identification:$qualifier";
}

sub encode_text {
    my $string = shift;
    if ($string) {
        $string =~ s/[?]/??/g;
        $string =~ s/'/?'/g;
        $string =~ s/:/?:/g;
        $string =~ s/[+]/?+/g;
    }
    return $string;
}

1;
__END__

=head1 NAME

Koha::Edifact::Order

=head1 SYNOPSIS

Format an Edifact Order message from a Koha basket

=head1 DESCRIPTION

Generates an Edifact format Order message for a Koha basket.
Normally the only methods used directly by the caller would be
new to set up the message, encode to return the formatted message
and filename to obtain a name under which to store the message

=head1 BUGS

Should integrate into Koha::Edifact namespace
Can caller interface be made cleaner?
Make handling of GIR segments more customizable

=head1 METHODS

=head2 new

  my $edi_order = Edifact::Order->new(
  orderlines => \@orderlines,
  vendor     => $vendor_edi_account,
  ean        => $library_ean
  );

  instantiate the Edifact::Order object, all parameters are Schema::Resultset objects
  Called in Koha::Edifact create_edi_order

=head2 filename

   my $filename = $edi_order->filename()

   returns a filename for the edi order. The filename embeds a reference to the
   basket the message was created to encode

=head2 encode

   my $edifact_message = $edi_order->encode();

   Encodes the basket as a valid edifact message ready for transmission

=head2 initial_service_segments

    Creates the service segments which begin the message

=head2 interchange_header

    Return an interchange header encoding sender and recipient
    ids message date and standards

=head2 user_data_message_segments

    Include message data within the encoded message

=head2 message_trailer

    Terminate message data including control data on number
    of messages and segments included

=head2 trailing_service_segments

   Include the service segments occurring at the end of the message

=head2 interchange_control_reference

   Returns the unique interchange control reference as a 14 digit number

=head2 message_reference

    On generates and subsequently returns the unique message
    reference number as a 12 digit number preceded by ME, to generate a new number
    pass the string 'new'.
    In practice we encode 1 message per transmission so there is only one message
    referenced. were we to encode multiple messages a new reference would be
    neaded for each

=head2 message_header

    Commences a new message

=head2 interchange_trailer

    returns the UNZ segment which ends the tranmission encoding the
    message count and control reference for the interchange

=head2 order_msg_header

    Formats the message header segments

=head2 beginning_of_message

    Returns the BGM segment which includes the Koha basket number

=head2 name_and_address

    Parameters: Function ( BUYER, DELIVERY, INVOICE, SUPPLIER)
                Id
                Agency

    Returns a NAD segment containg the id and agency for for the Function
    value. Handles the fact that NAD segments encode the value for 'EAN' differently
    to elsewhere.

=head2 order_line

    Creates the message segments wncoding an order line

=head2 item_description

    Encodes the biblio item fields Author, title, publisher, date of publication
    binding

=head2 imd_segment

    Formats an IMD segment, handles the chunking of data into the 35 character
    lengths required and the creation of repeat segments

=head2 gir_segments

    Add item level information

=head2 add_gir_identity_number

    Handle the formatting of a GIR element
    return empty string if no data

=head2 add_seg

    Adds a parssed array of segments to the objects segment list
    ensures all segments are properly terminated by '

=head2 lin_segment

    Adds a LIN segment consisting of the line number and the ean number
    if the passed isbn is valid

=head2 additional_product_id

    Add a PIA segment for an additional product id

=head2 message_date_segment

    Passed a DateTime object returns a correctly formatted DTM segment

=head2 _const

    Stores and returns constant strings for service_string_advice
    and message_identifier
    TBD replace with class variables

=head2 _interchange_sr_identifier

    Format sender and receipient identifiers for use in the interchange header

=head2 encode_text

    Encode textual data into the standard character set ( iso 8859-1 )
    and quote any Edifact metacharacters

=head2 msg_date_string

    Convenient routine which returns message date as a Y-m-d string
    useful if the caller wants to log date of creation

=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>


=head1 COPYRIGHT

   Copyright 2014,2015,2016 PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License


=cut
