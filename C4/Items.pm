package C4::Items;

# Copyright 2007 LibLime, Inc.
# Parts Copyright Biblibre 2010
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

use strict;
#use warnings; FIXME - Bug 2505

use vars qw(@ISA @EXPORT);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);

    @EXPORT = qw(
        GetItem
        AddItemFromMarc
        AddItem
        AddItemBatchFromMarc
        ModItemFromMarc
        Item2Marc
        ModItem
        ModDateLastSeen
        ModItemTransfer
        DelItem
        CheckItemPreSave
        GetItemsForInventory
        GetItemsInfo
        GetItemsLocationInfo
        GetHostItemsInfo
        get_hostitemnumbers_of
        GetHiddenItemnumbers
        ItemSafeToDelete
        DelItemCheck
        MoveItemFromBiblio
        GetLatestAcquisitions
        CartToShelf
        ShelfToCart
        GetAnalyticsCount
        SearchItemsByField
        SearchItems
        PrepareItemrecordDisplay
    );
}

use Carp;
use C4::Context;
use C4::Koha;
use C4::Biblio;
use Koha::DateUtils;
use MARC::Record;
use C4::ClassSource;
use C4::Log;
use List::MoreUtils qw(any);
use YAML qw(Load);
use DateTime::Format::MySQL;
use Data::Dumper; # used as part of logging item record changes, not just for
                  # debugging; so please don't remove this

use Koha::AuthorisedValues;
use Koha::DateUtils qw(dt_from_string);
use Koha::Database;

use Koha::Biblioitems;
use Koha::Items;
use Koha::ItemTypes;
use Koha::SearchEngine;
use Koha::SearchEngine::Search;
use Koha::Libraries;

=head1 NAME

C4::Items - item management functions

=head1 DESCRIPTION

This module contains an API for manipulating item 
records in Koha, and is used by cataloguing, circulation,
acquisitions, and serials management.

# FIXME This POD is not up-to-date
A Koha item record is stored in two places: the
items table and embedded in a MARC tag in the XML
version of the associated bib record in C<biblioitems.marcxml>.
This is done to allow the item information to be readily
indexed (e.g., by Zebra), but means that each item
modification transaction must keep the items table
and the MARC XML in sync at all times.

Consequently, all code that creates, modifies, or deletes
item records B<must> use an appropriate function from 
C<C4::Items>.  If no existing function is suitable, it is
better to add one to C<C4::Items> than to use add
one-off SQL statements to add or modify items.

The items table will be considered authoritative.  In other
words, if there is ever a discrepancy between the items
table and the MARC XML, the items table should be considered
accurate.

=head1 HISTORICAL NOTE

Most of the functions in C<C4::Items> were originally in
the C<C4::Biblio> module.

=head1 CORE EXPORTED FUNCTIONS

The following functions are meant for use by users
of C<C4::Items>

=cut

=head2 GetItem

  $item = GetItem($itemnumber,$barcode,$serial);

Return item information, for a given itemnumber or barcode.
The return value is a hashref mapping item column
names to values.  If C<$serial> is true, include serial publication data.

=cut

sub GetItem {
    my ($itemnumber,$barcode, $serial) = @_;
    my $dbh = C4::Context->dbh;

    my $item;
    if ($itemnumber) {
        $item = Koha::Items->find( $itemnumber );
    } else {
        $item = Koha::Items->find( { barcode => $barcode } );
    }

    return unless ( $item );

    my $data = $item->unblessed();
    $data->{itype} = $item->effective_itemtype(); # set the correct itype

    if ($serial) {
        my $ssth = $dbh->prepare("SELECT serialseq,publisheddate from serialitems left join serial on serialitems.serialid=serial.serialid where serialitems.itemnumber=?");
        $ssth->execute( $data->{'itemnumber'} );
        ( $data->{'serialseq'}, $data->{'publisheddate'} ) = $ssth->fetchrow_array();
    }

    return $data;
}    # sub GetItem

=head2 CartToShelf

  CartToShelf($itemnumber);

Set the current shelving location of the item record
to its stored permanent shelving location.  This is
primarily used to indicate when an item whose current
location is a special processing ('PROC') or shelving cart
('CART') location is back in the stacks.

=cut

sub CartToShelf {
    my ( $itemnumber ) = @_;

    unless ( $itemnumber ) {
        croak "FAILED CartToShelf() - no itemnumber supplied";
    }

    my $item = GetItem($itemnumber);
    if ( $item->{location} eq 'CART' ) {
        $item->{location} = $item->{permanent_location};
        ModItem($item, undef, $itemnumber);
    }
}

=head2 ShelfToCart

  ShelfToCart($itemnumber);

Set the current shelving location of the item
to shelving cart ('CART').

=cut

sub ShelfToCart {
    my ( $itemnumber ) = @_;

    unless ( $itemnumber ) {
        croak "FAILED ShelfToCart() - no itemnumber supplied";
    }

    my $item = GetItem($itemnumber);
    $item->{'location'} = 'CART';
    ModItem($item, undef, $itemnumber);
}

=head2 AddItemFromMarc

  my ($biblionumber, $biblioitemnumber, $itemnumber) 
      = AddItemFromMarc($source_item_marc, $biblionumber);

Given a MARC::Record object containing an embedded item
record and a biblionumber, create a new item record.

=cut

sub AddItemFromMarc {
    my ( $source_item_marc, $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;

    # parse item hash from MARC
    my $frameworkcode = C4::Biblio::GetFrameworkCode( $biblionumber );
    my ($itemtag,$itemsubfield)=C4::Biblio::GetMarcFromKohaField("items.itemnumber",$frameworkcode);

    my $localitemmarc=MARC::Record->new;
    $localitemmarc->append_fields($source_item_marc->field($itemtag));
    my $item = TransformMarcToKoha( $localitemmarc, $frameworkcode ,'items');
    my $unlinked_item_subfields = _get_unlinked_item_subfields($localitemmarc, $frameworkcode);
    return AddItem($item, $biblionumber, $dbh, $frameworkcode, $unlinked_item_subfields);
}

=head2 AddItem

  my ($biblionumber, $biblioitemnumber, $itemnumber) 
      = AddItem($item, $biblionumber[, $dbh, $frameworkcode, $unlinked_item_subfields]);

Given a hash containing item column names as keys,
create a new Koha item record.

The first two optional parameters (C<$dbh> and C<$frameworkcode>)
do not need to be supplied for general use; they exist
simply to allow them to be picked up from AddItemFromMarc.

The final optional parameter, C<$unlinked_item_subfields>, contains
an arrayref containing subfields present in the original MARC
representation of the item (e.g., from the item editor) that are
not mapped to C<items> columns directly but should instead
be stored in C<items.more_subfields_xml> and included in 
the biblio items tag for display and indexing.

=cut

sub AddItem {
    my $item         = shift;
    my $biblionumber = shift;

    my $dbh           = @_ ? shift : C4::Context->dbh;
    my $frameworkcode = @_ ? shift : C4::Biblio::GetFrameworkCode($biblionumber);
    my $unlinked_item_subfields;
    if (@_) {
        $unlinked_item_subfields = shift;
    }

    # needs old biblionumber and biblioitemnumber
    $item->{'biblionumber'} = $biblionumber;
    my $sth = $dbh->prepare("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
    $sth->execute( $item->{'biblionumber'} );
    ( $item->{'biblioitemnumber'} ) = $sth->fetchrow;

    _set_defaults_for_add($item);
    _set_derived_columns_for_add($item);
    $item->{'more_subfields_xml'} = _get_unlinked_subfields_xml($unlinked_item_subfields);

    # FIXME - checks here
    unless ( $item->{itype} ) {    # default to biblioitem.itemtype if no itype
        my $itype_sth = $dbh->prepare("SELECT itemtype FROM biblioitems WHERE biblionumber = ?");
        $itype_sth->execute( $item->{'biblionumber'} );
        ( $item->{'itype'} ) = $itype_sth->fetchrow_array;
    }

    my ( $itemnumber, $error ) = _koha_new_item( $item, $item->{barcode} );
    return if $error;

    $item->{'itemnumber'} = $itemnumber;

    ModZebra( $item->{biblionumber}, "specialUpdate", "biblioserver" );

    logaction( "CATALOGUING", "ADD", $itemnumber, "item" )
      if C4::Context->preference("CataloguingLog");

    return ( $item->{biblionumber}, $item->{biblioitemnumber}, $itemnumber );
}

=head2 AddItemBatchFromMarc

  ($itemnumber_ref, $error_ref) = AddItemBatchFromMarc($record, 
             $biblionumber, $biblioitemnumber, $frameworkcode);

Efficiently create item records from a MARC biblio record with
embedded item fields.  This routine is suitable for batch jobs.

This API assumes that the bib record has already been
saved to the C<biblio> and C<biblioitems> tables.  It does
not expect that C<biblio_metadata.metadata> is populated, but it
will do so via a call to ModBibiloMarc.

The goal of this API is to have a similar effect to using AddBiblio
and AddItems in succession, but without inefficient repeated
parsing of the MARC XML bib record.

This function returns an arrayref of new itemsnumbers and an arrayref of item
errors encountered during the processing.  Each entry in the errors
list is a hashref containing the following keys:

=over

=item item_sequence

Sequence number of original item tag in the MARC record.

=item item_barcode

Item barcode, provide to assist in the construction of
useful error messages.

=item error_code

Code representing the error condition.  Can be 'duplicate_barcode',
'invalid_homebranch', or 'invalid_holdingbranch'.

=item error_information

Additional information appropriate to the error condition.

=back

=cut

sub AddItemBatchFromMarc {
    my ($record, $biblionumber, $biblioitemnumber, $frameworkcode) = @_;
    my $error;
    my @itemnumbers = ();
    my @errors = ();
    my $dbh = C4::Context->dbh;

    # We modify the record, so lets work on a clone so we don't change the
    # original.
    $record = $record->clone();
    # loop through the item tags and start creating items
    my @bad_item_fields = ();
    my ($itemtag, $itemsubfield) = C4::Biblio::GetMarcFromKohaField("items.itemnumber",'');
    my $item_sequence_num = 0;
    ITEMFIELD: foreach my $item_field ($record->field($itemtag)) {
        $item_sequence_num++;
        # we take the item field and stick it into a new
        # MARC record -- this is required so far because (FIXME)
        # TransformMarcToKoha requires a MARC::Record, not a MARC::Field
        # and there is no TransformMarcFieldToKoha
        my $temp_item_marc = MARC::Record->new();
        $temp_item_marc->append_fields($item_field);
    
        # add biblionumber and biblioitemnumber
        my $item = TransformMarcToKoha( $temp_item_marc, $frameworkcode, 'items' );
        my $unlinked_item_subfields = _get_unlinked_item_subfields($temp_item_marc, $frameworkcode);
        $item->{'more_subfields_xml'} = _get_unlinked_subfields_xml($unlinked_item_subfields);
        $item->{'biblionumber'} = $biblionumber;
        $item->{'biblioitemnumber'} = $biblioitemnumber;

        # check for duplicate barcode
        my %item_errors = CheckItemPreSave($item);
        if (%item_errors) {
            push @errors, _repack_item_errors($item_sequence_num, $item, \%item_errors);
            push @bad_item_fields, $item_field;
            next ITEMFIELD;
        }

        _set_defaults_for_add($item);
        _set_derived_columns_for_add($item);
        my ( $itemnumber, $error ) = _koha_new_item( $item, $item->{barcode} );
        warn $error if $error;
        push @itemnumbers, $itemnumber; # FIXME not checking error
        $item->{'itemnumber'} = $itemnumber;

        logaction("CATALOGUING", "ADD", $itemnumber, "item") if C4::Context->preference("CataloguingLog"); 

        my $new_item_marc = _marc_from_item_hash($item, $frameworkcode, $unlinked_item_subfields);
        $item_field->replace_with($new_item_marc->field($itemtag));
    }

    # remove any MARC item fields for rejected items
    foreach my $item_field (@bad_item_fields) {
        $record->delete_field($item_field);
    }

    # update the MARC biblio
 #   $biblionumber = ModBiblioMarc( $record, $biblionumber, $frameworkcode );

    return (\@itemnumbers, \@errors);
}

=head2 ModItemFromMarc

  ModItemFromMarc($item_marc, $biblionumber, $itemnumber);

This function updates an item record based on a supplied
C<MARC::Record> object containing an embedded item field.
This API is meant for the use of C<additem.pl>; for 
other purposes, C<ModItem> should be used.

This function uses the hash %default_values_for_mod_from_marc,
which contains default values for item fields to
apply when modifying an item.  This is needed because
if an item field's value is cleared, TransformMarcToKoha
does not include the column in the
hash that's passed to ModItem, which without
use of this hash makes it impossible to clear
an item field's value.  See bug 2466.

Note that only columns that can be directly
changed from the cataloging and serials
item editors are included in this hash.

Returns item record

=cut

sub _build_default_values_for_mod_marc {
    # Has no framework parameter anymore, since Default is authoritative
    # for Koha to MARC mappings.

    my $cache     = Koha::Caches->get_instance();
    my $cache_key = "default_value_for_mod_marc-";
    my $cached    = $cache->get_from_cache($cache_key);
    return $cached if $cached;

    my $default_values = {
        barcode                  => undef,
        booksellerid             => undef,
        ccode                    => undef,
        'items.cn_source'        => undef,
        coded_location_qualifier => undef,
        copynumber               => undef,
        damaged                  => 0,
        enumchron                => undef,
        holdingbranch            => undef,
        homebranch               => undef,
        itemcallnumber           => undef,
        itemlost                 => 0,
        itemnotes                => undef,
        itemnotes_nonpublic      => undef,
        itype                    => undef,
        location                 => undef,
        permanent_location       => undef,
        materials                => undef,
        new_status               => undef,
        notforloan               => 0,
        # paidfor => undef, # commented, see bug 12817
        price                    => undef,
        replacementprice         => undef,
        replacementpricedate     => undef,
        restricted               => undef,
        stack                    => undef,
        stocknumber              => undef,
        uri                      => undef,
        withdrawn                => 0,
    };
    my %default_values_for_mod_from_marc;
    while ( my ( $field, $default_value ) = each %$default_values ) {
        my $kohafield = $field;
        $kohafield =~ s|^([^\.]+)$|items.$1|;
        $default_values_for_mod_from_marc{$field} = $default_value
            if C4::Biblio::GetMarcFromKohaField( $kohafield );
    }

    $cache->set_in_cache($cache_key, \%default_values_for_mod_from_marc);
    return \%default_values_for_mod_from_marc;
}

sub ModItemFromMarc {
    my $item_marc = shift;
    my $biblionumber = shift;
    my $itemnumber = shift;

    my $frameworkcode = C4::Biblio::GetFrameworkCode($biblionumber);
    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber", $frameworkcode );

    my $localitemmarc = MARC::Record->new;
    $localitemmarc->append_fields( $item_marc->field($itemtag) );
    my $item = TransformMarcToKoha( $localitemmarc, $frameworkcode, 'items' );
    my $default_values = _build_default_values_for_mod_marc();
    foreach my $item_field ( keys %$default_values ) {
        $item->{$item_field} = $default_values->{$item_field}
          unless exists $item->{$item_field};
    }
    my $unlinked_item_subfields = _get_unlinked_item_subfields( $localitemmarc, $frameworkcode );

    ModItem( $item, $biblionumber, $itemnumber, { unlinked_item_subfields => $unlinked_item_subfields } );
    return $item;
}

=head2 ModItem

ModItem(
    { column => $newvalue },
    $biblionumber,
    $itemnumber,
    {
        [ unlinked_item_subfields => $unlinked_item_subfields, ]
        [ log_action => 1, ]
    }
);

Change one or more columns in an item record and update
the MARC representation of the item.

The first argument is a hashref mapping from item column
names to the new values.  The second and third arguments
are the biblionumber and itemnumber, respectively.
The fourth, optional parameter (additional_params) may contain the keys
unlinked_item_subfields and log_action.

C<$unlinked_item_subfields> contains an arrayref containing
subfields present in the original MARC
representation of the item (e.g., from the item editor) that are
not mapped to C<items> columns directly but should instead
be stored in C<items.more_subfields_xml> and included in 
the biblio items tag for display and indexing.

If one of the changed columns is used to calculate
the derived value of a column such as C<items.cn_sort>, 
this routine will perform the necessary calculation
and set the value.

If log_action is set to false, the action will not be logged.
If log_action is true or undefined, the action will be logged.

=cut

sub ModItem {
    my ( $item, $biblionumber, $itemnumber, $additional_params ) = @_;
    my $log_action = $additional_params->{log_action} // 1;
    my $unlinked_item_subfields = $additional_params->{unlinked_item_subfields};

    # if $biblionumber is undefined, get it from the current item
    unless (defined $biblionumber) {
        $biblionumber = _get_single_item_column('biblionumber', $itemnumber);
    }

    if ($unlinked_item_subfields) {
        $item->{'more_subfields_xml'} = _get_unlinked_subfields_xml($unlinked_item_subfields);
    };

    $item->{'itemnumber'} = $itemnumber or return;

    my @fields = qw( itemlost withdrawn damaged );

    # Only call GetItem if we need to set an "on" date field
    if ( $item->{itemlost} || $item->{withdrawn} || $item->{damaged} ) {
        my $pre_mod_item = GetItem( $item->{'itemnumber'} );
        for my $field (@fields) {
            if (    defined( $item->{$field} )
                and not $pre_mod_item->{$field}
                and $item->{$field} )
            {
                $item->{ $field . '_on' } =
                  DateTime::Format::MySQL->format_datetime( dt_from_string() );
            }
        }
    }

    # If the field is defined but empty, we are removing and,
    # and thus need to clear out the 'on' field as well
    for my $field (@fields) {
        if ( defined( $item->{$field} ) && !$item->{$field} ) {
            $item->{ $field . '_on' } = undef;
        }
    }


    _set_derived_columns_for_mod($item);
    _do_column_fixes_for_mod($item);
    # FIXME add checks
    # duplicate barcode
    # attempt to change itemnumber
    # attempt to change biblionumber (if we want
    # an API to relink an item to a different bib,
    # it should be a separate function)

    # update items table
    _koha_modify_item($item);

    # request that bib be reindexed so that searching on current
    # item status is possible
    ModZebra( $biblionumber, "specialUpdate", "biblioserver" );

    logaction( "CATALOGUING", "MODIFY", $itemnumber, "item " . Dumper($item) )
      if $log_action && C4::Context->preference("CataloguingLog");
}

=head2 ModItemTransfer

  ModItemTransfer($itenumber, $frombranch, $tobranch);

Marks an item as being transferred from one branch
to another.

=cut

sub ModItemTransfer {
    my ( $itemnumber, $frombranch, $tobranch ) = @_;

    my $dbh = C4::Context->dbh;

    # Remove the 'shelving cart' location status if it is being used.
    CartToShelf( $itemnumber ) if ( C4::Context->preference("ReturnToShelvingCart") );

    $dbh->do("UPDATE branchtransfers SET datearrived = NOW(), comments = ? WHERE itemnumber = ? AND datearrived IS NULL", undef, "Canceled, new transfer from $frombranch to $tobranch created", $itemnumber);

    #new entry in branchtransfers....
    my $sth = $dbh->prepare(
        "INSERT INTO branchtransfers (itemnumber, frombranch, datesent, tobranch)
        VALUES (?, ?, NOW(), ?)");
    $sth->execute($itemnumber, $frombranch, $tobranch);

    ModItem({ holdingbranch => $tobranch }, undef, $itemnumber);
    ModDateLastSeen($itemnumber);
    return;
}

=head2 ModDateLastSeen

ModDateLastSeen( $itemnumber, $leave_item_lost );

Mark item as seen. Is called when an item is issued, returned or manually marked during inventory/stocktaking.
C<$itemnumber> is the item number
C<$leave_item_lost> determines if a lost item will be found or remain lost

=cut

sub ModDateLastSeen {
    my ( $itemnumber, $leave_item_lost ) = @_;

    my $today = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });

    my $params;
    $params->{datelastseen} = $today;
    $params->{itemlost} = 0 unless $leave_item_lost;

    ModItem( $params, undef, $itemnumber, { log_action => 0 } );
}

=head2 DelItem

  DelItem({ itemnumber => $itemnumber, [ biblionumber => $biblionumber ] } );

Exported function (core API) for deleting an item record in Koha.

=cut

sub DelItem {
    my ( $params ) = @_;

    my $itemnumber   = $params->{itemnumber};
    my $biblionumber = $params->{biblionumber};

    unless ($biblionumber) {
        my $item = Koha::Items->find( $itemnumber );
        $biblionumber = $item ? $item->biblio->biblionumber : undef;
    }

    # If there is no biblionumber for the given itemnumber, there is nothing to delete
    return 0 unless $biblionumber;

    # FIXME check the item has no current issues
    my $deleted = _koha_delete_item( $itemnumber );

    ModZebra( $biblionumber, "specialUpdate", "biblioserver" );

    #search item field code
    logaction("CATALOGUING", "DELETE", $itemnumber, "item") if C4::Context->preference("CataloguingLog");
    return $deleted;
}

=head2 CheckItemPreSave

    my $item_ref = TransformMarcToKoha($marc, 'items');
    # do stuff
    my %errors = CheckItemPreSave($item_ref);
    if (exists $errors{'duplicate_barcode'}) {
        print "item has duplicate barcode: ", $errors{'duplicate_barcode'}, "\n";
    } elsif (exists $errors{'invalid_homebranch'}) {
        print "item has invalid home branch: ", $errors{'invalid_homebranch'}, "\n";
    } elsif (exists $errors{'invalid_holdingbranch'}) {
        print "item has invalid holding branch: ", $errors{'invalid_holdingbranch'}, "\n";
    } else {
        print "item is OK";
    }

Given a hashref containing item fields, determine if it can be
inserted or updated in the database.  Specifically, checks for
database integrity issues, and returns a hash containing any
of the following keys, if applicable.

=over 2

=item duplicate_barcode

Barcode, if it duplicates one already found in the database.

=item invalid_homebranch

Home branch, if not defined in branches table.

=item invalid_holdingbranch

Holding branch, if not defined in branches table.

=back

This function does NOT implement any policy-related checks,
e.g., whether current operator is allowed to save an
item that has a given branch code.

=cut

sub CheckItemPreSave {
    my $item_ref = shift;

    my %errors = ();

    # check for duplicate barcode
    if (exists $item_ref->{'barcode'} and defined $item_ref->{'barcode'}) {
        my $existing_item= Koha::Items->find({barcode => $item_ref->{'barcode'}});
        if ($existing_item) {
            if (!exists $item_ref->{'itemnumber'}                       # new item
                or $item_ref->{'itemnumber'} != $existing_item->itemnumber) { # existing item
                $errors{'duplicate_barcode'} = $item_ref->{'barcode'};
            }
        }
    }

    # check for valid home branch
    if (exists $item_ref->{'homebranch'} and defined $item_ref->{'homebranch'}) {
        my $home_library = Koha::Libraries->find( $item_ref->{homebranch} );
        unless (defined $home_library) {
            $errors{'invalid_homebranch'} = $item_ref->{'homebranch'};
        }
    }

    # check for valid holding branch
    if (exists $item_ref->{'holdingbranch'} and defined $item_ref->{'holdingbranch'}) {
        my $holding_library = Koha::Libraries->find( $item_ref->{holdingbranch} );
        unless (defined $holding_library) {
            $errors{'invalid_holdingbranch'} = $item_ref->{'holdingbranch'};
        }
    }

    return %errors;

}

=head1 EXPORTED SPECIAL ACCESSOR FUNCTIONS

The following functions provide various ways of 
getting an item record, a set of item records, or
lists of authorized values for certain item fields.

=cut

=head2 GetItemsForInventory

($itemlist, $iTotalRecords) = GetItemsForInventory( {
  minlocation  => $minlocation,
  maxlocation  => $maxlocation,
  location     => $location,
  itemtype     => $itemtype,
  ignoreissued => $ignoreissued,
  datelastseen => $datelastseen,
  branchcode   => $branchcode,
  branch       => $branch,
  offset       => $offset,
  size         => $size,
  statushash   => $statushash,
} );

Retrieve a list of title/authors/barcode/callnumber, for biblio inventory.

The sub returns a reference to a list of hashes, each containing
itemnumber, author, title, barcode, item callnumber, and date last
seen. It is ordered by callnumber then title.

The required minlocation & maxlocation parameters are used to specify a range of item callnumbers
the datelastseen can be used to specify that you want to see items not seen since a past date only.
offset & size can be used to retrieve only a part of the whole listing (defaut behaviour)
$statushash requires a hashref that has the authorized values fieldname (intems.notforloan, etc...) as keys, and an arrayref of statuscodes we are searching for as values.

$iTotalRecords is the number of rows that would have been returned without the $offset, $size limit clause

=cut

sub GetItemsForInventory {
    my ( $parameters ) = @_;
    my $minlocation  = $parameters->{'minlocation'}  // '';
    my $maxlocation  = $parameters->{'maxlocation'}  // '';
    my $location     = $parameters->{'location'}     // '';
    my $itemtype     = $parameters->{'itemtype'}     // '';
    my $ignoreissued = $parameters->{'ignoreissued'} // '';
    my $datelastseen = $parameters->{'datelastseen'} // '';
    my $branchcode   = $parameters->{'branchcode'}   // '';
    my $branch       = $parameters->{'branch'}       // '';
    my $offset       = $parameters->{'offset'}       // '';
    my $size         = $parameters->{'size'}         // '';
    my $statushash   = $parameters->{'statushash'}   // '';

    my $dbh = C4::Context->dbh;
    my ( @bind_params, @where_strings );

    my $select_columns = q{
        SELECT items.itemnumber, barcode, itemcallnumber, title, author, biblio.biblionumber, biblio.frameworkcode, datelastseen, homebranch, location, notforloan, damaged, itemlost, withdrawn, stocknumber
    };
    my $select_count = q{SELECT COUNT(*)};
    my $query = q{
        FROM items
        LEFT JOIN biblio ON items.biblionumber = biblio.biblionumber
        LEFT JOIN biblioitems on items.biblionumber = biblioitems.biblionumber
    };
    if ($statushash){
        for my $authvfield (keys %$statushash){
            if ( scalar @{$statushash->{$authvfield}} > 0 ){
                my $joinedvals = join ',', @{$statushash->{$authvfield}};
                push @where_strings, "$authvfield in (" . $joinedvals . ")";
            }
        }
    }

    if ($minlocation) {
        push @where_strings, 'itemcallnumber >= ?';
        push @bind_params, $minlocation;
    }

    if ($maxlocation) {
        push @where_strings, 'itemcallnumber <= ?';
        push @bind_params, $maxlocation;
    }

    if ($datelastseen) {
        $datelastseen = output_pref({ str => $datelastseen, dateformat => 'iso', dateonly => 1 });
        push @where_strings, '(datelastseen < ? OR datelastseen IS NULL)';
        push @bind_params, $datelastseen;
    }

    if ( $location ) {
        push @where_strings, 'items.location = ?';
        push @bind_params, $location;
    }

    if ( $branchcode ) {
        if($branch eq "homebranch"){
        push @where_strings, 'items.homebranch = ?';
        }else{
            push @where_strings, 'items.holdingbranch = ?';
        }
        push @bind_params, $branchcode;
    }

    if ( $itemtype ) {
        push @where_strings, 'biblioitems.itemtype = ?';
        push @bind_params, $itemtype;
    }

    if ( $ignoreissued) {
        $query .= "LEFT JOIN issues ON items.itemnumber = issues.itemnumber ";
        push @where_strings, 'issues.date_due IS NULL';
    }

    if ( @where_strings ) {
        $query .= 'WHERE ';
        $query .= join ' AND ', @where_strings;
    }
    my $count_query = $select_count . $query;
    $query .= ' ORDER BY items.cn_sort, itemcallnumber, title';
    $query .= " LIMIT $offset, $size" if ($offset and $size);
    $query = $select_columns . $query;
    my $sth = $dbh->prepare($query);
    $sth->execute( @bind_params );

    my @results = ();
    my $tmpresults = $sth->fetchall_arrayref({});
    $sth = $dbh->prepare( $count_query );
    $sth->execute( @bind_params );
    my ($iTotalRecords) = $sth->fetchrow_array();

    my @avs = Koha::AuthorisedValues->search(
        {   'marc_subfield_structures.kohafield' => { '>' => '' },
            'me.authorised_value'                => { '>' => '' },
        },
        {   join     => { category => 'marc_subfield_structures' },
            distinct => ['marc_subfield_structures.kohafield, me.category, frameworkcode, me.authorised_value'],
            '+select' => [ 'marc_subfield_structures.kohafield', 'marc_subfield_structures.frameworkcode', 'me.authorised_value', 'me.lib' ],
            '+as'     => [ 'kohafield',                          'frameworkcode',                          'authorised_value',    'lib' ],
        }
    );

    my $avmapping = { map { $_->get_column('kohafield') . ',' . $_->get_column('frameworkcode') . ',' . $_->get_column('authorised_value') => $_->get_column('lib') } @avs };

    foreach my $row (@$tmpresults) {

        # Auth values
        foreach (keys %$row) {
            if (defined($avmapping->{"items.$_,".$row->{'frameworkcode'}.",".$row->{$_}})) {
                $row->{$_} = $avmapping->{"items.$_,".$row->{'frameworkcode'}.",".$row->{$_}};
            }
        }
        push @results, $row;
    }

    return (\@results, $iTotalRecords);
}

=head2 GetItemsInfo

  @results = GetItemsInfo($biblionumber);

Returns information about items with the given biblionumber.

C<GetItemsInfo> returns a list of references-to-hash. Each element
contains a number of keys. Most of them are attributes from the
C<biblio>, C<biblioitems>, C<items>, and C<itemtypes> tables in the
Koha database. Other keys include:

=over 2

=item C<$data-E<gt>{branchname}>

The name (not the code) of the branch to which the book belongs.

=item C<$data-E<gt>{datelastseen}>

This is simply C<items.datelastseen>, except that while the date is
stored in YYYY-MM-DD format in the database, here it is converted to
DD/MM/YYYY format. A NULL date is returned as C<//>.

=item C<$data-E<gt>{datedue}>

=item C<$data-E<gt>{class}>

This is the concatenation of C<biblioitems.classification>, the book's
Dewey code, and C<biblioitems.subclass>.

=item C<$data-E<gt>{ocount}>

I think this is the number of copies of the book available.

=item C<$data-E<gt>{order}>

If this is set, it is set to C<One Order>.

=back

=cut

sub GetItemsInfo {
    my ( $biblionumber ) = @_;
    my $dbh   = C4::Context->dbh;
    require C4::Languages;
    my $language = C4::Languages::getlanguage();
    my $query = "
    SELECT items.*,
           biblio.*,
           biblioitems.volume,
           biblioitems.number,
           biblioitems.itemtype,
           biblioitems.isbn,
           biblioitems.issn,
           biblioitems.publicationyear,
           biblioitems.publishercode,
           biblioitems.volumedate,
           biblioitems.volumedesc,
           biblioitems.lccn,
           biblioitems.url,
           items.notforloan as itemnotforloan,
           issues.borrowernumber,
           issues.date_due as datedue,
           issues.onsite_checkout,
           borrowers.cardnumber,
           borrowers.surname,
           borrowers.firstname,
           borrowers.branchcode as bcode,
           serial.serialseq,
           serial.publisheddate,
           itemtypes.description,
           COALESCE( localization.translation, itemtypes.description ) AS translated_description,
           itemtypes.notforloan as notforloan_per_itemtype,
           holding.branchurl,
           holding.branchcode,
           holding.branchname,
           holding.opac_info as holding_branch_opac_info,
           home.opac_info as home_branch_opac_info
    ";
    $query .= "
     FROM items
     LEFT JOIN branches AS holding ON items.holdingbranch = holding.branchcode
     LEFT JOIN branches AS home ON items.homebranch=home.branchcode
     LEFT JOIN biblio      ON      biblio.biblionumber     = items.biblionumber
     LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber
     LEFT JOIN issues USING (itemnumber)
     LEFT JOIN borrowers USING (borrowernumber)
     LEFT JOIN serialitems USING (itemnumber)
     LEFT JOIN serial USING (serialid)
     LEFT JOIN itemtypes   ON   itemtypes.itemtype         = "
     . (C4::Context->preference('item-level_itypes') ? 'items.itype' : 'biblioitems.itemtype');
    $query .= q|
    LEFT JOIN localization ON itemtypes.itemtype = localization.code
        AND localization.entity = 'itemtypes'
        AND localization.lang = ?
    |;

    $query .= " WHERE items.biblionumber = ? ORDER BY home.branchname, items.enumchron, LPAD( items.copynumber, 8, '0' ), items.dateaccessioned DESC" ;
    my $sth = $dbh->prepare($query);
    $sth->execute($language, $biblionumber);
    my $i = 0;
    my @results;
    my $serial;

    my $userenv = C4::Context->userenv;
    my $want_not_same_branch = C4::Context->preference("IndependentBranches") && !C4::Context->IsSuperLibrarian();
    while ( my $data = $sth->fetchrow_hashref ) {
        if ( $data->{borrowernumber} && $want_not_same_branch) {
            $data->{'NOTSAMEBRANCH'} = $data->{'bcode'} ne $userenv->{branch};
        }

        $serial ||= $data->{'serial'};

        my $descriptions;
        # get notforloan complete status if applicable
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $data->{frameworkcode}, kohafield => 'items.notforloan', authorised_value => $data->{itemnotforloan} });
        $data->{notforloanvalue}     = $descriptions->{lib} // '';
        $data->{notforloanvalueopac} = $descriptions->{opac_description} // '';

        # get restricted status and description if applicable
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $data->{frameworkcode}, kohafield => 'items.restricted', authorised_value => $data->{restricted} });
        $data->{restricted}     = $descriptions->{lib} // '';
        $data->{restrictedopac} = $descriptions->{opac_description} // '';

        # my stack procedures
        $descriptions = Koha::AuthorisedValues->get_description_by_koha_field({frameworkcode => $data->{frameworkcode}, kohafield => 'items.stack', authorised_value => $data->{stack} });
        $data->{stack}          = $descriptions->{lib} // '';

        # Find the last 3 people who borrowed this item.
        my $sth2 = $dbh->prepare("SELECT * FROM old_issues,borrowers
                                    WHERE itemnumber = ?
                                    AND old_issues.borrowernumber = borrowers.borrowernumber
                                    ORDER BY returndate DESC
                                    LIMIT 3");
        $sth2->execute($data->{'itemnumber'});
        my $ii = 0;
        while (my $data2 = $sth2->fetchrow_hashref()) {
            $data->{"timestamp$ii"} = $data2->{'timestamp'} if $data2->{'timestamp'};
            $data->{"card$ii"}      = $data2->{'cardnumber'} if $data2->{'cardnumber'};
            $data->{"borrower$ii"}  = $data2->{'borrowernumber'} if $data2->{'borrowernumber'};
            $ii++;
        }

        $results[$i] = $data;
        $i++;
    }

    return $serial
        ? sort { ($b->{'publisheddate'} || $b->{'enumchron'}) cmp ($a->{'publisheddate'} || $a->{'enumchron'}) } @results
        : @results;
}

=head2 GetItemsLocationInfo

  my @itemlocinfo = GetItemsLocationInfo($biblionumber);

Returns the branch names, shelving location and itemcallnumber for each item attached to the biblio in question

C<GetItemsInfo> returns a list of references-to-hash. Data returned:

=over 2

=item C<$data-E<gt>{homebranch}>

Branch Name of the item's homebranch

=item C<$data-E<gt>{holdingbranch}>

Branch Name of the item's holdingbranch

=item C<$data-E<gt>{location}>

Item's shelving location code

=item C<$data-E<gt>{location_intranet}>

The intranet description for the Shelving Location as set in authorised_values 'LOC'

=item C<$data-E<gt>{location_opac}>

The OPAC description for the Shelving Location as set in authorised_values 'LOC'.  Falls back to intranet description if no OPAC 
description is set.

=item C<$data-E<gt>{itemcallnumber}>

Item's itemcallnumber

=item C<$data-E<gt>{cn_sort}>

Item's call number normalized for sorting

=back
  
=cut

sub GetItemsLocationInfo {
        my $biblionumber = shift;
        my @results;

	my $dbh = C4::Context->dbh;
	my $query = "SELECT a.branchname as homebranch, b.branchname as holdingbranch, 
			    location, itemcallnumber, cn_sort
		     FROM items, branches as a, branches as b
		     WHERE homebranch = a.branchcode AND holdingbranch = b.branchcode 
		     AND biblionumber = ?
		     ORDER BY cn_sort ASC";
	my $sth = $dbh->prepare($query);
        $sth->execute($biblionumber);

        while ( my $data = $sth->fetchrow_hashref ) {
             my $av = Koha::AuthorisedValues->search({ category => 'LOC', authorised_value => $data->{location} });
             $av = $av->count ? $av->next : undef;
             $data->{location_intranet} = $av ? $av->lib : '';
             $data->{location_opac}     = $av ? $av->opac_description : '';
	     push @results, $data;
	}
	return @results;
}

=head2 GetHostItemsInfo

    $hostiteminfo = GetHostItemsInfo($hostfield);
    Returns the iteminfo for items linked to records via a host field

=cut

sub GetHostItemsInfo {
    my ($record) = @_;
    my @returnitemsInfo;

    if( !C4::Context->preference('EasyAnalyticalRecords') ) {
        return @returnitemsInfo;
    }

    my @fields;
    if( C4::Context->preference('marcflavour') eq 'MARC21' ||
      C4::Context->preference('marcflavour') eq 'NORMARC') {
        @fields = $record->field('773');
    } elsif( C4::Context->preference('marcflavour') eq 'UNIMARC') {
        @fields = $record->field('461');
    }

    foreach my $hostfield ( @fields ) {
        my $hostbiblionumber = $hostfield->subfield("0");
        my $linkeditemnumber = $hostfield->subfield("9");
        my @hostitemInfos = GetItemsInfo($hostbiblionumber);
        foreach my $hostitemInfo (@hostitemInfos) {
            if( $hostitemInfo->{itemnumber} eq $linkeditemnumber ) {
                push @returnitemsInfo, $hostitemInfo;
                last;
            }
        }
    }
    return @returnitemsInfo;
}

=head2 GetLastAcquisitions

  my $lastacq = GetLastAcquisitions({'branches' => ('branch1','branch2'), 
                                    'itemtypes' => ('BK','BD')}, 10);

=cut

sub  GetLastAcquisitions {
	my ($data,$max) = @_;

	my $itemtype = C4::Context->preference('item-level_itypes') ? 'itype' : 'itemtype';
	
	my $number_of_branches = @{$data->{branches}};
	my $number_of_itemtypes   = @{$data->{itemtypes}};
	
	
	my @where = ('WHERE 1 '); 
	$number_of_branches and push @where
	   , 'AND holdingbranch IN (' 
	   , join(',', ('?') x $number_of_branches )
	   , ')'
	 ;
	
	$number_of_itemtypes and push @where
	   , "AND $itemtype IN (" 
	   , join(',', ('?') x $number_of_itemtypes )
	   , ')'
	 ;

	my $query = "SELECT biblio.biblionumber as biblionumber, title, dateaccessioned
				 FROM items RIGHT JOIN biblio ON (items.biblionumber=biblio.biblionumber) 
			            RIGHT JOIN biblioitems ON (items.biblioitemnumber=biblioitems.biblioitemnumber)
			            @where
			            GROUP BY biblio.biblionumber 
			            ORDER BY dateaccessioned DESC LIMIT $max";

	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare($query);
    
    $sth->execute((@{$data->{branches}}, @{$data->{itemtypes}}));
	
	my @results;
	while( my $row = $sth->fetchrow_hashref){
		push @results, {date => $row->{dateaccessioned} 
						, biblionumber => $row->{biblionumber}
						, title => $row->{title}};
	}
	
	return @results;
}

=head2 get_hostitemnumbers_of

  my @itemnumbers_of = get_hostitemnumbers_of($biblionumber);

Given a biblionumber, return the list of corresponding itemnumbers that are linked to it via host fields

Return a reference on a hash where key is a biblionumber and values are
references on array of itemnumbers.

=cut


sub get_hostitemnumbers_of {
    my ($biblionumber) = @_;
    my $marcrecord = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });

    return unless $marcrecord;

    my ( @returnhostitemnumbers, $tag, $biblio_s, $item_s );

    my $marcflavor = C4::Context->preference('marcflavour');
    if ( $marcflavor eq 'MARC21' || $marcflavor eq 'NORMARC' ) {
        $tag      = '773';
        $biblio_s = '0';
        $item_s   = '9';
    }
    elsif ( $marcflavor eq 'UNIMARC' ) {
        $tag      = '461';
        $biblio_s = '0';
        $item_s   = '9';
    }

    foreach my $hostfield ( $marcrecord->field($tag) ) {
        my $hostbiblionumber = $hostfield->subfield($biblio_s);
        next unless $hostbiblionumber; # have tag, don't have $biblio_s subfield
        my $linkeditemnumber = $hostfield->subfield($item_s);
        if ( ! $linkeditemnumber ) {
            warn "ERROR biblionumber $biblionumber has 773^0, but doesn't have 9";
            next;
        }
        my $is_from_biblio = Koha::Items->search({ itemnumber => $linkeditemnumber, biblionumber => $hostbiblionumber });
        push @returnhostitemnumbers, $linkeditemnumber
          if $is_from_biblio;
    }

    return @returnhostitemnumbers;
}

=head2 GetHiddenItemnumbers

    my @itemnumbers_to_hide = GetHiddenItemnumbers(@items);

Given a list of items it checks which should be hidden from the OPAC given
the current configuration. Returns a list of itemnumbers corresponding to
those that should be hidden.

=cut

sub GetHiddenItemnumbers {
    my (@items) = @_;
    my @resultitems;

    my $yaml = C4::Context->preference('OpacHiddenItems');
    return () if (! $yaml =~ /\S/ );
    $yaml = "$yaml\n\n"; # YAML is anal on ending \n. Surplus does not hurt
    my $hidingrules;
    eval {
        $hidingrules = YAML::Load($yaml);
    };
    if ($@) {
        warn "Unable to parse OpacHiddenItems syspref : $@";
        return ();
    }
    my $dbh = C4::Context->dbh;

    # For each item
    foreach my $item (@items) {

        # We check each rule
        foreach my $field (keys %$hidingrules) {
            my $val;
            if (exists $item->{$field}) {
                $val = $item->{$field};
            }
            else {
                my $query = "SELECT $field from items where itemnumber = ?";
                $val = $dbh->selectrow_array($query, undef, $item->{'itemnumber'});
            }
            $val = '' unless defined $val;

            # If the results matches the values in the yaml file
            if (any { $val eq $_ } @{$hidingrules->{$field}}) {

                # We add the itemnumber to the list
                push @resultitems, $item->{'itemnumber'};

                # If at least one rule matched for an item, no need to test the others
                last;
            }
        }
    }
    return @resultitems;
}

=head1 LIMITED USE FUNCTIONS

The following functions, while part of the public API,
are not exported.  This is generally because they are
meant to be used by only one script for a specific
purpose, and should not be used in any other context
without careful thought.

=cut

=head2 GetMarcItem

  my $item_marc = GetMarcItem($biblionumber, $itemnumber);

Returns MARC::Record of the item passed in parameter.
This function is meant for use only in C<cataloguing/additem.pl>,
where it is needed to support that script's MARC-like
editor.

=cut

sub GetMarcItem {
    my ( $biblionumber, $itemnumber ) = @_;

    # GetMarcItem has been revised so that it does the following:
    #  1. Gets the item information from the items table.
    #  2. Converts it to a MARC field for storage in the bib record.
    #
    # The previous behavior was:
    #  1. Get the bib record.
    #  2. Return the MARC tag corresponding to the item record.
    #
    # The difference is that one treats the items row as authoritative,
    # while the other treats the MARC representation as authoritative
    # under certain circumstances.

    my $itemrecord = GetItem($itemnumber);

    # Tack on 'items.' prefix to column names so that C4::Biblio::TransformKohaToMarc will work.
    # Also, don't emit a subfield if the underlying field is blank.

    
    return Item2Marc($itemrecord,$biblionumber);

}
sub Item2Marc {
	my ($itemrecord,$biblionumber)=@_;
    my $mungeditem = { 
        map {  
            defined($itemrecord->{$_}) && $itemrecord->{$_} ne '' ? ("items.$_" => $itemrecord->{$_}) : ()  
        } keys %{ $itemrecord } 
    };
    my $framework = C4::Biblio::GetFrameworkCode( $biblionumber );
    my $itemmarc = C4::Biblio::TransformKohaToMarc(
        $mungeditem, { no_split => 1},
    );
    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField(
        "items.itemnumber", $framework,
    );

    my $unlinked_item_subfields = _parse_unlinked_item_subfields_from_xml($mungeditem->{'items.more_subfields_xml'});
    if (defined $unlinked_item_subfields and $#$unlinked_item_subfields > -1) {
		foreach my $field ($itemmarc->field($itemtag)){
            $field->add_subfields(@$unlinked_item_subfields);
        }
    }
	return $itemmarc;
}

=head1 PRIVATE FUNCTIONS AND VARIABLES

The following functions are not meant to be called
directly, but are documented in order to explain
the inner workings of C<C4::Items>.

=cut

=head2 %derived_columns

This hash keeps track of item columns that
are strictly derived from other columns in
the item record and are not meant to be set
independently.

Each key in the hash should be the name of a
column (as named by TransformMarcToKoha).  Each
value should be hashref whose keys are the
columns on which the derived column depends.  The
hashref should also contain a 'BUILDER' key
that is a reference to a sub that calculates
the derived value.

=cut

my %derived_columns = (
    'items.cn_sort' => {
        'itemcallnumber' => 1,
        'items.cn_source' => 1,
        'BUILDER' => \&_calc_items_cn_sort,
    }
);

=head2 _set_derived_columns_for_add 

  _set_derived_column_for_add($item);

Given an item hash representing a new item to be added,
calculate any derived columns.  Currently the only
such column is C<items.cn_sort>.

=cut

sub _set_derived_columns_for_add {
    my $item = shift;

    foreach my $column (keys %derived_columns) {
        my $builder = $derived_columns{$column}->{'BUILDER'};
        my $source_values = {};
        foreach my $source_column (keys %{ $derived_columns{$column} }) {
            next if $source_column eq 'BUILDER';
            $source_values->{$source_column} = $item->{$source_column};
        }
        $builder->($item, $source_values);
    }
}

=head2 _set_derived_columns_for_mod 

  _set_derived_column_for_mod($item);

Given an item hash representing a new item to be modified.
calculate any derived columns.  Currently the only
such column is C<items.cn_sort>.

This routine differs from C<_set_derived_columns_for_add>
in that it needs to handle partial item records.  In other
words, the caller of C<ModItem> may have supplied only one
or two columns to be changed, so this function needs to
determine whether any of the columns to be changed affect
any of the derived columns.  Also, if a derived column
depends on more than one column, but the caller is not
changing all of then, this routine retrieves the unchanged
values from the database in order to ensure a correct
calculation.

=cut

sub _set_derived_columns_for_mod {
    my $item = shift;

    foreach my $column (keys %derived_columns) {
        my $builder = $derived_columns{$column}->{'BUILDER'};
        my $source_values = {};
        my %missing_sources = ();
        my $must_recalc = 0;
        foreach my $source_column (keys %{ $derived_columns{$column} }) {
            next if $source_column eq 'BUILDER';
            if (exists $item->{$source_column}) {
                $must_recalc = 1;
                $source_values->{$source_column} = $item->{$source_column};
            } else {
                $missing_sources{$source_column} = 1;
            }
        }
        if ($must_recalc) {
            foreach my $source_column (keys %missing_sources) {
                $source_values->{$source_column} = _get_single_item_column($source_column, $item->{'itemnumber'});
            }
            $builder->($item, $source_values);
        }
    }
}

=head2 _do_column_fixes_for_mod

  _do_column_fixes_for_mod($item);

Given an item hashref containing one or more
columns to modify, fix up certain values.
Specifically, set to 0 any passed value
of C<notforloan>, C<damaged>, C<itemlost>, or
C<withdrawn> that is either undefined or
contains the empty string.

=cut

sub _do_column_fixes_for_mod {
    my $item = shift;

    if (exists $item->{'notforloan'} and
        (not defined $item->{'notforloan'} or $item->{'notforloan'} eq '')) {
        $item->{'notforloan'} = 0;
    }
    if (exists $item->{'damaged'} and
        (not defined $item->{'damaged'} or $item->{'damaged'} eq '')) {
        $item->{'damaged'} = 0;
    }
    if (exists $item->{'itemlost'} and
        (not defined $item->{'itemlost'} or $item->{'itemlost'} eq '')) {
        $item->{'itemlost'} = 0;
    }
    if (exists $item->{'withdrawn'} and
        (not defined $item->{'withdrawn'} or $item->{'withdrawn'} eq '')) {
        $item->{'withdrawn'} = 0;
    }
    if (exists $item->{location}
        and $item->{location} ne 'CART'
        and $item->{location} ne 'PROC'
        and not $item->{permanent_location}
    ) {
        $item->{'permanent_location'} = $item->{'location'};
    }
    if (exists $item->{'timestamp'}) {
        delete $item->{'timestamp'};
    }
}

=head2 _get_single_item_column

  _get_single_item_column($column, $itemnumber);

Retrieves the value of a single column from an C<items>
row specified by C<$itemnumber>.

=cut

sub _get_single_item_column {
    my $column = shift;
    my $itemnumber = shift;
    
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT $column FROM items WHERE itemnumber = ?");
    $sth->execute($itemnumber);
    my ($value) = $sth->fetchrow();
    return $value; 
}

=head2 _calc_items_cn_sort

  _calc_items_cn_sort($item, $source_values);

Helper routine to calculate C<items.cn_sort>.

=cut

sub _calc_items_cn_sort {
    my $item = shift;
    my $source_values = shift;

    $item->{'items.cn_sort'} = GetClassSort($source_values->{'items.cn_source'}, $source_values->{'itemcallnumber'}, "");
}

=head2 _set_defaults_for_add 

  _set_defaults_for_add($item_hash);

Given an item hash representing an item to be added, set
correct default values for columns whose default value
is not handled by the DBMS.  This includes the following
columns:

=over 2

=item * 

C<items.dateaccessioned>

=item *

C<items.notforloan>

=item *

C<items.damaged>

=item *

C<items.itemlost>

=item *

C<items.withdrawn>

=back

=cut

sub _set_defaults_for_add {
    my $item = shift;
    $item->{dateaccessioned} ||= output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });
    $item->{$_} ||= 0 for (qw( notforloan damaged itemlost withdrawn));
}

=head2 _koha_new_item

  my ($itemnumber,$error) = _koha_new_item( $item, $barcode );

Perform the actual insert into the C<items> table.

=cut

sub _koha_new_item {
    my ( $item, $barcode ) = @_;
    my $dbh=C4::Context->dbh;  
    my $error;
    $item->{permanent_location} //= $item->{location};
    _mod_item_dates( $item );
    my $query =
           "INSERT INTO items SET
            biblionumber        = ?,
            biblioitemnumber    = ?,
            barcode             = ?,
            dateaccessioned     = ?,
            booksellerid        = ?,
            homebranch          = ?,
            price               = ?,
            replacementprice    = ?,
            replacementpricedate = ?,
            datelastborrowed    = ?,
            datelastseen        = ?,
            stack               = ?,
            notforloan          = ?,
            damaged             = ?,
            itemlost            = ?,
            withdrawn           = ?,
            itemcallnumber      = ?,
            coded_location_qualifier = ?,
            restricted          = ?,
            itemnotes           = ?,
            itemnotes_nonpublic = ?,
            holdingbranch       = ?,
            paidfor             = ?,
            location            = ?,
            permanent_location  = ?,
            onloan              = ?,
            issues              = ?,
            renewals            = ?,
            reserves            = ?,
            cn_source           = ?,
            cn_sort             = ?,
            ccode               = ?,
            itype               = ?,
            materials           = ?,
            uri                 = ?,
            enumchron           = ?,
            more_subfields_xml  = ?,
            copynumber          = ?,
            stocknumber         = ?,
            new_status          = ?
          ";
    my $sth = $dbh->prepare($query);
    my $today = output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 });
   $sth->execute(
            $item->{'biblionumber'},
            $item->{'biblioitemnumber'},
            $barcode,
            $item->{'dateaccessioned'},
            $item->{'booksellerid'},
            $item->{'homebranch'},
            $item->{'price'},
            $item->{'replacementprice'},
            $item->{'replacementpricedate'} || $today,
            $item->{datelastborrowed},
            $item->{datelastseen} || $today,
            $item->{stack},
            $item->{'notforloan'},
            $item->{'damaged'},
            $item->{'itemlost'},
            $item->{'withdrawn'},
            $item->{'itemcallnumber'},
            $item->{'coded_location_qualifier'},
            $item->{'restricted'},
            $item->{'itemnotes'},
            $item->{'itemnotes_nonpublic'},
            $item->{'holdingbranch'},
            $item->{'paidfor'},
            $item->{'location'},
            $item->{'permanent_location'},
            $item->{'onloan'},
            $item->{'issues'},
            $item->{'renewals'},
            $item->{'reserves'},
            $item->{'items.cn_source'},
            $item->{'items.cn_sort'},
            $item->{'ccode'},
            $item->{'itype'},
            $item->{'materials'},
            $item->{'uri'},
            $item->{'enumchron'},
            $item->{'more_subfields_xml'},
            $item->{'copynumber'},
            $item->{'stocknumber'},
            $item->{'new_status'},
    );

    my $itemnumber;
    if ( defined $sth->errstr ) {
        $error.="ERROR in _koha_new_item $query".$sth->errstr;
    }
    else {
        $itemnumber = $dbh->{'mysql_insertid'};
    }

    return ( $itemnumber, $error );
}

=head2 MoveItemFromBiblio

  MoveItemFromBiblio($itenumber, $frombiblio, $tobiblio);

Moves an item from a biblio to another

Returns undef if the move failed or the biblionumber of the destination record otherwise

=cut

sub MoveItemFromBiblio {
    my ($itemnumber, $frombiblio, $tobiblio) = @_;
    my $dbh = C4::Context->dbh;
    my ( $tobiblioitem ) = $dbh->selectrow_array(q|
        SELECT biblioitemnumber
        FROM biblioitems
        WHERE biblionumber = ?
    |, undef, $tobiblio );
    my $return = $dbh->do(q|
        UPDATE items
        SET biblioitemnumber = ?,
            biblionumber = ?
        WHERE itemnumber = ?
            AND biblionumber = ?
    |, undef, $tobiblioitem, $tobiblio, $itemnumber, $frombiblio );
    if ($return == 1) {
        ModZebra( $tobiblio, "specialUpdate", "biblioserver" );
        ModZebra( $frombiblio, "specialUpdate", "biblioserver" );
	    # Checking if the item we want to move is in an order 
        require C4::Acquisition;
        my $order = C4::Acquisition::GetOrderFromItemnumber($itemnumber);
	    if ($order) {
		    # Replacing the biblionumber within the order if necessary
		    $order->{'biblionumber'} = $tobiblio;
	        C4::Acquisition::ModOrder($order);
	    }

        # Update reserves, hold_fill_targets, tmp_holdsqueue and linktracker tables
        for my $table_name ( qw( reserves hold_fill_targets tmp_holdsqueue linktracker ) ) {
            $dbh->do( qq|
                UPDATE $table_name
                SET biblionumber = ?
                WHERE itemnumber = ?
            |, undef, $tobiblio, $itemnumber );
        }
        return $tobiblio;
	}
    return;
}

=head2 ItemSafeToDelete

   ItemSafeToDelete( $biblionumber, $itemnumber);

Exported function (core API) for checking whether an item record is safe to delete.

returns 1 if the item is safe to delete,

"book_on_loan" if the item is checked out,

"not_same_branch" if the item is blocked by independent branches,

"book_reserved" if the there are holds aganst the item, or

"linked_analytics" if the item has linked analytic records.

=cut

sub ItemSafeToDelete {
    my ( $biblionumber, $itemnumber ) = @_;
    my $status;
    my $dbh = C4::Context->dbh;

    my $error;

    my $countanalytics = GetAnalyticsCount($itemnumber);

    # check that there is no issue on this item before deletion.
    my $sth = $dbh->prepare(
        q{
        SELECT COUNT(*) FROM issues
        WHERE itemnumber = ?
    }
    );
    $sth->execute($itemnumber);
    my ($onloan) = $sth->fetchrow;

    my $item = GetItem($itemnumber);

    if ($onloan) {
        $status = "book_on_loan";
    }
    elsif ( defined C4::Context->userenv
        and !C4::Context->IsSuperLibrarian()
        and C4::Context->preference("IndependentBranches")
        and ( C4::Context->userenv->{branch} ne $item->{'homebranch'} ) )
    {
        $status = "not_same_branch";
    }
    else {
        # check it doesn't have a waiting reserve
        $sth = $dbh->prepare(
            q{
            SELECT COUNT(*) FROM reserves
            WHERE (found = 'W' OR found = 'T')
            AND itemnumber = ?
        }
        );
        $sth->execute($itemnumber);
        my ($reserve) = $sth->fetchrow;
        if ($reserve) {
            $status = "book_reserved";
        }
        elsif ( $countanalytics > 0 ) {
            $status = "linked_analytics";
        }
        else {
            $status = 1;
        }
    }
    return $status;
}

=head2 DelItemCheck

   DelItemCheck( $biblionumber, $itemnumber);

Exported function (core API) for deleting an item record in Koha if there no current issue.

DelItemCheck wraps ItemSafeToDelete around DelItem.

=cut

sub DelItemCheck {
    my ( $biblionumber, $itemnumber ) = @_;
    my $status = ItemSafeToDelete( $biblionumber, $itemnumber );

    if ( $status == 1 ) {
        DelItem(
            {
                biblionumber => $biblionumber,
                itemnumber   => $itemnumber
            }
        );
    }
    return $status;
}

=head2 _koha_modify_item

  my ($itemnumber,$error) =_koha_modify_item( $item );

Perform the actual update of the C<items> row.  Note that this
routine accepts a hashref specifying the columns to update.

=cut

sub _koha_modify_item {
    my ( $item ) = @_;
    my $dbh=C4::Context->dbh;  
    my $error;

    my $query = "UPDATE items SET ";
    my @bind;
    _mod_item_dates( $item );
    for my $key ( keys %$item ) {
        next if ( $key eq 'itemnumber' );
        $query.="$key=?,";
        push @bind, $item->{$key};
    }
    $query =~ s/,$//;
    $query .= " WHERE itemnumber=?";
    push @bind, $item->{'itemnumber'};
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    if ( $sth->err ) {
        $error.="ERROR in _koha_modify_item $query: ".$sth->errstr;
        warn $error;
    }
    return ($item->{'itemnumber'},$error);
}

sub _mod_item_dates { # date formatting for date fields in item hash
    my ( $item ) = @_;
    return if !$item || ref($item) ne 'HASH';

    my @keys = grep
        { $_ =~ /^onloan$|^date|date$|datetime$/ }
        keys %$item;
    # Incl. dateaccessioned,replacementpricedate,datelastborrowed,datelastseen
    # NOTE: We do not (yet) have items fields ending with datetime
    # Fields with _on$ have been handled already

    foreach my $key ( @keys ) {
        next if !defined $item->{$key}; # skip undefs
        my $dt = eval { dt_from_string( $item->{$key} ) };
            # eval: dt_from_string will die on us if we pass illegal dates

        my $newstr;
        if( defined $dt  && ref($dt) eq 'DateTime' ) {
            if( $key =~ /datetime/ ) {
                $newstr = DateTime::Format::MySQL->format_datetime($dt);
            } else {
                $newstr = DateTime::Format::MySQL->format_date($dt);
            }
        }
        $item->{$key} = $newstr; # might be undef to clear garbage
    }
}

=head2 _koha_delete_item

  _koha_delete_item( $itemnum );

Internal function to delete an item record from the koha tables

=cut

sub _koha_delete_item {
    my ( $itemnum ) = @_;

    my $dbh = C4::Context->dbh;
    # save the deleted item to deleteditems table
    my $sth = $dbh->prepare("SELECT * FROM items WHERE itemnumber=?");
    $sth->execute($itemnum);
    my $data = $sth->fetchrow_hashref();

    # There is no item to delete
    return 0 unless $data;

    my $query = "INSERT INTO deleteditems SET ";
    my @bind  = ();
    foreach my $key ( keys %$data ) {
        next if ( $key eq 'timestamp' ); # timestamp will be set by db
        $query .= "$key = ?,";
        push( @bind, $data->{$key} );
    }
    $query =~ s/\,$//;
    $sth = $dbh->prepare($query);
    $sth->execute(@bind);

    # delete from items table
    $sth = $dbh->prepare("DELETE FROM items WHERE itemnumber=?");
    my $deleted = $sth->execute($itemnum);
    return ( $deleted == 1 ) ? 1 : 0;
}

=head2 _marc_from_item_hash

  my $item_marc = _marc_from_item_hash($item, $frameworkcode[, $unlinked_item_subfields]);

Given an item hash representing a complete item record,
create a C<MARC::Record> object containing an embedded
tag representing that item.

The third, optional parameter C<$unlinked_item_subfields> is
an arrayref of subfields (not mapped to C<items> fields per the
framework) to be added to the MARC representation
of the item.

=cut

sub _marc_from_item_hash {
    my $item = shift;
    my $frameworkcode = shift;
    my $unlinked_item_subfields;
    if (@_) {
        $unlinked_item_subfields = shift;
    }
   
    # Tack on 'items.' prefix to column names so lookup from MARC frameworks will work
    # Also, don't emit a subfield if the underlying field is blank.
    my $mungeditem = { map {  (defined($item->{$_}) and $item->{$_} ne '') ? 
                                (/^items\./ ? ($_ => $item->{$_}) : ("items.$_" => $item->{$_})) 
                                : ()  } keys %{ $item } }; 

    my $item_marc = MARC::Record->new();
    foreach my $item_field ( keys %{$mungeditem} ) {
        my ( $tag, $subfield ) = C4::Biblio::GetMarcFromKohaField( $item_field, $frameworkcode );
        next unless defined $tag and defined $subfield;    # skip if not mapped to MARC field
        my @values = split(/\s?\|\s?/, $mungeditem->{$item_field}, -1);
        foreach my $value (@values){
            if ( my $field = $item_marc->field($tag) ) {
                    $field->add_subfields( $subfield => $value );
            } else {
                my $add_subfields = [];
                if (defined $unlinked_item_subfields and ref($unlinked_item_subfields) eq 'ARRAY' and $#$unlinked_item_subfields > -1) {
                    $add_subfields = $unlinked_item_subfields;
            }
            $item_marc->add_fields( $tag, " ", " ", $subfield => $value, @$add_subfields );
            }
        }
    }

    return $item_marc;
}

=head2 _repack_item_errors

Add an error message hash generated by C<CheckItemPreSave>
to a list of errors.

=cut

sub _repack_item_errors {
    my $item_sequence_num = shift;
    my $item_ref = shift;
    my $error_ref = shift;

    my @repacked_errors = ();

    foreach my $error_code (sort keys %{ $error_ref }) {
        my $repacked_error = {};
        $repacked_error->{'item_sequence'} = $item_sequence_num;
        $repacked_error->{'item_barcode'} = exists($item_ref->{'barcode'}) ? $item_ref->{'barcode'} : '';
        $repacked_error->{'error_code'} = $error_code;
        $repacked_error->{'error_information'} = $error_ref->{$error_code};
        push @repacked_errors, $repacked_error;
    } 

    return @repacked_errors;
}

=head2 _get_unlinked_item_subfields

  my $unlinked_item_subfields = _get_unlinked_item_subfields($original_item_marc, $frameworkcode);

=cut

sub _get_unlinked_item_subfields {
    my $original_item_marc = shift;
    my $frameworkcode = shift;

    my $marcstructure = GetMarcStructure(1, $frameworkcode, { unsafe => 1 });

    # assume that this record has only one field, and that that
    # field contains only the item information
    my $subfields = [];
    my @fields = $original_item_marc->fields();
    if ($#fields > -1) {
        my $field = $fields[0];
	    my $tag = $field->tag();
        foreach my $subfield ($field->subfields()) {
            if (defined $subfield->[1] and
                $subfield->[1] ne '' and
                !$marcstructure->{$tag}->{$subfield->[0]}->{'kohafield'}) {
                push @$subfields, $subfield->[0] => $subfield->[1];
            }
        }
    }
    return $subfields;
}

=head2 _get_unlinked_subfields_xml

  my $unlinked_subfields_xml = _get_unlinked_subfields_xml($unlinked_item_subfields);

=cut

sub _get_unlinked_subfields_xml {
    my $unlinked_item_subfields = shift;

    my $xml;
    if (defined $unlinked_item_subfields and ref($unlinked_item_subfields) eq 'ARRAY' and $#$unlinked_item_subfields > -1) {
        my $marc = MARC::Record->new();
        # use of tag 999 is arbitrary, and doesn't need to match the item tag
        # used in the framework
        $marc->append_fields(MARC::Field->new('999', ' ', ' ', @$unlinked_item_subfields));
        $marc->encoding("UTF-8");    
        $xml = $marc->as_xml("USMARC");
    }

    return $xml;
}

=head2 _parse_unlinked_item_subfields_from_xml

  my $unlinked_item_subfields = _parse_unlinked_item_subfields_from_xml($whole_item->{'more_subfields_xml'}):

=cut

sub  _parse_unlinked_item_subfields_from_xml {
    my $xml = shift;
    require C4::Charset;
    return unless defined $xml and $xml ne "";
    my $marc = MARC::Record->new_from_xml(C4::Charset::StripNonXmlChars($xml),'UTF-8');
    my $unlinked_subfields = [];
    my @fields = $marc->fields();
    if ($#fields > -1) {
        foreach my $subfield ($fields[0]->subfields()) {
            push @$unlinked_subfields, $subfield->[0] => $subfield->[1];
        }
    }
    return $unlinked_subfields;
}

=head2 GetAnalyticsCount

  $count= &GetAnalyticsCount($itemnumber)

counts Usage of itemnumber in Analytical bibliorecords. 

=cut

sub GetAnalyticsCount {
    my ($itemnumber) = @_;

    ### ZOOM search here
    my $query;
    $query= "hi=".$itemnumber;
    my $searcher = Koha::SearchEngine::Search->new({index => $Koha::SearchEngine::BIBLIOS_INDEX});
    my ($err,$res,$result) = $searcher->simple_search_compat($query,0,10);
    return ($result);
}

=head2 SearchItemsByField

    my $items = SearchItemsByField($field, $value);

SearchItemsByField will search for items on a specific given field.
For instance you can search all items with a specific stocknumber like this:

    my $items = SearchItemsByField('stocknumber', $stocknumber);

=cut

sub SearchItemsByField {
    my ($field, $value) = @_;

    my $filters = {
        field => $field,
        query => $value,
    };

    my ($results) = SearchItems($filters);
    return $results;
}

sub _SearchItems_build_where_fragment {
    my ($filter) = @_;

    my $dbh = C4::Context->dbh;

    my $where_fragment;
    if (exists($filter->{conjunction})) {
        my (@where_strs, @where_args);
        foreach my $f (@{ $filter->{filters} }) {
            my $fragment = _SearchItems_build_where_fragment($f);
            if ($fragment) {
                push @where_strs, $fragment->{str};
                push @where_args, @{ $fragment->{args} };
            }
        }
        my $where_str = '';
        if (@where_strs) {
            $where_str = '(' . join (' ' . $filter->{conjunction} . ' ', @where_strs) . ')';
            $where_fragment = {
                str => $where_str,
                args => \@where_args,
            };
        }
    } else {
        my @columns = Koha::Database->new()->schema()->resultset('Item')->result_source->columns;
        push @columns, Koha::Database->new()->schema()->resultset('Biblio')->result_source->columns;
        push @columns, Koha::Database->new()->schema()->resultset('Biblioitem')->result_source->columns;
        my @operators = qw(= != > < >= <= like);
        my $field = $filter->{field};
        if ( (0 < grep /^$field$/, @columns) or (substr($field, 0, 5) eq 'marc:') ) {
            my $op = $filter->{operator};
            my $query = $filter->{query};

            if (!$op or (0 == grep /^$op$/, @operators)) {
                $op = '='; # default operator
            }

            my $column;
            if ($field =~ /^marc:(\d{3})(?:\$(\w))?$/) {
                my $marcfield = $1;
                my $marcsubfield = $2;
                my ($kohafield) = $dbh->selectrow_array(q|
                    SELECT kohafield FROM marc_subfield_structure
                    WHERE tagfield=? AND tagsubfield=? AND frameworkcode=''
                |, undef, $marcfield, $marcsubfield);

                if ($kohafield) {
                    $column = $kohafield;
                } else {
                    # MARC field is not linked to a DB field so we need to use
                    # ExtractValue on marcxml from biblio_metadata or
                    # items.more_subfields_xml, depending on the MARC field.
                    my $xpath;
                    my $sqlfield;
                    my ($itemfield) = C4::Biblio::GetMarcFromKohaField('items.itemnumber');
                    if ($marcfield eq $itemfield) {
                        $sqlfield = 'more_subfields_xml';
                        $xpath = '//record/datafield/subfield[@code="' . $marcsubfield . '"]';
                    } else {
                        $sqlfield = 'metadata'; # From biblio_metadata
                        if ($marcfield < 10) {
                            $xpath = "//record/controlfield[\@tag=\"$marcfield\"]";
                        } else {
                            $xpath = "//record/datafield[\@tag=\"$marcfield\"]/subfield[\@code=\"$marcsubfield\"]";
                        }
                    }
                    $column = "ExtractValue($sqlfield, '$xpath')";
                }
            } else {
                $column = $field;
            }

            if (ref $query eq 'ARRAY') {
                if ($op eq '=') {
                    $op = 'IN';
                } elsif ($op eq '!=') {
                    $op = 'NOT IN';
                }
                $where_fragment = {
                    str => "$column $op (" . join (',', ('?') x @$query) . ")",
                    args => $query,
                };
            } else {
                $where_fragment = {
                    str => "$column $op ?",
                    args => [ $query ],
                };
            }
        }
    }

    return $where_fragment;
}

=head2 SearchItems

    my ($items, $total) = SearchItems($filter, $params);

Perform a search among items

$filter is a reference to a hash which can be a filter, or a combination of filters.

A filter has the following keys:

=over 2

=item * field: the name of a SQL column in table items

=item * query: the value to search in this column

=item * operator: comparison operator. Can be one of = != > < >= <= like

=back

A combination of filters hash the following keys:

=over 2

=item * conjunction: 'AND' or 'OR'

=item * filters: array ref of filters

=back

$params is a reference to a hash that can contain the following parameters:

=over 2

=item * rows: Number of items to return. 0 returns everything (default: 0)

=item * page: Page to return (return items from (page-1)*rows to (page*rows)-1)
               (default: 1)

=item * sortby: A SQL column name in items table to sort on

=item * sortorder: 'ASC' or 'DESC'

=back

=cut

sub SearchItems {
    my ($filter, $params) = @_;

    $filter //= {};
    $params //= {};
    return unless ref $filter eq 'HASH';
    return unless ref $params eq 'HASH';

    # Default parameters
    $params->{rows} ||= 0;
    $params->{page} ||= 1;
    $params->{sortby} ||= 'itemnumber';
    $params->{sortorder} ||= 'ASC';

    my ($where_str, @where_args);
    my $where_fragment = _SearchItems_build_where_fragment($filter);
    if ($where_fragment) {
        $where_str = $where_fragment->{str};
        @where_args = @{ $where_fragment->{args} };
    }

    my $dbh = C4::Context->dbh;
    my $query = q{
        SELECT SQL_CALC_FOUND_ROWS items.*
        FROM items
          LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
          LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber
          LEFT JOIN biblio_metadata ON biblio_metadata.biblionumber = biblio.biblionumber
          WHERE 1
    };
    if (defined $where_str and $where_str ne '') {
        $query .= qq{ AND $where_str };
    }

    $query .= q{ AND biblio_metadata.format = 'marcxml' AND biblio_metadata.marcflavour = ? };
    push @where_args, C4::Context->preference('marcflavour');

    my @columns = Koha::Database->new()->schema()->resultset('Item')->result_source->columns;
    push @columns, Koha::Database->new()->schema()->resultset('Biblio')->result_source->columns;
    push @columns, Koha::Database->new()->schema()->resultset('Biblioitem')->result_source->columns;
    my $sortby = (0 < grep {$params->{sortby} eq $_} @columns)
        ? $params->{sortby} : 'itemnumber';
    my $sortorder = (uc($params->{sortorder}) eq 'ASC') ? 'ASC' : 'DESC';
    $query .= qq{ ORDER BY $sortby $sortorder };

    my $rows = $params->{rows};
    my @limit_args;
    if ($rows > 0) {
        my $offset = $rows * ($params->{page}-1);
        $query .= qq { LIMIT ?, ? };
        push @limit_args, $offset, $rows;
    }

    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute(@where_args, @limit_args);

    return unless ($rv);
    my ($total_rows) = $dbh->selectrow_array(q{ SELECT FOUND_ROWS() });

    return ($sth->fetchall_arrayref({}), $total_rows);
}


=head1  OTHER FUNCTIONS

=head2 _find_value

  ($indicators, $value) = _find_value($tag, $subfield, $record,$encoding);

Find the given $subfield in the given $tag in the given
MARC::Record $record.  If the subfield is found, returns
the (indicators, value) pair; otherwise, (undef, undef) is
returned.

PROPOSITION :
Such a function is used in addbiblio AND additem and serial-edit and maybe could be used in Authorities.
I suggest we export it from this module.

=cut

sub _find_value {
    my ( $tagfield, $insubfield, $record, $encoding ) = @_;
    my @result;
    my $indicator;
    if ( $tagfield < 10 ) {
        if ( $record->field($tagfield) ) {
            push @result, $record->field($tagfield)->data();
        } else {
            push @result, "";
        }
    } else {
        foreach my $field ( $record->field($tagfield) ) {
            my @subfields = $field->subfields();
            foreach my $subfield (@subfields) {
                if ( @$subfield[0] eq $insubfield ) {
                    push @result, @$subfield[1];
                    $indicator = $field->indicator(1) . $field->indicator(2);
                }
            }
        }
    }
    return ( $indicator, @result );
}


=head2 PrepareItemrecordDisplay

  PrepareItemrecordDisplay($itemrecord,$bibnum,$itemumber,$frameworkcode);

Returns a hash with all the fields for Display a given item data in a template

The $frameworkcode returns the item for the given frameworkcode, ONLY if bibnum is not provided

=cut

sub PrepareItemrecordDisplay {

    my ( $bibnum, $itemnum, $defaultvalues, $frameworkcode ) = @_;

    my $dbh = C4::Context->dbh;
    $frameworkcode = C4::Biblio::GetFrameworkCode($bibnum) if $bibnum;
    my ( $itemtagfield, $itemtagsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber", $frameworkcode );

    # Note: $tagslib obtained from GetMarcStructure() in 'unsafe' mode is
    # a shared data structure. No plugin (including custom ones) should change
    # its contents. See also GetMarcStructure.
    my $tagslib = GetMarcStructure( 1, $frameworkcode, { unsafe => 1 } );

    # return nothing if we don't have found an existing framework.
    return q{} unless $tagslib;
    my $itemrecord;
    if ($itemnum) {
        $itemrecord = C4::Items::GetMarcItem( $bibnum, $itemnum );
    }
    my @loop_data;

    my $branch_limit = C4::Context->userenv ? C4::Context->userenv->{"branch"} : "";
    my $query = qq{
        SELECT authorised_value,lib FROM authorised_values
    };
    $query .= qq{
        LEFT JOIN authorised_values_branches ON ( id = av_id )
    } if $branch_limit;
    $query .= qq{
        WHERE category = ?
    };
    $query .= qq{ AND ( branchcode = ? OR branchcode IS NULL )} if $branch_limit;
    $query .= qq{ ORDER BY lib};
    my $authorised_values_sth = $dbh->prepare( $query );
    foreach my $tag ( sort keys %{$tagslib} ) {
        if ( $tag ne '' ) {

            # loop through each subfield
            my $cntsubf;
            foreach my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
                next if IsMarcStructureInternal($tagslib->{$tag}{$subfield});
                next unless ( $tagslib->{$tag}->{$subfield}->{'tab'} );
                next if ( $tagslib->{$tag}->{$subfield}->{'tab'} ne "10" );
                my %subfield_data;
                $subfield_data{tag}           = $tag;
                $subfield_data{subfield}      = $subfield;
                $subfield_data{countsubfield} = $cntsubf++;
                $subfield_data{kohafield}     = $tagslib->{$tag}->{$subfield}->{'kohafield'};
                $subfield_data{id}            = "tag_".$tag."_subfield_".$subfield."_".int(rand(1000000));

                #        $subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
                $subfield_data{marc_lib}   = $tagslib->{$tag}->{$subfield}->{lib};
                $subfield_data{mandatory}  = $tagslib->{$tag}->{$subfield}->{mandatory};
                $subfield_data{repeatable} = $tagslib->{$tag}->{$subfield}->{repeatable};
                $subfield_data{hidden}     = "display:none"
                  if ( ( $tagslib->{$tag}->{$subfield}->{hidden} > 4 )
                    || ( $tagslib->{$tag}->{$subfield}->{hidden} < -4 ) );
                my ( $x, $defaultvalue );
                if ($itemrecord) {
                    ( $x, $defaultvalue ) = _find_value( $tag, $subfield, $itemrecord );
                }
                $defaultvalue = $tagslib->{$tag}->{$subfield}->{defaultvalue} unless $defaultvalue;
                if ( !defined $defaultvalue ) {
                    $defaultvalue = q||;
                } else {
                    $defaultvalue =~ s/"/&quot;/g;
                }

                # search for itemcallnumber if applicable
                if ( $tagslib->{$tag}->{$subfield}->{kohafield} eq 'items.itemcallnumber'
                    && C4::Context->preference('itemcallnumber') ) {
                    my $CNtag      = substr( C4::Context->preference('itemcallnumber'), 0, 3 );
                    my $CNsubfield = substr( C4::Context->preference('itemcallnumber'), 3, 1 );
                    if ( $itemrecord and my $field = $itemrecord->field($CNtag) ) {
                        $defaultvalue = $field->subfield($CNsubfield);
                    }
                }
                if (   $tagslib->{$tag}->{$subfield}->{kohafield} eq 'items.itemcallnumber'
                    && $defaultvalues
                    && $defaultvalues->{'callnumber'} ) {
                    if( $itemrecord and $defaultvalues and not $itemrecord->subfield($tag,$subfield) ){
                        # if the item record exists, only use default value if the item has no callnumber
                        $defaultvalue = $defaultvalues->{callnumber};
                    } elsif ( !$itemrecord and $defaultvalues ) {
                        # if the item record *doesn't* exists, always use the default value
                        $defaultvalue = $defaultvalues->{callnumber};
                    }
                }
                if (   ( $tagslib->{$tag}->{$subfield}->{kohafield} eq 'items.holdingbranch' || $tagslib->{$tag}->{$subfield}->{kohafield} eq 'items.homebranch' )
                    && $defaultvalues
                    && $defaultvalues->{'branchcode'} ) {
                    if ( $itemrecord and $defaultvalues and not $itemrecord->subfield($tag,$subfield) ) {
                        $defaultvalue = $defaultvalues->{branchcode};
                    }
                }
                if (   ( $tagslib->{$tag}->{$subfield}->{kohafield} eq 'items.location' )
                    && $defaultvalues
                    && $defaultvalues->{'location'} ) {

                    if ( $itemrecord and $defaultvalues and not $itemrecord->subfield($tag,$subfield) ) {
                        # if the item record exists, only use default value if the item has no locationr
                        $defaultvalue = $defaultvalues->{location};
                    } elsif ( !$itemrecord and $defaultvalues ) {
                        # if the item record *doesn't* exists, always use the default value
                        $defaultvalue = $defaultvalues->{location};
                    }
                }
                if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
                    my @authorised_values;
                    my %authorised_lib;

                    # builds list, depending on authorised value...
                    #---- branch
                    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
                        if (   ( C4::Context->preference("IndependentBranches") )
                            && !C4::Context->IsSuperLibrarian() ) {
                            my $sth = $dbh->prepare( "SELECT branchcode,branchname FROM branches WHERE branchcode = ? ORDER BY branchname" );
                            $sth->execute( C4::Context->userenv->{branch} );
                            push @authorised_values, ""
                              unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
                            while ( my ( $branchcode, $branchname ) = $sth->fetchrow_array ) {
                                push @authorised_values, $branchcode;
                                $authorised_lib{$branchcode} = $branchname;
                            }
                        } else {
                            my $sth = $dbh->prepare( "SELECT branchcode,branchname FROM branches ORDER BY branchname" );
                            $sth->execute;
                            push @authorised_values, ""
                              unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
                            while ( my ( $branchcode, $branchname ) = $sth->fetchrow_array ) {
                                push @authorised_values, $branchcode;
                                $authorised_lib{$branchcode} = $branchname;
                            }
                        }

                        $defaultvalue = C4::Context->userenv ? C4::Context->userenv->{branch} : undef;
                        if ( $defaultvalues and $defaultvalues->{branchcode} ) {
                            $defaultvalue = $defaultvalues->{branchcode};
                        }

                        #----- itemtypes
                    } elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes" ) {
                        my $itemtypes = Koha::ItemTypes->search_with_localization;
                        push @authorised_values, ""
                          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
                        while ( my $itemtype = $itemtypes->next ) {
                            push @authorised_values, $itemtype->itemtype;
                            $authorised_lib{$itemtype->itemtype} = $itemtype->translated_description;
                        }
                        if ($defaultvalues && $defaultvalues->{'itemtype'}) {
                            $defaultvalue = $defaultvalues->{'itemtype'};
                        }

                        #---- class_sources
                    } elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "cn_source" ) {
                        push @authorised_values, "" unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );

                        my $class_sources = GetClassSources();
                        my $default_source = C4::Context->preference("DefaultClassificationSource");

                        foreach my $class_source (sort keys %$class_sources) {
                            next unless $class_sources->{$class_source}->{'used'} or
                                        ($class_source eq $default_source);
                            push @authorised_values, $class_source;
                            $authorised_lib{$class_source} = $class_sources->{$class_source}->{'description'};
                        }

                        $defaultvalue = $default_source;

                        #---- "true" authorised value
                    } else {
                        $authorised_values_sth->execute(
                            $tagslib->{$tag}->{$subfield}->{authorised_value},
                            $branch_limit ? $branch_limit : ()
                        );
                        push @authorised_values, ""
                          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
                        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
                            push @authorised_values, $value;
                            $authorised_lib{$value} = $lib;
                        }
                    }
                    $subfield_data{marc_value} = {
                        type    => 'select',
                        values  => \@authorised_values,
                        default => "$defaultvalue",
                        labels  => \%authorised_lib,
                    };
                } elsif ( $tagslib->{$tag}->{$subfield}->{value_builder} ) {
                # it is a plugin
                    require Koha::FrameworkPlugin;
                    my $plugin = Koha::FrameworkPlugin->new({
                        name => $tagslib->{$tag}->{$subfield}->{value_builder},
                        item_style => 1,
                    });
                    my $pars = { dbh => $dbh, record => undef, tagslib =>$tagslib, id => $subfield_data{id}, tabloop => undef };
                    $plugin->build( $pars );
                    if ( $itemrecord and my $field = $itemrecord->field($tag) ) {
                        $defaultvalue = $field->subfield($subfield);
                    }
                    if( !$plugin->errstr ) {
                        #TODO Move html to template; see report 12176/13397
                        my $tab= $plugin->noclick? '-1': '';
                        my $class= $plugin->noclick? ' disabled': '';
                        my $title= $plugin->noclick? 'No popup': 'Tag editor';
                        $subfield_data{marc_value} = qq[<input type="text" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="255" value="$defaultvalue" /><a href="#" id="buttonDot_$subfield_data{id}" tabindex="$tab" class="buttonDot $class" title="$title">...</a>\n].$plugin->javascript;
                    } else {
                        warn $plugin->errstr;
                        $subfield_data{marc_value} = qq(<input type="text" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="255" value="$defaultvalue" />); # supply default input form
                    }
                }
                elsif ( $tag eq '' ) {       # it's an hidden field
                    $subfield_data{marc_value} = qq(<input type="hidden" tabindex="1" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="255" value="$defaultvalue" />);
                }
                elsif ( $tagslib->{$tag}->{$subfield}->{'hidden'} ) {   # FIXME: shouldn't input type be "hidden" ?
                    $subfield_data{marc_value} = qq(<input type="text" tabindex="1" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="255" value="$defaultvalue" />);
                }
                elsif ( length($defaultvalue) > 100
                            or (C4::Context->preference("marcflavour") eq "UNIMARC" and
                                  300 <= $tag && $tag < 400 && $subfield eq 'a' )
                            or (C4::Context->preference("marcflavour") eq "MARC21"  and
                                  500 <= $tag && $tag < 600                     )
                          ) {
                    # oversize field (textarea)
                    $subfield_data{marc_value} = qq(<textarea tabindex="1" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="255">$defaultvalue</textarea>\n");
                } else {
                    $subfield_data{marc_value} = "<input type=\"text\" name=\"field_value\" value=\"$defaultvalue\" size=\"50\" maxlength=\"255\" />";
                }
                push( @loop_data, \%subfield_data );
            }
        }
    }
    my $itemnumber;
    if ( $itemrecord && $itemrecord->field($itemtagfield) ) {
        $itemnumber = $itemrecord->subfield( $itemtagfield, $itemtagsubfield );
    }
    return {
        'itemtagfield'    => $itemtagfield,
        'itemtagsubfield' => $itemtagsubfield,
        'itemnumber'      => $itemnumber,
        'iteminformation' => \@loop_data
    };
}

sub ToggleNewStatus {
    my ( $params ) = @_;
    my @rules = @{ $params->{rules} };
    my $report_only = $params->{report_only};

    my $dbh = C4::Context->dbh;
    my @errors;
    my @item_columns = map { "items.$_" } Koha::Items->columns;
    my @biblioitem_columns = map { "biblioitems.$_" } Koha::Biblioitems->columns;
    my $report;
    for my $rule ( @rules ) {
        my $age = $rule->{age};
        my $conditions = $rule->{conditions};
        my $substitutions = $rule->{substitutions};
        my @params;

        my $query = q|
            SELECT items.biblionumber, items.itemnumber
            FROM items
            LEFT JOIN biblioitems ON biblioitems.biblionumber = items.biblionumber
            WHERE 1
        |;
        for my $condition ( @$conditions ) {
            if (
                 grep {/^$condition->{field}$/} @item_columns
              or grep {/^$condition->{field}$/} @biblioitem_columns
            ) {
                if ( $condition->{value} =~ /\|/ ) {
                    my @values = split /\|/, $condition->{value};
                    $query .= qq| AND $condition->{field} IN (|
                        . join( ',', ('?') x scalar @values )
                        . q|)|;
                    push @params, @values;
                } else {
                    $query .= qq| AND $condition->{field} = ?|;
                    push @params, $condition->{value};
                }
            }
        }
        if ( defined $age ) {
            $query .= q| AND TO_DAYS(NOW()) - TO_DAYS(dateaccessioned) >= ? |;
            push @params, $age;
        }
        my $sth = $dbh->prepare($query);
        $sth->execute( @params );
        while ( my $values = $sth->fetchrow_hashref ) {
            my $biblionumber = $values->{biblionumber};
            my $itemnumber = $values->{itemnumber};
            my $item = C4::Items::GetItem( $itemnumber );
            for my $substitution ( @$substitutions ) {
                next unless $substitution->{field};
                C4::Items::ModItem( {$substitution->{field} => $substitution->{value}}, $biblionumber, $itemnumber )
                    unless $report_only;
                push @{ $report->{$itemnumber} }, $substitution;
            }
        }
    }

    return $report;
}


1;
