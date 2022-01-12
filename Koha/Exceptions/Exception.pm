package Koha::Exceptions::Exception;

use Modern::Perl;

# Looks like this class should be more Koha::Exception::Base;
use Exception::Class (
    'Koha::Exceptions::Exception' => {
        description => "Something went wrong!"
    },
);

sub full_message {
    my $self = shift;
    my $msg = $self->description;
    my @fields;
    my $field_hash = $self->field_hash;
    while ( my ( $field, $value ) = each %$field_hash ) {
        push @fields, $field . " => " . $value;
    }
    return
      sprintf "Exception '%s' thrown '%s'" . ( @fields ? " with %s" : "" ) . "\n",
      ref($self), $msg, ( @fields ? join ', ', @fields : () );
}

1;
