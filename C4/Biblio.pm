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

use vars qw(@ISA @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);

    @EXPORT_OK = qw(
        AddBiblio
        GetBiblioData
        GetISBDView
        GetMarcControlnumber
        GetMarcISBN
        GetMarcISSN
        GetMarcSubjects
        GetMarcSeries
        GetMarcUrls
        GetUsedMarcStructure
        GetXmlBiblio
        GetMarcPrice
        MungeMarcPrice
        GetMarcQuantity
        GetAuthorisedValueDesc
        GetMarcStructure
        GetMarcSubfieldStructure
        IsMarcStructureInternal
        GetMarcFromKohaField
        GetMarcSubfieldStructureFromKohaField
        GetFrameworkCode
        TransformKohaToMarc
        PrepHostMarcField
        CountItemsIssued
        ModBiblio
        ModZebra
        UpdateTotalIssues
        RemoveAllNsb
        DelBiblio
        BiblioAutoLink
        LinkBibHeadingsToAuthorities
        ApplyMarcOverlayRules
        TransformMarcToKoha
        TransformHtmlToMarc
        TransformHtmlToXml
        prepare_host_field
    );

    # Internal functions
    # those functions are exported but should not be used
    # they are useful in a few circumstances, so they are exported,
    # but don't use them unless you are a core developer ;-)
    push @EXPORT_OK, qw(
      ModBiblioMarc
    );
}

use Carp qw( carp );
use Try::Tiny qw( catch try );

use Encode;
use List::MoreUtils qw( uniq );
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use POSIX qw( strftime );
use Module::Load::Conditional qw( can_load );

use C4::Koha;
use C4::Log qw( logaction );    # logaction
use C4::Budgets;
use C4::ClassSource qw( GetClassSort GetClassSource );
use C4::Charset qw(
    nsb_clean
    SetMarcUnicodeFlag
    SetUTF8Flag
);
use C4::Languages;
use C4::Linker;
use C4::OAI::Sets;
use C4::Items qw( GetMarcItem );

use Koha::Logger;
use Koha::Caches;
use Koha::ClassSources;
use Koha::Authority::Types;
use Koha::Acquisition::Currencies;
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::Biblio::Metadatas;
use Koha::Holds;
use Koha::ItemTypes;
use Koha::MarcOverlayRules;
use Koha::Plugins;
use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;
use Koha::Libraries;
use Koha::Util::MARC;

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

The C<$options> argument is a hashref with additional parameters:

=over 4

=item B<defer_marc_save>: used when ModBiblioMarc is handled by the caller

=item B<skip_record_index>: used when the indexing schedulling will be handled by the caller

=back

=cut

sub AddBiblio {
    my ( $record, $frameworkcode, $options ) = @_;

    $options //= {};
    my $skip_record_index = $options->{skip_record_index} || 0;
    my $defer_marc_save   = $options->{defer_marc_save}   || 0;

    if (!$record) {
        carp('AddBiblio called with undefined record');
        return;
    }

    my $schema = Koha::Database->schema;
    my ( $biblionumber, $biblioitemnumber );
    try {
        $schema->txn_do(sub {

            # transform the data into koha-table style data
            SetUTF8Flag($record);
            my $olddata = TransformMarcToKoha({ record => $record, limit_table => 'no_items' });

            my $biblio = Koha::Biblio->new(
                {
                    frameworkcode => $frameworkcode,
                    author        => $olddata->{author},
                    title         => $olddata->{title},
                    subtitle      => $olddata->{subtitle},
                    medium        => $olddata->{medium},
                    part_number   => $olddata->{part_number},
                    part_name     => $olddata->{part_name},
                    unititle      => $olddata->{unititle},
                    notes         => $olddata->{notes},
                    serial        => $olddata->{serial},
                    seriestitle   => $olddata->{seriestitle},
                    copyrightdate => $olddata->{copyrightdate},
                    datecreated   => \'NOW()',
                    abstract      => $olddata->{abstract},
                }
            )->store;
            $biblionumber = $biblio->biblionumber;
            Koha::Exceptions::ObjectNotCreated->throw unless $biblio;

            my ($cn_sort) = GetClassSort( $olddata->{'biblioitems.cn_source'}, $olddata->{'cn_class'}, $olddata->{'cn_item'} );
            my $biblioitem = Koha::Biblioitem->new(
                {
                    biblionumber          => $biblionumber,
                    volume                => $olddata->{volume},
                    number                => $olddata->{number},
                    itemtype              => $olddata->{itemtype},
                    isbn                  => $olddata->{isbn},
                    issn                  => $olddata->{issn},
                    publicationyear       => $olddata->{publicationyear},
                    publishercode         => $olddata->{publishercode},
                    volumedate            => $olddata->{volumedate},
                    volumedesc            => $olddata->{volumedesc},
                    collectiontitle       => $olddata->{collectiontitle},
                    collectionissn        => $olddata->{collectionissn},
                    collectionvolume      => $olddata->{collectionvolume},
                    editionstatement      => $olddata->{editionstatement},
                    editionresponsibility => $olddata->{editionresponsibility},
                    illus                 => $olddata->{illus},
                    pages                 => $olddata->{pages},
                    notes                 => $olddata->{bnotes},
                    size                  => $olddata->{size},
                    place                 => $olddata->{place},
                    lccn                  => $olddata->{lccn},
                    url                   => $olddata->{url},
                    cn_source      => $olddata->{'biblioitems.cn_source'},
                    cn_class       => $olddata->{cn_class},
                    cn_item        => $olddata->{cn_item},
                    cn_suffix      => $olddata->{cn_suff},
                    cn_sort        => $cn_sort,
                    totalissues    => $olddata->{totalissues},
                    ean            => $olddata->{ean},
                    agerestriction => $olddata->{agerestriction},
                }
            )->store;
            Koha::Exceptions::ObjectNotCreated->throw unless $biblioitem;
            $biblioitemnumber = $biblioitem->biblioitemnumber;

            _koha_marc_update_bib_ids( $record, $frameworkcode, $biblionumber, $biblioitemnumber );

            # update MARC subfield that stores biblioitems.cn_sort
            _koha_marc_update_biblioitem_cn_sort( $record, $olddata, $frameworkcode );

            if (C4::Context->preference('AutoLinkBiblios')) {
                BiblioAutoLink( $record, $frameworkcode );
            }

            # now add the record, don't index while we are in the transaction though
            ModBiblioMarc( $record, $biblionumber, { skip_record_index => 1 } ) unless $defer_marc_save;

            # update OAI-PMH sets
            if(C4::Context->preference("OAI-PMH:AutoUpdateSets")) {
                C4::OAI::Sets::UpdateOAISetsBiblio($biblionumber, $record);
            }

            _after_biblio_action_hooks({ action => 'create', biblio_id => $biblionumber });

            logaction( "CATALOGUING", "ADD", $biblionumber, "biblio" ) if C4::Context->preference("CataloguingLog");

        });
        # We index now, after the transaction is committed
        unless ( $skip_record_index ) {
            my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
            $indexer->index_records( $biblionumber, "specialUpdate", "biblioserver" );
        }
    } catch {
        warn $_;
        ( $biblionumber, $biblioitemnumber ) = ( undef, undef );
    };
    return ( $biblionumber, $biblioitemnumber );
}

=head2 ModBiblio

  ModBiblio($record, $biblionumber, $frameworkcode, $options);

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

The C<$options> argument is a hashref with additional parameters:

=over 4

=item C<overlay_context>

This parameter is forwarded to L</ApplyMarcOverlayRules> where it is used for
selecting the current rule set if MARCOverlayRules is enabled.
See L</ApplyMarcOverlayRules> for more details.

=item C<disable_autolink>

Unless C<disable_autolink> is passed ModBiblio will relink record headings
to authorities based on settings in the system preferences. This flag allows
us to not relink records when the authority linker is saving modifications.

=item C<skip_holds_queue>

Unless C<skip_holds_queue> is passed, ModBiblio will trigger the BatchUpdateBiblioHoldsQueue
task to rebuild the holds queue for the biblio if I<RealTimeHoldsQueue> is enabled.

=back

Returns 1 on success 0 on failure

=cut

sub ModBiblio {
    my ( $record, $biblionumber, $frameworkcode, $options ) = @_;

    $options //= {};
    my $skip_record_index = $options->{skip_record_index} || 0;

    if (!$record) {
        carp 'No record passed to ModBiblio';
        return 0;
    }

    if ( C4::Context->preference("CataloguingLog") ) {
        my $biblio = Koha::Biblios->find($biblionumber);
        logaction( "CATALOGUING", "MODIFY", $biblionumber, "biblio BEFORE=>" . $biblio->metadata->record->as_formatted );
    }

    if ( !$options->{disable_autolink} && C4::Context->preference('AutoLinkBiblios') ) {
        BiblioAutoLink( $record, $frameworkcode );
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

    # apply overlay rules
    if (   C4::Context->preference('MARCOverlayRules')
        && $biblionumber
        && defined $options
        && exists $options->{overlay_context} )
    {
        $record = ApplyMarcOverlayRules(
            {
                biblionumber    => $biblionumber,
                record          => $record,
                overlay_context => $options->{overlay_context},
            }
        );
    }

    # update biblionumber and biblioitemnumber in MARC
    # FIXME - this is assuming a 1 to 1 relationship between
    # biblios and biblioitems
    my $sth = $dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblionumber);
    my ($biblioitemnumber) = $sth->fetchrow;
    $sth->finish();
    _koha_marc_update_bib_ids( $record, $frameworkcode, $biblionumber, $biblioitemnumber );

    # load the koha-table data object
    my $oldbiblio = TransformMarcToKoha({ record => $record });

    # update MARC subfield that stores biblioitems.cn_sort
    _koha_marc_update_biblioitem_cn_sort( $record, $oldbiblio, $frameworkcode );

    # update the MARC record (that now contains biblio and items) with the new record data
    ModBiblioMarc( $record, $biblionumber, { skip_record_index => $skip_record_index } );

    # modify the other koha tables
    _koha_modify_biblio( $dbh, $oldbiblio, $frameworkcode );
    _koha_modify_biblioitem_nonmarc( $dbh, $oldbiblio );

    _after_biblio_action_hooks({ action => 'modify', biblio_id => $biblionumber });

    # update OAI-PMH sets
    if(C4::Context->preference("OAI-PMH:AutoUpdateSets")) {
        C4::OAI::Sets::UpdateOAISetsBiblio($biblionumber, $record);
    }

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
        {
            biblio_ids => [ $biblionumber ]
        }
    ) unless $options->{skip_holds_queue} or !C4::Context->preference('RealTimeHoldsQueue');

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
    my ( $itemtag, $itemsubfield ) = GetMarcFromKohaField( "items.itemnumber" );

    # delete any item fields from incoming record to avoid
    # duplication or incorrect data - use AddItem() or ModItem()
    # to change items
    foreach my $field ( $record->field($itemtag) ) {
        $record->delete_field($field);
    }
}

=head2 DelBiblio

  my $error = &DelBiblio($biblionumber, $params);

Exported function (core API) for deleting a biblio in koha.
Deletes biblio record from Zebra and Koha tables (biblio & biblioitems)
Also backs it up to deleted* tables.
Checks to make sure that the biblio has no items attached.
return:
C<$error> : undef unless an error occurs

I<$params> is a hashref containing extra parameters. Valid keys are:

=over 4

=item B<skip_holds_queue>: used when the holds queue update will be handled by the caller

=item B<skip_record_index>: used when the indexing schedulling will be handled by the caller

=back
=cut

sub DelBiblio {
    my ($biblionumber, $params) = @_;

    my $biblio = Koha::Biblios->find( $biblionumber );
    return unless $biblio; # Should we throw an exception instead?

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

    # We delete any existing holds
    my $holds = $biblio->holds;
    while ( my $hold = $holds->next ) {
        # no need to update the holds queue on each step, we'll do it at the end
        $hold->cancel({ skip_holds_queue => 1 });
    }

    # We update any existing orders
    my $orders = $biblio->orders;
    $orders->update({ deleted_biblionumber => $biblionumber}, { no_triggers => 1 });
    # Update related ILL requests
    $biblio->ill_requests->update({ deleted_biblio_id => $biblio->id, biblio_id => undef });

    unless ( $params->{skip_record_index} ){
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        $indexer->index_records( $biblionumber, "recordDelete", "biblioserver" );
    }

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

    _after_biblio_action_hooks({ action => 'delete', biblio_id => $biblionumber });

    logaction( "CATALOGUING", "DELETE", $biblionumber, "biblio" ) if C4::Context->preference("CataloguingLog");

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
        {
            biblio_ids => [ $biblionumber ]
        }
    ) unless $params->{skip_holds_queue} or !C4::Context->preference('RealTimeHoldsQueue');

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
    my $verbose = shift;
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
    my ( $headings_changed, $results ) =
      LinkBibHeadingsToAuthorities( $linker, $record, $frameworkcode, C4::Context->preference("CatalogModuleRelink") || '', undef, $verbose );
    # By default we probably don't want to relink things when cataloging
    return $headings_changed, $results;
}

=head2 LinkBibHeadingsToAuthorities

  my $num_headings_changed, %results = LinkBibHeadingsToAuthorities($linker, $marc, $frameworkcode, [$allowrelink, $tagtolink,  $verbose]);

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
    my $tagtolink     = shift;
    my $verbose = shift;
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
        if ( defined $tagtolink ) {
          next unless $field->tag() == $tagtolink ;
        }
        my $heading = C4::Heading->new_from_field( $field, $frameworkcode );
        next unless defined $heading;

        # check existing $9
        my $current_link = $field->subfield('9');

        if ( defined $current_link && (!$allowrelink || !C4::Context->preference('LinkerRelink')) )
        {
            $results{'linked'}->{ $heading->display_form() }++;
            push(@{$results{'details'}}, { tag => $field->tag(), authid => $current_link, status => 'UNCHANGED'}) if $verbose;
            next;
        }

        my ( $authid, $fuzzy, $match_count ) = $linker->get_link($heading);
        if ($authid) {
            $results{ $fuzzy ? 'fuzzy' : 'linked' }
              ->{ $heading->display_form() }++;
            if(defined $current_link and $current_link == $authid) {
                push(@{$results{'details'}}, { tag => $field->tag(), authid => $current_link, status => 'UNCHANGED'}) if $verbose;
                next;
            }

            $field->delete_subfield( code => '9' ) if defined $current_link;
            $field->add_subfields( '9', $authid );
            $num_headings_changed++;
            push(@{$results{'details'}}, { tag => $field->tag(), authid => $authid, status => 'LOCAL_FOUND'}) if $verbose;
        }
        else {
            my $authority_type = Koha::Authority::Types->find( $heading->auth_type() );
            if ( defined $current_link
                && (!$allowrelink || C4::Context->preference('LinkerKeepStale')) )
            {
                $results{'fuzzy'}->{ $heading->display_form() }++;
                push(@{$results{'details'}}, { tag => $field->tag(), authid => $current_link, status => 'UNCHANGED'}) if $verbose;
            }
            elsif ( C4::Context->preference('AutoCreateAuthorities') ) {
                if ( _check_valid_auth_link( $current_link, $field ) ) {
                    $results{'linked'}->{ $heading->display_form() }++;
                }
                elsif ( !$match_count ) {
                    my $authority_type = Koha::Authority::Types->find( $heading->auth_type() );
                    my $marcrecordauth = MARC::Record->new();
                    if ( C4::Context->preference('marcflavour') eq 'MARC21' ) {
                        $marcrecordauth->leader('     nz  a22     o  4500');
                        SetMarcUnicodeFlag( $marcrecordauth, 'MARC21' );
                    }
                    $field->delete_subfield( code => '9' )
                      if defined $current_link;
                    my @auth_subfields;
                    foreach my $subfield ( $field->subfields() ){
                        if ( $subfield->[0] =~ /[A-z]/
                            && C4::Heading::valid_heading_subfield(
                                $field->tag, $subfield->[0] )
                           ){
                            push @auth_subfields, $subfield->[0] => $subfield->[1];
                        }
                    }
                    # Bib headings contain some ending punctuation that should NOT
                    # be included in the authority record. Strip those before creation
                    next unless @auth_subfields; # Don't try to create a record if we have no fields;
                    my $last_sub = pop @auth_subfields;
                    $last_sub =~ s/[\s]*[,.:=;!%\/][\s]*$//;
                    push @auth_subfields, $last_sub;
                    my $authfield = MARC::Field->new( $authority_type->auth_tag_to_report, '', '', @auth_subfields );
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
                                'a' => C4::Context->preference('GenerateAuthorityField667')
                            )
                        );
                        my $cite =
                            $bib->author() . ", "
                          . $bib->title_proper() . ", "
                          . $bib->publication_date() . " ";
                        $cite =~ s/^[\s\,]*//;
                        $cite =~ s/[\s\,]*$//;
                        $cite =
                            C4::Context->preference('GenerateAuthorityField670') . ": ("
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
                    push(@{$results{'details'}}, { tag => $field->tag(), authid => $authid, status => 'CREATED'}) if $verbose;
                }
            }
            elsif ( defined $current_link ) {
                if ( _check_valid_auth_link( $current_link, $field ) ) {
                    $results{'linked'}->{ $heading->display_form() }++;
                    push(@{$results{'details'}}, { tag => $field->tag(), authid => $authid, status => 'UNCHANGED'}) if $verbose;
                }
                else {
                    $field->delete_subfield( code => '9' );
                    $num_headings_changed++;
                    $results{'unlinked'}->{ $heading->display_form() }++;
                    push(@{$results{'details'}}, { tag => $field->tag(), authid => undef, status => 'NONE_FOUND', auth_type => $heading->auth_type(), tag_to_report => $authority_type->auth_tag_to_report}) if $verbose;
                }
            }
            else {
                $results{'unlinked'}->{ $heading->display_form() }++;
                push(@{$results{'details'}}, { tag => $field->tag(), authid => undef, status => 'NONE_FOUND', auth_type => $heading->auth_type(), tag_to_report => $authority_type->auth_tag_to_report}) if $verbose;
            }
        }

    }
    push(@{$results{'details'}}, { tag => '', authid => undef, status => 'UNCHANGED'}) unless %results;
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

    return C4::AuthoritiesMarc::CompareFieldWithAuthority( { 'field' => $field, 'authid' => $authid } );
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
    my ( $holdingbrtagf, $holdingbrtagsubf ) = &GetMarcFromKohaField( "items.holdingbranch" );
    my $tagslib = GetMarcStructure( 1, $itemtype, { unsafe => 1 } );

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

GetMarcStructure creates keys (lib, tab, mandatory, repeatable, important) for a display purpose.
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
        "SELECT tagfield,liblibrarian,libopac,mandatory,repeatable,important,ind1_defaultvalue,ind2_defaultvalue
        FROM marc_tag_structure 
        WHERE frameworkcode=? 
        ORDER BY tagfield"
    );
    $sth->execute($frameworkcode);
    my ( $liblibrarian, $libopac, $tag, $res, $mandatory, $repeatable, $important, $ind1_defaultvalue, $ind2_defaultvalue );

    while ( ( $tag, $liblibrarian, $libopac, $mandatory, $repeatable, $important, $ind1_defaultvalue, $ind2_defaultvalue ) = $sth->fetchrow ) {
        $res->{$tag}->{lib}        = ( $forlibrarian or !$libopac ) ? $liblibrarian : $libopac;
        $res->{$tag}->{tab}        = "";
        $res->{$tag}->{mandatory}  = $mandatory;
        $res->{$tag}->{important}  = $important;
        $res->{$tag}->{repeatable} = $repeatable;
    $res->{$tag}->{ind1_defaultvalue} = $ind1_defaultvalue;
    $res->{$tag}->{ind2_defaultvalue} = $ind2_defaultvalue;
    }

    my $mss = Koha::MarcSubfieldStructures->search( { frameworkcode => $frameworkcode } )->unblessed;
    for my $m (@$mss) {
        $res->{ $m->{tagfield} }->{ $m->{tagsubfield} } = {
            lib => ( $forlibrarian or !$m->{libopac} ) ? $m->{liblibrarian} : $m->{libopac},
            subfield => $m->{tagsubfield},
            %$m
        };
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
        ORDER BY tagfield, display_order, tagsubfield
    };
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($frameworkcode);
    return $sth->fetchall_arrayref( {} );
}

=pod

=head2 GetMarcSubfieldStructure

  my $structure = GetMarcSubfieldStructure($frameworkcode, [$params]);

Returns a reference to hash representing MARC subfield structure
for framework with framework code C<$frameworkcode>, C<$params> is
optional and may contain additional options.

=over 4

=item C<$frameworkcode>

The framework code.

=item C<$params>

An optional hash reference with additional options.
The following options are supported:

=over 4

=item unsafe

Pass { unsafe => 1 } do disable cached object cloning,
and instead get a shared reference, resulting in better
performance (but care must be taken so that retured object
is never modified).

Note: If you call GetMarcSubfieldStructure with unsafe => 1, do not modify or
even autovivify its contents. It is a cached/shared data structure. Your
changes would be passed around in subsequent calls.

=back

=back

=cut

sub GetMarcSubfieldStructure {
    my ( $frameworkcode, $params ) = @_;

    $frameworkcode //= '';

    my $cache     = Koha::Caches->get_instance();
    my $cache_key = "MarcSubfieldStructure-$frameworkcode";
    my $cached  = $cache->get_from_cache($cache_key, { unsafe => ($params && $params->{unsafe}) });
    return $cached if $cached;

    my $dbh = C4::Context->dbh;
    # We moved to selectall_arrayref since selectall_hashref does not
    # keep duplicate mappings on kohafield (like place in 260 vs 264)
    my $subfield_aref = $dbh->selectall_arrayref( q|
        SELECT *
        FROM marc_subfield_structure
        WHERE frameworkcode = ?
        AND kohafield > ''
        ORDER BY frameworkcode, tagfield, display_order, tagsubfield
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
    my $mss = GetMarcSubfieldStructure( '', { unsafe => 1 } ); # Do not change framework
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
    my $mss = GetMarcSubfieldStructure( '', { unsafe => 1 } ); # Do not change framework
    return unless $mss->{$kohafield};
    return wantarray ? @{$mss->{$kohafield}} : $mss->{$kohafield}->[0];
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
            AND `schema`=?
    |, undef, $biblionumber, C4::Context->preference('marcflavour')
    );
    return $marcxml;
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
    
    if ( $marcflavour eq "MARC21" ) {
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

    return q{} unless defined($value);

    my $cache     = Koha::Caches->get_instance();
    my $cache_key;
    if ( !$category ) {

        return $value unless defined $tagslib->{$tag}->{$subfield}->{'authorised_value'};

        #---- branch
        if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
            $cache_key = "libraries:name";
            my $libraries = $cache->get_from_cache( $cache_key, { unsafe => 1 } );
            if ( !$libraries ) {
                $libraries = {
                    map { $_->branchcode => $_->branchname }
                      Koha::Libraries->search( {},
                        { columns => [ 'branchcode', 'branchname' ] } )
                      ->as_list
                };
                $cache->set_in_cache($cache_key, $libraries);
            }
            return $libraries->{$value};
        }

        #---- itemtypes
        if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "itemtypes" ) {
            my $lang = C4::Languages::getlanguage;
            $lang //= 'en';
            $cache_key = 'itemtype:description:' . $lang;
            my $itypes = $cache->get_from_cache( $cache_key, { unsafe => 1 } );
            if ( !$itypes ) {
                $itypes =
                  { map { $_->itemtype => $_->translated_description }
                      Koha::ItemTypes->search()->as_list };
                $cache->set_in_cache( $cache_key, $itypes );
            }
            return $itypes->{$value};
        }

        if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "cn_source" ) {
            $cache_key = "cn_sources:description";
            my $cn_sources = $cache->get_from_cache( $cache_key, { unsafe => 1 } );
            if ( !$cn_sources ) {
                $cn_sources = {
                    map { $_->cn_source => $_->description }
                      Koha::ClassSources->search( {},
                        { columns => [ 'cn_source', 'description' ] } )
                      ->as_list
                };
                $cache->set_in_cache($cache_key, $cn_sources);
            }
            return $cn_sources->{$value};
        }

        #---- "true" authorized value
        $category = $tagslib->{$tag}->{$subfield}->{'authorised_value'};
    }

    my $dbh = C4::Context->dbh;
    if ( $category ne "" ) {
        $cache_key = "AV_descriptions:" . $category;
        my $av_descriptions = $cache->get_from_cache( $cache_key, { unsafe => 1 } );
        if ( !$av_descriptions ) {
            $av_descriptions = {
                map {
                    $_->authorised_value =>
                      { lib => $_->lib, lib_opac => $_->lib_opac }
                } Koha::AuthorisedValues->search(
                    { category => $category },
                    {
                        columns => [ 'authorised_value', 'lib_opac', 'lib' ]
                    }
                )->as_list
            };
            $cache->set_in_cache($cache_key, $av_descriptions);
        }
        return ( $opac && $av_descriptions->{$value}->{'lib_opac'} )
          ? $av_descriptions->{$value}->{'lib_opac'}
          : $av_descriptions->{$value}->{'lib'};
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
    # Control number or Record identifier are the same field in MARC21 and UNIMARC
    # Keep $marcflavour for possible later use
    if ($marcflavour eq "MARC21" || $marcflavour eq "UNIMARC" ) {
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
        if ( $isbn && $isbn ne "" ) {
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
    else {    # assume MARC21
        $scope = '022';
    }
    my @marcissns;
    foreach my $field ( $record->field($scope) ) {
        push @marcissns, $field->subfield( 'a' )
            if ( $field->subfield( 'a' ) ne "" );
    }
    return \@marcissns;
}    # end GetMarcISSN

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
    } else { # marc21
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
                    operator => (scalar @link_loop) ? ' AND ' : undef
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
    } else {    # marc21
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
                operator => (scalar @link_loop) ? ' AND ' : undef
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
    my $cache          = Koha::Cache::Memory::Lite->get_instance();
    my $cache_key      = "FrameworkCode-$biblionumber";
    my $frameworkcode  = $cache->get_from_cache($cache_key);
    unless ( defined $frameworkcode ) {
        my $dbh = C4::Context->dbh;
        ($frameworkcode) = $dbh->selectrow_array(
            "SELECT frameworkcode FROM biblio WHERE biblionumber=?",
            undef, $biblionumber );
        $cache->set_in_cache( $cache_key, $frameworkcode );
    }
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
    my $mss = GetMarcSubfieldStructure( '', { unsafe => 1 } ); # do not change framework
    my $tag_hr = {};
    while ( my ($kohafield, $value) = each %$hash ) {
        foreach my $fld ( @{ $mss->{$kohafield} } ) {
            my $tagfield    = $fld->{tagfield};
            my $tagsubfield = $fld->{tagsubfield};
            next if !$tagfield;

            # BZ 21800: split value if field is repeatable.
            my @values = _check_split($params, $fld, $value)
                ? split(/\s?\|\s?/, $value, -1)
                : ( $value );
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

sub _check_split {
# Checks if $value must be split; may consult passed framework
    my ($params, $fld, $value) = @_;
    return if index($value,'|') == -1; # nothing to worry about
    return if $params->{no_split};

    # if we did not get a specific framework, check default in $mss
    return $fld->{repeatable} if !$params->{framework};

    # here we need to check the specific framework
    my $mss = GetMarcSubfieldStructure($params->{framework}, { unsafe => 1 });
    foreach my $fld2 ( @{ $mss->{ $fld->{kohafield} } } ) {
        next if $fld2->{tagfield} ne $fld->{tagfield};
        next if $fld2->{tagsubfield} ne $fld->{tagsubfield};
        return 1 if $fld2->{repeatable};
    }
    return;
}

=head2 PrepHostMarcField

    $hostfield = PrepHostMarcField ( $hostbiblionumber,$hostitemnumber,$marcflavour )

This function returns a host field populated with data from the host record, the field can then be added to an analytical record

=cut

sub PrepHostMarcField {
    my ($hostbiblionumber,$hostitemnumber, $marcflavour) = @_;
    $marcflavour ||="MARC21";

    my $biblio = Koha::Biblios->find($hostbiblionumber);
    my $hostrecord = $biblio->metadata->record;
    my $item = Koha::Items->find($hostitemnumber);

	my $hostmarcfield;
    if ( $marcflavour eq "MARC21" ) {
	
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
        my $barcode = $item->barcode;
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

    my ( $perm_loc_tag, $perm_loc_subfield ) = C4::Biblio::GetMarcFromKohaField( "items.permanent_location" );

    my $xml = MARC::File::XML::header('UTF-8');
    $xml .= "<record>\n";
    $auth_type = C4::Context->preference('marcflavour') unless $auth_type; # FIXME auth_type must be removed
    MARC::File::XML->default_record_format($auth_type);

    # in UNIMARC, field 100 contains the encoding
    # check that there is one, otherwise the
    # MARC::Record->new_from_xml will fail (and Koha will die)
    my $unimarc_and_100_exist = 0;
    $unimarc_and_100_exist = 1 if $auth_type eq 'ITEM';    # if we rebuild an item, no need of a 100 field
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

        my $skip = @$values[$i] eq q{};
        $skip = 0
          if $perm_loc_tag
          && $perm_loc_subfield
          && @$tags[$i] eq $perm_loc_tag
          && @$subfields[$i] eq $perm_loc_subfield;

        if ( ( @$tags[$i] ne $prevtag ) ) {
            $close_last_tag = 0;
            $j++ unless ( @$tags[$i] eq "" );
            my $str = ( $indicator->[$j] // q{} ) . '  '; # extra space prevents substr outside of string warn
            my $ind1 = _default_ind_to_space( substr( $str, 0, 1 ) );
            my $ind2 = _default_ind_to_space( substr( $str, 1, 1 ) );
            if ( !$first ) {
                $xml .= "</datafield>\n";
                if (   ( @$tags[$i] && @$tags[$i] > 10 )
                    && ( !$skip ) ) {
                    $xml .= "<datafield tag=\"@$tags[$i]\" ind1=\"$ind1\" ind2=\"$ind2\">\n";
                    $xml .= "<subfield code=\"@$subfields[$i]\">@$values[$i]</subfield>\n";
                    $first = 0;
                    $close_last_tag = 1;
                } else {
                    $first = 1;
                }
            } else {
                if ( !$skip ) {

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
            if ( !$skip ) {
                if ($first) {
                    my $str = ( $indicator->[$j] // q{} ) . '  '; # extra space prevents substr outside of string warn
                    my $ind1 = _default_ind_to_space( substr( $str, 0, 1 ) );
                    my $ind2 = _default_ind_to_space( substr( $str, 1, 1 ) );
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

    @fields = sort { $a->tag() cmp $b->tag() } @fields;
    $record->append_fields(@fields);
    return $record;
}

=head2 TransformMarcToKoha

    $result = TransformMarcToKoha({ record => $record, limit_table => $limit })

Extract data from a MARC bib record into a hashref representing
Koha biblio, biblioitems, and items fields.

If passed an undefined record will log the error and return an empty
hash_ref.

=cut

sub TransformMarcToKoha {
    my ( $params ) = @_;

    my $record = $params->{record};
    my $limit_table = $params->{limit_table} // q{};
    my $kohafields = $params->{kohafields};

    my $result = {};
    if (!defined $record) {
        carp('TransformMarcToKoha called with undefined record');
        return $result;
    }

    my %tables = ( biblio => 1, biblioitems => 1, items => 1 );
    if( $limit_table eq 'items' ) {
        %tables = ( items => 1 );
    } elsif ( $limit_table eq 'no_items' ){
        %tables = ( biblio => 1, biblioitems => 1 );
    }

    # The next call acknowledges Default as the authoritative framework
    # for Koha to MARC mappings.
    my $mss = GetMarcSubfieldStructure( '', { unsafe => 1 } ); # Do not change framework
    @{$kohafields} = keys %{ $mss } unless $kohafields;
    foreach my $kohafield ( @{$kohafields} ) {
        my ( $table, $column ) = split /[.]/, $kohafield, 2;
        next unless $tables{$table};
        my ( $value, @values );
        foreach my $fldhash ( @{$mss->{$kohafield}} ) {
            my $tag = $fldhash->{tagfield};
            my $sub = $fldhash->{tagsubfield};
            foreach my $fld ( $record->field($tag) ) {
                if( $sub eq '@' || $fld->is_control_field ) {
                    push @values, $fld->data if $fld->data;
                } else {
                    push @values, grep { $_ } $fld->subfield($sub);
                }
            }
        }
        if ( @values ){
            $value = join ' | ', uniq(@values);

            # Additional polishing for individual kohafields
            if( $kohafield =~ /copyrightdate|publicationyear/ ) {
                $value = _adjust_pubyear( $value );
            }
        }

        next if !defined $value;
        my $key = _disambiguate( $table, $column );
        $result->{$key} = $value;
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

=head2 _adjust_pubyear

    Helper routine for TransformMarcToKoha

=cut

sub _adjust_pubyear {
    my $retval = shift;
    # modify return value to keep only the 1st year found
    if( $retval =~ m/c(\d\d\d\d)/ and $1 > 0 ) { # search cYYYY first
        $retval = $1;
    } elsif( $retval =~ m/(\d\d\d\d)/ && $1 > 0 ) {
        $retval = $1;
    } elsif( $retval =~ m/(?<year>\d{1,3})[.Xx?-]/ ) {
        # See also bug 24674: enough to look at one unknown year char like .Xx-?
        # At this point in code 1234? or 1234- already passed the earlier regex
        # Things like 2-, 1xx, 1??? are now converted to a four positions-year.
        $retval = $+{year} * ( 10 ** (4-length($+{year})) );
    } else {
        $retval = undef;
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

    ModZebra( $record_number, $op, $server );

$record_number is the authid or biblionumber we want to index

$op is the operation: specialUpdate or recordDelete

$server is authorityserver or biblioserver

=cut

sub ModZebra {
    my ( $record_number, $op, $server ) = @_;
    Koha::Logger->get->debug("ModZebra: updates requested for: $record_number $op $server");
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
    $check_sth->execute( $server, $record_number, $op );
    my ($count) = $check_sth->fetchrow_array;
    $check_sth->finish();
    if ( $count == 0 ) {
        my $sth = $dbh->prepare("INSERT INTO zebraqueue  (biblio_auth_number,server,operation) VALUES(?,?,?)");
        $sth->execute( $record_number, $server, $op );
        $sth->finish;
    }
}

=head1 INTERNAL FUNCTIONS

=head2 _koha_marc_update_bib_ids


  _koha_marc_update_bib_ids($record, $frameworkcode, $biblionumber, $biblioitemnumber);

Internal function to add or update biblionumber and biblioitemnumber to
the MARC XML.

=cut

sub _koha_marc_update_bib_ids {
    my ( $record, $frameworkcode, $biblionumber, $biblioitemnumber ) = @_;

    my ( $biblio_tag,     $biblio_subfield )     = GetMarcFromKohaField( "biblio.biblionumber" );
    die qq{No biblionumber tag for framework "$frameworkcode"} unless $biblio_tag;
    my ( $biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField( "biblioitems.biblioitemnumber" );
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

    # update the control number (001) in MARC
    if(C4::Context->preference('autoControlNumber') eq 'biblionumber'){
        unless($record->field('001')){
            $record->insert_fields_ordered(MARC::Field->new('001', $biblionumber));
        }
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

    my ( $biblioitem_tag, $biblioitem_subfield ) = GetMarcFromKohaField( "biblioitems.cn_sort" );
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
               subtitle = ?,
               medium = ?,
               part_number = ?,
               part_name = ?,
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
        $frameworkcode,        $biblio->{'author'},      $biblio->{'title'},       $biblio->{'subtitle'},
        $biblio->{'medium'},   $biblio->{'part_number'}, $biblio->{'part_name'},   $biblio->{'unititle'},
        $biblio->{'notes'},    $biblio->{'serial'},      $biblio->{'seriestitle'}, $biblio->{'copyrightdate'} ? int($biblio->{'copyrightdate'}) : undef,
        $biblio->{'abstract'}, $biblio->{'biblionumber'}
    ) if $biblio->{'biblionumber'};

    my $cache = Koha::Cache::Memory::Lite->get_instance();
    $cache->clear_from_cache("FrameworkCode-" . $biblio->{biblionumber});

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
                INSERT INTO deletedbiblio_metadata (biblionumber, format, `schema`, metadata)
                SELECT biblionumber, format, `schema`, metadata FROM biblio_metadata WHERE biblionumber=?
            |,  undef, $biblionumber );
            $dbh->do( q|DELETE FROM biblio_metadata WHERE biblionumber=?|,
                undef, $biblionumber );
        }
    );
}

=head1 UNEXPORTED FUNCTIONS

=head2 ModBiblioMarc

  ModBiblioMarc($newrec,$biblionumber);

Add MARC XML data for a biblio to koha

Function exported, but should NOT be used, unless you really know what you're doing

=cut

sub ModBiblioMarc {
    # pass the MARC::Record to this function, and it will create the records in
    # the marcxml field
    my ( $record, $biblionumber, $params ) = @_;
    if ( !$record ) {
        carp 'ModBiblioMarc passed an undefined record';
        return;
    }

    my $skip_record_index = $params->{skip_record_index} || 0;

    # Clone record as it gets modified
    $record = $record->clone();
    my $dbh    = C4::Context->dbh;
    my @fields = $record->fields();
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
        schema       => C4::Context->preference('marcflavour'),
    };
    $record->as_usmarc; # Bug 20126/10455 This triggers field length calculation

    my $m_rs = Koha::Biblio::Metadatas->find($metadata) //
        Koha::Biblio::Metadata->new($metadata);

    my $userenv = C4::Context->userenv;
    if ($userenv) {
        my $borrowernumber = $userenv->{number};
        my $borrowername = join ' ', map { $_ // q{} } @$userenv{qw(firstname surname)};
        unless ($m_rs->in_storage) {
            Koha::Util::MARC::set_marc_field($record, C4::Context->preference('MarcFieldForCreatorId'), $borrowernumber);
            Koha::Util::MARC::set_marc_field($record, C4::Context->preference('MarcFieldForCreatorName'), $borrowername);
        }
        Koha::Util::MARC::set_marc_field($record, C4::Context->preference('MarcFieldForModifierId'), $borrowernumber);
        Koha::Util::MARC::set_marc_field($record, C4::Context->preference('MarcFieldForModifierName'), $borrowername);
    }

    $m_rs->metadata( $record->as_xml_record($encoding) );
    $m_rs->store;

    unless ( $skip_record_index ) {
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        $indexer->index_records( $biblionumber, "specialUpdate", "biblioserver" );
    }

    return $biblionumber;
}

=head2 prepare_host_field

$marcfield = prepare_host_field( $hostbiblioitem, $marcflavour );
Generate the host item entry for an analytic child entry

=cut

sub prepare_host_field {
    my ( $hostbiblio, $marcflavour ) = @_;
    $marcflavour ||= C4::Context->preference('marcflavour');

    my $biblio = Koha::Biblios->find($hostbiblio);
    my $host = $biblio->metadata->record;
    # unfortunately as_string does not 'do the right thing'
    # if field returns undef
    my %sfd;
    my $field;
    my $host_field;
    if ( $marcflavour eq 'MARC21' ) {
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
    my ($biblionumber, $increase, $value, $skip_holds_queue) = @_;
    my $totalissues;

    my $biblio = Koha::Biblios->find($biblionumber);
    unless ($biblio) {
        carp "UpdateTotalIssues could not get biblio";
        return;
    }

    my $record = $biblio->metadata->record;
    unless ($record) {
        carp "UpdateTotalIssues could not get biblio record";
        return;
    }
    my $biblioitem = $biblio->biblioitem;
    my ($totalissuestag, $totalissuessubfield) = GetMarcFromKohaField( 'biblioitems.totalissues' );
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

     return ModBiblio($record, $biblionumber, $biblio->frameworkcode, { skip_holds_queue => $skip_holds_queue });
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

=head2 ApplyMarcOverlayRules

    my $record = ApplyMarcOverlayRules($params)

Applies marc merge rules to a record.

C<$params> is expected to be a hashref with below keys defined.

=over 4

=item C<biblionumber>
biblionumber of old record

=item C<record>
Incoming record that will be merged with old record

=item C<overlay_context>
hashref containing at least one context module and filter value on
the form {module => filter, ...}.

=back

Returns:

=over 4

=item C<$record>

Merged MARC record based with merge rules for C<context> applied. If no old
record for C<biblionumber> can be found, C<record> is returned unchanged.
Default action when no matching context is found to return C<record> unchanged.
If no rules are found for a certain field tag the default is to overwrite with
fields with this field tag from C<record>.

=back

=cut

sub ApplyMarcOverlayRules {
    my ($params) = @_;
    my $biblionumber = $params->{biblionumber};
    my $incoming_record = $params->{record};

    if (!$biblionumber) {
        carp 'ApplyMarcOverlayRules called on undefined biblionumber';
        return;
    }
    if (!$incoming_record) {
        carp 'ApplyMarcOverlayRules called on undefined record';
        return;
    }
    my $biblio = Koha::Biblios->find($biblionumber);
    my $old_record = $biblio->metadata->record;

    # Skip overlay rules if called with no context
    if ($old_record && defined $params->{overlay_context}) {
        return Koha::MarcOverlayRules->merge_records($old_record, $incoming_record, $params->{overlay_context});
    }
    return $incoming_record;
}

=head2 _after_biblio_action_hooks

Helper method that takes care of calling all plugin hooks

=cut

sub _after_biblio_action_hooks {
    my ( $args ) = @_;

    my $biblio_id = $args->{biblio_id};
    my $action    = $args->{action};

    my $biblio = Koha::Biblios->find( $biblio_id );
    Koha::Plugins->call(
        'after_biblio_action',
        {
            action    => $action,
            biblio    => $biblio,
            biblio_id => $biblio_id,
        }
    );
}

1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Paul POULAIN paul.poulain@free.fr

Joshua Ferraro jmf@liblime.com

=cut
