package C4::Biblio;

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
# Copyright 2011 Equinox Software, Inc.
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
use Carp;

use Encode qw( decode is_utf8 );
use List::MoreUtils qw( uniq );
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use POSIX qw(strftime);
use Module::Load::Conditional qw(can_load);

use C4::Koha;
use C4::Log;    # logaction
use C4::Budgets;
use C4::ClassSource;
use C4::Charset;
use C4::Linker;
use C4::OAI::Sets;
use C4::Debug;

use Koha::Caches;
use Koha::Authority::Types;
use Koha::Acquisition::Currencies;
use Koha::Biblio::Metadata;
use Koha::Biblio::Metadatas;
use Koha::Holds;
use Koha::ItemTypes;
use Koha::SearchEngine;
use Koha::Libraries;

use vars qw(@ISA @EXPORT);
use vars qw($debug $cgi_debug);

BEGIN {

    require Exporter;
    @ISA = qw( Exporter );

    # to add biblios
    # EXPORTED FUNCTIONS.
    push @EXPORT, qw(
      &AddBiblio
    );

    # to get something
    push @EXPORT, qw(
      GetBiblioData
      GetMarcBiblio

      &GetRecordValue

      &GetISBDView

      &GetMarcControlnumber
      &GetMarcNotes
      &GetMarcISBN
      &GetMarcISSN
      &GetMarcSubjects
      &GetMarcAuthors
      &GetMarcSeries
      &GetMarcHosts
      GetMarcUrls
      &GetUsedMarcStructure
      &GetXmlBiblio
      &GetCOinSBiblio
      &GetMarcPrice
      &MungeMarcPrice
      &GetMarcQuantity

      &GetAuthorisedValueDesc
      &GetMarcStructure
      &IsMarcStructureInternal
      &GetMarcFromKohaField
      &GetMarcSubfieldStructureFromKohaField
      &GetFrameworkCode
      &TransformKohaToMarc
      &PrepHostMarcField

      &CountItemsIssued
      &CountBiblioInOrders
    );

    # To modify something
    push @EXPORT, qw(
      &ModBiblio
      &ModZebra
      &UpdateTotalIssues
      &RemoveAllNsb
    );

    # To delete something
    push @EXPORT, qw(
      &DelBiblio
    );

    # To link headings in a bib record
    # to authority records.
    push @EXPORT, qw(
      &BiblioAutoLink
      &LinkBibHeadingsToAuthorities
    );

    # Internal functions
    # those functions are exported but should not be used
    # they are useful in a few circumstances, so they are exported,
    # but don't use them unless you are a core developer ;-)
    push @EXPORT, qw(
      &ModBiblioMarc
    );

    # Others functions
    push @EXPORT, qw(
      &TransformMarcToKoha
      &TransformHtmlToMarc
      &TransformHtmlToXml
      prepare_host_field
    );
}

=head1 NAME

C4::Biblio - cataloging management functions

=head1 DESCRIPTION

Biblio.pm contains functions for managing storage and editing of bibliographic data within Koha. Most of the functions in this module are used for cataloging records: adding, editing, or removing biblios, biblioitems, or items. Koha's stores bibliographic information in three places:

=over 4

=item 1. in the biblio,biblioitems,items, etc tables, which are limited to a one-to-one mapping to underlying MARC data

=item 2. as raw MARC in the Zebra index and storage engine

=item 3. as MARC XML in biblio_metadata.metadata

=back

In the 3.0 version of Koha, the authoritative record-level information is in biblio_metadata.metadata

Because the data isn't completely normalized there's a chance for information to get out of sync. The design choice to go with a un-normalized schema was driven by performance and stability concerns. However, if this occur, it can be considered as a bug : The API is (or should be) complete & the only entry point for all biblio/items managements.

=over 4

=item 1. Compared with MySQL, Zebra is slow to update an index for small data changes -- especially for proc-intensive operations like circulation

=item 2. Zebra's index has been known to crash and a backup of the data is necessary to rebuild it in such cases

=back

Because of this design choice, the process of managing storage and editing is a bit convoluted. Historically, Biblio.pm's grown to an unmanagable size and as a result we have several types of functions currently:

=over 4

=item 1. Add*/Mod*/Del*/ - high-level external functions suitable for being called from external scripts to manage the collection

=item 2. _koha_* - low-level internal functions for managing the koha tables

=item 3. Marc management function : as the MARC record is stored in biblio_metadata.metadata, some subs dedicated to it's management are in this package. They should be used only internally by Biblio.pm, the only official entry points being AddBiblio, AddItem, ModBiblio, ModItem.

=item 4. Zebra functions used to update the Zebra index

=item 5. internal helper functions such as char_decode, checkitems, etc. Some of these probably belong in Koha.pm

=back

The MARC record (in biblio_metadata.metadata) contains the complete marc record, including items. It also contains the biblionumber. That is the reason why it is not stored directly by AddBiblio, with all other fields . To save a biblio, we need to :

=over 4

=item 1. save datas in biblio and biblioitems table, that gives us a biblionumber and a biblioitemnumber

=item 2. add the biblionumber and biblioitemnumber into the MARC records

=item 3. save the marc record

=back

=head1 EXPORTED FUNCTIONS

=head2 AddBiblio

  ($biblionumber,$biblioitemnumber) = AddBiblio($record,$frameworkcode);

Exported function (core API) for adding a new biblio to koha.

The first argument is a C<MARC::Record> object containing the
bib to add, while the second argument is the desired MARC
framework code.

This function also accepts a third, optional argument: a hashref
to additional options.  The only defined option is C<defer_marc_save>,
which if present and mapped to a true value, causes C<AddBiblio>
to omit the call to save the MARC in C<biblio_metadata.metadata>
This option is provided B<only>
for the use of scripts such as C<bulkmarcimport.pl> that may need
to do some manipulation of the MARC record for item parsing before
saving it and which cannot afford the performance hit of saving
the MARC record twice.  Consequently, do not use that option
unless you can guarantee that C<ModBiblioMarc> will be called.

=cut

sub AddBiblio {
    my $record          = shift;
    my $frameworkcode   = shift;
    my $options         = @_ ? shift : undef;
    my $defer_marc_save = 0;
    if (!$record) {
        carp('AddBiblio called with undefined record');
        return;
    }
    if ( defined $options and exists $options->{'defer_marc_save'} and $options->{'defer_marc_save'} ) {
        $defer_marc_save = 1;
    }

    my ( $biblionumber, $biblioitemnumber, $error );
    my $dbh = C4::Context->dbh;

    # transform the data into koha-table style data
    SetUTF8Flag($record);
    my $olddata = TransformMarcToKoha( $record, $frameworkcode );
    ( $biblionumber, $error ) = _koha_add_biblio( $dbh, $olddata, $frameworkcode );
    $olddata->{'biblionumber'} = $biblionumber;
    ( $biblioitemnumber, $error ) = _koha_add_biblioitem( $dbh, $olddata );

    _koha_marc_update_bib_ids( $record, $frameworkcode, $biblionumber, $biblioitemnumber );

    # update MARC subfield that stores biblioitems.cn_sort
    _koha_marc_update_biblioitem_cn_sort( $record, $olddata, $frameworkcode );

    # now add the record
    ModBiblioMarc( $record, $biblionumber, $frameworkcode ) unless $defer_marc_save;

    # update OAI-PMH sets
    if(C4::Context->preference("OAI-PMH:AutoUpdateSets")) {
        C4::OAI::Sets::UpdateOAISetsBiblio($biblionumber, $record);
    }

    logaction( "CATALOGUING", "ADD", $biblionumber, "biblio" ) if C4::Context->preference("CataloguingLog");
    return ( $biblionumber, $biblioitemnumber );
}

=head2 ModBiblio

  ModBiblio( $record,$biblionumber,$frameworkcode);

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

Returns 1 on success 0 on failure

=cut

sub ModBiblio {
    my ( $record, $biblionumber, $frameworkcode ) = @_;
    if (!$record) {
        carp 'No record passed to ModBiblio';
        return 0;
    }

    if ( C4::Context->preference("CataloguingLog") ) {
        my $newrecord = GetMarcBiblio({ biblionumber => $biblionumber });
        logaction( "CATALOGUING", "MODIFY", $biblionumber, "biblio BEFORE=>" . $newrecord->as_formatted );
    }

    # Cleaning up invalid fields must be done early or SetUTF8Flag is liable to
    # throw an exception which probably won't be handled.
    foreach my $field ($record->fields()) {
        if (! $field->is_control_field()) {
            if (scalar($field->subfields()) == 0 || (scalar($field->subfields()) == 1 && $field->subfield('9'))) {
                $record->delete_field($field);
            }
        }
    }

    SetUTF8Flag($record);
    my $dbh = C4::Context->dbh;

    $frameworkcode = "" if !$frameworkcode || $frameworkcode eq "Default"; # XXX

    _strip_item_fields($record, $frameworkcode);

    # update biblionumber and biblioitemnumber in MARC
    # FIXME - this is assuming a 1 to 1 relationship between
    # biblios and biblioitems
    my $sth = $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblionumber);
    my ($biblioitemnumber) = $sth->fetchrow;
    $sth->finish();
    _koha_marc_update_bib_ids( $record, $frameworkcode, $biblionumber, $biblioitemnumber );

    # load the koha-table data object
    my $oldbiblio = TransformMarcToKoha( $record, $frameworkcode );

    # update MARC subfield that stores biblioitems.cn_sort
    _koha_marc_update_biblioitem_cn_sort( $record, $oldbiblio, $frameworkcode );

    # update the MARC record (that now contains biblio and items) with the new record data
    &ModBiblioMarc( $record, $biblionumber, $frameworkcode );

    # modify the other koha tables
    _koha_modify_biblio( $dbh, $oldbiblio, $frameworkcode );
    _koha_modify_biblioitem_nonmarc( $dbh, $oldbiblio );

    # update OAI-PMH sets
    if(C4::Context->preference("OAI-PMH:AutoUpdateSets")) {
        C4::OAI::Sets::UpdateOAISetsBiblio($biblionumber, $record);
    }

    return 1;
}

=head2 _strip_item_fields

  _strip_item_fields($record, $frameworkcode)

Utility routine to remove item tags from a
MARC bib.

=cut

sub _strip_item_fields {
    my $record = shift;
    my $frameworkcode = shift;
    # get the items before and append them to the biblio before updating the record, atm we just have the biblio
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField( "items.itemnumber", $frameworkcode );

    # delete any item fields from incoming record to avoid
    # duplication or incorrect data - use AddItem() or ModItem()
    # to change items
    foreach my $field ( $record->field($itemtag) ) {
        $record->delete_field($field);
    }
}

=head2 DelBiblio

  my $error = &DelBiblio($biblionumber);

Exported function (core API) for deleting a biblio in koha.
Deletes biblio record from Zebra and Koha tables (biblio & biblioitems)
Also backs it up to deleted* tables.
Checks to make sure that the biblio has no items attached.
return:
C<$error> : undef unless an error occurs

=cut

sub DelBiblio {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    my $error;    # for error handling

    # First make sure this biblio has no items attached
    my $sth = $dbh->prepare("SELECT itemnumber FROM items WHERE biblionumber=?");
    $sth->execute($biblionumber);
    if ( my $itemnumber = $sth->fetchrow ) {

        # Fix this to use a status the template can understand
        $error .= "This Biblio has items attached, please delete them first before deleting this biblio ";
    }

    return $error if $error;

    # We delete attached subscriptions
    require C4::Serials;
    my $subscriptions = C4::Serials::GetFullSubscriptionsFromBiblionumber($biblionumber);
    foreach my $subscription (@$subscriptions) {
        C4::Serials::DelSubscription( $subscription->{subscriptionid} );
    }

    # We delete any existing holds
    my $biblio = Koha::Biblios->find( $biblionumber );
    my $holds = $biblio->holds;
    while ( my $hold = $holds->next ) {
        $hold->cancel;
    }

    # Delete in Zebra. Be careful NOT to move this line after _koha_delete_biblio
    # for at least 2 reasons :
    # - if something goes wrong, the biblio may be deleted from Koha but not from zebra
    #   and we would have no way to remove it (except manually in zebra, but I bet it would be very hard to handle the problem)
    ModZebra( $biblionumber, "recordDelete", "biblioserver" );

    # delete biblioitems and items from Koha tables and save in deletedbiblioitems,deleteditems
    $sth = $dbh->prepare("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
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

    logaction( "CATALOGUING", "DELETE", $biblionumber, "biblio" ) if C4::Context->preference("CataloguingLog");

    return;
}


=head2 BiblioAutoLink

  my $headings_linked = BiblioAutoLink($record, $frameworkcode)

Automatically links headings in a bib record to authorities.

Returns the number of headings changed

=cut

sub BiblioAutoLink {
    my $record        = shift;
    my $frameworkcode = shift;
    if (!$record) {
        carp('Undefined record passed to BiblioAutoLink');
        return 0;
    }
    my ( $num_headings_changed, %results );

    my $linker_module =
      "C4::Linker::" . ( C4::Context->preference("LinkerModule") || 'Default' );
    unless ( can_load( modules => { $linker_module => undef } ) ) {
        $linker_module = 'C4::Linker::Default';
        unless ( can_load( modules => { $linker_module => undef } ) ) {
            return 0;
        }
    }

    my $linker = $linker_module->new(
        { 'options' => C4::Context->preference("LinkerOptions") } );
    my ( $headings_changed, undef ) =
      LinkBibHeadingsToAuthorities( $linker, $record, $frameworkcode, C4::Context->preference("CatalogModuleRelink") || '' );
    # By default we probably don't want to relink things when cataloging
    return $headings_changed;
}

=head2 LinkBibHeadingsToAuthorities

  my $num_headings_changed, %results = LinkBibHeadingsToAuthorities($linker, $marc, $frameworkcode, [$allowrelink]);

Links bib headings to authority records by checking
each authority-controlled field in the C<MARC::Record>
object C<$marc>, looking for a matching authority record,
and setting the linking subfield $9 to the ID of that
authority record.  

If $allowrelink is false, existing authids will never be
replaced, regardless of the values of LinkerKeepStale and
LinkerRelink.

Returns the number of heading links changed in the
MARC record.

=cut

sub LinkBibHeadingsToAuthorities {
    my $linker        = shift;
    my $bib           = shift;
    my $frameworkcode = shift;
    my $allowrelink = shift;
    my %results;
    if (!$bib) {
        carp 'LinkBibHeadingsToAuthorities called on undefined bib record';
        return ( 0, {});
    }
    require C4::Heading;
    require C4::AuthoritiesMarc;

    $allowrelink = 1 unless defined $allowrelink;
    my $num_headings_changed = 0;
    foreach my $field ( $bib->fields() ) {
        my $heading = C4::Heading->new_from_bib_field( $field, $frameworkcode );
        next unless defined $heading;

        # check existing $9
        my $current_link = $field->subfield('9');

        if ( defined $current_link && (!$allowrelink || !C4::Context->preference('LinkerRelink')) )
        {
            $results{'linked'}->{ $heading->display_form() }++;
            next;
        }

        my ( $authid, $fuzzy ) = $linker->get_link($heading);
        if ($authid) {
            $results{ $fuzzy ? 'fuzzy' : 'linked' }
              ->{ $heading->display_form() }++;
            next if defined $current_link and $current_link == $authid;

            $field->delete_subfield( code => '9' ) if defined $current_link;
            $field->add_subfields( '9', $authid );
            $num_headings_changed++;
        }
        else {
            if ( defined $current_link
                && (!$allowrelink || C4::Context->preference('LinkerKeepStale')) )
            {
                $results{'fuzzy'}->{ $heading->display_form() }++;
            }
            elsif ( C4::Context->preference('AutoCreateAuthorities') ) {
                if ( _check_valid_auth_link( $current_link, $field ) ) {
                    $results{'linked'}->{ $heading->display_form() }++;
                }
                else {
                    my $authority_type = Koha::Authority::Types->find( $heading->auth_type() );
                    my $marcrecordauth = MARC::Record->new();
                    if ( C4::Context->preference('marcflavour') eq 'MARC21' ) {
                        $marcrecordauth->leader('     nz  a22     o  4500');
                        SetMarcUnicodeFlag( $marcrecordauth, 'MARC21' );
                    }
                    $field->delete_subfield( code => '9' )
                      if defined $current_link;
                    my $authfield =
                      MARC::Field->new( $authority_type->auth_tag_to_report,
                        '', '', "a" => "" . $field->subfield('a') );
                    map {
                        $authfield->add_subfields( $_->[0] => $_->[1] )
                          if ( $_->[0] =~ /[A-z]/ && $_->[0] ne "a" )
                    } $field->subfields();
                    $marcrecordauth->insert_fields_ordered($authfield);

# bug 2317: ensure new authority knows it's using UTF-8; currently
# only need to do this for MARC21, as MARC::Record->as_xml_record() handles
# automatically for UNIMARC (by not transcoding)
# FIXME: AddAuthority() instead should simply explicitly require that the MARC::Record
# use UTF-8, but as of 2008-08-05, did not want to introduce that kind
# of change to a core API just before the 3.0 release.

                    if ( C4::Context->preference('marcflavour') eq 'MARC21' ) {
                        my $userenv = C4::Context->userenv;
                        my $library;
                        if ( $userenv && $userenv->{'branch'} ) {
                            $library = Koha::Libraries->find( $userenv->{'branch'} );
                        }
                        $marcrecordauth->insert_fields_ordered(
                            MARC::Field->new(
                                '667', '', '',
                                'a' => "Machine generated authority record."
                            )
                        );
                        my $cite =
                            $bib->author() . ", "
                          . $bib->title_proper() . ", "
                          . $bib->publication_date() . " ";
                        $cite =~ s/^[\s\,]*//;
                        $cite =~ s/[\s\,]*$//;
                        $cite =
                            "Work cat.: ("
                          . ( $library ? $library->get_effective_marcorgcode : C4::Context->preference('MARCOrgCode') ) . ")"
                          . $bib->subfield( '999', 'c' ) . ": "
                          . $cite;
                        $marcrecordauth->insert_fields_ordered(
                            MARC::Field->new( '670', '', '', 'a' => $cite ) );
                    }

           #          warn "AUTH RECORD ADDED : ".$marcrecordauth->as_formatted;

                    $authid =
                      C4::AuthoritiesMarc::AddAuthority( $marcrecordauth, '',
                        $heading->auth_type() );
                    $field->add_subfields( '9', $authid );
                    $num_headings_changed++;
                    $linker->update_cache($heading, $authid);
                    $results{'added'}->{ $heading->display_form() }++;
                }
            }
            elsif ( defined $current_link ) {
                if ( _check_valid_auth_link( $current_link, $field ) ) {
                    $results{'linked'}->{ $heading->display_form() }++;
                }
                else {
                    $field->delete_subfield( code => '9' );
                    $num_headings_changed++;
                    $results{'unlinked'}->{ $heading->display_form() }++;
                }
            }
            else {
                $results{'unlinked'}->{ $heading->display_form() }++;
            }
        }

    }
    return $num_headings_changed, \%results;
}

=head2 _check_valid_auth_link

    if ( _check_valid_auth_link($authid, $field) ) {
        ...
    }

Check whether the specified heading-auth link is valid without reference
to Zebra. Ideally this code would be in C4::Heading, but that won't be
possible until we have de-cycled C4::AuthoritiesMarc, so this is the
safest place.

=cut

sub _check_valid_auth_link {
    my ( $authid, $field ) = @_;

    require C4::AuthoritiesMarc;

    my $authorized_heading =
      C4::AuthoritiesMarc::GetAuthorizedHeading( { 'authid' => $authid } ) || '';

   return ($field->as_string('abcdefghijklmnopqrstuvwxyz') eq $authorized_heading);
}

=head2 GetRecordValue

  my $values = GetRecordValue($field, $record, $frameworkcode);

Get MARC fields from a keyword defined in fieldmapping table.

=cut

sub GetRecordValue {
    my ( $field, $record, $frameworkcode ) = @_;

    if (!$record) {
        carp 'GetRecordValue called with undefined record';
        return;
    }
    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare('SELECT fieldcode, subfieldcode FROM fieldmapping WHERE frameworkcode = ? AND field = ?');
    $sth->execute( $frameworkcode, $field );

    my @result = ();

    while ( my $row = $sth->fetchrow_hashref ) {
        foreach my $field ( $record->field( $row->{fieldcode} ) ) {
            if ( ( $row->{subfieldcode} ne "" && $field->subfield( $row->{subfieldcode} ) ) ) {
                foreach my $subfield ( $field->subfield( $row->{subfieldcode} ) ) {
                    push @result, { 'subfield' => $subfield };
                }

            } elsif ( $row->{subfieldcode} eq "" ) {
                push @result, { 'subfield' => $field->as_string() };
            }
        }
    }

    return \@result;
}

=head2 GetBiblioData

  $data = &GetBiblioData($biblionumber);

Returns information about the book with the given biblionumber.
C<&GetBiblioData> returns a reference-to-hash. The keys are the fields in
the C<biblio> and C<biblioitems> tables in the
Koha database.

In addition, C<$data-E<gt>{subject}> is the list of the book's
subjects, separated by C<" , "> (space, comma, space).
If there are multiple biblioitems with the given biblionumber, only
the first one is considered.

=cut

sub GetBiblioData {
    my ($bibnum) = @_;
    my $dbh = C4::Context->dbh;

    my $query = " SELECT * , biblioitems.notes AS bnotes, itemtypes.notforloan as bi_notforloan, biblio.notes
            FROM biblio
            LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
            LEFT JOIN itemtypes ON biblioitems.itemtype = itemtypes.itemtype
            WHERE biblio.biblionumber = ?";

    my $sth = $dbh->prepare($query);
    $sth->execute($bibnum);
    my $data;
    $data = $sth->fetchrow_hashref;
    $sth->finish;

    return ($data);
}    # sub GetBiblioData

=head2 GetISBDView 

  $isbd = &GetISBDView({
      'record'    => $marc_record,
      'template'  => $interface, # opac/intranet
      'framework' => $framework,
  });

Return the ISBD view which can be included in opac and intranet

=cut

sub GetISBDView {
    my ( $params ) = @_;

    # Expecting record WITH items.
    my $record    = $params->{record};
    return unless defined $record;

    my $template  = $params->{template} // q{};
    my $sysprefname = $template eq 'opac' ? 'opacisbd' : 'isbd';
    my $framework = $params->{framework};
    my $itemtype  = $framework;
    my ( $holdingbrtagf, $holdingbrtagsubf ) = &GetMarcFromKohaField( "items.holdingbranch", $itemtype );
    my $tagslib = &GetMarcStructure( 1, $itemtype, { unsafe => 1 } );

    my $ISBD = C4::Context->preference($sysprefname);
    my $bloc = $ISBD;
    my $res;
    my $blocres;

    foreach my $isbdfield ( split( /#/, $bloc ) ) {

        #         $isbdfield= /(.?.?.?)/;
        $isbdfield =~ /(\d\d\d)([^\|])?\|(.*)\|(.*)\|(.*)/;
        my $fieldvalue = $1 || 0;
        my $subfvalue  = $2 || "";
        my $textbefore = $3;
        my $analysestring = $4;
        my $textafter     = $5;

        #         warn "==> $1 / $2 / $3 / $4";
        #         my $fieldvalue=substr($isbdfield,0,3);
        if ( $fieldvalue > 0 ) {
            my $hasputtextbefore = 0;
            my @fieldslist       = $record->field($fieldvalue);
            @fieldslist = sort { $a->subfield($holdingbrtagsubf) cmp $b->subfield($holdingbrtagsubf) } @fieldslist if ( $fieldvalue eq $holdingbrtagf );

            #         warn "ERROR IN ISBD DEFINITION at : $isbdfield" unless $fieldvalue;
            #             warn "FV : $fieldvalue";
            if ( $subfvalue ne "" ) {
                # OPAC hidden subfield
                next
                  if ( ( $template eq 'opac' )
                    && ( $tagslib->{$fieldvalue}->{$subfvalue}->{'hidden'} || 0 ) > 0 );
                foreach my $field (@fieldslist) {
                    foreach my $subfield ( $field->subfield($subfvalue) ) {
                        my $calculated = $analysestring;
                        my $tag        = $field->tag();
                        if ( $tag < 10 ) {
                        } else {
                            my $subfieldvalue = GetAuthorisedValueDesc( $tag, $subfvalue, $subfield, '', $tagslib );
                            my $tagsubf = $tag . $subfvalue;
                            $calculated =~ s/\{(.?.?.?.?)$tagsubf(.*?)\}/$1$subfieldvalue$2\{$1$tagsubf$2\}/g;
                            if ( $template eq "opac" ) { $calculated =~ s#/cgi-bin/koha/[^/]+/([^.]*.pl\?.*)$#opac-$1#g; }

                            # field builded, store the result
                            if ( $calculated && !$hasputtextbefore ) {    # put textbefore if not done
                                $blocres .= $textbefore;
                                $hasputtextbefore = 1;
                            }

                            # remove punctuation at start
                            $calculated =~ s/^( |;|:|\.|-)*//g;
                            $blocres .= $calculated;

                        }
                    }
                }
                $blocres .= $textafter if $hasputtextbefore;
            } else {
                foreach my $field (@fieldslist) {
                    my $calculated = $analysestring;
                    my $tag        = $field->tag();
                    if ( $tag < 10 ) {
                    } else {
                        my @subf = $field->subfields;
                        for my $i ( 0 .. $#subf ) {
                            my $valuecode     = $subf[$i][1];
                            my $subfieldcode  = $subf[$i][0];
                            # OPAC hidden subfield
                            next
                              if ( ( $template eq 'opac' )
                                && ( $tagslib->{$fieldvalue}->{$subfieldcode}->{'hidden'} || 0 ) > 0 );
                            my $subfieldvalue = GetAuthorisedValueDesc( $tag, $subf[$i][0], $subf[$i][1], '', $tagslib );
                            my $tagsubf       = $tag . $subfieldcode;

                            $calculated =~ s/                  # replace all {{}} codes by the value code.
                                  \{\{$tagsubf\}\} # catch the {{actualcode}}
                                /
                                  $valuecode     # replace by the value code
                               /gx;

                            $calculated =~ s/\{(.?.?.?.?)$tagsubf(.*?)\}/$1$subfieldvalue$2\{$1$tagsubf$2\}/g;
                            if ( $template eq "opac" ) { $calculated =~ s#/cgi-bin/koha/[^/]+/([^.]*.pl\?.*)$#opac-$1#g; }
                        }

                        # field builded, store the result
                        if ( $calculated && !$hasputtextbefore ) {    # put textbefore if not done
                            $blocres .= $textbefore;
                            $hasputtextbefore = 1;
                        }

                        # remove punctuation at start
                        $calculated =~ s/^( |;|:|\.|-)*//g;
                        $blocres .= $calculated;
                    }
                }
                $blocres .= $textafter if $hasputtextbefore;
            }
        } else {
            $blocres .= $isbdfield;
        }
    }
    $res .= $blocres;

    $res =~ s/\{(.*?)\}//g;
    $res =~ s/\\n/\n/g;
    $res =~ s/\n/<br\/>/g;

    # remove empty ()
    $res =~ s/\(\)//g;

    return $res;
}

=head1 FUNCTIONS FOR HANDLING MARC MANAGEMENT

=head2 IsMarcStructureInternal

    my $tagslib = C4::Biblio::GetMarcStructure();
    for my $tag ( sort keys %$tagslib ) {
        next unless $tag;
        for my $subfield ( sort keys %{ $tagslib->{$tag} } ) {
            next if IsMarcStructureInternal($tagslib->{$tag}{$subfield});
        }
        # Process subfield
    }

GetMarcStructure creates keys (lib, tab, mandatory, repeatable) for a display purpose.
These different values should not be processed as valid subfields.

=cut

sub IsMarcStructureInternal {
    my ( $subfield ) = @_;
    return ref $subfield ? 0 : 1;
}

=head2 GetMarcStructure

  $res = GetMarcStructure($forlibrarian, $frameworkcode, [ $params ]);

Returns a reference to a big hash of hash, with the Marc structure for the given frameworkcode
$forlibrarian  :if set to 1, the MARC descriptions are the librarians ones, otherwise it's the public (OPAC) ones
$frameworkcode : the framework code to read
$params allows you to pass { unsafe => 1 } for better performance.

Note: If you call GetMarcStructure with unsafe => 1, do not modify or
even autovivify its contents. It is a cached/shared data structure. Your
changes c/would be passed around in subsequent calls.

=cut

sub GetMarcStructure {
    my ( $forlibrarian, $frameworkcode, $params ) = @_;
    $frameworkcode = "" unless $frameworkcode;

    $forlibrarian = $forlibrarian ? 1 : 0;
    my $unsafe = ($params && $params->{unsafe})? 1: 0;
    my $cache = Koha::Caches->get_instance();
    my $cache_key = "MarcStructure-$forlibrarian-$frameworkcode";
    my $cached = $cache->get_from_cache($cache_key, { unsafe => $unsafe });
    return $cached if $cached;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT tagfield,liblibrarian,libopac,mandatory,repeatable,ind1_defaultvalue,ind2_defaultvalue
        FROM marc_tag_structure 
        WHERE frameworkcode=? 
        ORDER BY tagfield"
    );
    $sth->execute($frameworkcode);
    my ( $liblibrarian, $libopac, $tag, $res, $tab, $mandatory, $repeatable, $ind1_defaultvalue, $ind2_defaultvalue );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable, $ind1_defaultvalue, $ind2_defaultvalue ) = $sth->fetchrow ) {
        $res->{$tag}->{lib}        = ( $forlibrarian or !$libopac ) ? $liblibrarian : $libopac;
        $res->{$tag}->{tab}        = "";
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{repeatable} = $repeatable;
    $res->{$tag}->{ind1_defaultvalue} = $ind1_defaultvalue;
    $res->{$tag}->{ind2_defaultvalue} = $ind2_defaultvalue;
    }

    $sth = $dbh->prepare(
        "SELECT tagfield,tagsubfield,liblibrarian,libopac,tab,mandatory,repeatable,authorised_value,authtypecode,value_builder,kohafield,seealso,hidden,isurl,link,defaultvalue,maxlength
         FROM   marc_subfield_structure 
         WHERE  frameworkcode=? 
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
    my $maxlength;

    while (
        (   $tag,          $subfield,      $liblibrarian, $libopac, $tab,    $mandatory, $repeatable, $authorised_value,
            $authtypecode, $value_builder, $kohafield,    $seealso, $hidden, $isurl,     $link,       $defaultvalue,
            $maxlength
        )
        = $sth->fetchrow
      ) {
        $res->{$tag}->{$subfield}->{lib}              = ( $forlibrarian or !$libopac ) ? $liblibrarian : $libopac;
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
        $res->{$tag}->{$subfield}->{maxlength}        = $maxlength;
    }

    $cache->set_in_cache($cache_key, $res);
    return $res;
}

=head2 GetUsedMarcStructure

The same function as GetMarcStructure except it just takes field
in tab 0-9. (used field)

  my $results = GetUsedMarcStructure($frameworkcode);

C<$results> is a ref to an array which each case contains a ref
to a hash which each keys is the columns from marc_subfield_structure

C<$frameworkcode> is the framework code. 

=cut

sub GetUsedMarcStructure {
    my $frameworkcode = shift || '';
    my $query = q{
        SELECT *
        FROM   marc_subfield_structure
        WHERE   tab > -1 
            AND frameworkcode = ?
        ORDER BY tagfield, tagsubfield
    };
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($frameworkcode);
    return $sth->fetchall_arrayref( {} );
}

=head2 GetMarcSubfieldStructure

=cut

sub GetMarcSubfieldStructure {
    my ( $frameworkcode ) = @_;

    $frameworkcode //= '';

    my $cache     = Koha::Caches->get_instance();
    my $cache_key = "MarcSubfieldStructure-$frameworkcode";
    my $cached    = $cache->get_from_cache($cache_key);
    return $cached if $cached;

    my $dbh = C4::Context->dbh;
    # We moved to selectall_arrayref since selectall_hashref does not
    # keep duplicate mappings on kohafield (like place in 260 vs 264)
    my $subfield_aref = $dbh->selectall_arrayref( q|
        SELECT *
        FROM marc_subfield_structure
        WHERE frameworkcode = ?
        AND kohafield > ''
        ORDER BY frameworkcode,tagfield,tagsubfield
    |, { Slice => {} }, $frameworkcode );
    # Now map the output to a hash structure
    my $subfield_structure = {};
    foreach my $row ( @$subfield_aref ) {
        push @{ $subfield_structure->{ $row->{kohafield} }}, $row;
    }
    $cache->set_in_cache( $cache_key, $subfield_structure );
    return $subfield_structure;
}

=head2 GetMarcFromKohaField

    ( $field,$subfield ) = GetMarcFromKohaField( $kohafield );
    @fields = GetMarcFromKohaField( $kohafield );
    $field = GetMarcFromKohaField( $kohafield );

    Returns the MARC fields & subfields mapped to $kohafield.
    Since the Default framework is considered as authoritative for such
    mappings, the former frameworkcode parameter is obsoleted.

    In list context all mappings are returned; there can be multiple
    mappings. Note that in the above example you could miss a second
    mappings in the first call.
    In scalar context only the field tag of the first mapping is returned.

=cut

sub GetMarcFromKohaField {
    my ( $kohafield ) = @_;
    return unless $kohafield;
    # The next call uses the Default framework since it is AUTHORITATIVE
    # for all Koha to MARC mappings.
    my $mss = GetMarcSubfieldStructure( '' ); # Do not change framework
    my @retval;
    foreach( @{ $mss->{$kohafield} } ) {
        push @retval, $_->{tagfield}, $_->{tagsubfield};
    }
    return wantarray ? @retval : ( @retval ? $retval[0] : undef );
}

=head2 GetMarcSubfieldStructureFromKohaField

    my $str = GetMarcSubfieldStructureFromKohaField( $kohafield );

    Returns marc subfield structure information for $kohafield.
    The Default framework is used, since it is authoritative for kohafield
    mappings.
    In list context returns a list of all hashrefs, since there may be
    multiple mappings. In scalar context the first hashref is returned.

=cut

sub GetMarcSubfieldStructureFromKohaField {
    my ( $kohafield ) = @_;

    return unless $kohafield;

    # The next call uses the Default framework since it is AUTHORITATIVE
    # for all Koha to MARC mappings.
    my $mss = GetMarcSubfieldStructure(''); # Do not change framework
    return unless $mss->{$kohafield};
    return wantarray ? @{$mss->{$kohafield}} : $mss->{$kohafield}->[0];
}

=head2 GetMarcBiblio

  my $record = GetMarcBiblio({
      biblionumber => $biblionumber,
      embed_items  => $embeditems,
      opac         => $opac });

Returns MARC::Record representing a biblio record, or C<undef> if the
biblionumber doesn't exist.

Both embed_items and opac are optional.
If embed_items is passed and is 1, items are embedded.
If opac is passed and is 1, the record is filtered as needed.

=over 4

=item C<$biblionumber>

the biblionumber

=item C<$embeditems>

set to true to include item information.

=item C<$opac>

set to true to make the result suited for OPAC view. This causes things like
OpacHiddenItems to be applied.

=back

=cut

sub GetMarcBiblio {
    my ($params) = @_;

    if (not defined $params) {
        carp 'GetMarcBiblio called without parameters';
        return;
    }

    my $biblionumber = $params->{biblionumber};
    my $embeditems   = $params->{embed_items} || 0;
    my $opac         = $params->{opac} || 0;

    if (not defined $biblionumber) {
        carp 'GetMarcBiblio called with undefined biblionumber';
        return;
    }

    my $dbh          = C4::Context->dbh;
    my $sth          = $dbh->prepare("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=? ");
    $sth->execute($biblionumber);
    my $row     = $sth->fetchrow_hashref;
    my $biblioitemnumber = $row->{'biblioitemnumber'};
    my $marcxml = GetXmlBiblio( $biblionumber );
    $marcxml = StripNonXmlChars( $marcxml );
    my $frameworkcode = GetFrameworkCode($biblionumber);
    MARC::File::XML->default_record_format( C4::Context->preference('marcflavour') );
    my $record = MARC::Record->new();

    if ($marcxml) {
        $record = eval {
            MARC::Record::new_from_xml( $marcxml, "utf8",
                C4::Context->preference('marcflavour') );
        };
        if ($@) { warn " problem with :$biblionumber : $@ \n$marcxml"; }
        return unless $record;

        C4::Biblio::_koha_marc_update_bib_ids( $record, $frameworkcode, $biblionumber,
            $biblioitemnumber );
        C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblionumber, undef, $opac )
          if ($embeditems);

        return $record;
    }
    else {
        return;
    }
}

=head2 GetXmlBiblio

  my $marcxml = GetXmlBiblio($biblionumber);

Returns biblio_metadata.metadata/marcxml of the biblionumber passed in parameter.
The XML should only contain biblio information (item information is no longer stored in marcxml field)

=cut

sub GetXmlBiblio {
    my ($biblionumber) = @_;
    my $dbh = C4::Context->dbh;
    return unless $biblionumber;
    my ($marcxml) = $dbh->selectrow_array(
        q|
        SELECT metadata
        FROM biblio_metadata
        WHERE biblionumber=?
            AND format='marcxml'
            AND marcflavour=?
    |, undef, $biblionumber, C4::Context->preference('marcflavour')
    );
    return $marcxml;
}

=head2 GetCOinSBiblio

  my $coins = GetCOinSBiblio($record);

Returns the COinS (a span) which can be included in a biblio record

=cut

sub GetCOinSBiblio {
    my $record = shift;

    # get the coin format
    if ( ! $record ) {
        carp 'GetCOinSBiblio called with undefined record';
        return;
    }
    my $pos7 = substr $record->leader(), 7, 1;
    my $pos6 = substr $record->leader(), 6, 1;
    my $mtx;
    my $genre;
    my ( $aulast, $aufirst ) = ( '', '' );
    my $oauthors  = '';
    my $title     = '';
    my $subtitle  = '';
    my $pubyear   = '';
    my $isbn      = '';
    my $issn      = '';
    my $publisher = '';
    my $pages     = '';
    my $titletype = 'b';

    # For the purposes of generating COinS metadata, LDR/06-07 can be
    # considered the same for UNIMARC and MARC21
    my $fmts6;
    my $fmts7;
    %$fmts6 = (
                'a' => 'book',
                'b' => 'manuscript',
                'c' => 'book',
                'd' => 'manuscript',
                'e' => 'map',
                'f' => 'map',
                'g' => 'film',
                'i' => 'audioRecording',
                'j' => 'audioRecording',
                'k' => 'artwork',
                'l' => 'document',
                'm' => 'computerProgram',
                'o' => 'document',
                'r' => 'document',
            );
    %$fmts7 = (
                    'a' => 'journalArticle',
                    's' => 'journal',
              );

    $genre = $fmts6->{$pos6} ? $fmts6->{$pos6} : 'book';

    if ( $genre eq 'book' ) {
            $genre = $fmts7->{$pos7} if $fmts7->{$pos7};
    }

    ##### We must transform mtx to a valable mtx and document type ####
    if ( $genre eq 'book' ) {
            $mtx = 'book';
    } elsif ( $genre eq 'journal' ) {
            $mtx = 'journal';
            $titletype = 'j';
    } elsif ( $genre eq 'journalArticle' ) {
            $mtx   = 'journal';
            $genre = 'article';
            $titletype = 'a';
    } else {
            $mtx = 'dc';
    }

    $genre = ( $mtx eq 'dc' ) ? "&amp;rft.type=$genre" : "&amp;rft.genre=$genre";

    if ( C4::Context->preference("marcflavour") eq "UNIMARC" ) {

        # Setting datas
        $aulast  = $record->subfield( '700', 'a' ) || '';
        $aufirst = $record->subfield( '700', 'b' ) || '';
        $oauthors = "&amp;rft.au=$aufirst $aulast";

        # others authors
        if ( $record->field('200') ) {
            for my $au ( $record->field('200')->subfield('g') ) {
                $oauthors .= "&amp;rft.au=$au";
            }
        }
        $title =
          ( $mtx eq 'dc' )
          ? "&amp;rft.title=" . $record->subfield( '200', 'a' )
          : "&amp;rft.title=" . $record->subfield( '200', 'a' ) . "&amp;rft.btitle=" . $record->subfield( '200', 'a' );
        $pubyear   = $record->subfield( '210', 'd' ) || '';
        $publisher = $record->subfield( '210', 'c' ) || '';
        $isbn      = $record->subfield( '010', 'a' ) || '';
        $issn      = $record->subfield( '011', 'a' ) || '';
    } else {

        # MARC21 need some improve

        # Setting datas
        if ( $record->field('100') ) {
            $oauthors .= "&amp;rft.au=" . $record->subfield( '100', 'a' );
        }

        # others authors
        if ( $record->field('700') ) {
            for my $au ( $record->field('700')->subfield('a') ) {
                $oauthors .= "&amp;rft.au=$au";
            }
        }
        $title = "&amp;rft." . $titletype . "title=" . $record->subfield( '245', 'a' );
        $subtitle = $record->subfield( '245', 'b' ) || '';
        $title .= $subtitle;
        if ($titletype eq 'a') {
            $pubyear   = $record->field('008') || '';
            $pubyear   = substr($pubyear->data(), 7, 4) if $pubyear;
            $isbn      = $record->subfield( '773', 'z' ) || '';
            $issn      = $record->subfield( '773', 'x' ) || '';
            if ($mtx eq 'journal') {
                $title    .= "&amp;rft.title=" . ( $record->subfield( '773', 't' ) || $record->subfield( '773', 'a') || q{} );
            } else {
                $title    .= "&amp;rft.btitle=" . ( $record->subfield( '773', 't' ) || $record->subfield( '773', 'a') || q{} );
            }
            foreach my $rel ($record->subfield( '773', 'g' )) {
                if ($pages) {
                    $pages .= ', ';
                }
                $pages .= $rel;
            }
        } else {
            $pubyear   = $record->subfield( '260', 'c' ) || '';
            $publisher = $record->subfield( '260', 'b' ) || '';
            $isbn      = $record->subfield( '020', 'a' ) || '';
            $issn      = $record->subfield( '022', 'a' ) || '';
        }

    }
    my $coins_value =
"ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A$mtx$genre$title&amp;rft.isbn=$isbn&amp;rft.issn=$issn&amp;rft.aulast=$aulast&amp;rft.aufirst=$aufirst$oauthors&amp;rft.pub=$publisher&amp;rft.date=$pubyear&amp;rft.pages=$pages";
    $coins_value =~ s/(\ |&[^a])/\+/g;
    $coins_value =~ s/\"/\&quot\;/g;

#<!-- TMPL_VAR NAME="ocoins_format" -->&amp;rft.au=<!-- TMPL_VAR NAME="author" -->&amp;rft.btitle=<!-- TMPL_VAR NAME="title" -->&amp;rft.date=<!-- TMPL_VAR NAME="publicationyear" -->&amp;rft.pages=<!-- TMPL_VAR NAME="pages" -->&amp;rft.isbn=<!-- TMPL_VAR NAME=amazonisbn -->&amp;rft.aucorp=&amp;rft.place=<!-- TMPL_VAR NAME="place" -->&amp;rft.pub=<!-- TMPL_VAR NAME="publishercode" -->&amp;rft.edition=<!-- TMPL_VAR NAME="edition" -->&amp;rft.series=<!-- TMPL_VAR NAME="series" -->&amp;rft.genre="

    return $coins_value;
}


=head2 GetMarcPrice

return the prices in accordance with the Marc format.

returns 0 if no price found
returns undef if called without a marc record or with
an unrecognized marc format

=cut

sub GetMarcPrice {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcPrice called on undefined record';
        return;
    }

    my @listtags;
    my $subfield;
    
    if ( $marcflavour eq "MARC21" || $marcflavour eq "NORMARC" ) {
        @listtags = ('345', '020');
        $subfield="c";
    } elsif ( $marcflavour eq "UNIMARC" ) {
        @listtags = ('345', '010');
        $subfield="d";
    } else {
        return;
    }
    
    for my $field ( $record->field(@listtags) ) {
        for my $subfield_value  ($field->subfield($subfield)){
            #check value
            $subfield_value = MungeMarcPrice( $subfield_value );
            return $subfield_value if ($subfield_value);
        }
    }
    return 0; # no price found
}

=head2 MungeMarcPrice

Return the best guess at what the actual price is from a price field.

=cut

sub MungeMarcPrice {
    my ( $price ) = @_;
    return unless ( $price =~ m/\d/ ); ## No digits means no price.
    # Look for the currency symbol and the normalized code of the active currency, if it's there,
    my $active_currency = Koha::Acquisition::Currencies->get_active;
    my $symbol = $active_currency->symbol;
    my $isocode = $active_currency->isocode;
    $isocode = $active_currency->currency unless defined $isocode;
    my $localprice;
    if ( $symbol ) {
        my @matches =($price=~ /
            \s?
            (                          # start of capturing parenthesis
            (?:
            (?:[\p{Sc}\p{L}\/.]){1,4}  # any character from Currency signs or Letter Unicode categories or slash or dot                                              within 1 to 4 occurrences : call this whole block 'symbol block'
            |(?:\d+[\p{P}\s]?){1,4}    # or else at least one digit followed or not by a punctuation sign or whitespace,                                             all these within 1 to 4 occurrences : call this whole block 'digits block'
            )
            \s?\p{Sc}?\s?              # followed or not by a whitespace. \p{Sc}?\s? are for cases like '25$ USD'
            (?:
            (?:[\p{Sc}\p{L}\/.]){1,4}  # followed by same block as symbol block
            |(?:\d+[\p{P}\s]?){1,4}    # or by same block as digits block
            )
            \s?\p{L}{0,4}\s?           # followed or not by a whitespace. \p{L}{0,4}\s? are for cases like '$9.50 USD'
            )                          # end of capturing parenthesis
            (?:\p{P}|\z)               # followed by a punctuation sign or by the end of the string
            /gx);

        if ( @matches ) {
            foreach ( @matches ) {
                $localprice = $_ and last if index($_, $isocode)>=0;
            }
            if ( !$localprice ) {
                foreach ( @matches ) {
                    $localprice = $_ and last if $_=~ /(^|[^\p{Sc}\p{L}\/])\Q$symbol\E([^\p{Sc}\p{L}\/]+\z|\z)/;
                }
            }
        }
    }
    if ( $localprice ) {
        $price = $localprice;
    } else {
        ## Grab the first number in the string ( can use commas or periods for thousands separator and/or decimal separator )
        ( $price ) = $price =~ m/([\d\,\.]+[[\,\.]\d\d]?)/;
    }
    # eliminate symbol/isocode, space and any final dot from the string
    $price =~ s/[\p{Sc}\p{L}\/ ]|\.$//g;
    # remove comma,dot when used as separators from hundreds
    $price =~s/[\,\.](\d{3})/$1/g;
    # convert comma to dot to ensure correct display of decimals if existing
    $price =~s/,/./;
    return $price;
}


=head2 GetMarcQuantity

return the quantity of a book. Used in acquisition only, when importing a file an iso2709 from a bookseller
Warning : this is not really in the marc standard. In Unimarc, Electre (the most widely used bookseller) use the 969$a

returns 0 if no quantity found
returns undef if called without a marc record or with
an unrecognized marc format

=cut

sub GetMarcQuantity {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcQuantity called on undefined record';
        return;
    }

    my @listtags;
    my $subfield;
    
    if ( $marcflavour eq "MARC21" ) {
        return 0
    } elsif ( $marcflavour eq "UNIMARC" ) {
        @listtags = ('969');
        $subfield="a";
    } else {
        return;
    }
    
    for my $field ( $record->field(@listtags) ) {
        for my $subfield_value  ($field->subfield($subfield)){
            #check value
            if ($subfield_value) {
                 # in France, the cents separator is the , but sometimes, ppl use a .
                 # in this case, the price will be x100 when unformatted ! Replace the . by a , to get a proper price calculation
                $subfield_value =~ s/\./,/ if C4::Context->preference("CurrencyFormat") eq "FR";
                return $subfield_value;
            }
        }
    }
    return 0; # no price found
}


=head2 GetAuthorisedValueDesc

  my $subfieldvalue =get_authorised_value_desc(
    $tag, $subf[$i][0],$subf[$i][1], '', $taglib, $category, $opac);

Retrieve the complete description for a given authorised value.

Now takes $category and $value pair too.

  my $auth_value_desc =GetAuthorisedValueDesc(
    '','', 'DVD' ,'','','CCODE');

If the optional $opac parameter is set to a true value, displays OPAC 
descriptions rather than normal ones when they exist.

=cut

sub GetAuthorisedValueDesc {
    my ( $tag, $subfield, $value, $framework, $tagslib, $category, $opac ) = @_;

    if ( !$category ) {

        return $value unless defined $tagslib->{$tag}->{$subfield}->{'authorised_value'};

        #---- branch
        if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
            return Koha::Libraries->find($value)->branchname;
        }

        #---- itemtypes
        if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "itemtypes" ) {
            my $itemtype = Koha::ItemTypes->find( $value );
            return $itemtype ? $itemtype->translated_description : q||;
        }

        #---- "true" authorized value
        $category = $tagslib->{$tag}->{$subfield}->{'authorised_value'};
    }

    my $dbh = C4::Context->dbh;
    if ( $category ne "" ) {
        my $sth = $dbh->prepare( "SELECT lib, lib_opac FROM authorised_values WHERE category = ? AND authorised_value = ?" );
        $sth->execute( $category, $value );
        my $data = $sth->fetchrow_hashref;
        return ( $opac && $data->{'lib_opac'} ) ? $data->{'lib_opac'} : $data->{'lib'};
    } else {
        return $value;    # if nothing is found return the original value
    }
}

=head2 GetMarcControlnumber

  $marccontrolnumber = GetMarcControlnumber($record,$marcflavour);

Get the control number / record Identifier from the MARC record and return it.

=cut

sub GetMarcControlnumber {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcControlnumber called on undefined record';
        return;
    }
    my $controlnumber = "";
    # Control number or Record identifier are the same field in MARC21, UNIMARC and NORMARC
    # Keep $marcflavour for possible later use
    if ($marcflavour eq "MARC21" || $marcflavour eq "UNIMARC" || $marcflavour eq "NORMARC") {
        my $controlnumberField = $record->field('001');
        if ($controlnumberField) {
            $controlnumber = $controlnumberField->data();
        }
    }
    return $controlnumber;
}

=head2 GetMarcISBN

  $marcisbnsarray = GetMarcISBN( $record, $marcflavour );

Get all ISBNs from the MARC record and returns them in an array.
ISBNs stored in different fields depending on MARC flavour

=cut

sub GetMarcISBN {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcISBN called on undefined record';
        return;
    }
    my $scope;
    if ( $marcflavour eq "UNIMARC" ) {
        $scope = '010';
    } else {    # assume marc21 if not unimarc
        $scope = '020';
    }

    my @marcisbns;
    foreach my $field ( $record->field($scope) ) {
        my $isbn = $field->subfield( 'a' );
        if ( $isbn ne "" ) {
            push @marcisbns, $isbn;
        }
    }

    return \@marcisbns;
}    # end GetMarcISBN


=head2 GetMarcISSN

  $marcissnsarray = GetMarcISSN( $record, $marcflavour );

Get all valid ISSNs from the MARC record and returns them in an array.
ISSNs are stored in different fields depending on MARC flavour

=cut

sub GetMarcISSN {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcISSN called on undefined record';
        return;
    }
    my $scope;
    if ( $marcflavour eq "UNIMARC" ) {
        $scope = '011';
    }
    else {    # assume MARC21 or NORMARC
        $scope = '022';
    }
    my @marcissns;
    foreach my $field ( $record->field($scope) ) {
        push @marcissns, $field->subfield( 'a' )
            if ( $field->subfield( 'a' ) ne "" );
    }
    return \@marcissns;
}    # end GetMarcISSN

=head2 GetMarcNotes

    $marcnotesarray = GetMarcNotes( $record, $marcflavour );

    Get all notes from the MARC record and returns them in an array.
    The notes are stored in different fields depending on MARC flavour.
    MARC21 5XX $u subfields receive special attention as they are URIs.

=cut

sub GetMarcNotes {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcNotes called on undefined record';
        return;
    }

    my $scope = $marcflavour eq "UNIMARC"? '3..': '5..';
    my @marcnotes;
    my %blacklist = map { $_ => 1 }
        split( /,/, C4::Context->preference('NotesBlacklist'));
    foreach my $field ( $record->field($scope) ) {
        my $tag = $field->tag();
        next if $blacklist{ $tag };
        if( $marcflavour ne 'UNIMARC' && $field->subfield('u') ) {
            # Field 5XX$u always contains URI
            # Examples: 505u, 506u, 510u, 514u, 520u, 530u, 538u, 540u, 542u, 552u, 555u, 561u, 563u, 583u
            # We first push the other subfields, then all $u's separately
            # Leave further actions to the template (see e.g. opac-detail)
            my $othersub =
                join '', ( 'a' .. 't', 'v' .. 'z', '0' .. '9' ); # excl 'u'
            push @marcnotes, { marcnote => $field->as_string($othersub) };
            foreach my $sub ( $field->subfield('u') ) {
                $sub =~ s/^\s+|\s+$//g; # trim
                push @marcnotes, { marcnote => $sub };
            }
        } else {
            push @marcnotes, { marcnote => $field->as_string() };
        }
    }
    return \@marcnotes;
}

=head2 GetMarcSubjects

  $marcsubjcts = GetMarcSubjects($record,$marcflavour);

Get all subjects from the MARC record and returns them in an array.
The subjects are stored in different fields depending on MARC flavour

=cut

sub GetMarcSubjects {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcSubjects called on undefined record';
        return;
    }
    my ( $mintag, $maxtag, $fields_filter );
    if ( $marcflavour eq "UNIMARC" ) {
        $mintag = "600";
        $maxtag = "611";
        $fields_filter = '6..';
    } else { # marc21/normarc
        $mintag = "600";
        $maxtag = "699";
        $fields_filter = '6..';
    }

    my @marcsubjects;

    my $subject_limit = C4::Context->preference("TraceCompleteSubfields") ? 'su,complete-subfield' : 'su';
    my $AuthoritySeparator = C4::Context->preference('AuthoritySeparator');

    foreach my $field ( $record->field($fields_filter) ) {
        next unless ($field->tag() >= $mintag && $field->tag() <= $maxtag);
        my @subfields_loop;
        my @subfields = $field->subfields();
        my @link_loop;

        # if there is an authority link, build the links with an= subfield9
        my $subfield9 = $field->subfield('9');
        my $authoritylink;
        if ($subfield9) {
            my $linkvalue = $subfield9;
            $linkvalue =~ s/(\(|\))//g;
            @link_loop = ( { limit => 'an', 'link' => $linkvalue } );
            $authoritylink = $linkvalue
        }

        # other subfields
        for my $subject_subfield (@subfields) {
            next if ( $subject_subfield->[0] eq '9' );

            # don't load unimarc subfields 3,4,5
            next if ( ( $marcflavour eq "UNIMARC" ) and ( $subject_subfield->[0] =~ /2|3|4|5/ ) );
            # don't load MARC21 subfields 2 (FIXME: any more subfields??)
            next if ( ( $marcflavour eq "MARC21" ) and ( $subject_subfield->[0] =~ /2/ ) );

            my $code      = $subject_subfield->[0];
            my $value     = $subject_subfield->[1];
            my $linkvalue = $value;
            $linkvalue =~ s/(\(|\))//g;
            # if no authority link, build a search query
            unless ($subfield9) {
                push @link_loop, {
                    limit    => $subject_limit,
                    'link'   => $linkvalue,
                    operator => (scalar @link_loop) ? ' and ' : undef
                };
            }
            my @this_link_loop = @link_loop;
            # do not display $0
            unless ( $code eq '0' ) {
                push @subfields_loop, {
                    code      => $code,
                    value     => $value,
                    link_loop => \@this_link_loop,
                    separator => (scalar @subfields_loop) ? $AuthoritySeparator : ''
                };
            }
        }

        push @marcsubjects, {
            MARCSUBJECT_SUBFIELDS_LOOP => \@subfields_loop,
            authoritylink => $authoritylink,
        } if $authoritylink || @subfields_loop;

    }
    return \@marcsubjects;
}    #end getMARCsubjects

=head2 GetMarcAuthors

  authors = GetMarcAuthors($record,$marcflavour);

Get all authors from the MARC record and returns them in an array.
The authors are stored in different fields depending on MARC flavour

=cut

sub GetMarcAuthors {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcAuthors called on undefined record';
        return;
    }
    my ( $mintag, $maxtag, $fields_filter );

    # tagslib useful only for UNIMARC author responsibilities
    my $tagslib;
    if ( $marcflavour eq "UNIMARC" ) {
        # FIXME : we don't have the framework available, we take the default framework. May be buggy on some setups, will be usually correct.
        $tagslib = GetMarcStructure( 1, '', { unsafe => 1 });
        $mintag = "700";
        $maxtag = "712";
        $fields_filter = '7..';
    } else { # marc21/normarc
        $mintag = "700";
        $maxtag = "720";
        $fields_filter = '7..';
    }

    my @marcauthors;
    my $AuthoritySeparator = C4::Context->preference('AuthoritySeparator');

    foreach my $field ( $record->field($fields_filter) ) {
        next unless $field->tag() >= $mintag && $field->tag() <= $maxtag;
        my @subfields_loop;
        my @link_loop;
        my @subfields  = $field->subfields();
        my $count_auth = 0;

        # if there is an authority link, build the link with Koha-Auth-Number: subfield9
        my $subfield9 = $field->subfield('9');
        if ($subfield9) {
            my $linkvalue = $subfield9;
            $linkvalue =~ s/(\(|\))//g;
            @link_loop = ( { 'limit' => 'an', 'link' => $linkvalue } );
        }

        # other subfields
        my $unimarc3;
        for my $authors_subfield (@subfields) {
            next if ( $authors_subfield->[0] eq '9' );

            # unimarc3 contains the $3 of the author for UNIMARC.
            # For french academic libraries, it's the "ppn", and it's required for idref webservice
            $unimarc3 = $authors_subfield->[1] if $marcflavour eq 'UNIMARC' and $authors_subfield->[0] =~ /3/;

            # don't load unimarc subfields 3, 5
            next if ( $marcflavour eq 'UNIMARC' and ( $authors_subfield->[0] =~ /3|5/ ) );

            my $code = $authors_subfield->[0];
            my $value        = $authors_subfield->[1];
            my $linkvalue    = $value;
            $linkvalue =~ s/(\(|\))//g;
            # UNIMARC author responsibility
            if ( $marcflavour eq 'UNIMARC' and $code eq '4' ) {
                $value = GetAuthorisedValueDesc( $field->tag(), $code, $value, '', $tagslib );
                $linkvalue = "($value)";
            }
            # if no authority link, build a search query
            unless ($subfield9) {
                push @link_loop, {
                    limit    => 'au',
                    'link'   => $linkvalue,
                    operator => (scalar @link_loop) ? ' and ' : undef
                };
            }
            my @this_link_loop = @link_loop;
            # do not display $0
            unless ( $code eq '0') {
                push @subfields_loop, {
                    tag       => $field->tag(),
                    code      => $code,
                    value     => $value,
                    link_loop => \@this_link_loop,
                    separator => (scalar @subfields_loop) ? $AuthoritySeparator : ''
                };
            }
        }
        push @marcauthors, {
            MARCAUTHOR_SUBFIELDS_LOOP => \@subfields_loop,
            authoritylink => $subfield9,
            unimarc3 => $unimarc3
        };
    }
    return \@marcauthors;
}

=head2 GetMarcUrls

  $marcurls = GetMarcUrls($record,$marcflavour);

Returns arrayref of URLs from MARC data, suitable to pass to tmpl loop.
Assumes web resources (not uncommon in MARC21 to omit resource type ind) 

=cut

sub GetMarcUrls {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcUrls called on undefined record';
        return;
    }

    my @marcurls;
    for my $field ( $record->field('856') ) {
        my @notes;
        for my $note ( $field->subfield('z') ) {
            push @notes, { note => $note };
        }
        my @urls = $field->subfield('u');
        foreach my $url (@urls) {
            $url =~ s/^\s+|\s+$//g; # trim
            my $marcurl;
            if ( $marcflavour eq 'MARC21' ) {
                my $s3   = $field->subfield('3');
                my $link = $field->subfield('y');
                unless ( $url =~ /^\w+:/ ) {
                    if ( $field->indicator(1) eq '7' ) {
                        $url = $field->subfield('2') . "://" . $url;
                    } elsif ( $field->indicator(1) eq '1' ) {
                        $url = 'ftp://' . $url;
                    } else {

                        #  properly, this should be if ind1=4,
                        #  however we will assume http protocol since we're building a link.
                        $url = 'http://' . $url;
                    }
                }

                # TODO handle ind 2 (relationship)
                $marcurl = {
                    MARCURL => $url,
                    notes   => \@notes,
                };
                $marcurl->{'linktext'} = $link || $s3 || C4::Context->preference('URLLinkText') || $url;
                $marcurl->{'part'} = $s3 if ($link);
                $marcurl->{'toc'} = 1 if ( defined($s3) && $s3 =~ /^[Tt]able/ );
            } else {
                $marcurl->{'linktext'} = $field->subfield('2') || C4::Context->preference('URLLinkText') || $url;
                $marcurl->{'MARCURL'} = $url;
            }
            push @marcurls, $marcurl;
        }
    }
    return \@marcurls;
}

=head2 GetMarcSeries

  $marcseriesarray = GetMarcSeries($record,$marcflavour);

Get all series from the MARC record and returns them in an array.
The series are stored in different fields depending on MARC flavour

=cut

sub GetMarcSeries {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcSeries called on undefined record';
        return;
    }

    my ( $mintag, $maxtag, $fields_filter );
    if ( $marcflavour eq "UNIMARC" ) {
        $mintag = "225";
        $maxtag = "225";
        $fields_filter = '2..';
    } else {    # marc21/normarc
        $mintag = "440";
        $maxtag = "490";
        $fields_filter = '4..';
    }

    my @marcseries;
    my $AuthoritySeparator = C4::Context->preference('AuthoritySeparator');

    foreach my $field ( $record->field($fields_filter) ) {
        next unless $field->tag() >= $mintag && $field->tag() <= $maxtag;
        my @subfields_loop;
        my @subfields = $field->subfields();
        my @link_loop;

        for my $series_subfield (@subfields) {

            # ignore $9, used for authority link
            next if ( $series_subfield->[0] eq '9' );

            my $volume_number;
            my $code      = $series_subfield->[0];
            my $value     = $series_subfield->[1];
            my $linkvalue = $value;
            $linkvalue =~ s/(\(|\))//g;

            # see if this is an instance of a volume
            if ( $code eq 'v' ) {
                $volume_number = 1;
            }

            push @link_loop, {
                'link' => $linkvalue,
                operator => (scalar @link_loop) ? ' and ' : undef
            };

            if ($volume_number) {
                push @subfields_loop, { volumenum => $value };
            } else {
                push @subfields_loop, {
                    code      => $code,
                    value     => $value,
                    link_loop => \@link_loop,
                    separator => (scalar @subfields_loop) ? $AuthoritySeparator : '',
                    volumenum => $volume_number,
                }
            }
        }
        push @marcseries, { MARCSERIES_SUBFIELDS_LOOP => \@subfields_loop };

    }
    return \@marcseries;
}    #end getMARCseriess

=head2 GetMarcHosts

  $marchostsarray = GetMarcHosts($record,$marcflavour);

Get all host records (773s MARC21, 461 UNIMARC) from the MARC record and returns them in an array.

=cut

sub GetMarcHosts {
    my ( $record, $marcflavour ) = @_;
    if (!$record) {
        carp 'GetMarcHosts called on undefined record';
        return;
    }

    my ( $tag,$title_subf,$bibnumber_subf,$itemnumber_subf);
    $marcflavour ||="MARC21";
    if ( $marcflavour eq "MARC21" || $marcflavour eq "NORMARC" ) {
        $tag = "773";
        $title_subf = "t";
        $bibnumber_subf ="0";
        $itemnumber_subf='9';
    }
    elsif ($marcflavour eq "UNIMARC") {
        $tag = "461";
        $title_subf = "t";
        $bibnumber_subf ="0";
        $itemnumber_subf='9';
    };

    my @marchosts;

    foreach my $field ( $record->field($tag)) {

        my @fields_loop;

        my $hostbiblionumber = $field->subfield("$bibnumber_subf");
        my $hosttitle = $field->subfield($title_subf);
        my $hostitemnumber=$field->subfield($itemnumber_subf);
        push @fields_loop, { hostbiblionumber => $hostbiblionumber, hosttitle => $hosttitle, hostitemnumber => $hostitemnumber};
        push @marchosts, { MARCHOSTS_FIELDS_LOOP => \@fields_loop };

        }
    my $marchostsarray = \@marchosts;
    return $marchostsarray;
}

=head2 UpsertMarcSubfield

    my $record = C4::Biblio::UpsertMarcSubfield($MARC::Record, $fieldTag, $subfieldCode, $subfieldContent);

=cut

sub UpsertMarcSubfield {
    my ($record, $tag, $code, $content) = @_;
    my $f = $record->field($tag);

    if ($f) {
        $f->update( $code => $content );
    }
    else {
        my $f = MARC::Field->new( $tag, '', '', $code => $content);
        $record->insert_fields_ordered( $f );
    }
}

=head2 UpsertMarcControlField

    my $record = C4::Biblio::UpsertMarcControlField($MARC::Record, $fieldTag, $content);

=cut

sub UpsertMarcControlField {
    my ($record, $tag, $content) = @_;
    die "UpsertMarcControlField() \$tag '$tag' is not a control field\n" unless 0+$tag < 10;
    my $f = $record->field($tag);

    if ($f) {
        $f->update( $content );
    }
    else {
        my $f = MARC::Field->new($tag, $content);
        $record->insert_fields_ordered( $f );
    }
}

=head2 GetFrameworkCode

  $frameworkcode = GetFrameworkCode( $biblionumber )

=cut

sub GetFrameworkCode {
    my ($biblionumber) = @_;
    my $dbh            = C4::Context->dbh;
    my $sth            = $dbh->prepare("SELECT frameworkcode FROM biblio WHERE biblionumber=?");
    $sth->execute($biblionumber);
    my ($frameworkcode) = $sth->fetchrow;
    return $frameworkcode;
}

=head2 TransformKohaToMarc

    $record = TransformKohaToMarc( $hash [, $params ]  )

This function builds a (partial) MARC::Record from a hash.
Hash entries can be from biblio, biblioitems or items.
The params hash includes the parameter no_split used in C4::Items.

This function is called in acquisition module, to create a basic catalogue
entry from user entry.

=cut


sub TransformKohaToMarc {
    my ( $hash, $params ) = @_;
    my $record = MARC::Record->new();
    SetMarcUnicodeFlag( $record, C4::Context->preference("marcflavour") );

    # In the next call we use the Default framework, since it is considered
    # authoritative for Koha to Marc mappings.
    my $mss = GetMarcSubfieldStructure( '' ); # do not change framework
    my $tag_hr = {};
    while ( my ($kohafield, $value) = each %$hash ) {
        foreach my $fld ( @{ $mss->{$kohafield} } ) {
            my $tagfield    = $fld->{tagfield};
            my $tagsubfield = $fld->{tagsubfield};
            next if !$tagfield;
            my @values = $params->{no_split}
                ? ( $value )
                : split(/\s?\|\s?/, $value, -1);
            foreach my $value ( @values ) {
                next if $value eq '';
                $tag_hr->{$tagfield} //= [];
                push @{$tag_hr->{$tagfield}}, [($tagsubfield, $value)];
            }
        }
    }
    foreach my $tag (sort keys %$tag_hr) {
        my @sfl = @{$tag_hr->{$tag}};
        @sfl = sort { $a->[0] cmp $b->[0]; } @sfl;
        @sfl = map { @{$_}; } @sfl;
        # Special care for control fields: remove the subfield indication @
        # and do not insert indicators.
        my @ind = $tag < 10 ? () : ( " ", " " );
        @sfl = grep { $_ ne '@' } @sfl if $tag < 10;
        $record->insert_fields_ordered( MARC::Field->new($tag, @ind, @sfl) );
    }
    return $record;
}

=head2 PrepHostMarcField

    $hostfield = PrepHostMarcField ( $hostbiblionumber,$hostitemnumber,$marcflavour )

This function returns a host field populated with data from the host record, the field can then be added to an analytical record

=cut

sub PrepHostMarcField {
    my ($hostbiblionumber,$hostitemnumber, $marcflavour) = @_;
    $marcflavour ||="MARC21";
    
    require C4::Items;
    my $hostrecord = GetMarcBiblio({ biblionumber => $hostbiblionumber });
	my $item = C4::Items::GetItem($hostitemnumber);
	
	my $hostmarcfield;
    if ( $marcflavour eq "MARC21" || $marcflavour eq "NORMARC" ) {
	
        #main entry
        my $mainentry;
        if ($hostrecord->subfield('100','a')){
            $mainentry = $hostrecord->subfield('100','a');
        } elsif ($hostrecord->subfield('110','a')){
            $mainentry = $hostrecord->subfield('110','a');
        } else {
            $mainentry = $hostrecord->subfield('111','a');
        }
	
        # qualification info
        my $qualinfo;
        if (my $field260 = $hostrecord->field('260')){
            $qualinfo =  $field260->as_string( 'abc' );
        }
	

    	#other fields
        my $ed = $hostrecord->subfield('250','a');
        my $barcode = $item->{'barcode'};
        my $title = $hostrecord->subfield('245','a');

        # record control number, 001 with 003 and prefix
        my $recctrlno;
        if ($hostrecord->field('001')){
            $recctrlno = $hostrecord->field('001')->data();
            if ($hostrecord->field('003')){
                $recctrlno = '('.$hostrecord->field('003')->data().')'.$recctrlno;
            }
        }

        # issn/isbn
        my $issn = $hostrecord->subfield('022','a');
        my $isbn = $hostrecord->subfield('020','a');


        $hostmarcfield = MARC::Field->new(
                773, '0', '',
                '0' => $hostbiblionumber,
                '9' => $hostitemnumber,
                'a' => $mainentry,
                'b' => $ed,
                'd' => $qualinfo,
                'o' => $barcode,
                't' => $title,
                'w' => $recctrlno,
                'x' => $issn,
                'z' => $isbn
                );
    } elsif ($marcflavour eq "UNIMARC") {
        $hostmarcfield = MARC::Field->new(
            461, '', '',
            '0' => $hostbiblionumber,
            't' => $hostrecord->subfield('200','a'), 
            '9' => $hostitemnumber
        );	
    };

    return $hostmarcfield;
}

=head2 TransformHtmlToXml

  $xml = TransformHtmlToXml( $tags, $subfields, $values, $indicator, 
                             $ind_tag, $auth_type )

$auth_type contains :

=over

=item - nothing : rebuild a biblio. In UNIMARC the encoding is in 100$a pos 26/27

=item - UNIMARCAUTH : rebuild an authority. In UNIMARC, the encoding is in 100$a pos 13/14

=item - ITEM : rebuild an item : in UNIMARC, 100$a, it's in the biblio ! (otherwise, we would get 2 100 fields !)

=back

=cut

sub TransformHtmlToXml {
    my ( $tags, $subfields, $values, $indicator, $ind_tag, $auth_type ) = @_;
    # NOTE: The parameter $ind_tag is NOT USED -- BZ 11247

    my $xml = MARC::File::XML::header('UTF-8');
    $xml .= "<record>\n";
    $auth_type = C4::Context->preference('marcflavour') unless $auth_type;
    MARC::File::XML->default_record_format($auth_type);

    # in UNIMARC, field 100 contains the encoding
    # check that there is one, otherwise the
    # MARC::Record->new_from_xml will fail (and Koha will die)
    my $unimarc_and_100_exist = 0;
    $unimarc_and_100_exist = 1 if $auth_type eq 'ITEM';    # if we rebuild an item, no need of a 100 field
    my $prevvalue;
    my $prevtag = -1;
    my $first   = 1;
    my $j       = -1;
    my $close_last_tag;
    for ( my $i = 0 ; $i < @$tags ; $i++ ) {

        if ( C4::Context->preference('marcflavour') eq 'UNIMARC' and @$tags[$i] eq "100" and @$subfields[$i] eq "a" ) {

            # if we have a 100 field and it's values are not correct, skip them.
            # if we don't have any valid 100 field, we will create a default one at the end
            my $enc = substr( @$values[$i], 26, 2 );
            if ( $enc eq '01' or $enc eq '50' or $enc eq '03' ) {
                $unimarc_and_100_exist = 1;
            } else {
                next;
            }
        }
        @$values[$i] =~ s/&/&amp;/g;
        @$values[$i] =~ s/</&lt;/g;
        @$values[$i] =~ s/>/&gt;/g;
        @$values[$i] =~ s/"/&quot;/g;
        @$values[$i] =~ s/'/&apos;/g;

        if ( ( @$tags[$i] ne $prevtag ) ) {
            $close_last_tag = 0;
            $j++ unless ( @$tags[$i] eq "" );
            my $indicator1 = eval { substr( @$indicator[$j], 0, 1 ) };
            my $indicator2 = eval { substr( @$indicator[$j], 1, 1 ) };
            my $ind1       = _default_ind_to_space($indicator1);
            my $ind2;
            if ( @$indicator[$j] ) {
                $ind2 = _default_ind_to_space($indicator2);
            } else {
                warn "Indicator in @$tags[$i] is empty";
                $ind2 = " ";
            }
            if ( !$first ) {
                $xml .= "</datafield>\n";
                if (   ( @$tags[$i] && @$tags[$i] > 10 )
                    && ( @$values[$i] ne "" ) ) {
                    $xml .= "<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                    $xml .= "<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                    $first = 0;
                    $close_last_tag = 1;
                } else {
                    $first = 1;
                }
            } else {
                if ( @$values[$i] ne "" ) {

                    # leader
                    if ( @$tags[$i] eq "000" ) {
                        $xml .= "<leader>@$values[$i]</leader>\n";
                        $first = 1;

                        # rest of the fixed fields
                    } elsif ( @$tags[$i] < 10 ) {
                        $xml .= "<controlfield tag=\"@$tags[$i]\">@$values[$i]</controlfield>\n";
                        $first = 1;
                    } else {
                        $xml .= "<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                        $xml .= "<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                        $first = 0;
                        $close_last_tag = 1;
                    }
                }
            }
        } else {    # @$tags[$i] eq $prevtag
            my $indicator1 = eval { substr( @$indicator[$j], 0, 1 ) };
            my $indicator2 = eval { substr( @$indicator[$j], 1, 1 ) };
            my $ind1       = _default_ind_to_space($indicator1);
            my $ind2;
            if ( @$indicator[$j] ) {
                $ind2 = _default_ind_to_space($indicator2);
            } else {
                warn "Indicator in @$tags[$i] is empty";
                $ind2 = " ";
            }
            if ( @$values[$i] eq "" ) {
            } else {
                if ($first) {
                    $xml .= "<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                    $first = 0;
                    $close_last_tag = 1;
                }
                $xml .= "<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
            }
        }
        $prevtag = @$tags[$i];
    }
    $xml .= "</datafield>\n" if $close_last_tag;
    if ( C4::Context->preference('marcflavour') eq 'UNIMARC' and !$unimarc_and_100_exist ) {

        #     warn "SETTING 100 for $auth_type";
        my $string = strftime( "%Y%m%d", localtime(time) );

        # set 50 to position 26 is biblios, 13 if authorities
        my $pos = 26;
        $pos = 13 if $auth_type eq 'UNIMARCAUTH';
        $string = sprintf( "%-*s", 35, $string );
        substr( $string, $pos, 6, "50" );
        $xml .= "<datafield tag=\"100\" ind1=\"\" ind2=\"\">\n";
        $xml .= "<subfield code=\"a\">$string</subfield>\n";
        $xml .= "</datafield>\n";
    }
    $xml .= "</record>\n";
    $xml .= MARC::File::XML::footer();
    return $xml;
}

=head2 _default_ind_to_space

Passed what should be an indicator returns a space
if its undefined or zero length

=cut

sub _default_ind_to_space {
    my $s = shift;
    if ( !defined $s || $s eq q{} ) {
        return ' ';
    }
    return $s;
}

=head2 TransformHtmlToMarc

    L<$record> = TransformHtmlToMarc(L<$cgi>)
    L<$cgi> is the CGI object which contains the values for subfields
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
    L<$record> is the MARC::Record object.

=cut

sub TransformHtmlToMarc {
    my ($cgi, $isbiblio) = @_;

    my @params = $cgi->multi_param();

    # explicitly turn on the UTF-8 flag for all
    # 'tag_' parameters to avoid incorrect character
    # conversion later on
    my $cgi_params = $cgi->Vars;
    foreach my $param_name ( keys %$cgi_params ) {
        if ( $param_name =~ /^tag_/ ) {
            my $param_value = $cgi_params->{$param_name};
            unless ( Encode::is_utf8( $param_value ) ) {
                $cgi_params->{$param_name} = Encode::decode('UTF-8', $param_value );
            }
        }
    }

    # creating a new record
    my $record = MARC::Record->new();
    my @fields;
    my ($biblionumbertagfield, $biblionumbertagsubfield) = (-1, -1);
    ($biblionumbertagfield, $biblionumbertagsubfield) =
        &GetMarcFromKohaField( "biblio.biblionumber", '' ) if $isbiblio;
#FIXME This code assumes that the CGI params will be in the same order as the fields in the template; this is no absolute guarantee!
    for (my $i = 0; $params[$i]; $i++ ) {    # browse all CGI params
        my $param    = $params[$i];
        my $newfield = 0;

        # if we are on biblionumber, store it in the MARC::Record (it may not be in the edited fields)
        if ( $param eq 'biblionumber' ) {
            if ( $biblionumbertagfield < 10 ) {
                $newfield = MARC::Field->new( $biblionumbertagfield, scalar $cgi->param($param), );
            } else {
                $newfield = MARC::Field->new( $biblionumbertagfield, '', '', "$biblionumbertagsubfield" => scalar $cgi->param($param), );
            }
            push @fields, $newfield if ($newfield);
        } elsif ( $param =~ /^tag_(\d*)_indicator1_/ ) {    # new field start when having 'input name="..._indicator1_..."
            my $tag = $1;

            my $ind1 = _default_ind_to_space( substr( $cgi->param($param), 0, 1 ) );
            my $ind2 = _default_ind_to_space( substr( $cgi->param( $params[ $i + 1 ] ), 0, 1 ) );
            $newfield = 0;
            my $j = $i + 2;

            if ( $tag < 10 ) {                              # no code for theses fields
                                                            # in MARC editor, 000 contains the leader.
                next if $tag == $biblionumbertagfield;
                my $fval= $cgi->param($params[$j+1]);
                if ( $tag eq '000' ) {
                    # Force a fake leader even if not provided to avoid crashing
                    # during decoding MARC record containing UTF-8 characters
                    $record->leader(
                        length( $fval ) == 24
                        ? $fval
                        : '     nam a22        4500'
			)
                    ;
                    # between 001 and 009 (included)
                } elsif ( $fval ne '' ) {
                    $newfield = MARC::Field->new( $tag, $fval, );
                }

                # > 009, deal with subfields
            } else {
                # browse subfields for this tag (reason for _code_ match)
                while(defined $params[$j] && $params[$j] =~ /_code_/) {
                    last unless defined $params[$j+1];
                    $j += 2 and next
                        if $tag == $biblionumbertagfield and
                           $cgi->param($params[$j]) eq $biblionumbertagsubfield;
                    #if next param ne subfield, then it was probably empty
                    #try next param by incrementing j
                    if($params[$j+1]!~/_subfield_/) {$j++; next; }
                    my $fkey= $cgi->param($params[$j]);
                    my $fval= $cgi->param($params[$j+1]);
                    #check if subfield value not empty and field exists
                    if($fval ne '' && $newfield) {
                        $newfield->add_subfields( $fkey => $fval);
                    }
                    elsif($fval ne '') {
                        $newfield = MARC::Field->new( $tag, $ind1, $ind2, $fkey => $fval );
                    }
                    $j += 2;
                } #end-of-while
                $i= $j-1; #update i for outer loop accordingly
            }
            push @fields, $newfield if ($newfield);
        }
    }

    $record->append_fields(@fields);
    return $record;
}

=head2 TransformMarcToKoha

    $result = TransformMarcToKoha( $record, undef, $limit )

Extract data from a MARC bib record into a hashref representing
Koha biblio, biblioitems, and items fields.

If passed an undefined record will log the error and return an empty
hash_ref.

=cut

sub TransformMarcToKoha {
    my ( $record, $frameworkcode, $limit_table ) = @_;
    # FIXME  Parameter $frameworkcode is obsolete and will be removed
    $limit_table //= q{};

    my $result = {};
    if (!defined $record) {
        carp('TransformMarcToKoha called with undefined record');
        return $result;
    }

    my %tables = ( biblio => 1, biblioitems => 1, items => 1 );
    if( $limit_table eq 'items' ) {
        %tables = ( items => 1 );
    }

    # The next call acknowledges Default as the authoritative framework
    # for Koha to MARC mappings.
    my $mss = GetMarcSubfieldStructure(''); # Do not change framework
    foreach my $kohafield ( keys %{ $mss } ) {
        my ( $table, $column ) = split /[.]/, $kohafield, 2;
        next unless $tables{$table};
        my $val = TransformMarcToKohaOneField( $kohafield, $record );
        next if !defined $val;
        my $key = _disambiguate( $table, $column );
        $result->{$key} = $val;
    }
    return $result;
}

=head2 _disambiguate

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

=cut

sub _disambiguate {
    my ( $table, $column ) = @_;
    if ( $column eq "cn_sort" or $column eq "cn_source" ) {
        return $table . '.' . $column;
    } else {
        return $column;
    }

}

=head2 TransformMarcToKohaOneField

    $val = TransformMarcToKohaOneField( 'biblio.title', $marc );

    Note: The authoritative Default framework is used implicitly.

=cut

sub TransformMarcToKohaOneField {
    my ( $kohafield, $marc ) = @_;

    my ( @rv, $retval );
    my @mss = GetMarcSubfieldStructureFromKohaField($kohafield);
    foreach my $fldhash ( @mss ) {
        my $tag = $fldhash->{tagfield};
        my $sub = $fldhash->{tagsubfield};
        foreach my $fld ( $marc->field($tag) ) {
            if( $sub eq '@' || $fld->is_control_field ) {
                push @rv, $fld->data if $fld->data;
            } else {
                push @rv, grep { $_ } $fld->subfield($sub);
            }
        }
    }
    return unless @rv;
    $retval = join ' | ', uniq(@rv);

    # Additional polishing for individual kohafields
    if( $kohafield =~ /copyrightdate|publicationyear/ ) {
        $retval = _adjust_pubyear( $retval );
    }

    return $retval;
}

=head2 _adjust_pubyear

    Helper routine for TransformMarcToKohaOneField

=cut

sub _adjust_pubyear {
    my $retval = shift;
    # modify return value to keep only the 1st year found
    if( $retval =~ m/c(\d\d\d\d)/ and $1 > 0 ) { # search cYYYY first
        $retval = $1;
    } elsif( $retval =~ m/(\d\d\d\d)/ && $1 > 0 ) {
        $retval = $1;
    } elsif( $retval =~ m/
             (?<year>\d)[-]?[.Xx?]{3}
            |(?<year>\d{2})[.Xx?]{2}
            |(?<year>\d{3})[.Xx?]
            |(?<year>\d)[-]{3}\?
            |(?<year>\d\d)[-]{2}\?
            |(?<year>\d{3})[-]\?
    /xms ) { # the form 198-? occurred in Dutch ISBD rules
        my $digits = $+{year};
        $retval = $digits * ( 10 ** ( 4 - length($digits) ));
    }
    return $retval;
}

=head2 CountItemsIssued

    my $count = CountItemsIssued( $biblionumber );

=cut

sub CountItemsIssued {
    my ($biblionumber) = @_;
    my $dbh            = C4::Context->dbh;
    my $sth            = $dbh->prepare('SELECT COUNT(*) as issuedCount FROM items, issues WHERE items.itemnumber = issues.itemnumber AND items.biblionumber = ?');
    $sth->execute($biblionumber);
    my $row = $sth->fetchrow_hashref();
    return $row->{'issuedCount'};
}

=head2 ModZebra

  ModZebra( $biblionumber, $op, $server, $record );

$biblionumber is the biblionumber we want to index

$op is specialUpdate or recordDelete, and is used to know what we want to do

$server is the server that we want to update

$record is the update MARC record if it's available. If it's not supplied
and is needed, it'll be loaded from the database.

=cut

sub ModZebra {
###Accepts a $server variable thus we can use it for biblios authorities or other zebra dbs
    my ( $biblionumber, $op, $server, $record ) = @_;
    $debug && warn "ModZebra: update requested for: $biblionumber $op $server\n";
    if ( C4::Context->preference('SearchEngine') eq 'Elasticsearch' ) {

        # TODO abstract to a standard API that'll work for whatever
        require Koha::SearchEngine::Elasticsearch::Indexer;
        my $indexer = Koha::SearchEngine::Elasticsearch::Indexer->new(
            {
                index => $server eq 'biblioserver'
                ? $Koha::SearchEngine::BIBLIOS_INDEX
                : $Koha::SearchEngine::AUTHORITIES_INDEX
            }
        );
        if ( $op eq 'specialUpdate' ) {
            unless ($record) {
                $record = GetMarcBiblio({
                    biblionumber => $biblionumber,
                    embed_items  => 1 });
            }
            my $records = [$record];
            $indexer->update_index_background( [$biblionumber], [$record] );
        }
        elsif ( $op eq 'recordDelete' ) {
            $indexer->delete_index_background( [$biblionumber] );
        }
        else {
            croak "ModZebra called with unknown operation: $op";
        }
    }

    my $dbh = C4::Context->dbh;

    # true ModZebra commented until indexdata fixes zebraDB crashes (it seems they occur on multiple updates
    # at the same time
    # replaced by a zebraqueue table, that is filled with ModZebra to run.
    # the table is emptied by rebuild_zebra.pl script (using the -z switch)
    my $check_sql = "SELECT COUNT(*) FROM zebraqueue
    WHERE server = ?
        AND   biblio_auth_number = ?
        AND   operation = ?
        AND   done = 0";
    my $check_sth = $dbh->prepare_cached($check_sql);
    $check_sth->execute( $server, $biblionumber, $op );
    my ($count) = $check_sth->fetchrow_array;
    $check_sth->finish();
    if ( $count == 0 ) {
        my $sth = $dbh->prepare("INSERT INTO zebraqueue  (biblio_auth_number,server,operation) VALUES(?,?,?)");
        $sth->execute( $biblionumber, $server, $op );
        $sth->finish;
    }
}


=head2 EmbedItemsInMarcBiblio

    EmbedItemsInMarcBiblio($marc, $biblionumber, $itemnumbers, $opac);

Given a MARC::Record object containing a bib record,
modify it to include the items attached to it as 9XX
per the bib's MARC framework.
if $itemnumbers is defined, only specified itemnumbers are embedded.

If $opac is true, then opac-relevant suppressions are included.

=cut

sub EmbedItemsInMarcBiblio {
    my ($marc, $biblionumber, $itemnumbers, $opac) = @_;
    if ( !$marc ) {
        carp 'EmbedItemsInMarcBiblio: No MARC record passed';
        return;
    }

    $itemnumbers = [] unless defined $itemnumbers;

    my $frameworkcode = GetFrameworkCode($biblionumber);
    _strip_item_fields($marc, $frameworkcode);

    # ... and embed the current items
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT itemnumber FROM items WHERE biblionumber = ?");
    $sth->execute($biblionumber);
    my @item_fields;
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField( "items.itemnumber", $frameworkcode );
    my @items;
    my $opachiddenitems = $opac
      && ( C4::Context->preference('OpacHiddenItems') !~ /^\s*$/ );
    require C4::Items;
    while ( my ($itemnumber) = $sth->fetchrow_array ) {
        next if @$itemnumbers and not grep { $_ == $itemnumber } @$itemnumbers;
        my $i = $opachiddenitems ? C4::Items::GetItem($itemnumber) : undef;
        push @items, { itemnumber => $itemnumber, item => $i };
    }
    my @hiddenitems =
      $opachiddenitems
      ? C4::Items::GetHiddenItemnumbers( map { $_->{item} } @items )
      : ();
    # Convert to a hash for quick searching
    my %hiddenitems = map { $_ => 1 } @hiddenitems;
    foreach my $itemnumber ( map { $_->{itemnumber} } @items ) {
        next if $hiddenitems{$itemnumber};
        my $item_marc = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
        push @item_fields, $item_marc->field($itemtag);
    }
    $marc->append_fields(@item_fields);
}

=head1 INTERNAL FUNCTIONS

=head2 _koha_marc_update_bib_ids


  _koha_marc_update_bib_ids($record, $frameworkcode, $biblionumber, $biblioitemnumber);

Internal function to add or update biblionumber and biblioitemnumber to
the MARC XML.

=cut

sub _koha_marc_update_bib_ids {
    my ( $record, $frameworkcode, $biblionumber, $biblioitemnumber ) = @_;

    my ( $biblio_tag,     $biblio_subfield )     = GetMarcFromKohaField( "biblio.biblionumber",          $frameworkcode );
    die qq{No biblionumber tag for framework "$frameworkcode"} unless $biblio_tag;
    my ( $biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField( "biblioitems.biblioitemnumber", $frameworkcode );
    die qq{No biblioitemnumber tag for framework "$frameworkcode"} unless $biblioitem_tag;

    if ( $biblio_tag < 10 ) {
        C4::Biblio::UpsertMarcControlField( $record, $biblio_tag, $biblionumber );
    } else {
        C4::Biblio::UpsertMarcSubfield($record, $biblio_tag, $biblio_subfield, $biblionumber);
    }
    if ( $biblioitem_tag < 10 ) {
        C4::Biblio::UpsertMarcControlField( $record, $biblioitem_tag, $biblioitemnumber );
    } else {
        C4::Biblio::UpsertMarcSubfield($record, $biblioitem_tag, $biblioitem_subfield, $biblioitemnumber);
    }
}

=head2 _koha_marc_update_biblioitem_cn_sort

  _koha_marc_update_biblioitem_cn_sort($marc, $biblioitem, $frameworkcode);

Given a MARC bib record and the biblioitem hash, update the
subfield that contains a copy of the value of biblioitems.cn_sort.

=cut

sub _koha_marc_update_biblioitem_cn_sort {
    my $marc          = shift;
    my $biblioitem    = shift;
    my $frameworkcode = shift;

    my ( $biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField( "biblioitems.cn_sort", $frameworkcode );
    return unless $biblioitem_tag;

    my ($cn_sort) = GetClassSort( $biblioitem->{'biblioitems.cn_source'}, $biblioitem->{'cn_class'}, $biblioitem->{'cn_item'} );

    if ( my $field = $marc->field($biblioitem_tag) ) {
        $field->delete_subfield( code => $biblioitem_subfield );
        if ( $cn_sort ne '' ) {
            $field->add_subfields( $biblioitem_subfield => $cn_sort );
        }
    } else {

        # if we get here, no biblioitem tag is present in the MARC record, so
        # we'll create it if $cn_sort is not empty -- this would be
        # an odd combination of events, however
        if ($cn_sort) {
            $marc->insert_grouped_field( MARC::Field->new( $biblioitem_tag, ' ', ' ', $biblioitem_subfield => $cn_sort ) );
        }
    }
}

=head2 _koha_add_biblio

  my ($biblionumber,$error) = _koha_add_biblio($dbh,$biblioitem);

Internal function to add a biblio ($biblio is a hash with the values)

=cut

sub _koha_add_biblio {
    my ( $dbh, $biblio, $frameworkcode ) = @_;

    my $error;

    # set the series flag
    unless (defined $biblio->{'serial'}){
    	$biblio->{'serial'} = 0;
    	if ( $biblio->{'seriestitle'} ) { $biblio->{'serial'} = 1 }
    }

    my $query = "INSERT INTO biblio
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
        $frameworkcode, $biblio->{'author'},      $biblio->{'title'},         $biblio->{'unititle'}, $biblio->{'notes'},
        $biblio->{'serial'},        $biblio->{'seriestitle'}, $biblio->{'copyrightdate'}, $biblio->{'abstract'}
    );

    my $biblionumber = $dbh->{'mysql_insertid'};
    if ( $dbh->errstr ) {
        $error .= "ERROR in _koha_add_biblio $query" . $dbh->errstr;
        warn $error;
    }

    $sth->finish();

    #warn "LEAVING _koha_add_biblio: ".$biblionumber."\n";
    return ( $biblionumber, $error );
}

=head2 _koha_modify_biblio

  my ($biblionumber,$error) == _koha_modify_biblio($dbh,$biblio,$frameworkcode);

Internal function for updating the biblio table

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
        $frameworkcode,      $biblio->{'author'},      $biblio->{'title'},         $biblio->{'unititle'}, $biblio->{'notes'},
        $biblio->{'serial'}, $biblio->{'seriestitle'}, $biblio->{'copyrightdate'}, $biblio->{'abstract'}, $biblio->{'biblionumber'}
    ) if $biblio->{'biblionumber'};

    if ( $dbh->errstr || !$biblio->{'biblionumber'} ) {
        $error .= "ERROR in _koha_modify_biblio $query" . $dbh->errstr;
        warn $error;
    }
    return ( $biblio->{'biblionumber'}, $error );
}

=head2 _koha_modify_biblioitem_nonmarc

  my ($biblioitemnumber,$error) = _koha_modify_biblioitem_nonmarc( $dbh, $biblioitem );

=cut

sub _koha_modify_biblioitem_nonmarc {
    my ( $dbh, $biblioitem ) = @_;
    my $error;

    # re-calculate the cn_sort, it may have changed
    my ($cn_sort) = GetClassSort( $biblioitem->{'biblioitems.cn_source'}, $biblioitem->{'cn_class'}, $biblioitem->{'cn_item'} );

    my $query = "UPDATE biblioitems 
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
        totalissues     = ?,
        ean             = ?,
        agerestriction  = ?
        where biblioitemnumber = ?
        ";
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $biblioitem->{'biblionumber'},     $biblioitem->{'volume'},           $biblioitem->{'number'},                $biblioitem->{'itemtype'},
        $biblioitem->{'isbn'},             $biblioitem->{'issn'},             $biblioitem->{'publicationyear'},       $biblioitem->{'publishercode'},
        $biblioitem->{'volumedate'},       $biblioitem->{'volumedesc'},       $biblioitem->{'collectiontitle'},       $biblioitem->{'collectionissn'},
        $biblioitem->{'collectionvolume'}, $biblioitem->{'editionstatement'}, $biblioitem->{'editionresponsibility'}, $biblioitem->{'illus'},
        $biblioitem->{'pages'},            $biblioitem->{'bnotes'},           $biblioitem->{'size'},                  $biblioitem->{'place'},
        $biblioitem->{'lccn'},             $biblioitem->{'url'},              $biblioitem->{'biblioitems.cn_source'}, $biblioitem->{'cn_class'},
        $biblioitem->{'cn_item'},          $biblioitem->{'cn_suffix'},        $cn_sort,                               $biblioitem->{'totalissues'},
        $biblioitem->{'ean'},              $biblioitem->{'agerestriction'},   $biblioitem->{'biblioitemnumber'}
    );
    if ( $dbh->errstr ) {
        $error .= "ERROR in _koha_modify_biblioitem_nonmarc $query" . $dbh->errstr;
        warn $error;
    }
    return ( $biblioitem->{'biblioitemnumber'}, $error );
}

=head2 _koha_add_biblioitem

  my ($biblioitemnumber,$error) = _koha_add_biblioitem( $dbh, $biblioitem );

Internal function to add a biblioitem

=cut

sub _koha_add_biblioitem {
    my ( $dbh, $biblioitem ) = @_;
    my $error;

    my ($cn_sort) = GetClassSort( $biblioitem->{'biblioitems.cn_source'}, $biblioitem->{'cn_class'}, $biblioitem->{'cn_item'} );
    my $query = "INSERT INTO biblioitems SET
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
        url             = ?,
        cn_source       = ?,
        cn_class        = ?,
        cn_item         = ?,
        cn_suffix       = ?,
        cn_sort         = ?,
        totalissues     = ?,
        ean             = ?,
        agerestriction  = ?
        ";
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $biblioitem->{'biblionumber'},     $biblioitem->{'volume'},           $biblioitem->{'number'},                $biblioitem->{'itemtype'},
        $biblioitem->{'isbn'},             $biblioitem->{'issn'},             $biblioitem->{'publicationyear'},       $biblioitem->{'publishercode'},
        $biblioitem->{'volumedate'},       $biblioitem->{'volumedesc'},       $biblioitem->{'collectiontitle'},       $biblioitem->{'collectionissn'},
        $biblioitem->{'collectionvolume'}, $biblioitem->{'editionstatement'}, $biblioitem->{'editionresponsibility'}, $biblioitem->{'illus'},
        $biblioitem->{'pages'},            $biblioitem->{'bnotes'},           $biblioitem->{'size'},                  $biblioitem->{'place'},
        $biblioitem->{'lccn'},             $biblioitem->{'url'},                   $biblioitem->{'biblioitems.cn_source'},
        $biblioitem->{'cn_class'},         $biblioitem->{'cn_item'},          $biblioitem->{'cn_suffix'},             $cn_sort,
        $biblioitem->{'totalissues'},      $biblioitem->{'ean'},              $biblioitem->{'agerestriction'}
    );
    my $bibitemnum = $dbh->{'mysql_insertid'};

    if ( $dbh->errstr ) {
        $error .= "ERROR in _koha_add_biblioitem $query" . $dbh->errstr;
        warn $error;
    }
    $sth->finish();
    return ( $bibitemnum, $error );
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

    # FIXME There is a transaction in _koha_delete_biblio_metadata
    # But actually all the following should be done inside a single transaction
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

        _koha_delete_biblio_metadata( $biblionumber );

        # delete the biblio
        my $sth2 = $dbh->prepare("DELETE FROM biblio WHERE biblionumber=?");
        $sth2->execute($biblionumber);
        # update the timestamp (Bugzilla 7146)
        $sth2= $dbh->prepare("UPDATE deletedbiblio SET timestamp=NOW() WHERE biblionumber=?");
        $sth2->execute($biblionumber);
        $sth2->finish;
    }
    $sth->finish;
    return;
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
    my $sth = $dbh->prepare("SELECT * FROM biblioitems WHERE biblioitemnumber=?");
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
        my $sth2 = $dbh->prepare("DELETE FROM biblioitems WHERE biblioitemnumber=?");
        $sth2->execute($biblioitemnumber);
        # update the timestamp (Bugzilla 7146)
        $sth2= $dbh->prepare("UPDATE deletedbiblioitems SET timestamp=NOW() WHERE biblioitemnumber=?");
        $sth2->execute($biblioitemnumber);
        $sth2->finish;
    }
    $sth->finish;
    return;
}

=head2 _koha_delete_biblio_metadata

  $error = _koha_delete_biblio_metadata($biblionumber);

C<$biblionumber> - the biblionumber of the biblio metadata to be deleted

=cut

sub _koha_delete_biblio_metadata {
    my ($biblionumber) = @_;

    my $dbh    = C4::Context->dbh;
    my $schema = Koha::Database->new->schema;
    $schema->txn_do(
        sub {
            $dbh->do( q|
                INSERT INTO deletedbiblio_metadata (biblionumber, format, marcflavour, metadata)
                SELECT biblionumber, format, marcflavour, metadata FROM biblio_metadata WHERE biblionumber=?
            |,  undef, $biblionumber );
            $dbh->do( q|DELETE FROM biblio_metadata WHERE biblionumber=?|,
                undef, $biblionumber );
        }
    );
}

=head1 UNEXPORTED FUNCTIONS

=head2 ModBiblioMarc

  &ModBiblioMarc($newrec,$biblionumber,$frameworkcode);

Add MARC XML data for a biblio to koha

Function exported, but should NOT be used, unless you really know what you're doing

=cut

sub ModBiblioMarc {
    # pass the MARC::Record to this function, and it will create the records in
    # the marcxml field
    my ( $record, $biblionumber, $frameworkcode ) = @_;
    if ( !$record ) {
        carp 'ModBiblioMarc passed an undefined record';
        return;
    }

    # Clone record as it gets modified
    $record = $record->clone();
    my $dbh    = C4::Context->dbh;
    my @fields = $record->fields();
    if ( !$frameworkcode ) {
        $frameworkcode = "";
    }
    my $sth = $dbh->prepare("UPDATE biblio SET frameworkcode=? WHERE biblionumber=?");
    $sth->execute( $frameworkcode, $biblionumber );
    $sth->finish;
    my $encoding = C4::Context->preference("marcflavour");

    # deal with UNIMARC field 100 (encoding) : create it if needed & set encoding to unicode
    if ( $encoding eq "UNIMARC" ) {
	my $defaultlanguage = C4::Context->preference("UNIMARCField100Language");
        $defaultlanguage = "fre" if (!$defaultlanguage || length($defaultlanguage) != 3);
        my $string = $record->subfield( 100, "a" );
        if ( ($string) && ( length( $record->subfield( 100, "a" ) ) == 36 ) ) {
            my $f100 = $record->field(100);
            $record->delete_field($f100);
        } else {
            $string = POSIX::strftime( "%Y%m%d", localtime );
            $string =~ s/\-//g;
            $string = sprintf( "%-*s", 35, $string );
	    substr ( $string, 22, 3, $defaultlanguage);
        }
        substr( $string, 25, 3, "y50" );
        unless ( $record->subfield( 100, "a" ) ) {
            $record->insert_fields_ordered( MARC::Field->new( 100, "", "", "a" => $string ) );
        }
    }

    #enhancement 5374: update transaction date (005) for marc21/unimarc
    if($encoding =~ /MARC21|UNIMARC/) {
      my @a= (localtime) [5,4,3,2,1,0]; $a[0]+=1900; $a[1]++;
        # YY MM DD HH MM SS (update year and month)
      my $f005= $record->field('005');
      $f005->update(sprintf("%4d%02d%02d%02d%02d%04.1f",@a)) if $f005;
    }

    my $metadata = {
        biblionumber => $biblionumber,
        format       => 'marcxml',
        marcflavour  => C4::Context->preference('marcflavour'),
    };
    $record->as_usmarc; # Bug 20126/10455 This triggers field length calculation

    # FIXME To replace with ->find_or_create?
    if ( my $m_rs = Koha::Biblio::Metadatas->find($metadata) ) {
        $m_rs->metadata( $record->as_xml_record($encoding) );
        $m_rs->store;
    } else {
        my $m_rs = Koha::Biblio::Metadata->new($metadata);
        $m_rs->metadata( $record->as_xml_record($encoding) );
        $m_rs->store;
    }
    ModZebra( $biblionumber, "specialUpdate", "biblioserver", $record );
    return $biblionumber;
}

=head2 CountBiblioInOrders

    $count = &CountBiblioInOrders( $biblionumber);

This function return count of biblios in orders with $biblionumber 

=cut

sub CountBiblioInOrders {
 my ($biblionumber) = @_;
    my $dbh            = C4::Context->dbh;
    my $query          = "SELECT count(*)
          FROM  aqorders 
          WHERE biblionumber=? AND (datecancellationprinted IS NULL OR datecancellationprinted='0000-00-00')";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my $count = $sth->fetchrow;
    return ($count);
}

=head2 prepare_host_field

$marcfield = prepare_host_field( $hostbiblioitem, $marcflavour );
Generate the host item entry for an analytic child entry

=cut

sub prepare_host_field {
    my ( $hostbiblio, $marcflavour ) = @_;
    $marcflavour ||= C4::Context->preference('marcflavour');
    my $host = GetMarcBiblio({ biblionumber => $hostbiblio });
    # unfortunately as_string does not 'do the right thing'
    # if field returns undef
    my %sfd;
    my $field;
    my $host_field;
    if ( $marcflavour eq 'MARC21' || $marcflavour eq 'NORMARC' ) {
        if ( $field = $host->field('100') || $host->field('110') || $host->field('11') ) {
            my $s = $field->as_string('ab');
            if ($s) {
                $sfd{a} = $s;
            }
        }
        if ( $field = $host->field('245') ) {
            my $s = $field->as_string('a');
            if ($s) {
                $sfd{t} = $s;
            }
        }
        if ( $field = $host->field('260') ) {
            my $s = $field->as_string('abc');
            if ($s) {
                $sfd{d} = $s;
            }
        }
        if ( $field = $host->field('240') ) {
            my $s = $field->as_string();
            if ($s) {
                $sfd{b} = $s;
            }
        }
        if ( $field = $host->field('022') ) {
            my $s = $field->as_string('a');
            if ($s) {
                $sfd{x} = $s;
            }
        }
        if ( $field = $host->field('020') ) {
            my $s = $field->as_string('a');
            if ($s) {
                $sfd{z} = $s;
            }
        }
        if ( $field = $host->field('001') ) {
            $sfd{w} = $field->data(),;
        }
        $host_field = MARC::Field->new( 773, '0', ' ', %sfd );
        return $host_field;
    }
    elsif ( $marcflavour eq 'UNIMARC' ) {
        #author
        if ( $field = $host->field('700') || $host->field('710') || $host->field('720') ) {
            my $s = $field->as_string('ab');
            if ($s) {
                $sfd{a} = $s;
            }
        }
        #title
        if ( $field = $host->field('200') ) {
            my $s = $field->as_string('a');
            if ($s) {
                $sfd{t} = $s;
            }
        }
        #place of publicaton
        if ( $field = $host->field('210') ) {
            my $s = $field->as_string('a');
            if ($s) {
                $sfd{c} = $s;
            }
        }
        #date of publication
        if ( $field = $host->field('210') ) {
            my $s = $field->as_string('d');
            if ($s) {
                $sfd{d} = $s;
            }
        }
        #edition statement
        if ( $field = $host->field('205') ) {
            my $s = $field->as_string();
            if ($s) {
                $sfd{e} = $s;
            }
        }
        #URL
        if ( $field = $host->field('856') ) {
            my $s = $field->as_string('u');
            if ($s) {
                $sfd{u} = $s;
            }
        }
        #ISSN
        if ( $field = $host->field('011') ) {
            my $s = $field->as_string('a');
            if ($s) {
                $sfd{x} = $s;
            }
        }
        #ISBN
        if ( $field = $host->field('010') ) {
            my $s = $field->as_string('a');
            if ($s) {
                $sfd{y} = $s;
            }
        }
        if ( $field = $host->field('001') ) {
            $sfd{0} = $field->data(),;
        }
        $host_field = MARC::Field->new( 461, '0', ' ', %sfd );
        return $host_field;
    }
    return;
}


=head2 UpdateTotalIssues

  UpdateTotalIssues($biblionumber, $increase, [$value])

Update the total issue count for a particular bib record.

=over 4

=item C<$biblionumber> is the biblionumber of the bib to update

=item C<$increase> is the amount to increase (or decrease) the total issues count by

=item C<$value> is the absolute value that total issues count should be set to. If provided, C<$increase> is ignored.

=back

=cut

sub UpdateTotalIssues {
    my ($biblionumber, $increase, $value) = @_;
    my $totalissues;

    my $record = GetMarcBiblio({ biblionumber => $biblionumber });
    unless ($record) {
        carp "UpdateTotalIssues could not get biblio record";
        return;
    }
    my $biblio = Koha::Biblios->find( $biblionumber );
    unless ($biblio) {
        carp "UpdateTotalIssues could not get datas of biblio";
        return;
    }
    my $biblioitem = $biblio->biblioitem;
    my ($totalissuestag, $totalissuessubfield) = GetMarcFromKohaField('biblioitems.totalissues', $biblio->frameworkcode);
    unless ($totalissuestag) {
        return 1; # There is nothing to do
    }

    if (defined $value) {
        $totalissues = $value;
    } else {
        $totalissues = $biblioitem->totalissues + $increase;
    }

     my $field = $record->field($totalissuestag);
     if (defined $field) {
         $field->update( $totalissuessubfield => $totalissues );
     } else {
         $field = MARC::Field->new($totalissuestag, '0', '0',
                 $totalissuessubfield => $totalissues);
         $record->insert_grouped_field($field);
     }

     return ModBiblio($record, $biblionumber, $biblio->frameworkcode);
}

=head2 RemoveAllNsb

    &RemoveAllNsb($record);

Removes all nsb/nse chars from a record

=cut

sub RemoveAllNsb {
    my $record = shift;
    if (!$record) {
        carp 'RemoveAllNsb called with undefined record';
        return;
    }

    SetUTF8Flag($record);

    foreach my $field ($record->fields()) {
        if ($field->is_control_field()) {
            $field->update(nsb_clean($field->data()));
        } else {
            my @subfields = $field->subfields();
            my @new_subfields;
            foreach my $subfield (@subfields) {
                push @new_subfields, $subfield->[0] => nsb_clean($subfield->[1]);
            }
            if (scalar(@new_subfields) > 0) {
                my $new_field;
                eval {
                    $new_field = MARC::Field->new(
                        $field->tag(),
                        $field->indicator(1),
                        $field->indicator(2),
                        @new_subfields
                    );
                };
                if ($@) {
                    warn "error in RemoveAllNsb : $@";
                } else {
                    $field->replace_with($new_field);
                }
            }
        }
    }

    return $record;
}

1;


__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Paul POULAIN paul.poulain@free.fr

Joshua Ferraro jmf@liblime.com

=cut
