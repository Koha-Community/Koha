package C4::Biblio;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;

require Exporter;
# use utf8;
use C4::Context;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use ZOOM;
use C4::Koha;
use C4::Dates qw/format_date/;
use C4::Log; # logaction
use C4::ClassSource;

use vars qw($VERSION @ISA @EXPORT);

# TODO: fix version
# $VERSION = ?;

@ISA = qw( Exporter );

# EXPORTED FUNCTIONS.

# to add biblios or items
push @EXPORT, qw( &AddBiblio &AddItem );

# to get something
push @EXPORT, qw(
  &GetBiblio
  &GetBiblioData
  &GetBiblioItemData
  &GetBiblioItemInfosOf
  &GetBiblioItemByBiblioNumber
  &GetBiblioFromItemNumber
  
  &GetMarcItem
  &GetItem
  &GetItemInfosOf
  &GetItemStatus
  &GetItemLocation
  &GetLostItems
  &GetItemsForInventory
  &GetItemsCount

  &GetMarcNotes
  &GetMarcSubjects
  &GetMarcBiblio
  &GetMarcAuthors
  &GetMarcSeries
  GetMarcUrls
  &GetUsedMarcStructure

  &GetItemsInfo
  &GetItemsByBiblioitemnumber
  &GetItemnumberFromBarcode
  &get_itemnumbers_of
  &GetXmlBiblio

  &GetAuthorisedValueDesc
  &GetMarcStructure
  &GetMarcFromKohaField
  &GetFrameworkCode
  &GetPublisherNameFromIsbn
  &TransformKohaToMarc
);

# To modify something
push @EXPORT, qw(
  &ModBiblio
  &ModItem
  &ModItemTransfer
  &ModBiblioframework
  &ModZebra
  &ModItemInMarc
  &ModItemInMarconefield
  &ModDateLastSeen
);

# To delete something
push @EXPORT, qw(
  &DelBiblio
  &DelItem
);

# Internal functions
# those functions are exported but should not be used
# they are usefull is few circumstances, so are exported.
# but don't use them unless you're a core developer ;-)
push @EXPORT, qw(
  &ModBiblioMarc
  &AddItemInMarc
);

# Others functions
push @EXPORT, qw(
  &TransformMarcToKoha
  &TransformHtmlToMarc2
  &TransformHtmlToMarc
  &TransformHtmlToXml
  &PrepareItemrecordDisplay
  &char_decode
  &GetNoZebraIndexes
);

=head1 NAME

C4::Biblio - cataloging management functions

=head1 DESCRIPTION

Biblio.pm contains functions for managing storage and editing of bibliographic data within Koha. Most of the functions in this module are used for cataloging records: adding, editing, or removing biblios, biblioitems, or items. Koha's stores bibliographic information in three places:

=over 4

=item 1. in the biblio,biblioitems,items, etc tables, which are limited to a one-to-one mapping to underlying MARC data

=item 2. as raw MARC in the Zebra index and storage engine

=item 3. as raw MARC the biblioitems.marc and biblioitems.marcxml

=back

In the 3.0 version of Koha, the authoritative record-level information is in biblioitems.marcxml

Because the data isn't completely normalized there's a chance for information to get out of sync. The design choice to go with a un-normalized schema was driven by performance and stability concerns. However, if this occur, it can be considered as a bug : The API is (or should be) complete & the only entry point for all biblio/items managements.

=over 4

=item 1. Compared with MySQL, Zebra is slow to update an index for small data changes -- especially for proc-intensive operations like circulation

=item 2. Zebra's index has been known to crash and a backup of the data is necessary to rebuild it in such cases

=back

Because of this design choice, the process of managing storage and editing is a bit convoluted. Historically, Biblio.pm's grown to an unmanagable size and as a result we have several types of functions currently:

=over 4

=item 1. Add*/Mod*/Del*/ - high-level external functions suitable for being called from external scripts to manage the collection

=item 2. _koha_* - low-level internal functions for managing the koha tables

=item 3. Marc management function : as the MARC record is stored in biblioitems.marc(xml), some subs dedicated to it's management are in this package. They should be used only internally by Biblio.pm, the only official entry points being AddBiblio, AddItem, ModBiblio, ModItem.

=item 4. Zebra functions used to update the Zebra index

=item 5. internal helper functions such as char_decode, checkitems, etc. Some of these probably belong in Koha.pm

=back

The MARC record (in biblioitems.marcxml) contains the complete marc record, including items. It also contains the biblionumber. That is the reason why it is not stored directly by AddBiblio, with all other fields . To save a biblio, we need to :

=over 4

=item 1. save datas in biblio and biblioitems table, that gives us a biblionumber and a biblioitemnumber

=item 2. add the biblionumber and biblioitemnumber into the MARC records

=item 3. save the marc record

=back

When dealing with items, we must :

=over 4

=item 1. save the item in items table, that gives us an itemnumber

=item 2. add the itemnumber to the item MARC field

=item 3. overwrite the MARC record (with the added item) into biblioitems.marc(xml)

When modifying a biblio or an item, the behaviour is quite similar.

=back

=head1 EXPORTED FUNCTIONS

=head2 AddBiblio

=over 4

($biblionumber,$biblioitemnumber) = AddBiblio($record,$frameworkcode);
Exported function (core API) for adding a new biblio to koha.

=back

=cut

sub AddBiblio {
    my ( $record, $frameworkcode ) = @_;
	my ($biblionumber,$biblioitemnumber,$error);
    my $dbh = C4::Context->dbh;
    # transform the data into koha-table style data
    my $olddata = TransformMarcToKoha( $dbh, $record, $frameworkcode );
    ($biblionumber,$error) = _koha_add_biblio( $dbh, $olddata, $frameworkcode );
    $olddata->{'biblionumber'} = $biblionumber;
    ($biblioitemnumber,$error) = _koha_add_biblioitem( $dbh, $olddata );

    _koha_marc_update_bib_ids($record, $frameworkcode, $biblionumber, $biblioitemnumber);

    # now add the record
    $biblionumber = ModBiblioMarc( $record, $biblionumber, $frameworkcode );
      
    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","ADD",$biblionumber,"biblio") 
        if C4::Context->preference("CataloguingLog");

    return ( $biblionumber, $biblioitemnumber );
}

=head2 AddItem

=over 2

    $biblionumber = AddItem( $record, $biblionumber)
    Exported function (core API) for adding a new item to Koha

=back

=cut

sub AddItem {
    my ( $record, $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    
    # add item in old-DB
    my $frameworkcode = GetFrameworkCode( $biblionumber );
    my $item = &TransformMarcToKoha( $dbh, $record, $frameworkcode );

    # needs old biblionumber and biblioitemnumber
    $item->{'biblionumber'} = $biblionumber;
    my $sth =
      $dbh->prepare(
        "SELECT biblioitemnumber,itemtype FROM biblioitems WHERE biblionumber=?"
      );
    $sth->execute( $item->{'biblionumber'} );
    my $itemtype;
    ( $item->{'biblioitemnumber'}, $itemtype ) = $sth->fetchrow;
    $sth =
      $dbh->prepare(
        "SELECT notforloan FROM itemtypes WHERE itemtype=?");
    $sth->execute( C4::Context->preference('item-level_itypes') ? $item->{'ccode'} : $itemtype );
    my $notforloan = $sth->fetchrow;
    ##Change the notforloan field if $notforloan found
    if ( $notforloan > 0 ) {
        $item->{'notforloan'} = $notforloan;
        &MARCitemchange( $record, "items.notforloan", $notforloan );
    }
    if ( !$item->{'dateaccessioned'} || $item->{'dateaccessioned'} eq '' ) {

        # find today's date
        my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
          localtime(time);
        $year += 1900;
        $mon  += 1;
        my $date =
          "$year-" . sprintf( "%0.2d", $mon ) . "-" . sprintf( "%0.2d", $mday );
        $item->{'dateaccessioned'} = $date;
        &MARCitemchange( $record, "items.dateaccessioned", $date );
    }
    my ( $itemnumber, $error ) = &_koha_new_items( $dbh, $item, $item->{barcode} );
    # add itemnumber to MARC::Record before adding the item.
    $sth = $dbh->prepare(
"SELECT tagfield,tagsubfield 
FROM marc_subfield_structure
WHERE frameworkcode=? 
	AND kohafield=?"
      );
    &TransformKohaToMarcOneField( $sth, $record, "items.itemnumber", $itemnumber,
        $frameworkcode );

    # add the item
    &AddItemInMarc( $record, $item->{'biblionumber'},$frameworkcode );
   
    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","ADD",$itemnumber,"item") 
        if C4::Context->preference("CataloguingLog");
    
    return ($item->{biblionumber}, $item->{biblioitemnumber},$itemnumber);
}

=head2 ModBiblio

    ModBiblio( $record,$biblionumber,$frameworkcode);
    Exported function (core API) to modify a biblio

=cut

sub ModBiblio {
    my ( $record, $biblionumber, $frameworkcode ) = @_;
    if (C4::Context->preference("CataloguingLog")) {
        my $newrecord = GetMarcBiblio($biblionumber);
        &logaction(C4::Context->userenv->{'number'},"CATALOGUING","MODIFY",$biblionumber,"BEFORE=>".$newrecord->as_formatted);
    }
    
    my $dbh = C4::Context->dbh;
    
    $frameworkcode = "" unless $frameworkcode;

    # get the items before and append them to the biblio before updating the record, atm we just have the biblio
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField("items.itemnumber",$frameworkcode);
    my $oldRecord = GetMarcBiblio( $biblionumber );
    
    # parse each item, and, for an unknown reason, re-encode each subfield 
    # if you don't do that, the record will have encoding mixed
    # and the biblio will be re-encoded.
    # strange, I (Paul P.) searched more than 1 day to understand what happends
    # but could only solve the problem this way...
   my @fields = $oldRecord->field( $itemtag );
    foreach my $fielditem ( @fields ){
        my $field;
        foreach ($fielditem->subfields()) {
            if ($field) {
                $field->add_subfields(Encode::encode('utf-8',$_->[0]) => Encode::encode('utf-8',$_->[1]));
            } else {
                $field = MARC::Field->new("$itemtag",'','',Encode::encode('utf-8',$_->[0]) => Encode::encode('utf-8',$_->[1]));
            }
          }
        $record->append_fields($field);
    }
    
    # update biblionumber and biblioitemnumber in MARC
    # FIXME - this is assuming a 1 to 1 relationship between
    # biblios and biblioitems
    my $sth =  $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblionumber);
    my ($biblioitemnumber) = $sth->fetchrow;
    $sth->finish();
    _koha_marc_update_bib_ids($record, $frameworkcode, $biblionumber, $biblioitemnumber);

    # update the MARC record (that now contains biblio and items) with the new record data
    &ModBiblioMarc( $record, $biblionumber, $frameworkcode );
    
    # load the koha-table data object
    my $oldbiblio = TransformMarcToKoha( $dbh, $record, $frameworkcode );

    # modify the other koha tables
    _koha_modify_biblio( $dbh, $oldbiblio, $frameworkcode );
    _koha_modify_biblioitem_nonmarc( $dbh, $oldbiblio );
    return 1;
}

=head2 ModItem

=over 2

Exported function (core API) for modifying an item in Koha.

=back

=cut

sub ModItem {
    my ( $record, $biblionumber, $itemnumber, $delete, $new_item_hashref )
      = @_;
    
    #logging
    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","MODIFY",$itemnumber,$record->as_formatted) 
        if C4::Context->preference("CataloguingLog");
      
    my $dbh = C4::Context->dbh;
    
    # if we have a MARC record, we're coming from cataloging and so
    # we do the whole routine: update the MARC and zebra, then update the koha
    # tables
    if ($record) {
        my $frameworkcode = GetFrameworkCode( $biblionumber );
        ModItemInMarc( $record, $biblionumber, $itemnumber, $frameworkcode );
        my $olditem       = TransformMarcToKoha( $dbh, $record, $frameworkcode,'items');
        $olditem->{'biblionumber'} = $biblionumber;
        my $sth =  $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
        $sth->execute($biblionumber);
        my ($biblioitemnumber) = $sth->fetchrow;
        $sth->finish(); 
        $olditem->{'biblioitemnumber'} = $biblioitemnumber;
        _koha_modify_item( $dbh, $olditem );
        return $biblionumber;
    }

    # otherwise, we're just looking to modify something quickly
    # (like a status) so we just update the koha tables
    elsif ($new_item_hashref) {
        _koha_modify_item( $dbh, $new_item_hashref );
    }
}

sub ModItemTransfer {
    my ( $itemnumber, $frombranch, $tobranch ) = @_;
    
    my $dbh = C4::Context->dbh;
    
    #new entry in branchtransfers....
    my $sth = $dbh->prepare(
        "INSERT INTO branchtransfers (itemnumber, frombranch, datesent, tobranch)
        VALUES (?, ?, NOW(), ?)");
    $sth->execute($itemnumber, $frombranch, $tobranch);
    #update holdingbranch in items .....
     $sth= $dbh->prepare(
          "UPDATE items SET holdingbranch = ? WHERE items.itemnumber = ?");
    $sth->execute($tobranch,$itemnumber);
    &ModDateLastSeen($itemnumber);
    $sth = $dbh->prepare(
        "SELECT biblionumber FROM items WHERE itemnumber=?"
      );
    $sth->execute($itemnumber);
    while ( my ( $biblionumber ) = $sth->fetchrow ) {
        &ModItemInMarconefield( $biblionumber, $itemnumber,
            'items.holdingbranch', $tobranch );
    }
    return;
}

=head2 ModBiblioframework

    ModBiblioframework($biblionumber,$frameworkcode);
    Exported function to modify a biblio framework

=cut

sub ModBiblioframework {
    my ( $biblionumber, $frameworkcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "UPDATE biblio SET frameworkcode=? WHERE biblionumber=?"
    );
    $sth->execute($frameworkcode, $biblionumber);
    return 1;
}

=head2 ModItemInMarconefield

=over

modify only 1 field in a MARC item (mainly used for holdingbranch, but could also be used for status modif - moving a book to "lost" on a long overdu for example)
&ModItemInMarconefield( $biblionumber, $itemnumber, $itemfield, $newvalue )

=back

=cut

sub ModItemInMarconefield {
    my ( $biblionumber, $itemnumber, $itemfield, $newvalue ) = @_;
    my $dbh = C4::Context->dbh;
    if ( !defined $newvalue ) {
        $newvalue = "";
    }

    my $record = GetMarcItem( $biblionumber, $itemnumber );
    my ($tagfield, $tagsubfield) = GetMarcFromKohaField( $itemfield,'');
    if ($tagfield && $tagsubfield) {
        my $tag = $record->field($tagfield);
        if ($tag) {
#             my $tagsubs = $record->field($tagfield)->subfield($tagsubfield);
            $tag->update( $tagsubfield => $newvalue );
            $record->delete_field($tag);
            $record->insert_fields_ordered($tag);
            &ModItemInMarc( $record, $biblionumber, $itemnumber, 0 );
        }
    }
}

=head2 ModItemInMarc

=over

&ModItemInMarc( $record, $biblionumber, $itemnumber )

=back

=cut

sub ModItemInMarc {
    my ( $ItemRecord, $biblionumber, $itemnumber, $frameworkcode) = @_;
    my $dbh = C4::Context->dbh;
    
    # get complete MARC record & replace the item field by the new one
    my $completeRecord = GetMarcBiblio($biblionumber);
    my ($itemtag,$itemsubfield) = GetMarcFromKohaField("items.itemnumber",$frameworkcode);
    my $itemField = $ItemRecord->field($itemtag);
    my @items = $completeRecord->field($itemtag);
    foreach (@items) {
        if ($_->subfield($itemsubfield) eq $itemnumber) {
#             $completeRecord->delete_field($_);
            $_->replace_with($itemField);
        }
    }
    # save the record
    my $sth = $dbh->prepare("UPDATE biblioitems SET marc=?,marcxml=? WHERE biblionumber=?");
    $sth->execute( $completeRecord->as_usmarc(), $completeRecord->as_xml_record(),$biblionumber );
    $sth->finish;
    ModZebra($biblionumber,"specialUpdate","biblioserver",$completeRecord);
}

=head2 ModDateLastSeen

&ModDateLastSeen($itemnum)
Mark item as seen. Is called when an item is issued, returned or manually marked during inventory/stocktaking
C<$itemnum> is the item number

=cut

sub ModDateLastSeen {
    my ($itemnum) = @_;
    my $dbh       = C4::Context->dbh;
    my $sth       =
      $dbh->prepare(
          "UPDATE items SET itemlost=0,datelastseen  = NOW() WHERE items.itemnumber = ?"
      );
    $sth->execute($itemnum);
    return;
}
=head2 DelBiblio

=over

my $error = &DelBiblio($dbh,$biblionumber);
Exported function (core API) for deleting a biblio in koha.
Deletes biblio record from Zebra and Koha tables (biblio,biblioitems,items)
Also backs it up to deleted* tables
Checks to make sure there are not issues on any of the items
return:
C<$error> : undef unless an error occurs

=back

=cut

sub DelBiblio {
    my ( $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $error;    # for error handling
	
	# First make sure this biblio has no items attached
	my $sth = $dbh->prepare("SELECT itemnumber FROM items WHERE biblionumber=?");
	$sth->execute($biblionumber);
	if (my $itemnumber = $sth->fetchrow){
		# Fix this to use a status the template can understand
		$error .= "This Biblio has items attached, please delete them first before deleting this biblio ";
	}

    return $error if $error;

    # Delete in Zebra. Be careful NOT to move this line after _koha_delete_biblio
    # for at least 2 reasons :
    # - we need to read the biblio if NoZebra is set (to remove it from the indexes
    # - if something goes wrong, the biblio may be deleted from Koha but not from zebra
    #   and we would have no way to remove it (except manually in zebra, but I bet it would be very hard to handle the problem)
    ModZebra($biblionumber, "delete_record", "biblioserver", undef);

    # delete biblioitems and items from Koha tables and save in deletedbiblioitems,deleteditems
    $sth =
      $dbh->prepare(
        "SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
    $sth->execute($biblionumber);
    while ( my $biblioitemnumber = $sth->fetchrow ) {

        # delete this biblioitem
        $error = _koha_delete_biblioitems( $dbh, $biblioitemnumber );
        return $error if $error;
    }

    # delete biblio from Koha tables and save in deletedbiblio
    # must do this *after* _koha_delete_biblioitems, otherwise
    # delete cascade will prevent deletedbiblioitems rows
    # from being generated by _koha_delete_biblioitems
    $error = _koha_delete_biblio( $dbh, $biblionumber );

    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","DELETE",$biblionumber,"") 
        if C4::Context->preference("CataloguingLog");
    return;
}

=head2 DelItem

=over

DelItem( $biblionumber, $itemnumber );
Exported function (core API) for deleting an item record in Koha.

=back

=cut

sub DelItem {
    my ( $dbh, $biblionumber, $itemnumber ) = @_;
	
	# check the item has no current issues
	
	
    &_koha_delete_item( $dbh, $itemnumber );

    # get the MARC record
    my $record = GetMarcBiblio($biblionumber);
    my $frameworkcode = GetFrameworkCode($biblionumber);

    # backup the record
    my $copy2deleted = $dbh->prepare("UPDATE deleteditems SET marc=? WHERE itemnumber=?");
    $copy2deleted->execute( $record->as_usmarc(), $itemnumber );

    #search item field code
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField("items.itemnumber",$frameworkcode);
    my @fields = $record->field($itemtag);

    # delete the item specified
    foreach my $field (@fields) {
        if ( $field->subfield($itemsubfield) eq $itemnumber ) {
            $record->delete_field($field);
        }
    }
    &ModBiblioMarc( $record, $biblionumber, $frameworkcode );
    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","DELETE",$itemnumber,"item") 
        if C4::Context->preference("CataloguingLog");
}

=head2 GetBiblioData

=over 4

$data = &GetBiblioData($biblionumber);
Returns information about the book with the given biblionumber.
C<&GetBiblioData> returns a reference-to-hash. The keys are the fields in
the C<biblio> and C<biblioitems> tables in the
Koha database.
In addition, C<$data-E<gt>{subject}> is the list of the book's
subjects, separated by C<" , "> (space, comma, space).
If there are multiple biblioitems with the given biblionumber, only
the first one is considered.

=back

=cut

sub GetBiblioData {
    my ( $bibnum ) = @_;
    my $dbh = C4::Context->dbh;

    my $query =  C4::Context->preference('item-level_itypes')  
		? " SELECT * , biblioitems.notes AS bnotes, itemtypes.notforloan as bi_notforloan, biblio.notes
        	FROM biblio
            LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
            LEFT JOIN itemtypes ON biblioitems.itemtype = itemtypes.itemtype
        	WHERE biblio.biblionumber = ?
            AND biblioitems.biblionumber = biblio.biblionumber "
		: " SELECT * , biblioitems.notes AS bnotes, biblio.notes
        	FROM biblio
            LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
        	WHERE biblio.biblionumber = ?
            AND biblioitems.biblionumber = biblio.biblionumber
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($bibnum);
    my $data;
    $data = $sth->fetchrow_hashref;
    $sth->finish;

    return ($data);
}    # sub GetBiblioData


=head2 GetItemsInfo

=over 4

  @results = &GetItemsInfo($biblionumber, $type);

Returns information about books with the given biblionumber.

C<$type> may be either C<intra> or anything else. If it is not set to
C<intra>, then the search will exclude lost, very overdue, and
withdrawn items.

C<&GetItemsInfo> returns a list of references-to-hash. Each element
contains a number of keys. Most of them are table items from the
C<biblio>, C<biblioitems>, C<items>, and C<itemtypes> tables in the
Koha database. Other keys include:

=over 4

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

=back

=cut

sub GetItemsInfo {
    my ( $biblionumber, $type ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT *,items.notforloan as itemnotforloan
                 FROM items 
                 LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
                 LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber";
	$query .=  (C4::Context->preference('item-level_itypes')) ?
			   		 " LEFT JOIN itemtypes on items.ccode = itemtypes.itemtype "
			   		: " LEFT JOIN itemtypes on biblioitems.itemtype = itemtypes.itemtype ";
	$query .= "WHERE items.biblionumber = ? ORDER BY items.dateaccessioned desc" ;
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my $i = 0;
    my @results;
    my ( $date_due, $count_reserves );

    my $isth    = $dbh->prepare(
        "SELECT issues.*,borrowers.cardnumber,borrowers.surname,borrowers.firstname
        FROM   issues LEFT JOIN borrowers ON issues.borrowernumber=borrowers.borrowernumber
        WHERE  itemnumber = ?
            AND returndate IS NULL"
       );
    while ( my $data = $sth->fetchrow_hashref ) {
        my $datedue = '';
        $isth->execute( $data->{'itemnumber'} );
        if ( my $idata = $isth->fetchrow_hashref ) {
            $data->{borrowernumber} = $idata->{borrowernumber};
            $data->{cardnumber}     = $idata->{cardnumber};
            $data->{surname}     = $idata->{surname};
            $data->{firstname}     = $idata->{firstname};
            $datedue                = format_date( $idata->{'date_due'} );
        }
        if ( $datedue eq '' ) {
            #$datedue="Available";
            my ( $restype, $reserves ) =
              C4::Reserves::CheckReserves( $data->{'itemnumber'} );
            if ($restype) {

                #$datedue=$restype;
                $count_reserves = $restype;
            }
        }
        $isth->finish;

        #get branch information.....
        my $bsth = $dbh->prepare(
            "SELECT * FROM branches WHERE branchcode = ?
        "
        );
        $bsth->execute( $data->{'holdingbranch'} );
        if ( my $bdata = $bsth->fetchrow_hashref ) {
            $data->{'branchname'} = $bdata->{'branchname'};
        }
        my $date = format_date( $data->{'datelastseen'} );
        $data->{'datelastseen'}   = $date;
        $data->{'datedue'}        = $datedue;
        $data->{'count_reserves'} = $count_reserves;

        # get notforloan complete status if applicable
        my $sthnflstatus = $dbh->prepare(
            'SELECT authorised_value
            FROM   marc_subfield_structure
            WHERE  kohafield="items.notforloan"
        '
        );

        $sthnflstatus->execute;
        my ($authorised_valuecode) = $sthnflstatus->fetchrow;
        if ($authorised_valuecode) {
            $sthnflstatus = $dbh->prepare(
                "SELECT lib FROM authorised_values
                 WHERE  category=?
                 AND authorised_value=?"
            );
            $sthnflstatus->execute( $authorised_valuecode,
                $data->{itemnotforloan} );
            my ($lib) = $sthnflstatus->fetchrow;
            $data->{notforloan} = $lib;
        }

        # my stack procedures
        my $stackstatus = $dbh->prepare(
            'SELECT authorised_value
             FROM   marc_subfield_structure
             WHERE  kohafield="items.stack"
        '
        );
        $stackstatus->execute;

        ($authorised_valuecode) = $stackstatus->fetchrow;
        if ($authorised_valuecode) {
            $stackstatus = $dbh->prepare(
                "SELECT lib
                 FROM   authorised_values
                 WHERE  category=?
                 AND    authorised_value=?
            "
            );
            $stackstatus->execute( $authorised_valuecode, $data->{stack} );
            my ($lib) = $stackstatus->fetchrow;
            $data->{stack} = $lib;
        }
        $results[$i] = $data;
        $i++;
    }
    $sth->finish;

    return (@results);
}

=head2 getitemstatus

=over 4

$itemstatushash = &getitemstatus($fwkcode);
returns information about status.
Can be MARC dependant.
fwkcode is optional.
But basically could be can be loan or not
Create a status selector with the following code

=head3 in PERL SCRIPT

my $itemstatushash = getitemstatus;
my @itemstatusloop;
foreach my $thisstatus (keys %$itemstatushash) {
    my %row =(value => $thisstatus,
                statusname => $itemstatushash->{$thisstatus}->{'statusname'},
            );
    push @itemstatusloop, \%row;
}
$template->param(statusloop=>\@itemstatusloop);


=head3 in TEMPLATE

            <select name="statusloop">
                <option value="">Default</option>
            <!-- TMPL_LOOP name="statusloop" -->
                <option value="<!-- TMPL_VAR name="value" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="statusname" --></option>
            <!-- /TMPL_LOOP -->
            </select>

=cut

sub GetItemStatus {

    # returns a reference to a hash of references to status...
    my ($fwk) = @_;
    my %itemstatus;
    my $dbh = C4::Context->dbh;
    my $sth;
    $fwk = '' unless ($fwk);
    my ( $tag, $subfield ) =
      GetMarcFromKohaField( "items.notforloan", $fwk );
    if ( $tag and $subfield ) {
        my $sth =
          $dbh->prepare(
			"SELECT authorised_value
			FROM marc_subfield_structure
			WHERE tagfield=?
				AND tagsubfield=?
				AND frameworkcode=?
			"
          );
        $sth->execute( $tag, $subfield, $fwk );
        if ( my ($authorisedvaluecat) = $sth->fetchrow ) {
            my $authvalsth =
              $dbh->prepare(
				"SELECT authorised_value,lib
				FROM authorised_values 
				WHERE category=? 
				ORDER BY lib
				"
              );
            $authvalsth->execute($authorisedvaluecat);
            while ( my ( $authorisedvalue, $lib ) = $authvalsth->fetchrow ) {
                $itemstatus{$authorisedvalue} = $lib;
            }
            $authvalsth->finish;
            return \%itemstatus;
            exit 1;
        }
        else {

            #No authvalue list
            # build default
        }
        $sth->finish;
    }

    #No authvalue list
    #build default
    $itemstatus{"1"} = "Not For Loan";
    return \%itemstatus;
}

=head2 getitemlocation

=over 4

$itemlochash = &getitemlocation($fwk);
returns informations about location.
where fwk stands for an optional framework code.
Create a location selector with the following code

=head3 in PERL SCRIPT

my $itemlochash = getitemlocation;
my @itemlocloop;
foreach my $thisloc (keys %$itemlochash) {
    my $selected = 1 if $thisbranch eq $branch;
    my %row =(locval => $thisloc,
                selected => $selected,
                locname => $itemlochash->{$thisloc},
            );
    push @itemlocloop, \%row;
}
$template->param(itemlocationloop => \@itemlocloop);

=head3 in TEMPLATE

<select name="location">
    <option value="">Default</option>
<!-- TMPL_LOOP name="itemlocationloop" -->
    <option value="<!-- TMPL_VAR name="locval" -->" <!-- TMPL_IF name="selected" -->selected<!-- /TMPL_IF -->><!-- TMPL_VAR name="locname" --></option>
<!-- /TMPL_LOOP -->
</select>

=back

=cut

sub GetItemLocation {

    # returns a reference to a hash of references to location...
    my ($fwk) = @_;
    my %itemlocation;
    my $dbh = C4::Context->dbh;
    my $sth;
    $fwk = '' unless ($fwk);
    my ( $tag, $subfield ) =
      GetMarcFromKohaField( "items.location", $fwk );
    if ( $tag and $subfield ) {
        my $sth =
          $dbh->prepare(
			"SELECT authorised_value
			FROM marc_subfield_structure 
			WHERE tagfield=? 
				AND tagsubfield=? 
				AND frameworkcode=?"
          );
        $sth->execute( $tag, $subfield, $fwk );
        if ( my ($authorisedvaluecat) = $sth->fetchrow ) {
            my $authvalsth =
              $dbh->prepare(
				"SELECT authorised_value,lib
				FROM authorised_values
				WHERE category=?
				ORDER BY lib"
              );
            $authvalsth->execute($authorisedvaluecat);
            while ( my ( $authorisedvalue, $lib ) = $authvalsth->fetchrow ) {
                $itemlocation{$authorisedvalue} = $lib;
            }
            $authvalsth->finish;
            return \%itemlocation;
            exit 1;
        }
        else {

            #No authvalue list
            # build default
        }
        $sth->finish;
    }

    #No authvalue list
    #build default
    $itemlocation{"1"} = "Not For Loan";
    return \%itemlocation;
}

=head2 GetLostItems

$items = GetLostItems($where,$orderby);

This function get the items lost into C<$items>.

=over 2

=item input:
C<$where> is a hashref. it containts a field of the items table as key
and the value to match as value.
C<$orderby> is a field of the items table.

=item return:
C<$items> is a reference to an array full of hasref which keys are items' table column.

=item usage in the perl script:

my %where;
$where{barcode} = 0001548;
my $items = GetLostItems( \%where, "homebranch" );
$template->param(itemsloop => $items);

=back

=cut

sub GetLostItems {
    # Getting input args.
    my $where   = shift;
    my $orderby = shift;
    my $dbh     = C4::Context->dbh;

    my $query   = "
        SELECT *
        FROM   items
        WHERE  itemlost IS NOT NULL
          AND  itemlost <> 0
    ";
    foreach my $key (keys %$where) {
        $query .= " AND " . $key . " LIKE '%" . $where->{$key} . "%'";
    }
    $query .= " ORDER BY ".$orderby if defined $orderby;

    my $sth = $dbh->prepare($query);
    $sth->execute;
    my @items;
    while ( my $row = $sth->fetchrow_hashref ){
        push @items, $row;
    }
    return \@items;
}

=head2 GetItemsForInventory

$itemlist = GetItemsForInventory($minlocation,$maxlocation,$datelastseen,$offset,$size)

Retrieve a list of title/authors/barcode/callnumber, for biblio inventory.

The sub returns a list of hashes, containing itemnumber, author, title, barcode & item callnumber.
It is ordered by callnumber,title.

The minlocation & maxlocation parameters are used to specify a range of item callnumbers
the datelastseen can be used to specify that you want to see items not seen since a past date only.
offset & size can be used to retrieve only a part of the whole listing (defaut behaviour)

=cut

sub GetItemsForInventory {
    my ( $minlocation, $maxlocation,$location, $datelastseen, $branch, $offset, $size ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($datelastseen) {
        $datelastseen=format_date_in_iso($datelastseen);  
        my $query =
                "SELECT itemnumber,barcode,itemcallnumber,title,author,biblio.biblionumber,datelastseen
                 FROM items
                   LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber 
                 WHERE itemcallnumber>= ?
                   AND itemcallnumber <=?
                   AND (datelastseen< ? OR datelastseen IS NULL)";
        $query.= " AND items.location=".$dbh->quote($location) if $location;
        $query.= " AND items.homebranch=".$dbh->quote($branch) if $branch;
        $query .= " ORDER BY itemcallnumber,title";
        $sth = $dbh->prepare($query);
        $sth->execute( $minlocation, $maxlocation, $datelastseen );
    }
    else {
        my $query ="
                SELECT itemnumber,barcode,itemcallnumber,biblio.biblionumber,title,author,datelastseen
                FROM items 
                  LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber 
                WHERE itemcallnumber>= ?
                  AND itemcallnumber <=?";
        $query.= " AND items.location=".$dbh->quote($location) if $location;
        $query.= " AND items.homebranch=".$dbh->quote($branch) if $branch;
        $query .= " ORDER BY itemcallnumber,title";
        $sth = $dbh->prepare($query);
        $sth->execute( $minlocation, $maxlocation );
    }
    my @results;
    while ( my $row = $sth->fetchrow_hashref ) {
        $offset-- if ($offset);
        $row->{datelastseen}=format_date($row->{datelastseen});
        if ( ( !$offset ) && $size ) {
            push @results, $row;
            $size--;
        }
    }
    return \@results;
}

=head2 &GetBiblioItemData

=over 4

$itemdata = &GetBiblioItemData($biblioitemnumber);

Looks up the biblioitem with the given biblioitemnumber. Returns a
reference-to-hash. The keys are the fields from the C<biblio>,
C<biblioitems>, and C<itemtypes> tables in the Koha database, except
that C<biblioitems.notes> is given as C<$itemdata-E<gt>{bnotes}>.

=back

=cut

#'
sub GetBiblioItemData {
    my ($biblioitemnumber) = @_;
    my $dbh       = C4::Context->dbh;
	my $query = "SELECT *,biblioitems.notes AS bnotes
		FROM biblio, biblioitems ";
	if(C4::Context->preference('item-level_itypes')) { 
		$query .= "LEFT JOIN itemtypes on biblioitems.itemtype=itemtypes.itemtype ";
	}	 
	$query .= " WHERE biblio.biblionumber = biblioitems.biblionumber 
		AND biblioitemnumber = ? ";
    my $sth       =  $dbh->prepare($query);
    my $data;
    $sth->execute($biblioitemnumber);
    $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ($data);
}    # sub &GetBiblioItemData

=head2 GetItemnumberFromBarcode

=over 4

$result = GetItemnumberFromBarcode($barcode);

=back

=cut

sub GetItemnumberFromBarcode {
    my ($barcode) = @_;
    my $dbh = C4::Context->dbh;

    my $rq =
      $dbh->prepare("SELECT itemnumber FROM items WHERE items.barcode=?");
    $rq->execute($barcode);
    my ($result) = $rq->fetchrow;
    return ($result);
}

=head2 GetBiblioItemByBiblioNumber

=over 4

NOTE : This function has been copy/paste from C4/Biblio.pm from head before zebra integration.

=back

=cut

sub GetBiblioItemByBiblioNumber {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("Select * FROM biblioitems WHERE biblionumber = ?");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);

    while ( my $data = $sth->fetchrow_hashref ) {
        push @results, $data;
    }

    $sth->finish;
    return @results;
}

=head2 GetBiblioFromItemNumber

=over 4

$item = &GetBiblioFromItemNumber($itemnumber);

Looks up the item with the given itemnumber.

C<&itemnodata> returns a reference-to-hash whose keys are the fields
from the C<biblio>, C<biblioitems>, and C<items> tables in the Koha
database.

=back

=cut

#'
sub GetBiblioFromItemNumber {
    my ( $itemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT * FROM items 
        LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
        LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber
         WHERE items.itemnumber = ?"
    );

    $sth->execute($itemnumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ($data);
}

=head2 GetBiblio

=over 4

( $count, @results ) = &GetBiblio($biblionumber);

=back

=cut

sub GetBiblio {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM biblio WHERE biblionumber = ?");
    my $count = 0;
    my @results;
    $sth->execute($biblionumber);
    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while
    $sth->finish;
    return ( $count, @results );
}    # sub GetBiblio

=head2 GetItem

=over 4

$data = &GetItem($itemnumber,$barcode);

return Item information, for a given itemnumber or barcode

=back

=cut

sub GetItem {
    my ($itemnumber,$barcode) = @_;
    my $dbh = C4::Context->dbh;
    if ($itemnumber) {
        my $sth = $dbh->prepare("
            SELECT * FROM items 
            WHERE itemnumber = ?");
        $sth->execute($itemnumber);
        my $data = $sth->fetchrow_hashref;
        return $data;
    } else {
        my $sth = $dbh->prepare("
            SELECT * FROM items 
            WHERE barcode = ?"
            );
        $sth->execute($barcode);
        my $data = $sth->fetchrow_hashref;
        return $data;
    }
}    # sub GetItem

=head2 get_itemnumbers_of

=over 4

my @itemnumbers_of = get_itemnumbers_of(@biblionumbers);

Given a list of biblionumbers, return the list of corresponding itemnumbers
for each biblionumber.

Return a reference on a hash where keys are biblionumbers and values are
references on array of itemnumbers.

=back

=cut

sub get_itemnumbers_of {
    my @biblionumbers = @_;

    my $dbh = C4::Context->dbh;

    my $query = '
        SELECT itemnumber,
            biblionumber
        FROM items
        WHERE biblionumber IN (?' . ( ',?' x scalar @biblionumbers - 1 ) . ')
    ';
    my $sth = $dbh->prepare($query);
    $sth->execute(@biblionumbers);

    my %itemnumbers_of;

    while ( my ( $itemnumber, $biblionumber ) = $sth->fetchrow_array ) {
        push @{ $itemnumbers_of{$biblionumber} }, $itemnumber;
    }

    return \%itemnumbers_of;
}

=head2 GetItemInfosOf

=over 4

GetItemInfosOf(@itemnumbers);

=back

=cut

sub GetItemInfosOf {
    my @itemnumbers = @_;

    my $query = '
        SELECT *
        FROM items
        WHERE itemnumber IN (' . join( ',', @itemnumbers ) . ')
    ';
    return get_infos_of( $query, 'itemnumber' );
}

=head2 GetItemsByBiblioitemnumber

=over 4

GetItemsByBiblioitemnumber($biblioitemnumber);

Returns an arrayref of hashrefs suitable for use in a TMPL_LOOP
Called by moredetail.pl

=back

=cut

sub GetItemsByBiblioitemnumber {
	my ( $bibitem ) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT * FROM items WHERE items.biblioitemnumber = ?")	|| die $dbh->errstr;
	# Get all items attached to a biblioitem
    my $i = 0;
    my @results; 
    $sth->execute($bibitem) || die $sth->errstr;
    while ( my $data = $sth->fetchrow_hashref ) {  
		# Foreach item, get circulation information
		my $sth2 = $dbh->prepare( "SELECT * FROM issues,borrowers
                                   WHERE itemnumber = ?
                                   AND returndate is NULL
                                   AND issues.borrowernumber = borrowers.borrowernumber"
        );
        $sth2->execute( $data->{'itemnumber'} );
        if ( my $data2 = $sth2->fetchrow_hashref ) {
			# if item is out, set the due date and who it is out too
			$data->{'date_due'}   = $data2->{'date_due'};
			$data->{'cardnumber'} = $data2->{'cardnumber'};
			$data->{'borrowernumber'}   = $data2->{'borrowernumber'};
		}
        else {
			# set date_due to blank, so in the template we check itemlost, and wthdrawn 
			$data->{'date_due'} = '';                                                                                                         
		}    # else         
        $sth2->finish;
        # Find the last 3 people who borrowed this item.                  
        my $query2 = "SELECT * FROM issues, borrowers WHERE itemnumber = ?
                      AND issues.borrowernumber = borrowers.borrowernumber
                      AND returndate is not NULL
                      ORDER BY returndate desc,timestamp desc LIMIT 3";
        $sth2 = $dbh->prepare($query2) || die $dbh->errstr;
        $sth2->execute( $data->{'itemnumber'} ) || die $sth2->errstr;
        my $i2 = 0;
        while ( my $data2 = $sth2->fetchrow_hashref ) {
			$data->{"timestamp$i2"} = $data2->{'timestamp'};
			$data->{"card$i2"}      = $data2->{'cardnumber'};
			$data->{"borrower$i2"}  = $data2->{'borrowernumber'};
			$i2++;
		}
        $sth2->finish;
        push(@results,$data);
    } 
    $sth->finish;
    return (\@results); 
}


=head2 GetBiblioItemInfosOf

=over 4

GetBiblioItemInfosOf(@biblioitemnumbers);

=back

=cut

sub GetBiblioItemInfosOf {
    my @biblioitemnumbers = @_;

    my $query = '
        SELECT biblioitemnumber,
            publicationyear,
            itemtype
        FROM biblioitems
        WHERE biblioitemnumber IN (' . join( ',', @biblioitemnumbers ) . ')
    ';
    return get_infos_of( $query, 'biblioitemnumber' );
}

=head1 FUNCTIONS FOR HANDLING MARC MANAGEMENT

=head2 GetMarcStructure

=over 4

$res = GetMarcStructure($forlibrarian,$frameworkcode);

Returns a reference to a big hash of hash, with the Marc structure for the given frameworkcode
$forlibrarian  :if set to 1, the MARC descriptions are the librarians ones, otherwise it's the public (OPAC) ones
$frameworkcode : the framework code to read

=back

=cut

sub GetMarcStructure {
    my ( $forlibrarian, $frameworkcode ) = @_;
    my $dbh=C4::Context->dbh;
    $frameworkcode = "" unless $frameworkcode;
    my $sth;
    my $libfield = ( $forlibrarian eq 1 ) ? 'liblibrarian' : 'libopac';

    # check that framework exists
    $sth =
      $dbh->prepare(
        "SELECT COUNT(*) FROM marc_tag_structure WHERE frameworkcode=?");
    $sth->execute($frameworkcode);
    my ($total) = $sth->fetchrow;
    $frameworkcode = "" unless ( $total > 0 );
    $sth =
      $dbh->prepare(
		"SELECT tagfield,liblibrarian,libopac,mandatory,repeatable 
		FROM marc_tag_structure 
		WHERE frameworkcode=? 
		ORDER BY tagfield"
      );
    $sth->execute($frameworkcode);
    my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable ) =
        $sth->fetchrow )
    {
        $res->{$tag}->{lib} =
          ( $forlibrarian or !$libopac ) ? $liblibrarian : $libopac;
        $res->{$tab}->{tab}        = "";
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
    }

    $sth =
      $dbh->prepare(
			"SELECT tagfield,tagsubfield,liblibrarian,libopac,tab,mandatory,repeatable,authorised_value,authtypecode,value_builder,kohafield,seealso,hidden,isurl,link,defaultvalue 
				FROM marc_subfield_structure 
			WHERE frameworkcode=? 
				ORDER BY tagfield,tagsubfield
			"
    );
    
    $sth->execute($frameworkcode);

    my $subfield;
    my $authorised_value;
    my $authtypecode;
    my $value_builder;
    my $kohafield;
    my $seealso;
    my $hidden;
    my $isurl;
    my $link;
    my $defaultvalue;

    while (
        (
            $tag,          $subfield,      $liblibrarian,
            ,              $libopac,       $tab,
            $mandatory,    $repeatable,    $authorised_value,
            $authtypecode, $value_builder, $kohafield,
            $seealso,      $hidden,        $isurl,
            $link,$defaultvalue
        )
        = $sth->fetchrow
      )
    {
        $res->{$tag}->{$subfield}->{lib} =
          ( $forlibrarian or !$libopac ) ? $liblibrarian : $libopac;
        $res->{$tag}->{$subfield}->{tab}              = $tab;
        $res->{$tag}->{$subfield}->{mandatory}        = $mandatory;
        $res->{$tag}->{$subfield}->{repeatable}       = $repeatable;
        $res->{$tag}->{$subfield}->{authorised_value} = $authorised_value;
        $res->{$tag}->{$subfield}->{authtypecode}     = $authtypecode;
        $res->{$tag}->{$subfield}->{value_builder}    = $value_builder;
        $res->{$tag}->{$subfield}->{kohafield}        = $kohafield;
        $res->{$tag}->{$subfield}->{seealso}          = $seealso;
        $res->{$tag}->{$subfield}->{hidden}           = $hidden;
        $res->{$tag}->{$subfield}->{isurl}            = $isurl;
        $res->{$tag}->{$subfield}->{'link'}           = $link;
        $res->{$tag}->{$subfield}->{defaultvalue}     = $defaultvalue;
    }
    return $res;
}

=head2 GetUsedMarcStructure

    the same function as GetMarcStructure expcet it just take field
    in tab 0-9. (used field)
    
    my $results = GetUsedMarcStructure($frameworkcode);
    
    L<$results> is a ref to an array which each case containts a ref
    to a hash which each keys is the columns from marc_subfield_structure
    
    L<$frameworkcode> is the framework code. 
    
=cut

sub GetUsedMarcStructure($){
    my $frameworkcode = shift || '';
    my $dbh           = C4::Context->dbh;
    my $query         = qq/
        SELECT *
        FROM   marc_subfield_structure
        WHERE   tab > -1 
            AND frameworkcode = ?
    /;
    my @results;
    my $sth = $dbh->prepare($query);
    $sth->execute($frameworkcode);
    while (my $row = $sth->fetchrow_hashref){
        push @results,$row;
    }
    return \@results;
}

=head2 GetMarcFromKohaField

=over 4

($MARCfield,$MARCsubfield)=GetMarcFromKohaField($kohafield,$frameworkcode);
Returns the MARC fields & subfields mapped to the koha field 
for the given frameworkcode

=back

=cut

sub GetMarcFromKohaField {
    my ( $kohafield, $frameworkcode ) = @_;
    return 0, 0 unless $kohafield;
    my $relations = C4::Context->marcfromkohafield;
    return (
        $relations->{$frameworkcode}->{$kohafield}->[0],
        $relations->{$frameworkcode}->{$kohafield}->[1]
    );
}

=head2 GetMarcBiblio

=over 4

Returns MARC::Record of the biblionumber passed in parameter.
the marc record contains both biblio & item datas

=back

=cut

sub GetMarcBiblio {
    my $biblionumber = shift;
    my $dbh          = C4::Context->dbh;
    my $sth          =
      $dbh->prepare("SELECT marcxml FROM biblioitems WHERE biblionumber=? ");
    $sth->execute($biblionumber);
     my ($marcxml) = $sth->fetchrow;
     MARC::File::XML->default_record_format(C4::Context->preference('marcflavour'));
     $marcxml =~ s/\x1e//g;
     $marcxml =~ s/\x1f//g;
     $marcxml =~ s/\x1d//g;
     $marcxml =~ s/\x0f//g;
     $marcxml =~ s/\x0c//g;  
#   warn $marcxml;
    my $record = MARC::Record->new();
    if ($marcxml) {
        $record = eval {MARC::Record::new_from_xml( $marcxml, "utf8", C4::Context->preference('marcflavour'))};
        if ($@) {warn $@;}
#      $record = MARC::Record::new_from_usmarc( $marc) if $marc;
        return $record;
    } else {
        return undef;
    }
}

=head2 GetXmlBiblio

=over 4

my $marcxml = GetXmlBiblio($biblionumber);

Returns biblioitems.marcxml of the biblionumber passed in parameter.
The XML contains both biblio & item datas

=back

=cut

sub GetXmlBiblio {
    my ( $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare("SELECT marcxml FROM biblioitems WHERE biblionumber=? ");
    $sth->execute($biblionumber);
    my ($marcxml) = $sth->fetchrow;
    return $marcxml;
}

=head2 GetAuthorisedValueDesc

=over 4

my $subfieldvalue =get_authorised_value_desc(
    $tag, $subf[$i][0],$subf[$i][1], '', $taglib);
Retrieve the complete description for a given authorised value.

=back

=cut

sub GetAuthorisedValueDesc {
    my ( $tag, $subfield, $value, $framework, $tagslib ) = @_;
    my $dbh = C4::Context->dbh;
    
    #---- branch
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
        return C4::Branch::GetBranchName($value);
    }

    #---- itemtypes
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "itemtypes" ) {
        return getitemtypeinfo($value)->{description};
    }

    #---- "true" authorized value
    my $category = $tagslib->{$tag}->{$subfield}->{'authorised_value'};
    if ( $category ne "" ) {
        my $sth =
          $dbh->prepare(
            "SELECT lib FROM authorised_values WHERE category = ? AND authorised_value = ?"
          );
        $sth->execute( $category, $value );
        my $data = $sth->fetchrow_hashref;
        return $data->{'lib'};
    }
    else {
        return $value;    # if nothing is found return the original value
    }
}

=head2 GetMarcItem

=over 4

Returns MARC::Record of the item passed in parameter.

=back

=cut

sub GetMarcItem {
    my ( $biblionumber, $itemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $newrecord = MARC::Record->new();
    my $marcflavour = C4::Context->preference('marcflavour');
    
    my $marcxml = GetXmlBiblio($biblionumber);
    my $record = MARC::Record->new();
    $record = MARC::Record::new_from_xml( $marcxml, "utf8", $marcflavour );
    # now, find where the itemnumber is stored & extract only the item
    my ( $itemnumberfield, $itemnumbersubfield ) =
      GetMarcFromKohaField( 'items.itemnumber', '' );
    my @fields = $record->field($itemnumberfield);
    foreach my $field (@fields) {
        if ( $field->subfield($itemnumbersubfield) eq $itemnumber ) {
            $newrecord->insert_fields_ordered($field);
        }
    }
    return $newrecord;
}



=head2 GetMarcNotes

=over 4

$marcnotesarray = GetMarcNotes( $record, $marcflavour );
Get all notes from the MARC record and returns them in an array.
The note are stored in differents places depending on MARC flavour

=back

=cut

sub GetMarcNotes {
    my ( $record, $marcflavour ) = @_;
    my $scope;
    if ( $marcflavour eq "MARC21" ) {
        $scope = '5..';
    }
    else {    # assume unimarc if not marc21
        $scope = '3..';
    }
    my @marcnotes;
    my $note = "";
    my $tag  = "";
    my $marcnote;
    foreach my $field ( $record->field($scope) ) {
        my $value = $field->as_string();
        if ( $note ne "" ) {
            $marcnote = { marcnote => $note, };
            push @marcnotes, $marcnote;
            $note = $value;
        }
        if ( $note ne $value ) {
            $note = $note . " " . $value;
        }
    }

    if ( $note ) {
        $marcnote = { marcnote => $note };
        push @marcnotes, $marcnote;    #load last tag into array
    }
    return \@marcnotes;
}    # end GetMarcNotes

=head2 GetMarcSubjects

=over 4

$marcsubjcts = GetMarcSubjects($record,$marcflavour);
Get all subjects from the MARC record and returns them in an array.
The subjects are stored in differents places depending on MARC flavour

=back

=cut

sub GetMarcSubjects {
    my ( $record, $marcflavour ) = @_;
    my ( $mintag, $maxtag );
    if ( $marcflavour eq "MARC21" ) {
        $mintag = "600";
        $maxtag = "699";
    }
    else {    # assume unimarc if not marc21
        $mintag = "600";
        $maxtag = "611";
    }
	
    my @marcsubjects;
	my $subject = "";
	my $subfield = "";
	my $marcsubject;

    foreach my $field ( $record->field('6..' )) {
        next unless $field->tag() >= $mintag && $field->tag() <= $maxtag;
		my @subfields_loop;
        my @subfields = $field->subfields();
		my $counter = 0;
		my @link_loop;
		for my $subject_subfield (@subfields ) {
			# don't load unimarc subfields 3,4,5
			next if (($marcflavour eq "UNIMARC") and ($subject_subfield->[0] =~ (3|4|5) ) );
			my $code = $subject_subfield->[0];
			my $value = $subject_subfield->[1];
			my $linkvalue = $value;
			$linkvalue =~ s/(\(|\))//g;
			my $operator = " and " unless $counter==0;
			push @link_loop, {link => $linkvalue, operator => $operator };
			my $separator = C4::Context->preference("authoritysep") unless $counter==0;
			# ignore $9
			push @subfields_loop, {code => $code, value => $value, link_loop => \@link_loop, separator => $separator} unless ($subject_subfield->[0] == 9 );
			# this needs to be added back in in a way that the template can expose it properly
			#if ( $code == 9 ) {
            #    $link = "an:".$subject_subfield->[1];
            #    $flag = 1;
            #}
			$counter++;
		}
                
		push @marcsubjects, { MARCSUBJECT_SUBFIELDS_LOOP => \@subfields_loop };
        
	}
        return \@marcsubjects;
}  #end getMARCsubjects

=head2 GetMarcAuthors

=over 4

authors = GetMarcAuthors($record,$marcflavour);
Get all authors from the MARC record and returns them in an array.
The authors are stored in differents places depending on MARC flavour

=back

=cut

sub GetMarcAuthors {
    my ( $record, $marcflavour ) = @_;
    my ( $mintag, $maxtag );
    # tagslib useful for UNIMARC author reponsabilities
    my $tagslib = &GetMarcStructure( 1, '' ); # FIXME : we don't have the framework available, we take the default framework. May be bugguy on some setups, will be usually correct.
    if ( $marcflavour eq "MARC21" ) {
        $mintag = "700";
        $maxtag = "720"; 
    }
    elsif ( $marcflavour eq "UNIMARC" ) {    # assume unimarc if not marc21
        $mintag = "701";
        $maxtag = "712";
    }
	else {
		return;
	}
    my @marcauthors;

    foreach my $field ( $record->fields ) {
        next unless $field->tag() >= $mintag && $field->tag() <= $maxtag;
        my %hash;
        my @subfields = $field->subfields();
        my $count_auth = 0;
        for my $authors_subfield (@subfields) {
			#unimarc-specific line
            next if ($marcflavour eq 'UNIMARC' and (($authors_subfield->[0] eq '3') or ($authors_subfield->[0] eq '5')));
            my $subfieldcode = $authors_subfield->[0];
            my $value;
            # deal with UNIMARC author responsibility
			if ( $marcflavour eq 'UNIMARC' and ($authors_subfield->[0] eq '4')) {
            	$value = "(".GetAuthorisedValueDesc( $field->tag(), $authors_subfield->[0], $authors_subfield->[1], '', $tagslib ).")";
            } else {
                $value        = $authors_subfield->[1];
            }
            $hash{tag}       = $field->tag;
            $hash{value}    .= $value . " " if ($subfieldcode != 9) ;
            $hash{link}     .= $value if ($subfieldcode eq 9);
        }
        push @marcauthors, \%hash;
    }
    return \@marcauthors;
}

=head2 GetMarcUrls

=over 4

$marcurls = GetMarcUrls($record,$marcflavour);
Returns arrayref of URLs from MARC data, suitable to pass to tmpl loop.
Assumes web resources (not uncommon in MARC21 to omit resource type ind) 

=back

=cut

sub GetMarcUrls {
    my ($record, $marcflavour) = @_;
    my @marcurls;
    my $marcurl;
    for my $field ($record->field('856')) {
        my $url = $field->subfield('u');
        my @notes;
        for my $note ( $field->subfield('z')) {
            push @notes , {note => $note};
        }        
        $marcurl = {  MARCURL => $url,
                      notes => \@notes,
					};
		if($marcflavour eq 'MARC21') {
        	my $s3 = $field->subfield('3');
			my $link = $field->subfield('y');
            $marcurl->{'linktext'} = $link || $s3 || $url ;;
            $marcurl->{'part'} = $s3 if($link);
            $marcurl->{'toc'} = 1 if($s3 =~ /^[Tt]able/) ;
		} else {
			$marcurl->{'linktext'} = $url;
		}
        push @marcurls, $marcurl;    
	}
    return \@marcurls;
}  #end GetMarcUrls

=head2 GetMarcSeries

=over 4

$marcseriesarray = GetMarcSeries($record,$marcflavour);
Get all series from the MARC record and returns them in an array.
The series are stored in differents places depending on MARC flavour

=back

=cut

sub GetMarcSeries {
    my ($record, $marcflavour) = @_;
    my ($mintag, $maxtag);
    if ($marcflavour eq "MARC21") {
        $mintag = "440";
        $maxtag = "490";
    } else {           # assume unimarc if not marc21
        $mintag = "600";
        $maxtag = "619";
    }

    my @marcseries;
    my $subjct = "";
    my $subfield = "";
    my $marcsubjct;

    foreach my $field ($record->field('440'), $record->field('490')) {
        my @subfields_loop;
        #my $value = $field->subfield('a');
        #$marcsubjct = {MARCSUBJCT => $value,};
        my @subfields = $field->subfields();
        #warn "subfields:".join " ", @$subfields;
        my $counter = 0;
        my @link_loop;
        for my $series_subfield (@subfields) {
			my $volume_number;
			undef $volume_number;
			# see if this is an instance of a volume
			if ($series_subfield->[0] eq 'v') {
				$volume_number=1;
			}

            my $code = $series_subfield->[0];
            my $value = $series_subfield->[1];
            my $linkvalue = $value;
            $linkvalue =~ s/(\(|\))//g;
            my $operator = " and " unless $counter==0;
            push @link_loop, {link => $linkvalue, operator => $operator };
            my $separator = C4::Context->preference("authoritysep") unless $counter==0;
			if ($volume_number) {
			push @subfields_loop, {volumenum => $value};
			}
			else {
            push @subfields_loop, {code => $code, value => $value, link_loop => \@link_loop, separator => $separator, volumenum => $volume_number};
			}
            $counter++;
        }
        push @marcseries, { MARCSERIES_SUBFIELDS_LOOP => \@subfields_loop };
        #$marcsubjct = {MARCSUBJCT => $field->as_string(),};
        #push @marcsubjcts, $marcsubjct;
        #$subjct = $value;

    }
    my $marcseriessarray=\@marcseries;
    return $marcseriessarray;
}  #end getMARCseriess

=head2 GetFrameworkCode

=over 4

    $frameworkcode = GetFrameworkCode( $biblionumber )

=back

=cut

sub GetFrameworkCode {
    my ( $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT frameworkcode FROM biblio WHERE biblionumber=?");
    $sth->execute($biblionumber);
    my ($frameworkcode) = $sth->fetchrow;
    return $frameworkcode;
}

=head2 GetPublisherNameFromIsbn

    $name = GetPublishercodeFromIsbn($isbn);
    if(defined $name){
        ...
    }

=cut

sub GetPublisherNameFromIsbn($){
    my $isbn = shift;
    $isbn =~ s/[- _]//g;
    $isbn =~ s/^0*//;
    my @codes = (split '-', DisplayISBN($isbn));
    my $code = $codes[0].$codes[1].$codes[2];
    my $dbh  = C4::Context->dbh;
    my $query = qq{
        SELECT distinct publishercode
        FROM   biblioitems
        WHERE  isbn LIKE ?
        AND    publishercode IS NOT NULL
        LIMIT 1
    };
    my $sth = $dbh->prepare($query);
    $sth->execute("$code%");
    my $name = $sth->fetchrow;
    return $name if length $name;
    return undef;
}

=head2 TransformKohaToMarc

=over 4

    $record = TransformKohaToMarc( $hash )
    This function builds partial MARC::Record from a hash
    Hash entries can be from biblio or biblioitems.
    This function is called in acquisition module, to create a basic catalogue entry from user entry

=back

=cut

sub TransformKohaToMarc {

    my ( $hash ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
    $dbh->prepare(
        "SELECT tagfield,tagsubfield FROM marc_subfield_structure WHERE frameworkcode=? AND kohafield=?"
    );
    my $record = MARC::Record->new();
    foreach (keys %{$hash}) {
        &TransformKohaToMarcOneField( $sth, $record, $_,
            $hash->{$_}, '' );
        }
    return $record;
}

=head2 TransformKohaToMarcOneField

=over 4

    $record = TransformKohaToMarcOneField( $sth, $record, $kohafieldname, $value, $frameworkcode );

=back

=cut

sub TransformKohaToMarcOneField {
    my ( $sth, $record, $kohafieldname, $value, $frameworkcode ) = @_;
    $frameworkcode='' unless $frameworkcode;
    my $tagfield;
    my $tagsubfield;

    if ( !defined $sth ) {
        my $dbh = C4::Context->dbh;
        $sth = $dbh->prepare(
            "SELECT tagfield,tagsubfield FROM marc_subfield_structure WHERE frameworkcode=? AND kohafield=?"
        );
    }
    $sth->execute( $frameworkcode, $kohafieldname );
    if ( ( $tagfield, $tagsubfield ) = $sth->fetchrow ) {
        my $tag = $record->field($tagfield);
        if ($tag) {
            $tag->update( $tagsubfield => $value );
            $record->delete_field($tag);
            $record->insert_fields_ordered($tag);
        }
        else {
            $record->add_fields( $tagfield, " ", " ", $tagsubfield => $value );
        }
    }
    return $record;
}

=head2 TransformHtmlToXml

=over 4

$xml = TransformHtmlToXml( $tags, $subfields, $values, $indicator, $ind_tag, $auth_type )

$auth_type contains :
- nothing : rebuild a biblio, un UNIMARC the encoding is in 100$a pos 26/27
- UNIMARCAUTH : rebuild an authority. In UNIMARC, the encoding is in 100$a pos 13/14
- ITEM : rebuild an item : in UNIMARC, 100$a, it's in the biblio ! (otherwise, we would get 2 100 fields !)

=back

=cut

sub TransformHtmlToXml {
    my ( $tags, $subfields, $values, $indicator, $ind_tag, $auth_type ) = @_;
    my $xml = MARC::File::XML::header('UTF-8');
    $auth_type = C4::Context->preference('marcflavour') unless $auth_type;
    MARC::File::XML->default_record_format($auth_type);
    # in UNIMARC, field 100 contains the encoding
    # check that there is one, otherwise the 
    # MARC::Record->new_from_xml will fail (and Koha will die)
    my $unimarc_and_100_exist=0;
    $unimarc_and_100_exist=1 if $auth_type eq 'ITEM'; # if we rebuild an item, no need of a 100 field
    my $prevvalue;
    my $prevtag = -1;
    my $first   = 1;
    my $j       = -1;
    for ( my $i = 0 ; $i <= @$tags ; $i++ ) {
        if (C4::Context->preference('marcflavour') eq 'UNIMARC' and @$tags[$i] eq "100" and @$subfields[$i] eq "a") {
            # if we have a 100 field and it's values are not correct, skip them.
            # if we don't have any valid 100 field, we will create a default one at the end
            my $enc = substr( @$values[$i], 26, 2 );
            if ($enc eq '01' or $enc eq '50' or $enc eq '03') {
                $unimarc_and_100_exist=1;
            } else {
                next;
            }
        }
        @$values[$i] =~ s/&/&amp;/g;
        @$values[$i] =~ s/</&lt;/g;
        @$values[$i] =~ s/>/&gt;/g;
        @$values[$i] =~ s/"/&quot;/g;
        @$values[$i] =~ s/'/&apos;/g;
#         if ( !utf8::is_utf8( @$values[$i] ) ) {
#             utf8::decode( @$values[$i] );
#         }
        if ( ( @$tags[$i] ne $prevtag ) ) {
            $j++ unless ( @$tags[$i] eq "" );
            if ( !$first ) {
                $xml .= "</datafield>\n";
                if (   ( @$tags[$i] && @$tags[$i] > 10 )
                    && ( @$values[$i] ne "" ) )
                {
                    my $ind1 = substr( @$indicator[$j], 0, 1 );
                    my $ind2;
                    if ( @$indicator[$j] ) {
                        $ind2 = substr( @$indicator[$j], 1, 1 );
                    }
                    else {
                        warn "Indicator in @$tags[$i] is empty";
                        $ind2 = " ";
                    }
                    $xml .=
"<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                    $xml .=
"<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                    $first = 0;
                }
                else {
                    $first = 1;
                }
            }
            else {
                if ( @$values[$i] ne "" ) {

                    # leader
                    if ( @$tags[$i] eq "000" ) {
                        $xml .= "<leader>@$values[$i]</leader>\n";
                        $first = 1;

                        # rest of the fixed fields
                    }
                    elsif ( @$tags[$i] < 10 ) {
                        $xml .=
"<controlfield tag=\"@$tags[$i]\">@$values[$i]</controlfield>\n";
                        $first = 1;
                    }
                    else {
                        my $ind1 = substr( @$indicator[$j], 0, 1 );
                        my $ind2 = substr( @$indicator[$j], 1, 1 );
                        $xml .=
"<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                        $xml .=
"<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                        $first = 0;
                    }
                }
            }
        }
        else {    # @$tags[$i] eq $prevtag
            if ( @$values[$i] eq "" ) {
            }
            else {
                if ($first) {
                    my $ind1 = substr( @$indicator[$j], 0, 1 );
                    my $ind2 = substr( @$indicator[$j], 1, 1 );
                    $xml .=
"<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                    $first = 0;
                }
                $xml .=
"<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
            }
        }
        $prevtag = @$tags[$i];
    }
    if (C4::Context->preference('marcflavour') and !$unimarc_and_100_exist) {
#     warn "SETTING 100 for $auth_type";
        use POSIX qw(strftime);
        my $string = strftime( "%Y%m%d", localtime(time) );
        # set 50 to position 26 is biblios, 13 if authorities
        my $pos=26;
        $pos=13 if $auth_type eq 'UNIMARCAUTH';
        $string = sprintf( "%-*s", 35, $string );
        substr( $string, $pos , 6, "50" );
        $xml .= "<datafield tag=\"100\" ind1=\"\" ind2=\"\">\n";
        $xml .= "<subfield code=\"a\">$string</subfield>\n";
        $xml .= "</datafield>\n";
    }
    $xml .= MARC::File::XML::footer();
    return $xml;
}

=head2 TransformHtmlToMarc

    L<$record> = TransformHtmlToMarc(L<$params>,L<$cgi>)
    L<$params> is a ref to an array as below:
    {
        'tag_010_indicator_531951' ,
        'tag_010_code_a_531951_145735' ,
        'tag_010_subfield_a_531951_145735' ,
        'tag_200_indicator_873510' ,
        'tag_200_code_a_873510_673465' ,
        'tag_200_subfield_a_873510_673465' ,
        'tag_200_code_b_873510_704318' ,
        'tag_200_subfield_b_873510_704318' ,
        'tag_200_code_e_873510_280822' ,
        'tag_200_subfield_e_873510_280822' ,
        'tag_200_code_f_873510_110730' ,
        'tag_200_subfield_f_873510_110730' ,
    }
    L<$cgi> is the CGI object which containts the value.
    L<$record> is the MARC::Record object.

=cut

sub TransformHtmlToMarc {
    my $params = shift;
    my $cgi    = shift;
    
    # creating a new record
    my $record  = MARC::Record->new();
    my $i=0;
    my @fields;
    while ($params->[$i]){ # browse all CGI params
        my $param = $params->[$i];
        my $newfield=0;
        # if we are on biblionumber, store it in the MARC::Record (it may not be in the edited fields)
        if ($param eq 'biblionumber') {
            my ( $biblionumbertagfield, $biblionumbertagsubfield ) =
                &GetMarcFromKohaField( "biblio.biblionumber", '' );
            if ($biblionumbertagfield < 10) {
                $newfield = MARC::Field->new(
                    $biblionumbertagfield,
                    $cgi->param($param),
                );
            } else {
                $newfield = MARC::Field->new(
                    $biblionumbertagfield,
                    '',
                    '',
                    "$biblionumbertagsubfield" => $cgi->param($param),
                );
            }
            push @fields,$newfield if($newfield);
        } 
        elsif ($param =~ /^tag_(\d*)_indicator_/){ # new field start when having 'input name="..._indicator_..."
            my $tag  = $1;
            
            my $ind1 = substr($cgi->param($param),0,1);
            my $ind2 = substr($cgi->param($param),1,1);
            $newfield=0;
            my $j=$i+1;
            
            if($tag < 10){ # no code for theses fields
    # in MARC editor, 000 contains the leader.
                if ($tag eq '000' ) {
                    $record->leader($cgi->param($params->[$j+1])) if length($cgi->param($params->[$j+1]))==24;
    # between 001 and 009 (included)
                } else {
                    $newfield = MARC::Field->new(
                        $tag,
                        $cgi->param($params->[$j+1]),
                    );
                }
    # > 009, deal with subfields
            } else {
                while($params->[$j] =~ /_code_/){ # browse all it's subfield
                    my $inner_param = $params->[$j];
                    if ($newfield){
                        if($cgi->param($params->[$j+1])){  # only if there is a value (code => value)
                            $newfield->add_subfields(
                                $cgi->param($inner_param) => $cgi->param($params->[$j+1])
                            );
                        }
                    } else {
                        if ( $cgi->param($params->[$j+1]) ) { # creating only if there is a value (code => value)
                            $newfield = MARC::Field->new(
                                $tag,
                                ''.$ind1,
                                ''.$ind2,
                                $cgi->param($inner_param) => $cgi->param($params->[$j+1]),
                            );
                        }
                    }
                    $j+=2;
                }
            }
            push @fields,$newfield if($newfield);
        }
        $i++;
    }
    
    $record->append_fields(@fields);
    return $record;
}

=head2 TransformMarcToKoha

=over 4

	$result = TransformMarcToKoha( $dbh, $record, $frameworkcode )

=back

=cut

sub TransformMarcToKoha {
    my ( $dbh, $record, $frameworkcode, $table ) = @_;

    my $result;

    # sometimes we only want to return the items data
    if ($table eq 'items') {
        my $sth = $dbh->prepare("SHOW COLUMNS FROM items");
        $sth->execute();
        while ( (my $field) = $sth->fetchrow ) {
            my $value = get_koha_field_from_marc($table,$field,$record,$frameworkcode);
            my $key = _disambiguate($table, $field);
            if ($result->{$key}) {
                $result->{$key} .= " | " . $value;
            } else {
                $result->{$key} = $value;
            }
        }
        return $result;
    } else {
        my @tables = ('biblio','biblioitems','items');
        foreach my $table (@tables){
            my $sth2 = $dbh->prepare("SHOW COLUMNS from $table");
            $sth2->execute;
            while (my ($field) = $sth2->fetchrow){
                # FIXME use of _disambiguate is a temporary hack
                # $result->{_disambiguate($table, $field)} = get_koha_field_from_marc($table,$field,$record,$frameworkcode);
                my $value = get_koha_field_from_marc($table,$field,$record,$frameworkcode);
                my $key = _disambiguate($table, $field);
                if ($result->{$key}) {
                    # FIXME - hack to not bring in duplicates of the same value
                    unless (($key eq "biblionumber" or $key eq "biblioitemnumber") and ($value eq "")) {
                        $result->{$key} .= " | " . $value;
                    }
                } else {
                    $result->{$key} = $value;
                }
            }
            $sth2->finish();
        }
        # modify copyrightdate to keep only the 1st year found
        my $temp = $result->{'copyrightdate'};
        $temp =~ m/c(\d\d\d\d)/;    # search cYYYY first
        if ( $1 > 0 ) {
            $result->{'copyrightdate'} = $1;
        }
        else {                      # if no cYYYY, get the 1st date.
            $temp =~ m/(\d\d\d\d)/;
            $result->{'copyrightdate'} = $1;
        }
    
        # modify publicationyear to keep only the 1st year found
        $temp = $result->{'publicationyear'};
        $temp =~ m/c(\d\d\d\d)/;    # search cYYYY first
        if ( $1 > 0 ) {
            $result->{'publicationyear'} = $1;
        }
        else {                      # if no cYYYY, get the 1st date.
            $temp =~ m/(\d\d\d\d)/;
            $result->{'publicationyear'} = $1;
        }
        return $result;
    }
}


=head2 _disambiguate

=over 4

$newkey = _disambiguate($table, $field);

This is a temporary hack to distinguish between the
following sets of columns when using TransformMarcToKoha.

items.cn_source & biblioitems.cn_source
items.cn_sort & biblioitems.cn_sort

Columns that are currently NOT distinguished (FIXME
due to lack of time to fully test) are:

biblio.notes and biblioitems.notes
biblionumber
timestamp
biblioitemnumber

FIXME - this is necessary because prefixing each column
name with the table name would require changing lots
of code and templates, and exposing more of the DB
structure than is good to the UI templates, particularly
since biblio and bibloitems may well merge in a future
version.  In the future, it would also be good to 
separate DB access and UI presentation field names
more.

=back

=cut

sub _disambiguate {
    my ($table, $column) = @_;
    if ($column eq "cn_sort" or $column eq "cn_source") {
        return $table . '.' . $column;
    } else {
        return $column;
    }

}

=head2 get_koha_field_from_marc

=over 4

$result->{_disambiguate($table, $field)} = get_koha_field_from_marc($table,$field,$record,$frameworkcode);

Internal function to map data from the MARC record to a specific non-MARC field.
FIXME: this is meant to replace TransformMarcToKohaOneField after more testing.

=back

=cut

sub get_koha_field_from_marc {
    my ($koha_table,$koha_column,$record,$frameworkcode) = @_;
    my ( $tagfield, $subfield ) = GetMarcFromKohaField( $koha_table.'.'.$koha_column, $frameworkcode );  
    my $kohafield;
    foreach my $field ( $record->field($tagfield) ) {
        if ( $field->tag() < 10 ) {
            if ( $kohafield ) {
                $kohafield .= " | " . $field->data();
            }
            else {
                $kohafield = $field->data();
            }
        }
        else {
            if ( $field->subfields ) {
                my @subfields = $field->subfields();
                foreach my $subfieldcount ( 0 .. $#subfields ) {
                    if ( $subfields[$subfieldcount][0] eq $subfield ) {
                        if ( $kohafield ) {
                            $kohafield .=
                              " | " . $subfields[$subfieldcount][1];
                        }
                        else {
                            $kohafield =
                              $subfields[$subfieldcount][1];
                        }
                    }
                }
            }
        }
    }
    return $kohafield;
} 


=head2 TransformMarcToKohaOneField

=over 4

$result = TransformMarcToKohaOneField( $kohatable, $kohafield, $record, $result, $frameworkcode )

=back

=cut

sub TransformMarcToKohaOneField {

    # FIXME ? if a field has a repeatable subfield that is used in old-db,
    # only the 1st will be retrieved...
    my ( $kohatable, $kohafield, $record, $result, $frameworkcode ) = @_;
    my $res = "";
    my ( $tagfield, $subfield ) =
      GetMarcFromKohaField( $kohatable . "." . $kohafield,
        $frameworkcode );
    foreach my $field ( $record->field($tagfield) ) {
        if ( $field->tag() < 10 ) {
            if ( $result->{$kohafield} ) {
                $result->{$kohafield} .= " | " . $field->data();
            }
            else {
                $result->{$kohafield} = $field->data();
            }
        }
        else {
            if ( $field->subfields ) {
                my @subfields = $field->subfields();
                foreach my $subfieldcount ( 0 .. $#subfields ) {
                    if ( $subfields[$subfieldcount][0] eq $subfield ) {
                        if ( $result->{$kohafield} ) {
                            $result->{$kohafield} .=
                              " | " . $subfields[$subfieldcount][1];
                        }
                        else {
                            $result->{$kohafield} =
                              $subfields[$subfieldcount][1];
                        }
                    }
                }
            }
        }
    }
    return $result;
}

=head1  OTHER FUNCTIONS

=head2 char_decode

=over 4

my $string = char_decode( $string, $encoding );

converts ISO 5426 coded string to UTF-8
sloppy code : should be improved in next issue

=back

=cut

sub char_decode {
    my ( $string, $encoding ) = @_;
    $_ = $string;

    $encoding = C4::Context->preference("marcflavour") unless $encoding;
    if ( $encoding eq "UNIMARC" ) {

        #         s/\xe1/Æ/gm;
        s/\xe2/Ğ/gm;
        s/\xe9/Ø/gm;
        s/\xec/ş/gm;
        s/\xf1/æ/gm;
        s/\xf3/ğ/gm;
        s/\xf9/ø/gm;
        s/\xfb/ß/gm;
        s/\xc1\x61/à/gm;
        s/\xc1\x65/è/gm;
        s/\xc1\x69/ì/gm;
        s/\xc1\x6f/ò/gm;
        s/\xc1\x75/ù/gm;
        s/\xc1\x41/À/gm;
        s/\xc1\x45/È/gm;
        s/\xc1\x49/Ì/gm;
        s/\xc1\x4f/Ò/gm;
        s/\xc1\x55/Ù/gm;
        s/\xc2\x41/Á/gm;
        s/\xc2\x45/É/gm;
        s/\xc2\x49/Í/gm;
        s/\xc2\x4f/Ó/gm;
        s/\xc2\x55/Ú/gm;
        s/\xc2\x59/İ/gm;
        s/\xc2\x61/á/gm;
        s/\xc2\x65/é/gm;
        s/\xc2\x69/í/gm;
        s/\xc2\x6f/ó/gm;
        s/\xc2\x75/ú/gm;
        s/\xc2\x79/ı/gm;
        s/\xc3\x41/Â/gm;
        s/\xc3\x45/Ê/gm;
        s/\xc3\x49/Î/gm;
        s/\xc3\x4f/Ô/gm;
        s/\xc3\x55/Û/gm;
        s/\xc3\x61/â/gm;
        s/\xc3\x65/ê/gm;
        s/\xc3\x69/î/gm;
        s/\xc3\x6f/ô/gm;
        s/\xc3\x75/û/gm;
        s/\xc4\x41/Ã/gm;
        s/\xc4\x4e/Ñ/gm;
        s/\xc4\x4f/Õ/gm;
        s/\xc4\x61/ã/gm;
        s/\xc4\x6e/ñ/gm;
        s/\xc4\x6f/õ/gm;
        s/\xc8\x41/Ä/gm;
        s/\xc8\x45/Ë/gm;
        s/\xc8\x49/Ï/gm;
        s/\xc8\x61/ä/gm;
        s/\xc8\x65/ë/gm;
        s/\xc8\x69/ï/gm;
        s/\xc8\x6F/ö/gm;
        s/\xc8\x75/ü/gm;
        s/\xc8\x76/ÿ/gm;
        s/\xc9\x41/Ä/gm;
        s/\xc9\x45/Ë/gm;
        s/\xc9\x49/Ï/gm;
        s/\xc9\x4f/Ö/gm;
        s/\xc9\x55/Ü/gm;
        s/\xc9\x61/ä/gm;
        s/\xc9\x6f/ö/gm;
        s/\xc9\x75/ü/gm;
        s/\xca\x41/Å/gm;
        s/\xca\x61/å/gm;
        s/\xd0\x43/Ç/gm;
        s/\xd0\x63/ç/gm;

        # this handles non-sorting blocks (if implementation requires this)
        $string = nsb_clean($_);
    }
    elsif ( $encoding eq "USMARC" || $encoding eq "MARC21" ) {
        ##MARC-8 to UTF-8

        s/\xe1\x61/à/gm;
        s/\xe1\x65/è/gm;
        s/\xe1\x69/ì/gm;
        s/\xe1\x6f/ò/gm;
        s/\xe1\x75/ù/gm;
        s/\xe1\x41/À/gm;
        s/\xe1\x45/È/gm;
        s/\xe1\x49/Ì/gm;
        s/\xe1\x4f/Ò/gm;
        s/\xe1\x55/Ù/gm;
        s/\xe2\x41/Á/gm;
        s/\xe2\x45/É/gm;
        s/\xe2\x49/Í/gm;
        s/\xe2\x4f/Ó/gm;
        s/\xe2\x55/Ú/gm;
        s/\xe2\x59/İ/gm;
        s/\xe2\x61/á/gm;
        s/\xe2\x65/é/gm;
        s/\xe2\x69/í/gm;
        s/\xe2\x6f/ó/gm;
        s/\xe2\x75/ú/gm;
        s/\xe2\x79/ı/gm;
        s/\xe3\x41/Â/gm;
        s/\xe3\x45/Ê/gm;
        s/\xe3\x49/Î/gm;
        s/\xe3\x4f/Ô/gm;
        s/\xe3\x55/Û/gm;
        s/\xe3\x61/â/gm;
        s/\xe3\x65/ê/gm;
        s/\xe3\x69/î/gm;
        s/\xe3\x6f/ô/gm;
        s/\xe3\x75/û/gm;
        s/\xe4\x41/Ã/gm;
        s/\xe4\x4e/Ñ/gm;
        s/\xe4\x4f/Õ/gm;
        s/\xe4\x61/ã/gm;
        s/\xe4\x6e/ñ/gm;
        s/\xe4\x6f/õ/gm;
        s/\xe6\x41/Ă/gm;
        s/\xe6\x45/Ĕ/gm;
        s/\xe6\x65/ĕ/gm;
        s/\xe6\x61/ă/gm;
        s/\xe8\x45/Ë/gm;
        s/\xe8\x49/Ï/gm;
        s/\xe8\x65/ë/gm;
        s/\xe8\x69/ï/gm;
        s/\xe8\x76/ÿ/gm;
        s/\xe9\x41/A/gm;
        s/\xe9\x4f/O/gm;
        s/\xe9\x55/U/gm;
        s/\xe9\x61/a/gm;
        s/\xe9\x6f/o/gm;
        s/\xe9\x75/u/gm;
        s/\xea\x41/A/gm;
        s/\xea\x61/a/gm;

        #Additional Turkish characters
        s/\x1b//gm;
        s/\x1e//gm;
        s/(\xf0)s/\xc5\x9f/gm;
        s/(\xf0)S/\xc5\x9e/gm;
        s/(\xf0)c/ç/gm;
        s/(\xf0)C/Ç/gm;
        s/\xe7\x49/\\xc4\xb0/gm;
        s/(\xe6)G/\xc4\x9e/gm;
        s/(\xe6)g/ğ\xc4\x9f/gm;
        s/\xB8/ı/gm;
        s/\xB9/£/gm;
        s/(\xe8|\xc8)o/ö/gm;
        s/(\xe8|\xc8)O/Ö/gm;
        s/(\xe8|\xc8)u/ü/gm;
        s/(\xe8|\xc8)U/Ü/gm;
        s/\xc2\xb8/\xc4\xb1/gm;
        s/¸/\xc4\xb1/gm;

        # this handles non-sorting blocks (if implementation requires this)
        $string = nsb_clean($_);
    }
    return ($string);
}

=head2 nsb_clean

=over 4

my $string = nsb_clean( $string, $encoding );

=back

=cut

sub nsb_clean {
    my $NSB      = '\x88';    # NSB : begin Non Sorting Block
    my $NSE      = '\x89';    # NSE : Non Sorting Block end
                              # handles non sorting blocks
    my ($string) = @_;
    $_ = $string;
    s/$NSB/(/gm;
    s/[ ]{0,1}$NSE/) /gm;
    $string = $_;
    return ($string);
}

=head2 PrepareItemrecordDisplay

=over 4

PrepareItemrecordDisplay($itemrecord,$bibnum,$itemumber);

Returns a hash with all the fields for Display a given item data in a template

=back

=cut

sub PrepareItemrecordDisplay {

    my ( $bibnum, $itemnum ) = @_;

    my $dbh = C4::Context->dbh;
    my $frameworkcode = &GetFrameworkCode( $bibnum );
    my ( $itemtagfield, $itemtagsubfield ) =
      &GetMarcFromKohaField( "items.itemnumber", $frameworkcode );
    my $tagslib = &GetMarcStructure( 1, $frameworkcode );
    my $itemrecord = GetMarcItem( $bibnum, $itemnum) if ($itemnum);
    my @loop_data;
    my $authorised_values_sth =
      $dbh->prepare(
"SELECT authorised_value,lib FROM authorised_values WHERE category=? ORDER BY lib"
      );
    foreach my $tag ( sort keys %{$tagslib} ) {
        my $previous_tag = '';
        if ( $tag ne '' ) {
            # loop through each subfield
            my $cntsubf;
            foreach my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
                next if ( subfield_is_koha_internal_p($subfield) );
                next if ( $tagslib->{$tag}->{$subfield}->{'tab'} ne "10" );
                my %subfield_data;
                $subfield_data{tag}           = $tag;
                $subfield_data{subfield}      = $subfield;
                $subfield_data{countsubfield} = $cntsubf++;
                $subfield_data{kohafield}     =
                  $tagslib->{$tag}->{$subfield}->{'kohafield'};

         #        $subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
                $subfield_data{marc_lib} =
                    "<span id=\"error\" title=\""
                  . $tagslib->{$tag}->{$subfield}->{lib} . "\">"
                  . substr( $tagslib->{$tag}->{$subfield}->{lib}, 0, 12 )
                  . "</span>";
                $subfield_data{mandatory} =
                  $tagslib->{$tag}->{$subfield}->{mandatory};
                $subfield_data{repeatable} =
                  $tagslib->{$tag}->{$subfield}->{repeatable};
                $subfield_data{hidden} = "display:none"
                  if $tagslib->{$tag}->{$subfield}->{hidden};
                my ( $x, $value );
                ( $x, $value ) = _find_value( $tag, $subfield, $itemrecord )
                  if ($itemrecord);
                $value =~ s/"/&quot;/g;

                # search for itemcallnumber if applicable
                if ( $tagslib->{$tag}->{$subfield}->{kohafield} eq
                    'items.itemcallnumber'
                    && C4::Context->preference('itemcallnumber') )
                {
                    my $CNtag =
                      substr( C4::Context->preference('itemcallnumber'), 0, 3 );
                    my $CNsubfield =
                      substr( C4::Context->preference('itemcallnumber'), 3, 1 );
                    my $temp = $itemrecord->field($CNtag) if ($itemrecord);
                    if ($temp) {
                        $value = $temp->subfield($CNsubfield);
                    }
                }
                if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
                    my @authorised_values;
                    my %authorised_lib;

                    # builds list, depending on authorised value...
                    #---- branch
                    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq
                        "branches" )
                    {
                        if ( ( C4::Context->preference("IndependantBranches") )
                            && ( C4::Context->userenv->{flags} != 1 ) )
                        {
                            my $sth =
                              $dbh->prepare(
								"SELECT branchcode,branchname FROM branches WHERE branchcode = ? ORDER BY branchname"
                              );
                            $sth->execute( C4::Context->userenv->{branch} );
                            push @authorised_values, ""
                              unless (
                                $tagslib->{$tag}->{$subfield}->{mandatory} );
                            while ( my ( $branchcode, $branchname ) =
                                $sth->fetchrow_array )
                            {
                                push @authorised_values, $branchcode;
                                $authorised_lib{$branchcode} = $branchname;
                            }
                        }
                        else {
                            my $sth =
                              $dbh->prepare(
								"SELECT branchcode,branchname FROM branches ORDER BY branchname"
                              );
                            $sth->execute;
                            push @authorised_values, ""
                              unless (
                                $tagslib->{$tag}->{$subfield}->{mandatory} );
                            while ( my ( $branchcode, $branchname ) =
                                $sth->fetchrow_array )
                            {
                                push @authorised_values, $branchcode;
                                $authorised_lib{$branchcode} = $branchname;
                            }
                        }

                        #----- itemtypes
                    }
                    elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq
                        "itemtypes" )
                    {
                        my $sth =
                          $dbh->prepare(
						  	"SELECT itemtype,description FROM itemtypes ORDER BY description"
                          );
                        $sth->execute;
                        push @authorised_values, ""
                          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
                        while ( my ( $itemtype, $description ) =
                            $sth->fetchrow_array )
                        {
                            push @authorised_values, $itemtype;
                            $authorised_lib{$itemtype} = $description;
                        }

                        #---- "true" authorised value
                    }
                    else {
                        $authorised_values_sth->execute(
                            $tagslib->{$tag}->{$subfield}->{authorised_value} );
                        push @authorised_values, ""
                          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
                        while ( my ( $value, $lib ) =
                            $authorised_values_sth->fetchrow_array )
                        {
                            push @authorised_values, $value;
                            $authorised_lib{$value} = $lib;
                        }
                    }
                    $subfield_data{marc_value} = CGI::scrolling_list(
                        -name     => 'field_value',
                        -values   => \@authorised_values,
                        -default  => "$value",
                        -labels   => \%authorised_lib,
                        -size     => 1,
                        -tabindex => '',
                        -multiple => 0,
                    );
                }
                elsif ( $tagslib->{$tag}->{$subfield}->{thesaurus_category} ) {
                    $subfield_data{marc_value} =
"<input type=\"text\" name=\"field_value\"  size=47 maxlength=255> <a href=\"javascript:Dopop('cataloguing/thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=',)\">...</a>";

#"
# COMMENTED OUT because No $i is provided with this API.
# And thus, no value_builder can be activated.
# BUT could be thought over.
#         } elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
#             my $plugin="value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
#             require $plugin;
#             my $extended_param = plugin_parameters($dbh,$itemrecord,$tagslib,$i,0);
#             my ($function_name,$javascript) = plugin_javascript($dbh,$record,$tagslib,$i,0);
#             $subfield_data{marc_value}="<input type=\"text\" value=\"$value\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY OnFocus=\"javascript:Focus$function_name()\" OnBlur=\"javascript:Blur$function_name()\"> <a href=\"javascript:Clic$function_name()\">...</a> $javascript";
                }
                else {
                    $subfield_data{marc_value} =
"<input type=\"text\" name=\"field_value\" value=\"$value\" size=50 maxlength=255>";
                }
                push( @loop_data, \%subfield_data );
            }
        }
    }
    my $itemnumber = $itemrecord->subfield( $itemtagfield, $itemtagsubfield )
      if ( $itemrecord && $itemrecord->field($itemtagfield) );
    return {
        'itemtagfield'    => $itemtagfield,
        'itemtagsubfield' => $itemtagsubfield,
        'itemnumber'      => $itemnumber,
        'iteminformation' => \@loop_data
    };
}
#"

#
# true ModZebra commented until indexdata fixes zebraDB crashes (it seems they occur on multiple updates
# at the same time
# replaced by a zebraqueue table, that is filled with ModZebra to run.
# the table is emptied by misc/cronjobs/zebraqueue_start.pl script
# =head2 ModZebrafiles
# 
# &ModZebrafiles( $dbh, $biblionumber, $record, $folder, $server );
# 
# =cut
# 
# sub ModZebrafiles {
# 
#     my ( $dbh, $biblionumber, $record, $folder, $server ) = @_;
# 
#     my $op;
#     my $zebradir =
#       C4::Context->zebraconfig($server)->{directory} . "/" . $folder . "/";
#     unless ( opendir( DIR, "$zebradir" ) ) {
#         warn "$zebradir not found";
#         return;
#     }
#     closedir DIR;
#     my $filename = $zebradir . $biblionumber;
# 
#     if ($record) {
#         open( OUTPUT, ">", $filename . ".xml" );
#         print OUTPUT $record;
#         close OUTPUT;
#     }
# }

=head2 ModZebra

=over 4

ModZebra( $biblionumber, $op, $server, $newRecord );

    $biblionumber is the biblionumber we want to index
    $op is specialUpdate or delete, and is used to know what we want to do
    $server is the server that we want to update
    $newRecord is the MARC::Record containing the new record. It is usefull only when NoZebra=1, and is used to know what to add to the nozebra database. (the record in mySQL being, if it exist, the previous record, the one just before the modif. We need both : the previous and the new one.
    
=back

=cut

sub ModZebra {
###Accepts a $server variable thus we can use it for biblios authorities or other zebra dbs
    my ( $biblionumber, $op, $server, $newRecord ) = @_;
    my $dbh=C4::Context->dbh;

    # true ModZebra commented until indexdata fixes zebraDB crashes (it seems they occur on multiple updates
    # at the same time
    # replaced by a zebraqueue table, that is filled with ModZebra to run.
    # the table is emptied by misc/cronjobs/zebraqueue_start.pl script

    if (C4::Context->preference("NoZebra")) {
        # lock the nozebra table : we will read index lines, update them in Perl process
        # and write everything in 1 transaction.
        # lock the table to avoid someone else overwriting what we are doing
        $dbh->do('LOCK TABLES nozebra WRITE,biblio WRITE,biblioitems WRITE, systempreferences WRITE, auth_types WRITE, auth_header WRITE');
        my %result; # the result hash that will be builded by deletion / add, and written on mySQL at the end, to improve speed
        my $record;
        if ($server eq 'biblioserver') {
            $record= GetMarcBiblio($biblionumber);
        } else {
            $record= C4::AuthoritiesMarc::GetAuthority($biblionumber);
        }
        if ($op eq 'specialUpdate') {
            # OK, we have to add or update the record
            # 1st delete (virtually, in indexes) ...
            %result = _DelBiblioNoZebra($biblionumber,$record,$server);
            # ... add the record
            %result=_AddBiblioNoZebra($biblionumber,$newRecord, $server, %result);
        } else {
            # it's a deletion, delete the record...
            # warn "DELETE the record $biblionumber on $server".$record->as_formatted;
            %result=_DelBiblioNoZebra($biblionumber,$record,$server);
        }
        # ok, now update the database...
        my $sth = $dbh->prepare("UPDATE nozebra SET biblionumbers=? WHERE server=? AND indexname=? AND value=?");
        foreach my $key (keys %result) {
            foreach my $index (keys %{$result{$key}}) {
                $sth->execute($result{$key}->{$index}, $server, $key, $index);
            }
        }
        $dbh->do('UNLOCK TABLES');

    } else {
        #
        # we use zebra, just fill zebraqueue table
        #
        my $sth=$dbh->prepare("INSERT INTO zebraqueue  (biblio_auth_number,server,operation) VALUES(?,?,?)");
        $sth->execute($biblionumber,$server,$op);
        $sth->finish;
    }
}

=head2 GetNoZebraIndexes

    %indexes = GetNoZebraIndexes;
    
    return the data from NoZebraIndexes syspref.

=cut

sub GetNoZebraIndexes {
    my $index = C4::Context->preference('NoZebraIndexes');
    my %indexes;
    foreach my $line (split /('|"),/,$index) {
        $line =~ /(.*)=>(.*)/;
        my $index = substr($1,1); # get the index, don't forget to remove initial ' or "
        my $fields = $2;
        $index =~ s/'|"| //g;
        $fields =~ s/'|"| //g;
        $indexes{$index}=$fields;
    }
    return %indexes;
}

=head1 INTERNAL FUNCTIONS

=head2 _DelBiblioNoZebra($biblionumber,$record,$server);

    function to delete a biblio in NoZebra indexes
    This function does NOT delete anything in database : it reads all the indexes entries
    that have to be deleted & delete them in the hash
    The SQL part is done either :
    - after the Add if we are modifying a biblio (delete + add again)
    - immediatly after this sub if we are doing a true deletion.
    $server can be 'biblioserver' or 'authorityserver' : it indexes biblios or authorities (in the same table, $server being part of the table itself

=cut


sub _DelBiblioNoZebra {
    my ($biblionumber, $record, $server)=@_;
    
    # Get the indexes
    my $dbh = C4::Context->dbh;
    # Get the indexes
    my %index;
    my $title;
    if ($server eq 'biblioserver') {
        %index=GetNoZebraIndexes;
        # get title of the record (to store the 10 first letters with the index)
        my ($titletag,$titlesubfield) = GetMarcFromKohaField('biblio.title');
        $title = lc($record->subfield($titletag,$titlesubfield));
    } else {
        # for authorities, the "title" is the $a mainentry
        my $authref = C4::AuthoritiesMarc::GetAuthType($record->subfield(152,'b'));
        warn "ERROR : authtype undefined for ".$record->as_formatted unless $authref;
        $title = $record->subfield($authref->{auth_tag_to_report},'a');
        $index{'mainmainentry'}= $authref->{'auth_tag_to_report'}.'a';
        $index{'mainentry'}    = $authref->{'auth_tag_to_report'}.'*';
        $index{'auth_type'}    = '152b';
    }
    
    my %result;
    # remove blancks comma (that could cause problem when decoding the string for CQL retrieval) and regexp specific values
    $title =~ s/ |,|;|\[|\]|\(|\)|\*|-|'|=//g;
    # limit to 10 char, should be enough, and limit the DB size
    $title = substr($title,0,10);
    #parse each field
    my $sth2=$dbh->prepare('SELECT biblionumbers FROM nozebra WHERE server=? AND indexname=? AND value=?');
    foreach my $field ($record->fields()) {
        #parse each subfield
        next if $field->tag <10;
        foreach my $subfield ($field->subfields()) {
            my $tag = $field->tag();
            my $subfieldcode = $subfield->[0];
            my $indexed=0;
            # check each index to see if the subfield is stored somewhere
            # otherwise, store it in __RAW__ index
            foreach my $key (keys %index) {
#                 warn "examining $key index : ".$index{$key}." for $tag $subfieldcode";
                if ($index{$key} =~ /$tag\*/ or $index{$key} =~ /$tag$subfieldcode/) {
                    $indexed=1;
                    my $line= lc $subfield->[1];
                    # remove meaningless value in the field...
                    $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:/ /g;
                    # ... and split in words
                    foreach (split / /,$line) {
                        next unless $_; # skip  empty values (multiple spaces)
                        # if the entry is already here, do nothing, the biblionumber has already be removed
                        unless ($result{$key}->{$_} =~ /$biblionumber,$title\-(\d);/) {
                            # get the index value if it exist in the nozebra table and remove the entry, otherwise, do nothing
                            $sth2->execute($server,$key,$_);
                            my $existing_biblionumbers = $sth2->fetchrow;
                            # it exists
                            if ($existing_biblionumbers) {
#                                 warn " existing for $key $_: $existing_biblionumbers";
                                $result{$key}->{$_} =$existing_biblionumbers;
                                $result{$key}->{$_} =~ s/$biblionumber,$title\-(\d);//;
                            }
                        }
                    }
                }
            }
            # the subfield is not indexed, store it in __RAW__ index anyway
            unless ($indexed) {
                my $line= lc $subfield->[1];
                $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:/ /g;
                # ... and split in words
                foreach (split / /,$line) {
                    next unless $_; # skip  empty values (multiple spaces)
                    # if the entry is already here, do nothing, the biblionumber has already be removed
                    unless ($result{'__RAW__'}->{$_} =~ /$biblionumber,$title\-(\d);/) {
                        # get the index value if it exist in the nozebra table and remove the entry, otherwise, do nothing
                        $sth2->execute($server,'__RAW__',$_);
                        my $existing_biblionumbers = $sth2->fetchrow;
                        # it exists
                        if ($existing_biblionumbers) {
                            $result{'__RAW__'}->{$_} =$existing_biblionumbers;
                            $result{'__RAW__'}->{$_} =~ s/$biblionumber,$title\-(\d);//;
                        }
                    }
                }
            }
        }
    }
    return %result;
}

=head2 _AddBiblioNoZebra($biblionumber, $record, $server, %result);

    function to add a biblio in NoZebra indexes

=cut

sub _AddBiblioNoZebra {
    my ($biblionumber, $record, $server, %result)=@_;
    my $dbh = C4::Context->dbh;
    # Get the indexes
    my %index;
    my $title;
    if ($server eq 'biblioserver') {
        %index=GetNoZebraIndexes;
        # get title of the record (to store the 10 first letters with the index)
        my ($titletag,$titlesubfield) = GetMarcFromKohaField('biblio.title');
        $title = lc($record->subfield($titletag,$titlesubfield));
    } else {
        # warn "server : $server";
        # for authorities, the "title" is the $a mainentry
        my $authref = C4::AuthoritiesMarc::GetAuthType($record->subfield(152,'b'));
        warn "ERROR : authtype undefined for ".$record->as_formatted unless $authref;
        $title = $record->subfield($authref->{auth_tag_to_report},'a');
        $index{'mainmainentry'} = $authref->{auth_tag_to_report}.'a';
        $index{'mainentry'}     = $authref->{auth_tag_to_report}.'*';
        $index{'auth_type'}     = '152b';
    }

    # remove blancks comma (that could cause problem when decoding the string for CQL retrieval) and regexp specific values
    $title =~ s/ |,|;|\[|\]|\(|\)|\*|-|'|=//g;
    # limit to 10 char, should be enough, and limit the DB size
    $title = substr($title,0,10);
    #parse each field
    my $sth2=$dbh->prepare('SELECT biblionumbers FROM nozebra WHERE server=? AND indexname=? AND value=?');
    foreach my $field ($record->fields()) {
        #parse each subfield
        next if $field->tag <10;
        foreach my $subfield ($field->subfields()) {
            my $tag = $field->tag();
            my $subfieldcode = $subfield->[0];
            my $indexed=0;
            # check each index to see if the subfield is stored somewhere
            # otherwise, store it in __RAW__ index
            foreach my $key (keys %index) {
#                 warn "examining $key index : ".$index{$key}." for $tag $subfieldcode";
                if ($index{$key} =~ /$tag\*/ or $index{$key} =~ /$tag$subfieldcode/) {
                    $indexed=1;
                    my $line= lc $subfield->[1];
                    # remove meaningless value in the field...
                    $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:/ /g;
                    # ... and split in words
                    foreach (split / /,$line) {
                        next unless $_; # skip  empty values (multiple spaces)
                        # if the entry is already here, improve weight
#                         warn "managing $_";
                        if ($result{$key}->{"$_"} =~ /$biblionumber,$title\-(\d);/) {
                            my $weight=$1+1;
                            $result{$key}->{"$_"} =~ s/$biblionumber,$title\-(\d);//;
                            $result{$key}->{"$_"} .= "$biblionumber,$title-$weight;";
                        } else {
                            # get the value if it exist in the nozebra table, otherwise, create it
                            $sth2->execute($server,$key,$_);
                            my $existing_biblionumbers = $sth2->fetchrow;
                            # it exists
                            if ($existing_biblionumbers) {
                                $result{$key}->{"$_"} =$existing_biblionumbers;
                                my $weight=$1+1;
                                $result{$key}->{"$_"} =~ s/$biblionumber,$title\-(\d);//;
                                $result{$key}->{"$_"} .= "$biblionumber,$title-$weight;";
                            # create a new ligne for this entry
                            } else {
#                             warn "INSERT : $server / $key / $_";
                                $dbh->do('INSERT INTO nozebra SET server='.$dbh->quote($server).', indexname='.$dbh->quote($key).',value='.$dbh->quote($_));
                                $result{$key}->{"$_"}.="$biblionumber,$title-1;";
                            }
                        }
                    }
                }
            }
            # the subfield is not indexed, store it in __RAW__ index anyway
            unless ($indexed) {
                my $line= lc $subfield->[1];
                $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:/ /g;
                # ... and split in words
                foreach (split / /,$line) {
                    next unless $_; # skip  empty values (multiple spaces)
                    # if the entry is already here, improve weight
                    if ($result{'__RAW__'}->{"$_"} =~ /$biblionumber,$title\-(\d);/) {
                        my $weight=$1+1;
                        $result{'__RAW__'}->{"$_"} =~ s/$biblionumber,$title\-(\d);//;
                        $result{'__RAW__'}->{"$_"} .= "$biblionumber,$title-$weight;";
                    } else {
                        # get the value if it exist in the nozebra table, otherwise, create it
                        $sth2->execute($server,'__RAW__',$_);
                        my $existing_biblionumbers = $sth2->fetchrow;
                        # it exists
                        if ($existing_biblionumbers) {
                            $result{'__RAW__'}->{"$_"} =$existing_biblionumbers;
                            my $weight=$1+1;
                            $result{'__RAW__'}->{"$_"} =~ s/$biblionumber,$title\-(\d);//;
                            $result{'__RAW__'}->{"$_"} .= "$biblionumber,$title-$weight;";
                        # create a new ligne for this entry
                        } else {
                            $dbh->do('INSERT INTO nozebra SET server='.$dbh->quote($server).',  indexname="__RAW__",value='.$dbh->quote($_));
                            $result{'__RAW__'}->{"$_"}.="$biblionumber,$title-1;";
                        }
                    }
                }
            }
        }
    }
    return %result;
}


=head2 MARCitemchange

=over 4

&MARCitemchange( $record, $itemfield, $newvalue )

Function to update a single value in an item field.
Used twice, could probably be replaced by something else, but works well...

=back

=back

=cut

sub MARCitemchange {
    my ( $record, $itemfield, $newvalue ) = @_;
    my $dbh = C4::Context->dbh;
    
    my ( $tagfield, $tagsubfield ) =
      GetMarcFromKohaField( $itemfield, "" );
    if ( ($tagfield) && ($tagsubfield) ) {
        my $tag = $record->field($tagfield);
        if ($tag) {
            $tag->update( $tagsubfield => $newvalue );
            $record->delete_field($tag);
            $record->insert_fields_ordered($tag);
        }
    }
}
=head2 _find_value

=over 4

($indicators, $value) = _find_value($tag, $subfield, $record,$encoding);

Find the given $subfield in the given $tag in the given
MARC::Record $record.  If the subfield is found, returns
the (indicators, value) pair; otherwise, (undef, undef) is
returned.

PROPOSITION :
Such a function is used in addbiblio AND additem and serial-edit and maybe could be used in Authorities.
I suggest we export it from this module.

=back

=cut

sub _find_value {
    my ( $tagfield, $insubfield, $record, $encoding ) = @_;
    my @result;
    my $indicator;
    if ( $tagfield < 10 ) {
        if ( $record->field($tagfield) ) {
            push @result, $record->field($tagfield)->data();
        }
        else {
            push @result, "";
        }
    }
    else {
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

=head2 _koha_marc_update_bib_ids

=over 4

_koha_marc_update_bib_ids($record, $frameworkcode, $biblionumber, $biblioitemnumber);

Internal function to add or update biblionumber and biblioitemnumber to
the MARC XML.

=back

=cut

sub _koha_marc_update_bib_ids {
    my ($record, $frameworkcode, $biblionumber, $biblioitemnumber) = @_;

    # we must add bibnum and bibitemnum in MARC::Record...
    # we build the new field with biblionumber and biblioitemnumber
    # we drop the original field
    # we add the new builded field.
    my ($biblio_tag, $biblio_subfield ) = GetMarcFromKohaField("biblio.biblionumber",$frameworkcode);
    my ($biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField("biblioitems.biblioitemnumber",$frameworkcode);

    if ($biblio_tag != $biblioitem_tag) {
        # biblionumber & biblioitemnumber are in different fields

        # deal with biblionumber
        my ($new_field, $old_field);
        if ($biblio_tag < 10) {
            $new_field = MARC::Field->new( $biblio_tag, $biblionumber );
        } else {
            $new_field =
              MARC::Field->new( $biblio_tag, '', '',
                "$biblio_subfield" => $biblionumber );
        }

        # drop old field and create new one...
        $old_field = $record->field($biblio_tag);
        $record->delete_field($old_field);
        $record->append_fields($new_field);

        # deal with biblioitemnumber
        if ($biblioitem_tag < 10) {
            $new_field = MARC::Field->new( $biblioitem_tag, $biblioitemnumber, );
        } else {
            $new_field =
              MARC::Field->new( $biblioitem_tag, '', '',
                "$biblioitem_subfield" => $biblioitemnumber, );
        }
        # drop old field and create new one...
        $old_field = $record->field($biblioitem_tag);
        $record->delete_field($old_field);
        $record->insert_fields_ordered($new_field);

    } else {
        # biblionumber & biblioitemnumber are in the same field (can't be <10 as fields <10 have only 1 value)
        my $new_field = MARC::Field->new(
            $biblio_tag, '', '',
            "$biblio_subfield" => $biblionumber,
            "$biblioitem_subfield" => $biblioitemnumber
        );

        # drop old field and create new one...
        my $old_field = $record->field($biblio_tag);
        $record->delete_field($old_field);
        $record->insert_fields_ordered($new_field);
    }
}

=head2 _koha_add_biblio

=over 4

my ($biblionumber,$error) = _koha_add_biblio($dbh,$biblioitem);

Internal function to add a biblio ($biblio is a hash with the values)

=back

=cut

sub _koha_add_biblio {
    my ( $dbh, $biblio, $frameworkcode ) = @_;

	my $error;

	# set the series flag
    my $serial = 0;
    if ( $biblio->{'seriestitle'} ) { $serial = 1 };

	my $query = 
        "INSERT INTO biblio
		SET frameworkcode = ?,
			author = ?,
			title = ?,
			unititle =?,
			notes = ?,
			serial = ?,
			seriestitle = ?,
			copyrightdate = ?,
			datecreated=NOW(),
			abstract = ?
		";
    my $sth = $dbh->prepare($query);
    $sth->execute(
		$frameworkcode,
        $biblio->{'author'},
        $biblio->{'title'},
		$biblio->{'unititle'},
        $biblio->{'notes'},
		$serial,
        $biblio->{'seriestitle'},
		$biblio->{'copyrightdate'},
        $biblio->{'abstract'}
    );

    my $biblionumber = $dbh->{'mysql_insertid'};
	if ( $dbh->errstr ) {
		$error.="ERROR in _koha_add_biblio $query".$dbh->errstr;
        warn $error;
    }

    $sth->finish();
	#warn "LEAVING _koha_add_biblio: ".$biblionumber."\n";
    return ($biblionumber,$error);
}

=head2 _koha_modify_biblio

=over 4

my ($biblionumber,$error) == _koha_modify_biblio($dbh,$biblio,$frameworkcode);

Internal function for updating the biblio table

=back

=cut

sub _koha_modify_biblio {
    my ( $dbh, $biblio, $frameworkcode ) = @_;
	my $error;

    my $query = "
        UPDATE biblio
        SET    frameworkcode = ?,
			   author = ?,
			   title = ?,
			   unititle = ?,
			   notes = ?,
			   serial = ?,
			   seriestitle = ?,
			   copyrightdate = ?,
               abstract = ?
        WHERE  biblionumber = ?
		"
	;
    my $sth = $dbh->prepare($query);
    
    $sth->execute(
		$frameworkcode,
        $biblio->{'author'},
        $biblio->{'title'},
        $biblio->{'unititle'},
        $biblio->{'notes'},
        $biblio->{'serial'},
        $biblio->{'seriestitle'},
        $biblio->{'copyrightdate'},
		$biblio->{'abstract'},
        $biblio->{'biblionumber'}
    ) if $biblio->{'biblionumber'};

    if ( $dbh->errstr || !$biblio->{'biblionumber'} ) {
		$error.="ERROR in _koha_modify_biblio $query".$dbh->errstr;
        warn $error;
    }
    return ( $biblio->{'biblionumber'},$error );
}

=head2 _koha_modify_biblioitem_nonmarc

=over 4

my ($biblioitemnumber,$error) = _koha_modify_biblioitem_nonmarc( $dbh, $biblioitem );

Updates biblioitems row except for marc and marcxml, which should be changed
via ModBiblioMarc

=back

=cut

sub _koha_modify_biblioitem_nonmarc {
    my ( $dbh, $biblioitem ) = @_;
	my $error;

	# re-calculate the cn_sort, it may have changed
	my ($cn_sort) = GetClassSort($biblioitem->{'biblioitems.cn_source'}, $biblioitem->{'cn_class'}, $biblioitem->{'cn_item'} );

	my $query = 
	"UPDATE biblioitems 
	SET biblionumber	= ?,
		volume			= ?,
		number			= ?,
        itemtype        = ?,
        isbn            = ?,
        issn            = ?,
		publicationyear = ?,
        publishercode   = ?,
		volumedate     	= ?,
		volumedesc     	= ?,
		collectiontitle = ?,
		collectionissn  = ?,
		collectionvolume= ?,
		editionstatement= ?,
		editionresponsibility = ?,
		illus     		= ?,
		pages     		= ?,
		notes     		= ?,
		size     		= ?,
		place     		= ?,
		lccn     		= ?,
		url     		= ?,
        cn_source  		= ?,
        cn_class        = ?,
        cn_item        	= ?,
		cn_suffix       = ?,
		cn_sort        	= ?,
		totalissues     = ?
        where biblioitemnumber = ?
		";
	my $sth = $dbh->prepare($query);
	$sth->execute(
		$biblioitem->{'biblionumber'},
		$biblioitem->{'volume'},
		$biblioitem->{'number'},
		$biblioitem->{'itemtype'},
		$biblioitem->{'isbn'},
		$biblioitem->{'issn'},
		$biblioitem->{'publicationyear'},
		$biblioitem->{'publishercode'},
		$biblioitem->{'volumedate'},
		$biblioitem->{'volumedesc'},
		$biblioitem->{'collectiontitle'},
		$biblioitem->{'collectionissn'},
		$biblioitem->{'collectionvolume'},
		$biblioitem->{'editionstatement'},
		$biblioitem->{'editionresponsibility'},
		$biblioitem->{'illus'},
		$biblioitem->{'pages'},
		$biblioitem->{'bnotes'},
		$biblioitem->{'size'},
		$biblioitem->{'place'},
		$biblioitem->{'lccn'},
		$biblioitem->{'url'},
		$biblioitem->{'biblioitems.cn_source'},
		$biblioitem->{'cn_class'},
		$biblioitem->{'cn_item'},
		$biblioitem->{'cn_suffix'},
		$cn_sort,
		$biblioitem->{'totalissues'},
		$biblioitem->{'biblioitemnumber'}
	);
    if ( $dbh->errstr ) {
		$error.="ERROR in _koha_modify_biblioitem_nonmarc $query".$dbh->errstr;
        warn $error;
    }
	return ($biblioitem->{'biblioitemnumber'},$error);
}

=head2 _koha_add_biblioitem

=over 4

my ($biblioitemnumber,$error) = _koha_add_biblioitem( $dbh, $biblioitem );

Internal function to add a biblioitem

=back

=cut

sub _koha_add_biblioitem {
    my ( $dbh, $biblioitem ) = @_;
	my $error;

	my ($cn_sort) = GetClassSort($biblioitem->{'biblioitems.cn_source'}, $biblioitem->{'cn_class'}, $biblioitem->{'cn_item'} );
    my $query =
    "INSERT INTO biblioitems SET
        biblionumber    = ?,
        volume          = ?,
        number          = ?,
        itemtype        = ?,
        isbn            = ?,
        issn            = ?,
        publicationyear = ?,
        publishercode   = ?,
        volumedate      = ?,
        volumedesc      = ?,
        collectiontitle = ?,
        collectionissn  = ?,
        collectionvolume= ?,
        editionstatement= ?,
        editionresponsibility = ?,
        illus           = ?,
        pages           = ?,
        notes           = ?,
        size            = ?,
        place           = ?,
        lccn            = ?,
        marc            = ?,
        url             = ?,
        cn_source       = ?,
        cn_class        = ?,
        cn_item         = ?,
        cn_suffix       = ?,
        cn_sort         = ?,
        totalissues     = ?
        ";
	my $sth = $dbh->prepare($query);
    $sth->execute(
        $biblioitem->{'biblionumber'},
        $biblioitem->{'volume'},
        $biblioitem->{'number'},
        $biblioitem->{'itemtype'},
        $biblioitem->{'isbn'},
        $biblioitem->{'issn'},
        $biblioitem->{'publicationyear'},
        $biblioitem->{'publishercode'},
        $biblioitem->{'volumedate'},
        $biblioitem->{'volumedesc'},
        $biblioitem->{'collectiontitle'},
        $biblioitem->{'collectionissn'},
        $biblioitem->{'collectionvolume'},
        $biblioitem->{'editionstatement'},
        $biblioitem->{'editionresponsibility'},
        $biblioitem->{'illus'},
        $biblioitem->{'pages'},
        $biblioitem->{'bnotes'},
        $biblioitem->{'size'},
        $biblioitem->{'place'},
        $biblioitem->{'lccn'},
        $biblioitem->{'marc'},
        $biblioitem->{'url'},
        $biblioitem->{'biblioitems.cn_source'},
        $biblioitem->{'cn_class'},
        $biblioitem->{'cn_item'},
        $biblioitem->{'cn_suffix'},
        $cn_sort,
        $biblioitem->{'totalissues'}
    );
    my $bibitemnum = $dbh->{'mysql_insertid'};
    if ( $dbh->errstr ) {
		$error.="ERROR in _koha_add_biblioitem $query".$dbh->errstr;
		warn $error;
    }
    $sth->finish();
    return ($bibitemnum,$error);
}

=head2 _koha_new_items

=over 4

my ($itemnumber,$error) = _koha_new_items( $dbh, $item, $barcode );

=back

=cut

sub _koha_new_items {
    my ( $dbh, $item, $barcode ) = @_;
	my $error;

    my ($items_cn_sort) = GetClassSort($item->{'items.cn_source'}, $item->{'itemcallnumber'}, "");

    # if dateaccessioned is provided, use it. Otherwise, set to NOW()
    if ( $item->{'dateaccessioned'} eq '' || !$item->{'dateaccessioned'} ) {
		my $today = C4::Dates->new();    
		$item->{'dateaccessioned'} =  $today->output("iso"); #TODO: check time issues
	}
	my $query = 
           "INSERT INTO items SET
			biblionumber     	= ?,
            biblioitemnumber    = ?,
			barcode          	= ?,
			dateaccessioned  	= ?,
			booksellerid        = ?,
            homebranch          = ?,
            price               = ?,
			replacementprice 	= ?,
            replacementpricedate = NOW(),
			datelastborrowed 	= ?,
			datelastseen     	= NOW(),
			stack            	= ?,
			notforloan 			= ?,
			damaged 			= ?,
            itemlost        	= ?,
			wthdrawn        	= ?,
			itemcallnumber 		= ?,
			restricted 			= ?,
			itemnotes 			= ?,
			holdingbranch   	= ?,
            paidfor         	= ?,
			location 			= ?,
			onloan 				= ?,
			cn_source 			= ?,
			cn_sort 			= ?,
			ccode 				= ?,
			materials 			= ?,
			uri 				= ?
          ";
    my $sth = $dbh->prepare($query);
	$sth->execute(
			$item->{'biblionumber'},
			$item->{'biblioitemnumber'},
            $barcode,
			$item->{'dateaccessioned'},
			$item->{'booksellerid'},
            $item->{'homebranch'},
            $item->{'price'},
			$item->{'replacementprice'},
			$item->{datelastborrowed},
			$item->{stack},
			$item->{'notforloan'},
			$item->{'damaged'},
            $item->{'itemlost'},
			$item->{'wthdrawn'},
			$item->{'itemcallnumber'},
            $item->{'restricted'},
			$item->{'itemnotes'},
			$item->{'holdingbranch'},
			$item->{'paidfor'},
			$item->{'location'},
			$item->{'onloan'},
			$item->{'items.cn_source'},
			$items_cn_sort,
			$item->{'ccode'},
			$item->{'materials'},
			$item->{'uri'},
    );
    my $itemnumber = $dbh->{'mysql_insertid'};
    if ( defined $sth->errstr ) {
        $error.="ERROR in _koha_new_items $query".$sth->errstr;
    }
	$sth->finish();
    return ( $itemnumber, $error );
}

=head2 _koha_modify_item

=over 4

my ($itemnumber,$error) =_koha_modify_item( $dbh, $item, $op );

=back

=cut

sub _koha_modify_item {
    my ( $dbh, $item ) = @_;
	my $error;

	# calculate items.cn_sort
    $item->{'cn_sort'} = GetClassSort($item->{'items.cn_source'}, $item->{'itemcallnumber'}, "");

    my $query = "UPDATE items SET ";
	my @bind;
	for my $key ( keys %$item ) {
		$query.="$key=?,";
		push @bind, $item->{$key};
    }
	$query =~ s/,$//;
    $query .= " WHERE itemnumber=?";
    push @bind, $item->{'itemnumber'};
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    if ( $dbh->errstr ) {
        $error.="ERROR in _koha_modify_item $query".$dbh->errstr;
        warn $error;
    }
    $sth->finish();
	return ($item->{'itemnumber'},$error);
}

=head2 _koha_delete_biblio

=over 4

$error = _koha_delete_biblio($dbh,$biblionumber);

Internal sub for deleting from biblio table -- also saves to deletedbiblio

C<$dbh> - the database handle
C<$biblionumber> - the biblionumber of the biblio to be deleted

=back

=cut

# FIXME: add error handling

sub _koha_delete_biblio {
    my ( $dbh, $biblionumber ) = @_;

    # get all the data for this biblio
    my $sth = $dbh->prepare("SELECT * FROM biblio WHERE biblionumber=?");
    $sth->execute($biblionumber);

    if ( my $data = $sth->fetchrow_hashref ) {

        # save the record in deletedbiblio
        # find the fields to save
        my $query = "INSERT INTO deletedbiblio SET ";
        my @bind  = ();
        foreach my $temp ( keys %$data ) {
            $query .= "$temp = ?,";
            push( @bind, $data->{$temp} );
        }

        # replace the last , by ",?)"
        $query =~ s/\,$//;
        my $bkup_sth = $dbh->prepare($query);
        $bkup_sth->execute(@bind);
        $bkup_sth->finish;

        # delete the biblio
        my $del_sth = $dbh->prepare("DELETE FROM biblio WHERE biblionumber=?");
        $del_sth->execute($biblionumber);
        $del_sth->finish;
    }
    $sth->finish;
    return undef;
}

=head2 _koha_delete_biblioitems

=over 4

$error = _koha_delete_biblioitems($dbh,$biblioitemnumber);

Internal sub for deleting from biblioitems table -- also saves to deletedbiblioitems

C<$dbh> - the database handle
C<$biblionumber> - the biblioitemnumber of the biblioitem to be deleted

=back

=cut

# FIXME: add error handling

sub _koha_delete_biblioitems {
    my ( $dbh, $biblioitemnumber ) = @_;

    # get all the data for this biblioitem
    my $sth =
      $dbh->prepare("SELECT * FROM biblioitems WHERE biblioitemnumber=?");
    $sth->execute($biblioitemnumber);

    if ( my $data = $sth->fetchrow_hashref ) {

        # save the record in deletedbiblioitems
        # find the fields to save
        my $query = "INSERT INTO deletedbiblioitems SET ";
        my @bind  = ();
        foreach my $temp ( keys %$data ) {
            $query .= "$temp = ?,";
            push( @bind, $data->{$temp} );
        }

        # replace the last , by ",?)"
        $query =~ s/\,$//;
        my $bkup_sth = $dbh->prepare($query);
        $bkup_sth->execute(@bind);
        $bkup_sth->finish;

        # delete the biblioitem
        my $del_sth =
          $dbh->prepare("DELETE FROM biblioitems WHERE biblioitemnumber=?");
        $del_sth->execute($biblioitemnumber);
        $del_sth->finish;
    }
    $sth->finish;
    return undef;
}

=head2 _koha_delete_item

=over 4

_koha_delete_item( $dbh, $itemnum );

Internal function to delete an item record from the koha tables

=back

=cut

sub _koha_delete_item {
    my ( $dbh, $itemnum ) = @_;

	# save the deleted item to deleteditems table
    my $sth = $dbh->prepare("SELECT * FROM items WHERE itemnumber=?");
    $sth->execute($itemnum);
    my $data = $sth->fetchrow_hashref();
    $sth->finish();
    my $query = "INSERT INTO deleteditems SET ";
    my @bind  = ();
    foreach my $key ( keys %$data ) {
        $query .= "$key = ?,";
        push( @bind, $data->{$key} );
    }
    $query =~ s/\,$//;
    $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    $sth->finish();

	# delete from items table
    $sth = $dbh->prepare("DELETE FROM items WHERE itemnumber=?");
    $sth->execute($itemnum);
    $sth->finish();
	return undef;
}

=head1 UNEXPORTED FUNCTIONS

=head2 ModBiblioMarc

    &ModBiblioMarc($newrec,$biblionumber,$frameworkcode);
    
    Add MARC data for a biblio to koha 
    
    Function exported, but should NOT be used, unless you really know what you're doing

=cut

sub ModBiblioMarc {
    
# pass the MARC::Record to this function, and it will create the records in the marc field
    my ( $record, $biblionumber, $frameworkcode ) = @_;
    my $dbh = C4::Context->dbh;
    my @fields = $record->fields();
    if ( !$frameworkcode ) {
        $frameworkcode = "";
    }
    my $sth =
      $dbh->prepare("UPDATE biblio SET frameworkcode=? WHERE biblionumber=?");
    $sth->execute( $frameworkcode, $biblionumber );
    $sth->finish;
    my $encoding = C4::Context->preference("marcflavour");

    # deal with UNIMARC field 100 (encoding) : create it if needed & set encoding to unicode
    if ( $encoding eq "UNIMARC" ) {
        my $string;
        if ( length($record->subfield( 100, "a" )) == 35 ) {
            $string = $record->subfield( 100, "a" );
            my $f100 = $record->field(100);
            $record->delete_field($f100);
        }
        else {
            $string = POSIX::strftime( "%Y%m%d", localtime );
            $string =~ s/\-//g;
            $string = sprintf( "%-*s", 35, $string );
        }
        substr( $string, 22, 6, "frey50" );
        unless ( $record->subfield( 100, "a" ) ) {
            $record->insert_grouped_field(
                MARC::Field->new( 100, "", "", "a" => $string ) );
        }
    }
    ModZebra($biblionumber,"specialUpdate","biblioserver",$record);
    $sth =
      $dbh->prepare(
        "UPDATE biblioitems SET marc=?,marcxml=? WHERE biblionumber=?");
    $sth->execute( $record->as_usmarc(), $record->as_xml_record($encoding),
        $biblionumber );
    $sth->finish;
    return $biblionumber;
}

=head2 AddItemInMarc

=over 4

$newbiblionumber = AddItemInMarc( $record, $biblionumber, $frameworkcode );

Add an item in a MARC record and save the MARC record

Function exported, but should NOT be used, unless you really know what you're doing

=back

=cut

sub AddItemInMarc {

    # pass the MARC::Record to this function, and it will create the records in the marc tables
    my ( $record, $biblionumber, $frameworkcode ) = @_;
    my $newrec = &GetMarcBiblio($biblionumber);

    # create it
    my @fields = $record->fields();
    foreach my $field (@fields) {
        $newrec->append_fields($field);
    }

    # FIXME: should we be making sure the biblionumbers are the same?
    my $newbiblionumber =
      &ModBiblioMarc( $newrec, $biblionumber, $frameworkcode );
    return $newbiblionumber;
}

=head2 z3950_extended_services

z3950_extended_services($serviceType,$serviceOptions,$record);

    z3950_extended_services is used to handle all interactions with Zebra's extended serices package, which is employed to perform all management of the MARC data stored in Zebra.

C<$serviceType> one of: itemorder,create,drop,commit,update,xmlupdate

C<$serviceOptions> a has of key/value pairs. For instance, if service_type is 'update', $service_options should contain:

    action => update action, one of specialUpdate, recordInsert, recordReplace, recordDelete, elementUpdate.

and maybe

    recordidOpaque => Opaque Record ID (user supplied) or recordidNumber => Record ID number (system number).
    syntax => the record syntax (transfer syntax)
    databaseName = Database from connection object

    To set serviceOptions, call set_service_options($serviceType)

C<$record> the record, if one is needed for the service type

    A record should be in XML. You can convert it to XML from MARC by running it through marc2xml().

=cut

sub z3950_extended_services {
    my ( $server, $serviceType, $action, $serviceOptions ) = @_;

    # get our connection object
    my $Zconn = C4::Context->Zconn( $server, 0, 1 );

    # create a new package object
    my $Zpackage = $Zconn->package();

    # set our options
    $Zpackage->option( action => $action );

    if ( $serviceOptions->{'databaseName'} ) {
        $Zpackage->option( databaseName => $serviceOptions->{'databaseName'} );
    }
    if ( $serviceOptions->{'recordIdNumber'} ) {
        $Zpackage->option(
            recordIdNumber => $serviceOptions->{'recordIdNumber'} );
    }
    if ( $serviceOptions->{'recordIdOpaque'} ) {
        $Zpackage->option(
            recordIdOpaque => $serviceOptions->{'recordIdOpaque'} );
    }

 # this is an ILL request (Zebra doesn't support it, but Koha could eventually)
 #if ($serviceType eq 'itemorder') {
 #   $Zpackage->option('contact-name' => $serviceOptions->{'contact-name'});
 #   $Zpackage->option('contact-phone' => $serviceOptions->{'contact-phone'});
 #   $Zpackage->option('contact-email' => $serviceOptions->{'contact-email'});
 #   $Zpackage->option('itemorder-item' => $serviceOptions->{'itemorder-item'});
 #}

    if ( $serviceOptions->{record} ) {
        $Zpackage->option( record => $serviceOptions->{record} );

        # can be xml or marc
        if ( $serviceOptions->{'syntax'} ) {
            $Zpackage->option( syntax => $serviceOptions->{'syntax'} );
        }
    }

    # send the request, handle any exception encountered
    eval { $Zpackage->send($serviceType) };
    if ( $@ && $@->isa("ZOOM::Exception") ) {
        return "error:  " . $@->code() . " " . $@->message() . "\n";
    }

    # free up package resources
    $Zpackage->destroy();
}

=head2 set_service_options

my $serviceOptions = set_service_options($serviceType);

C<$serviceType> itemorder,create,drop,commit,update,xmlupdate

Currently, we only support 'create', 'commit', and 'update'. 'drop' support will be added as soon as Zebra supports it.

=cut

sub set_service_options {
    my ($serviceType) = @_;
    my $serviceOptions;

# FIXME: This needs to be an OID ... if we ever need 'syntax' this sub will need to change
#   $serviceOptions->{ 'syntax' } = ''; #zebra doesn't support syntaxes other than xml

    if ( $serviceType eq 'commit' ) {

        # nothing to do
    }
    if ( $serviceType eq 'create' ) {

        # nothing to do
    }
    if ( $serviceType eq 'drop' ) {
        die "ERROR: 'drop' not currently supported (by Zebra)";
    }
    return $serviceOptions;
}

=head2 GetItemsCount

$count = &GetItemsCount( $biblionumber);
this function return count of item with $biblionumber
=cut

sub GetItemsCount {
    my ( $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT count(*)
 		  FROM  items 
 		  WHERE biblionumber=?";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my $count = $sth->fetchrow;  
    $sth->finish;
    return ($count);
}

END { }    # module clean-up code here (global destructor)

1;

__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

Joshua Ferraro jmf@liblime.com

=cut
