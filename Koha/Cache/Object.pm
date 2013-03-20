package Koha::Cache::Object;

# Copyright 2013 C & P Bibliography Services
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

Koha::Cache::Object - Tie-able class for caching objects

=head1 SYNOPSIS

    my $cache = Koha::Cache->new();
    my $scalar = Koha::Cache->create_scalar(
        {
            'key'         => 'whatever',
            'timeout'     => 2,
            'constructor' => sub { return 'stuff'; },
        }
    );
    my %hash = Koha::Cache->create_hash(
        {
            'key'         => 'whateverelse',
            'timeout'     => 2,
            'constructor' => sub { return { 'stuff' => 'nonsense' }; },
        }
    );

=head1 DESCRIPTION

Do not use this class directly. It is tied to variables by Koha::Cache
for transparent cache access. If you choose to ignore this warning, you
should be aware that it is disturbingly polymorphic and supports both
scalars and hashes, with arrays a potential future addition.

=head1 TIE METHODS

=cut

use strict;
use warnings;
use Carp;

use base qw(Class::Accessor);

__PACKAGE__->mk_ro_accessors(
    qw( allowupdate arguments cache cache_type constructor destructor inprocess key lastupdate timeout unset value )
);

# General/SCALAR routines

sub TIESCALAR {
    my ( $class, $self ) = @_;

    $self->{'datatype'}  ||= 'SCALAR';
    $self->{'arguments'} ||= [];
    if ( defined $self->{'preload'} ) {
        $self->{'value'} = &{ $self->{'preload'} }( @{ $self->{'arguments'} } );
        if ( defined( $self->{'cache'} ) ) {
            $self->{'cache'}->set_in_cache( $self->{'key'}, $self->{'value'},
                $self->{'timeout'}, $self->{'cache_type'} . '_cache' );
        }
        $self->{'lastupdate'} = time;
    }
    return bless $self, $class;
}

sub FETCH {
    my ( $self, $index ) = @_;

    $ENV{DEBUG}
      && $index
      && carp "Retrieving cached hash member $index of $self->{'key'}";

    my $now = time;

    if ( !( $self->{'inprocess'} && defined( $self->{'value'} ) )
        && $self->{'cache'} )
    {
        $self->{'value'} =
          $self->{'cache'}
          ->get_from_cache( $self->{'key'}, $self->{'cache_type'} . '_cache' );
        $self->{'lastupdate'} = $now;
    }

    if (   !defined $self->{'value'}
        || ( defined $index && !exists $self->{'value'}->{$index} )
        || !defined $self->{'lastupdate'}
        || ( $now - $self->{'lastupdate'} > $self->{'timeout'} ) )
    {
        $self->{'value'} =
          &{ $self->{'constructor'} }( @{ $self->{'arguments'} },
            $self->{'value'}, $index );
        if ( defined( $self->{'cache'} ) ) {
            $self->{'cache'}->set_in_cache( $self->{'key'}, $self->{'value'},
                $self->{'timeout'}, $self->{'cache_type'} . '_cache' );
        }
        $self->{'lastupdate'} = $now;
    }
    if ( $self->{'datatype'} eq 'HASH' && defined $index ) {
        return $self->{'value'}->{$index};
    }
    return $self->{'value'};
}

sub STORE {
    my $value = pop @_;
    my ( $self, $index ) = @_;

    if ( $self->{'datatype'} eq 'HASH' && defined($index) ) {
        $self->{'value'}->{$index} = $value;
    }
    else {
        $self->{'value'} = $value;
    }
    if (   defined( $self->{'allowupdate'} )
        && $self->{'allowupdate'}
        && defined( $self->{'cache'} ) )
    {
        $self->{'cache'}
          ->set_in_cache( $self->{'key'}, $self->{'value'}, $self->{'timeout'},
            $self->{'cache_type'} . '_cache' );
    }

    return $self->{'value'};
}

sub DESTROY {
    my ($self) = @_;

    if ( defined( $self->{'destructor'} ) ) {
        &{ $self->{'destructor'} }( @{ $self->{'arguments'} } );
    }

    if (   defined( $self->{'unset'} )
        && $self->{'unset'}
        && defined( $self->{'cache'} ) )
    {
        $self->{'cache'}->clear_from_cache( $self->{'key'},
            $self->{'cache_type'} . '_cache' );
    }

    undef $self->{'value'};

    return $self;
}

# HASH-specific routines

sub TIEHASH {
    my ( $class, $self, @args ) = @_;
    $self->{'datatype'} = 'HASH';
    return TIESCALAR( $class, $self, @args );
}

sub DELETE {
    my ( $self, $index ) = @_;
    delete $self->{'value'}->{$index};
    return $self->STORE( $self->{'value'} );
}

sub EXISTS {
    my ( $self, $index ) = @_;
    $self->FETCH($index);
    return exists $self->{'value'}->{$index};
}

sub FIRSTKEY {
    my ($self) = @_;
    $self->FETCH;
    $self->{'iterator'} = [ keys %{ $self->{'value'} } ];
    return $self->NEXTKEY;
}

sub NEXTKEY {
    my ($self) = @_;
    return shift @{ $self->{'iterator'} };
}

sub SCALAR {
    my ($self) = @_;
    $self->FETCH;
    return scalar %{ $self->{'value'} }
      if ( ref( $self->{'value'} ) eq 'HASH' );
    return;
}

sub CLEAR {
    my ($self) = @_;
    return $self->DESTROY;
}

# ARRAY-specific routines

=head1 SEE ALSO

Koha::Cache, tie, perltie

=head1 AUTHOR

Jared Camins-Esakov, E<lt>jcamins@cpbibliography.comE<gt>

=cut

1;

__END__
