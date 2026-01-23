package WebService::ILS::OverDrive::Library;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::OverDrive::Library - WebService::ILS module for OverDrive
discovery only services

=head1 SYNOPSIS

    use WebService::ILS::OverDrive::Library;

=head1 DESCRIPTION

See L<WebService::ILS::OverDrive>

=cut

use Carp;
use HTTP::Request::Common;

use parent qw(WebService::ILS::OverDrive);

__PACKAGE__->_set_param_spec({
    library_id        => { required => 1, defined => 1 },
});

sub make_access_token_request {
    my $self = shift;

    return HTTP::Request::Common::POST( 'https://oauth.overdrive.com/token', {
        grant_type => 'client_credentials'
    } );
}

sub collection_token {
    my $self = shift;

    if (my $collection_token = $self->SUPER::collection_token) {
        return $collection_token;
    }

    $self->native_library_account;
    my $collection_token = $self->SUPER::collection_token
      or die "Library has no collections\n";
    return $collection_token;
}

=head1 NATIVE METHODS

=head2 native_library_account ()

See L<https://developer.overdrive.com/apis/library-account>

=cut

sub native_library_account {
    my $self = shift;

    my $library = $self->get_response($self->library_url);
    if (my $collection_token = $library->{collectionToken}) {
        $self->SUPER::collection_token( $collection_token);
    }
    return $library;
}

# Discovery helpers

sub library_url {
    my $self = shift;
    return $self->discovery_action_url("/libraries/".$self->library_id);
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
