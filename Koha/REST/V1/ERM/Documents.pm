package Koha::REST::V1::ERM::Documents;

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

use Koha::ERM::Documents;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 get

Controller function that handles retrieving a single Koha::ERM::Document object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $document_id = $c->validation->param('document_id');

        # Do not use $c->objects->find here, we need the file_content
        my $document = Koha::ERM::Documents->find($document_id);

        if ( !$document ) {
            return $c->render(
                status  => 404,
                openapi => { error => "Document not found" }
            );
        }

        $c->render_file('data' => $document->file_content, 'filename' => $document->file_name);
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
