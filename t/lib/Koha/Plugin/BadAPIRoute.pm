package Koha::Plugin::BadAPIRoute;

use Modern::Perl;

use Mojo::JSON qw(decode_json);

use base qw(Koha::Plugins::Base);

our $VERSION = 0.01;
our $metadata = {
    name            => 'Bad API Route Plugin',
    author          => 'John Doe',
    description     => 'Test plugin for bad API route',
    date_authored   => '2018-',
    date_updated    => '2013-01-14',
    minimum_version => '17.11',
    maximum_version => undef,
    version         => $VERSION,
    my_example_tag  => 'find_me',
};

sub new {
    my ( $class, $args ) = @_;
    $args->{'metadata'} = $metadata;
    my $self = $class->SUPER::new($args);
    return $self;
}

sub api_namespace {
    return "badass";
}

sub api_routes {
    my ( $self, $args ) = @_;

    my $spec = qq{
{
  "/patrons/{patron_id}/bother_wrong": {
    "put": {
      "x-mojo-to": "Koha::Plugin::BadAPIRoute#bother",
      "operationId": "BotherPatron",
      "tags": ["patrons"],
      "parameters": [{
        "name": "patron_id",
        "in": "nowhere",
        "description": "Internal patron identifier",
        "required": true,
        "type": "integer"
      }],
      "produces": [
        "application/json"
      ],
      "responses": {
        "200": {
          "description": "A bothered patron",
          "schema": {
              "type": "object",
                "properties": {
                  "bothered": {
                    "description": "If the patron has been bothered",
                    "type": "boolean"
                  }
                }
          }
        },
        "404": {
          "description": "An error occurred",
          "schema": {
              "type": "object",
                "properties": {
                  "error": {
                    "description": "An explanation for the error",
                    "type": "string"
                  }
                }
          }
        }
      },
      "x-koha-authorization": {
        "permissions": {
          "borrowers": "1"
        }
      }
    }
  }
}
    };

    return decode_json($spec);
}

1;
