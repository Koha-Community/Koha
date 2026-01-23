package WebService::ILS::RecordedBooks::PartnerBase;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::RecordedBooks::PartnerBase - RecordedBooks partner API

=head1 SYNOPSIS

See L<WebService::ILS::RecordedBooks::Partner>
and L<WebService::ILS::RecordedBooks::PartnerPatron>;

=cut

use Carp;
use URI::Escape;

use parent qw(WebService::ILS::RecordedBooks);

sub title_url {
    my $self = shift;
    my $isbn = shift or croak "No isbn";
    return $self->library_action_base_url."/titles/$isbn";
}

sub _request_with_token {
    my $self = shift;
    my $request = shift or croak "No request";

    $request->header( Authorization => "Basic ".$self->client_secret );
    return $self->user_agent->request( $request );
}

=head1 CIRCULATION METHOD SPECIFICS

=cut

use constant NATIVE_PATRON_ID_KEY => "patronId";
my %PATRON_XLATE = (
    NATIVE_PATRON_ID_KEY() => 'id',
);
sub patron {
    my $self = shift;
    return $self->_result_xlate($self->native_patron(@_), \%PATRON_XLATE);
}

=head2 patron_id ($email_or_id)

=cut

sub patron_id {
    my $self = shift;
    my $patron = $self->native_patron(@_) or return;
    return $patron->{NATIVE_PATRON_ID_KEY()};
}

=head1 NATIVE METHODS

=head2 native_patron ($email_or_id)

=cut

sub native_patron {
    my $self = shift;
    my $cardnum_or_email = shift or croak "No patron identification";

    my $url = $self->api_url("/rpc/libraries/".$self->library_id."/patrons/".uri_escape($cardnum_or_email));
    return $self->get_response($url);
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
