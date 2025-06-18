package Koha::REST::V1::DeletedBiblios;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Old::Biblios;
use Koha::DateUtils;
use Koha::RecordProcessor;

use C4::Context;

use Koha::Items;

use List::MoreUtils qw( any );
use MARC::Record::MiJ;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 get

Controller function that handles retrieving a single biblio object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $attributes;
    $attributes = { prefetch => ['metadata'] }    # don't prefetch metadata if not needed
        unless $c->req->headers->accept =~ m/application\/json/;

    my $biblio = Koha::Old::Biblios->find( { biblionumber => $c->param('biblio_id') }, $attributes );

    return $c->render_resource_not_found("Bibliographic record")
        unless $biblio;

    return try {

        if ( $c->req->headers->accept =~ m/application\/json/ ) {
            return $c->render(
                status => 200,
                json   => $biblio->to_api
            );
        } else {
            my $metadata = $biblio->metadata;
            my $record   = $metadata->record;
            my $schema   = $metadata->schema // C4::Context->preference("marcflavour");

            $c->respond_to(
                marcxml => {
                    status => 200,
                    format => 'marcxml',
                    text   => $record->as_xml_record($schema),
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
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list

Controller function that handles listing a deleted biblio objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my @prefetch = qw(biblioitem);
    push @prefetch, 'metadata'    # don't prefetch metadata if not needed
        unless $c->req->headers->accept =~ m/application\/json/;

    my $rs      = Koha::Old::Biblios->search( undef, { prefetch => \@prefetch } );
    my $biblios = $c->objects->search_rs( $rs, [ ( sub { $rs->api_query_fixer( $_[0], '', $_[1] ) } ) ] );

    return try {

        if ( $c->req->headers->accept =~ m/application\/json(;.*)?$/ ) {
            return $c->render(
                status => 200,
                json   => $c->objects->to_api($biblios),
            );
        } elsif ( $c->req->headers->accept =~ m/application\/marcxml\+xml(;.*)?$/ ) {
            $c->res->headers->add( 'Content-Type', 'application/marcxml+xml' );
            return $c->render(
                status => 200,
                text   => $biblios->print_collection('marcxml')
            );
        } elsif ( $c->req->headers->accept =~ m/application\/marc-in-json(;.*)?$/ ) {
            $c->res->headers->add( 'Content-Type', 'application/marc-in-json' );
            return $c->render(
                status => 200,
                data   => $biblios->print_collection('mij')
            );
        } elsif ( $c->req->headers->accept =~ m/application\/marc(;.*)?$/ ) {
            $c->res->headers->add( 'Content-Type', 'application/marc' );
            return $c->render(
                status => 200,
                text   => $biblios->print_collection('marc')
            );
        } elsif ( $c->req->headers->accept =~ m/text\/plain(;.*)?$/ ) {
            return $c->render(
                status => 200,
                text   => $biblios->print_collection('txt')
            );
        } else {
            return $c->render(
                status  => 406,
                openapi => [
                    "application/json",         "application/marcxml+xml",
                    "application/marc-in-json", "application/marc",
                    "text/plain"
                ]
            );
        }
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
