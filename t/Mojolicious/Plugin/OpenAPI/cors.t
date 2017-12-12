use Modern::Perl;

use Test::Mojo;
use Test::More;
use Mojo::Parameters;
use Mojolicious;

require_ok('Mojolicious::Plugin::OpenAPI');
use Mojolicious::Plugin::OpenAPI;

require_ok('Mojolicious::Plugin::OpenAPI::CORS');
use Mojolicious::Plugin::OpenAPI::CORS;

require_ok('t::Mojolicious::Plugin::OpenAPI::CORS::Helpers');
use t::Mojolicious::Plugin::OpenAPI::CORS::Helpers;

my $app = make_app();

subtest "CORS internals", \&CORSInternals;
sub CORSInternals {
  my ($xcors, $openapipath, $openapipathSpec, $retVal);

  ##########################
  ### x-cors happy path! ###
  ##x-cors defaults
  $xcors = {
    'x-cors-access-control-allow-origin-list' => 'http://cors.example.com /^https:\/\/.*kirjasto.*$/ t::Mojolicious::Plugin::OpenAPI::CORS::Helpers::origin_whitelist()',
    'x-cors-access-control-allow-credentials' => 'true',
    'x-cors-access-control-allow-methods' => 'GET, POST, DELETE',
  };

  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_origin($xcors, undef, undef);
  is($retVal->[0], 'http://cors.example.com', 'Default _handle_access_control_allow_origin() static url');
  is(ref $retVal->[1], 'Regexp', 'Default _handle_access_control_allow_origin() regexp');
  my $regexp = $retVal->[1];
  ok('https://testi.kirjasto.fi:9999' =~ /$regexp/, 'Default _handle_access_control_allow_origin() regexp successfully parsed');
  is(ref $retVal->[2], 'CODE', 'Default _handle_access_control_allow_origin() subroutine');
  is(&{$retVal->[2]}(Mojolicious::Controller->new, 'http://cors.example.com:8080'), 'http://cors.example.com:8080', 'Default _handle_access_control_allow_origin() subroutine works!');
  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_credentials($xcors, undef, undef);
  is($retVal, 'true', 'Default _handle_access_control_allow_credentials()');
  $retVal = [sort(keys(%{Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_methods($xcors, undef, undef)}))];
  is($retVal->[0], 'DELETE', 'Default _handle_access_control_allow_methods()');
  is($retVal->[1], 'GET',    'Default _handle_access_control_allow_methods()');
  is($retVal->[2], 'POST',   'Default _handle_access_control_allow_methods()');

  ##x-cors path spec
  $openapipath = '/api/cors-pets';
  $openapipathSpec = {
    'x-cors-access-control-allow-origin-list' => '*',
    'x-cors-access-control-allow-credentials' => 'false',
    'x-cors-access-control-allow-methods' => 'HEAD',
  };

  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_origin(undef, $openapipath, $openapipathSpec);
  is($retVal->[0], '*', 'Path not implemented _handle_access_control_allow_origin()');
  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_credentials(undef, $openapipath, $openapipathSpec);
  is($retVal, 'false', 'Path _handle_access_control_allow_credentials()');
  $retVal = [sort(keys(%{Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_methods(undef, $openapipath, $openapipathSpec)}))];
  is($retVal->[0], 'HEAD', 'Path _handle_access_control_allow_methods()');

  ##x-cors path undef
  $openapipathSpec = {};
  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_origin(undef, $openapipath, $openapipathSpec);
  is($retVal, undef, 'Path undef _handle_access_control_allow_origin()');
  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_credentials(undef, $openapipath, $openapipathSpec);
  is($retVal, undef, 'Path undef _handle_access_control_allow_credentials()');
  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_methods(undef, $openapipath, $openapipathSpec);
  is($retVal, undef, 'Path _handle_access_control_allow_methods()');


  ##########################
  ### x-cors error cases ###
  ##x-cors defaults
  $xcors = {
    'x-cors-access-control-allow-origin-list' => 'this is bad',
    'x-cors-access-control-allow-credentials' => 'trueish',
    'x-cors-access-control-allow-methods' => 'SLARP, SLURP, DARP',
  };

  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_origin($xcors, undef, undef);
  is($retVal->[0], 'this', 'Default error cannot be detected _handle_access_control_allow_origin()');
  is($retVal->[1], 'is',   'Default error cannot be detected _handle_access_control_allow_origin()');
  is($retVal->[2], 'bad',  'Default er  ror cannot be detected _handle_access_control_allow_origin()');
  eval {$retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_credentials($xcors, undef, undef)};
  ok($@ =~ /value for CORS header 'Access-Control-Allow-Credentials' must be 'true'/, 'Default error _handle_access_control_allow_credentials()');
  eval {$retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_methods($xcors, undef, undef)};
  ok($@ =~ /CORS directive 'x-cors-access-control-allow-methods' is not well formed./, 'Default error _handle_access_control_allow_methods()');

  ################################
  ### x-cors default overloads ###
  $xcors = {
    'x-cors-access-control-allow-origin-list' => 'http://cors.example.com /^.*kirjasto.*$/',
    'x-cors-access-control-allow-credentials' => 'true',
    'x-cors-access-control-allow-methods' => 'GET, POST, DELETE',
  };
  $openapipath = '/api/cors-pets';
  $openapipathSpec = {
    'x-cors-access-control-allow-origin-list' => '*',
    'x-cors-access-control-allow-credentials' => 'false',
    'x-cors-access-control-allow-methods' => '*',
  };

  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_origin($xcors, $openapipath, $openapipathSpec);
  is($retVal->[0], '*', 'Default overloaded _handle_access_control_allow_origin()');
  $retVal = Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_credentials($xcors, $openapipath, $openapipathSpec);
  is($retVal, 'false', 'Default overloaded _handle_access_control_allow_credentials()');
  $retVal = [sort(keys(%{Mojolicious::Plugin::OpenAPI::CORS->_handle_access_control_allow_methods($xcors, $openapipath, $openapipathSpec)}))];
  is($retVal->[0], '*', 'Default overloaded _handle_access_control_allow_methods()');

  ##x-cors path spec

}

subtest "Simple CORS", \&simpleCORS;
sub simpleCORS {
  my ($t, $ua, $tx, $headers, $json, $body);

  $t = Test::Mojo->new($app);
  $t->app->plugin(OpenAPI => {url => "data://main/preflight.json"});

  ## Make a GET request from remote Origin ##
  $ua = $t->ua;
  $tx = $ua->build_tx(GET => '/api/cors-pets' => {Accept => '*/*'});
  $tx->req->headers->add('Origin' => 'http://cors.example.com:9999');
  $tx = $ua->start($tx);

  is($tx->res->code, 200, "GET request 200 from allowed Origin");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      'http://cors.example.com:9999',   "Access-Control-Allow-Origin");
  is($headers->header('Access-Control-Allow-Methods'),     undef,                            "Access-Control-Allow-Methods undef");
  is($headers->header('Access-Control-Allow-Headers'),     undef,                            "Access-Control-Allow-Headers undef");
  is($headers->header('Access-Control-Expose-Headers'),    undef,                            "Access-Control-Expose-Headers undef");
  is($headers->header('Access-Control-Allow-Credentials'), 'true',                            "Access-Control-Allow-Credentials true");
  $json = $tx->res->json;
  is($json->{pet1}, 'George',   "Got George...");
  is($json->{pet2}, 'Georgina', "...and Georgina");

  ## Make a GET request from remote Origin using a dynamic Origin handler ##
  $ua = $t->ua;
  $tx = $ua->build_tx(GET => '/api/cors-humans' => {Accept => '*/*'});
  $tx->req->headers->add('Origin' => 'http://cors.example.com:9999');
  $tx = $ua->start($tx);

  is($tx->res->code, 200, "GET request 200 from allowed Origin using the dynamic Origin handler");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      'http://cors.example.com:9999',   "Access-Control-Allow-Origin");
  is($headers->header('Access-Control-Allow-Methods'),     undef,                            "Access-Control-Allow-Methods undef");
  is($headers->header('Access-Control-Allow-Headers'),     undef,                            "Access-Control-Allow-Headers undef");
  is($headers->header('Access-Control-Expose-Headers'),    undef,                            "Access-Control-Expose-Headers undef");
  is($headers->header('Access-Control-Allow-Credentials'), 'true',                           "Access-Control-Allow-Credentials true");
  $json = $tx->res->json;
  is($json->{pet1}, 'George',   "Got George...");
  is($json->{pet2}, 'Georgina', "...and Georgina");

  ## Make a GET request from remote Origin, but we wont permit it. ##
  $ua = $t->ua;
  $tx = $ua->build_tx(GET => '/api/cors-pets' => {Accept => '*/*'});
  $tx->req->headers->add('Origin' => 'http://fake-cors.example.com:9999');
  $tx = $ua->start($tx);

  is($tx->res->code, 403, "GET request 403 from disallowed Origin");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      undef, "Access-Control-Allow-Origin undef");
  is($headers->header('Access-Control-Allow-Methods'),     undef, "Access-Control-Allow-Methods undef");
  is($headers->header('Access-Control-Allow-Headers'),     undef, "Access-Control-Allow-Headers undef");
  is($headers->header('Access-Control-Expose-Headers'),    undef, "Access-Control-Expose-Headers undef");
  is($headers->header('Access-Control-Allow-Credentials'), undef, "Access-Control-Allow-Credentials undef");
  $json = $tx->res->json;
  is($json->{errors}->[0], "Origin 'http://fake-cors.example.com:9999' not allowed", "Origin not allowed");

  ## Make a GET request from local domain ##
  $ua = $t->ua;
  $tx = $ua->build_tx(GET => '/api/cors-pets' => {Accept => '*/*'});
  $tx = $ua->start($tx);

  is($tx->res->code, 200, "GET request 200 from local domain");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      undef, "Access-Control-Allow-Origin undef");
  is($headers->header('Access-Control-Allow-Methods'),     undef, "Access-Control-Allow-Methods undef");
  is($headers->header('Access-Control-Allow-Headers'),     undef, "Access-Control-Allow-Headers undef");
  is($headers->header('Access-Control-Expose-Headers'),    undef, "Access-Control-Expose-Headers undef");
  is($headers->header('Access-Control-Allow-Credentials'), undef, "Access-Control-Allow-Credentials undef");
  $json = $tx->res->json;
  is($json->{pet1}, 'George',   "Got George...");
  is($json->{pet2}, 'Georgina', "...and Georgina");

  #Make a DELETE request from same domain with same origin. This should be allowed since it is actually not a CORS request.
  $ua = $t->ua;
  $tx = $ua->build_tx(DELETE => '/api/cors-pets/1024' => {Accept => '*/*'});
  $tx->req->headers->add('Origin' => 'http://127.0.0.1:9999');
  $tx = $ua->start($tx);

  is($tx->res->code, 204, "DELETE response 204 from local domain with local Origin");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      undef, "Access-Control-Allow-Origin undef");
  is($headers->header('Access-Control-Allow-Methods'),     undef, "Access-Control-Allow-Methods undef");
  is($headers->header('Access-Control-Allow-Headers'),     undef, "Access-Control-Allow-Headers undef");
  is($headers->header('Access-Control-Expose-H      "x-cors-access-control-allow-methods": "DELETE",
      "x-cors-access-control-allow-credentials": "false",eaders'),    undef, "Access-Control-Expose-Headers undef");
  is($headers->header('Access-Control-Allow-Credentials'), undef, "Access-Control-Allow-Credentials undef");
  is($tx->res->body, '', "Delete ok");

  #Make a DELETE request from a strange origin without a preflight-request. This must fail!
  $ua = $t->ua;
  $tx = $ua->build_tx(DELETE => '/api/cors-pets/1024' => {Accept => '*/*'});
  $tx->req->headers->add('Origin' => 'http://fake-cors.example.com:9999');
  $tx = $ua->start($tx);

  is($tx->res->code, 403, "DELETE response 403 from strange Origin");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      undef, "Access-Control-Allow-Origin undef");
  is($headers->header('Access-Control-Allow-Methods'),     undef, "Access-Control-Allow-Methods undef");
  is($headers->header('Access-Control-Allow-Headers'),     undef, "Access-Control-Allow-Headers undef");
  is($headers->header('Access-Control-Expose-Headers'),    undef, "Access-Control-Expose-Headers undef");
  is($headers->header('Access-Control-Allow-Credentials'), undef, "Access-Control-Allow-Credentials undef");
  $json = $tx->res->json;
  is($json->{errors}->[0], "Origin 'http://fake-cors.example.com:9999' not allowed", "Origin not allowed");
}

subtest "Preflight request", \&preflightRequest;
sub preflightRequest {
  my ($t, $ua, $tx, $headers);

  $t = Test::Mojo->new($app);
  $t->app->plugin(OpenAPI => {url => "data://main/preflight.json"});

  #Make a OPTIONS preflight request for following GET-requests :) Mojo-fu!
  $ua = $t->ua;
  $tx = $ua->build_tx(OPTIONS => '/api/cors-pets' => {Accept => '*/*'});
  $tx->req->headers->add('Origin' => 'http://cors.example.com:9999');
  $tx->req->headers->add('Access-Control-Request-Method' => 'GET');
  $tx->req->headers->add('Access-Control-Request-Headers' => 'Timezone-Offset, Sample-Source');
  $tx = $ua->start($tx);

  is($tx->res->code, 200, "Preflight response 200");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      'http://cors.example.com:9999',   "Access-Control-Allow-Origin");
  is($headers->header('Access-Control-Allow-Methods'),     'GET, POST',                      "Access-Control-Allow-Methods default overloaded with any");
  is($headers->header('Access-Control-Allow-Headers'),     'Timezone-Offset, Sample-Source', "Access-Control-Allow-Headers");
  is($headers->header('Access-Control-Expose-Headers'),    'Timezone-Offset, Sample-Source', "Access-Control-Expose-Headers");
  is($headers->header('Access-Control-Allow-Credentials'), 'true',                           "Access-Control-Allow-Credentials");

  #Make a OPTIONS preflight request for following DELETE-requests :) Mojo-fu!
  $ua = $t->ua;
  $tx = $ua->build_tx(OPTIONS => '/api/cors-pets/1024' => {Accept => '*/*'});
  $tx->req->headers->add('Origin' => 'http://cors.example.com:9999');
  $tx->req->headers->add('Access-Control-Request-Method' => 'DELETE');
  $tx->req->headers->add('Access-Control-Request-Headers' => 'Timezone-Offset, Sample-Source');
  $tx = $ua->start($tx);

  is($tx->res->code, 200, "Preflight response 200");
  $headers = $tx->res->headers;
  is($headers->header('Access-Control-Allow-Origin'),      'http://cors.example.com:9999',   "Access-Control-Allow-Origin");
  is($headers->header('Access-Control-Allow-Methods'),     'DELETE',                         "Access-Control-Allow-Methods default overloaded");
  is($headers->header('Access-Control-Allow-Headers'),     'Timezone-Offset, Sample-Source', "Access-Control-Allow-Headers");
  is($headers->header('Access-Control-Expose-Headers'),    'Timezone-Offset, Sample-Source', "Access-Control-Expose-Headers");
  is($headers->header('Access-Control-Allow-Credentials'), undef,                            "Access-Control-Allow-Credentials default overloaded");
}

sub make_app {
    eval <<"HERE";
package t::Mojolicious::Plugin::OpenAPI::CORS;
use Mojo::Base 'Mojolicious';
sub startup {};
1;
HERE
    return t::Mojolicious::Plugin::OpenAPI::CORS->new;
}

done_testing();

__DATA__
@@ preflight.json
{
  "swagger": "2.0",
  "basePath": "/api",
  "info": {
    "version": "1.0",
    "title": "cors"
  },
  "x-cors": {
    "x-cors-access-control-allow-origin-list": "http://cors.example.com:9999 http://localhost:3012",
    "x-cors-access-control-allow-credentials": "true",
    "x-cors-access-control-allow-methods": "GET, HEAD",
    "x-cors-access-control-max-age": "600"
  },
  "paths": {
    "/cors-humans": {
      "x-cors-access-control-allow-origin-list": "t::Mojolicious::Plugin::OpenAPI::CORS::Helpers::origin_whitelist()",
      "get": {
        "x-mojo-to": "Api#cors_list_humans",
        "operationId": "corsListHumans",
        "responses": {
          "200": {"description": "anything"}
        }
      }
    },
    "/cors-pets": {
      "x-cors-access-control-allow-methods": "*",
      "get": {
        "x-mojo-to": "Api#cors_list_pets",
        "operationId": "corsListPets",
        "responses": {
          "200": {"description": "anything"}
        }
      },
      "post" : {
        "x-mojo-to": "Api#add_pet",
        "operationId" : "addPet",
        "parameters" : [
          {
            "name" : "pet",
            "schema" : { "$ref" : "#/definitions/Pet" },
            "in" : "body",
            "required": true,
            "description" : "Pet object that needs to be added to the store"
          }
        ],
        "responses" : {
          "200": {
            "description": "pet response",
            "schema": {
              "type": "array",
              "items": { "$ref": "#/definitions/Pet" }
            }
          }
        }
      }
    },
    "/cors-pets/{petId}": {
      "x-cors-access-control-allow-methods": "DELETE",
      "x-cors-access-control-allow-credentials": "false",
      "delete": {
        "x-mojo-to": "Api#cors_delete_pets",
        "operationId": "corsDeletePets",
        "parameters": [
          {
            "name": "petId",
            "in": "path",
            "required": true,
            "type": "integer"
          }
        ],
        "responses": {
          "204": {"description": "delete ok"}
        }
      }
    }
  },
  "definitions" : {
    "Pet" : {
      "required" : ["name"],
      "properties" : {
        "id" : { "format" : "int64", "type" : "integer" },
        "name" : { "type" : "string" }
      }
    }
  }
}
