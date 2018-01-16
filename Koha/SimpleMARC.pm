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
  add_field
  update_field
  copy_field
  copy_and_replace_field
  move_field
  delete_field
  field_exists
  field_equals
);


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
    my $field_numbers = $params->{field_numbers} // [];

    if ( ! ( $record && $fromFieldName && $toFieldName ) ) { return; }


    if (   not $fromSubfieldName
        or $fromSubfieldName eq ''
        or not $toSubfieldName
        or $toSubfieldName eq '' ) {
        _copy_move_field(
            {   record        => $record,
                from_field    => $fromFieldName,
                to_field      => $toFieldName,
                regex         => $regex,
                field_numbers => $field_numbers,
                action        => 'copy',
            }
        );
    } else {
        _copy_move_subfield(
            {   record        => $record,
                from_field    => $fromFieldName,
                from_subfield => $fromSubfieldName,
                to_field      => $toFieldName,
                to_subfield   => $toSubfieldName,
                regex         => $regex,
                field_numbers => $field_numbers,
                action        => 'copy',
            }
        );
    }
}

sub copy_and_replace_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $fromSubfieldName = $params->{from_subfield};
    my $toFieldName = $params->{to_field};
    my $toSubfieldName = $params->{to_subfield};
    my $regex = $params->{regex};
    my $field_numbers = $params->{field_numbers} // [];

    if ( ! ( $record && $fromFieldName && $toFieldName ) ) { return; }


    if ( not $fromSubfieldName or $fromSubfieldName eq ''
      or not $toSubfieldName or $toSubfieldName eq ''
    ) {
        _copy_move_field(
            {   record        => $record,
                from_field    => $fromFieldName,
                to_field      => $toFieldName,
                regex         => $regex,
                field_numbers => $field_numbers,
                action        => 'replace',
            }
        );
    } else {
        _copy_move_subfield(
            {   record        => $record,
                from_field    => $fromFieldName,
                from_subfield => $fromSubfieldName,
                to_field      => $toFieldName,
                to_subfield   => $toSubfieldName,
                regex         => $regex,
                field_numbers => $field_numbers,
                action        => 'replace',
            }
        );
    }
}

sub update_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my @values = @{ $params->{values} };
    my $field_numbers = $params->{field_numbers} // [];

    if ( ! ( $record && $fieldName ) ) { return; }

    if ( not $subfieldName or $subfieldName eq '' ) {
        # FIXME I'm not sure the actual implementation is correct.
        die "This action is not implemented yet";
        #_update_field({ record => $record, field => $fieldName, values => \@values });
    } else {
        _update_subfield({ record => $record, field => $fieldName, subfield => $subfieldName, values => \@values, field_numbers => $field_numbers });
    }
}

=head2 add_field

  add_field({
      record   => $record,
      field    => $fieldName,
      subfield => $subfieldName,
      values   => \@values,
      field_numbers => $field_numbers,
  });

  Adds a new field/subfield with supplied value(s).
  This function always add a new field as opposed to 'update_field' which will
  either update if field exists and add if it does not.

=cut


sub add_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my @values = @{ $params->{values} };
    my $field_numbers = $params->{field_numbers} // [];

    if ( ! ( $record && $fieldName ) ) { return; }
    if ( $fieldName > 10 ) {
        foreach my $value ( @values ) {
            my $field = MARC::Field->new( $fieldName, '', '', "$subfieldName" => $value );
            $record->append_fields( $field );
        }
    } else {
        foreach my $value ( @values ) {
            my $field = MARC::Field->new( $fieldName, $value );
            $record->append_fields( $field );
        }
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
    my $field_numbers = $params->{field_numbers} // [];
    my $i = 0;

    my @fields = $record->field( $fieldName );

    if ( @$field_numbers ) {
        @fields = map { $_ <= @fields ? $fields[ $_ - 1 ] : () } @$field_numbers;
    }

    if ( @fields ) {
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
    my $field_numbers = $params->{field_numbers} // [];

    if ( not $subfieldName or $subfieldName eq '' ) {
        _read_field({ record => $record, field => $fieldName, field_numbers => $field_numbers });
    } else {
        _read_subfield({ record => $record, field => $fieldName, subfield => $subfieldName, field_numbers => $field_numbers });
    }
}

sub _read_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $field_numbers = $params->{field_numbers} // [];

    my @fields = $record->field( $fieldName );

    return unless @fields;

    return map { $_->data() } @fields
        if $fieldName < 10;

    my @values;
    if ( @$field_numbers ) {
        for my $field_number ( @$field_numbers ) {
            if ( $field_number <= scalar( @fields ) ) {
                for my $sf ( $fields[$field_number - 1]->subfields ) {
                    push @values, $sf->[1];
                }
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
    my $field_numbers = $params->{field_numbers} // [];

    my @fields = $record->field( $fieldName );

    return unless @fields;

    my @values;
    foreach my $field ( @fields ) {
        my @sf = $field->subfield( $subfieldName );
        push( @values, @sf );
    }

    if ( @values and @$field_numbers ) {
        @values = map { $_ <= @values ? $values[ $_ - 1 ] : () } @$field_numbers;
    }

    return @values;
}

=head2 field_exists

  @field_numbers = field_exists( $record, $fieldName[, $subfieldName ]);

  Returns the field numbers or an empty array.

=cut

sub field_exists {
  my ( $params ) = @_;
  my $record = $params->{record};
  my $fieldName = $params->{field};
  my $subfieldName = $params->{subfield};

  if ( ! $record ) { return; }

  my @field_numbers = ();
  my $current_field_number = 1;
  for my $field ( $record->field( $fieldName ) ) {
    if ( $subfieldName ) {
      push @field_numbers, $current_field_number
        if $field->subfield( $subfieldName );
    } else {
      push @field_numbers, $current_field_number;
    }
    $current_field_number++;
  }

  return \@field_numbers;
}

=head2 field_equals

  $bool = field_equals( $record, $value, $fieldName[, $subfieldName[, $regex ] ]);

  Returns true if the field equals the given value, false otherwise.

  If a regular expression ( $regex ) is supplied, the value will be compared using
  the given regex. Example: $regex = 'sought_text'

=cut

sub field_equals {
  my ( $params ) = @_;
  my $record = $params->{record};
  my $value = $params->{value};
  my $fieldName = $params->{field};
  my $subfieldName = $params->{subfield};
  my $is_regex = $params->{is_regex};

  if ( ! $record ) { return; }

  my @field_numbers = ();
  my $current_field_number = 1;
  FIELDS: for my $field ( $record->field( $fieldName ) ) {
    my @subfield_values = $subfieldName
        ? $field->subfield( $subfieldName )
        : map { $_->[1] } $field->subfields;

    SUBFIELDS: for my $subfield_value ( @subfield_values ) {
      if (
          (
              $is_regex and $subfield_value =~ m/$value/
          ) or (
              $subfield_value eq $value
          )
      ) {
          push @field_numbers, $current_field_number;
          last SUBFIELDS;
      }
    }
    $current_field_number++;
  }

  return \@field_numbers;
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
    my $field_numbers = $params->{field_numbers} // [];

    if (   not $fromSubfieldName
        or $fromSubfieldName eq ''
        or not $toSubfieldName
        or $toSubfieldName eq '' ) {
        _copy_move_field(
            {   record        => $record,
                from_field    => $fromFieldName,
                to_field      => $toFieldName,
                regex         => $regex,
                field_numbers => $field_numbers,
                action        => 'move',
            }
        );
    } else {
        _copy_move_subfield(
            {   record        => $record,
                from_field    => $fromFieldName,
                from_subfield => $fromSubfieldName,
                to_field      => $toFieldName,
                to_subfield   => $toSubfieldName,
                regex         => $regex,
                field_numbers => $field_numbers,
                action        => 'move',
            }
        );
    }
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
    my $field_numbers = $params->{field_numbers} // [];

    if ( not $subfieldName or $subfieldName eq '' ) {
        _delete_field({ record => $record, field => $fieldName, field_numbers => $field_numbers });
    } else {
        _delete_subfield({ record => $record, field => $fieldName, subfield => $subfieldName, field_numbers => $field_numbers });
    }
}

sub _delete_field {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $field_numbers = $params->{field_numbers} // [];

    my @fields = $record->field( $fieldName );

    if ( @$field_numbers ) {
        @fields = map { $_ <= @fields ? $fields[ $_ - 1 ] : () } @$field_numbers;
    }
    foreach my $field ( @fields ) {
        $record->delete_field( $field );
    }
}

sub _delete_subfield {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fieldName = $params->{field};
    my $subfieldName = $params->{subfield};
    my $field_numbers = $params->{field_numbers} // [];

    my @fields = $record->field( $fieldName );

    if ( @$field_numbers ) {
        @fields = map { $_ <= @fields ? $fields[ $_ - 1 ] : () } @$field_numbers;
    }

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
    my $field_numbers = $params->{field_numbers} // [];
    my $action = $params->{action} || 'copy';

    my @from_fields = $record->field( $fromFieldName );
    if ( @$field_numbers ) {
        @from_fields = map { $_ <= @from_fields ? $from_fields[ $_ - 1 ] : () } @$field_numbers;
    }

    my @new_fields;
    for my $from_field ( @from_fields ) {
        my $new_field = $from_field->clone;
        $new_field->{_tag} = $toFieldName; # Should be replaced by set_tag, introduced by MARC::Field 2.0.4
        if ( $regex and $regex->{search} ) {
            for my $subfield ( $new_field->subfields ) {
                my $value = $subfield->[1];
                ( $value ) = _modify_values({ values => [ $value ], regex => $regex });
                $new_field->update( $subfield->[0], $value );
            }
        }
        if ( $action eq 'move' ) {
            $record->delete_field( $from_field )
        }
        elsif ( $action eq 'replace' ) {
            my @to_fields = $record->field( $toFieldName );
            if ( @to_fields ) {
                $record->delete_field( $to_fields[0] );
            }
        }
        push @new_fields, $new_field;
    }
    $record->append_fields( @new_fields );
}

sub _copy_move_subfield {
    my ( $params ) = @_;
    my $record = $params->{record};
    my $fromFieldName = $params->{from_field};
    my $fromSubfieldName = $params->{from_subfield};
    my $toFieldName = $params->{to_field};
    my $toSubfieldName = $params->{to_subfield};
    my $regex = $params->{regex};
    my $field_numbers = $params->{field_numbers} // [];
    my $action = $params->{action} || 'copy';

    my @values = read_field({ record => $record, field => $fromFieldName, subfield => $fromSubfieldName });
    if ( @$field_numbers ) {
        @values = map { $_ <= @values ? $values[ $_ - 1 ] : () } @$field_numbers;
    }
    _modify_values({ values => \@values, regex => $regex });
    my $dont_erase = $action eq 'copy' ? 1 : 0;
    _update_subfield({ record => $record, field => $toFieldName, subfield => $toSubfieldName, values => \@values, dont_erase => $dont_erase });

    # And delete if it's a move
    if ( $action eq 'move' ) {
        _delete_subfield({
            record => $record,
            field => $fromFieldName,
            subfield => $fromSubfieldName,
            field_numbers => $field_numbers,
        });
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
