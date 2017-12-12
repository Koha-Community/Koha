package t::Mojolicious::Plugin::OpenAPI::CORS::Helpers;

=head1 IN THIS FILE

We implement test subroutines to test CORS operations.

=cut

=head2 origin_whitelist

Used to test the "x-cors-access-control-allow-origin-list" CORS option.

@param {Mojolicious::Controller} $c
@param {String} $origin, the origin to accept or deny.
@returns {String or undef}, The $origin if it is accepted or undef.

=cut

use Scalar::Util qw(blessed);

sub origin_whitelist {
  my ($c, $origin) = @_;
  my @cc = caller(0);
  die $cc[3]."($c, $origin):> \$c '$c' is not a Mojolicious::Controller!" unless(blessed($c) && $c->isa('Mojolicious::Controller'));
  return $origin if($origin && $origin =~ /example/);
  return undef;
}

=head2 fake_authenticate

Implements the OpenAPI::Guides::ProtectedApi to authenticate using x-mojo-around-action

By default fails all requests with HTTP status 401

Increments $ENV{'OPENAPI-CORS-FAKE-AUTHENTICATE'} every time this subroutine is called.

@returns {undef} but renders 401 and JSON error.

=cut

sub fake_authenticate {
  my ($next, $c, $opObj) = @_;

  $ENV{'OPENAPI-CORS-FAKE-AUTHENTICATE'} = 0 unless $ENV{'OPENAPI-CORS-FAKE-AUTHENTICATE'};
  $ENV{'OPENAPI-CORS-FAKE-AUTHENTICATE'}++;

  return $c->render(
    json => {errors => [{message => "Always fail auth", path => "/"}]},
    status => 401
  );
}

1; #Make compiler happy!
