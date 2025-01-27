package Koha::ERM::Documents;

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

use MIME::Base64 qw( decode_base64 );
use MIME::Types;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::ERM::Document;

use base qw(Koha::Objects);

=head1 NAME

Koha::ERM::Documents- Koha ERM Document Object set class

=head1 API

=head2 Class Methods

=cut

=head3 replace_with

Replaces ERM Agreement or ERM License documents with new updated ones

=cut

sub replace_with {
    my ( $self, $documents, $obj ) = @_;
    my $schema = $obj->_result->result_source->schema;
    $schema->txn_do(
        sub {
            my $existing_documents = $obj->documents;
            my $max_allowed_packet = C4::Context->dbh->selectrow_array(q{SELECT @@max_allowed_packet});

            # FIXME Here we are not deleting all the documents before recreating them, like we do for other related resources.
            # As we do not want the content of the documents to transit over the network we need to use the document_id (and allow it in the API spec)
            # to distinguish from each other
            # Delete all the documents that are not part of the PUT request
            my $document_ids_after_update = [ map { $_->{document_id} || () } @$documents ];
            $obj->documents->search(
                {
                    @$document_ids_after_update
                    ? ( document_id => { '-not_in' => $document_ids_after_update } )
                    : ()
                }
            )->delete;

            for my $document (@$documents) {
                my $file_content =
                    defined( $document->{file_content} ) ? decode_base64( $document->{file_content} ) : "";
                my $mt = MIME::Types->new();

                # Throw exception if uploaded file exceeds server limit
                Koha::Exceptions::PayloadTooLarge->throw("File size exceeds limit defined by server")
                    if length($file_content) > $max_allowed_packet;

                if ( $document->{document_id} ) {

                    # The document already exists in DB
                    $existing_documents->find( $document->{document_id} )->set(
                        {
                            #Check if existing document had its file changed
                            length $file_content
                            ? (
                                file_content => $file_content,
                                file_type    => $mt->mimeTypeOf( $document->{file_name} ),
                                file_name    => $document->{file_name},
                                uploaded_on  => dt_from_string,
                                )
                            : (),
                            file_description  => $document->{file_description},
                            physical_location => $document->{physical_location},
                            uri               => $document->{uri},
                            notes             => $document->{notes},
                        }
                    )->store;
                } else {

                    # Creating a whole new document
                    $document->{file_type} = $mt->mimeTypeOf( $document->{file_name} );
                    $document->{uploaded_on} //= dt_from_string;
                    $document->{file_content} = $file_content;
                    $obj->_result->add_to_erm_documents($document);
                }
            }
        }
    );
}

=head3 type

=cut

sub _type {
    return 'ErmDocument';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::ERM::Document';
}

1;
