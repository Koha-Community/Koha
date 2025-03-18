package C4::Linker::FirstMatch;

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
use C4::Heading;
use C4::Linker::Default;    # Use Default for flipping

use base qw(C4::Linker);

=head1 Functions

=cut

=head2 new

Missing POD for new.

=cut

sub new {
    my $class = shift;
    my $param = shift;

    my $self = $class->SUPER::new($param);
    $self->{'default_linker'} = C4::Linker::Default->new($param);
    bless $self, $class;
    return $self;
}

=head2 get_link

Missing POD for get_link.

=cut

sub get_link {
    my $self    = shift;
    my $heading = shift;
    return $self->{'default_linker'}->get_link( $heading, 'first' );
}

=head2 update_cache

Missing POD for update_cache.

=cut

sub update_cache {
    my $self    = shift;
    my $heading = shift;
    my $authid  = shift;
    $self->{'default_linker'}->update_cache( $heading, $authid );
}

=head2 flip_heading

Missing POD for flip_heading.

=cut

sub flip_heading {
    my $self    = shift;
    my $heading = shift;

    return $self->{'default_linker'}->flip($heading);
}

1;
__END__

=head1 NAME

C4::Linker::FirstMatch - match against the first authority record

=cut
