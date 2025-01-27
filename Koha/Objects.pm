package Koha::Objects;

# Copyright ByWater Solutions 2014
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

use Modern::Perl;

use Carp            qw( carp );
use List::MoreUtils qw( none );
use Class::Inspector;

use Koha::Database;
use Koha::Exceptions::Object;

=head1 NAME

Koha::Objects - Koha Object set base class

=head1 SYNOPSIS

    use Koha::Objects;
    my $objects = Koha::Objects->search({ borrowernumber => $borrowernumber});

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

It returns undef if no results were found

my $object = Koha::Objects->find( { col1 => $val1, col2 => $val2 } );
my $object = Koha::Objects->find( $id );
my $object = Koha::Objects->find( $idpart1, $idpart2, $attrs ); # composite PK

=cut

sub find {
    my ( $self, @pars ) = @_;

    my $object;

    unless ( !@pars || none { defined($_) } @pars ) {
        my $result = $self->_resultset()->find(@pars);
        if ($result) {
            $object = $self->object_class()->_new_from_dbic($result);
        }
    }

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

=head3 search

    # scalar context
    my $objects = Koha::Objects->search([$params, $attributes]);
    while (my $object = $objects->next) {
        do_stuff($object);
    }

This B<instantiates> the I<Koha::Objects> class, and generates a resultset
based on the query I<$params> and I<$attributes> that are passed (like in DBIC).

=cut

sub search {
    my ( $self, $params, $attributes ) = @_;

    my $class = ref($self) ? ref($self) : $self;
    my $rs    = $self->_resultset()->search( $params, $attributes );

    return $class->_new_from_dbic($rs);
}

=head3 search_related

    my $objects = Koha::Objects->search_related( $rel_name, $cond?, \%attrs? );

Searches the specified relationship, optionally specifying a condition and attributes for matching records.

=cut

sub search_related {
    my ( $self, $rel_name, @params ) = @_;

    return if !$rel_name;

    my $rs = $self->_resultset()->search_related( $rel_name, @params );
    return if !$rs;
    my $object_class = _get_objects_class( $rs->result_class );

    eval "require $object_class";
    return _new_from_dbic( $object_class, $rs );
}

=head3 delete

=cut

sub delete {
    my ( $self, $params ) = @_;

    if ( Class::Inspector->function_exists( $self->object_class, 'delete' ) ) {
        my $objects_deleted;
        $self->_resultset->result_source->schema->txn_do(
            sub {
                $self->reset;    # If we iterated already over the set
                while ( my $o = $self->next ) {
                    $o->delete($params);
                    $objects_deleted++;
                }
            }
        );
        return $objects_deleted;
    }

    return $self->_resultset->delete;
}

=head3 update

    my $objects = Koha::Objects->new; # or Koha::Objects->search
    $objects->update( $fields, [ { no_triggers => 0/1 } ] );

This method overloads the DBIC inherited one so if code-level triggers exist
(through the use of an overloaded I<update> or I<store> method in the Koha::Object
based class) those are called in a loop on the resultset.

If B<no_triggers> is passed and I<true>, then the DBIC update method is called
directly. This feature is important for performance, in cases where no code-level
triggers should be triggered. The developer will explicitly ask for this and QA should
catch wrong uses as well.

=cut

sub update {
    my ( $self, $fields, $options ) = @_;

    Koha::Exceptions::Object::NotInstantiated->throw(
        method => 'update',
        class  => $self
    ) unless ref $self;

    my $no_triggers = $options->{no_triggers};

    if (
        !$no_triggers
        && (   Class::Inspector->function_exists( $self->object_class, 'update' )
            or Class::Inspector->function_exists( $self->object_class, 'store' ) )
        )
    {
        my $objects_updated;
        $self->_resultset->result_source->schema->txn_do(
            sub {
                while ( my $o = $self->next ) {
                    $o->update($fields);
                    $objects_updated++;
                }
            }
        );
        return $objects_updated;
    }

    return $self->_resultset->update($fields);
}

=head3 filter_by_last_update

    my $filtered_objects = $objects->filter_by_last_update({
        from => $from_datetime, to => $to_datetime,
        days|older_than => $days, min_days => $days, younger_than => $days,
    });

You should pass at least one of the parameters: from, to, days|older_than,
min_days or younger_than. Make sure that they do not conflict with each other
to get meaningful results.
Note: from, to and min_days are inclusive! And by nature days|older_than
and younger_than are exclusive.

The from and to parameters must be DateTime objects.

=cut

sub filter_by_last_update {
    my ( $self, $params ) = @_;
    my $timestamp_column_name = $params->{timestamp_column_name} || 'timestamp';
    my $conditions;
    Koha::Exceptions::MissingParameter->throw("Please pass: days|from|to|older_than|younger_than")
        unless grep { exists $params->{$_} } qw/days from to older_than younger_than min_days/;

    foreach my $key (qw(from to)) {
        if ( exists $params->{$key} and ref $params->{$key} ne 'DateTime' ) {
            Koha::Exceptions::WrongParameter->throw("'$key' parameter must be a DateTime object");
        }
    }

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    foreach my $p (qw/days older_than younger_than min_days/) {
        next if !exists $params->{$p};
        my $days     = $params->{$p};
        my $operator = { days => '<', older_than => '<', min_days => '<=' }->{$p} // '>';
        $conditions->{$operator} = \[ 'DATE_SUB(CURDATE(), INTERVAL ? DAY)', $days ];
    }
    if ( exists $params->{from} ) {
        $conditions->{'>='} = $dtf->format_datetime( $params->{from} );
    }
    if ( exists $params->{to} ) {
        $conditions->{'<='} = $dtf->format_datetime( $params->{to} );
    }

    return $self->search( { $timestamp_column_name => $conditions } );
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
    my ($self) = @_;

    my $result = $self->_resultset()->next();
    return unless $result;

    my $object = $self->object_class()->_new_from_dbic($result);

    return $object;
}

=head3 Koha::Objects->last;

my $object = Koha::Objects->last;

Returns the last object that is part of this set.
Returns undef if there are no object to return.

=cut

sub last {
    my ($self) = @_;

    my $count = $self->_resultset->count;
    return unless $count;

    my ($result) = $self->_resultset->slice( $count - 1, $count - 1 );

    my $object = $self->object_class()->_new_from_dbic($result);

    return $object;
}

=head3 empty

    my $empty_rs = Koha::Objects->new->empty;

Sets the resultset empty. This is handy for consistency on method returns
(e.g. if we know in advance we won't have results but want to keep returning
an iterator).

=cut

sub empty {
    my ($self) = @_;

    Koha::Exceptions::Object::NotInstantiated->throw(
        method => 'empty',
        class  => $self
    ) unless ref $self;

    $self = $self->search( \'0 = 1' );
    $self->_resultset()->set_cache( [] );

    return $self;
}

=head3 Koha::Objects->reset();

Koha::Objects->reset();

resets iteration so the next call to next() will start agein
with the first object in a set.

=cut

sub reset {
    my ($self) = @_;

    $self->_resultset()->reset();

    return $self;
}

=head3 Koha::Objects->as_list();

Koha::Objects->as_list();

Returns an arrayref of the objects in this set.

=cut

sub as_list {
    my ($self) = @_;

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
    my ( $self, $column_name ) = @_;
    return $self->_resultset->get_column($column_name)->all;
}

=head3 Koha::Objects->TO_JSON

Returns an unblessed representation of objects, suitable for JSON output.

=cut

sub TO_JSON {
    my ($self) = @_;

    return [ map { $_->TO_JSON } $self->as_list ];
}

=head3 Koha::Objects->to_api

Returns a representation of the objects, suitable for API output .

=cut

sub to_api {
    my ( $self, $params ) = @_;

    return [ map { $_->to_api($params) } $self->as_list ];
}

=head3 attributes_from_api

    my $attributes = $objects->attributes_from_api( $api_attributes );

Translates attributes from the API to DBIC

=cut

sub attributes_from_api {
    my ( $self, $attributes ) = @_;

    $self->{_singular_object} ||= $self->object_class->new();
    return $self->{_singular_object}->attributes_from_api($attributes);
}

=head3 from_api_mapping

    my $mapped_attributes_hash = $objects->from_api_mapping;

Attributes map from the API to DBIC

=cut

sub from_api_mapping {
    my ($self) = @_;

    $self->{_singular_object} ||= $self->object_class->new();
    return $self->{_singular_object}->from_api_mapping;
}

=head3 prefetch_whitelist

    my $whitelist = $object->prefetch_whitelist()

Returns a hash of prefetchable subs and the type it returns

=cut

sub prefetch_whitelist {
    my ($self) = @_;

    $self->{_singular_object} ||= $self->object_class->new();

    $self->{_singular_object}->prefetch_whitelist;
}

=head3 Koha::Objects->_wrap

wraps the DBIC object in a corresponding Koha object

=cut

sub _wrap {
    my ( $self, @dbic_rows ) = @_;

    my @objects = map { $self->object_class->_new_from_dbic($_) } @dbic_rows;

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
    } else {
        return Koha::Database->new()->schema()->resultset( $self->_type() );
    }
}

sub _get_objects_class {
    my ($type) = @_;
    return unless $type;

    if ( $type->can('koha_objects_class') ) {
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
    my ($class) = @_;
    return Koha::Database->new->schema->resultset( $class->_type )->result_source->columns;
}

=head3 AUTOLOAD

The autoload method is used call DBIx::Class method on a resultset.

Important: If you plan to use one of the DBIx::Class methods you must provide
relevant tests in t/db_dependent/Koha/Objects.t
Currently count, is_paged, pager, result_class, single and slice are covered.

=cut

sub AUTOLOAD {
    my ( $self, @params ) = @_;

    my @known_methods = qw( count is_paged pager result_class single slice );
    my $method        = our $AUTOLOAD;
    $method =~ s/.*:://;

    unless ( grep { $_ eq $method } @known_methods ) {
        my $class = ref($self) ? ref($self) : $self;
        Koha::Exceptions::Object::MethodNotCoveredByTests->throw(
            error      => sprintf( "The method %s->%s is not covered by tests!", $class, $method ),
            show_trace => 1
        );
    }

    my $r = eval { $self->_resultset->$method(@params) };
    if ($@) {
        carp "No method $method found for " . ref($self) . " " . $@;
        return;
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
