package Koha::REST::V1::Biblios::MetadataErrors;

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

use Koha::Biblio::Metadata::Errors;
use Koha::Biblios;

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Biblios::MetadataErrors - REST controller for biblio metadata errors

=head1 API

=head2 Methods

=head3 delete

Delete (resolve) a single biblio metadata error row.

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $biblio = Koha::Biblios->find( $c->param('biblio_id') );
    return $c->render_resource_not_found("Biblio") unless $biblio;

    my $error = $biblio->metadata->metadata_errors->find( $c->param('error_id') );
    return $c->render_resource_not_found("Metadata error") unless $error;

    return try {
        $error->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
