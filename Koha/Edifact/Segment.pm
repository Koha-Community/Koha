package Koha::Edifact::Segment;

# Copyright 2014,2016 PTFS-Europe Ltd
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

sub new {
    my ( $class, $parm_ref ) = @_;
    my $self = {};
    if ( $parm_ref->{seg_string} ) {
        $self = _parse_seg( $parm_ref->{seg_string} );
    }

    bless $self, $class;
    return $self;
}

sub tag {
    my $self = shift;
    return $self->{tag};
}

# return specified element may be data or an array ref if components
sub elem {
    my ( $self, $element_number, $component_number ) = @_;
    if ( $element_number < @{ $self->{elem_arr} } ) {

        my $e = $self->{elem_arr}->[$element_number];
        if ( defined $component_number ) {
            if ( ref $e eq 'ARRAY' ) {
                if ( $component_number < @{$e} ) {
                    return $e->[$component_number];
                }
            }
            elsif ( $component_number == 0 ) {

                # a string could be an element with a single component
                return $e;
            }
            return;
        }
        else {
            return $e;
        }
    }
    return;    #element undefined ( out of range
}

sub element {
    my ( $self, @params ) = @_;

    return $self->elem(@params);
}

sub as_string {
    my $self = shift;

    my $string = $self->{tag};
    foreach my $e ( @{ $self->{elem_arr} } ) {
        $string .= q|+|;
        if ( ref $e eq 'ARRAY' ) {
            $string .= join q{:}, @{$e};
        }
        else {
            $string .= $e;
        }
    }

    return $string;
}

# parse a string into fields
sub _parse_seg {
    my $s = shift;
    my $e = {
        tag      => substr( $s,                0, 3 ),
        elem_arr => _get_elements( substr( $s, 3 ) ),
    };
    return $e;
}

##
# String parsing
#

sub _get_elements {
    my $seg = shift;

    $seg =~ s/^[+]//;    # dont start with a dummy element`
    my @elem_array = map { _components($_) } split /(?<![?])[+]/, $seg;

    return \@elem_array;
}

sub _components {
    my $element = shift;
    my @c = split /(?<![?])[:]/, $element;
    if ( @c == 1 ) {     # single element return a string
        return de_escape( $c[0] );
    }
    @c = map { de_escape($_) } @c;
    return \@c;
}

sub de_escape {
    my $string = shift;

    # remove escaped characters from the component string
    $string =~ s/[?]([:?+'])/$1/g;
    return $string;
}
1;
__END__

=head1 NAME

Koha::Edifact::Segment - Class foe Edifact Segments

=head1 DESCRIPTION

 Used by Koha::Edifact to represent segments in a parsed Edifact message


=head1 METHODS

=head2 new

     my $s = Koha::Edifact::Segment->new( { seg_string => $raw });

     passed a string representation of the segment,  parses it
     and retums a Segment object

=head2 tag

     returns the three character segment tag

=head2 elem

      $data = $s->elem($element_number, $component_number)
      return the contents of a specified element and if specified
      component of that element

=head2 element

      syntactic sugar this wraps the rlem method in a fuller name

=head2 as_string

      returns a string representation of the segment

=head2 _parse_seg

   passed a string representation of a segment returns a hash ref with
   separate tag and data elements

=head2 _get_elements

   passed the data portion of a segment, splits it into elements, passing each to
   components to further parse them. Returns a reference to an array of
   elements

=head2 _components

   Passed a string element splits it into components  and returns a reference
   to an array of components, if only one component is present that is returned
   directly.
   quote characters are removed from the components

=head2 de_escape

   Removes Edifact escapes from the passed string and returns the modified
   string


=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>


=head1 COPYRIGHT

   Copyright 2014,2016, PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License


=cut
