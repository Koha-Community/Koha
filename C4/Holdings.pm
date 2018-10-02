package C4::Holdings;

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
# Copyright 2011 Equinox Software, Inc.
# Copyright 2017-2018 University of Helsinki (The National Library Of Finland)
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

# TODO check which use's are really necessary

use Encode qw( decode is_utf8 );
use List::MoreUtils qw( uniq );
use MARC::Record;
use MARC::File::USMARC;
use MARC::File::XML;
use POSIX qw(strftime);

use C4::Koha;
use C4::Log;    # logaction
use C4::ClassSource;
use C4::Charset;
use C4::Debug;

use Koha::Caches;
use Koha::Holdings::Metadata;
use Koha::Holdings::Metadatas;
use Koha::Libraries;

use vars qw(@ISA @EXPORT);
use vars qw($debug $cgi_debug);

BEGIN {

    require Exporter;
    @ISA = qw( Exporter );

    # to add holdings
    # EXPORTED FUNCTIONS.
    push @EXPORT, qw(
      &AddHolding
    );

    # to get something
    push @EXPORT, qw(
      GetHolding
    );

    # To modify something
    push @EXPORT, qw(
      &ModHolding
    );

    # To delete something
    push @EXPORT, qw(
      &DelHolding
    );
}

=head1 NAME

C4::Holding - cataloging management functions

=head1 DESCRIPTION

Holding.pm contains functions for managing storage and editing of holdings data within Koha. Most of the functions in this module are used for cataloging holdings records: adding, editing, or removing holdings. Koha stores holdings information in two places:

=over 4

=item 1. in the holdings table which is limited to a one-to-one mapping to underlying MARC data

=item 2. as MARC XML in holdings_metadata.metadata

=back

In the 3.0 version of Koha, the authoritative record-level information is in holdings_metadata.metadata

Because the data isn't completely normalized there's a chance for information to get out of sync. The design choice to go with a un-normalized schema was driven by performance and stability concerns. However, if this occur, it can be considered as a bug : The API is (or should be) complete & the only entry point for all holdings management.

=over 4

=item 1. Add*/Mod*/Del*/ - high-level external functions suitable for being called from external scripts to manage the collection

=back

The MARC record (in holdings_metadata.metadata) contains the MARC holdings record. It also contains the holding_id. That is the reason why it is not stored directly by AddHolding, with all other fields. To save a holding, we need to:

=over 4

=item 1. save data in holdings table, that gives us a holding_id

=item 2. add the holding_id into the MARC record

=item 3. save the marc record

=back

=head1 EXPORTED FUNCTIONS

=head2 AddHolding

  $holding_id = AddHolding($record, $frameworkcode, $biblionumber);

Exported function (core API) for adding a new holding to koha.

The first argument is a C<MARC::Record> object containing the
holding to add, while the second argument is the desired MARC
framework code and third the biblionumber to link to.

=cut

sub AddHolding {
    my $record          = shift;
    my $frameworkcode   = shift;
    my $biblionumber    = shift;
    if (!$record) {
        carp('AddHolding called with undefined record');
        return;
    }

    my $dbh = C4::Context->dbh;

    my $biblio = Koha::Biblios->find( $biblionumber );
    my $biblioitemnumber = $biblio->biblioitem->biblioitemnumber;

    # transform the data into koha-table style data
    SetUTF8Flag($record);
    my $rowData = TransformMarcHoldingToKoha( $record );
    my ($holding_id) = _koha_add_holding( $dbh, $rowData, $frameworkcode, $biblionumber, $biblioitemnumber );

    _koha_marc_update_ids( $record, $frameworkcode, $holding_id, $biblionumber, $biblioitemnumber );

    # now add the record
    ModHoldingMarc( $record, $holding_id, $frameworkcode );

    logaction( "CATALOGUING", "ADD", $holding_id, "holding" ) if C4::Context->preference("CataloguingLog");
    return $holding_id;
}

=head2 ModHolding

  ModHolding($record, $holding_id, $frameworkcode);

Replace an existing holding record identified by C<$holding_id>
with one supplied by the MARC::Record object C<$record>.

C<$frameworkcode> specifies the MARC framework to use
when storing the modified holdings record.

Returns 1 on success 0 on failure

=cut

sub ModHolding {
    my ( $record, $holding_id, $frameworkcode ) = @_;
    if (!$record) {
        carp 'No record passed to ModHolding';
        return 0;
    }

    if ( C4::Context->preference("CataloguingLog") ) {
        my $newrecord = GetMarcHolding($holding_id);
        logaction( "CATALOGUING", "MODIFY", $holding_id, "holding BEFORE=>" . $newrecord->as_formatted );
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

    $frameworkcode = 'HLD' if !$frameworkcode || $frameworkcode eq 'Default';

    # update holding_id in MARC
    _koha_marc_update_ids( $record, $frameworkcode, $holding_id );

    # load the koha-table data object
    my $rowData = TransformMarcHoldingToKoha( $record );
    # update the MARC record (that now contains biblio and items) with the new record data
    &ModHoldingMarc( $record, $holding_id, $frameworkcode );

    # modify the other koha tables
    _koha_modify_holding( $dbh, $holding_id, $rowData, $frameworkcode );

    return 1;
}

=head2 DelHolding

  my $error = &DelHolding($holding_id);

Exported function (core API) for deleting a holding in koha.
Deletes holding record from Koha tables (holdings, holdings_metadata)
Also backs it up to deleted* tables.
Checks to make sure that the holding has no items attached.
return:
C<$error> : undef unless an error occurs

=cut

sub DelHolding {
    my ($holding_id) = @_;
    my $dbh = C4::Context->dbh;
    my $error;    # for error handling

    # First make sure this holding has no items attached
    my $sth = $dbh->prepare("SELECT itemnumber FROM items WHERE holding_id=?");
    $sth->execute($holding_id);
    if ( my $itemnumber = $sth->fetchrow ) {

        # Fix this to use a status the template can understand
        $error .= "This holding record has items attached, please delete them first before deleting this holding record ";
    }

    return $error if $error;

    # delete holding
    _koha_delete_holding( $dbh, $holding_id );

    logaction( "CATALOGUING", "DELETE", $holding_id, "holding" ) if C4::Context->preference("CataloguingLog");

    return;
}

=head2 GetHolding

  my $holding = &GetHolding($holding_id);

=cut

sub GetHolding {
    my ($holding_id) = @_;
    my $dbh             = C4::Context->dbh;
    my $sth             = $dbh->prepare("SELECT * FROM holding WHERE holding_id = ? AND deleted_on IS NULL");
    my $count           = 0;
    my @results;
    $sth->execute($holding_id);
    if ( my $data = $sth->fetchrow_hashref ) {
        return $data;
    }
    return;
}

=head2 GetHoldingsByBiblionumber

  GetHoldingsByBiblionumber($biblionumber);

Returns an arrayref of hashrefs suitable for use in a TMPL_LOOP
Called by C<C4::XISBN>

=cut

sub GetHoldingsByBiblionumber {
    my ( $bib ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM holdings WHERE holdings.biblionumber = ? AND deleted_on IS NULL") || die $dbh->errstr;
    # Get all holdings attached to a biblioitem
    my $i = 0;
    my @results;
    $sth->execute($bib) || die $sth->errstr;
    while ( my $data = $sth->fetchrow_hashref ) {
        push(@results, $data);
    }
    return (\@results);
}

=head2 GetMarcHolding

  my $record = GetMarcHolding(holding_id, [$opac]);

Returns MARC::Record representing a holding record, or C<undef> if the
record doesn't exist.

=over 4

=item C<$holding_id>

the holding_id

=item C<$opac>

set to true to make the result suited for OPAC view. This causes things like
OpacHiddenItems to be applied.

=back

=cut

sub GetMarcHolding {
    my $holding_id = shift;
    my $opac         = shift || 0;

    if (not defined $holding_id) {
        carp 'GetMarcHolding called with undefined holding_id';
        return;
    }

    my $marcflavour = C4::Context->preference('marcflavour');

    my $marcxml = GetXmlHolding( $holding_id );
    $marcxml = StripNonXmlChars( $marcxml );
    my $frameworkcode = GetHoldingFrameworkCode( $holding_id );
    MARC::File::XML->default_record_format( $marcflavour );

    if ($marcxml) {
        my $record = eval {
            MARC::Record::new_from_xml( $marcxml, "utf8", $marcflavour );
        };
        if ($@) { warn " problem with holding $holding_id : $@ \n$marcxml"; }
        return unless $record;

        _koha_marc_update_ids( $record, $frameworkcode, $holding_id );

        return $record;
    }
    return;
}

=head2 GetXmlHolding

  my $marcxml = GetXmlHolding($holding_id);

Returns holdings_metadata.metadata/marcxml of the holding_id passed in parameter.

=cut

sub GetXmlHolding {
    my ($holding_id) = @_;
    return unless $holding_id;

    my $marcflavour = C4::Context->preference('marcflavour');
    my $sth = C4::Context->dbh->prepare(
        q|
        SELECT metadata
        FROM holdings_metadata
        WHERE holding_id=?
            AND format='marcxml'
            AND marcflavour=?
        |
    );

    $sth->execute( $holding_id, $marcflavour );
    my ($marcxml) = $sth->fetchrow();
    $sth->finish();
    return $marcxml;
}

=head2 GetMarcHoldingsByBiblionumber

  my $records = GetMarcHoldingsByBiblionumber(biblionumber);

Returns MARC::Record array representing holding records

=over 4

=item C<$biblionumber>

biblionumber

=back

=cut

sub GetMarcHoldingsByBiblionumber {
    my $biblionumber = shift;

    my $marcflavour = C4::Context->preference('marcflavour');
    my $sth = C4::Context->dbh->prepare(
        q|
        SELECT metadata
        FROM holdings_metadata
        WHERE holding_id IN (SELECT holding_id FROM holdings WHERE biblionumber=?)
            AND format='marcxml'
            AND marcflavour=?
        |
    );

    $sth->execute( $biblionumber, $marcflavour );

    my @records;
    while (my ($marcxml) = $sth->fetchrow()) {
        $marcxml = StripNonXmlChars( $marcxml );
        my $record = eval {
            MARC::Record::new_from_xml( $marcxml, "utf8", $marcflavour );
        };
        if ($@) {
            warn " problem with holding for biblio $biblionumber : $@ \n$marcxml";
        }
        push @records, $record if $record;
    }
    $sth->finish();
    return \@records;
}

=head2 GetMarcHoldingsFields

  my @marc_fields = GetMarcHoldingsFields($biblionumber);

Returns an array of MARC::Record objects of the holdings for the biblio.

=cut

sub GetMarcHoldingsFields {
	my ( $biblionumber ) = @_;

    # This is so much faster than using Koha::Holdings->search that it makes sense even if it's ugly.
    my $sth = C4::Context->dbh->prepare( 'SELECT * FROM holdings WHERE biblionumber = ?' );
    $sth->execute( $biblionumber );
    my $holdings = $sth->fetchall_arrayref({});
    $sth->finish();
    my @holdings_fields;
    my ( $holdingstag, $holdingssubfield ) = GetMarcHoldingFromKohaField( 'holdings.holdingbranch' );

    ITEMLOOP: foreach my $holding (@$holdings) {

        my $mungedholding = {
            map {
                defined($holding->{$_}) && $holding->{$_} ne '' ? ("holdings.$_" => $holding->{$_}) : ()
            } keys %{ $holding }
        };
        my $marc = TransformKohaHoldingToMarc($mungedholding);

        push @holdings_fields, $marc->field( $holdingstag );
    }

    return \@holdings_fields;
}

=head2 GetHoldingFrameworkCode

  $frameworkcode = GetFrameworkCode( $holding_id )

=cut

sub GetHoldingFrameworkCode {
    my ($holding_id) = @_;
    my $sth = C4::Context->dbh->prepare("SELECT frameworkcode FROM holdings WHERE holding_id=?");
    $sth->execute($holding_id);
    my ($frameworkcode) = $sth->fetchrow;
    $sth->finish();
    return $frameworkcode;
}

=head1 INTERNAL FUNCTIONS

=head2 _koha_add_holding

  my ($holding_id,$error) = _koha_add_hodings($dbh, $holding, $frameworkcode, $biblionumber, $biblioitemnumber);

Internal function to add a holding ($holding is a hash with the values)

=cut

sub _koha_add_holding {
    my ( $dbh, $holding, $frameworkcode, $biblionumber, $biblioitemnumber ) = @_;

    my $error;

    my $query = "INSERT INTO holdings
        SET biblionumber = ?,
            biblioitemnumber = ?,
            frameworkcode = ?,
            holdingbranch = ?,
            location = ?,
            callnumber = ?,
            suppress = ?,
            datecreated = NOW()
        ";

    my $sth = $dbh->prepare($query);
    $sth->execute(
        $biblionumber, $biblioitemnumber, $frameworkcode,
        $holding->{holdingbranch}, $holding->{location}, $holding->{callnumber}, $holding->{suppress} ? 1 : 0
    );

    my $holding_id = $dbh->{'mysql_insertid'};
    if ( $dbh->errstr ) {
        $error .= "ERROR in _koha_add_holding $query" . $dbh->errstr;
        warn $error;
    }

    $sth->finish();

    return ( $holding_id, $error );
}

=head2 _koha_modify_holding

  my ($biblionumber,$error) == _koha_modify_holding($dbh, $holding, $frameworkcode);

Internal function for updating the holdings table

=cut

sub _koha_modify_holding {
    my ( $dbh, $holding_id, $holding, $frameworkcode ) = @_;
    my $error;

    my $query = "
        UPDATE holdings
        SET    frameworkcode = ?,
               holdingbranch = ?,
               location = ?,
               callnumber = ?,
               suppress = ?
        WHERE  holding_id = ?
        "
      ;
    my $sth = $dbh->prepare($query);

    $sth->execute(
        $frameworkcode, $holding->{holdingbranch}, $holding->{location}, $holding->{callnumber}, $holding->{suppress} ? 1 : 0, $holding_id
    ) if $holding_id;

    if ( $dbh->errstr || !$holding_id ) {
        die "ERROR in _koha_modify_holding for holding $holding_id: " . $dbh->errstr;
    }
    return ( $holding_id, $error );
}

=head2 _koha_delete_holding

  $error = _koha_delete_holding($dbh, $holding_id);

Internal sub for deleting from holdings table

C<$dbh> - the database handle

C<$holding_id> - the holding_id of the holding to be deleted

=cut

sub _koha_delete_holding {
    my ( $dbh, $holding_id ) = @_;

    my $schema = Koha::Database->new->schema;
    $schema->txn_do(
        sub {
            $dbh->do('UPDATE holdings_metadata SET deleted_on = NOW() WHERE holding_id=?', undef, $holding_id);
            $dbh->do('UPDATE holdings SET deleted_on = NOW() WHERE holding_id=?', undef, $holding_id);
        }
    );
    return;
}

=head1 INTERNAL FUNCTIONS

=head2 _koha_marc_update_ids


  _koha_marc_update_ids($record, $frameworkcode, $holding_id[, $biblionumber, $biblioitemnumber]);

Internal function to add or update holding_id, biblionumber and biblioitemnumber to
the MARC XML.

=cut

sub _koha_marc_update_ids {
    my ( $record, $frameworkcode, $holding_id, $biblionumber, $biblioitemnumber ) = @_;

    my ( $holding_tag, $holding_subfield ) = GetMarcHoldingFromKohaField( "holdings.holding_id" );
    die qq{No holding_id tag for framework "$frameworkcode"} unless $holding_tag;

    if ( $holding_tag < 10 ) {
        C4::Biblio::UpsertMarcControlField( $record, $holding_tag, $holding_id );
    } else {
        C4::Biblio::UpsertMarcSubfield($record, $holding_tag, $holding_subfield, $holding_id);
    }

    if ( defined $biblionumber ) {
        my ( $biblio_tag, $biblio_subfield ) = GetMarcHoldingFromKohaField( "biblio.biblionumber" );
        die qq{No biblionumber tag for framework "$frameworkcode"} unless $biblio_tag;
        if ( $biblio_tag < 10 ) {
            C4::Biblio::UpsertMarcControlField( $record, $biblio_tag, $biblionumber );
        } else {
            C4::Biblio::UpsertMarcSubfield($record, $biblio_tag, $biblio_subfield, $biblionumber);
        }
    }
    if ( defined $biblioitemnumber ) {
        my ( $biblioitem_tag, $biblioitem_subfield ) = GetMarcHoldingFromKohaField( "biblioitems.biblioitemnumber" );
        die qq{No biblioitemnumber tag for framework "$frameworkcode"} unless $biblioitem_tag;
        if ( $biblioitem_tag < 10 ) {
            C4::Biblio::UpsertMarcControlField( $record, $biblioitem_tag, $biblioitemnumber );
        } else {
            C4::Biblio::UpsertMarcSubfield($record, $biblioitem_tag, $biblioitem_subfield, $biblioitemnumber);
        }
    }
}

=head1 UNEXPORTED FUNCTIONS

=head2 ModHoldingMarc

  &ModHoldingMarc($newrec,$holding_id,$frameworkcode);

Add MARC XML data for a holding to koha

Function exported, but should NOT be used, unless you really know what you're doing

=cut

sub ModHoldingMarc {
    # pass the MARC::Record to this function, and it will create the records in
    # the marcxml field
    my ( $record, $holding_id, $frameworkcode ) = @_;
    if ( !$record ) {
        carp 'ModHoldingMarc passed an undefined record';
        return;
    }

    # Clone record as it gets modified
    $record = $record->clone();
    my $dbh    = C4::Context->dbh;
    my @fields = $record->fields();
    if ( !$frameworkcode ) {
        $frameworkcode = "";
    }
    my $sth = $dbh->prepare("UPDATE holdings SET frameworkcode=? WHERE holding_id=?");
    $sth->execute( $frameworkcode, $holding_id );
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
        holding_id => $holding_id,
        format        => 'marcxml',
        marcflavour   => C4::Context->preference('marcflavour'),
    };
    # FIXME To replace with ->find_or_create?
    if ( my $m_rs = Koha::Holdings::Metadatas->find($metadata) ) {
        $m_rs->metadata( $record->as_xml_record($encoding) );
        $m_rs->store;
    } else {
        my $m_rs = Koha::Holdings::Metadata->new($metadata);
        $m_rs->metadata( $record->as_xml_record($encoding) );
        $m_rs->store;
    }
    return $holding_id;
}

=head2 GetMarcHoldingFromKohaField

    ( $field,$subfield ) = GetMarcHoldingFromKohaField( $kohafield );
    @fields = GetMarcHoldingFromKohaField( $kohafield );
    $field = GetMarcHoldingFromKohaField( $kohafield );

    Returns the MARC fields & subfields mapped to $kohafield.
    Uses the HLD framework that is considered as authoritative.

    In list context all mappings are returned; there can be multiple
    mappings. Note that in the above example you could miss a second
    mappings in the first call.
    In scalar context only the field tag of the first mapping is returned.

=cut

sub GetMarcHoldingFromKohaField {
    my ( $kohafield ) = @_;
    return unless $kohafield;
    # The next call uses the Default framework since it is AUTHORITATIVE
    # for all Koha to MARC mappings.
    my $mss = C4::Biblio::GetMarcSubfieldStructure( 'HLD' );
    my @retval = ( $mss->{$kohafield}{tagfield}, $mss->{$kohafield}{tagsubfield} );
    return wantarray ? @retval : ( @retval ? $retval[0] : undef );
}

=head2 GetMarcHoldingSubfieldStructureFromKohaField

    my $str = GetMarcHoldingSubfieldStructureFromKohaField( $kohafield );

    Returns marc subfield structure information for $kohafield.
    Uses the HLD framework that is considered as authoritative.

    In list context returns a list of all hashrefs, since there may be
    multiple mappings. In scalar context the first hashref is returned.

=cut

sub GetMarcHoldingSubfieldStructureFromKohaField {
    my ( $kohafield ) = @_;

    return unless $kohafield;

    # The next call uses the Default framework since it is AUTHORITATIVE
    # for all Koha to MARC mappings.
    my $mss = C4::Biblio::GetMarcSubfieldStructure( 'HLD' ); # Do not change framework
    return exists $mss->{$kohafield}
        ? $mss->{$kohafield}
        : undef;
}

=head2 TransformMarcHoldingToKoha

    $result = TransformMarcHoldingToKoha( $record, undef )

Extract data from a MARC holdings record into a hashref representing
Koha holdings fields.

If passed an undefined record will log the error and return an empty
hash_ref.

=cut

sub TransformMarcHoldingToKoha {
    my ( $record ) = @_;

    my $result = {};
    if (!defined $record) {
        carp('TransformMarcToKoha called with undefined record');
        return $result;
    }

    my %tables = ( holdings => 1 );

    # The next call acknowledges HLD as the authoritative framework
    # for holdings to MARC mappings.
    my $mss = C4::Biblio::GetMarcSubfieldStructure( 'HLD' ); # Do not change framework
    foreach my $kohafield ( keys %{ $mss } ) {
        my ( $table, $column ) = split /[.]/, $kohafield, 2;
        next unless $tables{$table};
        my $val = TransformMarcHoldingToKohaOneField( $kohafield, $record );
        next if !defined $val;
        $result->{$column} = $val;
    }
    return $result;
}

=head2 TransformMarcHoldingToKohaOneField

    $val = TransformMarcHoldingToKohaOneField( 'biblio.title', $marc );

    Note: The authoritative Default framework is used implicitly.

=cut

sub TransformMarcHoldingToKohaOneField {
    my ( $kohafield, $marc ) = @_;

    my ( @rv, $retval );
    my @mss = GetMarcHoldingSubfieldStructureFromKohaField($kohafield);
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

    return $retval;
}

=head2 TransformKohaToMarc

    $record = TransformKohaToMarc( $hash )

This function builds partial MARC::Record from a hash
Hash entries can be from biblio or biblioitems.

This function is called in acquisition module, to create a basic catalogue
entry from user entry

=cut


sub TransformKohaHoldingToMarc {
    my $hash = shift;
    my $record = MARC::Record->new();
    SetMarcUnicodeFlag( $record, C4::Context->preference("marcflavour") );
    my $mss = C4::Biblio::GetMarcSubfieldStructure( 'HLD' );
    my $tag_hr = {};
    while ( my ($kohafield, $value) = each %$hash ) {
        next unless exists $mss->{$kohafield};
        next unless $mss->{$kohafield};
        my $tagfield    = $mss->{$kohafield}{tagfield} . '';
        my $tagsubfield = $mss->{$kohafield}{tagsubfield};
        foreach my $value ( split(/\s?\|\s?/, $value, -1) ) {
            next if $value eq '';
            $tag_hr->{$tagfield} //= [];
            push @{$tag_hr->{$tagfield}}, [($tagsubfield, $value)];
        }
    }
    foreach my $tag (sort keys %$tag_hr) {
        my @sfl = @{$tag_hr->{$tag}};
        @sfl = sort { $a->[0] cmp $b->[0]; } @sfl;
        @sfl = map { @{$_}; } @sfl;
        $record->insert_fields_ordered(
            MARC::Field->new($tag, " ", " ", @sfl)
        );
    }
    return $record;
}

1;


__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Paul POULAIN paul.poulain@free.fr

Joshua Ferraro jmf@liblime.com

Ere Maijala ere.maijala@helsinki.fi

=cut
