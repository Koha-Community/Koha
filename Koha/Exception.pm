package Koha::Exception;

use Modern::Perl;

use Exception::Class (
    'Koha::Exception' => {
        description => "Something went wrong!"
    },
);

sub full_message {
    my $self = shift;

    # If a message was passed manually, use it
    return sprintf "Exception '%s' thrown '%s'\n", ref($self), $self->message
      if $self->message;

    my $field_hash = $self->field_hash;

    my $description = $self->description;
    my @fields;

    foreach my $key ( sort keys %$field_hash ) {
        push @fields, $key . " => " . $field_hash->{$key}
          if defined $field_hash->{$key};
    }

    return
      sprintf "Exception '%s' thrown '%s'" . ( @fields ? " with %s" : "" ) . "\n",
      ref($self), $description, ( @fields ? join ', ', @fields : () );
}

=head1 NAME

Koha::Exception - Base class for exceptions

=head1 Exceptions

=head2 Koha::Exception

Generic exception.

=head1 Class methods

=head2 full_message

Generic method for exception stringifying.

=cut

1;
