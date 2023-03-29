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

use Modern::Perl;

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);

    @EXPORT_OK = qw(
        AddItemFromMarc
        AddItemBatchFromMarc
        ModItemFromMarc
        Item2Marc
        ModDateLastSeen
        ModItemTransfer
        CheckItemPreSave
        GetItemsForInventory
        get_hostitemnumbers_of
        GetMarcItem
        CartToShelf
        GetAnalyticsCount
        SearchItems
        PrepareItemrecordDisplay
        ToggleNewStatus
    );
}

use Carp qw( croak );
use C4::Context;
use C4::Koha;
use C4::Biblio qw( GetMarcStructure TransformMarcToKoha );
use MARC::Record;
use C4::ClassSource qw( GetClassSort GetClassSources GetClassSource );
use C4::Log qw( logaction );
use List::MoreUtils qw( any );
use DateTime::Format::MySQL;
                  # debugging; so please don't remove this

use Koha::AuthorisedValues;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Database;

use Koha::Biblios;
use Koha::Biblioitems;
use Koha::Items;
use Koha::ItemTypes;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;
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

    my $item = Koha::Items->find($itemnumber);
    if ( $item->location eq 'CART' ) {
        $item->location($item->permanent_location)->store;
    }
}

=head2 AddItemFromMarc

  my ($biblionumber, $biblioitemnumber, $itemnumber) 
      = AddItemFromMarc($source_item_marc, $biblionumber[, $params]);

Given a MARC::Record object containing an embedded item
record and a biblionumber, create a new item record.

The final optional parameter, C<$params>, may contain
'skip_record_index' key, which relayed down to Koha::Item/store,
there it prevents calling of index_records,
which takes most of the time in batch adds/deletes: index_records
to be called later in C<additem.pl> after the whole loop.

You may also optionally pass biblioitemnumber in the params hash to
boost performance of inserts by preventing a lookup in Koha::Item.

$params:
    skip_record_index => 1|0
    biblioitemnumber => $biblioitemnumber

=cut

sub AddItemFromMarc {
    my $source_item_marc = shift;
    my $biblionumber     = shift;
    my $params           = @_ ? shift : {};

    my $dbh = C4::Context->dbh;

    # parse item hash from MARC
    my $frameworkcode = C4::Biblio::GetFrameworkCode($biblionumber);
    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );
    my $localitemmarc = MARC::Record->new;
    $localitemmarc->append_fields( $source_item_marc->field($itemtag) );

    my $item_values = C4::Biblio::TransformMarcToKoha({ record => $localitemmarc, limit_table => 'items' });
    my $unlinked_item_subfields = _get_unlinked_item_subfields( $localitemmarc, $frameworkcode );
    $item_values->{more_subfields_xml} = _get_unlinked_subfields_xml($unlinked_item_subfields);
    $item_values->{biblionumber} = $biblionumber;
    $item_values->{biblioitemnumber} = $params->{biblioitemnumber};
    $item_values->{cn_source} = delete $item_values->{'items.cn_source'}; # Because of C4::Biblio::_disambiguate
    $item_values->{cn_sort}   = delete $item_values->{'items.cn_sort'};   # Because of C4::Biblio::_disambiguate
    my $item = Koha::Item->new( $item_values )->store({ skip_record_index => $params->{skip_record_index} });
    return ( $item->biblionumber, $item->biblioitemnumber, $item->itemnumber );
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
    my @itemnumbers = ();
    my @errors = ();
    my $dbh = C4::Context->dbh;

    # We modify the record, so lets work on a clone so we don't change the
    # original.
    $record = $record->clone();
    # loop through the item tags and start creating items
    my @bad_item_fields = ();
    my ($itemtag, $itemsubfield) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );
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
        my $item = TransformMarcToKoha({ record => $temp_item_marc, limit_table => 'items' });
        my $unlinked_item_subfields = _get_unlinked_item_subfields($temp_item_marc, $frameworkcode);
        $item->{'more_subfields_xml'} = _get_unlinked_subfields_xml($unlinked_item_subfields);
        $item->{'biblionumber'} = $biblionumber;
        $item->{'biblioitemnumber'} = $biblioitemnumber;
        $item->{cn_source} = delete $item->{'items.cn_source'}; # Because of C4::Biblio::_disambiguate
        $item->{cn_sort}   = delete $item->{'items.cn_sort'};   # Because of C4::Biblio::_disambiguate

        # check for duplicate barcode
        my %item_errors = CheckItemPreSave($item);
        if (%item_errors) {
            push @errors, _repack_item_errors($item_sequence_num, $item, \%item_errors);
            push @bad_item_fields, $item_field;
            next ITEMFIELD;
        }

        my $item_object = Koha::Item->new($item)->store;
        push @itemnumbers, $item_object->itemnumber; # FIXME not checking error

        logaction("CATALOGUING", "ADD", $item_object->itemnumber, "item") if C4::Context->preference("CataloguingLog");

        my $new_item_marc = _marc_from_item_hash($item_object->unblessed, $frameworkcode, $unlinked_item_subfields);
        $item_field->replace_with($new_item_marc->field($itemtag));
    }

    # remove any MARC item fields for rejected items
    foreach my $item_field (@bad_item_fields) {
        $record->delete_field($item_field);
    }

    return (\@itemnumbers, \@errors);
}

=head2 ModItemFromMarc

my $item = ModItemFromMarc($item_marc, $biblionumber, $itemnumber[, $params]);

The final optional parameter, C<$params>, expected to contain
'skip_record_index' key, which relayed down to Koha::Item/store,
there it prevents calling of index_records,
which takes most of the time in batch adds/deletes: index_records better
to be called later in C<additem.pl> after the whole loop.

$params:
    skip_record_index => 1|0

=cut

sub ModItemFromMarc {
    my ( $item_marc, $biblionumber, $itemnumber, $params ) = @_;

    my $frameworkcode = C4::Biblio::GetFrameworkCode($biblionumber);
    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

    my $localitemmarc = MARC::Record->new;
    $localitemmarc->append_fields( $item_marc->field($itemtag) );
    my $item_object = Koha::Items->find($itemnumber);
    my $item = TransformMarcToKoha({ record => $localitemmarc, limit_table => 'items' });

    # When importing items we blank this column, we need to set it to the existing value
    # to prevent it being blanked by set_or_blank
    $item->{onloan} = $item_object->onloan if( $item_object->onloan && !defined $item->{onloan} );

    # When importing and replacing items we should not remove the dateacquired so we should set it
    # to the existing value
    $item->{dateaccessioned} = $item_object->dateaccessioned
      if ( $item_object->dateaccessioned && !defined $item->{dateaccessioned} );

    my ( $perm_loc_tag, $perm_loc_subfield ) = C4::Biblio::GetMarcFromKohaField( "items.permanent_location" );
    my $has_permanent_location = defined $perm_loc_tag && defined $item_marc->subfield( $perm_loc_tag, $perm_loc_subfield );

    # Retrieving the values for the fields that are not linked
    my @mapped_fields = Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => $frameworkcode,
            kohafield     => { -like => "items.%" }
        }
    )->get_column('kohafield');
    for my $c ( $item_object->_result->result_source->columns ) {
        next if grep { "items.$c" eq $_ } @mapped_fields;
        $item->{$c} = $item_object->$c;
    }

    $item->{cn_source} = delete $item->{'items.cn_source'}; # Because of C4::Biblio::_disambiguate
    delete $item->{'items.cn_sort'};   # Because of C4::Biblio::_disambiguate
    $item->{itemnumber} = $itemnumber;
    $item->{biblionumber} = $biblionumber;

    my $existing_cn_sort = $item_object->cn_sort; # set_or_blank will reset cn_sort to undef as we are not passing it
                                                  # We rely on Koha::Item->store to modify it if itemcallnumber or cn_source is modified
    $item_object = $item_object->set_or_blank($item);
    $item_object->cn_sort($existing_cn_sort); # Resetting to the existing value

    $item_object->make_column_dirty('permanent_location') if $has_permanent_location;

    my $unlinked_item_subfields = _get_unlinked_item_subfields( $localitemmarc, $frameworkcode );
    $item_object->more_subfields_xml(_get_unlinked_subfields_xml($unlinked_item_subfields));
    $item_object->store({ skip_record_index => $params->{skip_record_index} });

    return $item_object->unblessed;
}

=head2 ModItemTransfer

  ModItemTransfer($itemnumber, $frombranch, $tobranch, $trigger, [$params]);

Marks an item as being transferred from one branch to another and records the trigger.

The last optional parameter allows for passing skip_record_index through to the items store call.

=cut

sub ModItemTransfer {
    my ( $itemnumber, $frombranch, $tobranch, $trigger, $params ) = @_;

    my $dbh = C4::Context->dbh;
    my $item = Koha::Items->find( $itemnumber );

    # NOTE: This retains the existing hard coded behaviour by ignoring transfer limits
    # and always replacing any existing transfers. (In theory, calls to ModItemTransfer
    # will have been preceded by a check of branch transfer limits)
    my $to_library = Koha::Libraries->find($tobranch);
    my $transfer = $item->request_transfer(
        {
            to            => $to_library,
            reason        => $trigger,
            ignore_limits => 1,
            replace       => 1
        }
    );

    # Immediately set the item to in transit if it is checked in
    if ( !$item->checkout ) {
        $item->holdingbranch($frombranch)->store(
            {
                log_action        => 0,
                skip_record_index => $params->{skip_record_index}
            }
        );
        $transfer->transit;
    }

    return;
}

=head2 ModDateLastSeen

ModDateLastSeen( $itemnumber, $leave_item_lost, $params );

Mark item as seen. Is called when an item is issued, returned or manually marked during inventory/stocktaking.
C<$itemnumber> is the item number
C<$leave_item_lost> determines if a lost item will be found or remain lost

The last optional parameter allows for passing skip_record_index through to the items store call.

=cut

sub ModDateLastSeen {
    my ( $itemnumber, $leave_item_lost, $params ) = @_;

    my $item = Koha::Items->find($itemnumber);
    $item->datelastseen(dt_from_string);
    my $log = $item->itemlost && !$leave_item_lost ? 1 : 0; # If item was lost, record the change to the item
    $item->itemlost(0) unless $leave_item_lost;
    $item->store({ log_action => $log, skip_record_index => $params->{skip_record_index}, skip_holds_queue => $params->{skip_holds_queue} });
}

=head2 CheckItemPreSave

    my $item_ref = TransformMarcToKoha({ record => $marc, limit_table => 'items' });
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
  ignoreissued => $ignoreissued,
  datelastseen => $datelastseen,
  branchcode   => $branchcode,
  branch       => $branch,
  offset       => $offset,
  size         => $size,
  statushash   => $statushash,
  itemtypes    => \@itemsarray,
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
    my $class_source = $parameters->{'class_source'}  // C4::Context->preference('DefaultClassificationSource');
    my $location     = $parameters->{'location'}     // '';
    my $itemtype     = $parameters->{'itemtype'}     // '';
    my $ignoreissued = $parameters->{'ignoreissued'} // '';
    my $datelastseen = $parameters->{'datelastseen'} // '';
    my $branchcode   = $parameters->{'branchcode'}   // '';
    my $branch       = $parameters->{'branch'}       // '';
    my $offset       = $parameters->{'offset'}       // '';
    my $size         = $parameters->{'size'}         // '';
    my $statushash   = $parameters->{'statushash'}   // '';
    my $ignore_waiting_holds = $parameters->{'ignore_waiting_holds'} // '';
    my $itemtypes    = $parameters->{'itemtypes'}    || [];
    my $ccode        = $parameters->{'ccode'}        // '';

    my $dbh = C4::Context->dbh;
    my ( @bind_params, @where_strings );

    my $min_cnsort = GetClassSort($class_source,undef,$minlocation);
    my $max_cnsort = GetClassSort($class_source,undef,$maxlocation);

    my $select_columns = q{
        SELECT DISTINCT(items.itemnumber), barcode, itemcallnumber, title, author, biblio.biblionumber, biblio.frameworkcode, datelastseen, homebranch, location, notforloan, damaged, itemlost, withdrawn, stocknumber, items.cn_sort, ccode

    };
    my $select_count = q{SELECT COUNT(DISTINCT(items.itemnumber))};
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

    if ($ccode){
        push @where_strings, 'ccode = ?';
        push @bind_params, $ccode;
    }

    if ($minlocation) {
        push @where_strings, 'items.cn_sort >= ?';
        push @bind_params, $min_cnsort;
    }

    if ($maxlocation) {
        push @where_strings, 'items.cn_sort <= ?';
        push @bind_params, $max_cnsort;
    }

    if ($datelastseen) {
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

    if ( $ignore_waiting_holds ) {
        $query .= "LEFT JOIN reserves ON items.itemnumber = reserves.itemnumber ";
        push( @where_strings, q{(reserves.found != 'W' OR reserves.found IS NULL)} );
    }

    if ( @$itemtypes ) {
        my $itemtypes_str = join ', ', @$itemtypes;
        push @where_strings, "( biblioitems.itemtype IN (" . $itemtypes_str . ") OR items.itype IN (" . $itemtypes_str . ") )";
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
    )->as_list;

    my $avmapping = { map { $_->get_column('kohafield') . ',' . $_->get_column('frameworkcode') . ',' . $_->get_column('authorised_value') => $_->get_column('lib') } @avs };

    foreach my $row (@$tmpresults) {

        # Auth values
        foreach (keys %$row) {
            if (
                defined(
                    $avmapping->{ "items.$_," . $row->{'frameworkcode'} . "," . ( $row->{$_} // q{} ) }
                )
            ) {
                $row->{$_} = $avmapping->{"items.$_,".$row->{'frameworkcode'}.",".$row->{$_}};
            }
        }
        push @results, $row;
    }

    return (\@results, $iTotalRecords);
}

=head2 get_hostitemnumbers_of

  my @itemnumbers_of = get_hostitemnumbers_of($biblionumber);

Given a biblionumber, return the list of corresponding itemnumbers that are linked to it via host fields

Return a reference on a hash where key is a biblionumber and values are
references on array of itemnumbers.

=cut


sub get_hostitemnumbers_of {
    my ($biblionumber) = @_;

    if( !C4::Context->preference('EasyAnalyticalRecords') ) {
        return ();
    }

    my $biblio = Koha::Biblios->find($biblionumber);
    my $marcrecord = $biblio->metadata->record;
    return unless $marcrecord;

    my ( @returnhostitemnumbers, $tag, $biblio_s, $item_s );

    my $marcflavor = C4::Context->preference('marcflavour');
    if ( $marcflavor eq 'MARC21' ) {
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

    my $item = Koha::Items->find($itemnumber) or return;

    # Tack on 'items.' prefix to column names so that C4::Biblio::TransformKohaToMarc will work.
    # Also, don't emit a subfield if the underlying field is blank.

    return Item2Marc($item->unblessed, $biblionumber);

}
sub Item2Marc {
	my ($itemrecord,$biblionumber)=@_;
    my $mungeditem = { 
        map {  
            defined($itemrecord->{$_}) && $itemrecord->{$_} ne '' ? ("items.$_" => $itemrecord->{$_}) : ()  
        } keys %{ $itemrecord } 
    };
    my $framework = C4::Biblio::GetFrameworkCode( $biblionumber );
    my $itemmarc = C4::Biblio::TransformKohaToMarc( $mungeditem, { framework => $framework } );
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
        my ( $tag, $subfield ) = C4::Biblio::GetMarcFromKohaField( $item_field );
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

    my $marcstructure = C4::Biblio::GetMarcStructure(1, $frameworkcode, { unsafe => 1 });

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

    if ( !C4::Context->preference('EasyAnalyticalRecords') ) {
        return 0;
    }

    ### ZOOM search here
    my $query;
    $query= "hi=".$itemnumber;
    my $searcher = Koha::SearchEngine::Search->new({index => $Koha::SearchEngine::BIBLIOS_INDEX});
    my ($err,$res,$result) = $searcher->simple_search_compat($query,0,10);
    return ($result);
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
        push @columns, Koha::Database->new()->schema()->resultset('Issue')->result_source->columns;
        my @operators = qw(= != > < >= <= is like);
        push @operators, 'not like';
        my $field = $filter->{field} // q{};
        if ( (0 < grep { $_ eq $field } @columns) or (substr($field, 0, 5) eq 'marc:') ) {
            my $op = $filter->{operator};
            my $query = $filter->{query};
            my $ifnull = $filter->{ifnull};

            if (!$op or (0 == grep { $_ eq $op } @operators)) {
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
            }
            elsif ($field eq 'isbn') {
                if ( C4::Context->preference("SearchWithISBNVariations") and $query ) {
                    my @isbns = C4::Koha::GetVariationsOfISBN( $query );
                    $query = [];
                    push @$query, @isbns;
                }
                $column = $field;
            }
            elsif ($field eq 'issn') {
                if ( C4::Context->preference("SearchWithISSNVariations") and $query ) {
                    my @issns = C4::Koha::GetVariationsOfISSN( $query );
                    $query = [];
                    push @$query, @issns;
                }
                $column = $field;
            } else {
                $column = $field;
            }

            if ( defined $ifnull ) {
                $column = "COALESCE($column, ?)";
            }

            if (ref $query eq 'ARRAY') {
                if ($op eq 'like') {
                    $where_fragment = {
                        str => "($column LIKE " . join (" OR $column LIKE ", ('?') x @$query ) . ")",
                        args => $query,
                    };
                }
                else {
                    if ($op eq '=') {
                        $op = 'IN';
                    } elsif ($op eq '!=') {
                        $op = 'NOT IN';
                    }
                    $where_fragment = {
                        str => "$column $op (" . join (',', ('?') x @$query) . ")",
                        args => $query,
                    };
                }
            } elsif ( $op eq 'is' ) {
                $where_fragment = {
                    str => "$column $op $query",
                    args => [],
                };
            } else {
                $where_fragment = {
                    str => "$column $op ?",
                    args => [ $query ],
                };
            }

            if ( defined $ifnull ) {
                unshift @{ $where_fragment->{args} }, $ifnull;
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

=item * operator: comparison operator. Can be one of = != > < >= <= like 'not like' is

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
          LEFT JOIN issues ON issues.itemnumber = items.itemnumber
          WHERE 1
    };
    if (defined $where_str and $where_str ne '') {
        $query .= qq{ AND $where_str };
    }

    $query .= q{ AND biblio_metadata.format = 'marcxml' AND biblio_metadata.schema = ? };
    push @where_args, C4::Context->preference('marcflavour');

    my @columns = Koha::Database->new()->schema()->resultset('Item')->result_source->columns;
    push @columns, Koha::Database->new()->schema()->resultset('Biblio')->result_source->columns;
    push @columns, Koha::Database->new()->schema()->resultset('Biblioitem')->result_source->columns;
    push @columns, Koha::Database->new()->schema()->resultset('Issue')->result_source->columns;

    if ( $params->{sortby} eq 'availability' ) {
        my $sortorder = (uc($params->{sortorder}) eq 'ASC') ? 'ASC' : 'DESC';
        $query .= qq{ ORDER BY onloan $sortorder };
    } else {
        my $sortby = (0 < grep {$params->{sortby} eq $_} @columns)
            ? $params->{sortby} : 'itemnumber';
        my $sortorder = (uc($params->{sortorder}) eq 'ASC') ? 'ASC' : 'DESC';
        $query .= qq{ ORDER BY $sortby $sortorder };
    }

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

  PrepareItemrecordDisplay($bibnum,$itemumber,$defaultvalues,$frameworkcode);

Returns a hash with all the fields for Display a given item data in a template

$defaultvalues should either contain a hashref of values for the new item, or be undefined.

The $frameworkcode returns the item for the given frameworkcode, ONLY if bibnum is not provided

=cut

sub PrepareItemrecordDisplay {

    my ( $bibnum, $itemnum, $defaultvalues, $frameworkcode ) = @_;

    my $dbh = C4::Context->dbh;
    $frameworkcode = C4::Biblio::GetFrameworkCode($bibnum) if $bibnum;
    my ( $itemtagfield, $itemtagsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

    # Note: $tagslib obtained from GetMarcStructure() in 'unsafe' mode is
    # a shared data structure. No plugin (including custom ones) should change
    # its contents. See also GetMarcStructure.
    my $tagslib = GetMarcStructure( 1, $frameworkcode, { unsafe => 1 } );

    # Pick the default location from NewItemsDefaultLocation
    if ( C4::Context->preference('NewItemsDefaultLocation') ) {
        $defaultvalues //= {};
        $defaultvalues->{location} //= C4::Context->preference('NewItemsDefaultLocation');
    }

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
            foreach my $subfield (
                sort { $a->{display_order} <=> $b->{display_order} || $a->{subfield} cmp $b->{subfield} }
                grep { ref($_) && %$_ } # Not a subfield (values for "important", "lib", "mandatory", etc.) or empty
                values %{ $tagslib->{$tag} } )
            {
                next unless ( $subfield->{'tab'} );
                next if ( $subfield->{'tab'} ne "10" );
                my %subfield_data;
                $subfield_data{tag}           = $tag;
                $subfield_data{subfield}      = $subfield->{subfield};
                $subfield_data{countsubfield} = $cntsubf++;
                $subfield_data{kohafield}     = $subfield->{kohafield};
                $subfield_data{id}            = "tag_".$tag."_subfield_".$subfield->{subfield}."_".int(rand(1000000));

                #        $subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
                $subfield_data{marc_lib}   = $subfield->{lib};
                $subfield_data{mandatory}  = $subfield->{mandatory};
                $subfield_data{repeatable} = $subfield->{repeatable};
                $subfield_data{hidden}     = "display:none"
                  if ( ( $subfield->{hidden} > 4 )
                    || ( $subfield->{hidden} < -4 ) );
                my ( $x, $defaultvalue );
                if ($itemrecord) {
                    ( $x, $defaultvalue ) = _find_value( $tag, $subfield->{subfield}, $itemrecord );
                }
                $defaultvalue = $subfield->{defaultvalue} unless $defaultvalue;
                if ( !defined $defaultvalue ) {
                    $defaultvalue = q||;
                } else {
                    $defaultvalue =~ s/"/&quot;/g;
                    # get today date & replace <<YYYY>>, <<MM>>, <<DD>> if provided in the default value
                    my $today_dt = dt_from_string;
                    my $year     = $today_dt->strftime('%Y');
                    my $shortyear     = $today_dt->strftime('%y');
                    my $month    = $today_dt->strftime('%m');
                    my $day      = $today_dt->strftime('%d');
                    $defaultvalue =~ s/<<YYYY>>/$year/g;
                    $defaultvalue =~ s/<<YY>>/$shortyear/g;
                    $defaultvalue =~ s/<<MM>>/$month/g;
                    $defaultvalue =~ s/<<DD>>/$day/g;

                    # And <<USER>> with surname (?)
                    my $username =
                      (   C4::Context->userenv
                        ? C4::Context->userenv->{'surname'}
                        : "superlibrarian" );
                    $defaultvalue =~ s/<<USER>>/$username/g;
                }

                my $maxlength = $subfield->{maxlength};

                # search for itemcallnumber if applicable
                if ( $subfield->{kohafield} eq 'items.itemcallnumber'
                    && C4::Context->preference('itemcallnumber') && $itemrecord) {
                    foreach my $itemcn_pref (split(/,/,C4::Context->preference('itemcallnumber'))){
                        my $CNtag      = substr( $itemcn_pref, 0, 3 );
                        next unless my $field = $itemrecord->field($CNtag);
                        my $CNsubfields = substr( $itemcn_pref, 3 );
                        $CNsubfields = undef if $CNsubfields eq '';
                        $defaultvalue = $field->as_string( $CNsubfields, ' ');
                        last if $defaultvalue;
                    }
                }
                if (   $subfield->{kohafield} eq 'items.itemcallnumber'
                    && $defaultvalues
                    && $defaultvalues->{'callnumber'} ) {
                    if( $itemrecord and $defaultvalues and not $itemrecord->subfield($tag,$subfield->{subfield}) ){
                        # if the item record exists, only use default value if the item has no callnumber
                        $defaultvalue = $defaultvalues->{callnumber};
                    } elsif ( !$itemrecord and $defaultvalues ) {
                        # if the item record *doesn't* exists, always use the default value
                        $defaultvalue = $defaultvalues->{callnumber};
                    }
                }
                if (   ( $subfield->{kohafield} eq 'items.holdingbranch' || $subfield->{kohafield} eq 'items.homebranch' )
                    && $defaultvalues
                    && $defaultvalues->{'branchcode'} ) {
                    if ( $itemrecord and $defaultvalues and not $itemrecord->subfield($tag,$subfield) ) {
                        $defaultvalue = $defaultvalues->{branchcode};
                    }
                }
                if (   ( $subfield->{kohafield} eq 'items.location' )
                    && $defaultvalues
                    && $defaultvalues->{'location'} ) {

                    if ( $itemrecord and $defaultvalues and not $itemrecord->subfield($tag,$subfield->{subfield}) ) {
                        # if the item record exists, only use default value if the item has no locationr
                        $defaultvalue = $defaultvalues->{location};
                    } elsif ( !$itemrecord and $defaultvalues ) {
                        # if the item record *doesn't* exists, always use the default value
                        $defaultvalue = $defaultvalues->{location};
                    }
                }
                if (   ( $subfield->{kohafield} eq 'items.ccode' )
                    && $defaultvalues
                    && $defaultvalues->{'ccode'} ) {

                    if ( !$itemrecord and $defaultvalues ) {
                        # if the item record *doesn't* exists, always use the default value
                        $defaultvalue = $defaultvalues->{ccode};
                    }
                }
                if ( $subfield->{authorised_value} ) {
                    my @authorised_values;
                    my %authorised_lib;

                    # builds list, depending on authorised value...
                    #---- branch
                    if ( $subfield->{'authorised_value'} eq "branches" ) {
                        if (   ( C4::Context->preference("IndependentBranches") )
                            && !C4::Context->IsSuperLibrarian() ) {
                            my $sth = $dbh->prepare( "SELECT branchcode,branchname FROM branches WHERE branchcode = ? ORDER BY branchname" );
                            $sth->execute( C4::Context->userenv->{branch} );
                            push @authorised_values, ""
                              unless ( $subfield->{mandatory} );
                            while ( my ( $branchcode, $branchname ) = $sth->fetchrow_array ) {
                                push @authorised_values, $branchcode;
                                $authorised_lib{$branchcode} = $branchname;
                            }
                        } else {
                            my $sth = $dbh->prepare( "SELECT branchcode,branchname FROM branches ORDER BY branchname" );
                            $sth->execute;
                            push @authorised_values, ""
                              unless ( $subfield->{mandatory} );
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
                    } elsif ( $subfield->{authorised_value} eq "itemtypes" ) {
                        my $itemtypes = Koha::ItemTypes->search_with_localization;
                        push @authorised_values, "";
                        while ( my $itemtype = $itemtypes->next ) {
                            push @authorised_values, $itemtype->itemtype;
                            $authorised_lib{$itemtype->itemtype} = $itemtype->translated_description;
                        }
                        if ($defaultvalues && $defaultvalues->{'itemtype'}) {
                            $defaultvalue = $defaultvalues->{'itemtype'};
                        }

                        #---- class_sources
                    } elsif ( $subfield->{authorised_value} eq "cn_source" ) {
                        push @authorised_values, "";

                        my $class_sources = GetClassSources();
                        my $default_source = $defaultvalue || C4::Context->preference("DefaultClassificationSource");

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
                            $subfield->{authorised_value},
                            $branch_limit ? $branch_limit : ()
                        );
                        push @authorised_values, "";
                        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
                            push @authorised_values, $value;
                            $authorised_lib{$value} = $lib;
                        }
                    }
                    $subfield_data{marc_value} = {
                        type    => 'select',
                        values  => \@authorised_values,
                        default => $defaultvalue // q{},
                        labels  => \%authorised_lib,
                    };
                } elsif ( $subfield->{value_builder} ) {
                # it is a plugin
                    require Koha::FrameworkPlugin;
                    my $plugin = Koha::FrameworkPlugin->new({
                        name => $subfield->{value_builder},
                        item_style => 1,
                    });
                    my $pars = { dbh => $dbh, record => undef, tagslib =>$tagslib, id => $subfield_data{id} };
                    $plugin->build( $pars );
                    if ( $itemrecord and my $field = $itemrecord->field($tag) ) {
                        $defaultvalue = $field->subfield($subfield->{subfield}) || q{};
                    }
                    if( !$plugin->errstr ) {
                        #TODO Move html to template; see report 12176/13397
                        my $tab= $plugin->noclick? '-1': '';
                        my $class= $plugin->noclick? ' disabled': '';
                        my $title= $plugin->noclick? 'No popup': 'Tag editor';
                        $subfield_data{marc_value} = qq[<input type="text" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="$maxlength" value="$defaultvalue" /><a href="#" id="buttonDot_$subfield_data{id}" class="buttonDot $class" title="$title">...</a>\n].$plugin->javascript;
                    } else {
                        warn $plugin->errstr;
                        $subfield_data{marc_value} = qq(<input type="text" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="$maxlength" value="$defaultvalue" />); # supply default input form
                    }
                }
                elsif ( $tag eq '' ) {       # it's an hidden field
                    $subfield_data{marc_value} = qq(<input type="hidden" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="$maxlength" value="$defaultvalue" />);
                }
                elsif ( $subfield->{'hidden'} ) {   # FIXME: shouldn't input type be "hidden" ?
                    $subfield_data{marc_value} = qq(<input type="text" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="$maxlength" value="$defaultvalue" />);
                }
                elsif ( length($defaultvalue) > 100
                            or (C4::Context->preference("marcflavour") eq "UNIMARC" and
                                  300 <= $tag && $tag < 400 && $subfield->{subfield} eq 'a' )
                            or (C4::Context->preference("marcflavour") eq "MARC21"  and
                                  500 <= $tag && $tag < 600                     )
                          ) {
                    # oversize field (textarea)
                    $subfield_data{marc_value} = qq(<textarea id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="$maxlength">$defaultvalue</textarea>\n");
                } else {
                    $subfield_data{marc_value} = qq(<input type="text" id="$subfield_data{id}" name="field_value" class="input_marceditor" size="50" maxlength="$maxlength" value="$defaultvalue" />);
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
        # Default to using items.dateaccessioned if there's an old item modification rule
        # missing an agefield value
        my $agefield = $rule->{agefield} ? $rule->{agefield} : 'items.dateaccessioned';
        my $conditions = $rule->{conditions};
        my $substitutions = $rule->{substitutions};
        foreach ( @$substitutions ) {
            ( $_->{item_field} ) = ( $_->{field} =~ /items\.(.*)/ );
        }
        my @params;

        my $query = q|
            SELECT items.*
            FROM items
            LEFT JOIN biblioitems ON biblioitems.biblionumber = items.biblionumber
            WHERE 1
        |;
        for my $condition ( @$conditions ) {
            next unless $condition->{field};
            if (
                 grep { $_ eq $condition->{field} } @item_columns
              or grep { $_ eq $condition->{field} } @biblioitem_columns
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
            $query .= qq| AND TO_DAYS(NOW()) - TO_DAYS($agefield) >= ? |;
            push @params, $age;
        }
        my $sth = $dbh->prepare($query);
        $sth->execute( @params );
        while ( my $values = $sth->fetchrow_hashref ) {
            my $biblionumber = $values->{biblionumber};
            my $itemnumber = $values->{itemnumber};
            my $item = Koha::Items->find($itemnumber);
            for my $substitution ( @$substitutions ) {
                my $field = $substitution->{item_field};
                my $value = $substitution->{value};
                next unless $substitution->{field};
                next if ( defined $values->{ $substitution->{item_field} } and $values->{ $substitution->{item_field} } eq $substitution->{value} );
                $item->$field($value);
                push @{ $report->{$itemnumber} }, $substitution;
            }
            $item->store unless $report_only;
        }
    }

    return $report;
}

1;
