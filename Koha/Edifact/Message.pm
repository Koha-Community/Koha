package Koha::Edifact::Message;

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

use strict;
use warnings;
use utf8;

use Koha::Edifact::Line;

sub new {
    my ( $class, $data_array_ref ) = @_;
    my $header       = shift @{$data_array_ref};
    my $bgm          = shift @{$data_array_ref};
    my $msg_function = $bgm->elem(2);
    my $dtm          = [];
    while ( $data_array_ref->[0]->tag eq 'DTM' ) {
        push @{$dtm}, shift @{$data_array_ref};
    }

    my $self = {
        function                 => $msg_function,
        header                   => $header,
        bgm                      => $bgm,
        message_reference_number => $header->elem(0),
        dtm                      => $dtm,
        datasegs                 => $data_array_ref,
    };

    bless $self, $class;
    return $self;
}

sub message_refno {
    my $self = shift;
    return $self->{message_reference_number};
}

sub function {
    my $self         = shift;
    my $msg_function = $self->{bgm}->elem(2);
    if ( $msg_function == 9 ) {
        return 'original';
    }
    elsif ( $msg_function == 7 ) {
        return 'retransmission';
    }
    return;
}

sub message_reference_number {
    my $self = shift;
    return $self->{header}->elem(0);
}

sub message_type {
    my $self = shift;
    return $self->{header}->elem( 1, 0 );
}

sub message_code {
    my $self = shift;
    return $self->{bgm}->elem( 0, 0 );
}

sub docmsg_number {
    my $self = shift;
    return $self->{bgm}->elem(1);
}

sub message_date {
    my $self = shift;

    # usually the first if not only dtm
    foreach my $d ( @{ $self->{dtm} } ) {
        if ( $d->elem( 0, 0 ) eq '137' ) {
            return $d->elem( 0, 1 );
        }
    }
    return;    # this should not happen
}

sub tax_point_date {
    my $self = shift;
    if ( $self->message_type eq 'INVOIC' ) {
        foreach my $d ( @{ $self->{dtm} } ) {
            if ( $d->elem( 0, 0 ) eq '131' ) {
                return $d->elem( 0, 1 );
            }
        }
    }
    return;
}

sub expiry_date {
    my $self = shift;
    if ( $self->message_type eq 'QUOTES' ) {
        foreach my $d ( @{ $self->{dtm} } ) {
            if ( $d->elem( 0, 0 ) eq '36' ) {
                return $d->elem( 0, 1 );
            }
        }
    }
    return;
}

sub shipment_charge {
    my $self = shift;

    # A large number of different charges can be expressed at invoice and
    # item level but the only one koha takes cognizance of is shipment
    # should we wrap all invoice level charges into it??
    if ( $self->message_type eq 'INVOIC' ) {
        my $delivery = 0;
        my $amt      = 0;
        foreach my $s ( @{ $self->{datasegs} } ) {
            if ( $s->tag eq 'LIN' ) {
                last;
            }
            if ( $s->tag eq 'ALC' ) {
                if ( $s->elem(0) eq 'C' ) {    # Its a charge
                    if ( $s->elem( 4, 0 ) eq 'DL' ) {    # delivery charge
                        $delivery = 1;
                    }
                }
                next;
            }
            if ( $s->tag eq 'MOA' ) {
                $amt += $s->elem( 0, 1 );
            }
        }
        return $amt;
    }
    return;
}

# return NAD fields

sub buyer_ean {
    my $self = shift;
    foreach my $s ( @{ $self->{datasegs} } ) {
        if ( $s->tag eq 'LIN' ) {
            last;
        }
        if ( $s->tag eq 'NAD' ) {
            my $qualifier = $s->elem(0);
            if ( $qualifier eq 'BY' ) {
                return $s->elem( 1, 0 );
            }
        }
    }
    return;
}

sub supplier_ean {
    my $self = shift;
    foreach my $s ( @{ $self->{datasegs} } ) {
        if ( $s->tag eq 'LIN' ) {
            last;
        }
        if ( $s->tag eq 'NAD' ) {
            my $qualifier = $s->elem(0);
            if ( $qualifier eq 'SU' ) {
                return $s->elem( 1, 0 );
            }
        }
    }
    return;

}

sub lineitems {
    my $self = shift;
    if ( $self->{quotation_lines} ) {
        return $self->{quotation_lines};
    }
    else {
        my $items    = [];
        my $item_arr = [];
        foreach my $seg ( @{ $self->{datasegs} } ) {
            my $tag = $seg->tag;
            if ( $tag eq 'LIN' ) {
                if ( @{$item_arr} ) {
                    push @{$items}, Koha::Edifact::Line->new($item_arr);
                }
                $item_arr = [$seg];
                next;
            }
            elsif ( $tag =~ m/^(UNS|CNT|UNT)$/sxm ) {
                if ( @{$item_arr} ) {
                    push @{$items}, Koha::Edifact::Line->new($item_arr);
                }
                last;
            }
            else {
                if ( @{$item_arr} ) {
                    push @{$item_arr}, $seg;
                }
            }
        }
        $self->{quotation_lines} = $items;
        return $items;
    }
}

1;
__END__

=head1 NAME

Koha::Edifact::Message

=head1 DESCRIPTION

Class modelling an Edifact Message for parsing

=head1 METHODS

=head2 new

   Passed an array of segments extracts message level info
   and parses lineitems as Line objects

=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>

=head1 COPYRIGHT

   Copyright 2014,2015 PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License

=cut
