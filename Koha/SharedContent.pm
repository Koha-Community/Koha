package Koha::SharedContent;

# Copyright 2016 BibLibre Morgane Alonso
#
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use JSON qw( from_json to_json );
use HTTP::Request;
use LWP::UserAgent;

use Koha::Serials;
use Koha::Reports;
use C4::Context;

=head1 NAME

Koha::SharedContent - Set of methods for querying Mana KB server

=head1 DESCRIPTION

Package for accessing shared content via Mana KB. Methods here are intended
to build and process queries for requesting from Mana KB server.

=cut

=head2 process_request

Koha::SharedContent::process_request($request);

Send a request to Mana KB server. URL is defined in koha-conf.xml in mana_config
tag. $request parameter must be a HTTP::Request object. See build_request method.

=cut

sub process_request {
    my $mana_request = shift;
    my $result;
    $mana_request->content_type('application/json');
    my $userAgent = LWP::UserAgent->new;
    if ( $mana_request->method eq "POST" ) {
        my $content;
        if ( $mana_request->content ) { $content = from_json( $mana_request->content ) }
        $content->{securitytoken} = C4::Context->preference("ManaToken");
        $mana_request->content( to_json($content) );
    }

    my $response = $userAgent->simple_request($mana_request);
    eval { $result = from_json( $response->decoded_content, { utf8 => 1 } ); };
    $result->{code} = $response->code;
    if ($@) {
        $result->{msg} = $@;
    }
    if ( $response->is_error ) {
        $result->{msg} = "An error occurred, mana server returned: " . $response->message;
    }
    return $result;
}

=head2 increment_entity_value

Koha::SharedContent::increment_entity_value($entity_type, $mana_entity_id, $field);

Increment by 1 the field $field of a Mana entity. I.e, this is used to count the number
of Koha instances using a specific entity.

=cut

sub increment_entity_value {
    return process_request( build_request( 'increment', @_ ) );
}

=head2 send_entity

my $result = Koha::SharedContent::send_entity($language, $borrowernumber, $mana_entity_id, $entity_type);

Share a Koha entity (i.e subscription or report) to Mana KB.

=cut

sub send_entity {
    my ( $lang, $loggedinuser, $resourceid, $resourcetype ) = @_;

    my $content = prepare_entity_data( $lang, $loggedinuser, $resourceid, $resourcetype );

    my $result = process_request( build_request( 'post', $resourcetype, $content ) );

    if ( $result and ( $result->{code} eq "200" or $result->{code} eq "201" ) ) {
        my $packages = "Koha::" . ucfirst($resourcetype) . "s";
        my $resource = $packages->find($resourceid);
        eval { $resource->set( { mana_id => $result->{id} } )->store };
    }
    return $result;
}

=head3 comment_entity

my $result = Koha::SharedContent::comment_entity($resource_id, $resource_type, $comment);

Send a comment about a Mana entity.

=cut

sub comment_entity {
    my ( $resourceid, $resourcetype, $comment ) = @_;

    my $result = process_request(
        build_request(
            'post', 'resource_comment',
            { resource_id => $resourceid, resource_type => $resourcetype, message => $comment }
        )
    );

    return $result;
}

=head2 prepare_entity_data

$data = prepare_entity_data($language, $borrowernumber, $mana_entity_id, $entity_type);

Prepare Koha entity data to be sent to Mana KB.

=cut

sub prepare_entity_data {
    my ( $lang, $loggedinuser, $ressourceid, $ressourcetype ) = @_;
    $lang ||= C4::Context->preference('StaffInterfaceLanguages');

    my $mana_email;
    if ( $loggedinuser ne 0 ) {
        my $borrower = Koha::Patrons->find($loggedinuser);
        $mana_email = $borrower->first_valid_email_address
            || Koha::Libraries->find( C4::Context->userenv->{'branch'} )->branchemail;
    }
    $mana_email = C4::Context->preference('KohaAdminEmailAddress')
        if ( ( not defined($mana_email) ) or ( $mana_email eq '' ) );

    my %versions = C4::Context::get_versions();

    my $mana_info = {
        language    => $lang,
        kohaversion => $versions{'kohaVersion'},
        exportemail => $mana_email
    };

    my $ressource_mana_info;
    my $packages = "Koha::" . ucfirst($ressourcetype) . "s";
    my $package  = "Koha::" . ucfirst($ressourcetype);
    $ressource_mana_info = $package->get_sharable_info($ressourceid);
    $ressource_mana_info = { %$ressource_mana_info, %$mana_info };

    return $ressource_mana_info;
}

=head2 get_entity_by_id

my $entity = Koha::SharedContent::get_entity_by_id($entity_type, $mana_entity_id, [{usecomments => 1}]);

Retrieve a Mana entity to be imported into Koha. Add {usecomments => 1} to tell Mana to
embed all user reviews.

=cut

sub get_entity_by_id {
    return process_request( build_request( 'getwithid', @_ ) );
}

=head2 search_entities

my $result = Koha::SharedContent::search_entities( $entity_type, $search_params );
my $entities = $result->{data};

Search entities on ManaKB.

=cut

sub search_entities {
    return process_request( build_request( 'get', @_ ) );
}

=head2 build_request

$request = build_request($mana_method, [$param1, $param2, ...]);

Create a HTTP::Request object to be passed to process_request.

=cut

sub build_request {
    my $type     = shift;
    my $resource = shift;
    my $mana_url = get_sharing_url();

    if ( $type eq 'get' ) {
        my $params = shift;
        $params = join '&',
            map { defined $params->{$_} && $params->{$_} ne '' ? $_ . "=" . $params->{$_} : () }
            keys %$params;
        my $url = "$mana_url/$resource.json?$params";
        return HTTP::Request->new( GET => $url );
    }

    if ( $type eq 'getwithid' ) {
        my $id     = shift;
        my $params = shift;
        $params = join '&',
            map { defined $params->{$_} && $params->{$_} ne '' ? $_ . "=" . $params->{$_} : () }
            keys %$params;

        my $url = "$mana_url/$resource/$id.json?$params";
        return HTTP::Request->new( GET => $url );
    }

    if ( $type eq 'post' ) {
        my $content = shift;

        my $url     = "$mana_url/$resource.json";
        my $request = HTTP::Request->new( POST => $url );

        my $json = to_json( $content, { utf8 => 1 } );
        $request->content($json);

        return $request;
    }

    if ( $type eq 'increment' ) {
        my $id    = shift;
        my $field = shift;
        my $step  = shift;
        my $param;

        $param->{step}     = $step || 1;
        $param->{id}       = $id;
        $param->{resource} = $resource;
        $param             = join '&',
            map { defined $param->{$_} ? $_ . "=" . $param->{$_} : () }
            keys %$param;
        my $url     = "$mana_url/$resource/$id.json/increment/$field?$param";
        my $request = HTTP::Request->new( POST => $url );

    }
}

=head2 get_sharing_url

my $mana_url = get_sharing_url();

Get the Mana KB server URL set in koha config file.

=cut

sub get_sharing_url {
    return C4::Context->config('mana_config');
}

1;
