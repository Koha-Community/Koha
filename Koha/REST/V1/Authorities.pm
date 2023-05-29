package Koha::REST::V1::Authorities;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Authorities;
use C4::AuthoritiesMarc qw( DelAuthority AddAuthority FindDuplicateAuthority ModAuthority);

use List::MoreUtils qw( any );
use MARC::Record::MiJ;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 get

Controller function that handles retrieving a single authority object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $authority = Koha::Authorities->find( { authid => $c->param('authority_id') } );
    unless ( $authority ) {
        return $c->render(
            status  => 404,
            openapi => {
                error => "Object not found."
            }
        );
    }

    return try {

        if ( $c->req->headers->accept =~ m/application\/json/ ) {
            return $c->render(
                status => 200,
                json   => $authority->to_api
            );
        }
        else {
            my $record = $authority->record;

            $c->respond_to(
                marcxml => {
                    status => 200,
                    format => 'marcxml',
                    text   => $record->as_xml_record
                },
                mij => {
                    status => 200,
                    format => 'mij',
                    data   => $record->to_mij
                },
                marc => {
                    status => 200,
                    format => 'marc',
                    text   => $record->as_usmarc
                },
                txt => {
                    status => 200,
                    format => 'text/plain',
                    text   => $record->as_formatted
                },
                any => {
                    status  => 406,
                    openapi => [
                        "application/json",
                        "application/marcxml+xml",
                        "application/marc-in-json",
                        "application/marc",
                        "text/plain"
                    ]
                }
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting an authority object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $authority = Koha::Authorities->find( { authid => $c->param('authority_id') } );

    if ( not defined $authority ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        );
    }

    return try {
        DelAuthority( { authid => $authority->authid } );

        return $c->render( status => 204, openapi => q{} );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles creating an authority object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    try {
        my $headers   = $c->req->headers;
        my $overrides = $c->stash('koha.overrides');

        my $flavour =
            C4::Context->preference('marcflavour') eq 'UNIMARC'
            ? 'UNIMARCAUTH'
            : 'MARC21';

        my $record;

        my $authtypecode = $headers->header('x-authority-type');
        my $content_type = $headers->content_type;

        if ( $content_type =~ m/application\/marcxml\+xml/ ) {
            $record = MARC::Record->new_from_xml( $c->req->body, 'UTF-8', $flavour );
        } elsif ( $content_type =~ m/application\/marc-in-json/ ) {
            $record = MARC::Record->new_from_mij_structure( $c->req->json );
        } elsif ( $content_type =~ m/application\/marc/ ) {
            $record = MARC::Record->new_from_usmarc( $c->req->body );
        } else {
            return $c->render(
                status  => 406,
                openapi => [
                    "application/marcxml+xml",
                    "application/marc-in-json",
                    "application/marc"
                ]
            );
        }

        unless ( $overrides->{any} || $overrides->{duplicate} ) {
            my ( $duplicateauthid, $duplicateauthvalue ) = C4::AuthoritiesMarc::FindDuplicateAuthority( $record, $authtypecode );

            return $c->render(
                status  => 409,
                openapi => {
                    error      => "Duplicate record ($duplicateauthid)",
                    error_code => 'duplicate',
                }
            ) unless !$duplicateauthid;
        }

        my $authid = AddAuthority( $record, undef, $authtypecode );

        $c->res->headers->location($c->req->url->to_string . '/' . $authid);
        $c->render(
            status  => 201,
            openapi => q{},
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}


=head3 update

Controller function that handles modifying an authority object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $authid = $c->param('authority_id');
    my $authority = Koha::Authorities->find( { authid => $authid } );

    if ( not defined $authority ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        );
    }

    try {
        my $headers = $c->req->headers;

        my $flavour =
            C4::Context->preference('marcflavour') eq 'UNIMARC'
            ? 'UNIMARCAUTH'
            : 'MARC21';

        my $record;
        my $authtypecode = $headers->header('x-authority-type') || $authority->authtypecode;
        if ( $c->req->headers->content_type =~ m/application\/marcxml\+xml/ ) {
            $record = MARC::Record->new_from_xml( $c->req->body, 'UTF-8', $flavour );
        } elsif ( $c->req->headers->content_type =~ m/application\/marc-in-json/ ) {
            $record = MARC::Record->new_from_mij_structure( $c->req->json );
        } elsif ( $c->req->headers->content_type =~ m/application\/marc/ ) {
            $record = MARC::Record->new_from_usmarc( $c->req->body );
        } else {
            return $c->render(
                status  => 406,
                openapi => [
                    "application/json",
                    "application/marcxml+xml",
                    "application/marc-in-json",
                    "application/marc"
                ]
            );
        }

        my $authid = ModAuthority( $authid, $record, $authtypecode );

        $c->render(
            status  => 200,
            openapi => { id => $authid }
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 list

Controller function that handles retrieving a list of authorities

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $authorities = $c->objects->search_rs( Koha::Authorities->new );

    return try {

        if ( $c->req->headers->accept =~ m/application\/json(;.*)?$/ ) {
            return $c->render(
                status => 200,
                json   => $authorities->to_api
            );
        }
        elsif (
            $c->req->headers->accept =~ m/application\/marcxml\+xml(;.*)?$/ )
        {
            $c->res->headers->add( 'Content-Type', 'application/marcxml+xml' );
            return $c->render(
                status => 200,
                text   => $authorities->print_collection('marcxml')
            );
        }
        elsif (
            $c->req->headers->accept =~ m/application\/marc-in-json(;.*)?$/ )
        {
            $c->res->headers->add( 'Content-Type', 'application/marc-in-json' );
            return $c->render(
                status => 200,
                data   => $authorities->print_collection('mij')
            );
        }
        elsif ( $c->req->headers->accept =~ m/application\/marc(;.*)?$/ ) {
            $c->res->headers->add( 'Content-Type', 'application/marc' );
            return $c->render(
                status => 200,
                text   => $authorities->print_collection('marc')
            );
        }
        elsif ( $c->req->headers->accept =~ m/text\/plain(;.*)?$/ ) {
            return $c->render(
                status => 200,
                text   => $authorities->print_collection('txt')
            );
        }
        else {
            return $c->render(
                status  => 406,
                openapi => [
                    "application/json",         "application/marcxml+xml",
                    "application/marc-in-json", "application/marc",
                    "text/plain"
                ]
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
