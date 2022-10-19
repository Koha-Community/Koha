package Koha::ERM::License;

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

use Koha::Database;

use base qw(Koha::Object);

use Koha::Acquisition::Bookseller;
use Koha::ERM::Documents;

=head1 NAME

Koha::ERM::License - Koha ERM License Object class

=head1 API

=head2 Class Methods

=cut

=head3 documents

Returns or updates the documents for this license

=cut

sub documents {
    my ( $self, $documents ) = @_;
    if ($documents) {
        $self->documents->replace_with($documents, $self);
    }
    my $documents_rs = $self->_result->erm_documents;
    return Koha::ERM::Documents->_new_from_dbic($documents_rs);
}

=head3 vendor

Return the vendor for this license

=cut

sub vendor {
    my ( $self ) = @_;
    my $vendor_rs = $self->_result->vendor;
    return unless $vendor_rs;
    return Koha::Acquisition::Bookseller->_new_from_dbic($vendor_rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmLicense';
}

1;
