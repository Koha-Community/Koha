package Koha::REST::V1;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious';

use C4::Context;
use Koha::Logger;
use Koha::Auth::Identity::Providers;

use Mojolicious::Plugin::OAuth2;
use JSON::Validator::Schema::OpenAPIv2;

use Try::Tiny qw( catch try );
use JSON      qw( encode_json decode_json );
use XML::LibXML;

=head1 NAME

Koha::REST::V1 - Main v.1 REST api class

=head1 API

=head2 Class Methods

=head3 startup

Overloaded Mojolicious->startup method. It is called at application startup.

=cut

sub startup {
    my $self = shift;

    my $logger = Koha::Logger->get( { interface => 'api' } );
    $self->log($logger);

    $self->hook(
        before_dispatch => sub {
            my $c = shift;

            # Remove /api/v1/app.pl/ from the path
            $c->req->url->base->path('/');

            # Handle CORS
            $c->res->headers->header(
                'Access-Control-Allow-Origin' => C4::Context->preference('AccessControlAllowOrigin') )
                if C4::Context->preference('AccessControlAllowOrigin');
        }
    );
    $self->hook(
        around_action => sub {
            my ( $next, $c, $action, $last ) = @_;

            # Flush memory caches before every request
            Koha::Caches->flush_L1_caches();
            Koha::Cache::Memory::Lite->flush();

            # Convert XML payload to JSON and validate against schema
            if ( $c->req->headers->content_type && $c->req->headers->content_type =~ /application\/xml/ ) {
                try {
                    my $xml = $c->req->body;

                    my $parser    = XML::LibXML->new();
                    my $doc       = $parser->parse_string($xml);
                    my $root      = $doc->documentElement();
                    my $spec_file = $self->home->rel_file("api/v1/swagger/swagger_bundle.json");
                    if ( !-f $spec_file ) {
                        $spec_file = $self->home->rel_file("api/v1/swagger/swagger.yaml");
                    }
                    my $json = parse_xml( $root, $spec_file );

                    $c->req->body( JSON::encode_json($json) );

                    unless ( $self->validate_json_payload( $c, $json ) ) {
                        return $c->render( status => 400, json => { error => 'Invalid JSON payload' } );
                    }
                } catch {

                    # If the request body is already JSON, don't try to parse it as XML
                    my $json = $c->req->body;
                    unless ( $self->validate_json_payload( $c, $json ) ) {
                        return $c->render( status => 400, json => { error => 'Invalid JSON payload' } );
                    }
                }
            }

            return $next->();
        }
    );

    $self->hook(
        after_dispatch => sub {
            my ($c) = @_;

            # Check if the response header content_type is application/xml
            if ( $c->res->headers->content_type && $c->res->headers->content_type eq 'application/xml' ) {

                # Convert JSON to XML
                my $xml = to_xml( decode_json( $c->res->body ) );

                $c->res->body($xml);
            }

            return;
        }
    );

    # Force charset=utf8 in Content-Type header for JSON responses
    $self->types->type( json => 'application/json; charset=utf8' );
    $self->types->type( xml  => 'application/xml' );

    # MARC-related types
    $self->types->type( marcxml => 'application/marcxml+xml' );
    $self->types->type( mij     => 'application/marc-in-json' );
    $self->types->type( marc    => 'application/marc' );

    # YAML type
    $self->types->type( yaml => 'application/yaml' );

    my $secret_passphrase = C4::Context->config('api_secret_passphrase');
    if ($secret_passphrase) {
        $self->secrets( [$secret_passphrase] );
    }

    my $spec_file = $self->home->rel_file("api/v1/swagger/swagger_bundle.json");
    if ( !-f $spec_file ) {
        $spec_file = $self->home->rel_file("api/v1/swagger/swagger.yaml");
    }

    push @{ $self->routes->namespaces }, 'Koha::Plugin';

    # Try to load and merge all schemas first and validate the result just once.
    try {

        my $schema = JSON::Validator::Schema::OpenAPIv2->new;

        $schema->resolve($spec_file);

        my $spec = $schema->bundle->data;

        $self->plugin(
            'Koha::REST::Plugin::PluginRoutes' => {
                spec     => $spec,
                validate => 0,
            }
        ) unless C4::Context->needs_install;    # load only if Koha is installed

        my $route = $self->config('route') // '/api/v1';

        $self->plugin(
            OpenAPI => {
                spec  => $spec,
                route => $self->routes->under($route)->to('Auth#under'),
            }
        );

        $self->plugin('RenderFile');
    } catch {

        # Validation of the complete spec failed. Resort to validation one-by-one
        # to catch bad ones.

        # JSON::Validator uses confess, so trim call stack from the message.
        $self->app->log->error( "Warning: Could not load REST API spec bundle: " . $_ );

        try {

            my $schema = JSON::Validator::Schema::OpenAPIv2->new;
            $schema->resolve($spec_file);

            my $spec = $schema->bundle->data;

            $self->plugin(
                'Koha::REST::Plugin::PluginRoutes' => {
                    spec     => $spec,
                    validate => 1
                }
            ) unless C4::Context->needs_install;    # load only if Koha is installed

            $self->plugin(
                OpenAPI => {
                    spec  => $spec,
                    route => $self->routes->under('/api/v1')->to('Auth#under'),
                }
            );
        } catch {

            # JSON::Validator uses confess, so trim call stack from the message.
            $self->app->log->error( "Warning: Could not load REST API spec bundle: " . $_ );
        };
    };

    my $oauth_configuration = {};
    try {
        my $search_options = { protocol => [ "OIDC", "OAuth" ] };

        my $providers = Koha::Auth::Identity::Providers->search($search_options);
        while ( my $provider = $providers->next ) {
            $oauth_configuration->{ $provider->code } = decode_json( $provider->config );
        }
    } catch {
        $self->app->log->warn( "Warning: Failed to fetch oauth configuration: " . $_ );
    };

    $self->plugin('Koha::App::Plugin::Language');
    $self->plugin('Koha::REST::Plugin::Pagination');
    $self->plugin('Koha::REST::Plugin::Query');
    $self->plugin('Koha::REST::Plugin::Objects');
    $self->plugin('Koha::REST::Plugin::Exceptions');
    $self->plugin('Koha::REST::Plugin::Responses');
    $self->plugin('Koha::REST::Plugin::Auth::IdP');
    $self->plugin('Koha::REST::Plugin::Auth::PublicRoutes');
    $self->plugin( 'Mojolicious::Plugin::OAuth2' => $oauth_configuration );
}

=head3 to_xml

    my $xml_string = to_xml( $json_hashref );

Converts a JSON-like hashref into an XML string.

=cut

sub to_xml {
    my $json = shift;
    my $xml  = XML::LibXML::Document->new( '1.0', 'UTF-8' );

    my $root_key = ( keys %$json )[0];
    my $root     = $xml->createElement($root_key);
    $xml->setDocumentElement($root);    # Set the root element

    _json_to_xml( $json->{$root_key}, $root, $xml );

    return $xml->toString;
}

=head3 _json_to_xml

    _json_to_xml( $data, $parent_node, $xml_doc );

Internal recursive helper for C<to_xml> to build XML elements from nested Perl structures.

=cut

sub _json_to_xml {
    my ( $json, $parent, $doc ) = @_;

    if ( ref $json eq 'HASH' ) {
        foreach my $key ( keys %$json ) {
            my $value = $json->{$key};
            if ( ref $value eq 'HASH' ) {
                my $elem = $doc->createElement($key);
                $parent->appendChild($elem);
                _json_to_xml( $value, $elem, $doc );
            } elsif ( ref $value eq 'ARRAY' ) {
                foreach my $item (@$value) {
                    my $elem = $doc->createElement($key);
                    $parent->appendChild($elem);
                    _json_to_xml( $item, $elem, $doc );
                }
            } else {
                my $elem = $doc->createElement($key);
                $elem->appendText($value);
                $parent->appendChild($elem);
            }
        }
    } elsif ( ref $json eq 'ARRAY' ) {
        foreach my $item (@$json) {
            my $elem = $doc->createElement('item');
            $parent->appendChild($elem);
            _json_to_xml( $item, $elem, $doc );
        }
    } else {
        my $elem = $doc->createElement('value');
        $elem->appendText($json);
        $parent->appendChild($elem);
    }
}

=head3 validate_json_payload

    my $is_valid = $self->validate_json_payload( $c, $payload );

Validates a JSON payload against the REST API OpenAPI/Swagger schema.
Returns C<1> if valid, C<0> if there are errors.

=cut

sub validate_json_payload {
    my ( $self, $c, $payload ) = @_;

    # Load the OpenAPI schema
    my $spec_file = $self->home->rel_file("api/v1/swagger/swagger_bundle.json");
    if ( !-f $spec_file ) {
        $spec_file = $self->home->rel_file("api/v1/swagger/swagger.yaml");
    }

    my $schema = JSON::Validator::Schema::OpenAPIv2->new;
    $schema->resolve($spec_file);

    my $spec = $schema->bundle->data;

    # Validate the JSON payload against the schema
    my $validator = JSON::Validator->new;
    $validator->schema($spec);

    my $errors = $validator->validate($payload);

    # Print the validation errors
    if ($errors) {

        #TODO: Do something here?
    }

    # Return 1 if the payload is valid, 0 otherwise
    return $errors ? 0 : 1;
}

=head3 parse_xml

    my $hashref = parse_xml( $xml_node, $spec_file );

Converts an C<XML::LibXML::Node> into a Perl hashref, using the OpenAPI schema definitions to correctly identify and cast array properties.

=cut

sub parse_xml {
    my ( $node, $spec_file ) = @_;
    my $hash = {};

    my $schema = JSON::Validator::Schema::OpenAPIv2->new($spec_file);

    _parse_node( $node, $hash, 0, $schema->data->{definitions} );

    return $hash;
}

=head3 _parse_node

    _parse_node( $node, $hash, $is_array, $schema_definitions );

Internal recursive helper for C<parse_xml> to populate a Perl hashref from XML elements.

=cut

sub _parse_node {
    my ( $node, $hash, $is_array, $schema_definitions ) = @_;

    my $name       = $node->localName();
    my $properties = $schema_definitions->{$name}->{properties};

    my @array_properties;
    foreach my $key ( keys %$properties ) {
        my $property = $properties->{$key};
        push @array_properties, $key if $property->{type} && $property->{type} eq 'array';
    }

    if ( $node->hasChildNodes() ) {
        my $child_hash = {};
        foreach my $child ( $node->childNodes() ) {
            if ( $child->nodeType() == 1 ) {    # 1 is the node type for elements
                if ( grep { $_ eq $child->localName() } @array_properties ) {
                    _parse_node( $child, $child_hash, 1, $schema_definitions );
                } else {
                    _parse_node( $child, $child_hash, 0, $schema_definitions );
                }
            }
        }
        if (%$child_hash) {
            if ( $is_array || exists $hash->{$name} ) {
                if ( ref( $hash->{$name} ) eq 'ARRAY' ) {
                    push @{ $hash->{$name} }, $child_hash;
                } else {
                    $hash->{$name} = [$child_hash];
                }
            } else {
                $hash->{$name} = $child_hash;
            }
        } else {
            my $text = $node->textContent();
            $text =~ s/^\s+//;    # remove leading whitespace
            $text =~ s/\s+$//;    # remove trailing whitespace
            if ( $is_array || exists $hash->{$name} ) {
                if ( ref( $hash->{$name} ) eq 'ARRAY' ) {
                    push @{ $hash->{$name} }, $text;
                } else {
                    $hash->{$name} = [$text];
                }
            } else {
                $hash->{$name} = $text;
            }
        }
    } else {
        my $text = $node->textContent();
        $text =~ s/^\s+//;    # remove leading whitespace
        $text =~ s/\s+$//;    # remove trailing whitespace
        $hash->{$name} = $text;
    }
}

1;
