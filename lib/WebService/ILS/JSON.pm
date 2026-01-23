package WebService::ILS::JSON;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::JSON - WebService::ILS module for services with JSON API

=head1 DESCRIPTION

To be subclassed

See L<WebService::ILS>

=cut

use Carp;
use HTTP::Request::Common;
use JSON qw(encode_json);
use URI;

use parent qw(WebService::ILS);

sub with_get_request {
    my $self = shift;
    my $callback = shift or croak "No callback";
    my $url = shift or croak "No url";
    my $get_params = shift; # hash ref

    my $uri = URI->new($url);
    $uri->query_form($get_params) if $get_params;
    my $request = HTTP::Request::Common::GET( $uri );
    my $response = $self->_request_with_auth($request);
    return $self->process_json_response($response, $callback);
}

sub with_delete_request {
    my $self = shift;
    my $callback = shift or croak "No callback";
    my $error_callback = shift;
    my $url = shift or croak "No url";

    my $request = HTTP::Request::Common::DELETE( $url );
    my $response = $self->_request_with_auth($request);
    return $response->content ? $self->process_json_response($response, $callback) : 1
      if $response->is_success;

    return $self->_error_result(
        sub { $self->process_json_error_response($response, $error_callback); },
        $request,
        $response
    );
}

sub with_post_request {
    my $self = shift;
    my $callback = shift or croak "No callback";
    my $url = shift or croak "No url";
    my $post_params = shift || {}; # hash ref

    my $request = HTTP::Request::Common::POST( $url, $post_params );
    my $response = $self->_request_with_auth($request);
    return $self->process_json_response($response, $callback);
}

# This will probably not suit everyone
sub with_put_request {
    my $self = shift;
    my $callback = shift or croak "No callback";
    my $url = shift or croak "No url";
    my $put_params = shift;

    my $request = HTTP::Request::Common::PUT( $url );
    my $content;
    if ($put_params) {
        my $url = URI->new('http:');
        $url->query_form(ref($put_params) eq "HASH" ? %$put_params : @$put_params);
        $content = $url->query;
    }
    if( $content ) {
        # HTML/4.01 says that line breaks are represented as "CR LF" pairs (i.e., `%0D%0A')
        $content =~ s/(?<!%0D)%0A/%0D%0A/go;

        $request->content_type("application/x-www-form-urlencoded");
        $request->content_length(length $content);
        $request->content($content);
    }
    else {
        $request->content_length(0);
    }

    my $response = $self->_request_with_auth($request);
    return $self->process_json_response($response, $callback);
}

sub with_json_request {
    my $self = shift;
    my $callback = shift or croak "No callback";
    my $error_callback = shift;
    my $url = shift or croak "No url";
    my $post_params = shift || {}; # hashref
    my $method = shift || 'post';

    my $req_builder = "HTTP::Request::Common::".uc( $method );
    no strict 'refs';
    my $request = $req_builder->( $url );
    $self->_json_request_content($request, $post_params);
    my $response = $self->_request_with_auth($request);
    return $self->process_json_response($response, $callback, $error_callback);
}

sub _json_request_content {
    my $self = shift;
    my $request = shift or croak "No request";
    my $data = shift or croak "No data"; # hashref

    $request->header( 'Content-Type' => 'application/json; charset=utf-8' );
    $request->content( encode_json($data) );
    $request->header( 'Content-Length' => bytes::length($request->content));
    return $request;
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
