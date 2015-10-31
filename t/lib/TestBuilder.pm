package t::lib::TestBuilder;

use Modern::Perl;
use Koha::Database;
use String::Random;


my $gen_type = {
    tinyint   => \&_gen_int,
    smallint  => \&_gen_int,
    mediumint => \&_gen_int,
    integer   => \&_gen_int,
    bigint    => \&_gen_int,

    float            => \&_gen_real,
    decimal          => \&_gen_real,
    double_precision => \&_gen_real,

    timestamp => \&_gen_date,
    datetime  => \&_gen_date,
    date      => \&_gen_date,

    char       => \&_gen_text,
    varchar    => \&_gen_text,
    tinytext   => \&_gen_text,
    text       => \&_gen_text,
    mediumtext => \&_gen_text,
    longtext   => \&_gen_text,

    set  => \&_gen_set_enum,
    enum => \&_gen_set_enum,

    tinyblob   => \&_gen_blob,
    mediumblob => \&_gen_blob,
    blob       => \&_gen_blob,
    longblob   => \&_gen_blob,
};

our $default_value = {
    UserPermission => {
        borrowernumber => {
            surname => 'my surname',
            address => 'my adress',
            city    => 'my city',
            branchcode => {
                branchcode => 'cB',
                branchname => 'my branchname',
            },
            categorycode => {
                categorycode    => 'cC',
                hidelostitems   => 0,
                category_type   => 'A',
                default_privacy => 'default',
            },
            privacy => 1,
        },
        module_bit => {
            module_bit => {
                bit => '10',
            },
            code => 'my code',
        },
        code => undef,
    },
};
$default_value->{UserPermission}->{code} = $default_value->{UserPermission}->{module_bit};


sub new {
    my ($class) = @_;
    my $self = {};
    bless( $self, $class );

    $self->schema( Koha::Database->new()->schema );
    $self->schema->storage->sql_maker->quote_char('`');

    return $self;
}

sub schema {
    my ($self, $schema) = @_;

    if( defined( $schema ) ) {
        $self->{schema} = $schema;
    }
    return $self->{schema};
}

sub clear {
    my ($self, $params) = @_;
    my $source = $self->schema->resultset( $params->{source} );
    return $source->delete_all();
}

sub build {
    my ($self, $params) = @_;
    my $source  = $params->{source} || return;
    my $value   = $params->{value};
    my $only_fk = $params->{only_fk} || 0;

    my $col_values = $self->_buildColumnValues({
        source  => $source,
        value   => $value,
    });

    my $data;
    my $foreign_keys = $self->_getForeignKeys( { source => $source } );
    for my $fk ( @$foreign_keys ) {
        my $fk_value;
        my $col_name = $fk->{keys}->[0]->{col_name};
        if( ref( $col_values->{$col_name} ) eq 'HASH' ) {
            $fk_value = $col_values->{$col_name};
        }
        elsif( defined( $col_values->{$col_name} ) ) {
            next;
        }

        my $fk_row = $self->build({
            source => $fk->{source},
            value  => $fk_value,
        });

        my $keys = $fk->{keys};
        for my $key( @$keys )  {
            $col_values->{ $key->{col_name} } = $fk_row->{ $key->{col_fk_name} };
            $data->{ $key->{col_name} } = $fk_row;
        }
    }

    my $new_row;
    if( $only_fk ) {
        $new_row = $col_values;
    }
    else {
        $new_row = $self->_storeColumnValues({
            source => $source,
            values => $col_values,
        });
    }
    $new_row->{_fk} = $data if( defined( $data ) );
    return $new_row;
}

sub _formatSource {
    my ($params) = @_;
    my $source = $params->{source};
    $source =~ s|(\w+)$|$1|;
    return $source;
}

sub _buildColumnValues {
    my ($self, $params) = @_;
    my $source = _formatSource( { source => $params->{source} } );
    my $original_value = $params->{value};

    my $col_values;
    my @columns = $self->schema->source($source)->columns;
    my %unique_constraints = $self->schema->source($source)->unique_constraints();

    my $build_value = 1;
    BUILD_VALUE: while ( $build_value ) {
        # generate random values for all columns
        for my $col_name( @columns ) {
            my $col_value = $self->_buildColumnValue({
                source      => $source,
                column_name => $col_name,
                value       => $original_value,
            });
            $col_values->{$col_name} = $col_value if( defined( $col_value ) );
        }
        $build_value = 0;

        # If default values are set, maybe the data exist in the DB
        # But no need to wait for another value
        # FIXME this can be wrong if a default value is defined for a field
        # which is not a constraint and that the generated value for the
        # constraint already exists.
        last BUILD_VALUE if exists( $default_value->{$source} );

        # If there is no original value given and unique constraints exist,
        # check if the generated values do not exist yet.
        if ( not defined $original_value and scalar keys %unique_constraints > 0 ) {

            # verify the data would respect each unique constraint
            CONSTRAINTS: foreach my $constraint (keys %unique_constraints) {

                my $condition;
                my $constraint_columns = $unique_constraints{$constraint};
                # loop through all constraint columns and build the condition
                foreach my $constraint_column ( @$constraint_columns ) {
                    # build the filter
                    $condition->{ $constraint_column } =
                            $col_values->{ $constraint_column };
                }

                my $count = $self->schema
                                 ->resultset( $source )
                                 ->search( $condition )
                                 ->count();
                if ( $count > 0 ) {
                    # no point checking more stuff, exit the loop
                    $build_value = 1;
                    last CONSTRAINTS;
                }
            }
        }
    }
    return $col_values;
}

# Returns [ {
#   rel_name => $rel_name,
#   source => $table_name,
#   keys => [ {
#       col_name => $col_name,
#       col_fk_name => $col_fk_name,
#   }, ... ]
# }, ... ]
sub _getForeignKeys {
    my ($self, $params) = @_;
    my $source = $self->schema->source( $params->{source} );

    my @foreign_keys = ();
    my @relationships = $source->relationships;
    for my $rel_name( @relationships ) {
        my $rel_info = $source->relationship_info($rel_name);
        if( $rel_info->{attrs}->{is_foreign_key_constraint} ) {
            my $rel = {
                rel_name => $rel_name,
                source   => $rel_info->{source},
            };

            my @keys = ();
            while( my ($col_fk_name, $col_name) = each(%{$rel_info->{cond}}) ) {
                $col_name    =~ s|self.(\w+)|$1|;
                $col_fk_name =~ s|foreign.(\w+)|$1|;
                push @keys, {
                    col_name    => $col_name,
                    col_fk_name => $col_fk_name,
                };
            }
            $rel->{keys} = \@keys;

            push @foreign_keys, $rel;
        }
    }
    return \@foreign_keys;
}

sub _storeColumnValues {
    my ($self, $params) = @_;
    my $source      = $params->{source};
    my $col_values  = $params->{values};

    my $new_row;
    eval {
        $new_row = $self->schema->resultset($source)->update_or_create($col_values);
    };
    die "$source - $@\n" if ($@);

    eval {
        $new_row = { $new_row->get_columns };
    };
    warn "$source - $@\n" if ($@);
    return $new_row;
}

sub _buildColumnValue {
    my ($self, $params) = @_;
    my $source    = $params->{source};
    my $value     = $params->{value};
    my $col_name  = $params->{column_name};
    my $col_info  = $self->schema->source($source)->column_info($col_name);

    my $col_value;
    if( exists( $value->{$col_name} ) ) {
        $col_value = $value->{$col_name};
    }
    elsif( exists $default_value->{$source} and exists $default_value->{$source}->{$col_name} ) {
        $col_value = $default_value->{$source}->{$col_name};
    }
    elsif( not $col_info->{default_value} and not $col_info->{is_auto_increment} and not $col_info->{is_foreign_key} ) {
        eval {
            my $data_type = $col_info->{data_type};
            $data_type =~ s| |_|;
            $col_value = $gen_type->{$data_type}->( $self, { info => $col_info } );
        };
        die "The type $col_info->{data_type} is not defined\n" if ($@);
    }
    return $col_value;
}


sub _gen_int {
    my ($self, $params) = @_;
    my $data_type = $params->{info}->{data_type};

    my $max = 1;
    if( $data_type eq 'tinyint' ) {
        $max = 127;
    }
    elsif( $data_type eq 'smallint' ) {
        $max = 32767;
    }
    elsif( $data_type eq 'mediumint' ) {
        $max = 8388607;
    }
    elsif( $data_type eq 'integer' ) {
        $max = 2147483647;
    }
    elsif( $data_type eq 'bigint' ) {
        $max = 9223372036854775807;
    }
    return int( rand($max+1) );
}

sub _gen_real {
    my ($self, $params) = @_;
    my $max = 10 ** 38;
    if( defined( $params->{info}->{size} ) ) {
        $max = 10 ** ($params->{info}->{size}->[0] - $params->{info}->{size}->[1]);
    }
    return rand($max) + 1;
}

sub _gen_date {
    my ($self, $params) = @_;
    return $self->schema->storage->datetime_parser->format_datetime(DateTime->now());
}

sub _gen_text {
    my ($self, $params) = @_;
    # From perldoc String::Random
    # max: specify the maximum number of characters to return for * and other
    # regular expression patters that don't return a fixed number of characters
    my $regex = '[A-Za-z][A-Za-z0-9_]*';
    my $size = $params->{info}{size};
    if ( defined $size and $size > 1 ) {
        $size--;
    } elsif ( defined $size and $size == 1 ) {
        $regex = '[A-Za-z]';
    }
    my $random = String::Random->new( max => $size );
    return $random->randregex($regex);
}

sub _gen_set_enum {
    my ($self, $params) = @_;
    return $params->{info}->{extra}->{list}->[0];
}

sub _gen_blob {
    my ($self, $params) = @_;;
    return 'b';
}

=head1 NAME

t::lib::TestBuilder.pm - Koha module to simplify the writing of tests

=head1 SYNOPSIS

    use t::lib::TestBuilder;

Koha module to insert the foreign keys automatically for the tests

=head1 DESCRIPTION

This module allows to insert automatically an entry in the database. All the database changes are wrapped in a transaction.
The foreign keys are created according to the DBIx::Class schema.
The taken values are the values by default if it is possible or randomly generated.

=head1 FUNCTIONS

=head2 new

    $builder = t::lib::TestBuilder->new()

Constructor - Begins a transaction and returns the object TestBuilder

=head2 schema

    $schema = $builder->schema

Getter - Returns the schema of DBIx::Class

=head2 clear

    $builder->clear({ source => $source_name })

=over

=item C<$source_name> is the name of the source in the DBIx::Class schema (required)

=back

Clears all the data of this source (database table)

=head2 build

    $builder->build({
        source  => $source_name,
        value   => $value,
        only_fk => $only_fk,
    })

=over

=item C<$source_name> is the name of the source in the DBIx::Class schema (required)

=item C<$value> is the values for the entry (optional)

=item C<$only_fk> is a boolean to indicate if only the foreign keys are created (optional)

=back

Inserts an entry in the database by instanciating all the foreign keys.
The values can be specified, the values which are not given are default values if they exists or generated randomly.
Returns the values of the entry as a hashref with an extra key : _fk which contains all the values of the generated foreign keys.

=head1 AUTHOR

Yohann Dufour <yohann.dufour@biblibre.com>

=head1 COPYRIGHT

Copyright 2014 - Biblibre SARL

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

Koha is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut

1;
