=encoding utf8

=head1 NAME

Mojolicious::Plugin::OpenAPI::CORS - CORS support for the Mojolicious plugin for OpenAPI

=head1 SYNOPSIS

  {
    "swagger": "2.0",
    "info": {...},
    "host": "petstore.openapi.wordnik.com",
    "basePath": "/api",
    "x-cors": {
      "x-cors-access-control-allow-origin-list": "*",
      "x-cors-access-control-allow-credentials": "true",
      "x-cors-access-control-allow-methods": "*",
      "x-cors-access-control-max-age": "3600"
    },
    "paths": {
      "/pets": {
        "x-cors-access-control-allow-origin-list": "/https://regexp.matching.domain/ https://my.trusted.domain:443",
        "x-cors-access-control-allow-credentials": "false",
        "get": {...},
        "post": {...}
      },
      "/pets/{id}": {
        "x-cors-access-control-allow-methods": "PUT",
        "put": {...},
        "delete": {...}
      }
    }
  }

=head1 DESCRIPTION

L<Mojolicious::Plugin::OpenAPI::CORS> is L<Mojolicious::Plugin::OpenAPI> extension
that adds support for CORS to your OpenAPI API.

The idea of this extension is to delegate worrying about CORS to the OpenAPI-system and help
keep programmers happy and productive!
You can define default CORS options in the root OpenAPI-element, and they are automatically
inherited to the REST endpoints.
You can also overload defaults from the OpenAPI "Path Item Object".

=head1 CORS options

These are the options to affect how your API endpoints react to CORS request.

You must define the '/x-cors' root object to enable CORS support in the OpenAPI plugin, including reasonable defaults:
  {
    "swagger": "2.0",
    "info": {...},
    ...
    "x-cors": {
      "x-cors-access-control-allow-origin-list": "*",
      "x-cors-access-control-allow-credentials": "true",
      "x-cors-access-control-allow-methods": "*",
      "x-cors-access-control-max-age": "3600"
    },
    ...
  }

Defaults can be overridden in the OpenAPI "Path Item Object". See SYNOPSIS on how to do that.

=head2 x-cors-access-control-allow-origin-list

Defines how the Access-Control-Allow-Origin response header is set.
Defaults to not allowed.
Supported values are:

* - Allow any Origin-header content

/regexp/ - Regular expression to match against the request Origin-header

https://cors.example.com:443 - Static Origin-header value.

MyApp::CORS::origin_whitelist() - Calls a subroutine to decide if the request's Origin-header
                                  is acceptable and what values to put to the response header.
                                  It must contain one or more '::' and end with () to be identified
                                  as a subroutine by the subsystem.

  ##Example of subroutine:
  #Parameters are a Mojolicious::Controller '$c' and a String '$origin'
  sub MyApp::CORS::origin_whitelist {
    my ($c, $origin) = @_;

    return $origin if 'origin is accepted';
    return undef if 'origin is not accepted';
  }

You can define a list of these values, and if any of the list values matches, the origin is accepted.

  "x-cors-access-control-allow-origin-list": "/cors.example.com/ http:/static.example.com:8080 MyApp::CORS::origin_whitelist()"

=head2 x-cors-access-control-allow-credentials

Defines how the Access-Control-Allow-Credentials response header is set.
Defaults to not allowed.
Mainly defines if cookies can be sent with the request. Allowed values are:

"true" - enable credentials

"false" - disable credentials, only useful when overriding default behaviour

=head2 x-cors-access-control-allow-methods

Defines how the Access-Control-Allow-Methods response header is set.
Defaults to no methods allowed.

Accepted values is a list of all the HTTP standard's HTTP verbs/methods, or * to tell
that all verbs/methods the path can receive are available.

  "x-cors-access-control-allow-methods": "GET, POST, PUT, HEAD"

=head2 x-cors-access-control-max-age

Defines how the Access-Control-Allow-Max-Age response header is set.
Defaults to 3600 seconds

Accepted value is an integer signifying the CORS preflight cache expiration duration in seconds.

=head2 x-cors-access-control-allow-headers

This is not implemented, and by default all headers are accepted.

=head2 x-cors-access-control-expose-headers

This is not implemented, and by default all headers are exposed.

=head1 Class subroutine definitions

=cut

package Mojolicious::Plugin::OpenAPI::CORS;

use constant DEBUG => $ENV{OPENAPI_DEBUG} || 0;

use Modern::Perl;

=head2 use_CORS

  my $xcors = $class->use_CORS($app, $openapi);

Are we using CORS in the OpenAPI-definition?
@param {Mojolicious} $app, the Mojolicious application derivative
@param {OpenAPI} $openapi, the OpenAPI-object containing the local OpenAPI-definition
@returns {HashRef} $xcors, the default OpenAPI-spec CORS options, if CORS is enabled, otherwise undef.

=cut

sub use_CORS {
  my ($class, $app, $openapi) = @_;

  my $xcors = $openapi->_validator->schema->get('/x-cors');
  if (not($xcors)) {
    warn "[OpenAPI][CORS] CORS is not needed. See the docs on how to enable it. Not installing preflight handlers or CORS configurations.\n" if DEBUG;
  }
  return $xcors;
}

=head2 set_default_CORS

  $class->set_default_CORS($route, $xcors);

Set default CORS settings for the given route. Is intended to be used for the root API route, from which the child routes can inherit settings.
@param {Mojolicious::Routes::Route} $r, route to CORS:erize
@param {HashRef} $xcors, CORS parameters from use_CORS()

=cut

sub set_default_CORS {
  my ($class, $r, $xcors) = @_;
  my $corsOpts = $class->get_opts(undef, $xcors, undef, undef);

  $r->to(%$corsOpts);
}

=head2 get_opts

  $class->get_opts($route_params, $xcors, $path, $pathSpec);

Get the CORS-options for the given definitions. API endpoint options override defaults.
@param {HashRef} $route_params, and existing Hash of parameters if you are collecting
                 parameters for a route definition, or if you want to include the
                 CORS-options to an existing data structure.
@param {HashRef} $xcors, default CORS-options from use_CORS();
@param {String} $path, OpenAPI-definition path-url to the API endpoint we are getting options for
@param {HashRef} $pathSpec, OpenAPI-operations for the API endpoint.

=cut

sub get_opts {
  my ($class, $route_params, $xcors, $path, $pathSpec) = @_;

  my $corsOpts = $route_params || {};
  if (my $credentials = $class->_handle_access_control_allow_credentials($xcors, $path, $pathSpec)) {
    $corsOpts->{'cors.credentials'} = ($credentials eq 'true') ? 1 : 0;
  }
  if (my $origin = $class->_handle_access_control_allow_origin($xcors, $path, $pathSpec)) {
    $corsOpts->{'cors.origin'} = $origin;
  }
  if (my $methods = $class->_handle_access_control_allow_methods($xcors, $path, $pathSpec)) {
    $corsOpts->{'cors.methods'} = $methods;
  }
  my $maxAge = $class->_handle_access_control_max_age($xcors, $path, $pathSpec);
  if (defined($maxAge)) { #Max age can be 0
    $corsOpts->{'cors.maxAge'} = $maxAge;
  }

  $corsOpts->{'cors.headers'} = qr/./msi; #Accept all headers as valid CORS headers
  $corsOpts->{'cors.expose'}  = qr/./msi; #Expose all headers for the client
  return $corsOpts;
}

=head2 _handle_access_control_allow_credentials

  my $boolean = $class->_handle_access_control_allow_credentials($xcors, $path, $pathSpec);

One or both of the params $xcors and $pathSpec must be defined.
@param {HashRef} $xcors, OpenAPI-specifications root definition 'x-cors', which should contain the default CORS options for the whole API.
@param {String} $path, path to this API endpoint.
@param {HashRef} $pathSpec, OpenAPI "Paths Object"
@returns {String Boolean}, 'true', if credentials allowed, 'false' if credentials are explicitly blocked, undef if this not defined and using default|inherited values.
@die if 'x-cors-access-control-allow-credentials' is not 'true' or 'false'. The directive can be missing altogether.

=cut

my $errorMsg_acac = "value for CORS header 'Access-Control-Allow-Credentials' must be 'true' or 'false' or the openapi-directive 'x-cors-access-control-allow-credentials' must not be defined at all.";
sub _handle_access_control_allow_credentials {
  my ($class, $xcors, $path, $pathSpec) = @_;

  my $default;
  if ($xcors) {
    $default = $xcors->{'x-cors-access-control-allow-credentials'};
    if ($default && $default !~ /^(?:true|false)$/) {
      my @cc = caller(0);
      die $cc[3].":> Default value '$default', $errorMsg_acac";
    }
  }

  my $pathOverride;
  if ($pathSpec) {
    $pathOverride = $pathSpec->{'x-cors-access-control-allow-credentials'};
    if ($pathOverride && $pathOverride !~ /^(?:true|false)$/) {
      my @cc = caller(0);
      die $cc[3].":> Path '$path' value '$pathOverride', $errorMsg_acac";
    }
  }
  return 'true' if  ($default && $default eq 'true'  && (not($pathOverride) || $pathOverride ne 'false')) || ($pathOverride && $pathOverride eq 'true');
  return 'false' if ($default && $default eq 'false' && (not($pathOverride) || $pathOverride ne 'true'))  || ($pathOverride && $pathOverride eq 'false');
  return undef;
}

my $errorMsg_acma = "value for CORS header 'Access-Control-Max-Age' must be an integer of seconds or the openapi-directive 'x-cors-access-control-max-age' must not be defined at all.";
sub _handle_access_control_max_age {
  my ($class, $xcors, $path, $pathSpec) = @_;

  my $default;
  if ($xcors) {
    $default = $xcors->{'x-cors-access-control-max-age'};
    if ($default && $default !~ /^\d+$/) {
      my @cc = caller(0);
      die $cc[3].":> Default value '$default', $errorMsg_acma";
    }
  }

  my $pathOverride;
  if ($pathSpec) {
    $pathOverride = $pathSpec->{'x-cors-access-control-max-age'};
    if ($pathOverride && $pathOverride !~ /^\d+$/) {
      my @cc = caller(0);
      die $cc[3].":> Path '$path' value '$pathOverride', $errorMsg_acma";
    }
  }
  return $pathOverride if defined($pathOverride);
  return $default if defined($default);
  return undef;
}

sub _handle_access_control_allow_origin {
  my ($class, $xcors, $path, $pathSpec) = @_;

  my $default;
  if ($xcors) {
    $default = $xcors->{'x-cors-access-control-allow-origin-list'};
  }

  my $pathOverride;
  if ($pathSpec) {
    $pathOverride = $pathSpec->{'x-cors-access-control-allow-origin-list'};
  }

  my $origins = $pathOverride || $default;
  return undef unless $origins;

  my @origins = map {
    if ($_ =~ m!^/(.*)/$!) { #This is a regexp, so cast it as such
      qr($1);
    }
    elsif ($_ =~ m!^(.+?::.+?)\(\)$!) { #This is a subroutine, so cast it as such
      \&{$1};
    }
    else {
      $_;
    }
  } split(/\s+/, $origins);
  return \@origins;
}

my $errorMsg_acam = "CORS directive 'x-cors-access-control-allow-methods' is not well formed. It should consist of a comma separated list of HTTP verbs, or be an empty string or a '*' to allow all methods or be completely missing from the OpenAPI-spec.";
sub _handle_access_control_allow_methods {
  my ($class, $xcors, $path, $pathSpec) = @_;

  my $_validate_acam = sub {
    my $acam = shift;
    return 1 if $acam eq '*';
    unless ($acam =~ /^(?&VERB)?(?:\s*,\s*(?&VERB))*$
                      (?(DEFINE)
                          (?<VERB>GET|HEAD|POST|PUT|DELETE|TRACE|OPTIONS|CONNECT|PATCH)
                      )/x) {
      return undef;
    }
    return 1;
  };

  my $default;
  if ($xcors) {
    $default = $xcors->{'x-cors-access-control-allow-methods'};
    unless (&$_validate_acam($default || '')) {
      my @cc = caller(0);
      die $cc[3].":> Default value '$default', $errorMsg_acam";
    }
  }

  my $pathOverride;
  if ($pathSpec) {
    $pathOverride = $pathSpec->{'x-cors-access-control-allow-methods'};
    unless (&$_validate_acam($pathOverride || '')) {
      my @cc = caller(0);
      die $cc[3].":> Path '$path' value '$pathOverride', $errorMsg_acam";
    }
  }

  my $realVal = $pathOverride || $default;
  if ($realVal) {
    my @realVals = split /\s*,\s*/ms, $realVal;
    my %good_methods = map {uc($_) => 1} @realVals;
    return \%good_methods
  }
  return undef;
}

=head2 is_CORS_request

  my $isCORS = $class->is_CORS_request($c);

@param {Mojolicious::Controller} $c, the controller of the request-response -cycle
@returns {Int Boolean}, 1 if this is a CORS-request, undef if not.

=cut

sub is_CORS_request {
  my ($class, $c) = @_;

  ##We can skip generating CORS headers if this request doesn't have a Origin-header.
  my $origin = $c->req->headers->origin;
  if (not($origin)) {
    return undef; #This is not a CORS-request, or if it is the browser will block the request.
  }
  my $absUrl = $c->req->url->to_abs;
  my $serverUrl = $absUrl->scheme.'://'.$absUrl->host;
  if ($origin =~ /^\Q$serverUrl\E/) {
    return undef; #Origin defined but is actually local host. Abort CORS.
  }

  return 1;
}


=head2 handle_simple_cors

  $class->handle_simple_cors($c);

Make a simple CORS check. Set CORS headers if check succeeds or there was no need for a CORS check,
or return 403 if request is unauthorized.
@param {Mojolicious::Controller} $c, the controller of the request-response -cycle
@returns {Boolean}, true, if request failed CORS authorization, undef if everything is ok.

=cut

sub handle_simple_cors {
  my ($class, $c) = @_;

  return undef if $c->stash('simple_cors_checked'); #We might check CORS in x-mojo-around-action -hook already, prevent adding same headers twice.
  return undef if lc $c->tx->req->method() eq 'options'; #OPTIONS-request cannot be a "simple CORS" -request and most likely is a preflight request, or should behave as such.
  return undef unless $class->is_CORS_request($c);

  my $h = $c->res->headers;
  $h->append(Vary => 'Origin'); #Set this to prevent caching whatever result we return

  my @errors;

  ##For simple CORS we need less headers
  _cors_response_check_origin($c, $h, $c->stash('cors.origin'), \@errors);

  ## Report CORS errors ##
  return \@errors if @errors;

  ## Access-Control-Allow-Credentials ##
  $h->header('Access-Control-Allow-Credentials' => 'true') if ($c->stash('cors.credentials'));

  #All is fine! Headers set! Full speed ahead!
  $c->stash(simple_cors_checked => 1);
  return undef;
}

=head2 handle_preflight_cors

  my $errors = $class->handle_preflight_cors($c); #Sets CORS headers
  $c->render(status => 200, data => {}) unless $errors;

Handles the CORS preflight-request.
Simply sets the required headers or returns a list of possible errors.
This is intended to enhance the original OPTIONS-request handler, not substitute it.
@param {Mojolicious::Controller} $c, the controller of the request-response -cycle
@returns {ArrayRef} of errors, if request failed CORS authorization, empty ArrayRef if everything is ok.

=cut

sub handle_preflight_cors {
  my ($class, $c) = @_;

  return undef unless $class->is_CORS_request($c);

  my $h = $c->res->headers;
  $h->append(Vary => 'Origin'); #Set this to prevent caching whatever result we return

  my @errors; #Collect all CORS errors here before returning a possible failure message

  ## Access-Control-Allow-Origin ##
  _cors_response_check_origin($c, $h, $c->stash('cors.origin'), \@errors);

  ## Access-Control-Allow-Methods ##
  _cors_response_check_method($c, $h, $c->stash('cors.methods'), \@errors);

  ## Report CORS errors, before headers are attached to the request ##
  return \@errors if @errors;

  ## Access-Control-Allow-Headers  ## Allow all headers. There can be potentially gazillion headers and checking all of them is expensive O(n^2)
  ## Access-Control-Expose-Headers ##
  my $headers = $c->req->headers->header('Access-Control-Request-Headers');
  if ($headers) {
    $h->header('Access-Control-Allow-Headers'  => $headers);
    $h->header('Access-Control-Expose-Headers' => $headers);
  }

  ## Access-Control-Allow-Credentials ##
  $h->header('Access-Control-Allow-Credentials' => 'true') if ($c->stash('cors.credentials'));

  ## Access-Control-Max-Age ##
  $h->header('Access-Control-Max-Age' => $c->stash('cors.maxAge') || 3600);

  return undef;
}

=head2 _cors_response_check_origin

  my $errors = _cors_response_check_origin($controller, $headers, $opt);

@param {Mojolicious::Controller} $c
@param {Mojo::Headers} $h
@param {HashRef} $opt, CORS options
@param {ArrayRef} $errors, Any previous errors happened when processing the CORS
@returns {ArrayRef of Strings}, the error descriptions if errors happened

=cut

sub _cors_response_check_origin {
  my ($c, $h, $allowedOrigins, $errors) = @_;
  $errors = [] unless $errors;
  my $origin = $c->req->headers->origin;
  my $originOk;
  $allowedOrigins = ['*'] unless $allowedOrigins; # default allow all
  if (ref $allowedOrigins eq 'ARRAY') {
    foreach my $ao (@$allowedOrigins) {
      if ((ref $ao eq 'Regexp' && $origin =~ /$ao/ms) || #Match regexp
          (ref $ao eq 'CODE' && &$ao($c, $origin))    || #Match dynamic subroutine
          $ao eq '*' ||                                  #Match anything
          $ao eq $origin                                 #Exact match
          ) {
        $originOk = 1;
        $h->header('Access-Control-Allow-Origin' => $origin) if(not(@$errors));
        return;
      }
    }
  }
  push @$errors, "Origin '$origin' not allowed" if not($originOk);
}

sub _cors_response_check_method {
  my ($c, $h, $allowedMethods, $errors) = @_;
  $errors = [] unless $errors;

  my $method = $c->req->headers->header('Access-Control-Request-Method');
  my $methodOk;
  $allowedMethods = { '*' => 1 } unless $allowedMethods; # default allow all
  if (ref $allowedMethods eq 'HASH') {
    if ($allowedMethods->{'*'}) {
      $methodOk = 1;
      my $allMethods = join(', ', map {uc($_)} sort(@{$c->stash('available_methods')})) if $c->stash('available_methods');
      $h->header('Access-Control-Allow-Methods' => $allMethods || $method) if(not(@$errors));
    }
    elsif ($allowedMethods->{uc($method)}) {
      $methodOk = 1;
      $h->header('Access-Control-Allow-Methods' => join(', ', sort(keys(%$allowedMethods)))) if(not(@$errors));
    }
  }
  push @$errors, "Method '$method' not allowed" if not($methodOk);
}

1;
