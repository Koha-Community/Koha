package Koha::Objects;

# Copyright ByWater Solutions 2014
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

use overload "0+" => "count", "<>" => "next", fallback => 1;

use Modern::Perl;

use Carp;

use Koha::Database;

our $type;

=head1 NAME

Koha::Objects - Koha Object set base class

=head1 SYNOPSIS

    use Koha::Objects;
    my @objects = Koha::Objects->search({ borrowernumber => $borrowernumber});

=head1 DESCRIPTION

This class must be subclassed.

=head1 API

=head2 Class Methods

=cut

=head3 Koha::Objects->new();

my $object = Koha::Object->new();

=cut

sub new {
    my ($class) = @_;
    my $self = {};

    bless( $self, $class );
}

=head3 Koha::Objects->new_from_dbic();

my $object = Koha::Object->new_from_dbic( $resultset );

=cut

sub new_from_dbic {
    my ( $class, $resultset ) = @_;
    my $self = { _resultset => $resultset };

    bless( $self, $class );
}

=head3 Koha::Objects->find();

my $object = Koha::Object->find($id);
my $object = Koha::Object->find( { keypart1 => $keypart1, keypart2 => $keypart2 } );

=cut

sub find {
    my ( $self, $id ) = @_;

    my $result = $self->_resultset()->find($id);

    my $object = $self->object_class()->new_from_dbic( $result );

    return $object;
}

=head3 Koha::Objects->search();

my @objects = Koha::Object->search($params);

=cut

sub search {
    my ( $self, $params ) = @_;

    if (wantarray) {
        my @dbic_rows = $self->_resultset()->search($params);

        return $self->_wrap(@dbic_rows);

    }
    else {
        my $class = ref( $self );
        my $rs = $self->_resultset()->search($params);

        return $class->new_from_dbic($rs);
    }
}

=head3 Koha::Objects->count();

my @objects = Koha::Object->count($params);

=cut

sub count {
    my ( $self, $params ) = @_;

    return $self->_resultset()->count($params);
}

=head3 Koha::Objects->next();

my $object = Koha::Object->next();

Returns the next object that is part of this set.
Returns undef if there are no more objects to return.

=cut

sub next {
    my ( $self, $id ) = @_;

    my $result = $self->_resultset()->next();
    return unless $result;

    my $object = $self->object_class()->new_from_dbic( $result );

    return $object;
}

=head3 Koha::Objects->reset();

Koha::Objects->reset();

resets iteration so the next call to next() will start agein
with the first object in a set.

=cut

sub reset {
    my ( $self, $id ) = @_;

    $self->_resultset()->reset();

    return $self;
}

=head3 Koha::Objects->as_list();

Koha::Objects->as_list();

Returns an arrayref of the objects in this set.

=cut

sub as_list {
    my ( $self, $id ) = @_;

    my @dbic_rows = $self->_resultset()->all();

    my @objects = $self->_wrap(@dbic_rows);

    return wantarray ? @objects : \@objects;
}

=head3 Koha::Objects->_wrap

wraps the DBIC object in a corrosponding Koha object

=cut

sub _wrap {
    my ( $self, @dbic_rows ) = @_;

    my @objects = map { $self->object_class()->new_from_dbic( $_ ) } @dbic_rows;

    return @objects;
}

=head3 Koha::Objects->_resultset

Returns the internal resultset or creates it if undefined

=cut

sub _resultset {
    my ($self) = @_;

    $self->{_resultset} ||=
      Koha::Database->new()->schema()->resultset( $self->type() );

    $self->{_resultset};
}

=head3 type

The type method must be set for all child classes.
The value returned by it should be the DBIC resultset name.
For example, for holds, type should return 'Reserve'.

=cut

sub type { }

=head3 object_class

This method must be set for all child classes.
The value returned by it should be the name of the Koha
object class that is returned by this class.
For example, for holds, object_class should return 'Koha::Hold'.

=cut

sub object_class { }

sub DESTROY { }

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
