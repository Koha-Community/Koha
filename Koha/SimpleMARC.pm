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
  my ( $record, $fromFieldName, $fromSubfieldName, $toFieldName, $toSubfieldName, $regex, $n, $dont_erase ) = @_;

  if ( ! ( $record && $fromFieldName && $toFieldName ) ) { return; }

  my @values = read_field( $record, $fromFieldName, $fromSubfieldName );
  @values = ( $values[$n-1] ) if ( $n );

  if ( $regex and $regex->{search} ) {
    $regex->{modifiers} //= q||;
    my @available_modifiers = qw( i g );
    my $modifiers = q||;
    for my $modifier ( split //, $regex->{modifiers} ) {
        $modifiers .= $modifier
            if grep {/$modifier/} @available_modifiers;
    }
    foreach my $value (@values) {
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
  update_field( $record, $toFieldName, $toSubfieldName, $dont_erase, @values );
}

=head2 update_field

  update_field( $record, $fieldName, $subfieldName, $dont_erase, $value[, $value,[ $value ... ] ] );

  Updates a field with the given value, creating it if neccessary.

  If multiple values are supplied, they will be used to update a list of repeatable fields
  until either the fields or the values are all used.

  If a single value is supplied for a repeated field, that value will be used to update
  each of the repeated fields.

=cut

sub update_field {
  my ( $record, $fieldName, $subfieldName, $dont_erase, @values ) = @_;

  if ( ! ( $record && $fieldName ) ) { return; }

  my $i = 0;
  my $field;
  if ( $subfieldName ) {
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
        $field = MARC::Field->new( $fieldName, '', '', "$subfieldName" => $values[$i++] );
        $record->append_fields( $field );
      }
    }
  } else { ## No subfield
    if ( my @fields = $record->field( $fieldName ) ) {
      @values = ($values[0]) x scalar( @fields )
        if @values == 1;
      foreach my $field ( @fields ) {
        $field->update( $values[$i++] );
      }
    } else {
      ## Field does not exists, create it
      foreach my $value ( @values ) {
        $field = MARC::Field->new( $fieldName, $value );
        $record->append_fields( $field );
      }
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
  my ( $record, $fieldName, $subfieldName, $n ) = @_;

  my @fields = $record->field( $fieldName );

  return map { $_->data() } @fields unless $subfieldName;

  my @subfields;
  foreach my $field ( @fields ) {
    my @sf = $field->subfield( $subfieldName );
    push( @subfields, @sf );
  }

  if ( $n ) {
    return $subfields[$n-1];
  } else {
    return @subfields;
  }
}

=head2 field_exists

  $bool = field_exists( $record, $fieldName[, $subfieldName ]);

  Returns true if the field exits, false otherwise.

=cut

sub field_exists {
  my ( $record, $fieldName, $subfieldName ) = @_;

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
  my ( $record, $value, $fieldName, $subfieldName, $regex, $n ) = @_;
  $n = 1 unless ( $n ); ## $n defaults to first field of a repeatable field series

  if ( ! $record ) { return; }

  my @field_values = read_field( $record, $fieldName, $subfieldName, $n );
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
  my ( $record, $fromFieldName, $fromSubfieldName, $toFieldName, $toSubfieldName, $regex, $n ) = @_;
  copy_field( $record, $fromFieldName, $fromSubfieldName, $toFieldName, $toSubfieldName, $regex, $n , 'dont_erase' );
  delete_field( $record, $fromFieldName, $fromSubfieldName, $n );
}

=head2 delete_field

  delete_field( $record, $fieldName[, $subfieldName [, $n ] ] );

  Deletes the given field.

  If $n is passed, only the Nth field will be deleted. $n = 1
  will delete the first repeatable field, $n = 3 will delete the third.

=cut

sub delete_field {
  my ( $record, $fieldName, $subfieldName, $n ) = @_;

  my @fields = $record->field( $fieldName );

  @fields = ( $fields[$n-1] ) if ( $n );

  if ( @fields && !$subfieldName ) {
    foreach my $field ( @fields ) {
      $record->delete_field( $field );
    }
  } elsif ( @fields && $subfieldName ) {
    foreach my $field ( @fields ) {
      $field->delete_subfield( code => $subfieldName );
    }
  }
}

1;
__END__
