package Koha::Edifact;

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
use File::Slurp;
use Carp;
use Encode qw( from_to );
use Koha::Edifact::Segment;
use Koha::Edifact::Message;

my $separator = {
    component => q{\:},
    data      => q{\+},
    decimal   => q{.},
    release   => q{\?},
    reserved  => q{ },
    segment   => q{\'},
};

sub new {
    my ( $class, $param_hashref ) = @_;
    my $transmission;
    my $self = ();

    if ( $param_hashref->{filename} ) {
        if ( $param_hashref->{transmission} ) {
            carp
"Cannot instantiate $class : both filename and transmission passed";
            return;
        }
        $transmission = read_file( $param_hashref->{filename} );
    }
    else {
        $transmission = $param_hashref->{transmission};
    }
    $self->{transmission} = _init($transmission);

    bless $self, $class;
    return $self;
}

sub interchange_header {
    my ( $self, $field ) = @_;

    my %element = (
        sender                        => 1,
        recipient                     => 2,
        datetime                      => 3,
        interchange_control_reference => 4,
        application_reference         => 6,
    );
    if ( !exists $element{$field} ) {
        carp "No interchange header field $field available";
        return;
    }
    my $data = $self->{transmission}->[0]->elem( $element{$field} );
    return $data;
}

sub interchange_trailer {
    my ( $self, $field ) = @_;
    my $trailer = $self->{transmission}->[-1];
    if ( $field eq 'interchange_control_count' ) {
        return $trailer->elem(0);
    }
    elsif ( $field eq 'interchange_control_reference' ) {
        return $trailer->elem(1);
    }
    carp "Trailer field $field not recognized";
    return;
}

sub new_data_iterator {
    my $self   = shift;
    my $offset = 0;
    while ( $self->{transmission}->[$offset]->tag() ne 'UNH' ) {
        ++$offset;
        if ( $offset == @{ $self->{transmission} } ) {
            carp 'Cannot find message start';
            return;
        }
    }
    $self->{data_iterator} = $offset;
    return 1;
}

sub next_segment {
    my $self = shift;
    if ( defined $self->{data_iterator} ) {
        my $seg = $self->{transmission}->[ $self->{data_iterator} ];
        if ( $seg->tag eq 'UNH' ) {

            $self->{msg_type} = $seg->elem( 1, 0 );
        }
        elsif ( $seg->tag eq 'LIN' ) {
            $self->{msg_type} = 'detail';
        }

        if ( $seg->tag ne 'UNZ' ) {
            $self->{data_iterator}++;
        }
        else {
            $self->{data_iterator} = undef;
        }
        return $seg;
    }
    return;
}

# for debugging return whole transmission
sub get_transmission {
    my $self = shift;

    return $self->{transmission};
}

sub message_type {
    my $self = shift;
    return $self->{msg_type};
}

sub _init {
    my $msg = shift;
    if ( !$msg ) {
        return;
    }
    if ( $msg =~ s/^UNA(.{6})// ) {
        if ( service_string_advice($1) ) {
            return segmentize($msg);

        }
        return;
    }
    else {
        my $s = substr $msg, 10;
        croak "File does not start with a Service string advice :$s";
    }
}

# return an array of Message objects
sub message_array {
    my $self = shift;

    # return an array of array_refs 1 ref to a message
    my $msg_arr = [];
    my $msg     = [];
    my $in_msg  = 0;
    foreach my $seg ( @{ $self->{transmission} } ) {
        if ( $seg->tag eq 'UNH' ) {
            $in_msg = 1;
            push @{$msg}, $seg;
        }
        elsif ( $seg->tag eq 'UNT' ) {
            $in_msg = 0;
            if ( @{$msg} ) {
                push @{$msg_arr}, Koha::Edifact::Message->new($msg);
                $msg = [];
            }
        }
        elsif ($in_msg) {
            push @{$msg}, $seg;
        }
    }
    return $msg_arr;
}

#
# internal parsing routines used in _init
#
sub service_string_advice {
    my $ssa = shift;

    # At present this just validates that the ssa
    # is standard Edifact
    # TBD reset the seps if non standard
    if ( $ssa ne q{:+.? '} ) {
        carp " Non standard Service String Advice [$ssa]";
        return;
    }

    # else use default separators
    return 1;
}

sub segmentize {
    my $raw = shift;

    # In practice edifact uses latin-1 but check
    # Transport now converts to utf-8 on ingest
    # Do not convert here
    #my $char_set = 'iso-8859-1';
    #if ( $raw =~ m/^UNB[+]UNO(.)/ ) {
    #    $char_set = msgcharset($1);
    #}
    #from_to( $raw, $char_set, 'utf8' );

    my $re = qr{
(?>         # dont backtrack into this group
    [?].     # either the escape character
            # followed by any other character
     |      # or
     [^'?]   # a character that is neither escape
             # nor split
             )+
}x;
    my @segmented;
    while ( $raw =~ /($re)/g ) {
        push @segmented, Koha::Edifact::Segment->new( { seg_string => $1 } );
    }
    return \@segmented;
}

sub msgcharset {
    my $code = shift;
    if ( $code =~ m/^[^ABCDEF]$/ ) {
        $code = 'default';
    }
    my %encoding_map = (
        A       => 'ascii',
        B       => 'ascii',
        C       => 'iso-8859-1',
        D       => 'iso-8859-1',
        E       => 'iso-8859-1',
        F       => 'iso-8859-1',
        default => 'iso-8859-1',
    );
    return $encoding_map{$code};
}

1;
__END__

=head1 NAME

Edifact - Edifact message handler

=head1 DESCRIPTION

   Koha module for parsing Edifact messages

=head1 SUBROUTINES

=head2 new

     my $e = Koha::Edifact->new( { filename => 'myfilename' } );
     or
     my $e = Koha::Edifact->new( { transmission => $msg_variable } );

     instantiate the Edifact parser, requires either to be passed an in-memory
     edifact message as transmission or a filename which it will read on creation

=head2 interchange_header

     will return the data in the header field designated by the parameter
     specified. Valid parameters are: 'sender', 'recipient', 'datetime',
    'interchange_control_reference', and 'application_reference'

=head2 interchange_trailer

     called either with the string 'interchange_control_count' or
     'interchange_control_reference' will return the corresponding field from
     the interchange trailer

=head2 new_data_iterator

     Sets the object's data_iterator to point to the UNH segment

=head2 next_segment

     Returns the next segment pointed to by the data_iterator. Increments the
     data_iterator member or destroys it if segment UNZ has been reached

=head2 get_transmission

     This method is useful in debugg:ing. Call on an Edifact object
     it returns the object's transmission member

=head2 message_type

     return the object's message type

=head2 message_array

     return an array of Message objects contained in the Edifact transmission

=head1 Internal Methods

=head2 _init

  Called by the constructor to do the parsing of the transmission

=head2 service_string_advice

  Examines the Service String Advice returns 1 if the default separartors are in use
  undef otherwise

=head2 segmentize

   takes a raw Edifact message and returns a reference to an array of
   its segments

=head2 msgcharset

    Return the character set the message was encoded in. The default is iso-8859-1

    We preserve this info but will have converted to utf-8 on ingest

=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>


=head1 COPYRIGHT

   Copyright 2014,2015, PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License


=cut
