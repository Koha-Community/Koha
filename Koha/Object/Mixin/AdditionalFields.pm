package Koha::Object::Mixin::AdditionalFields;

use Modern::Perl;

=head1 NAME

Koha::Object::Mixin::AdditionalFields

=head1 SYNOPSIS

    package Koha::Foo;

    use parent qw( Koha::Object Koha::Object::Mixin::AdditionalFields );

    sub _type { 'Foo' }


    package main;

    use Koha::Foo;

    Koha::Foos->find($id)->set_additional_fields(...);

=head1 API

=head2 Public methods

=head3 set_additional_fields

    $foo->set_additional_fields([
        {
            id => 1,
            value => 'foo',
        },
        {
            id => 2,
            value => 'bar',
        }
    ]);

=cut

sub set_additional_fields {
    my ($self, $additional_fields) = @_;

    my $rs = Koha::Database->new->schema->resultset('AdditionalFieldValue');

    foreach my $additional_field (@$additional_fields) {
        my $field_value = $rs->find_or_new({
            field_id => $additional_field->{id},
            record_id => $self->id,
        });
        my $value = $additional_field->{value};
        if (defined $value) {
            $field_value->set_columns({ value => $value })->update_or_insert;
        } elsif ($field_value->in_storage) {
            $field_value->delete;
        }
    }
}

sub additional_field_values {
    my ($self) = @_;

    return $self->_result->additional_field_values;
}

1;
