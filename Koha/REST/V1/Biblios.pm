package Koha::REST::V1::Biblios;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::Biblios;
use C4::Biblio qw(DelBiblio);

use MARC::Record::MiJ;

use Try::Tiny;

=head1 API

=head2 Class methods

=head3 get

Controller function that handles retrieving a single biblio object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $attributes;
    $attributes = { prefetch => [ 'metadata' ] } # don't prefetch metadata if not needed
        unless $c->req->headers->accept =~ m/application\/json/;

    my $biblio = Koha::Biblios->find( { biblionumber => $c->validation->param('biblio_id') }, $attributes );

    unless ( $biblio ) {
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
                json   => $c->build_json_biblio( { biblio => $biblio } )
            );
        }
        else {
            my $record = $biblio->metadata->record;

            $c->respond_to(
                marcxml => {
                    status => 200,
                    format => 'marcxml',
                    text   => $record->as_xml_record
                },
                mij => {
                    status => 200,
                    format => 'mij',
                    text   => $record->to_mij
                },
                marc => {
                    status => 200,
                    format => 'marc',
                    text   => $record->as_usmarc
                },
                any => {
                    status  => 406,
                    openapi => [
                        "application/json",
                        "application/marcxml+xml",
                        "application/marc-in-json",
                        "application/marc"
                    ]
                }
            );
        }
    }
    catch {
        return $c->render(
            status  => 500,
            openapi => { error => "Something went wrong, check the logs ($_)" }
        );
    };
}

=head3 delete

Controller function that handles deleting a biblio object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find( $c->validation->param('biblio_id') );

    if ( not defined $biblio ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        );
    }

    return try {
        my $error = DelBiblio( $biblio->id );

        if ($error) {
            return $c->render(
                status  => 409,
                openapi => { error => $error }
            );
        }
        else {
            return $c->render( status => 204, openapi => "" );
        }
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => $_->{msg} }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head2 Internal methods


=head3 _to_api

Helper function that maps unblessed Koha::Patron objects into REST api
attribute names.

=cut

sub _to_api {
    my $biblio = shift;

    # Rename attributes
    foreach my $column ( keys %{$Koha::REST::V1::Biblios::to_api_mapping} ) {
        my $mapped_column = $Koha::REST::V1::Biblios::to_api_mapping->{$column};
        if ( exists $biblio->{$column}
            && defined $mapped_column )
        {
            # key != undef
            $biblio->{$mapped_column} = delete $biblio->{$column};
        }
        elsif ( exists $biblio->{$column}
            && !defined $mapped_column )
        {
            # key == undef
            delete $biblio->{$column};
        }
    }

    return $biblio;
}


=head3 build_json_biblio

Internal method that returns all the attributes from the biblio and biblioitems tables

=cut

sub build_json_biblio {
    my ( $c, $args ) = @_;

    my $biblio = $args->{biblio};

    my $response = $biblio->TO_JSON;
    my $biblioitem = $biblio->biblioitem->TO_JSON;

    foreach my $key ( keys %{ $biblioitem } ) {
        $response->{$key} = $biblioitem->{$key};
    }

    return _to_api($response);
}


=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    agerestriction   => 'age_restriction',
    biblioitemnumber => undef, # meaningless
    biblionumber     => 'biblio_id',
    collectionissn   => 'collection_issn',
    collectiontitle  => 'collection_title',
    collectionvolume => 'collection_volume',
    copyrightdate    => 'copyright_date',
    datecreated      => 'creation_date',
    editionresponsibility => undef, # obsolete, not mapped
    editionstatement => 'edition_statement',
    frameworkcode    => 'framework_id',
    illus            => 'illustrations',
    itemtype         => 'item_type',
    lccn             => 'lc_control_number',
    place            => 'publication_place',
    publicationyear  => 'publication_year',
    publishercode    => 'publisher',
    seriestitle      => 'series_title',
    size             => 'material_size',
    totalissues      => 'serial_total_issues',
    unititle         => 'uniform_title',
    volumedate       => 'volume_date',
    volumedesc       => 'volume_description',
};

1;
