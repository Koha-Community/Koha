package Koha::Object;

# Copyright ByWater Solutions 2014
# Copyright 2016 Koha Development Team
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

use Carp qw( croak );
use Mojo::JSON;
use Scalar::Util qw( blessed looks_like_number );
use Try::Tiny qw( catch try );
use List::MoreUtils qw( any );

use Koha::Database;
use Koha::Exceptions::Object;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Object::Message;

=head1 NAME

Koha::Object - Koha Object base class

=head1 SYNOPSIS

    use Koha::Object;
    my $object = Koha::Object->new({ property1 => $property1, property2 => $property2, etc... } );

=head1 DESCRIPTION

This class must always be subclassed.

=head1 API

=head2 Class Methods

=cut

=head3 Koha::Object->new();

my $object = Koha::Object->new();
my $object = Koha::Object->new($attributes);

Note that this cannot be used to retrieve record from the DB.

=cut

sub new {
    my ( $class, $attributes ) = @_;
    my $self = {};

    if ($attributes) {
        my $schema = Koha::Database->new->schema;

        # Remove the arguments which exist, are not defined but NOT NULL to use the default value
        my $columns_info = $schema->resultset( $class->_type )->result_source->columns_info;
        for my $column_name ( keys %$attributes ) {
            my $c_info = $columns_info->{$column_name};
            next if $c_info->{is_nullable};
            next if not exists $attributes->{$column_name} or defined $attributes->{$column_name};
            delete $attributes->{$column_name};
        }

        $self->{_result} =
          $schema->resultset( $class->_type() )->new($attributes);
    }

    $self->{_messages} = [];

    croak("No _type found! Koha::Object must be subclassed!")
      unless $class->_type();

    bless( $self, $class );

}

=head3 Koha::Object->_new_from_dbic();

my $object = Koha::Object->_new_from_dbic($dbic_row);

=cut

sub _new_from_dbic {
    my ( $class, $dbic_row ) = @_;
    my $self = {};

    # DBIC result row
    $self->{_result} = $dbic_row;

    croak("No _type found! Koha::Object must be subclassed!")
      unless $class->_type();

    croak( "DBIC result _type " . ref( $self->{_result} ) . " isn't of the _type " . $class->_type() )
      unless ref( $self->{_result} ) eq "Koha::Schema::Result::" . $class->_type();

    bless( $self, $class );

}

=head3 $object->store();

Saves the object in storage.
If the object is new, it will be created.
If the object previously existed, it will be updated.

Returns:
    $self  if the store was a success
    undef  if the store failed

=cut

sub store {
    my ($self) = @_;

    my $columns_info = $self->_result->result_source->columns_info;

    # Handle not null and default values for integers and dates
    foreach my $col ( keys %{$columns_info} ) {
        # Integers
        if (   _numeric_column_type( $columns_info->{$col}->{data_type} )
            or _decimal_column_type( $columns_info->{$col}->{data_type} )
        ) {
            # Has been passed but not a number, usually an empty string
            my $value = $self->_result()->get_column($col);
            if ( defined $value and not looks_like_number( $value ) ) {
                if ( $columns_info->{$col}->{is_nullable} ) {
                    # If nullable, default to null
                    $self->_result()->set_column($col => undef);
                } else {
                    # If cannot be null, get the default value
                    # What if cannot be null and does not have a default value? Possible?
                    $self->_result()->set_column($col => $columns_info->{$col}->{default_value});
                }
            }
        }
        elsif ( _date_or_datetime_column_type( $columns_info->{$col}->{data_type} ) ) {
            # Set to null if an empty string (or == 0 but should not happen)
            my $value = $self->_result()->get_column($col);
            if ( defined $value and not $value ) {
                if ( $columns_info->{$col}->{is_nullable} ) {
                    $self->_result()->set_column($col => undef);
                } else {
                    $self->_result()->set_column($col => $columns_info->{$col}->{default_value});
                }
            }
            elsif ( not defined $self->$col
                  && $columns_info->{$col}->{datetime_undef_if_invalid} )
              {
                  # timestamp
                  $self->_result()->set_column($col => $columns_info->{$col}->{default_value});
              }
        }
    }

    try {
        return $self->_result()->update_or_insert() ? $self : undef;
    }
    catch {
        # Catch problems and raise relevant exceptions
        if (ref($_) eq 'DBIx::Class::Exception') {
            warn $_->{msg};
            if ( $_->{msg} =~ /Cannot add or update a child row: a foreign key constraint fails/ ) {
                # FK constraints
                # FIXME: MySQL error, if we support more DB engines we should implement this for each
                if ( $_->{msg} =~ /FOREIGN KEY \(`(?<column>.*?)`\)/ ) {
                    Koha::Exceptions::Object::FKConstraint->throw(
                        error     => 'Broken FK constraint',
                        broken_fk => $+{column}
                    );
                }
            }
            elsif( $_->{msg} =~ /Duplicate entry '(.*?)' for key '(?<key>.*?)'/ ) {
                Koha::Exceptions::Object::DuplicateID->throw(
                    error => 'Duplicate ID',
                    duplicate_id => $+{key}
                );
            }
            elsif( $_->{msg} =~ /Incorrect (?<type>\w+) value: '(?<value>.*)' for column \W?(?<property>\S+)/ ) { # The optional \W in the regex might be a quote or backtick
                my $type = $+{type};
                my $value = $+{value};
                my $property = $+{property};
                $property =~ s/['`]//g;
                Koha::Exceptions::Object::BadValue->throw(
                    type     => $type,
                    value    => $value,
                    property => $property =~ /(\w+\.\w+)$/ ? $1 : $property, # results in table.column without quotes or backtics
                );
            }
        }
        # Catch-all for foreign key breakages. It will help find other use cases
        $_->rethrow();
    }
}

=head3 $object->update();

A shortcut for set + store in one call.

=cut

sub update {
    my ($self, $values) = @_;
    Koha::Exceptions::Object::NotInStorage->throw unless $self->in_storage;
    $self->set($values)->store();
}

=head3 $object->delete();

Removes the object from storage.

Returns:
    The item object if deletion was a success
    The DBIX::Class error if deletion failed

=cut

sub delete {
    my ($self) = @_;

    my $deleted = $self->_result()->delete;
    if ( ref $deleted ) {
        my $object_class  = Koha::Object::_get_object_class( $self->_result->result_class );
        $deleted = $object_class->_new_from_dbic($deleted);
    }
    return $deleted;
}

=head3 $object->set( $properties_hashref )

$object->set(
    {
        property1 => $property1,
        property2 => $property2,
        property3 => $propery3,
    }
);

Enables multiple properties to be set at once

Returns:
    1      if all properties were set.
    0      if one or more properties do not exist.
    undef  if all properties exist but a different error
           prevents one or more properties from being set.

If one or more of the properties do not exist,
no properties will be set.

=cut

sub set {
    my ( $self, $properties ) = @_;

    my @columns = @{$self->_columns()};

    foreach my $p ( keys %$properties ) {
        unless ( grep { $_ eq $p } @columns ) {
            Koha::Exceptions::Object::PropertyNotFound->throw( "No property $p for " . ref($self) );
        }
    }

    return $self->_result()->set_columns($properties) ? $self : undef;
}

=head3 $object->set_or_blank( $properties_hashref )

$object->set_or_blank(
    {
        property1 => $property1,
        property2 => $property2,
        property3 => $propery3,
    }
);

If not listed in $properties_hashref, the property will be set to the default
value defined at DB level, or nulled.

=cut


sub set_or_blank {
    my ( $self, $properties ) = @_;

    my $columns_info = $self->_result->result_source->columns_info;

    foreach my $col ( keys %{$columns_info} ) {

        next if exists $properties->{$col};

        if ( $columns_info->{$col}->{is_nullable} ) {
            $properties->{$col} = undef;
        } else {
            $properties->{$col} = $columns_info->{$col}->{default_value};
        }
    }

    return $self->set($properties);
}

=head3 $object->unblessed();

Returns an unblessed representation of object.

=cut

sub unblessed {
    my ($self) = @_;

    return { $self->_result->get_columns };
}

=head3 $object->get_from_storage;

=cut

sub get_from_storage {
    my ( $self, $attrs ) = @_;
    my $stored_object = $self->_result->get_from_storage($attrs);
    return unless $stored_object;
    my $object_class  = Koha::Object::_get_object_class( $self->_result->result_class );
    return $object_class->_new_from_dbic($stored_object);
}

=head3 $object->object_messages

    my @messages = @{ $object->object_messages };

Returns the (probably non-fatal) messages that were recorded on the object.

=cut

sub object_messages {
    my ( $self ) = @_;

    $self->{_messages} = []
        unless defined $self->{_messages};

    return $self->{_messages};
}

=head3 $object->add_message

    try {
        <some action that might fail>
    }
    catch {
        if ( <fatal condition> ) {
            Koha::Exception->throw...
        }

        # This is a non fatal error, notify the caller
        $self->add_message({ message => $error, type => 'error' });
    }
    return $self;

Adds a message.

=cut

sub add_message {
    my ( $self, $params ) = @_;

    push @{ $self->{_messages} }, Koha::Object::Message->new($params);

    return $self;
}

=head3 $object->TO_JSON

Returns an unblessed representation of the object, suitable for JSON output.

=cut

sub TO_JSON {

    my ($self) = @_;

    my $unblessed    = $self->unblessed;
    my $columns_info = Koha::Database->new->schema->resultset( $self->_type )
        ->result_source->{_columns};

    foreach my $col ( keys %{$columns_info} ) {

        if ( $columns_info->{$col}->{is_boolean} )
        {    # Handle booleans gracefully
            $unblessed->{$col}
                = ( $unblessed->{$col} )
                ? Mojo::JSON->true
                : Mojo::JSON->false;
        }
        elsif ( _numeric_column_type( $columns_info->{$col}->{data_type} )
            and looks_like_number( $unblessed->{$col} )
        ) {

            # TODO: Remove once the solution for
            # https://github.com/perl5-dbi/DBD-mysql/issues/212
            # is ported to whatever distro we support by that time
            # or we move to DBD::MariaDB
            $unblessed->{$col} += 0;
        }
        elsif ( _decimal_column_type( $columns_info->{$col}->{data_type} )
            and looks_like_number( $unblessed->{$col} )
        ) {

            # TODO: Remove once the solution for
            # https://github.com/perl5-dbi/DBD-mysql/issues/212
            # is ported to whatever distro we support by that time
            # or we move to DBD::MariaDB
            $unblessed->{$col} += 0.00;
        }
        elsif ( _datetime_column_type( $columns_info->{$col}->{data_type} ) ) {
            eval {
                return unless $unblessed->{$col};
                $unblessed->{$col} = output_pref({
                    dateformat => 'rfc3339',
                    dt         => dt_from_string($unblessed->{$col}, 'sql'),
                });
            };
        }
    }
    return $unblessed;
}

sub _date_or_datetime_column_type {
    my ($column_type) = @_;

    my @dt_types = (
        'timestamp',
        'date',
        'datetime'
    );

    return ( grep { $column_type eq $_ } @dt_types) ? 1 : 0;
}
sub _datetime_column_type {
    my ($column_type) = @_;

    my @dt_types = (
        'timestamp',
        'datetime'
    );

    return ( grep { $column_type eq $_ } @dt_types) ? 1 : 0;
}

sub _numeric_column_type {
    # TODO: Remove once the solution for
    # https://github.com/perl5-dbi/DBD-mysql/issues/212
    # is ported to whatever distro we support by that time
    # or we move to DBD::MariaDB
    my ($column_type) = @_;

    my @numeric_types = (
        'bigint',
        'integer',
        'int',
        'mediumint',
        'smallint',
        'tinyint',
    );

    return ( grep { $column_type eq $_ } @numeric_types) ? 1 : 0;
}

sub _decimal_column_type {
    # TODO: Remove once the solution for
    # https://github.com/perl5-dbi/DBD-mysql/issues/212
    # is ported to whatever distro we support by that time
    # or we move to DBD::MariaDB
    my ($column_type) = @_;

    my @decimal_types = (
        'decimal',
        'double precision',
        'float'
    );

    return ( grep { $column_type eq $_ } @decimal_types) ? 1 : 0;
}

=head3 prefetch_whitelist

    my $whitelist = $object->prefetch_whitelist()

Returns a hash of prefetchable subs and the type they return.

=cut

sub prefetch_whitelist {
    my ( $self ) = @_;

    my $whitelist = {};
    my $relations = $self->_result->result_source->_relationships;

    foreach my $key (keys %{$relations}) {
        if($self->can($key)) {
            my $result_class = $relations->{$key}->{class};
            my $obj = $result_class->new;
            try {
                $whitelist->{$key} = Koha::Object::_get_object_class( $obj->result_class );
            } catch {
                $whitelist->{$key} = undef;
            }
        }
    }

    return $whitelist;
}

=head3 to_api

    my $object_for_api = $object->to_api(
        {
          [ embed => {
                items => {
                    children => {
                        holds => {,
                            children => {
                              ...
                            }
                        }
                    }
                },
                library => {
                    ...
                }
            },
            public => 0|1,
            ...
         ]
        }
    );

Returns a representation of the object, suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;
    my $json_object = $self->TO_JSON;

    # Make sure we duplicate the $params variable to avoid
    # breaking calls in a loop (Koha::Objects->to_api)
    $params = defined $params ? {%$params} : {};

    # children should be able to handle without
    my $embeds  = delete $params->{embed};
    my $strings = delete $params->{strings};

    # coded values handling
    my $string_map = {};
    if ( $strings and $self->can('strings_map') ) {
        $string_map = $self->strings_map($params);
    }

    # Remove forbidden attributes if required (including their coded values)
    if ( $params->{public} ) {
        for my $field ( keys %{$json_object} ) {
            delete $json_object->{$field}
              unless any { $_ eq $field } @{ $self->public_read_list };
        }

        if ($strings) {
            foreach my $field ( keys %{$string_map} ) {
                delete $string_map->{$field}
                  unless any { $_ eq $field } @{ $self->public_read_list };
            }
        }
    }

    my $to_api_mapping = $self->to_api_mapping;

    # Rename attributes and coded values if there's a mapping
    if ( $self->can('to_api_mapping') ) {
        foreach my $column ( keys %{ $self->to_api_mapping } ) {
            my $mapped_column = $self->to_api_mapping->{$column};
            if ( exists $json_object->{$column}
                && defined $mapped_column )
            {

                # key != undef
                $json_object->{$mapped_column} = delete $json_object->{$column};
                $string_map->{$mapped_column}  = delete $string_map->{$column}
                  if exists $string_map->{$column};

            }
            elsif ( exists $json_object->{$column}
                && !defined $mapped_column )
            {

                # key == undef
                delete $json_object->{$column};
                delete $string_map->{$column};
            }
        }
    }

    $json_object->{_strings} = $string_map
      if $strings;

    if ($embeds) {
        foreach my $embed ( keys %{$embeds} ) {
            if (    $embed =~ m/^(?<relation>.*)_count$/
                and $embeds->{$embed}->{is_count} )
            {

                my $relation = $+{relation};
                $json_object->{$embed} = $self->$relation->count;
            }
            else {
                my $curr = $embed;
                my $next = $embeds->{$curr}->{children};

                $params->{strings} = 1
                  if $embeds->{$embed}->{strings};

                my $children = $self->$curr;

                if ( defined $children and ref($children) eq 'ARRAY' ) {
                    my @list = map {
                        $self->_handle_to_api_child(
                            {
                                child  => $_,
                                next   => $next,
                                curr   => $curr,
                                params => $params
                            }
                        )
                    } @{$children};
                    $json_object->{$curr} = \@list;
                }
                else {
                    $json_object->{$curr} = $self->_handle_to_api_child(
                        {
                            child  => $children,
                            next   => $next,
                            curr   => $curr,
                            params => $params
                        }
                    );
                }
            }
        }
    }

    return $json_object;
}

=head3 to_api_mapping

    my $mapping = $object->to_api_mapping;

Generic method that returns the attribute name mappings required to
render the object on the API.

Note: this only returns an empty I<hashref>. Each class should have its
own mapping returned.

=cut

sub to_api_mapping {
    return {};
}

=head3 strings_map

    my $string_map = $object->strings_map($params);

Generic method that returns the string map for coded attributes.

Return should be a hashref keyed on database field name with the values
being hashrefs containing 'str', 'type' and optionally 'category'.

This is then used in to_api to render the _strings embed when requested.

Note: this only returns an empty I<hashref>. Each class should have its
own mapping returned.

=cut

sub strings_map {
    return {};
}

=head3 public_read_list


    my @public_read_list = @{$object->public_read_list};

Generic method that returns the list of database columns that are allowed to
be passed to render objects on the public API.

Note: this only returns an empty I<arrayref>. Each class should have its
own implementation.

=cut

sub public_read_list
 {
    return [];
}

=head3 from_api_mapping

    my $mapping = $object->from_api_mapping;

Generic method that returns the attribute name mappings so the data that
comes from the API is correctly renamed to match what is required for the DB.

=cut

sub from_api_mapping {
    my ( $self ) = @_;

    my $to_api_mapping = $self->to_api_mapping;

    unless ( defined $self->{_from_api_mapping} ) {
        $self->{_from_api_mapping} = {};
        while (my ($key, $value) = each %{ $to_api_mapping } ) {
            $self->{_from_api_mapping}->{$value} = $key
                if defined $value;
        }
    }

    return $self->{_from_api_mapping};
}

=head3 new_from_api

    my $object = Koha::Object->new_from_api;
    my $object = Koha::Object->new_from_api( $attrs );

Creates a new object, mapping the API attribute names to the ones on the DB schema.

=cut

sub new_from_api {
    my ( $class, $params ) = @_;

    my $self = $class->new;
    return $self->set_from_api( $params );
}

=head3 set_from_api

    my $object = Koha::Object->new(...);
    $object->set_from_api( $attrs )

Sets the object's attributes mapping API attribute names to the ones on the DB schema.

=cut

sub set_from_api {
    my ( $self, $from_api_params ) = @_;

    return $self->set( $self->attributes_from_api( $from_api_params ) );
}

=head3 attributes_from_api

    my $attributes = attributes_from_api( $params );

Returns the passed params, converted from API naming into the model.

=cut

sub attributes_from_api {
    my ( $self, $from_api_params ) = @_;

    my $from_api_mapping = $self->from_api_mapping;

    my $params;
    my $columns_info = $self->_result->result_source->columns_info;
    my $dtf          = $self->_result->result_source->storage->datetime_parser;

    while (my ($key, $value) = each %{ $from_api_params } ) {
        my $koha_field_name =
          exists $from_api_mapping->{$key}
          ? $from_api_mapping->{$key}
          : $key;

        if ( $columns_info->{$koha_field_name}->{is_boolean} ) {
            # TODO: Remove when D8 is formally deprecated
            # Handle booleans gracefully
            $value = ( $value ) ? 1 : 0;
        }
        elsif ( _date_or_datetime_column_type( $columns_info->{$koha_field_name}->{data_type} ) ) {
            try {
                if ( $columns_info->{$koha_field_name}->{data_type} eq 'date' ) {
                    $value = $dtf->format_date(dt_from_string($value, 'iso'))
                        if defined $value;
                }
                else {
                    $value = $dtf->format_datetime(dt_from_string($value, 'rfc3339'))
                        if defined $value;
                }
            }
            catch {
                Koha::Exceptions::BadParameter->throw( parameter => $key );
            };
        }

        $params->{$koha_field_name} = $value;
    }

    return $params;
}

=head3 $object->unblessed_all_relateds

my $everything_into_one_hashref = $object->unblessed_all_relateds

The unblessed method only retrieves column' values for the column of the object.
In a *few* cases we want to retrieve the information of all the prefetched data.

=cut

sub unblessed_all_relateds {
    my ($self) = @_;

    my %data;
    my $related_resultsets = $self->_result->{related_resultsets} || {};
    my $rs = $self->_result;
    while ( $related_resultsets and %$related_resultsets ) {
        my @relations = keys %{ $related_resultsets };
        if ( @relations ) {
            my $relation = $relations[0];
            $rs = $rs->related_resultset($relation)->get_cache;
            $rs = $rs->[0]; # Does it makes sense to have several values here?
            my $object_class = Koha::Object::_get_object_class( $rs->result_class );
            my $koha_object = $object_class->_new_from_dbic( $rs );
            $related_resultsets = $rs->{related_resultsets};
            %data = ( %data, %{ $koha_object->unblessed } );
        }
    }
    %data = ( %data, %{ $self->unblessed } );
    return \%data;
}

=head3 $object->_result();

Returns the internal DBIC Row object

=cut

sub _result {
    my ($self) = @_;

    # If we don't have a dbic row at this point, we need to create an empty one
    $self->{_result} ||=
      Koha::Database->new()->schema()->resultset( $self->_type() )->new({});

    return $self->{_result};
}

=head3 $object->_columns();

Returns an arrayref of the table columns

=cut

sub _columns {
    my ($self) = @_;

    # If we don't have a dbic row at this point, we need to create an empty one
    $self->{_columns} ||= [ $self->_result()->result_source()->columns() ];

    return $self->{_columns};
}

sub _get_object_class {
    my ( $type ) = @_;
    return unless $type;

    if( $type->can('koha_object_class') ) {
        return $type->koha_object_class;
    }
    $type =~ s|Schema::Result::||;
    return ${type};
}

=head3 AUTOLOAD

The autoload method is used only to get and set values for an objects properties.

=cut

sub AUTOLOAD {
    my ($self) = @_;

    my $method = our $AUTOLOAD;
    $method =~ s/.*://;

    my @columns = @{$self->_columns()};
    # Using direct setter/getter like $item->barcode() or $item->barcode($barcode);
    if ( grep { $_ eq $method } @columns ) {
        no strict 'refs';
        *{$AUTOLOAD} = sub {
            my $self = shift;
            if ( @_ ) {
                $self->_result()->set_column( $method, @_);
                return $self;
            } else {
                return $self->_result()->get_column( $method );
            }
        };
        goto &{$AUTOLOAD};
    }

    my @known_methods = qw( is_changed id in_storage get_column discard_changes make_column_dirty );

    Koha::Exceptions::Object::MethodNotCoveredByTests->throw(
        error      => sprintf("The method %s->%s is not covered by tests!", ref($self), $method),
        show_trace => 1
    ) unless grep { $_ eq $method } @known_methods;

    # Remove $self so that @_ now contain arguments only
    shift;
    my $r = eval { $self->_result->$method(@_) };
    if ( $@ ) {
        Koha::Exceptions::Object->throw( ref($self) . "::$method generated this error: " . $@ );
    }
    return $r;
}

=head3 _type

This method must be defined in the child class. The value is the name of the DBIC resultset.
For example, for borrowers, the _type method will return "Borrower".

=cut

sub _type { }

=head3 _handle_to_api_child

=cut

sub _handle_to_api_child {
    my ($self, $args ) = @_;

    my $child  = $args->{child};
    my $next   = $args->{next};
    my $curr   = $args->{curr};
    my $params = $args->{params};

    my $res;

    if ( defined $child ) {

        Koha::Exception->throw( "Asked to embed $curr but its return value doesn't implement to_api" )
            if defined $next and blessed $child and !$child->can('to_api');

        if ( blessed $child ) {
            $params->{embed} = $next;
            $res = $child->to_api($params);
        }
        else {
            $res = $child;
        }
    }

    return $res;
}

sub DESTROY { }

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

Jonathan Druart <jonathan.druart@bugs.koha-community.org>

=cut

1;
