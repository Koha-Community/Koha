package Koha::Objects::Mixin::AdditionalFields;

use Modern::Perl;

=head1 NAME

Koha::Objects::Mixin::AdditionalFields

=head1 SYNOPSIS

    package Koha::Foos;

    use parent qw( Koha::Objects Koha::Objects::Mixin::AdditionalFields );

    sub _type { 'Foo' }
    sub object_class { 'Koha::Foo' }


    package main;

    use Koha::Foos;

    Koha::Foos->search_additional_fields(...)

=head1 API

=head2 Public methods

=head3 search_additional_fields

    my @objects = Koha::Foos->search_additional_fields([
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

sub search_additional_fields {
    my ($class, $additional_fields) = @_;

    my %conditions;
    my $idx = 0;
    foreach my $additional_field (@$additional_fields) {
        ++$idx;
        my $alias = $idx > 1 ? "additional_field_values_$idx" : "additional_field_values";
        $conditions{"$alias.field_id"} = $additional_field->{id};
        $conditions{"$alias.value"} = { -like => '%' . $additional_field->{value} . '%'};
    }

    return $class->search(\%conditions, { join => [ ('additional_field_values') x $idx ] });
}

1;
