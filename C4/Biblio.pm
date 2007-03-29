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
use C4::Context;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use ZOOM;
use C4::Koha;
use C4::Date;
use utf8;
use C4::Log; # logaction

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v).".".join( "_", map { sprintf "%03d", $_ } @v ); };

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
  
  &GetItemInfosOf
  &GetItemStatus
  &GetItemLocation

  &GetItemsInfo
  &GetItemFromBarcode
  &getitemsbybiblioitem
  &get_itemnumbers_of
  &GetAuthorisedValueDesc
  &GetXmlBiblio
);

# To modify something
push @EXPORT, qw(
  &ModBiblio
  &ModItem
  &ModBiblioframework
);

# To delete something
push @EXPORT, qw(
  &DelBiblio
  &DelItem
);

# Marc related functions
push @EXPORT, qw(
  &MARCfind_marc_from_kohafield
  &MARCfind_frameworkcode
  &MARCgettagslib
  &MARCmoditemonefield
  &MARCaddbiblio
  &MARCadditem
  &MARCmodbiblio
  &MARCmoditem
  &MARCkoha2marcBiblio
  &MARCmarc2koha
  &MARCkoha2marcItem
  &MARChtml2marc
  &MARChtml2xml
  &MARCgetitem
  &MARCaddword
  &MARCdelword
  &MARCdelsubfield
  &GetMarcNotes
  &GetMarcSubjects
  &GetMarcBiblio
  &GetMarcAuthors
  &GetMarcSeries
  &Koha2Marc
);

# Others functions
push @EXPORT, qw(
  &PrepareItemrecordDisplay
  &zebraop
  &char_decode
  &itemcalculator
  &calculatelc
);

# OLD functions,
push @EXPORT, qw(
  &newitems
  &modbiblio
  &modbibitem
  &moditem
  &checkitems
);

=head1 NAME

C4::Biblio - acquisitions and cataloging management functions

=head1 DESCRIPTION

Biblio.pm contains functions for managing storage and editing of bibliographic data within Koha. Most of the functions in this module are used for cataloging records: adding, editing, or removing biblios, biblioitems, or items. Koha's stores bibliographic information in three places:

=over 4

=item 1. in the biblio,biblioitems,items, etc tables, which are limited to a one-to-one mapping to underlying MARC data

=item 2. as raw MARC in the Zebra index and storage engine

=item 3. as raw MARC the biblioitems.marc

=back

In the 2.4 version of Koha, the authoritative record-level information is in biblioitems.marc and the authoritative items information is in the items table.

Because the data isn't completely normalized there's a chance for information to get out of sync. The design choice to go with a un-normalized schema was driven by performance and stability concerns:

=over 4

=item 1. Compared with MySQL, Zebra is slow to update an index for small data changes -- especially for proc-intensive operations like circulation

=item 2. Zebra's index has been known to crash and a backup of the data is necessary to rebuild it in such cases

=back

Because of this design choice, the process of managing storage and editing is a bit convoluted. Historically, Biblio.pm's grown to an unmanagable size and as a result we have several types of functions currently:

=over 4

=item 1. Add*/Mod*/Del*/ - high-level external functions suitable for being called from external scripts to manage the collection

=item 2. _koha_* - low-level internal functions for managing the koha tables

=item 3. MARC* functions for interacting with the MARC data in both biblioitems.marc Zebra (biblioitems.marc is authoritative)

=item 4. Zebra functions used to update the Zebra index

=item 5. internal helper functions such as char_decode, checkitems, etc. Some of these probably belong in Koha.pm

=item 6. other functions that don't belong in Biblio.pm that will be cleaned out in time. (like MARCfind_marc_from_kohafield which belongs in Search.pm)

In time, as we solidify the new API these older functions will be weeded out.

=back

=head1 EXPORTED FUNCTIONS

=head2 AddBiblio

($biblionumber,$biblioitemnumber) = AddBiblio($record,$frameworkcode);

Exported function (core API) for adding a new biblio to koha.

=cut

sub AddBiblio {
    my ( $record, $frameworkcode ) = @_;
    my $oldbibnum;
    my $oldbibitemnum;
    my $dbh = C4::Context->dbh;
    # transform the data into koha-table style data
    my $olddata = MARCmarc2koha( $dbh, $record, $frameworkcode );
    $oldbibnum = _koha_add_biblio( $dbh, $olddata, $frameworkcode );
    $olddata->{'biblionumber'} = $oldbibnum;
    $oldbibitemnum = _koha_add_biblioitem( $dbh, $olddata );

    # we must add bibnum and bibitemnum in MARC::Record...
    # we build the new field with biblionumber and biblioitemnumber
    # we drop the original field
    # we add the new builded field.
    # NOTE : Works only if the field is ONLY for biblionumber and biblioitemnumber
    # (steve and paul : thinks 090 is a good choice)
    my $sth =
      $dbh->prepare(
        "SELECT tagfield,tagsubfield
         FROM marc_subfield_structure
         WHERE kohafield=?"
      );
    $sth->execute("biblio.biblionumber");
    ( my $tagfield1, my $tagsubfield1 ) = $sth->fetchrow;
    $sth->execute("biblioitems.biblioitemnumber");
    ( my $tagfield2, my $tagsubfield2 ) = $sth->fetchrow;

    my $newfield;

    # biblionumber & biblioitemnumber are in different fields
    if ( $tagfield1 != $tagfield2 ) {

        # deal with biblionumber
        if ( $tagfield1 < 10 ) {
            $newfield = MARC::Field->new( $tagfield1, $oldbibnum, );
        }
        else {
            $newfield =
              MARC::Field->new( $tagfield1, '', '',
                "$tagsubfield1" => $oldbibnum, );
        }

        # drop old field and create new one...
        my $old_field = $record->field($tagfield1);
        $record->delete_field($old_field);
        $record->append_fields($newfield);

        # deal with biblioitemnumber
        if ( $tagfield2 < 10 ) {
            $newfield = MARC::Field->new( $tagfield2, $oldbibitemnum, );
        }
        else {
            $newfield =
              MARC::Field->new( $tagfield2, '', '',
                "$tagsubfield2" => $oldbibitemnum, );
        }
        # drop old field and create new one...
        $old_field = $record->field($tagfield2);
        $record->delete_field($old_field);
        $record->insert_fields_ordered($newfield);

# biblionumber & biblioitemnumber are in the same field (can't be <10 as fields <10 have only 1 value)
    }
    else {
        my $newfield = MARC::Field->new(
            $tagfield1, '', '',
            "$tagsubfield1" => $oldbibnum,
            "$tagsubfield2" => $oldbibitemnum
        );

        # drop old field and create new one...
        my $old_field = $record->field($tagfield1);
        $record->delete_field($old_field);
        $record->insert_fields_ordered($newfield);
    }

    ###NEU specific add cataloguers cardnumber as well
    my $cardtag = C4::Context->preference('cataloguersfield');
    if ($cardtag) {
        my $tag  = substr( $cardtag, 0, 3 );
        my $subf = substr( $cardtag, 3, 1 );
        my $me        = C4::Context->userenv;
        my $cataloger = $me->{'cardnumber'} if ($me);
        my $newtag    = MARC::Field->new( $tag, '', '', $subf => $cataloger )
          if ($me);
        $record->delete_field($newtag);
        $record->insert_fields_ordered($newtag);
    }

    # now add the record
    my $biblionumber =
      MARCaddbiblio( $record, $oldbibnum, $frameworkcode );
      
    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","ADD",$biblionumber,"biblio") 
        if C4::Context->preference("CataloguingLog");
      
    return ( $biblionumber, $oldbibitemnum );
}

=head2 AddItem

$biblionumber = AddItem( $record, $biblionumber)

Exported function (core API) for adding a new item to Koha

=cut

sub AddItem {
    my ( $record, $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    
    # add item in old-DB
    my $frameworkcode = MARCfind_frameworkcode( $biblionumber );
    my $item = &MARCmarc2koha( $dbh, $record, $frameworkcode );

    # needs old biblionumber and biblioitemnumber
    $item->{'biblionumber'} = $biblionumber;
    my $sth =
      $dbh->prepare(
        "select biblioitemnumber,itemtype from biblioitems where biblionumber=?"
      );
    $sth->execute( $item->{'biblionumber'} );
    my $itemtype;
    ( $item->{'biblioitemnumber'}, $itemtype ) = $sth->fetchrow;
    $sth =
      $dbh->prepare(
        "select notforloan from itemtypes where itemtype='$itemtype'");
    $sth->execute();
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
    my ( $itemnumber, $error ) =
      &_koha_new_items( $dbh, $item, $item->{barcode} );

    # add itemnumber to MARC::Record before adding the item.
    $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
      );
    &MARCkoha2marcOnefield( $sth, $record, "items.itemnumber", $itemnumber,
        $frameworkcode );

    ##NEU specific add cataloguers cardnumber as well
    my $cardtag = C4::Context->preference('itemcataloguersubfield');
    if ($cardtag) {
        $sth->execute( $frameworkcode, "items.itemnumber" );
        my ( $itemtag, $subtag ) = $sth->fetchrow;
        my $me         = C4::Context->userenv;
        my $cataloguer = $me->{'cardnumber'} if ($me);
        my $newtag     = $record->field($itemtag);
        $newtag->update( $cardtag => $cataloguer ) if ($me);
        $record->delete_field($newtag);
        $record->append_fields($newtag);
    }

    # add the item
    &MARCadditem( $record, $item->{'biblionumber'},$frameworkcode );
    
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
        &logaction(C4::Context->userenv->{'number'},"CATALOGUING","MODIFY",$biblionumber,$newrecord->as_formatted) 
    }
    
    my $dbh = C4::Context->dbh;
    
    $frameworkcode = "" unless $frameworkcode;

    # update the MARC record with the new record data
    &MARCmodbiblio( $dbh, $biblionumber, $record, $frameworkcode, 1 );

    # load the koha-table data object
    my $oldbiblio = MARCmarc2koha( $dbh, $record, $frameworkcode );

    # modify the other koha tables
    my $oldbiblionumber = _koha_modify_biblio( $dbh, $oldbiblio );
    _koha_modify_biblioitem( $dbh, $oldbiblio );

    return 1;
}

=head2 ModItem

Exported function (core API) for modifying an item in Koha.

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
        my $frameworkcode = MARCfind_frameworkcode( $biblionumber );
        MARCmoditem( $record, $biblionumber, $itemnumber, $frameworkcode, $delete );
        my $olditem       = MARCmarc2koha( $dbh, $record, $frameworkcode );
        _koha_modify_item( $dbh, $olditem );
        return $biblionumber;
    }

    # otherwise, we're just looking to modify something quickly
    # (like a status) so we just update the koha tables
    elsif ($new_item_hashref) {
        _koha_modify_item( $dbh, $new_item_hashref );
    }
}

=head2 ModBiblioframework

ModBiblioframework($biblionumber,$frameworkcode);

Exported function to modify a biblio framework

=cut

sub ModBiblioframework {
    my ( $biblionumber, $frameworkcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
        "UPDATE biblio SET frameworkcode=? WHERE biblionumber=$biblionumber");
        
        warn "IN ModBiblioframework";
    $sth->execute($frameworkcode);
    return 1;
}

=head2 DelBiblio

my $error = &DelBiblio($dbh,$biblionumber);

Exported function (core API) for deleting a biblio in koha.

Deletes biblio record from Zebra and Koha tables (biblio,biblioitems,items)

Also backs it up to deleted* tables

Checks to make sure there are not issues on any of the items

return:
C<$error> : undef unless an error occurs

=cut

sub DelBiblio {
    my ( $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $error;    # for error handling

    # First make sure there are no items with issues are still attached
    my $sth =
      $dbh->prepare(
        "SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
    $sth->execute($biblionumber);
    while ( my $biblioitemnumber = $sth->fetchrow ) {
        my @issues = C4::Circulation::Circ2::itemissues($biblioitemnumber);
        foreach my $issue (@issues) {
            if (   ( $issue->{date_due} )
                && ( $issue->{date_due} ne "Available" ) )
            {

#FIXME: we need a status system in Biblio like in Circ to return standard codes and messages
# instead of hard-coded strings
                $error .=
"Item is checked out to a patron -- you must return it before deleting the Biblio";
            }
        }
    }
    return $error if $error;

    # Delete in Zebra
    zebraop($biblionumber,"delete_record","biblioserver");

    # delete biblio from Koha tables and save in deletedbiblio
    $error = &_koha_delete_biblio( $dbh, $biblionumber );

    # delete biblioitems and items from Koha tables and save in deletedbiblioitems,deleteditems
    $sth =
      $dbh->prepare(
        "SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
    $sth->execute($biblionumber);
    while ( my $biblioitemnumber = $sth->fetchrow ) {

        # delete this biblioitem
        $error = &_koha_delete_biblioitems( $dbh, $biblioitemnumber );
        return $error if $error;

        # delete items
        my $items_sth =
          $dbh->prepare(
            "SELECT itemnumber FROM items WHERE biblioitemnumber=?");
        $items_sth->execute($biblioitemnumber);
        while ( my $itemnumber = $items_sth->fetchrow ) {
            $error = &_koha_delete_items( $dbh, $itemnumber );
            return $error if $error;
        }
    }
    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","DELETE",$biblionumber,"") 
        if C4::Context->preference("CataloguingLog");
    return;
}

=head2 DelItem

DelItem( $biblionumber, $itemnumber );

Exported function (core API) for deleting an item record in Koha.

=cut

sub DelItem {
    my ( $biblionumber, $itemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    &_koha_delete_item( $dbh, $itemnumber );
    my $newrec = &MARCdelitem( $biblionumber, $itemnumber );
    &MARCaddbiblio( $newrec, $biblionumber, MARCfind_frameworkcode($biblionumber) );
    &logaction(C4::Context->userenv->{'number'},"CATALOGUING","DELETE",$itemnumber,"item") 
        if C4::Context->preference("CataloguingLog");
}

=head2 GetBiblioData

  $data = &GetBiblioData($biblionumber, $type);

Returns information about the book with the given biblionumber.

C<$type> is ignored.

C<&GetBiblioData> returns a reference-to-hash. The keys are the fields in
the C<biblio> and C<biblioitems> tables in the
Koha database.

In addition, C<$data-E<gt>{subject}> is the list of the book's
subjects, separated by C<" , "> (space, comma, space).

If there are multiple biblioitems with the given biblionumber, only
the first one is considered.

=cut

#'
sub GetBiblioData {
    my ( $bibnum, $type ) = @_;
    my $dbh = C4::Context->dbh;

    my $query = "
        SELECT * , biblioitems.notes AS bnotes, biblio.notes
        FROM biblio
            LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
            LEFT JOIN itemtypes ON biblioitems.itemtype = itemtypes.itemtype
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

=cut

#'
sub GetItemsInfo {
    my ( $biblionumber, $type ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT *,items.notforloan as itemnotforloan
                 FROM items, biblio, biblioitems
                 LEFT JOIN itemtypes on biblioitems.itemtype = itemtypes.itemtype
                WHERE items.biblionumber = ?
                    AND biblioitems.biblioitemnumber = items.biblioitemnumber
                    AND biblio.biblionumber = items.biblionumber
                ORDER BY items.dateaccessioned desc
                 ";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my $i = 0;
    my @results;
    my ( $date_due, $count_reserves );

    while ( my $data = $sth->fetchrow_hashref ) {
        my $datedue = '';
        my $isth    = $dbh->prepare(
            "SELECT issues.*,borrowers.cardnumber
            FROM   issues, borrowers
            WHERE  itemnumber = ?
                AND returndate IS NULL
                AND issues.borrowernumber=borrowers.borrowernumber"
        );
        $isth->execute( $data->{'itemnumber'} );
        if ( my $idata = $isth->fetchrow_hashref ) {
            $data->{borrowernumber} = $idata->{borrowernumber};
            $data->{cardnumber}     = $idata->{cardnumber};
            $datedue                = format_date( $idata->{'date_due'} );
        }
        if ( $datedue eq '' ) {
            #$datedue="Available";
            my ( $restype, $reserves ) =
              C4::Reserves2::CheckReserves( $data->{'itemnumber'} );
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
      MARCfind_marc_from_kohafield( $dbh, "items.notforloan", $fwk );
    if ( $tag and $subfield ) {
        my $sth =
          $dbh->prepare(
"select authorised_value from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?"
          );
        $sth->execute( $tag, $subfield, $fwk );
        if ( my ($authorisedvaluecat) = $sth->fetchrow ) {
            my $authvalsth =
              $dbh->prepare(
"select authorised_value, lib from authorised_values where category=? order by lib"
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

=cut

sub GetItemLocation {

    # returns a reference to a hash of references to location...
    my ($fwk) = @_;
    my %itemlocation;
    my $dbh = C4::Context->dbh;
    my $sth;
    $fwk = '' unless ($fwk);
    my ( $tag, $subfield ) =
      MARCfind_marc_from_kohafield( $dbh, "items.location", $fwk );
    if ( $tag and $subfield ) {
        my $sth =
          $dbh->prepare(
"select authorised_value from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?"
          );
        $sth->execute( $tag, $subfield, $fwk );
        if ( my ($authorisedvaluecat) = $sth->fetchrow ) {
            my $authvalsth =
              $dbh->prepare(
"select authorised_value, lib from authorised_values where category=? order by lib"
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

=head2 &GetBiblioItemData

  $itemdata = &GetBiblioItemData($biblioitemnumber);

Looks up the biblioitem with the given biblioitemnumber. Returns a
reference-to-hash. The keys are the fields from the C<biblio>,
C<biblioitems>, and C<itemtypes> tables in the Koha database, except
that C<biblioitems.notes> is given as C<$itemdata-E<gt>{bnotes}>.

=cut

#'
sub GetBiblioItemData {
    my ($bibitem) = @_;
    my $dbh       = C4::Context->dbh;
    my $sth       =
      $dbh->prepare(
"Select *,biblioitems.notes as bnotes from biblioitems, biblio,itemtypes where biblio.biblionumber = biblioitems.biblionumber and biblioitemnumber = ? and biblioitems.itemtype = itemtypes.itemtype"
      );
    my $data;

    $sth->execute($bibitem);

    $data = $sth->fetchrow_hashref;

    $sth->finish;
    return ($data);
}    # sub &GetBiblioItemData

=head2 GetItemFromBarcode

$result = GetItemFromBarcode($barcode);

=cut

sub GetItemFromBarcode {
    my ($barcode) = @_;
    my $dbh = C4::Context->dbh;

    my $rq =
      $dbh->prepare("SELECT itemnumber from items where items.barcode=?");
    $rq->execute($barcode);
    my ($result) = $rq->fetchrow;
    return ($result);
}

=head2 GetBiblioItemByBiblioNumber

NOTE : This function has been copy/paste from C4/Biblio.pm from head before zebra integration.

=cut

sub GetBiblioItemByBiblioNumber {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("Select * from biblioitems where biblionumber = ?");
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

  $item = &GetBiblioFromItemNumber($itemnumber);

Looks up the item with the given itemnumber.

C<&itemnodata> returns a reference-to-hash whose keys are the fields
from the C<biblio>, C<biblioitems>, and C<items> tables in the Koha
database.

=cut

#'
sub GetBiblioFromItemNumber {
    my ( $itemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $env;
    my $sth = $dbh->prepare(
        "SELECT * FROM biblio,items,biblioitems
         WHERE items.itemnumber = ?
           AND biblio.biblionumber = items.biblionumber
           AND biblioitems.biblioitemnumber = items.biblioitemnumber"
    );

    $sth->execute($itemnumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ($data);
}

=head2 GetBiblio

( $count, @results ) = &GetBiblio($biblionumber);

=cut

sub GetBiblio {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("Select * from biblio where biblionumber = ?");
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

=head2 getitemsbybiblioitem

( $count, @results ) = &getitemsbybiblioitem($biblioitemnum);

=cut

sub getitemsbybiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh             = C4::Context->dbh;
    my $sth             = $dbh->prepare(
        "Select * from items, biblio where
biblio.biblionumber = items.biblionumber and biblioitemnumber
= ?"
    );

    # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;

    $sth->execute($biblioitemnum);

    # || die "Cannot execute $query\n" . $sth->errstr;
    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$count] = $data;
        $count++;
    }    # while

    $sth->finish;
    return ( $count, @results );
}    # sub getitemsbybiblioitem

=head2 get_itemnumbers_of

  my @itemnumbers_of = get_itemnumbers_of(@biblionumbers);

Given a list of biblionumbers, return the list of corresponding itemnumbers
for each biblionumber.

Return a reference on a hash where keys are biblionumbers and values are
references on array of itemnumbers.

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

=head2 getRecord

$record = getRecord( $server, $koha_query, $recordSyntax );

get a single record in piggyback mode from Zebra and return it in the requested record syntax

default record syntax is XML

=cut

sub getRecord {
    my ( $server, $koha_query, $recordSyntax ) = @_;
    $recordSyntax = "xml" unless $recordSyntax;
    my $Zconn = C4::Context->Zconn( $server, 0, 1, 1, $recordSyntax );
    my $rs = $Zconn->search( new ZOOM::Query::CCL2RPN( $koha_query, $Zconn ) );
    if ( $rs->record(0) ) {
        return $rs->record(0)->raw();
    }
}

=head2 GetItemInfosOf

GetItemInfosOf(@itemnumbers);

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

=head2 GetBiblioItemInfosOf

GetBiblioItemInfosOf(@biblioitemnumbers);

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

=head1 FUNCTIONS FOR HANDLING MARC MANAGEMENT

=head2 MARCgettagslib

=cut

sub MARCgettagslib {
    my ( $dbh, $forlibrarian, $frameworkcode ) = @_;
    $frameworkcode = "" unless $frameworkcode;
    my $sth;
    my $libfield = ( $forlibrarian eq 1 ) ? 'liblibrarian' : 'libopac';

    # check that framework exists
    $sth =
      $dbh->prepare(
        "select count(*) from marc_tag_structure where frameworkcode=?");
    $sth->execute($frameworkcode);
    my ($total) = $sth->fetchrow;
    $frameworkcode = "" unless ( $total > 0 );
    $sth =
      $dbh->prepare(
"select tagfield,liblibrarian,libopac,mandatory,repeatable from marc_tag_structure where frameworkcode=? order by tagfield"
      );
    $sth->execute($frameworkcode);
    my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable ) =
        $sth->fetchrow )
    {
        $res->{$tag}->{lib} =
          ( $forlibrarian or !$libopac ) ? $liblibrarian : $libopac;
        $res->{$tab}->{tab}        = "";            # XXX
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
    }

    $sth =
      $dbh->prepare(
"select tagfield,tagsubfield,liblibrarian,libopac,tab, mandatory, repeatable,authorised_value,authtypecode,value_builder,kohafield,seealso,hidden,isurl,link,defaultvalue from marc_subfield_structure where frameworkcode=? order by tagfield,tagsubfield"
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
        $res->{$tag}->{$subfield}->{link}             = $link;
        $res->{$tag}->{$subfield}->{defaultvalue}     = $defaultvalue;
    }
    return $res;
}

=head2 MARCfind_marc_from_kohafield

=cut

sub MARCfind_marc_from_kohafield {
    my ( $dbh, $kohafield, $frameworkcode ) = @_;
    return 0, 0 unless $kohafield;
    my $relations = C4::Context->marcfromkohafield;
    return (
        $relations->{$frameworkcode}->{$kohafield}->[0],
        $relations->{$frameworkcode}->{$kohafield}->[1]
    );
}

=head2 MARCaddbiblio

&MARCaddbiblio($newrec,$biblionumber,$frameworkcode);

Add MARC data for a biblio to koha 

=cut

sub MARCaddbiblio {

# pass the MARC::Record to this function, and it will create the records in the marc tables
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
        if ( $record->subfield( 100, "a" ) ) {
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
#     warn "biblionumber : ".$biblionumber;
    $sth =
      $dbh->prepare(
        "update biblioitems set marc=?,marcxml=?  where biblionumber=?");
    $sth->execute( $record->as_usmarc(), $record->as_xml_record(),
        $biblionumber );
#     warn $record->as_xml_record();
    $sth->finish;
    zebraop($biblionumber,"specialUpdate","biblioserver");
    return $biblionumber;
}

=head2 MARCadditem

$newbiblionumber = MARCadditem( $record, $biblionumber, $frameworkcode );

=cut

sub MARCadditem {

# pass the MARC::Record to this function, and it will create the records in the marc tables
    my ( $record, $biblionumber, $frameworkcode ) = @_;
    my $newrec = &GetMarcBiblio($biblionumber);

    # 2nd recreate it
    my @fields = $record->fields();
    foreach my $field (@fields) {
        $newrec->append_fields($field);
    }

    # FIXME: should we be making sure the biblionumbers are the same?
    my $newbiblionumber =
      &MARCaddbiblio( $newrec, $biblionumber, $frameworkcode );
    return $newbiblionumber;
}

=head2 GetMarcBiblio

Returns MARC::Record of the biblionumber passed in parameter.

=cut

sub GetMarcBiblio {
    my $biblionumber = shift;
    my $dbh          = C4::Context->dbh;
    my $sth          =
      $dbh->prepare("select marcxml from biblioitems where biblionumber=? ");
    $sth->execute($biblionumber);
    my ($marcxml) = $sth->fetchrow;
#     warn "marcxml : $marcxml";
    MARC::File::XML->default_record_format(C4::Context->preference('marcflavour'));
    $marcxml =~ s/\x1e//g;
    $marcxml =~ s/\x1f//g;
    $marcxml =~ s/\x1d//g;
    $marcxml =~ s/\x0f//g;
    $marcxml =~ s/\x0c//g;
    my $record = MARC::Record->new();
    $record = MARC::Record::new_from_xml( $marcxml, "utf8",C4::Context->preference('marcflavour')) if $marcxml;
    return $record;
}

=head2 GetXmlBiblio

my $marcxml = GetXmlBiblio($biblionumber);

Returns biblioitems.marcxml of the biblionumber passed in parameter.

=cut

sub GetXmlBiblio {
    my ( $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare("select marcxml from biblioitems where biblionumber=? ");
    $sth->execute($biblionumber);
    my ($marcxml) = $sth->fetchrow;
    return $marcxml;
}

=head2 GetAuthorisedValueDesc

my $subfieldvalue =get_authorised_value_desc(
    $tag, $subf[$i][0],$subf[$i][1], '', $taglib);

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
        return getitemtypeinfo($value);
    }

    #---- "true" authorized value
    my $category = $tagslib->{$tag}->{$subfield}->{'authorised_value'};

    if ( $category ne "" ) {
        my $sth =
          $dbh->prepare(
            "select lib from authorised_values where category = ? and authorised_value = ?"
          );
        $sth->execute( $category, $value );
        my $data = $sth->fetchrow_hashref;
        return $data->{'lib'};
    }
    else {
        return $value;    # if nothing is found return the original value
    }
}

=head2 MARCgetitem

Returns MARC::Record of the item passed in parameter.

=cut

sub MARCgetitem {
    my ( $biblionumber, $itemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $newrecord = MARC::Record->new();
    my $marcflavour = C4::Context->preference('marcflavour');
    
    my $marcxml = GetXmlBiblio($biblionumber);
    my $record = MARC::Record->new();
#     warn "marcxml :$marcxml";
    $record = MARC::Record::new_from_xml( $marcxml, "utf8", $marcflavour );
#     warn "record :".$record->as_formatted;
    # now, find where the itemnumber is stored & extract only the item
    my ( $itemnumberfield, $itemnumbersubfield ) =
      MARCfind_marc_from_kohafield( $dbh, 'items.itemnumber', '' );
    my @fields = $record->field($itemnumberfield);
    foreach my $field (@fields) {
        if ( $field->subfield($itemnumbersubfield) eq $itemnumber ) {
            $newrecord->insert_fields_ordered($field);
        }
    }
    return $newrecord;
}

=head2 GetMarcNotes

$marcnotesarray = GetMarcNotes( $record, $marcflavour );

get a single record in piggyback mode from Zebra and return it in the requested record syntax

default record syntax is XML

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

$marcsubjcts = GetMarcSubjects($record,$marcflavour);

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

    my @marcsubjcts;

    foreach my $field ( $record->fields ) {
        next unless $field->tag() >= $mintag && $field->tag() <= $maxtag;
        my @subfields = $field->subfields();
        my $link;
        my $label = "su:";
        my $flag = 0;
        for my $subject_subfield ( @subfields ) {
            my $code = $subject_subfield->[0];
            $label .= $subject_subfield->[1] . " and su-to:" unless ( $code == 9 );
            if ( $code == 9 ) {
                $link = "Koha-Auth-Number:".$subject_subfield->[1];
                $flag = 1;
            }
            elsif ( ! $flag ) {
                $link = $label;
                $link =~ s/ and\ssu-to:$//;
            }
        }
        $label =~ s/su/ /g;
        $label =~ s/://g;
        $label =~ s/-to//g;
        $label =~ s/and//g;
        push @marcsubjcts,
          {
            label => $label,
            link  => $link
          }
    }
    return \@marcsubjcts;
}    #end GetMarcSubjects

=head2 GetMarcAuthors

authors = GetMarcAuthors($record,$marcflavour);

=cut

sub GetMarcAuthors {
    my ( $record, $marcflavour ) = @_;
    my ( $mintag, $maxtag );
    if ( $marcflavour eq "MARC21" ) {
        $mintag = "100";
        $maxtag = "111"; 
    }
    else {    # assume unimarc if not marc21
        $mintag = "701";
        $maxtag = "712";
    }

    my @marcauthors;

    foreach my $field ( $record->fields ) {
        next unless $field->tag() >= $mintag && $field->tag() <= $maxtag;
        my %hash;
        my @subfields = $field->subfields();
        my $count_auth = 0;
        my $and ;
        for my $authors_subfield (@subfields) {
        	if ($count_auth ne '0'){
        	$and = " and au:";
        	}
            $count_auth++;
            my $subfieldcode     = $authors_subfield->[0];
            my $value            = $authors_subfield->[1];
            $hash{'tag'}         = $field->tag;
            $hash{value}        .= $value . " " if ($subfieldcode != 9) ;
            $hash{link}        .= $value if ($subfieldcode eq 9);
        }
        push @marcauthors, \%hash;
    }
    return \@marcauthors;
}

=head2 GetMarcSeries

$marcseriessarray = GetMarcSeries($record,$marcflavour);

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

=head2 MARCmodbiblio

MARCmodbibio($dbh,$biblionumber,$record,$frameworkcode,1);

Modify a biblio record with the option to save items data

=cut

sub MARCmodbiblio {
    my ( $dbh, $biblionumber, $record, $frameworkcode, $keep_items ) = @_;

    # delete original record but save the items
    my $newrec = &MARCdelbiblio( $biblionumber, $keep_items );

    # recreate it and add the new fields
    my @fields = $record->fields();
    foreach my $field (@fields) {

        # this requires a more recent version of MARC::Record
        # but ensures the fields are in order
        $newrec->insert_fields_ordered($field);
    }

    # give back our old leader
    $newrec->leader( $record->leader() );

    # add the record back with the items info preserved
    &MARCaddbiblio( $newrec, $biblionumber, $frameworkcode );
}

=head2 MARCdelbiblio

&MARCdelbiblio( $biblionumber, $keep_items )

if the keep_item is set to 1, then all items are preserved.
This flag is set when the delbiblio is called by modbiblio
due to a too complex structure of MARC (repeatable fields and subfields),
the best solution for a modif is to delete / recreate the record.

1st of all, copy the MARC::Record to deletedbiblio table => if a true deletion, MARC data will be kept.
if deletion called before MARCmodbiblio => won't do anything, as the oldbiblionumber doesn't
exist in deletedbiblio table

=cut

sub MARCdelbiblio {
    my ( $biblionumber, $keep_items ) = @_;
    my $dbh = C4::Context->dbh;
    
    my $record          = GetMarcBiblio($biblionumber);
    my $oldbiblionumber = $biblionumber;
    my $copy2deleted    =
      $dbh->prepare("update deletedbiblio set marc=? where biblionumber=?");
    $copy2deleted->execute( $record->as_usmarc(), $oldbiblionumber );
    my @fields = $record->fields();

    # now, delete in MARC tables.
    if ( $keep_items eq 1 ) {
        #search item field code
        my $sth =
          $dbh->prepare(
"select tagfield from marc_subfield_structure where kohafield like 'items.%'"
          );
        $sth->execute;
        my $itemtag = $sth->fetchrow_hashref->{tagfield};

        foreach my $field (@fields) {

            if ( $field->tag() ne $itemtag ) {
                $record->delete_field($field);
            }    #if
        }    #foreach
    }
    else {
        foreach my $field (@fields) {

            $record->delete_field($field);
        }    #foreach
    }
    return $record;
}

=head2 MARCdelitem

MARCdelitem( $biblionumber, $itemnumber )

delete the item field from the MARC record for the itemnumber specified

=cut

sub MARCdelitem {
    my ( $biblionumber, $itemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    
    # get the MARC record
    my $record = GetMarcBiblio($biblionumber);

    # backup the record
    my $copy2deleted =
      $dbh->prepare("UPDATE deleteditems SET marc=? WHERE itemnumber=?");
    $copy2deleted->execute( $record->as_usmarc(), $itemnumber );

    #search item field code
    my $sth =
      $dbh->prepare(
"SELECT tagfield,tagsubfield FROM marc_subfield_structure WHERE kohafield LIKE 'items.itemnumber'"
      );
    $sth->execute;
    my ( $itemtag, $itemsubfield ) = $sth->fetchrow;
    my @fields = $record->field($itemtag);
    # delete the item specified
    foreach my $field (@fields) {
        if ( $field->subfield($itemsubfield) eq $itemnumber ) {
            $record->delete_field($field);
        }
    }
    return $record;
}

=head2 MARCmoditemonefield

&MARCmoditemonefield( $biblionumber, $itemnumber, $itemfield, $newvalue )

=cut

sub MARCmoditemonefield {
    my ( $biblionumber, $itemnumber, $itemfield, $newvalue ) = @_;
    my $dbh = C4::Context->dbh;
    if ( !defined $newvalue ) {
        $newvalue = "";
    }

    my $record = MARCgetitem( $biblionumber, $itemnumber );

    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where kohafield=?"
      );
    my $tagfield;
    my $tagsubfield;
    $sth->execute($itemfield);
    if ( ( $tagfield, $tagsubfield ) = $sth->fetchrow ) {
        my $tag = $record->field($tagfield);
        if ($tag) {
            my $tagsubs = $record->field($tagfield)->subfield($tagsubfield);
            $tag->update( $tagsubfield => $newvalue );
            $record->delete_field($tag);
            $record->insert_fields_ordered($tag);
            &MARCmoditem( $record, $biblionumber, $itemnumber, 0 );
        }
    }
}

=head2 MARCmoditem

&MARCmoditem( $record, $biblionumber, $itemnumber, $frameworkcode, $delete )

=cut

sub MARCmoditem {
    my ( $record, $biblionumber, $itemnumber, $frameworkcode, $delete ) = @_;
    my $dbh = C4::Context->dbh;
    
    # delete this item from MARC
    my $newrec = &MARCdelitem( $biblionumber, $itemnumber );

    # 2nd recreate it
    my @fields = $record->fields();
    ###NEU specific add cataloguers cardnumber as well
    my $cardtag = C4::Context->preference('itemcataloguersubfield');

    foreach my $field (@fields) {
        if ($cardtag) {
            my $me = C4::Context->userenv;
            my $cataloguer = $me->{'cardnumber'} if ($me);
            $field->update( $cardtag => $cataloguer ) if ($me);
        }
        $newrec->append_fields($field);
    }
    &MARCaddbiblio( $newrec, $biblionumber, $frameworkcode );
}

=head2 MARCfind_frameworkcode

$frameworkcode = MARCfind_frameworkcode( $biblionumber )

=cut

sub MARCfind_frameworkcode {
    my ( $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare("select frameworkcode from biblio where biblionumber=?");
    $sth->execute($biblionumber);
    my ($frameworkcode) = $sth->fetchrow;
    return $frameworkcode;
}

=head2 Koha2Marc

$record = Koha2Marc( $hash )

This function builds partial MARC::Record from a hash

Hash entries can be from biblio or biblioitems.

This function is called in acquisition module, to create a basic catalogue entry from user entry

=cut

sub Koha2Marc {

    my ( $hash ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
    $dbh->prepare(
        "select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
    );
    my $record = MARC::Record->new();
    foreach (keys %{$hash}) {
        &MARCkoha2marcOnefield( $sth, $record, $_,
            $hash->{$_}, '' );
        }
    return $record;
}
        
=head2 MARCkoha2marcBiblio

$record = MARCkoha2marcBiblio( $biblionumber, $biblioitemnumber )

this function builds partial MARC::Record from the old koha-DB fields

=cut

sub MARCkoha2marcBiblio {

    my ( $biblionumber, $biblioitemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
      );
    my $record = MARC::Record->new();

    #--- if biblionumber, then retrieve old-style koha data
    if ( $biblionumber > 0 ) {
        my $sth2 = $dbh->prepare(
"select biblionumber,author,title,unititle,notes,abstract,serial,seriestitle,copyrightdate,timestamp
        from biblio where biblionumber=?"
        );
        $sth2->execute($biblionumber);
        my $row = $sth2->fetchrow_hashref;
        my $code;
        foreach $code ( keys %$row ) {
            if ( $row->{$code} ) {
                &MARCkoha2marcOnefield( $sth, $record, "biblio." . $code,
                    $row->{$code}, '' );
            }
        }
    }

    #--- if biblioitem, then retrieve old-style koha data
    if ( $biblioitemnumber > 0 ) {
        my $sth2 = $dbh->prepare(
            " SELECT biblioitemnumber,biblionumber,volume,number,classification,
                        itemtype,url,isbn,issn,dewey,subclass,publicationyear,publishercode,
                        volumedate,volumeddesc,timestamp,illus,pages,notes AS bnotes,size,place
                    FROM biblioitems
                    WHERE biblioitemnumber=?
                    "
        );
        $sth2->execute($biblioitemnumber);
        my $row = $sth2->fetchrow_hashref;
        my $code;
        foreach $code ( keys %$row ) {
            if ( $row->{$code} ) {
                &MARCkoha2marcOnefield( $sth, $record, "biblioitems." . $code,
                    $row->{$code}, '' );
            }
        }
    }
    return $record;
}

=head2 MARCkoha2marcItem

$record = MARCkoha2marcItem( $dbh, $biblionumber, $itemnumber );

=cut

sub MARCkoha2marcItem {

    # this function builds partial MARC::Record from the old koha-DB fields
    my ( $dbh, $biblionumber, $itemnumber ) = @_;

    #    my $dbh=&C4Connect;
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
      );
    my $record = MARC::Record->new();

    #--- if item, then retrieve old-style koha data
    if ( $itemnumber > 0 ) {

        #    print STDERR "prepare $biblionumber,$itemnumber\n";
        my $sth2 = $dbh->prepare(
"SELECT itemnumber,biblionumber,multivolumepart,biblioitemnumber,barcode,dateaccessioned,
                        booksellerid,homebranch,price,replacementprice,replacementpricedate,datelastborrowed,
                        datelastseen,multivolume,stack,notforloan,itemlost,wthdrawn,itemcallnumber,issues,renewals,
                    reserves,restricted,binding,itemnotes,holdingbranch,timestamp,onloan,Cutterextra
                    FROM items
                    WHERE itemnumber=?"
        );
        $sth2->execute($itemnumber);
        my $row = $sth2->fetchrow_hashref;
        my $code;
        foreach $code ( keys %$row ) {
            if ( $row->{$code} ) {
                &MARCkoha2marcOnefield( $sth, $record, "items." . $code,
                    $row->{$code}, '' );
            }
        }
    }
    return $record;
}

=head2 MARCkoha2marcOnefield

$record = MARCkoha2marcOnefield( $sth, $record, $kohafieldname, $value, $frameworkcode );

=cut

sub MARCkoha2marcOnefield {
    my ( $sth, $record, $kohafieldname, $value, $frameworkcode ) = @_;
    $frameworkcode='' unless $frameworkcode;
    my $tagfield;
    my $tagsubfield;

    if ( !defined $sth ) {
        my $dbh = C4::Context->dbh;
        $sth =
          $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
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

=head2 MARChtml2xml

$xml = MARChtml2xml( $tags, $subfields, $values, $indicator, $ind_tag )

=cut

sub MARChtml2xml {
    my ( $tags, $subfields, $values, $indicator, $ind_tag ) = @_;
    my $xml = MARC::File::XML::header('UTF-8');
    if ( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        MARC::File::XML->default_record_format('UNIMARC');
        use POSIX qw(strftime);
        my $string = strftime( "%Y%m%d", localtime(time) );
        $string = sprintf( "%-*s", 35, $string );
        substr( $string, 22, 6, "frey50" );
        $xml .= "<datafield tag=\"100\" ind1=\"\" ind2=\"\">\n";
        $xml .= "<subfield code=\"a\">$string</subfield>\n";
        $xml .= "</datafield>\n";
    }
    my $prevvalue;
    my $prevtag = -1;
    my $first   = 1;
    my $j       = -1;
    for ( my $i = 0 ; $i <= @$tags ; $i++ ) {
        @$values[$i] =~ s/&/&amp;/g;
        @$values[$i] =~ s/</&lt;/g;
        @$values[$i] =~ s/>/&gt;/g;
        @$values[$i] =~ s/"/&quot;/g;
        @$values[$i] =~ s/'/&apos;/g;
        if ( !utf8::is_utf8( @$values[$i] ) ) {
            utf8::decode( @$values[$i] );
        }
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
    $xml .= MARC::File::XML::footer();

    return $xml;
}

=head2 MARChtml2marc

$record = MARChtml2marc( $dbh, $rtags, $rsubfields, $rvalues, %indicators )

=cut

sub MARChtml2marc {
    my ( $dbh, $rtags, $rsubfields, $rvalues, %indicators ) = @_;
    my $prevtag = -1;
    my $record  = MARC::Record->new();

    #     my %subfieldlist=();
    my $prevvalue;    # if tag <10
    my $field;        # if tag >=10
    for ( my $i = 0 ; $i < @$rtags ; $i++ ) {
        next unless @$rvalues[$i];

 # rebuild MARC::Record
 #             warn "0=>".@$rtags[$i].@$rsubfields[$i]." = ".@$rvalues[$i].": ";
        if ( @$rtags[$i] ne $prevtag ) {
            if ( $prevtag < 10 ) {
                if ($prevvalue) {

                    if ( $prevtag ne '000' ) {
                        $record->insert_fields_ordered(
                            ( sprintf "%03s", $prevtag ), $prevvalue );
                    }
                    else {

                        $record->leader($prevvalue);

                    }
                }
            }
            else {
                if ($field) {
                    $record->insert_fields_ordered($field);
                }
            }
            $indicators{ @$rtags[$i] } .= '  ';
            if ( @$rtags[$i] < 10 ) {
                $prevvalue = @$rvalues[$i];
                undef $field;
            }
            else {
                undef $prevvalue;
                $field = MARC::Field->new(
                    ( sprintf "%03s", @$rtags[$i] ),
                    substr( $indicators{ @$rtags[$i] }, 0, 1 ),
                    substr( $indicators{ @$rtags[$i] }, 1, 1 ),
                    @$rsubfields[$i] => @$rvalues[$i]
                );
            }
            $prevtag = @$rtags[$i];
        }
        else {
            if ( @$rtags[$i] < 10 ) {
                $prevvalue = @$rvalues[$i];
            }
            else {
                if ( length( @$rvalues[$i] ) > 0 ) {
                    $field->add_subfields( @$rsubfields[$i] => @$rvalues[$i] );
                }
            }
            $prevtag = @$rtags[$i];
        }
    }

    # the last has not been included inside the loop... do it now !
    $record->insert_fields_ordered($field) if $field;

    #     warn "HTML2MARC=".$record->as_formatted;
    $record->encoding('UTF-8');

    #    $record->MARC::File::USMARC::update_leader();
    return $record;
}

=head2 MARCmarc2koha

$result = MARCmarc2koha( $dbh, $record, $frameworkcode )

=cut

sub MARCmarc2koha {
    my ( $dbh, $record, $frameworkcode ) = @_;
    my $sth =
      $dbh->prepare(
"select tagfield,tagsubfield from marc_subfield_structure where frameworkcode=? and kohafield=?"
      );
    my $result;
    my $sth2 = $dbh->prepare("SHOW COLUMNS from biblio");
    $sth2->execute;
    my $field;
    while ( ($field) = $sth2->fetchrow ) {
        $result =
          &MARCmarc2kohaOneField( "biblio", $field, $record, $result,
            $frameworkcode );
    }
    $sth2 = $dbh->prepare("SHOW COLUMNS from biblioitems");
    $sth2->execute;
    while ( ($field) = $sth2->fetchrow ) {
        if ( $field eq 'notes' ) { $field = 'bnotes'; }
        $result =
          &MARCmarc2kohaOneField( "biblioitems", $field, $record, $result,
            $frameworkcode );
    }
    $sth2 = $dbh->prepare("SHOW COLUMNS from items");
    $sth2->execute;
    while ( ($field) = $sth2->fetchrow ) {
        $result =
          &MARCmarc2kohaOneField( "items", $field, $record, $result,
            $frameworkcode );
    }

    #
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

=head2 MARCmarc2kohaOneField

$result = MARCmarc2kohaOneField( $kohatable, $kohafield, $record, $result, $frameworkcode )

=cut

sub MARCmarc2kohaOneField {

# FIXME ? if a field has a repeatable subfield that is used in old-db, only the 1st will be retrieved...
    my ( $kohatable, $kohafield, $record, $result, $frameworkcode ) = @_;

    my $res = "";
    my ( $tagfield, $subfield ) =
      MARCfind_marc_from_kohafield( "", $kohatable . "." . $kohafield,
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

=head2 MARCitemchange

&MARCitemchange( $record, $itemfield, $newvalue )

=cut

sub MARCitemchange {
    my ( $record, $itemfield, $newvalue ) = @_;
    my $dbh = C4::Context->dbh;
    
    my ( $tagfield, $tagsubfield ) =
      MARCfind_marc_from_kohafield( $dbh, $itemfield, "" );
    if ( ($tagfield) && ($tagsubfield) ) {
        my $tag = $record->field($tagfield);
        if ($tag) {
            $tag->update( $tagsubfield => $newvalue );
            $record->delete_field($tag);
            $record->insert_fields_ordered($tag);
        }
    }
}

=head1 INTERNAL FUNCTIONS

=head2 _koha_add_biblio

_koha_add_biblio($dbh,$biblioitem);

Internal function to add a biblio ($biblio is a hash with the values)

=cut

sub _koha_add_biblio {
    my ( $dbh, $biblio, $frameworkcode ) = @_;
    my $sth = $dbh->prepare("Select max(biblionumber) from biblio");
    $sth->execute;
    my $data         = $sth->fetchrow_arrayref;
    my $biblionumber = $$data[0] + 1;
    my $series       = 0;

    if ( $biblio->{'seriestitle'} ) { $series = 1 }
    $sth->finish;
    $sth = $dbh->prepare(
        "INSERT INTO biblio
    SET biblionumber  = ?, title = ?, author = ?, copyrightdate = ?, serial = ?, seriestitle = ?, notes = ?, abstract = ?, unititle = ?, frameworkcode = ? "
    );
    $sth->execute(
        $biblionumber,         $biblio->{'title'},
        $biblio->{'author'},   $biblio->{'copyrightdate'},
        $biblio->{'serial'},   $biblio->{'seriestitle'},
        $biblio->{'notes'},    $biblio->{'abstract'},
        $biblio->{'unititle'}, $frameworkcode
    );

    $sth->finish;
    return ($biblionumber);
}

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

=head2 _koha_modify_biblio

Internal function for updating the biblio table

=cut

sub _koha_modify_biblio {
    my ( $dbh, $biblio ) = @_;

# FIXME: this code could be made more portable by not hard-coding the values that are supposed to be in biblio table
    my $sth =
      $dbh->prepare(
"Update biblio set title = ?, author = ?, abstract = ?, copyrightdate = ?, seriestitle = ?, serial = ?, unititle = ?, notes = ? where biblionumber = ?"
      );
    $sth->execute(
        $biblio->{'title'},       $biblio->{'author'},
        $biblio->{'abstract'},    $biblio->{'copyrightdate'},
        $biblio->{'seriestitle'}, $biblio->{'serial'},
        $biblio->{'unititle'},    $biblio->{'notes'},
        $biblio->{'biblionumber'}
    );
    $sth->finish;
    return ( $biblio->{'biblionumber'} );
}

=head2 _koha_modify_biblioitem

_koha_modify_biblioitem( $dbh, $biblioitem );

=cut

sub _koha_modify_biblioitem {
    my ( $dbh, $biblioitem ) = @_;
    my $query;
##Recalculate LC in case it changed --TG

    $biblioitem->{'itemtype'}      = $dbh->quote( $biblioitem->{'itemtype'} );
    $biblioitem->{'url'}           = $dbh->quote( $biblioitem->{'url'} );
    $biblioitem->{'isbn'}          = $dbh->quote( $biblioitem->{'isbn'} );
    $biblioitem->{'issn'}          = $dbh->quote( $biblioitem->{'issn'} );
    $biblioitem->{'publishercode'} =
      $dbh->quote( $biblioitem->{'publishercode'} );
    $biblioitem->{'publicationyear'} =
      $dbh->quote( $biblioitem->{'publicationyear'} );
    $biblioitem->{'classification'} =
      $dbh->quote( $biblioitem->{'classification'} );
    $biblioitem->{'dewey'}        = $dbh->quote( $biblioitem->{'dewey'} );
    $biblioitem->{'subclass'}     = $dbh->quote( $biblioitem->{'subclass'} );
    $biblioitem->{'illus'}        = $dbh->quote( $biblioitem->{'illus'} );
    $biblioitem->{'pages'}        = $dbh->quote( $biblioitem->{'pages'} );
    $biblioitem->{'volumeddesc'}  = $dbh->quote( $biblioitem->{'volumeddesc'} );
    $biblioitem->{'bnotes'}       = $dbh->quote( $biblioitem->{'bnotes'} );
    $biblioitem->{'size'}         = $dbh->quote( $biblioitem->{'size'} );
    $biblioitem->{'place'}        = $dbh->quote( $biblioitem->{'place'} );
    $biblioitem->{'ccode'}        = $dbh->quote( $biblioitem->{'ccode'} );
    $biblioitem->{'biblionumber'} =
      $dbh->quote( $biblioitem->{'biblionumber'} );

    $query = "Update biblioitems set
        itemtype        = $biblioitem->{'itemtype'},
        url             = $biblioitem->{'url'},
        isbn            = $biblioitem->{'isbn'},
        issn            = $biblioitem->{'issn'},
        publishercode   = $biblioitem->{'publishercode'},
        publicationyear = $biblioitem->{'publicationyear'},
        classification  = $biblioitem->{'classification'},
        dewey           = $biblioitem->{'dewey'},
        subclass        = $biblioitem->{'subclass'},
        illus           = $biblioitem->{'illus'},
        pages           = $biblioitem->{'pages'},
        volumeddesc     = $biblioitem->{'volumeddesc'},
        notes           = $biblioitem->{'bnotes'},
        size            = $biblioitem->{'size'},
        place           = $biblioitem->{'place'},
        ccode           = $biblioitem->{'ccode'}
        where biblionumber = $biblioitem->{'biblionumber'}";

    $dbh->do($query);
    if ( $dbh->errstr ) {
        warn "$query";
    }
}

=head2 _koha_modify_note

_koha_modify_note( $dbh, $bibitemnum, $note );

=cut

sub _koha_modify_note {
    my ( $dbh, $bibitemnum, $note ) = @_;

    #  my $dbh=C4Connect;
    my $query = "update biblioitems set notes='$note' where
  biblioitemnumber='$bibitemnum'";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
}

=head2 _koha_add_biblioitem

_koha_add_biblioitem( $dbh, $biblioitem );

Internal function to add a biblioitem

=cut

sub _koha_add_biblioitem {
    my ( $dbh, $biblioitem ) = @_;

    #  my $dbh   = C4Connect;
    my $sth = $dbh->prepare("SELECT max(biblioitemnumber) FROM biblioitems");
    my $data;
    my $bibitemnum;

    $sth->execute;
    $data       = $sth->fetchrow_arrayref;
    $bibitemnum = $$data[0] + 1;

    $sth->finish;

    $sth = $dbh->prepare(
        "INSERT INTO biblioitems SET
            biblioitemnumber = ?, biblionumber    = ?,
            volume           = ?, number          = ?,
            classification   = ?, itemtype        = ?,
            url              = ?, isbn            = ?,
            issn             = ?, dewey           = ?,
            subclass         = ?, publicationyear = ?,
            publishercode    = ?, volumedate      = ?,
            volumeddesc      = ?, illus           = ?,
            pages            = ?, notes           = ?,
            size             = ?, lccn            = ?,
            marc             = ?, lcsort          =?,
            place            = ?, ccode           = ?
          "
    );
    my ($lcsort) =
      calculatelc( $biblioitem->{'classification'} )
      . $biblioitem->{'subclass'};
    $sth->execute(
        $bibitemnum,                     $biblioitem->{'biblionumber'},
        $biblioitem->{'volume'},         $biblioitem->{'number'},
        $biblioitem->{'classification'}, $biblioitem->{'itemtype'},
        $biblioitem->{'url'},            $biblioitem->{'isbn'},
        $biblioitem->{'issn'},           $biblioitem->{'dewey'},
        $biblioitem->{'subclass'},       $biblioitem->{'publicationyear'},
        $biblioitem->{'publishercode'},  $biblioitem->{'volumedate'},
        $biblioitem->{'volumeddesc'},    $biblioitem->{'illus'},
        $biblioitem->{'pages'},          $biblioitem->{'bnotes'},
        $biblioitem->{'size'},           $biblioitem->{'lccn'},
        $biblioitem->{'marc'},           $biblioitem->{'place'},
        $lcsort,                         $biblioitem->{'ccode'}
    );
    $sth->finish;
    return ($bibitemnum);
}

=head2 _koha_new_items

_koha_new_items( $dbh, $item, $barcode );

=cut

sub _koha_new_items {
    my ( $dbh, $item, $barcode ) = @_;

    #  my $dbh   = C4Connect;
    my $sth = $dbh->prepare("Select max(itemnumber) from items");
    my $data;
    my $itemnumber;
    my $error = "";

    $sth->execute;
    $data       = $sth->fetchrow_hashref;
    $itemnumber = $data->{'max(itemnumber)'} + 1;
    $sth->finish;
## Now calculate lccalnumber
    my ($cutterextra) = itemcalculator(
        $dbh,
        $item->{'biblioitemnumber'},
        $item->{'itemcallnumber'}
    );

# FIXME the "notforloan" field seems to be named "loan" in some places. workaround bugfix.
    if ( $item->{'loan'} ) {
        $item->{'notforloan'} = $item->{'loan'};
    }

    # if dateaccessioned is provided, use it. Otherwise, set to NOW()
    if ( $item->{'dateaccessioned'} eq '' || !$item->{'dateaccessioned'} ) {

        $sth = $dbh->prepare(
            "Insert into items set
            itemnumber           = ?,     biblionumber     = ?,
            multivolumepart      = ?,
            biblioitemnumber     = ?,     barcode          = ?,
            booksellerid         = ?,     dateaccessioned  = NOW(),
            homebranch           = ?,     holdingbranch    = ?,
            price                = ?,     replacementprice = ?,
            replacementpricedate = NOW(), datelastseen     = NOW(),
            multivolume          = ?,     stack            = ?,
            itemlost             = ?,     wthdrawn         = ?,
            paidfor              = ?,     itemnotes        = ?,
            itemcallnumber       =?,      notforloan       = ?,
            location             = ?,     Cutterextra      = ?
          "
        );
        $sth->execute(
            $itemnumber,                $item->{'biblionumber'},
            $item->{'multivolumepart'}, $item->{'biblioitemnumber'},
            $barcode,                   $item->{'booksellerid'},
            $item->{'homebranch'},      $item->{'holdingbranch'},
            $item->{'price'},           $item->{'replacementprice'},
            $item->{multivolume},       $item->{stack},
            $item->{itemlost},          $item->{wthdrawn},
            $item->{paidfor},           $item->{'itemnotes'},
            $item->{'itemcallnumber'},  $item->{'notforloan'},
            $item->{'location'},        $cutterextra
        );
    }
    else {
        $sth = $dbh->prepare(
            "INSERT INTO items SET
            itemnumber           = ?,     biblionumber     = ?,
            multivolumepart      = ?,
            biblioitemnumber     = ?,     barcode          = ?,
            booksellerid         = ?,     dateaccessioned  = ?,
            homebranch           = ?,     holdingbranch    = ?,
            price                = ?,     replacementprice = ?,
            replacementpricedate = NOW(), datelastseen     = NOW(),
            multivolume          = ?,     stack            = ?,
            itemlost             = ?,     wthdrawn         = ?,
            paidfor              = ?,     itemnotes        = ?,
            itemcallnumber       = ?,     notforloan       = ?,
            location             = ?,
            Cutterextra          = ?
                            "
        );
        $sth->execute(
            $itemnumber,                 $item->{'biblionumber'},
            $item->{'multivolumepart'},  $item->{'biblioitemnumber'},
            $barcode,                    $item->{'booksellerid'},
            $item->{'dateaccessioned'},  $item->{'homebranch'},
            $item->{'holdingbranch'},    $item->{'price'},
            $item->{'replacementprice'}, $item->{multivolume},
            $item->{stack},              $item->{itemlost},
            $item->{wthdrawn},           $item->{paidfor},
            $item->{'itemnotes'},        $item->{'itemcallnumber'},
            $item->{'notforloan'},       $item->{'location'},
            $cutterextra
        );
    }
    if ( defined $sth->errstr ) {
        $error .= $sth->errstr;
    }
    return ( $itemnumber, $error );
}

=head2 _koha_modify_item

_koha_modify_item( $dbh, $item, $op );

=cut

sub _koha_modify_item {
    my ( $dbh, $item, $op ) = @_;
    $item->{'itemnum'} = $item->{'itemnumber'} unless $item->{'itemnum'};

    # if all we're doing is setting statuses, just update those and get out
    if ( $op eq "setstatus" ) {
        my $query =
          "UPDATE items SET itemlost=?,wthdrawn=?,binding=? WHERE itemnumber=?";
        my @bind = (
            $item->{'itemlost'}, $item->{'wthdrawn'},
            $item->{'binding'},  $item->{'itemnumber'}
        );
        my $sth = $dbh->prepare($query);
        $sth->execute(@bind);
        $sth->finish;
        return undef;
    }
## Now calculate lccalnumber
    my ($cutterextra) =
      itemcalculator( $dbh, $item->{'bibitemnum'}, $item->{'itemcallnumber'} );

    my $query = "UPDATE items SET
barcode=?,itemnotes=?,itemcallnumber=?,notforloan=?,location=?,multivolumepart=?,multivolume=?,stack=?,wthdrawn=?,holdingbranch=?,homebranch=?,cutterextra=?, onloan=?, binding=?";

    my @bind = (
        $item->{'barcode'},        $item->{'notes'},
        $item->{'itemcallnumber'}, $item->{'notforloan'},
        $item->{'location'},       $item->{multivolumepart},
        $item->{multivolume},      $item->{stack},
        $item->{wthdrawn},         $item->{holdingbranch},
        $item->{homebranch},       $cutterextra,
        $item->{onloan},           $item->{binding}
    );
    if ( $item->{'lost'} ne '' ) {
        $query =
"update items set biblioitemnumber=?,barcode=?,itemnotes=?,homebranch=?,
                            itemlost=?,wthdrawn=?,itemcallnumber=?,notforloan=?,
                             location=?,multivolumepart=?,multivolume=?,stack=?,wthdrawn=?,holdingbranch=?,cutterextra=?,onloan=?, binding=?";
        @bind = (
            $item->{'bibitemnum'},     $item->{'barcode'},
            $item->{'notes'},          $item->{'homebranch'},
            $item->{'lost'},           $item->{'wthdrawn'},
            $item->{'itemcallnumber'}, $item->{'notforloan'},
            $item->{'location'},       $item->{multivolumepart},
            $item->{multivolume},      $item->{stack},
            $item->{wthdrawn},         $item->{holdingbranch},
            $cutterextra,              $item->{onloan},
            $item->{binding}
        );
        if ( $item->{homebranch} ) {
            $query .= ",homebranch=?";
            push @bind, $item->{homebranch};
        }
        if ( $item->{holdingbranch} ) {
            $query .= ",holdingbranch=?";
            push @bind, $item->{holdingbranch};
        }
    }
    $query .= " where itemnumber=?";
    push @bind, $item->{'itemnum'};
    if ( $item->{'replacement'} ne '' ) {
        $query =~ s/ where/,replacementprice='$item->{'replacement'}' where/;
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    $sth->finish;
}

=head2 _koha_delete_item

_koha_delete_item( $dbh, $itemnum );

Internal function to delete an item record from the koha tables

=cut

sub _koha_delete_item {
    my ( $dbh, $itemnum ) = @_;

    my $sth = $dbh->prepare("select * from items where itemnumber=?");
    $sth->execute($itemnum);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    my $query = "Insert into deleteditems set ";
    my @bind  = ();
    foreach my $temp ( keys %$data ) {
        $query .= "$temp = ?,";
        push( @bind, $data->{$temp} );
    }
    $query =~ s/\,$//;

    #  print $query;
    $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    $sth->finish;
    $sth = $dbh->prepare("Delete from items where itemnumber=?");
    $sth->execute($itemnum);
    $sth->finish;
}

=head2 _koha_delete_biblio

$error = _koha_delete_biblio($dbh,$biblionumber);

Internal sub for deleting from biblio table -- also saves to deletedbiblio

C<$dbh> - the database handle
C<$biblionumber> - the biblionumber of the biblio to be deleted

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

$error = _koha_delete_biblioitems($dbh,$biblioitemnumber);

Internal sub for deleting from biblioitems table -- also saves to deletedbiblioitems

C<$dbh> - the database handle
C<$biblionumber> - the biblioitemnumber of the biblioitem to be deleted

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

=head2 _koha_delete_items

$error = _koha_delete_items($dbh,$itemnumber);

Internal sub for deleting from items table -- also saves to deleteditems

C<$dbh> - the database handle
C<$itemnumber> - the itemnumber of the item to be deleted

=cut

# FIXME: add error handling

sub _koha_delete_items {
    my ( $dbh, $itemnumber ) = @_;

    # get all the data for this item
    my $sth = $dbh->prepare("SELECT * FROM items WHERE itemnumber=?");
    $sth->execute($itemnumber);

    if ( my $data = $sth->fetchrow_hashref ) {

        # save the record in deleteditems
        # find the fields to save
        my $query = "INSERT INTO deleteditems SET ";
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

        # delete the item
        my $del_sth = $dbh->prepare("DELETE FROM items WHERE itemnumber=?");
        $del_sth->execute($itemnumber);
        $del_sth->finish;
    }
    $sth->finish;
    return undef;
}



=head2 modbiblio

  $biblionumber = &modbiblio($biblio);

Update a biblio record.

C<$biblio> is a reference-to-hash whose keys are the fields in the
biblio table in the Koha database. All fields must be present, not
just the ones you wish to change.

C<&modbiblio> updates the record defined by
C<$biblio-E<gt>{biblionumber}> with the values in C<$biblio>.

C<&modbiblio> returns C<$biblio-E<gt>{biblionumber}> whether it was
successful or not.

=cut

sub modbiblio {
    my ($biblio) = @_;
    my $dbh = C4::Context->dbh;
    my $biblionumber = _koha_modify_biblio( $dbh, $biblio );
    my $record = MARCkoha2marcBiblio( $biblionumber, $biblionumber );
    MARCmodbiblio( $dbh, $biblionumber, $record, "", 0 );
    return ($biblionumber);
}    # sub modbiblio

=head2 modbibitem

&modbibitem($biblioitem)

=cut

sub modbibitem {
    my ($biblioitem) = @_;
    my $dbh = C4::Context->dbh;
    &_koha_modify_biblio( $dbh, $biblioitem );
}    # sub modbibitem


=head2 newitems

$errors = &newitems( $item, @barcodes );

=cut

sub newitems {
    my ( $item, @barcodes ) = @_;
    my $dbh = C4::Context->dbh;
    my $errors;
    my $itemnumber;
    my $error;
    foreach my $barcode (@barcodes) {
        ( $itemnumber, $error ) = &_koha_new_items( $dbh, $item, uc($barcode) );
        $errors .= $error;
        my $MARCitem =
          &MARCkoha2marcItem( $dbh, $item->{biblionumber}, $itemnumber );
        &MARCadditem( $MARCitem, $item->{biblionumber} );
    }
    return ($errors);
}

=head2 moditem

$errors = &moditem( $item, $op );

=cut

sub moditem {
    my ( $item, $op ) = @_;
    my $dbh = C4::Context->dbh;
    &_koha_modify_item( $dbh, $item, $op );

    # if we're just setting statuses, just update items table
    # it's faster and zebra and marc will be synched anyway by the cron job
    unless ( $op eq "setstatus" ) {
        my $MARCitem = &MARCkoha2marcItem( $dbh, $item->{'biblionumber'},
            $item->{'itemnum'} );
        &MARCmoditem( $MARCitem, $item->{biblionumber}, $item->{itemnum},
                      MARCfind_frameworkcode( $item->{biblionumber} ), 0 );
    }
}

=head2 checkitems

$errors = &checkitems( $count, @barcodes );

=cut

sub checkitems {
    my ( $count, @barcodes ) = @_;
    my $dbh = C4::Context->dbh;
    my $error;
    my $sth = $dbh->prepare("Select * from items where barcode=?");
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        $barcodes[$i] = uc $barcodes[$i];
        $sth->execute( $barcodes[$i] );
        if ( my $data = $sth->fetchrow_hashref ) {
            $error .= " Duplicate Barcode: $barcodes[$i]";
        }
    }
    $sth->finish;
    return ($error);
}

=head1  OTHER FUNCTIONS

=head2 char_decode

my $string = char_decode( $string, $encoding );

converts ISO 5426 coded string to UTF-8
sloppy code : should be improved in next issue

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

=head2 PrepareItemrecordDisplay

PrepareItemrecordDisplay($itemrecord,$bibnum,$itemumber);

Returns a hash with all the fields for Display a given item data in a template

=cut

sub PrepareItemrecordDisplay {

    my ( $bibnum, $itemnum ) = @_;

    my $dbh = C4::Context->dbh;
    my $frameworkcode = &MARCfind_frameworkcode( $bibnum );
    my ( $itemtagfield, $itemtagsubfield ) =
      &MARCfind_marc_from_kohafield( $dbh, "items.itemnumber", $frameworkcode );
    my $tagslib = &MARCgettagslib( $dbh, 1, $frameworkcode );
    my $itemrecord = MARCgetitem( $bibnum, $itemnum) if ($itemnum);
    my @loop_data;
    my $authorised_values_sth =
      $dbh->prepare(
"select authorised_value,lib from authorised_values where category=? order by lib"
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
"select branchcode,branchname from branches where branchcode = ? order by branchname"
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
"select branchcode,branchname from branches order by branchname"
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
"select itemtype,description from itemtypes order by description"
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

=head2 nsb_clean

my $string = nsb_clean( $string, $encoding );

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

=head2 zebraopfiles

&zebraopfiles( $dbh, $biblionumber, $record, $folder, $server );

=cut

sub zebraopfiles {

    my ( $dbh, $biblionumber, $record, $folder, $server ) = @_;

    my $op;
    my $zebradir =
      C4::Context->zebraconfig($server)->{directory} . "/" . $folder . "/";
    unless ( opendir( DIR, "$zebradir" ) ) {
        warn "$zebradir not found";
        return;
    }
    closedir DIR;
    my $filename = $zebradir . $biblionumber;

    if ($record) {
        open( OUTPUT, ">", $filename . ".xml" );
        print OUTPUT $record;
        close OUTPUT;
    }
}

=head2 zebraop

zebraop( $dbh, $biblionumber, $op, $server );

=cut

sub zebraop {
###Accepts a $server variable thus we can use it for biblios authorities or other zebra dbs
    my ( $biblionumber, $op, $server ) = @_;
    my $dbh=C4::Context->dbh;
    #warn "SERVER:".$server;
#
# true zebraop commented until indexdata fixes zebraDB crashes (it seems they occur on multiple updates
# at the same time
# replaced by a zebraqueue table, that is filled with zebraop to run.
# the table is emptied by misc/cronjobs/zebraqueue_start.pl script

my $sth=$dbh->prepare("insert into zebraqueue  (biblio_auth_number ,server,operation) values(?,?,?)");
$sth->execute($biblionumber,$server,$op);
$sth->finish;

#
#     my @Zconnbiblio;
#     my $tried     = 0;
#     my $recon     = 0;
#     my $reconnect = 0;
#     my $record;
#     my $shadow;
# 
#   reconnect:
#     $Zconnbiblio[0] = C4::Context->Zconn( $server, 0, 1 );
# 
#     if ( $server eq "biblioserver" ) {
# 
#         # it's unclear to me whether this should be in xml or MARC format
#         # but it is clear it should be nabbed from zebra rather than from
#         # the koha tables
#         $record = GetMarcBiblio($biblionumber);
#         $record = $record->as_xml_record() if $record;
# #            warn "RECORD $biblionumber => ".$record;
#         $shadow="biblioservershadow";
# 
#         #           warn "RECORD $biblionumber => ".$record;
#         $shadow = "biblioservershadow";
# 
#     }
#     elsif ( $server eq "authorityserver" ) {
#         $record = C4::AuthoritiesMarc::XMLgetauthority( $dbh, $biblionumber );
#         $shadow = "authorityservershadow";
#     }    ## Add other servers as necessary
# 
#     my $Zpackage = $Zconnbiblio[0]->package();
#     $Zpackage->option( action => $op );
#     $Zpackage->option( record => $record );
# 
#   retry:
#     $Zpackage->send("update");
#     my $i;
#     my $event;
# 
#     while ( ( $i = ZOOM::event( \@Zconnbiblio ) ) != 0 ) {
#         $event = $Zconnbiblio[0]->last_event();
#         last if $event == ZOOM::Event::ZEND;
#     }
# 
#     my ( $error, $errmsg, $addinfo, $diagset ) = $Zconnbiblio[0]->error_x();
#     if ( $error == 10000 && $reconnect == 0 )
#     {    ## This is serious ZEBRA server is not available -reconnect
#         warn "problem with zebra server connection";
#         $reconnect = 1;
#         my $res = system('sc start "Z39.50 Server" >c:/zebraserver/error.log');
# 
#         #warn "Trying to restart ZEBRA Server";
#         #goto "reconnect";
#     }
#     elsif ( $error == 10007 && $tried < 2 )
#     {    ## timeout --another 30 looonng seconds for this update
#         $tried = $tried + 1;
#         warn "warn: timeout, trying again";
#         goto "retry";
#     }
#     elsif ( $error == 10004 && $recon == 0 ) {    ##Lost connection -reconnect
#         $recon = 1;
#         warn "error: reconnecting to zebra";
#         goto "reconnect";
# 
#    # as a last resort, we save the data to the filesystem to be indexed in batch
#     }
#     elsif ($error) {
#         warn
# "Error-$server   $op $biblionumber /errcode:, $error, /MSG:,$errmsg,$addinfo \n";
#         $Zpackage->destroy();
#         $Zconnbiblio[0]->destroy();
#         zebraopfiles( $dbh, $biblionumber, $record, $op, $server );
#         return;
#     }
#     if ( C4::Context->$shadow ) {
#         $Zpackage->send('commit');
#         while ( ( $i = ZOOM::event( \@Zconnbiblio ) ) != 0 ) {
# 
#             #waiting zebra to finish;
#          }
#     }
#     $Zpackage->destroy();
}

=head2 calculatelc

$lc = calculatelc($classification);

=cut

sub calculatelc {
    my ($classification) = @_;
    $classification =~ s/^\s+|\s+$//g;
    my $i = 0;
    my $lc2;
    my $lc1;

    for ( $i = 0 ; $i < length($classification) ; $i++ ) {
        my $c = ( substr( $classification, $i, 1 ) );
        if ( $c ge '0' && $c le '9' ) {

            $lc2 = substr( $classification, $i );
            last;
        }
        else {
            $lc1 .= substr( $classification, $i, 1 );

        }
    }    #while

    my $other = length($lc1);
    if ( !$lc1 ) {
        $other = 0;
    }

    my $extras;
    if ( $other < 4 ) {
        for ( 1 .. ( 4 - $other ) ) {
            $extras .= "0";
        }
    }
    $lc1 .= $extras;
    $lc2 =~ s/^ //g;

    $lc2 =~ s/ //g;
    $extras = "";
    ##Find the decimal part of $lc2
    my $pos = index( $lc2, "." );
    if ( $pos < 0 ) { $pos = length($lc2); }
    if ( $pos >= 0 && $pos < 5 ) {
        ##Pad lc2 with zeros to create a 5digit decimal needed in marc record to sort as numeric

        for ( 1 .. ( 5 - $pos ) ) {
            $extras .= "0";
        }
    }
    $lc2 = $extras . $lc2;
    return ( $lc1 . $lc2 );
}

=head2 itemcalculator

$cutterextra = itemcalculator( $dbh, $biblioitem, $callnumber );

=cut

sub itemcalculator {
    my ( $dbh, $biblioitem, $callnumber ) = @_;
    my $sth =
      $dbh->prepare(
"select classification, subclass from biblioitems where biblioitemnumber=?"
      );

    $sth->execute($biblioitem);
    my ( $classification, $subclass ) = $sth->fetchrow;
    my $all         = $classification . " " . $subclass;
    my $total       = length($all);
    my $cutterextra = substr( $callnumber, $total - 1 );

    return $cutterextra;
}

END { }    # module clean-up code here (global destructor)

1;

__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

Joshua Ferraro jmf@liblime.com

=cut

# $Id$
# $Log$
# Revision 1.191  2007/03/29 09:42:13  tipaul
# adding default value new feature into cataloguing. The system (definition) part has already been added by toins
#
# Revision 1.190  2007/03/29 08:45:19  hdl
# Deleting ignore_errors(1) pour MARC::Charset
#
# Revision 1.189  2007/03/28 10:39:16  hdl
# removing $dbh as a parameter in AuthoritiesMarc functions
# And reporting all differences into the scripts taht relies on those functions.
#
# Revision 1.188  2007/03/09 14:31:47  tipaul
# rel_3_0 moved to HEAD
#
# Revision 1.178.2.59  2007/02/28 10:01:13  toins
# reporting bug fix from 2.2.7.1 to rel_3_0
# LOG was :
# 		BUGFIX/improvement : limiting MARCsubject to 610 as 676 is dewey, and is somewhere else
#
# Revision 1.178.2.58  2007/02/05 16:50:01  toins
# fix a mod_perl bug:
# There was a global var modified into an internal function in {MARC|ISBD}detail.pl.
# Moving this function in Biblio.pm
#
# Revision 1.178.2.57  2007/01/25 09:37:58  tipaul
# removing warn
#
# Revision 1.178.2.56  2007/01/24 13:50:26  tipaul
# Acquisition fix
# removing newbiblio & newbiblioitems subs.
# adding Koha2Marc
#
# IMHO, all biblio handling is better handled if they are done in a single place, the subs with MARC::Record as parameters.
# newbiblio & newbiblioitems where koha 1.x subs, that are called when MARC=OFF (which is not working anymore in koha 3.0, unless someone reintroduce it), and in acquisition module.
# The Koha2Marc sub moves a hash (with biblio/biblioitems subfield as keys) into a MARC::Record, that can be used to call NewBiblio, the standard biblio manager sub.
#
# Revision 1.178.2.55  2007/01/17 18:07:17  alaurin
# bugfixing for zebraqueue_start and biblio.pm :
#
# 	- Zebraqueue_start : restoring function of deletion in zebraqueue DB list
#
# 	-biblio.pm : changing method of default_record_format, now we have :
# 		MARC::File::XML->default_record_format(C4::Context->preference('marcflavour'));
#
# 	with this line the encoding in zebra seems to be ok (in unimarc and marc21)
#
# Revision 1.178.2.54  2007/01/16 15:00:03  tipaul
# donc try to delete the biblio in koha, just fill zebraqueue table !
#
# Revision 1.178.2.53  2007/01/16 10:24:11  tipaul
# BUGFIXING :
# when modifying or deleting an item, the biblio frameworkcode was emptied.
#
# Revision 1.178.2.52  2007/01/15 17:20:55  toins
# *** empty log message ***
#
# Revision 1.178.2.51  2007/01/15 15:16:44  hdl
# Uncommenting zebraop.
#
# Revision 1.178.2.50  2007/01/15 14:59:09  hdl
# Adding creation of an unexpected serial any time.
# +
# USING Date::Calc and not Date::Manip.
# WARNING : There are still some Bugs in next issue date management. (Date::Calc donot wrap easily next year calculation.)
#
# Revision 1.178.2.49  2007/01/12 10:12:30  toins
# writing $record->as_formatted in the log when Modifying an item.
#
# Revision 1.178.2.48  2007/01/11 16:33:04  toins
# write $record->as_formatted into the log.
#
# Revision 1.178.2.47  2007/01/10 16:46:27  toins
# Theses modules need to use C4::Log.
#
# Revision 1.178.2.46  2007/01/10 16:31:15  toins
# new systems preferences :
#  - CataloguingLog (log the update/creation/deletion of a notice if set to 1)
#  - BorrowersLog ( idem for borrowers )
#  - IssueLog (log all issue if set to 1)
#  - ReturnLog (log all return if set to 1)
#  - SusbcriptionLog (log all creation/deletion/update of a subcription)
#
# All of theses are in a new tab called 'LOGFeatures' in systempreferences.pl
#
# Revision 1.178.2.45  2007/01/09 10:31:09  toins
# sync with dev_week. ( new function : GetMarcSeries )
#
# Revision 1.178.2.44  2007/01/04 17:41:32  tipaul
# 2 major bugfixes :
# - deletion of an item deleted the whole biblio because of a wrong API
# - create an item was bugguy for default framework
#
# Revision 1.178.2.43  2006/12/22 15:09:53  toins
# removing C4::Database;
#
# Revision 1.178.2.42  2006/12/20 16:51:00  tipaul
# ZEBRA update :
# - adding a new table : when a biblio is added/modified/ deleted, an entry is entered in this table
# - the zebraqueue_start.pl script read it & does the stuff.
#
# code coming from head (tumer). it can be run every minut instead of once every day for dev_week code.
#
# I just have commented the previous code (=real time update) in Biblio.pm, we will be able to reactivate it once indexdata fixes zebra update bug !
#
# Revision 1.178.2.41  2006/12/20 08:54:44  toins
# GetXmlBiblio wasn't exported.
#
# Revision 1.178.2.40  2006/12/19 16:45:56  alaurin
# bugfixing, for zebra and authorities
#
# Revision 1.178.2.39  2006/12/08 17:55:44  toins
# GetMarcAuthors now get authors for all subfields
#
# Revision 1.178.2.38  2006/12/07 15:42:14  toins
# synching opac & intranet.
# fix some broken link & bugs.
# removing warn compilation.
#
# Revision 1.178.2.37  2006/12/07 11:09:39  tipaul
# MAJOR FIX :
# the ->destroy() line destroys the zebra connection. When we are running koha as cgi, it's not a problem, as the script dies after each request.
# BUT for bulkmarcimport & mod_perl, the zebra conn must be persistant.
#
# Revision 1.178.2.36  2006/12/06 16:54:21  alaurin
# restore function zebraop for delete biblios :
#
# 1) restore C4::Circulation::Circ2::itemissues, (was missing)
# 2) restore zebraop value : delete_record
#
# Revision 1.178.2.35  2006/12/06 10:02:12  alaurin
# bugfixing for delete a biblio :
#
# restore itemissue fonction .... :
#
# other is pointed, zebra error 224... for biblio is not deleted in zebra ..
# ....
#
# Revision 1.178.2.34  2006/12/06 09:14:25  toins
# Correct the link to the MARC subjects.
#
# Revision 1.178.2.33  2006/12/05 11:35:29  toins
# Biblio.pm cleaned.
# additionalauthors, bibliosubject, bibliosubtitle tables are now unused.
# Some functions renamed according to the coding guidelines.
#
# Revision 1.178.2.32  2006/12/04 17:39:57  alaurin
# bugfix :
#
# restore zebraop for update zebra
#
# Revision 1.178.2.31  2006/12/01 17:00:19  tipaul
# additem needs $frameworkcode
#
# Revision 1.178.2.30  2006/11/30 18:23:51  toins
# theses scripts don't need to use C4::Search.
#
# Revision 1.178.2.29  2006/11/30 17:17:01  toins
# following functions moved from Search.p to Biblio.pm :
# - bibdata
# - itemsissues
# - addauthor
# - getMARCNotes
# - getMARCsubjects
#
# Revision 1.178.2.28  2006/11/28 15:15:03  toins
# sync with dev_week.
# (deleteditems table wasn't getting populaated because the execute was commented out. This puts it back
#     -- some table changes are needed as well, I'll commit those separately.)
#
# Revision 1.178.2.27  2006/11/20 16:52:05  alaurin
# minor bugfixing :
#
# correcting in _koha_modify_biblioitem : restore the biblionumber line .
#
# now the sql update of biblioitems is ok ....
#
# Revision 1.178.2.26  2006/11/17 14:57:21  tipaul
# code cleaning : moving bornum, borrnum, bornumber to a correct "borrowernumber"
#
# Revision 1.178.2.25  2006/11/17 13:18:58  tipaul
# code cleaning : removing use of "bib", and replacing with "biblionumber"
#
# WARNING : I tried to do carefully, but there are probably some mistakes.
# So if you encounter a problem you didn't have before, look for this change !!!
# anyway, I urge everybody to use only "biblionumber", instead of "bib", "bi", "biblio" or anything else. will be easier to maintain !!!
#
# Revision 1.178.2.24  2006/11/17 11:18:47  tipaul
# * removing useless subs
# * moving bibid to biblionumber where needed
#
# Revision 1.178.2.23  2006/11/17 09:39:04  btoumi
# bug fix double declaration of variable in same function
#
# Revision 1.178.2.22  2006/11/15 15:15:50  hdl
# Final First Version for New Facility for subscription management.
#
# Now
# use serials-collection.pl for history display
# and serials-edit.pl for serial edition
# subscription add and detail adds a new branch information to help IndependantBranches Library to manage different subscriptions for a serial
#
# This is aimed at replacing serials-receive and statecollection.
#
# Revision 1.178.2.21  2006/11/15 14:49:38  tipaul
# in some cases, there are invalid utf8 chars in XML (at least in SANOP). this commit remove them on the fly.
# Not sure it's a good idea to keep them in biblio.pm, let me know your opinion on koha-devel if you think it's a bad idea...
#
# Revision 1.178.2.20  2006/10/31 17:20:49  toins
# * moving bibitemdata from search to here.
# * using _koha_modify_biblio instead of OLDmodbiblio.
#
# Revision 1.178.2.19  2006/10/20 15:26:41  toins
# sync with dev_week.
#
# Revision 1.178.2.18  2006/10/19 11:57:04  btoumi
# bug fix : wrong syntax in sub call
#
# Revision 1.178.2.17  2006/10/17 09:54:42  toins
# ccode (re)-integration.
#
# Revision 1.178.2.16  2006/10/16 16:20:34  toins
# MARCgetbiblio cleaned up.
#
# Revision 1.178.2.15  2006/10/11 14:26:56  tipaul
# handling of UNIMARC :
# - better management of field 100 = automatic creation of the field if needed & filling encoding to unicode.
# - better management of encoding (MARC::File::XML new_from_xml()). This fix works only on my own version of M:F:XML, i think the actual one is buggy & have reported the problem to perl4lib mailing list
# - fixing a bug on MARCgetitem, that uses biblioitems.marc and not biblioitems.marcxml
#
# Revision 1.178.2.14  2006/10/11 07:59:36  tipaul
# removing hardcoded ccode fiels in biblioitems
#
# Revision 1.178.2.13  2006/10/10 14:21:24  toins
# Biblio.pm now returns a true value.
#
# Revision 1.178.2.12  2006/10/09 16:44:23  toins
# Sync with dev_week.
#
# Revision 1.178.2.11  2006/10/06 13:23:49  toins
# Synch with dev_week.
#
# Revision 1.178.2.10  2006/10/02 09:32:02  hdl
# Adding GetItemStatus and GetItemLocation function in order to make serials-receive.pl work.
#
# *************WARNING.***************
# tested for UNIMARC and using 'marcflavour' system preferences to set defaut_record_format.
#
# Revision 1.178.2.9  2006/09/26 07:54:20  hdl
# Bug FIX: Correct accents for UNIMARC biblio MARC details.
# (Adding the use of default_record_format in MARCgetbiblio if UNIMARC marcflavour is chosen. This should be widely used as soon as we use xml records)
#
# Revision 1.178.2.8  2006/09/25 14:46:22  hdl
# Now using iso2709 MARC data for MARC.
# (Works better for accents than XML)
#
# Revision 1.178.2.7  2006/09/20 13:44:14  hdl
# Bug Fixing : Cataloguing was broken for UNIMARC.
# Please test.

