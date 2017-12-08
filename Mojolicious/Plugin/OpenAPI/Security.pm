package Mojolicious::Plugin::OpenAPI::Security;
use Mojo::Base -base;

sub register {
  my ($self, $app, $openapi, $config) = @_;
  my $handlers = $config->{security} or return;

  return unless $openapi->validator->get('/securityDefinitions');
  return $openapi->route(
    $openapi->route->under('/')->to(cb => $self->_build_action($openapi, $handlers)));
}

sub _build_action {
  my ($self, $openapi, $handlers) = @_;
  my $global = $openapi->validator->get('/security') || [];
  my $definitions = $openapi->validator->get('/securityDefinitions');

  return sub {
    my $c = shift;
    return 1 if $c->req->method eq 'OPTIONS' and $c->match->stack->[-1]{'openapi.default_options'};

    my $spec = $c->openapi->spec || {};
    my @security_or = @{$spec->{security} || $global};
    my %res;

    return 1 unless @security_or;    # Nothing to check

    $c->delay(
      sub {
        my ($delay) = @_;

        for my $security_and (@security_or) {
          for my $name (keys %$security_and) {
            next if exists $res{$name};
            my $scb = $handlers->{$name};
            $res{$name} = ["No security callback for $name."] and next unless $scb;
            $res{$name} = undef;
            my $dcb = $delay->begin;
            $c->$scb(
              $definitions->{$name},
              $security_and->{$name},
              sub { $res{$name} //= $_[1]; $dcb->(); }
            );
          }
        }

        $delay->pass;    # Make sure we go to the next step
      },
      sub {
        my ($delay) = @_;
        my ($i, @errors) = (0);

        for my $security_and (@security_or) {
          my @e;
          for my $name (sort keys %$security_and) {
            my $path = sprintf '/security/%s/%s', $i, _pointer_escape($name);
            push @e, ref $res{$name} ? $res{$name} : {message => $res{$name}, path => $path}
              if defined $res{$name};
          }

          return $c->continue unless @e;    # Success!
          push @errors, @e;
          $i++;
        }

        $c->render(openapi => {errors => \@errors}, status => 401);
      },
    );

    return undef;
  };
}

sub _pointer_escape { local $_ = shift; s/~/~0/g; s!/!~1!g; $_; }

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::OpenAPI::Security - OpenAPI plugin for securing your API

=head1 DESCRIPTION

This plugin will allow you to use the security features provided by the OpenAPI
specification.

Note that this is currently EXPERIMENTAL! Please let me know if you have any
feedback. See L<https://github.com/jhthorsen/mojolicious-plugin-openapi/pull/40> for a
complete discussion.

=head1 TUTORIAL

=head2 Specification

Here is an example specification that use
L<securityDefinitions|http://swagger.io/specification/#securityDefinitionsObject>
and L<security|http://swagger.io/specification/#securityRequirementObject> from
the OpenAPI spec:

  {
    "swagger": "2.0",
    "info": { "version": "0.8", "title": "Super secure" },
    "schemes": [ "https" ],
    "basePath": "/api",
    "securityDefinitions": {
      "dummy": {
        "type": "apiKey",
        "name": "Authorization",
        "in": "header",
        "description": "dummy"
      }
    },
    "paths": {
      "/protected": {
        "post": {
          "x-mojo-to": "super#secret_resource",
          "security": [{"dummy": []}],
          "parameters": [
            { "in": "body", "name": "body", "schema": { "type": "object" } }
          ],
          "responses": {
            "200": {"description": "Echo response", "schema": { "type": "object" }},
            "401": {"description": "Sorry mate", "schema": { "type": "array" }}
          }
        }
      }
    }
  }

=head2 Application

The specification above can be dispatched to handlers inside your
L<Mojolicious> application. The do so, add the "security" key when loading the
plugin, and reference the "securityDefinitions" name inside that to a callback.
In this example, we have the "dummy" security handler:

  package Myapp;
  use Mojo::Base "Mojolicious";

  sub startup {
    my $app = shift;

    $app->plugin(OpenAPI => {
      url      => "data://main/sec.json",
      security => {
        dummy => sub {
          my ($c, $definition, $scopes, $cb) = @_;
          return $c->$cb() if $c->req->headers->authorization;
          return $c->$cb('Authorization header not present');
        }
      }
    });
  }

  1;

C<$c> is a L<Mojolicious::Controller> object. C<$definition> is the security
definition from C</securityDefinitions>. C<$scopes> is the Oauth scopes, which
in this case is just an empty array ref, but it will contain the value for
"security" under the given HTTP method.

Call C<$cb> with C<undef> or no argument at all to indicate pass. Call C<$cb>
with a defined value (usually a string) to indicate that the check has failed.
When none of the sets of security restrictions are satisfied, the standard
OpenAPI structure is built using the values passed to the callbacks as the
messages and rendered to the client with a status of 401.

Note that the callback must be called or the dispatch will hang.

See also L<Mojolicious::Plugin::OpenAPI/SYNOPSIS> for example
L<Mojolicious::Lite> application.

=head2 Controller

Your controllers and actions are unchanged. The difference in behavior is that
the action simply won't be called if you fail to pass the security tests.

=head2 Exempted routes

All of the routes created by the plugin are protected by the security
defintions with the following exemptions.  The base route that renders the
spec/documentation is exempted.  Additionally, when a route does not define its
own C<OPTIONS> handler a documentation endpoint is generated which is exempt as
well.

=head1 METHODS

=head2 register

Called by L<Mojolicious::Plugin::OpenAPI>.

=head1 SEE ALSO

L<Mojolicious::Plugin::OpenAPI>.

=cut
