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
# use utf8;
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use ZOOM;

use C4::Context;
use C4::Koha;
use C4::Branch;
use C4::Dates qw/format_date/;
use C4::Log; # logaction
use C4::ClassSource;
use C4::Charset;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	$VERSION = 1.00;

	require Exporter;
	@ISA = qw( Exporter );

	# to add biblios
# EXPORTED FUNCTIONS.
	push @EXPORT, qw( 
		&AddBiblio
	);

	# to get something
	push @EXPORT, qw(
		&GetBiblio
		&GetBiblioData
		&GetBiblioItemData
		&GetBiblioItemInfosOf
		&GetBiblioItemByBiblioNumber
		&GetBiblioFromItemNumber

		&GetMarcNotes
		&GetMarcSubjects
		&GetMarcBiblio
		&GetMarcAuthors
		&GetMarcSeries
		GetMarcUrls
		&GetUsedMarcStructure
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
		&ModBiblioframework
		&ModZebra
	);
	# To delete something
	push @EXPORT, qw(
		&DelBiblio
	);

    # To link headings in a bib record
    # to authority records.
    push @EXPORT, qw(
        &LinkBibHeadingsToAuthorities
    );

	# Internal functions
	# those functions are exported but should not be used
	# they are usefull is few circumstances, so are exported.
	# but don't use them unless you're a core developer ;-)
	push @EXPORT, qw(
		&ModBiblioMarc
	);
	# Others functions
	push @EXPORT, qw(
		&TransformMarcToKoha
		&TransformHtmlToMarc2
		&TransformHtmlToMarc
		&TransformHtmlToXml
		&PrepareItemrecordDisplay
		&GetNoZebraIndexes
	);
}

# because of interdependencies between
# C4::Search, C4::Heading, and C4::Biblio,
# 'use C4::Heading' must occur after
# the exports have been defined.
use C4::Heading;

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

=back

Exported function (core API) for adding a new biblio to koha.

The first argument is a C<MARC::Record> object containing the
bib to add, while the second argument is the desired MARC
framework code.

This function also accepts a third, optional argument: a hashref
to additional options.  The only defined option is C<defer_marc_save>,
which if present and mapped to a true value, causes C<AddBiblio>
to omit the call to save the MARC in C<bibilioitems.marc>
and C<biblioitems.marcxml>  This option is provided B<only>
for the use of scripts such as C<bulkmarcimport.pl> that may need
to do some manipulation of the MARC record for item parsing before
saving it and which cannot afford the performance hit of saving
the MARC record twice.  Consequently, do not use that option
unless you can guarantee that C<ModBiblioMarc> will be called.

=cut

sub AddBiblio {
    my $record = shift;
    my $frameworkcode = shift;
    my $options = @_ ? shift : undef;
    my $defer_marc_save = 0;
    if (defined $options and exists $options->{'defer_marc_save'} and $options->{'defer_marc_save'}) {
        $defer_marc_save = 1;
    }

    my ($biblionumber,$biblioitemnumber,$error);
    my $dbh = C4::Context->dbh;
    # transform the data into koha-table style data
    my $olddata = TransformMarcToKoha( $dbh, $record, $frameworkcode );
    ($biblionumber,$error) = _koha_add_biblio( $dbh, $olddata, $frameworkcode );
    $olddata->{'biblionumber'} = $biblionumber;
    ($biblioitemnumber,$error) = _koha_add_biblioitem( $dbh, $olddata );

    _koha_marc_update_bib_ids($record, $frameworkcode, $biblionumber, $biblioitemnumber);

    # update MARC subfield that stores biblioitems.cn_sort
    _koha_marc_update_biblioitem_cn_sort($record, $olddata, $frameworkcode);
    
    # now add the record
    $biblionumber = ModBiblioMarc( $record, $biblionumber, $frameworkcode ) unless $defer_marc_save;
      
    logaction("CATALOGUING", "ADD", $biblionumber, "biblio") if C4::Context->preference("CataloguingLog");

    return ( $biblionumber, $biblioitemnumber );
}

=head2 ModBiblio

=over 4

    ModBiblio( $record,$biblionumber,$frameworkcode);

=back

Replace an existing bib record identified by C<$biblionumber>
with one supplied by the MARC::Record object C<$record>.  The embedded
item, biblioitem, and biblionumber fields from the previous
version of the bib record replace any such fields of those tags that
are present in C<$record>.  Consequently, ModBiblio() is not
to be used to try to modify item records.

C<$frameworkcode> specifies the MARC framework to use
when storing the modified bib record; among other things,
this controls how MARC fields get mapped to display columns
in the C<biblio> and C<biblioitems> tables, as well as
which fields are used to store embedded item, biblioitem,
and biblionumber data for indexing.

=cut

sub ModBiblio {
    my ( $record, $biblionumber, $frameworkcode ) = @_;
    if (C4::Context->preference("CataloguingLog")) {
        my $newrecord = GetMarcBiblio($biblionumber);
        logaction("CATALOGUING", "MODIFY", $biblionumber, "BEFORE=>".$newrecord->as_formatted);
    }
    
    my $dbh = C4::Context->dbh;
    
    $frameworkcode = "" unless $frameworkcode;

    # get the items before and append them to the biblio before updating the record, atm we just have the biblio
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField("items.itemnumber",$frameworkcode);
    my $oldRecord = GetMarcBiblio( $biblionumber );

    # delete any item fields from incoming record to avoid
    # duplication or incorrect data - use AddItem() or ModItem()
    # to change items
    foreach my $field ($record->field($itemtag)) {
        $record->delete_field($field);
    }
    
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

    # load the koha-table data object
    my $oldbiblio = TransformMarcToKoha( $dbh, $record, $frameworkcode );

    # update MARC subfield that stores biblioitems.cn_sort
    _koha_marc_update_biblioitem_cn_sort($record, $oldbiblio, $frameworkcode);

    # update the MARC record (that now contains biblio and items) with the new record data
    &ModBiblioMarc( $record, $biblionumber, $frameworkcode );
    
    # modify the other koha tables
    _koha_modify_biblio( $dbh, $oldbiblio, $frameworkcode );
    _koha_modify_biblioitem_nonmarc( $dbh, $oldbiblio );
    return 1;
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
    my $oldRecord;
    if (C4::Context->preference("NoZebra")) {
        # only NoZebra indexing needs to have
        # the previous version of the record
        $oldRecord = GetMarcBiblio($biblionumber);
    }
    ModZebra($biblionumber, "recordDelete", "biblioserver", $oldRecord, undef);

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

    logaction("CATALOGUING", "DELETE", $biblionumber, "") if C4::Context->preference("CataloguingLog");

    return;
}

=head2 LinkBibHeadingsToAuthorities

=over 4

my $headings_linked = LinkBibHeadingsToAuthorities($marc);

=back

Links bib headings to authority records by checking
each authority-controlled field in the C<MARC::Record>
object C<$marc>, looking for a matching authority record,
and setting the linking subfield $9 to the ID of that
authority record.  

If no matching authority exists, or if multiple
authorities match, no $9 will be added, and any 
existing one inthe field will be deleted.

Returns the number of heading links changed in the
MARC record.

=cut

sub LinkBibHeadingsToAuthorities {
    my $bib = shift;

    my $num_headings_changed = 0;
    foreach my $field ($bib->fields()) {
        my $heading = C4::Heading->new_from_bib_field($field);    
        next unless defined $heading;

        # check existing $9
        my $current_link = $field->subfield('9');

        # look for matching authorities
        my $authorities = $heading->authorities();

        # want only one exact match
        if ($#{ $authorities } == 0) {
            my $authority = MARC::Record->new_from_usmarc($authorities->[0]);
            my $authid = $authority->field('001')->data();
            next if defined $current_link and $current_link eq $authid;

            $field->delete_subfield(code => '9') if defined $current_link;
            $field->add_subfields('9', $authid);
            $num_headings_changed++;
        } else {
            if (defined $current_link) {
                $field->delete_subfield(code => '9');
                $num_headings_changed++;
            }
        }

    }
    return $num_headings_changed;
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

  #  my $query =  C4::Context->preference('item-level_itypes') ? 
    #   " SELECT * , biblioitems.notes AS bnotes, biblio.notes
    #       FROM biblio
    #        LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
    #       WHERE biblio.biblionumber = ?
    #        AND biblioitems.biblionumber = biblio.biblionumber
    #";
    
    my $query = " SELECT * , biblioitems.notes AS bnotes, itemtypes.notforloan as bi_notforloan, biblio.notes
            FROM biblio
            LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
            LEFT JOIN itemtypes ON biblioitems.itemtype = itemtypes.itemtype
            WHERE biblio.biblionumber = ?
            AND biblioitems.biblionumber = biblio.biblionumber ";
         
    my $sth = $dbh->prepare($query);
    $sth->execute($bibnum);
    my $data;
    $data = $sth->fetchrow_hashref;
    $sth->finish;

    return ($data);
}    # sub GetBiblioData

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
        FROM biblio LEFT JOIN biblioitems on biblio.biblionumber=biblioitems.biblionumber ";
    unless(C4::Context->preference('item-level_itypes')) { 
        $query .= "LEFT JOIN itemtypes on biblioitems.itemtype=itemtypes.itemtype ";
    }    
    $query .= " WHERE biblioitemnumber = ? ";
    my $sth       =  $dbh->prepare($query);
    my $data;
    $sth->execute($biblioitemnumber);
    $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ($data);
}    # sub &GetBiblioItemData

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

$item = &GetBiblioFromItemNumber($itemnumber,$barcode);

Looks up the item with the given itemnumber. if undef, try the barcode.

C<&itemnodata> returns a reference-to-hash whose keys are the fields
from the C<biblio>, C<biblioitems>, and C<items> tables in the Koha
database.

=back

=cut

#'
sub GetBiblioFromItemNumber {
    my ( $itemnumber, $barcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if($itemnumber) {
        $sth=$dbh->prepare(  "SELECT * FROM items 
            LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
            LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber
             WHERE items.itemnumber = ?") ; 
        $sth->execute($itemnumber);
    } else {
        $sth=$dbh->prepare(  "SELECT * FROM items 
            LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
            LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber
             WHERE items.barcode = ?") ; 
        $sth->execute($barcode);
    }
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

# cache for results of GetMarcStructure -- needed
# for batch jobs
our $marc_structure_cache;

sub GetMarcStructure {
    my ( $forlibrarian, $frameworkcode ) = @_;
    my $dbh=C4::Context->dbh;
    $frameworkcode = "" unless $frameworkcode;

    if (defined $marc_structure_cache and exists $marc_structure_cache->{$forlibrarian}->{$frameworkcode}) {
        return $marc_structure_cache->{$forlibrarian}->{$frameworkcode};
    }

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
        $res->{$tag}->{tab}        = "";
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

    $marc_structure_cache->{$forlibrarian}->{$frameworkcode} = $res;

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

my $record = GetMarcBiblio($biblionumber);

=back

Returns MARC::Record representing bib identified by
C<$biblionumber>.  If no bib exists, returns undef.
The MARC record contains both biblio & item data.

=cut

sub GetMarcBiblio {
    my $biblionumber = shift;
    my $dbh          = C4::Context->dbh;
    my $sth          =
      $dbh->prepare("SELECT marcxml FROM biblioitems WHERE biblionumber=? ");
    $sth->execute($biblionumber);
    my $row = $sth->fetchrow_hashref;
    my $marcxml = StripNonXmlChars($row->{'marcxml'});
     MARC::File::XML->default_record_format(C4::Context->preference('marcflavour'));
    my $record = MARC::Record->new();
    if ($marcxml) {
        $record = eval {MARC::Record::new_from_xml( $marcxml, "utf8", C4::Context->preference('marcflavour'))};
        if ($@) {warn " problem with :$biblionumber : $@ \n$marcxml";}
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
    $tag, $subf[$i][0],$subf[$i][1], '', $taglib, $category);
Retrieve the complete description for a given authorised value.

Now takes $category and $value pair too.
my $auth_value_desc =GetAuthorisedValueDesc(
    '','', 'DVD' ,'','','CCODE');

=back

=cut

sub GetAuthorisedValueDesc {
    my ( $tag, $subfield, $value, $framework, $tagslib, $category ) = @_;
    my $dbh = C4::Context->dbh;

    if (!$category) {
#---- branch
        if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
            return C4::Branch::GetBranchName($value);
        }

#---- itemtypes
        if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "itemtypes" ) {
            return getitemtypeinfo($value)->{description};
        }

#---- "true" authorized value
        $category = $tagslib->{$tag}->{$subfield}->{'authorised_value'}
    }

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
        # if there is an authority link, build the link with an= subfield9
        my $subfield9 = $field->subfield('9');
        for my $subject_subfield (@subfields ) {
            # don't load unimarc subfields 3,4,5
            next if (($marcflavour eq "UNIMARC") and ($subject_subfield->[0] =~ /3|4|5/ ) );
            my $code = $subject_subfield->[0];
            my $value = $subject_subfield->[1];
            my $linkvalue = $value;
            $linkvalue =~ s/(\(|\))//g;
            my $operator = " and " unless $counter==0;
            if ($subfield9) {
                @link_loop = ({'limit' => 'an' ,link => "$subfield9" });
            } else {
                push @link_loop, {'limit' => 'su', link => $linkvalue, operator => $operator };
            }
            my $separator = C4::Context->preference("authoritysep") unless $counter==0;
            # ignore $9
            my @this_link_loop = @link_loop;
            push @subfields_loop, {code => $code, value => $value, link_loop => \@this_link_loop, separator => $separator} unless ($subject_subfield->[0] eq 9 );
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
        $mintag = "700";
        $maxtag = "712";
    }
    else {
        return;
    }
    my @marcauthors;

    foreach my $field ( $record->fields ) {
        next unless $field->tag() >= $mintag && $field->tag() <= $maxtag;
        my @subfields_loop;
        my @link_loop;
        my @subfields = $field->subfields();
        my $count_auth = 0;
        # if there is an authority link, build the link with Koha-Auth-Number: subfield9
        my $subfield9 = $field->subfield('9');
        for my $authors_subfield (@subfields) {
            # don't load unimarc subfields 3, 5
            next if ($marcflavour eq 'UNIMARC' and ($authors_subfield->[0] =~ /3|5/ ) );
            my $subfieldcode = $authors_subfield->[0];
            my $value = $authors_subfield->[1];
            my $linkvalue = $value;
            $linkvalue =~ s/(\(|\))//g;
            my $operator = " and " unless $count_auth==0;
            # if we have an authority link, use that as the link, otherwise use standard searching
            if ($subfield9) {
                @link_loop = ({'limit' => 'an' ,link => "$subfield9" });
            }
            else {
                # reset $linkvalue if UNIMARC author responsibility
                if ( $marcflavour eq 'UNIMARC' and ($authors_subfield->[0] eq "4")) {
                    $linkvalue = "(".GetAuthorisedValueDesc( $field->tag(), $authors_subfield->[0], $authors_subfield->[1], '', $tagslib ).")";
                }
                push @link_loop, {'limit' => 'au', link => $linkvalue, operator => $operator };
            }
            $value = GetAuthorisedValueDesc( $field->tag(), $authors_subfield->[0], $authors_subfield->[1], '', $tagslib ) if ( $marcflavour eq 'UNIMARC' and ($authors_subfield->[0] =~/4/));
            my @this_link_loop = @link_loop;
            my $separator = C4::Context->preference("authoritysep") unless $count_auth==0;
            push @subfields_loop, {code => $subfieldcode, value => $value, link_loop => \@this_link_loop, separator => $separator} unless ($authors_subfield->[0] == 9 );
            $count_auth++;
        }
        push @marcauthors, { MARCAUTHOR_SUBFIELDS_LOOP => \@subfields_loop };
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
        if($marcflavour eq 'MARC21') {
            my $s3 = $field->subfield('3');
            my $link = $field->subfield('y');
			unless($url =~ /^\w+:/) {
				if($field->indicator(1) eq '7') {
					$url = $field->subfield('2') . "://" . $url;
				} elsif ($field->indicator(1) eq '1') {
					$url = 'ftp://' . $url;
				} else {  
					#  properly, this should be if ind1=4,
					#  however we will assume http protocol since we're building a link.
					$url = 'http://' . $url;
				}
			}
			# TODO handle ind 2 (relationship)
        	$marcurl = {  MARCURL => $url,
                      notes => \@notes,
            };
            $marcurl->{'linktext'} = $link || $s3 || C4::Context->preference('URLLinkText') || $url ;;
            $marcurl->{'part'} = $s3 if($link);
            $marcurl->{'toc'} = 1 if($s3 =~ /^[Tt]able/) ;
        } else {
            $marcurl->{'linktext'} = $url || C4::Context->preference('URLLinkText') ;
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
    if (C4::Context->preference('marcflavour') eq 'UNIMARC' and !$unimarc_and_100_exist) {
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
        'tag_010_indicator1_531951' ,
        'tag_010_indicator2_531951' ,
        'tag_010_code_a_531951_145735' ,
        'tag_010_subfield_a_531951_145735' ,
        'tag_200_indicator1_873510' ,
        'tag_200_indicator2_873510' ,
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
   
    # explicitly turn on the UTF-8 flag for all
    # 'tag_' parameters to avoid incorrect character
    # conversion later on
    my $cgi_params = $cgi->Vars;
    foreach my $param_name (keys %$cgi_params) {
        if ($param_name =~ /^tag_/) {
            my $param_value = $cgi_params->{$param_name};
            if (utf8::decode($param_value)) {
                $cgi_params->{$param_name} = $param_value;
            } 
            # FIXME - need to do something if string is not valid UTF-8
        }
    }
   
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
        elsif ($param =~ /^tag_(\d*)_indicator1_/){ # new field start when having 'input name="..._indicator1_..."
            my $tag  = $1;
            
            my $ind1 = substr($cgi->param($param),0,1);
            my $ind2 = substr($cgi->param($params->[$i+1]),0,1);
            $newfield=0;
            my $j=$i+2;
            
            if($tag < 10){ # no code for theses fields
    # in MARC editor, 000 contains the leader.
                if ($tag eq '000' ) {
                    $record->leader($cgi->param($params->[$j+1])) if length($cgi->param($params->[$j+1]))==24;
    # between 001 and 009 (included)
                } elsif ($cgi->param($params->[$j+1]) ne '') {
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
                        if($cgi->param($params->[$j+1]) ne ''){  # only if there is a value (code => value)
                            $newfield->add_subfields(
                                $cgi->param($inner_param) => $cgi->param($params->[$j+1])
                            );
                        }
                    } else {
                        if ( $cgi->param($params->[$j+1]) ne '' ) { # creating only if there is a value (code => value)
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

# cache inverted MARC field map
our $inverted_field_map;

=head2 TransformMarcToKoha

=over 4

    $result = TransformMarcToKoha( $dbh, $record, $frameworkcode )

=back

Extract data from a MARC bib record into a hashref representing
Koha biblio, biblioitems, and items fields. 

=cut
sub TransformMarcToKoha {
    my ( $dbh, $record, $frameworkcode, $limit_table ) = @_;

    my $result;

    unless (defined $inverted_field_map) {
        $inverted_field_map = _get_inverted_marc_field_map();
    }

    my %tables = ();
    if ($limit_table eq 'items') {
        $tables{'items'} = 1;
    } else {
        $tables{'items'} = 1;
        $tables{'biblio'} = 1;
        $tables{'biblioitems'} = 1;
    }

    # traverse through record
    MARCFIELD: foreach my $field ($record->fields()) {
        my $tag = $field->tag();
        next MARCFIELD unless exists $inverted_field_map->{$frameworkcode}->{$tag};
        if ($field->is_control_field()) {
            my $kohafields = $inverted_field_map->{$frameworkcode}->{$tag}->{list};
            ENTRY: foreach my $entry (@{ $kohafields }) {
                my ($subfield, $table, $column) = @{ $entry };
                next ENTRY unless exists $tables{$table};
                my $key = _disambiguate($table, $column);
                if ($result->{$key}) {
                    unless (($key eq "biblionumber" or $key eq "biblioitemnumber") and ($field->data() eq "")) {
                        $result->{$key} .= " | " . $field->data();
                    }
                } else {
                    $result->{$key} = $field->data();
                }
            }
        } else {
            # deal with subfields
            MARCSUBFIELD: foreach my $sf ($field->subfields()) {
                my $code = $sf->[0];
                next MARCSUBFIELD unless exists $inverted_field_map->{$frameworkcode}->{$tag}->{sfs}->{$code};
                my $value = $sf->[1];
                SFENTRY: foreach my $entry (@{ $inverted_field_map->{$frameworkcode}->{$tag}->{sfs}->{$code} }) {
                    my ($table, $column) = @{ $entry };
                    next SFENTRY unless exists $tables{$table};
                    my $key = _disambiguate($table, $column);
                    if ($result->{$key}) {
                        unless (($key eq "biblionumber" or $key eq "biblioitemnumber") and ($value eq "")) {
                            $result->{$key} .= " | " . $value;
                        }
                    } else {
                        $result->{$key} = $value;
                    }
                }
            }
        }
    }

    # modify copyrightdate to keep only the 1st year found
    if (exists $result->{'copyrightdate'}) {
        my $temp = $result->{'copyrightdate'};
        $temp =~ m/c(\d\d\d\d)/;    # search cYYYY first
        if ( $1 > 0 ) {
            $result->{'copyrightdate'} = $1;
        }
        else {                      # if no cYYYY, get the 1st date.
            $temp =~ m/(\d\d\d\d)/;
            $result->{'copyrightdate'} = $1;
        }
    }

    # modify publicationyear to keep only the 1st year found
    if (exists $result->{'publicationyear'}) {
        my $temp = $result->{'publicationyear'};
        $temp =~ m/c(\d\d\d\d)/;    # search cYYYY first
        if ( $1 > 0 ) {
            $result->{'publicationyear'} = $1;
        }
        else {                      # if no cYYYY, get the 1st date.
            $temp =~ m/(\d\d\d\d)/;
            $result->{'publicationyear'} = $1;
        }
    }

    return $result;
}

sub _get_inverted_marc_field_map {
    my $field_map = {};
    my $relations = C4::Context->marcfromkohafield;

    foreach my $frameworkcode (keys %{ $relations }) {
        foreach my $kohafield (keys %{ $relations->{$frameworkcode} }) {
            my $tag = $relations->{$frameworkcode}->{$kohafield}->[0];
            my $subfield = $relations->{$frameworkcode}->{$kohafield}->[1];
            my ($table, $column) = split /[.]/, $kohafield, 2;
            push @{ $field_map->{$frameworkcode}->{$tag}->{list} }, [ $subfield, $table, $column ];
            push @{ $field_map->{$frameworkcode}->{$tag}->{sfs}->{$subfield} }, [ $table, $column ];
        }
    }
    return $field_map;
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


=head2 PrepareItemrecordDisplay

=over 4

PrepareItemrecordDisplay($itemrecord,$bibnum,$itemumber);

Returns a hash with all the fields for Display a given item data in a template

=back

=cut

sub PrepareItemrecordDisplay {

    my ( $bibnum, $itemnum, $defaultvalues ) = @_;

    my $dbh = C4::Context->dbh;
    my $frameworkcode = &GetFrameworkCode( $bibnum );
    my ( $itemtagfield, $itemtagsubfield ) =
      &GetMarcFromKohaField( "items.itemnumber", $frameworkcode );
    my $tagslib = &GetMarcStructure( 1, $frameworkcode );
    my $itemrecord = C4::Items::GetMarcItem( $bibnum, $itemnum) if ($itemnum);
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
                $subfield_data{marc_lib} = $tagslib->{$tag}->{$subfield}->{lib};
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
                if ( $tagslib->{$tag}->{$subfield}->{kohafield} eq
                    'items.itemcallnumber'
                    && $defaultvalues->{'callnumber'} )
                {
                    my $temp = $itemrecord->field($subfield) if ($itemrecord);
                    unless ($temp) {
                        $value = $defaultvalues->{'callnumber'};
                    }
                }
                if ( ($tagslib->{$tag}->{$subfield}->{kohafield} eq
                    'items.holdingbranch' ||
                    $tagslib->{$tag}->{$subfield}->{kohafield} eq
                    'items.homebranch')          
                    && $defaultvalues->{'branchcode'} )
                {
                    my $temp = $itemrecord->field($subfield) if ($itemrecord);
                    unless ($temp) {
                        $value = $defaultvalues->{branchcode};
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
"<input type=\"text\" name=\"field_value\"  size=\"47\" maxlength=\"255\" /> <a href=\"javascript:Dopop('cataloguing/thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=',)\">...</a>";

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
"<input type=\"text\" name=\"field_value\" value=\"$value\" size=\"50\" maxlength=\"255\" />";
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

ModZebra( $biblionumber, $op, $server, $oldRecord, $newRecord );

    $biblionumber is the biblionumber we want to index
    $op is specialUpdate or delete, and is used to know what we want to do
    $server is the server that we want to update
    $oldRecord is the MARC::Record containing the previous version of the record.  This is used only when 
      NoZebra=1, as NoZebra indexing needs to know the previous version of a record in order to
      do an update.
    $newRecord is the MARC::Record containing the new record. It is usefull only when NoZebra=1, and is used to know what to add to the nozebra database. (the record in mySQL being, if it exist, the previous record, the one just before the modif. We need both : the previous and the new one.
    
=back

=cut

sub ModZebra {
###Accepts a $server variable thus we can use it for biblios authorities or other zebra dbs
    my ( $biblionumber, $op, $server, $oldRecord, $newRecord ) = @_;
    my $dbh=C4::Context->dbh;

    # true ModZebra commented until indexdata fixes zebraDB crashes (it seems they occur on multiple updates
    # at the same time
    # replaced by a zebraqueue table, that is filled with ModZebra to run.
    # the table is emptied by misc/cronjobs/zebraqueue_start.pl script

    if (C4::Context->preference("NoZebra")) {
        # lock the nozebra table : we will read index lines, update them in Perl process
        # and write everything in 1 transaction.
        # lock the table to avoid someone else overwriting what we are doing
        $dbh->do('LOCK TABLES nozebra WRITE,biblio WRITE,biblioitems WRITE, systempreferences WRITE, auth_types WRITE, auth_header WRITE, auth_subfield_structure READ');
        my %result; # the result hash that will be built by deletion / add, and written on mySQL at the end, to improve speed
        if ($op eq 'specialUpdate') {
            # OK, we have to add or update the record
            # 1st delete (virtually, in indexes), if record actually exists
            if ($oldRecord) { 
                %result = _DelBiblioNoZebra($biblionumber,$oldRecord,$server);
            }
            # ... add the record
            %result=_AddBiblioNoZebra($biblionumber,$newRecord, $server, %result);
        } else {
            # it's a deletion, delete the record...
            # warn "DELETE the record $biblionumber on $server".$record->as_formatted;
            %result=_DelBiblioNoZebra($biblionumber,$oldRecord,$server);
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
        my $check_sql = "SELECT COUNT(*) FROM zebraqueue 
                         WHERE server = ?
                         AND   biblio_auth_number = ?
                         AND   operation = ?
                         AND   done = 0";
        my $check_sth = $dbh->prepare_cached($check_sql);
        $check_sth->execute($server, $biblionumber, $op);
        my ($count) = $check_sth->fetchrow_array;
        $check_sth->finish();
        if ($count == 0) {
            my $sth=$dbh->prepare("INSERT INTO zebraqueue  (biblio_auth_number,server,operation) VALUES(?,?,?)");
            $sth->execute($biblionumber,$server,$op);
            $sth->finish;
        }
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
        $index =~ s/'|"|\s//g;


        $fields =~ s/'|"|\s//g;
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
        my ($auth_type_tag, $auth_type_sf) = C4::AuthoritiesMarc::get_auth_type_location();
        my $authref = C4::AuthoritiesMarc::GetAuthType($record->subfield($auth_type_tag, $auth_type_sf));
        warn "ERROR : authtype undefined for ".$record->as_formatted unless $authref;
        $title = $record->subfield($authref->{auth_tag_to_report},'a');
        $index{'mainmainentry'}= $authref->{'auth_tag_to_report'}.'a';
        $index{'mainentry'}    = $authref->{'auth_tag_to_report'}.'*';
        $index{'auth_type'}    = "${auth_type_tag}${auth_type_sf}";
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
        my ($auth_type_tag, $auth_type_sf) = C4::AuthoritiesMarc::get_auth_type_location();
        my $authref = C4::AuthoritiesMarc::GetAuthType($record->subfield($auth_type_tag, $auth_type_sf));
        warn "ERROR : authtype undefined for ".$record->as_formatted unless $authref;
        $title = $record->subfield($authref->{auth_tag_to_report},'a');
        $index{'mainmainentry'} = $authref->{auth_tag_to_report}.'a';
        $index{'mainentry'}     = $authref->{auth_tag_to_report}.'*';
        $index{'auth_type'}    = "${auth_type_tag}${auth_type_sf}";
    }

    # remove blancks comma (that could cause problem when decoding the string for CQL retrieval) and regexp specific values
    $title =~ s/ |\.|,|;|\[|\]|\(|\)|\*|-|'|:|=|\r|\n//g;
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
#             warn "INDEXING :".$subfield->[1];
            # check each index to see if the subfield is stored somewhere
            # otherwise, store it in __RAW__ index
            foreach my $key (keys %index) {
#                 warn "examining $key index : ".$index{$key}." for $tag $subfieldcode";
                if ($index{$key} =~ /$tag\*/ or $index{$key} =~ /$tag$subfieldcode/) {
                    $indexed=1;
                    my $line= lc $subfield->[1];
                    # remove meaningless value in the field...
                    $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:|\r|\n/ /g;
                    # ... and split in words
                    foreach (split / /,$line) {
                        next unless $_; # skip  empty values (multiple spaces)
                        # if the entry is already here, improve weight
#                         warn "managing $_";
                        if ($result{$key}->{"$_"} =~ /$biblionumber,\Q$title\E\-(\d);/) { 
                            my $weight=$1+1;
                            $result{$key}->{"$_"} =~ s/$biblionumber,\Q$title\E\-(\d);//;
                            $result{$key}->{"$_"} .= "$biblionumber,$title-$weight;";
                        } else {
                            # get the value if it exist in the nozebra table, otherwise, create it
                            $sth2->execute($server,$key,$_);
                            my $existing_biblionumbers = $sth2->fetchrow;
                            # it exists
                            if ($existing_biblionumbers) {
                                $result{$key}->{"$_"} =$existing_biblionumbers;
                                my $weight=$1+1;
                                $result{$key}->{"$_"} =~ s/$biblionumber,\Q$title\E\-(\d);//;
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
                $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:|\r|\n/ /g;
                # ... and split in words
                foreach (split / /,$line) {
                    next unless $_; # skip  empty values (multiple spaces)
                    # if the entry is already here, improve weight
                    if ($result{'__RAW__'}->{"$_"} =~ /$biblionumber,\Q$title\E\-(\d);/) { 
                        my $weight=$1+1;
                        $result{'__RAW__'}->{"$_"} =~ s/$biblionumber,\Q$title\E\-(\d);//;
                        $result{'__RAW__'}->{"$_"} .= "$biblionumber,$title-$weight;";
                    } else {
                        # get the value if it exist in the nozebra table, otherwise, create it
                        $sth2->execute($server,'__RAW__',$_);
                        my $existing_biblionumbers = $sth2->fetchrow;
                        # it exists
                        if ($existing_biblionumbers) {
                            $result{'__RAW__'}->{"$_"} =$existing_biblionumbers;
                            my $weight=$1+1;
                            $result{'__RAW__'}->{"$_"} =~ s/$biblionumber,\Q$title\E\-(\d);//;
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
        $record->delete_field($old_field) if $old_field;
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
        $record->delete_field($old_field) if $old_field;
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
        $record->delete_field($old_field) if $old_field;
        $record->insert_fields_ordered($new_field);
    }
}

=head2 _koha_marc_update_biblioitem_cn_sort

=over 4

_koha_marc_update_biblioitem_cn_sort($marc, $biblioitem, $frameworkcode);

=back

Given a MARC bib record and the biblioitem hash, update the
subfield that contains a copy of the value of biblioitems.cn_sort.

=cut

sub _koha_marc_update_biblioitem_cn_sort {
    my $marc = shift;
    my $biblioitem = shift;
    my $frameworkcode= shift;

    my ($biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField("biblioitems.cn_sort",$frameworkcode);
    return unless $biblioitem_tag;

    my ($cn_sort) = GetClassSort($biblioitem->{'biblioitems.cn_source'}, $biblioitem->{'cn_class'}, $biblioitem->{'cn_item'} );

    if (my $field = $marc->field($biblioitem_tag)) {
        $field->delete_subfield(code => $biblioitem_subfield);
        if ($cn_sort ne '') {
            $field->add_subfields($biblioitem_subfield => $cn_sort);
        }
    } else {
        # if we get here, no biblioitem tag is present in the MARC record, so
        # we'll create it if $cn_sort is not empty -- this would be
        # an odd combination of events, however
        if ($cn_sort) {
            $marc->insert_grouped_field(MARC::Field->new($biblioitem_tag, ' ', ' ', $biblioitem_subfield => $cn_sort));
        }
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
    SET biblionumber    = ?,
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
        url             = ?,
        cn_source       = ?,
        cn_class        = ?,
        cn_item         = ?,
        cn_suffix       = ?,
        cn_sort         = ?,
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
    my $oldRecord;
    if (C4::Context->preference("NoZebra")) {
        # only NoZebra indexing needs to have
        # the previous version of the record
        $oldRecord = GetMarcBiblio($biblionumber);
    }
    $sth =
      $dbh->prepare(
        "UPDATE biblioitems SET marc=?,marcxml=? WHERE biblionumber=?");
    $sth->execute( $record->as_usmarc(), $record->as_xml_record($encoding),
        $biblionumber );
    $sth->finish;
    ModZebra($biblionumber,"specialUpdate","biblioserver",$oldRecord,$record);
    return $biblionumber;
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

=head3 get_biblio_authorised_values

  find the types and values for all authorised values assigned to this biblio.

  parameters:
    biblionumber

  returns: a hashref malling the authorised value to the value set for this biblionumber

      $authorised_values = {
                             'Scent'     => 'flowery',
                             'Audience'  => 'Young Adult',
                             'itemtypes' => 'SER',
                           };

  Notes: forlibrarian should probably be passed in, and called something different.


=cut

sub get_biblio_authorised_values {
    my $biblionumber = shift;
    
    my $forlibrarian = 1; # are we in staff or opac?
    my $frameworkcode = GetFrameworkCode( $biblionumber );

    my $authorised_values;

    my $record  = GetMarcBiblio( $biblionumber )
      or return $authorised_values;
    my $tagslib = GetMarcStructure( $forlibrarian, $frameworkcode )
      or return $authorised_values;

    # assume that these entries in the authorised_value table are bibliolevel.
    # ones that start with 'item%' are item level.
    my $query = q(SELECT distinct authorised_value, kohafield
                    FROM marc_subfield_structure
                    WHERE authorised_value !=''
                      AND (kohafield like 'biblio%'
                       OR  kohafield like '') );
    my $bibliolevel_authorised_values = C4::Context->dbh->selectall_hashref( $query, 'authorised_value' );
    
    foreach my $tag ( keys( %$tagslib ) ) {
        foreach my $subfield ( keys( %{$tagslib->{ $tag }} ) ) {
            # warn "checking $subfield. type is: " . ref $tagslib->{ $tag }{ $subfield };
            if ( 'HASH' eq ref $tagslib->{ $tag }{ $subfield } ) {
                if ( exists $tagslib->{ $tag }{ $subfield }{'authorised_value'} && exists $bibliolevel_authorised_values->{ $tagslib->{ $tag }{ $subfield }{'authorised_value'} } ) {
                    if ( defined $record->field( $tag ) ) {
                        my $this_subfield_value = $record->field( $tag )->subfield( $subfield );
                        if ( defined $this_subfield_value ) {
                            $authorised_values->{ $tagslib->{ $tag }{ $subfield }{'authorised_value'} } = $this_subfield_value;
                        }
                    }
                }
            }
        }
    }
    # warn ( Data::Dumper->Dump( [ $authorised_values ], [ 'authorised_values' ] ) );
    return $authorised_values;
}


1;

__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

Paul POULAIN paul.poulain@free.fr

Joshua Ferraro jmf@liblime.com

=cut
