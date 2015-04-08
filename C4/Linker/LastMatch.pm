package C4::Linker::LastMatch;

# Copyright 2011 C & P Bibliography Services
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
use Carp;
use C4::Heading;
use C4::Linker::Default;    # Use Default for flipping

use base qw(C4::Linker);

sub new {
    my $class = shift;
    my $param = shift;

    my $self = $class->SUPER::new($param);
    $self->{'default_linker'} = C4::Linker::Default->new($param);
    bless $self, $class;
    return $self;
}

sub get_link {
    my $self    = shift;
    my $heading = shift;
    return $self->{'default_linker'}->get_link( $heading, 'last' );
}

sub update_cache {
    my $self        = shift;
    my $heading     = shift;
    my $authid      = shift;
    $self->{'default_linker'}->update_cache( $heading, $authid );
}

sub flip_heading {
    my $self    = shift;
    my $heading = shift;

    return $self->{'default_linker'}->flip($heading);
}

1;
__END__

=head1 NAME

C4::Linker::LastMatch - match against the last authority record

=cut
