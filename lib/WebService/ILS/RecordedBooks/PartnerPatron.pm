package WebService::ILS::RecordedBooks::PartnerPatron;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::RecordedBooks::PartnerPatron - RecordedBooks patner API
for an individual patron

=head1 SYNOPSIS

    use WebService::ILS::RecordedBooks::PartnerPatron;

=head1 DESCRIPTION

L<WebService::ILS::RecordedBooks::PartnerPatron> - services
that use trusted partner credentials to operat on behalf of a specified patron

See L<WebService::ILS::RecordedBooks::Partner>

=cut

use Carp;

use parent qw(WebService::ILS::RecordedBooks::PartnerBase);

=head1 CONSTRUCTOR

=head2 new (%params_hash or $params_hashref)

=head3 Additional constructor params:

=over 12

=item C<user_id>        => RecordedBooks user id (barcode), or email

=back

C<client_id> is either RecordedBooks id (barcode) or email

=cut

use Class::Tiny qw(
    user_id
);

__PACKAGE__->_set_param_spec({
    user_id => { required => 1 },
});

sub BUILD {
    my $self = shift;
    my $params = shift;

    local $@;
    my $patron_id = eval { $self->SUPER::patron_id($self->user_id) }
      or croak "Invalid user_id ".$self->user_id.($@ ? "\n$@" : "");
    $self->user_id($patron_id);
}

sub circulation_action_base_url {
    my $self = shift;

    return $self->library_action_base_url."/patrons/".$self->user_id;
}

sub patron_id {
    my $self = shift;
    return $self->user_id;
}

sub patron {
    my $self = shift;
    return {id => $self->user_id};
}

=head1 NATIVE METHODS

=head2 native_patron ()

This method cannot be called

=cut

1;

__END__

=head1 LICENSE

Copyright (C) Catalyst IT NZ Ltd
Copyright (C) Bywater Solutions

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Srdjan Janković E<lt>srdjan@catalyst.net.nzE<gt>

=cut
