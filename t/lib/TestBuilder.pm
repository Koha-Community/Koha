package t::lib::TestBuilder;

use Modern::Perl;

use Koha::Database qw( schema );
use C4::Biblio qw( AddBiblio );
use Koha::Biblios qw( _type );
use Koha::Items qw( _type );
use Koha::DateUtils qw( dt_from_string );

use Bytes::Random::Secure;
use Carp qw( carp );
use Module::Load qw( load );
use String::Random;

use constant {
    SIZE_BARCODE => 20, # Not perfect but avoid to fetch the value when creating a new item
};

sub new {
    my ($class) = @_;
    my $self = {};
    bless( $self, $class );

    $self->schema( Koha::Database->new()->schema );
    $self->schema->storage->sql_maker->quote_char('`');

    $self->{gen_type} = _gen_type();
    $self->{default_values} = _gen_default_values();
    return $self;
}

sub schema {
    my ($self, $schema) = @_;

    if( defined( $schema ) ) {
        $self->{schema} = $schema;
    }
    return $self->{schema};
}

# sub clear has been obsoleted; use delete_all from the schema resultset

sub delete {
    my ( $self, $params ) = @_;
    my $source = $params->{source} || return;
    my @recs = ref( $params->{records} ) eq 'ARRAY'?
        @{$params->{records}}: ( $params->{records} // () );
    # tables without PK are not supported
    my @pk = $self->schema->source( $source )->primary_columns;
    return if !@pk;
    my $rv = 0;
    foreach my $rec ( @recs ) {
    # delete only works when you supply full primary key values
    # $cond does not include searches for undef (not allowed in PK)
        my $cond = { map { defined $rec->{$_}? ($_, $rec->{$_}): (); } @pk };
        next if keys %$cond < @pk;
        $self->schema->resultset( $source )->search( $cond )->delete;
        # we clear the pk columns in the supplied hash
        # this indirectly signals at least an attempt to delete
        map { delete $rec->{$_}; } @pk;
        $rv++;
    }
    return $rv;
}

sub build_object {
    my ( $self, $params ) = @_;

    my $class = $params->{class};
    my $value = $params->{value};

    if ( not defined $class ) {
        carp "Missing class param";
        return;
    }

    my @unknowns = grep( !/^(class|value)$/, keys %{ $params });
    carp "Unknown parameter(s): ", join( ', ', @unknowns ) if scalar @unknowns;

    load $class;
    my $source = $class->_type;

    my $hashref = $self->build({ source => $source, value => $value });
    my $object;
    if ( $class eq 'Koha::Old::Patrons' ) {
        $object = $class->search({ borrowernumber => $hashref->{borrowernumber} })->next;
    } elsif ( $class eq 'Koha::Statistics' ) {
        $object = $class->search({ datetime => $hashref->{datetime} })->next;
    } else {
        my @ids;
        my @pks = $self->schema->source( $class->_type )->primary_columns;
        foreach my $pk ( @pks ) {
            push @ids, $hashref->{ $pk };
        }

        $object = $class->find( @ids );
    }

    return $object;
}

sub build {
# build returns a hash of column values for a created record, or undef
# build does NOT update a record, or pass back values of an existing record
    my ($self, $params) = @_;
    my $source  = $params->{source};
    if( !$source ) {
        carp "Source parameter not specified!";
        return;
    }
    my $value   = $params->{value};

    my @unknowns = grep( !/^(source|value)$/, keys %{ $params });
    carp "Unknown parameter(s): ", join( ', ', @unknowns ) if scalar @unknowns;

    my $col_values = $self->_buildColumnValues({
        source  => $source,
        value   => $value,
    });
    return if !$col_values; # did not meet unique constraints?

    # loop thru all fk and create linked records if needed
    # fills remaining entries in $col_values
    my $foreign_keys = $self->_getForeignKeys( { source => $source } );
    my $col_names = {};
    for my $fk ( @$foreign_keys ) {
        # skip when FK points to itself: e.g. borrowers:guarantorid
        next if $fk->{source} eq $source;

        # If we have more than one FK on the same column, we only generate values for the first one
        next
          if scalar @{ $fk->{keys} } == 1
          && exists $col_names->{ $fk->{keys}->[0]->{col_name} };

        my $keys = $fk->{keys};
        my $tbl = $fk->{source};
        my $res = $self->_create_links( $tbl, $keys, $col_values, $value );
        return if !$res; # failed: no need to go further
        foreach( keys %$res ) { # save new values
            $col_values->{$_} = $res->{$_};
        }

        $col_names->{ $fk->{keys}->[0]->{col_name} } = 1
          if scalar @{ $fk->{keys} } == 1
    }

    # store this record and return hashref
    return $self->_storeColumnValues({
        source => $source,
        values => $col_values,
    });
}

sub build_sample_biblio {
    my ( $self, $args ) = @_;

    my $title  = $args->{title}  || 'Some boring read';
    my $author = $args->{author} || 'Some boring author';
    my $frameworkcode = $args->{frameworkcode} || '';
    my $itemtype = $args->{itemtype}
      || $self->build_object( { class => 'Koha::ItemTypes' } )->itemtype;

    my $marcflavour = C4::Context->preference('marcflavour');

    my $record = MARC::Record->new();
    $record->encoding( 'UTF-8' );

    my ( $tag, $subfield ) = $marcflavour eq 'UNIMARC' ? ( 200, 'a' ) : ( 245, 'a' );
    $record->append_fields(
        MARC::Field->new( $tag, ' ', ' ', $subfield => $title ),
    );

    ( $tag, $subfield ) = $marcflavour eq 'UNIMARC' ? ( 200, 'f' ) : ( 100, 'a' );
    $record->append_fields(
        MARC::Field->new( $tag, ' ', ' ', $subfield => $author ),
    );

    ( $tag, $subfield ) = $marcflavour eq 'UNIMARC' ? ( 995, 'r' ) : ( 942, 'c' );
    $record->append_fields(
        MARC::Field->new( $tag, ' ', ' ', $subfield => $itemtype )
    );

    my ($biblio_id) = C4::Biblio::AddBiblio( $record, $frameworkcode );
    return Koha::Biblios->find($biblio_id);
}

sub build_sample_item {
    my ( $self, $args ) = @_;

    my $biblionumber =
      delete $args->{biblionumber} || $self->build_sample_biblio->biblionumber;
    my $library = delete $args->{library}
      || $self->build_object( { class => 'Koha::Libraries' } )->branchcode;

    # If itype is not passed it will be picked from the biblio (see Koha::Item->store)

    my $barcode = delete $args->{barcode}
      || $self->_gen_text( { info => { size => SIZE_BARCODE } } );

    return Koha::Item->new(
        {
            biblionumber  => $biblionumber,
            homebranch    => $library,
            holdingbranch => $library,
            barcode       => $barcode,
            %$args,
        }
    )->store->get_from_storage;
}

# ------------------------------------------------------------------------------
# Internal helper routines

sub _create_links {
# returns undef for failure to create linked records
# otherwise returns hashref containing new column values for parent record
    my ( $self, $linked_tbl, $keys, $col_values, $value ) = @_;

    my $fk_value = {};
    my ( $cnt_scalar, $cnt_null ) = ( 0, 0 );

    # First, collect all values for creating a linked record (if needed)
    foreach my $fk ( @$keys ) {
        my ( $col, $destcol ) = ( $fk->{col_name}, $fk->{col_fk_name} );
        if( ref( $value->{$col} ) eq 'HASH' ) {
            # add all keys from the FK hash
            $fk_value = { %{ $value->{$col} }, %$fk_value };
        }
        if( exists $col_values->{$col} ) {
            # add specific value (this does not necessarily exclude some
            # values from the hash in the preceding if)
            $fk_value->{ $destcol } = $col_values->{ $col };
            $cnt_scalar++;
            $cnt_null++ if !defined( $col_values->{$col} );
        }
    }

    # If we saw all FK columns, first run the following checks
    if( $cnt_scalar == @$keys ) {
        # if one or more fk cols are null, the FK constraint will not be forced
        return {} if $cnt_null > 0;

        # does the record exist already?
        my @pks = $self->schema->source( $linked_tbl )->primary_columns;
        my %fk_pk_value;
        for (@pks) {
            $fk_pk_value{$_} = $fk_value->{$_} if defined $fk_value->{$_};
        }
        return {} if !(keys %fk_pk_value);
        return {} if $self->schema->resultset($linked_tbl)->find( \%fk_pk_value );
    }
    # create record with a recursive build call
    my $row = $self->build({ source => $linked_tbl, value => $fk_value });
    return if !$row; # failure

    # Finally, only return the new values
    my $rv = {};
    foreach my $fk ( @$keys ) {
        my ( $col, $destcol ) = ( $fk->{col_name}, $fk->{col_fk_name} );
        next if exists $col_values->{ $col };
        $rv->{ $col } = $row->{ $destcol };
    }
    return $rv; # success
}

sub _formatSource {
    my ($params) = @_;
    my $source = $params->{source} || return;
    $source =~ s|(\w+)$|$1|;
    return $source;
}

sub _buildColumnValues {
    my ($self, $params) = @_;
    my $source = _formatSource( $params ) || return;
    my $original_value = $params->{value};

    my $col_values = {};
    my @columns = $self->schema->source($source)->columns;
    my %unique_constraints = $self->schema->source($source)->unique_constraints();

    my $build_value = 5;
    # we try max $build_value times if there are unique constraints
    BUILD_VALUE: while ( $build_value ) {
        # generate random values for all columns
        for my $col_name( @columns ) {
            my $valref = $self->_buildColumnValue({
                source      => $source,
                column_name => $col_name,
                value       => $original_value,
            });
            return if !$valref; # failure
            if( @$valref ) { # could be empty
                # there will be only one value, but it could be undef
                $col_values->{$col_name} = $valref->[0];
            }
        }

        # verify the data would respect each unique constraint
        # note that this is INCOMPLETE since not all col_values are filled
        CONSTRAINTS: foreach my $constraint (keys %unique_constraints) {

                my $condition;
                my $constraint_columns = $unique_constraints{$constraint};
                # loop through all constraint columns and build the condition
                foreach my $constraint_column ( @$constraint_columns ) {
                    # build the filter
                    # if one column does not exist or is undef, skip it
                    # an insert with a null will not trigger the constraint
                    next CONSTRAINTS
                        if !exists $col_values->{ $constraint_column } ||
                        !defined $col_values->{ $constraint_column };
                    $condition->{ $constraint_column } =
                            $col_values->{ $constraint_column };
                }
                my $count = $self->schema
                                 ->resultset( $source )
                                 ->search( $condition )
                                 ->count();
                if ( $count > 0 ) {
                    # no point checking more stuff, exit the loop
                    $build_value--;
                    next BUILD_VALUE;
                }
        }
        last; # you passed all tests
    }
    return $col_values if $build_value > 0;

    # if you get here, we have a problem
    warn "Violation of unique constraint in $source";
    return;
}

sub _getForeignKeys {

# Returns the following arrayref
#   [ [ source => name, keys => [ col_name => A, col_fk_name => B ] ], ... ]
# The array gives source name and keys for each FK constraint

    my ($self, $params) = @_;
    my $source = $self->schema->source( $params->{source} );

    my ( @foreign_keys, $check_dupl );
    my @relationships = $source->relationships;
    for my $rel_name( @relationships ) {
        my $rel_info = $source->relationship_info($rel_name);
        if( $rel_info->{attrs}->{is_foreign_key_constraint} ) {
            $rel_info->{source} =~ s/^.*:://g;
            my $rel = { source => $rel_info->{source} };

            my @keys;
            while( my ($col_fk_name, $col_name) = each(%{$rel_info->{cond}}) ) {
                $col_name    =~ s|self.(\w+)|$1|;
                $col_fk_name =~ s|foreign.(\w+)|$1|;
                push @keys, {
                    col_name    => $col_name,
                    col_fk_name => $col_fk_name,
                };
            }
            # check if the combination table and keys is unique
            # so skip double belongs_to relations (as in Biblioitem)
            my $tag = $rel->{source}. ':'.
                join ',', sort map { $_->{col_name} } @keys;
            next if $check_dupl->{$tag};
            $check_dupl->{$tag} = 1;
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
    my $new_row = $self->schema->resultset( $source )->create( $col_values );
    return $new_row? { $new_row->get_columns }: {};
}

sub _buildColumnValue {
# returns an arrayref if all goes well
# an empty arrayref typically means: auto_incr column or fk column
# undef means failure
    my ($self, $params) = @_;
    my $source    = $params->{source};
    my $value     = $params->{value};
    my $col_name  = $params->{column_name};

    my $col_info  = $self->schema->source($source)->column_info($col_name);

    my $retvalue = [];
    if( $col_info->{is_auto_increment} ) {
        if( exists $value->{$col_name} ) {
            warn "Value not allowed for auto_incr $col_name in $source";
            return;
        }
        # otherwise: no need to assign a value
    } elsif( $col_info->{is_foreign_key} || _should_be_fk($source,$col_name) ) {
        if( exists $value->{$col_name} ) {
            if( !defined $value->{$col_name} && !$col_info->{is_nullable} ) {
                # This explicit undef is not allowed
                warn "Null value for $col_name in $source not allowed";
                return;
            }
            if( ref( $value->{$col_name} ) ne 'HASH' ) {
                push @$retvalue, $value->{$col_name};
            }
            # sub build will handle a passed hash value later on
        }
    } elsif( ref( $value->{$col_name} ) eq 'HASH' ) {
        # this is not allowed for a column that is not a FK
        warn "Hash not allowed for $col_name in $source";
        return;
    } elsif( exists $value->{$col_name} ) {
        if( !defined $value->{$col_name} && !$col_info->{is_nullable} ) {
            # This explicit undef is not allowed
            warn "Null value for $col_name in $source not allowed";
            return;
        }
        push @$retvalue, $value->{$col_name};
    } elsif( exists $self->{default_values}{$source}{$col_name} ) {
        my $v = $self->{default_values}{$source}{$col_name};
        $v = &$v() if ref($v) eq 'CODE';
        push @$retvalue, $v;
    } else {
        my $data_type = $col_info->{data_type};
        $data_type =~ s| |_|;
        if( my $hdlr = $self->{gen_type}->{$data_type} ) {
            push @$retvalue, &$hdlr( $self, { info => $col_info } );
        } else {
            warn "Unknown type $data_type for $col_name in $source";
            return;
        }
    }
    return $retvalue;
}

sub _should_be_fk {
# This sub is only needed for inconsistencies in the schema
# A column is not marked as FK, but a belongs_to relation is defined
    my ( $source, $column ) = @_;
    my $inconsistencies = {
        'Item.biblionumber'           => 1, #FIXME: Please remove me when I become FK
        'CheckoutRenewal.checkout_id' => 1, #FIXME: Please remove when issues and old_issues are merged
    };
    return $inconsistencies->{ "$source.$column" };
}

sub _gen_type {
    return {
        tinyint   => \&_gen_bool,
        smallint  => \&_gen_int,
        mediumint => \&_gen_int,
        integer   => \&_gen_int,
        bigint    => \&_gen_int,

        float            => \&_gen_real,
        decimal          => \&_gen_real,
        double_precision => \&_gen_real,

        timestamp => \&_gen_datetime,
        datetime  => \&_gen_datetime,
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
};

sub _gen_bool {
    my ($self, $params) = @_;
    return int( rand(2) );
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
    $max = 10 ** 5 if $max > 10 ** 5;
    return sprintf("%.2f", rand($max-0.1));
}

sub _gen_date {
    my ($self, $params) = @_;
    return $self->schema->storage->datetime_parser->format_date(dt_from_string)
}

sub _gen_datetime {
    my ($self, $params) = @_;
    return $self->schema->storage->datetime_parser->format_datetime(dt_from_string);
}

sub _gen_text {
    my ($self, $params) = @_;
    # From perldoc String::Random
    my $size = $params->{info}{size} // 10;
    $size -= alt_rand(0.5 * $size);
    my $regex = $size > 1
        ? '[A-Za-z][A-Za-z0-9_]{'.($size-1).'}'
        : '[A-Za-z]';
    my $random = String::Random->new( rand_gen => \&alt_rand );
    # rand_gen is only supported from 0.27 onward
    return $random->randregex($regex);
}

sub alt_rand { #Alternative randomizer
    my ($max) = @_;
    my $random = Bytes::Random::Secure->new( NonBlocking => 1 );
    my $r = $random->irand / 2**32;
    return int( $r * $max );
}

sub _gen_set_enum {
    my ($self, $params) = @_;
    return $params->{info}->{extra}->{list}->[0];
}

sub _gen_blob {
    my ($self, $params) = @_;;
    return 'b';
}

sub _gen_default_values {
    my ($self) = @_;
    return {
        BackgroundJob => {
            context => '{}'
        },
        Borrower => {
            login_attempts => 0,
            gonenoaddress  => undef,
            lost           => undef,
            debarred       => undef,
            borrowernotes  => '',
            secret         => undef,
            password_expiration_date => undef,
        },
        Item => {
            notforloan         => 0,
            itemlost           => 0,
            withdrawn          => 0,
            restricted         => 0,
            damaged            => 0,
            materials          => undef,
            more_subfields_xml => undef,
        },
        Category => {
            enrolmentfee => 0,
            reservefee   => 0,
            # Not X, used for statistics
            category_type => sub { return [ qw( A C S I P ) ]->[int(rand(5))] },
            min_password_length => undef,
            require_strong_password => undef,
        },
        Branch => {
            pickup_location => 0,
        },
        Reserve => {
            non_priority => 0,
        },
        Itemtype => {
            rentalcharge => 0,
            rentalcharge_daily => 0,
            rentalcharge_hourly => 0,
            defaultreplacecost => 0,
            processfee => 0,
            notforloan => 0,
        },
        Aqbookseller => {
            tax_rate => 0,
            discount => 0,
            url  => undef,
        },
        Aqbudget => {
            sort1_authcat => undef,
            sort2_authcat => undef,
        },
        AuthHeader => {
            marcxml => '',
        },
        BorrowerAttributeType => {
            mandatory => 0,
        },
        Suggestion => {
            suggesteddate => dt_from_string()->ymd,
            STATUS        => 'ASKED'
        },
        ReturnClaim => {
            issue_id => undef, # It should be a FK but we removed it
                               # We don't want to generate a random value
        },
        ImportItem => {
            status => 'staged',
            import_error => undef
        },
        SearchFilter => {
            opac => 1,
            staff_client => 1
        },
        ErmAgreement => {
            status           => 'active',
            closure_reason   => undef,
            renewal_priority => undef,
            vendor_id        => undef,
          },
    };
}

=head1 NAME

t::lib::TestBuilder.pm - Koha module to create test records

=head1 SYNOPSIS

    use t::lib::TestBuilder;
    my $builder = t::lib::TestBuilder->new;

    # The following call creates a patron, linked to branch CPL.
    # Surname is provided, other columns are randomly generated.
    # Branch CPL is created if it does not exist.
    my $patron = $builder->build({
        source => 'Borrower',
        value  => { surname => 'Jansen', branchcode => 'CPL' },
    });

=head1 DESCRIPTION

This module automatically creates database records for you.
If needed, records for foreign keys are created too.
Values will be randomly generated if not passed to TestBuilder.
Note that you should wrap these actions in a transaction yourself.

=head1 METHODS

=head2 new

    my $builder = t::lib::TestBuilder->new;

    Constructor - Returns the object TestBuilder

=head2 schema

    my $schema = $builder->schema;

    Getter - Returns the schema of DBIx::Class

=head2 delete

    $builder->delete({
        source => $source,
        records => $patron, # OR: records => [ $patron, ... ],
    });

    Delete individual records, created by builder.
    Returns the number of delete attempts, or undef.

=head2 build

    $builder->build({ source  => $source_name, value => $value });

    Create a test record in the table, represented by $source_name.
    The name is required and must conform to the DBIx::Class schema.
    Values may be specified by the optional $value hashref. Will be
    randomized otherwise.
    If needed, TestBuilder creates linked records for foreign keys.
    Returns the values of the new record as a hashref, or undef if
    the record could not be created.

    Note that build also supports recursive hash references inside the
    value hash for foreign key columns, like:
        value => {
            column1 => 'some_value',
            fk_col2 => {
                columnA => 'another_value',
            }
        }
    The hash for fk_col2 here means: create a linked record with build
    where columnA has this value. In case of a composite FK the hashes
    are merged.

    Realize that passing primary key values to build may result in undef
    if a record with that primary key already exists.

=head2 build_object

Given a plural Koha::Object-derived class, it creates a random element, and
returns the corresponding Koha::Object.

    my $patron = $builder->build_object({ class => 'Koha::Patrons' [, value => { ... }] });

=head1 AUTHOR

Yohann Dufour <yohann.dufour@biblibre.com>

Koha Development Team

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
