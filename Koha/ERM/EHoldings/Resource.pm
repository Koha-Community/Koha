package Koha::ERM::EHoldings::Resource;

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

use MARC::Record;

use Koha::Database;

use Koha::Acquisition::Booksellers;
use Koha::Biblios;
use Koha::ERM::EHoldings::Titles;
use Koha::ERM::EHoldings::Packages;

use base qw(Koha::Object);

=head1 NAME

Koha::ERM::EHoldings::Resource - Koha EHolding resource Object class

=head1 API

=head2 Class Methods

=cut

=head3 store

=cut

sub store {
    my ($self) = @_;

    # FIXME This is terrible and ugly, we need to:
    # * Provide a mapping for each attribute of title
    # * Deal with marcflavour
    # * Create a txn
    my $title = $self->title;
    my $biblio = $title->biblio_id ? Koha::Biblios->find($title->biblio_id) : undef;
    my $marc_record = $biblio ? $biblio->metadata->record : MARC::Record->new;
    eval {$marc_record->field('245')->delete_subfield('a');};
    $marc_record->add_fields(MARC::Field->new(245, '', '', a => $title->publication_title));

    my $biblio_id;
    if ( $biblio ) {
        $biblio_id = $title->biblio_id;
        C4::Biblio::ModBiblio($marc_record, $title->biblio_id, '');
    } else {
        ( $biblio_id ) = C4::Biblio::AddBiblio($marc_record, '');
    }

    $title->biblio_id($biblio_id)->store;

    $self = $self->SUPER::store;
    return $self;
}

=head3 package

Return the package for this resource

=cut

sub package {
    my ( $self ) = @_;
    my $package_rs = $self->_result->package;
    return Koha::ERM::EHoldings::Package->_new_from_dbic($package_rs);
}

=head3 title

Return the title for this resource

=cut

sub title {
    my ( $self ) = @_;
    my $title_rs = $self->_result->title;
    return Koha::ERM::EHoldings::Title->_new_from_dbic($title_rs);
}

=head3 vendor

Return the vendor for this resource

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
    return 'ErmEholdingsResource';
}

1;
