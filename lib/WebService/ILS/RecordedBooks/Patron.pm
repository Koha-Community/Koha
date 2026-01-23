package WebService::ILS::RecordedBooks::Patron;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::RecordedBooks::Patron - RecordedBooks patron API

=head1 SYNOPSIS

    use WebService::ILS::RecordedBooks::Patron;

=cut

=head1 DESCRIPTION

L<WebService::ILS::RecordedBooks::Patron> - services
that require patron credentials

See L<WebService::ILS::RecordedBooks>

=cut

use Carp;

use parent qw(WebService::ILS::RecordedBooks);

=head1 CONSTRUCTOR

=head2 new (%params_hash or $params_hashref)

=head3 Additional constructor params:

=over 16

=item C<user_id>

=item C<password>

=back

=cut

use Class::Tiny qw(
    user_id password
);

__PACKAGE__->_set_param_spec({
    user_id       => { required => 1 },
    password      => { required => 1 },
});


sub _access_auth_string {
    my $self = shift;
    return $self->client_secret;
}

sub _extract_token_from_response {
    my $self = shift;
    my $data = shift;

    return ($data->{bearer}, "bearer");
}

sub make_access_token_request {
    my $self = shift;

    my $url = $self->api_url("/tokens");
    my %params = (
        UserName => $self->user_id,
        Password => $self->password,
        LibraryId => $self->library_id,
    );
    my $req = HTTP::Request::Common::POST( $url );
    return $self->_json_request_content($req, \%params);
}

sub title_url {
    my $self = shift;
    my $isbn = shift or croak "No isbn";
    return $self->api_url("/titles/$isbn");
}

sub circulation_action_base_url {
    my $self = shift;

    return $self->api_url("/transactions");
}

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
