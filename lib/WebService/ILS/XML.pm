package WebService::ILS::XML;

use Modern::Perl;

=encoding utf-8

=head1 NAME

WebService::ILS::JSON - WebService::ILS module for services with XML API

=head1 DESCRIPTION

To be subclassed

See L<WebService::ILS>

=cut

use Carp;
use HTTP::Request::Common;
use URI;
use XML::LibXML;

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
    return $self->process_xml_response($response, $callback);
}

sub with_delete_request {
    my $self = shift;
    my $callback = shift or croak "No callback";
    my $error_callback = shift;
    my $url = shift or croak "No url";

    my $request = HTTP::Request::Common::DELETE( $url );
    my $response = $self->_request_with_auth($request);
    return 1 if $response->is_success;

    return $self->_error_result(
        sub { $self->process_invalid_xml_response($response, $error_callback); },
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
    return $self->process_xml_response($response, $callback);
}

sub with_xml_request {
    my $self = shift;
    my $callback = shift or croak "No callback";
    my $error_callback = shift;
    my $url = shift or croak "No url";
    my $dom = shift or croak "No XML document";
    my $method = shift || 'post';

    my $req_builder = "HTTP::Request::Common::".uc( $method );
    no strict 'refs';
    my $request = $req_builder->( $url );
    $request->header( 'Content-Type' => 'application/xml; charset=utf-8' );
    $request->content( $dom->toeString );
    $request->header( 'Content-Length' => bytes::length($request->content));
    my $response = $self->_request_with_auth($request);
    return $self->process_xml_response($response, $callback, $error_callback);
}

sub process_xml_response {
    my $self = shift;
    my $response = shift or croak "No response";
    my $success_callback = shift;
    my $error_callback = shift;

    unless ($response->is_success) {
        return $self->process_xml_error_response($response, $error_callback);
    }

    my $content_type = $response->header('Content-Type');
    die $response->as_string
        unless $content_type && $content_type =~ m!application/xml!;
    my $content = $response->decoded_content
        or die $self->invalid_response_exception_string($response);

    local $@;

    my $doc = eval { XML::LibXML->load_xml( string => $content )->documentElement() };
    #XXX check XML::LibXML::Error
    die "$@\nResponse:\n".$response->as_string if $@;

    return $doc unless $success_callback;

    my $res = eval {
        $success_callback->($doc);
    };
    die "$@\nResponse:\n$content" if $@;
    return $res;
}

sub process_xml_error_response {
    my $self = shift;
    my $response = shift or croak "No response";
    my $error_callback = shift;

    my $content_type = $response->header('Content-Type');
    if ($content_type && $content_type =~ m!application/xml!) {
        my $content = $response->decoded_content
            or die $self->invalid_response_exception_string($response);

        my $doc = eval { XML::LibXML->load_xml( string => $content )->documentElement() };
        #XXX check XML::LibXML::Error
        die "$@\nResponse:\n$content" if $@;

        if ($error_callback) {
            return $error_callback->($doc);
        }

        die $self->_error_from_xml($doc) || "Invalid response:\n$content";
    }
    die $self->invalid_response_exception_string($response);
}

sub _error_from_xml {};

sub _first_child_content {
    my $self = shift;
    my $parent_elt = shift or croak "No parent element";
    my $tag = shift or croak "No child tag name";

    my $child_elts = $parent_elt->getElementsByTagName($tag) or return;
    my $child_elt = $child_elts->shift or return;
    return $child_elt->textContent;
}

sub _children_content {
    my $self = shift;
    my $parent_elt = shift or croak "No parent element";
    my $tag = shift or croak "No child tag name";

    my $child_elts = $parent_elt->getElementsByTagName($tag) or return;
    return [ $child_elts->map( sub { $_[0]->textContent } ) ];
}

sub _xml_to_hash {
    my $self = shift;
    my $parent_elt = shift or croak "No parent element";
    my $tags = shift or croak "No children tag names";

    return { map { $_ => $self->_first_child_content($parent_elt, $_) } @$tags };
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
