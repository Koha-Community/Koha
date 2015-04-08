package C4::Linker;

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

=head1 NAME

C4::Linker - Base class for linking authorities to bibliographic records

=head1 SYNOPSIS

  use C4::Linker (%params );

=head1 DESCRIPTION

Base class for C4::Linker::X. Subclasses need to provide the following methods

B<get_link ($field)> - return the authid for the authority that should be
linked to the provided MARC::Field object, and a boolean to indicate whether
the match is "fuzzy" (the semantics of "fuzzy" are up to the individual plugin).
In order to handle authority limits, get_link should always end with:
    return $self->SUPER::_handle_auth_limit($authid), $fuzzy;

B<update_cache ($heading, $authid)> - updates internal linker cache for
$heading with $authid of a new created authotiry record

B<flip_heading ($field)> - return a MARC::Field object with the heading flipped
to the preferred form.

=head1 FUNCTIONS

=cut

use strict;
use warnings;
use Carp;
use C4::Context;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( ));

sub new {
    my $class = shift;
    my $param = shift;

    my $self = {};

    while ( my ( $key, $value ) = each %$param ) {
        if ( $key eq 'auth_limit' && $value ) {
            my $dbh = C4::Context->dbh;
            my $sql =
              "SELECT authid FROM auth_header WHERE $value ORDER BY authid ASC";
            my $sth = $dbh->prepare($sql);
            $sth->execute();
            while ( my ($authid) = $sth->fetchrow_array() ) {
                push @{ $self->{'auths_to_link'} }, $authid;
            }
        }
        elsif ( $key eq 'options' && $value ) {
            foreach my $opt ( split( /\|/, $value ) ) {
                $self->{$opt} = 1;
            }
        }
        elsif ($value) {
            $self->{$key} = $value;
        }
    }

    bless $self, $class;
    return $self;
}

=head2 _handle_auth_limit

    return $self->SUPER::_handle_auth_limit($authid), $fuzzy;

Function to be called by subclasses to handle authority record limits.

=cut

sub _handle_auth_limit {
    my $self   = shift;
    my $authid = shift;

    if ( defined $self->{'auths_to_link'} && defined $authid && !grep { $_ == $authid }
        @{ $self->{'auths_to_link'} } )
    {
        undef $authid;
    }
    return $authid;
}

=head2 EXPORT

None by default.

=head1 SEE ALSO

C4::Linker::Default

=head1 AUTHOR

Jared Camins-Esakov, C & P Bibliography Services, E<lt>jcamins@cpbibliography.comE<gt>

=cut

1;

__END__
