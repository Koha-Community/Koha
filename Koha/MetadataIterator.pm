package Koha::MetadataIterator;

# This contains an iterator over biblio and authority records

# Copyright 2014 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::MetadataIterator - iterates over records

=head1 DESCRIPTION

This provides a fairly generic iterator that will return records provided
by a function.

=head1 SYNOPSIS

    use Koha::MetadataIterator;
    my $next_func = sub {
        # something that'll return each record
    };
    my $iterator = Koha::MetadataIterator->new($next_func);
    while ( my $record = $iterator->next() ) {
        # do something with $record
    }

=head1 METHODS

=cut

use Modern::Perl;

=head2 new

    my $it = new($next_func);

Takes a function that will provide the next bit of data.

=cut

sub new {
    my ( $class, $next_func ) = @_;

    bless { next_func => $next_func, }, $class;
}

=head2 next()

Provides the next record.

=cut

sub next {
    my ($self) = @_;

    return $self->{next_func}->();
}

1;
