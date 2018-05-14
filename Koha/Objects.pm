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

use Modern::Perl;

use Carp;
use List::MoreUtils qw( none );

use Koha::Database;

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

my $object = Koha::Objects->new();

=cut

sub new {
    my ($class) = @_;
    my $self = {};

    bless( $self, $class );
}

=head3 Koha::Objects->_new_from_dbic();

my $object = Koha::Objects->_new_from_dbic( $resultset );

=cut

sub _new_from_dbic {
    my ( $class, $resultset ) = @_;
    my $self = { _resultset => $resultset };

    bless( $self, $class );
}

=head3 Koha::Objects->find();

Similar to DBIx::Class::ResultSet->find this method accepts:
    \%columns_values | @pk_values, { key => $unique_constraint, %attrs }?
Strictly speaking, columns_values should only refer to columns under an
unique constraint.

my $object = Koha::Objects->find( { col1 => $val1, col2 => $val2 } );
my $object = Koha::Objects->find( $id );
my $object = Koha::Objects->find( $idpart1, $idpart2, $attrs ); # composite PK

=cut

sub find {
    my ( $self, @pars ) = @_;

    croak 'Cannot use "->find" in list context' if wantarray;

    return if !@pars || none { defined($_) } @pars;

    my $result = $self->_resultset()->find( @pars );

    return unless $result;

    my $object = $self->object_class()->_new_from_dbic( $result );

    return $object;
}

=head3 Koha::Objects->find_or_create();

my $object = Koha::Objects->find_or_create( $attrs );

=cut

sub find_or_create {
    my ( $self, $params ) = @_;

    my $result = $self->_resultset->find_or_create($params);

    return unless $result;

    my $object = $self->object_class->_new_from_dbic($result);

    return $object;
}

=head3 Koha::Objects->search();

my @objects = Koha::Objects->search($params);

=cut

sub search {
    my ( $self, $params, $attributes ) = @_;

    if (wantarray) {
        my @dbic_rows = $self->_resultset()->search($params, $attributes);

        return $self->_wrap(@dbic_rows);

    }
    else {
        my $class = ref($self) ? ref($self) : $self;
        my $rs = $self->_resultset()->search($params, $attributes);

        return $class->_new_from_dbic($rs);
    }
}

=head3 search_related

    my @objects = Koha::Objects->search_related( $rel_name, $cond?, \%attrs? );
    my $objects = Koha::Objects->search_related( $rel_name, $cond?, \%attrs? );

Searches the specified relationship, optionally specifying a condition and attributes for matching records.

=cut

sub search_related {
    my ( $self, $rel_name, @params ) = @_;

    return if !$rel_name;
    if (wantarray) {
        my @dbic_rows = $self->_resultset()->search_related($rel_name, @params);
        return if !@dbic_rows;
        my $object_class = _get_objects_class( $dbic_rows[0]->result_class );

        eval "require $object_class";
        return _wrap( $object_class, @dbic_rows );

    } else {
        my $rs = $self->_resultset()->search_related($rel_name, @params);
        return if !$rs;
        my $object_class = _get_objects_class( $rs->result_class );

        eval "require $object_class";
        return _new_from_dbic( $object_class, $rs );
    }
}

=head3 single

my $object = Koha::Objects->search({}, { rows => 1 })->single

Returns one and only one object that is part of this set.
Returns undef if there are no objects found.

This is optimal as it will grab the first returned result without instantiating
a cursor.

See:
http://search.cpan.org/dist/DBIx-Class/lib/DBIx/Class/Manual/Cookbook.pod#Retrieve_one_and_only_one_row_from_a_resultset

=cut

sub single {
    my ($self) = @_;

    my $single = $self->_resultset()->single;
    return unless $single;

    return $self->object_class()->_new_from_dbic($single);
}

=head3 Koha::Objects->next();

my $object = Koha::Objects->next();

Returns the next object that is part of this set.
Returns undef if there are no more objects to return.

=cut

sub next {
    my ( $self ) = @_;

    my $result = $self->_resultset()->next();
    return unless $result;

    my $object = $self->object_class()->_new_from_dbic( $result );

    return $object;
}

=head3 Koha::Objects->last;

my $object = Koha::Objects->last;

Returns the last object that is part of this set.
Returns undef if there are no object to return.

=cut

sub last {
    my ( $self ) = @_;

    my $count = $self->_resultset->count;
    return unless $count;

    my ( $result ) = $self->_resultset->slice($count - 1, $count - 1);

    my $object = $self->object_class()->_new_from_dbic( $result );

    return $object;
}



=head3 Koha::Objects->reset();

Koha::Objects->reset();

resets iteration so the next call to next() will start agein
with the first object in a set.

=cut

sub reset {
    my ( $self ) = @_;

    $self->_resultset()->reset();

    return $self;
}

=head3 Koha::Objects->as_list();

Koha::Objects->as_list();

Returns an arrayref of the objects in this set.

=cut

sub as_list {
    my ( $self ) = @_;

    my @dbic_rows = $self->_resultset()->all();

    my @objects = $self->_wrap(@dbic_rows);

    return wantarray ? @objects : \@objects;
}

=head3 Koha::Objects->unblessed

Returns an unblessed representation of objects.

=cut

sub unblessed {
    my ($self) = @_;

    return [ map { $_->unblessed } $self->as_list ];
}

=head3 Koha::Objects->get_column

Return all the values of this set for a given column

=cut

sub get_column {
    my ($self, $column_name) = @_;
    return $self->_resultset->get_column( $column_name )->all;
}

=head3 Koha::Objects->TO_JSON

Returns an unblessed representation of objects, suitable for JSON output.

=cut

sub TO_JSON {
    my ($self) = @_;

    return [ map { $_->TO_JSON } $self->as_list ];
}

=head3 Koha::Objects->_wrap

wraps the DBIC object in a corresponding Koha object

=cut

sub _wrap {
    my ( $self, @dbic_rows ) = @_;

    my @objects = map { $self->object_class->_new_from_dbic( $_ ) } @dbic_rows;

    return @objects;
}

=head3 Koha::Objects->_resultset

Returns the internal resultset or creates it if undefined

=cut

sub _resultset {
    my ($self) = @_;

    if ( ref($self) ) {
        $self->{_resultset} ||=
          Koha::Database->new()->schema()->resultset( $self->_type() );

        return $self->{_resultset};
    }
    else {
        return Koha::Database->new()->schema()->resultset( $self->_type() );
    }
}

sub _get_objects_class {
    my ( $type ) = @_;
    return unless $type;

    if( $type->can('koha_objects_class') ) {
        return $type->koha_objects_class;
    }
    $type =~ s|Schema::Result::||;
    return "${type}s";
}

=head3 columns

my @columns = Koha::Objects->columns

Return the table columns

=cut

sub columns {
    my ( $class ) = @_;
    return Koha::Database->new->schema->resultset( $class->_type )->result_source->columns;
}

=head3 AUTOLOAD

The autoload method is used call DBIx::Class method on a resultset.

Important: If you plan to use one of the DBIx::Class methods you must provide
relevant tests in t/db_dependent/Koha/Objects.t
Currently count, pager, update and delete are covered.

=cut

sub AUTOLOAD {
    my ( $self, @params ) = @_;

    my @known_methods = qw( count is_paged pager update delete result_class single slice );
    my $method = our $AUTOLOAD;
    $method =~ s/.*:://;


    unless ( grep { /^$method$/ } @known_methods ) {
        my $class = ref($self) ? ref($self) : $self;
        Koha::Exceptions::Object::MethodNotCoveredByTests->throw(
            error      => sprintf("The method %s->%s is not covered by tests!", $class, $method),
            show_trace => 1
        );
    }

    my $r = eval { $self->_resultset->$method(@params) };
    if ( $@ ) {
        carp "No method $method found for " . ref($self) . " " . $@;
        return
    }
    return $r;
}

=head3 _type

The _type method must be set for all child classes.
The value returned by it should be the DBIC resultset name.
For example, for holds, _type should return 'Reserve'.

=cut

sub _type { }

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
