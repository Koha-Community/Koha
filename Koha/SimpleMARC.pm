package Koha::SimpleMARC;

# Copyright 2009 Kyle M. Hall <kyle.m.hall@gmail.com>

use Modern::Perl;

#use MARC::Record;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(

) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
  read_field
  update_field
  copy_field
  move_field
  delete_field
  field_exists
  field_equals
);

our $VERSION = '0.01';

our $debug = 0;

=head1 NAME

SimpleMARC - Perl module for making simple MARC record alterations.

=head1 SYNOPSIS

  use SimpleMARC;

=head1 DESCRIPTION

SimpleMARC is designed to make writing scripts
to modify MARC records simple and easy.

Every function in the modules requires a
MARC::Record object as its first parameter.

=head1 AUTHOR

Kyle Hall <lt>kyle.m.hall@gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kyle Hall

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.

=head1 FUNCTIONS

=head2 copy_field

  copy_field( $record, $fromFieldName, $fromSubfieldName, $toFieldName, $toSubfieldName[, $regex[, $n ] ] );

  Copies a value from one field to another. If a regular expression ( $regex ) is supplied,
  the value will be transformed by the given regex before being copied into the new field.
  Example: $regex = { search => 'Old Text', replace => 'Replacement Text', modifiers => 'g' };

  If $n is passed, copy_field will only copy the Nth field of the list of fields.
  E.g. $n = 1 will only use the first field's value, $n = 2 will use only the 2nd field's value.

=cut

sub copy_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $fromSubfieldName = $params->{from_subfield};
    my $toFieldName = $params->{to_field};
    my $toSubfieldName = $params->{to_subfield};
    my $regex = $params->{regex};
    my $n = $params->{n};

    if ( ! ( $record && $fromFieldName && $toFieldName ) ) { return; }


    if ( not $fromSubfieldName or $fromSubfieldName eq ''
      or not $toSubfieldName or $toSubfieldName eq ''
    ) {
        _copy_field({
            record => $record,
            from_field => $fromFieldName,
            to_field => $toFieldName,
            regex => $regex,
            n => $n
        });
    } else {
        _copy_subfield({
            record => $record,
            from_field => $fromFieldName,
            from_subfield => $fromSubfieldName,
            to_field => $toFieldName,
            to_subfield => $toSubfieldName,
            regex => $regex,
            n => $n
        });
    }

}

sub _copy_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $toFieldName = $params->{to_field};
    my $regex = $params->{regex};
    my $n = $params->{n};

    _copy_move_field({
        record => $record,
        from_field => $fromFieldName,
        to_field => $toFieldName,
        regex => $regex,
        n => $n
    });
}

sub _copy_subfield {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $fromSubfieldName = $params->{from_subfield};
    my $toFieldName = $params->{to_field};
    my $toSubfieldName = $params->{to_subfield};
    my $regex = $params->{regex};
    my $n = $params->{n};

    my @values = read_field({ record => $record, field => $fromFieldName, subfield => $fromSubfieldName });
    @values = ( $values[$n-1] ) if ( $n );
    _modify_values({ values => \@values, regex => $regex });

    update_field({ record => $record, field => $toFieldName, subfield => $toSubfieldName, values => \@values });
}

sub update_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my @values = @{ $params->{values} };

    if ( ! ( $record && $fieldName ) ) { return; }

    if ( not $subfieldName or $subfieldName eq '' ) {
        # FIXME I'm not sure the actual implementation is correct.
        die "This action is not implemented yet";
        #_update_field({ record => $record, field => $fieldName, values => \@values });
    } else {
        _update_subfield({ record => $record, field => $fieldName, subfield => $subfieldName, values => \@values });
    }
}

sub _update_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my @values = @{ $params->{values} };

    my $i = 0;
    if ( my @fields = $record->field( $fieldName ) ) {
        @values = ($values[0]) x scalar( @fields )
            if @values == 1;
        foreach my $field ( @fields ) {
            $field->update( $values[$i++] );
        }
    } else {
        ## Field does not exists, create it
        if ( $fieldName < 10 ) {
            foreach my $value ( @values ) {
                my $field = MARC::Field->new( $fieldName, $value );
                $record->append_fields( $field );
            }
        } else {
            warn "Invalid operation, trying to add a new field without subfield";
        }
    }
}

sub _update_subfield {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my @values = @{ $params->{values} };
    my $dont_erase = $params->{dont_erase};
    my $i = 0;

    if ( my @fields = $record->field( $fieldName ) ) {
        unless ( $dont_erase ) {
            @values = ($values[0]) x scalar( @fields )
                if @values == 1;
            foreach my $field ( @fields ) {
                $field->update( "$subfieldName" => $values[$i++] );
            }
        }
        if ( $i <= scalar ( @values ) - 1 ) {
            foreach my $field ( @fields ) {
                foreach my $j ( $i .. scalar( @values ) - 1) {
                    $field->add_subfields( "$subfieldName" => $values[$j] );
                }
            }
        }
    } else {
        ## Field does not exist, create it.
        foreach my $value ( @values ) {
            my $field = MARC::Field->new( $fieldName, '', '', "$subfieldName" => $values[$i++] );
            $record->append_fields( $field );
        }
    }
}

=head2 read_field

  my @values = read_field( $record, $fieldName[, $subfieldName, [, $n ] ] );

  Returns an array of field values for the given field and subfield

  If $n is given, it will return only the $nth value of the array.
  E.g. If $n = 1, it return the 1st value, if $n = 3, it will return the 3rd value.

=cut

sub read_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my $n = $params->{n};

    if ( not $subfieldName or $subfieldName eq '' ) {
        _read_field({ record => $record, field => $fieldName, n => $n });
    } else {
        _read_subfield({ record => $record, field => $fieldName, subfield => $subfieldName, n => $n });
    }
}

sub _read_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $n = $params->{n};

    my @fields = $record->field( $fieldName );

    return unless @fields;

    return map { $_->data() } @fields
        if $fieldName < 10;

    my @values;
    if ( $n ) {
        if ( $n <= scalar( @fields ) ) {
            for my $sf ( $fields[$n - 1]->subfields ) {
                push @values, $sf->[1];
            }
        }
    } else {
        foreach my $field ( @fields ) {
            for my $sf ( $field->subfields ) {
                push @values, $sf->[1];
            }
        }
    }

    return @values;
}

sub _read_subfield {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my $n = $params->{n};

    my @fields = $record->field( $fieldName );

    return unless @fields;

    my @values;
    foreach my $field ( @fields ) {
        my @sf = $field->subfield( $subfieldName );
        push( @values, @sf );
    }

    return $n
        ? $values[$n-1]
        : @values;
}

=head2 field_exists

  $bool = field_exists( $record, $fieldName[, $subfieldName ]);

  Returns true if the field exits, false otherwise.

=cut

sub field_exists {
  my ( $params ) = @_;
  my $record = $params->{record};
  my $fieldName = $params->{field};
  my $subfieldName = $params->{subfield};

  if ( ! $record ) { return; }

  my $return = 0;
  if ( $fieldName && $subfieldName ) {
    $return = $record->field( $fieldName ) && $record->subfield( $fieldName, $subfieldName );
  } elsif ( $fieldName ) {
    $return = $record->field( $fieldName ) && 1;
  }

  return $return;
}

=head2 field_equals

  $bool = field_equals( $record, $value, $fieldName[, $subfieldName[, $regex [, $n ] ] ]);

  Returns true if the field equals the given value, false otherwise.

  If a regular expression ( $regex ) is supplied, the value will be compared using
  the given regex. Example: $regex = 'sought_text'

  If $n is passed, the Nth field of a repeatable series will be used for comparison.
  Set $n to 1 or leave empty for a non-repeatable field.

=cut

sub field_equals {
  my ( $params ) = @_;
  my $record = $params->{record};
  my $value = $params->{value};
  my $fieldName = $params->{field};
  my $subfieldName = $params->{subfield};
  my $regex = $params->{regex};
  my $n = $params->{n};
  $n = 1 unless ( $n ); ## $n defaults to first field of a repeatable field series

  if ( ! $record ) { return; }

  my @field_values = read_field({ record => $record, field => $fieldName, subfield => $subfieldName, n => $n });
  my $field_value = $field_values[$n-1];

  if ( $regex ) {
    return $field_value =~ m/$value/;
  } else {
    return $field_value eq $value;
  }
}

=head2 move_field

  move_field( $record, $fromFieldName, $fromSubfieldName, $toFieldName, $toSubfieldName[, $regex [, $n ] ] );

  Moves a value from one field to another. If a regular expression ( $regex ) is supplied,
  the value will be transformed by the given regex before being moved into the new field.
  Example: $regex = 's/Old Text/Replacement Text/'

  If $n is passed, only the Nth field will be moved. $n = 1
  will move the first repeatable field, $n = 3 will move the third.

=cut

sub move_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $fromSubfieldName = $params->{from_subfield};
    my $toFieldName = $params->{to_field};
    my $toSubfieldName = $params->{to_subfield};
    my $regex = $params->{regex};
    my $n = $params->{n};

    if ( not $fromSubfieldName or $fromSubfieldName eq ''
        or not $toSubfieldName or $toSubfieldName eq ''
    ) {
        _move_field({
            record => $record,
            from_field => $fromFieldName,
            to_field => $toFieldName,
            regex => $regex,
            n => $n,
        });
    } else {
        _move_subfield({
            record => $record,
            from_field => $fromFieldName,
            from_subfield => $fromSubfieldName,
            to_field => $toFieldName,
            to_subfield => $toSubfieldName,
            regex => $regex,
            n => $n,
        });
    }
}

sub _move_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $toFieldName = $params->{to_field};
    my $regex = $params->{regex};
    my $n = $params->{n};
    _copy_move_field({
        record => $record,
        from_field => $fromFieldName,
        to_field => $toFieldName,
        regex => $regex,
        n => $n,
        action => 'move',
    });
}

sub _move_subfield {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $fromSubfieldName = $params->{from_subfield};
    my $toFieldName = $params->{to_field};
    my $toSubfieldName = $params->{to_subfield};
    my $regex = $params->{regex};
    my $n = $params->{n};

    # Copy
    my @values = read_field({ record => $record, field => $fromFieldName, subfield => $fromSubfieldName });
    @values = ( $values[$n-1] ) if $n;
    _modify_values({ values => \@values, regex => $regex });
    _update_subfield({ record => $record, field => $toFieldName, subfield => $toSubfieldName, dont_erase => 1, values => \@values });

    # And delete
    _delete_subfield({
        record => $record,
        field => $fromFieldName,
        subfield => $fromSubfieldName,
        n => $n,
    });
}

=head2 _delete_field

  _delete_field( $record, $fieldName[, $subfieldName [, $n ] ] );

  Deletes the given field.

  If $n is passed, only the Nth field will be deleted. $n = 1
  will delete the first repeatable field, $n = 3 will delete the third.

=cut

sub delete_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my $n = $params->{n};

    if ( not $subfieldName or $subfieldName eq '' ) {
        _delete_field({ record => $record, field => $fieldName, n => $n });
    } else {
        _delete_subfield({ record => $record, field => $fieldName, subfield => $subfieldName, n => $n });
    }
}

sub _delete_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $n = $params->{n};

    my @fields = $record->field( $fieldName );

    @fields = ( $fields[$n-1] ) if ( $n );
    foreach my $field ( @fields ) {
        $record->delete_field( $field );
    }
}

sub _delete_subfield {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my $n = $params->{n};

    my @fields = $record->field( $fieldName );

    @fields = ( $fields[$n-1] ) if ( $n );

    foreach my $field ( @fields ) {
        $field->delete_subfield( code => $subfieldName );
    }
}


sub _copy_move_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $toFieldName = $params->{to_field};
    my $regex = $params->{regex};
    my $n = $params->{n};
    my $action = $params->{action} || 'copy';

    my @fields = $record->field( $fromFieldName );
    if ( $n and $n <= scalar( @fields ) ) {
        @fields = ( $fields[$n - 1] );
    }

    for my $field ( @fields ) {
        my $new_field = $field->clone;
        $new_field->{_tag} = $toFieldName; # Should be replaced by set_tag, introduced by MARC::Field 2.0.4
        if ( $regex and $regex->{search} ) {
            for my $subfield ( $new_field->subfields ) {
                my $value = $subfield->[1];
                ( $value ) = _modify_values({ values => [ $value ], regex => $regex });
                $new_field->update( $subfield->[0], $value );
            }
        }
        $record->append_fields( $new_field );
        $record->delete_field( $field )
            if $action eq 'move';
    }
}

sub _modify_values {
    my ( $params ) = @_;
    my $values = $params->{values};
    my $regex = $params->{regex};

    if ( $regex and $regex->{search} ) {
        $regex->{modifiers} //= q||;
        my @available_modifiers = qw( i g );
        my $modifiers = q||;
        for my $modifier ( split //, $regex->{modifiers} ) {
            $modifiers .= $modifier
                if grep {/$modifier/} @available_modifiers;
        }
        foreach my $value ( @$values ) {
            if ( $modifiers =~ m/^(ig|gi)$/ ) {
                $value =~ s/$regex->{search}/$regex->{replace}/ig;
            }
            elsif ( $modifiers eq 'i' ) {
                $value =~ s/$regex->{search}/$regex->{replace}/i;
            }
            elsif ( $modifiers eq 'g' ) {
                $value =~ s/$regex->{search}/$regex->{replace}/g;
            }
            else {
                $value =~ s/$regex->{search}/$regex->{replace}/;
            }
        }
    }
    return @$values;
}
1;
__END__
