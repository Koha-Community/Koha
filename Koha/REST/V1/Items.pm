package Koha::REST::V1::Items;

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

use Koha::Items;

use Try::Tiny;

sub get {
    my $c = shift->openapi->valid_input or return;

    my $item;
    try {
        $item = Koha::Items->find($c->validation->param('item_id'));
        return $c->render( status => 200, openapi => $item->to_api );
    }
    catch {
        unless ( defined $item ) {
            return $c->render( status => 404,
                               openapi => { error => 'Item not found'} );
        }
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

=head3 _to_api

Helper function that maps unblessed Koha::Hold objects into REST api
attribute names.

=cut

sub _to_api {
    my $item = shift;

    # Rename attributes
    foreach my $column ( keys %{ $Koha::REST::V1::Items::to_api_mapping } ) {
        my $mapped_column = $Koha::REST::V1::Items::to_api_mapping->{$column};
        if (    exists $item->{ $column }
             && defined $mapped_column )
        {
            # key != undef
            $item->{ $mapped_column } = delete $item->{ $column };
        }
        elsif (    exists $item->{ $column }
                && !defined $mapped_column )
        {
            # key == undef
            delete $item->{ $column };
        }
    }

    return $item;
}

=head3 _to_model

Helper function that maps REST api objects into Koha::Hold
attribute names.

=cut

sub _to_model {
    my $item = shift;

    foreach my $attribute ( keys %{ $Koha::REST::V1::Items::to_model_mapping } ) {
        my $mapped_attribute = $Koha::REST::V1::Items::to_model_mapping->{$attribute};
        if (    exists $item->{ $attribute }
             && defined $mapped_attribute )
        {
            # key => !undef
            $item->{ $mapped_attribute } = delete $item->{ $attribute };
        }
        elsif (    exists $item->{ $attribute }
                && !defined $mapped_attribute )
        {
            # key => undef / to be deleted
            delete $item->{ $attribute };
        }
    }

    return $item;
}

=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    itemnumber => 'item_id',
    biblionumber => 'biblio_id',
    biblioitemnumber => undef,
    barcode => 'external_id',
    dateaccessioned => 'acquisition_date',
    booksellerid => 'acquisition_source',
    homebranch => 'home_library_id',
    price => 'purchase_price',
    replacementprice => 'replacement_price',
    replacementpricedate => 'replacement_price_date',
    datelastborrowed => 'last_checkout_date',
    datelastseen => 'last_seen_date',
    stack => undef,
    notforloan => 'not_for_loan_status',
    damaged => 'damaged_status',
    damaged_on => 'damaged_date',
    itemlost => 'lost_status',
    itemlost_on => 'lost_date',
    withdrawn => 'withdrawn',
    withdrawn_on => 'withdrawn_date',
    itemcallnumber => 'callnumber',
    coded_location_qualifier => 'coded_location_qualifier',
    issues => 'checkouts_count',
    renewals => 'renewals_count',
    reserves => 'holds_count',
    restricted => 'restricted_status',
    itemnotes => 'public_notes',
    itemnotes_nonpublic => 'internal_notes',
    holdingbranch => 'holding_library_id',
    paidfor => undef,
    timestamp => 'timestamp',
    location => 'location',
    permanent_location => 'permanent_location',
    onloan => 'checked_out_date',
    cn_source => 'call_number_source',
    cn_sort => 'call_number_sort',
    ccode => 'collection_code',
    materials => 'materials_notes',
    uri => 'uri',
    itype => 'item_type',
    more_subfields_xml => 'extended_subfields',
    enumchron => 'serial_issue_number',
    copynumber => 'copy_number',
    stocknumber => 'inventory_number',
    new_status => 'new_status'
};

=head3 $to_model_mapping

=cut

our $to_model_mapping = {
    item_id => 'itemnumber',
    biblio_id => 'biblionumber',
    external_id => 'barcode',
    acquisition_date => 'dateaccessioned',
    acquisition_source => 'booksellerid',
    home_library_id => 'homebranch',
    purchase_price => 'price',
    replacement_price => 'replacementprice',
    replacement_price_date => 'replacementpricedate',
    last_checkout_date => 'datelastborrowed',
    last_seen_date => 'datelastseen',
    not_for_loan_status => 'notforloan',
    damaged_status => 'damaged',
    damaged_date => 'damaged_on',
    lost_status => 'itemlost',
    lost_date => 'itemlost_on',
    withdrawn => 'withdrawn',
    withdrawn_date => 'withdrawn_on',
    callnumber => 'itemcallnumber',
    coded_location_qualifier => 'coded_location_qualifier',
    checkouts_count => 'issues',
    renewals_count => 'renewals',
    holds_count => 'reserves',
    restricted_status => 'restricted',
    public_notes => 'itemnotes',
    internal_notes => 'itemnotes_nonpublic',
    holding_library_id => 'holdingbranch',
    timestamp => 'timestamp',
    location => 'location',
    permanent_location => 'permanent_location',
    checked_out_date => 'onloan',
    call_number_source => 'cn_source',
    call_number_sort => 'cn_sort',
    collection_code => 'ccode',
    materials_notes => 'materials',
    uri => 'uri',
    item_type => 'itype',
    extended_subfields => 'more_subfields_xml',
    serial_issue_number => 'enumchron',
    copy_number => 'copynumber',
    inventory_number => 'stocknumber',
    new_status => 'new_status'
};

1;
