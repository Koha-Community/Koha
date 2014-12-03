package C4::BatchOverlay;

# Copyright (C) 2014 The Anonymous
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use MARC::Field;

use C4::Context;
use C4::BatchOverlay::BatchOverlayRule;
use C4::BatchOverlay::BatchOverlayErrors;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
        batchOverlayBiblios
        overlayBiblio
        generateReport
    );
}
use Text::Diff;

use C4::Biblio;
use C4::Context;
use C4::Breeding;
use C4::ImportBatch;
use C4::Matcher;

my $batchOverlayrulesCache = {};

sub batchOverlayBiblios {
    my ($biblionumbers, $mergeMatcher, $componentMatcher) = @_;

    my $reports = [];
    my $errorsBuilder = C4::BatchOverlay::BatchOverlayErrors->new();
    foreach my $biblionumber (@$biblionumbers) {
        my ($report, $errorsBuilder) = overlayBiblio( undef, $biblionumber, $mergeMatcher, $componentMatcher, $reports, $errorsBuilder );
    }

    return ($reports, $errorsBuilder);
}
sub batchImportBiblios {
    my ($searchTermsBatch, $mergeMatcher, $componentMatcher) = @_;

    my $reports = [];
    my $errorsBuilder = C4::BatchOverlay::BatchOverlayErrors->new();
    foreach my $searchTerm (@$searchTermsBatch) {
        my ($report, $errorsBuilder) = overlayBiblio( $searchTerm, undef, $mergeMatcher, $componentMatcher, $reports, $errorsBuilder );
    }

    return ($reports, $errorsBuilder);
}

#Returns $report-hash that is printable using C4::BatchOverlay::generateReport(); and a $error-string.
sub overlayBiblio {
    my ($searchTerm, $oldBiblionumber, $mergeMatcher, $componentMatcher, $reports, $errorsBuilder) = @_;

    my $commit = 1; #Should we write the modifications to DB?
    my $ok = 0; #a temporary boolean for sharing
    $errorsBuilder = C4::BatchOverlay::BatchOverlayErrors->new() unless $errorsBuilder;
    my @z3950targets;

    my $marcflavour = C4::Context->preference('marcflavour');
    $reports = [] unless $reports; #Collect merging, importing, etc reports here HASHes. keys( oldRecordXML, newRecordXML, mergedRecordXML, operation )

    # 1 # Firstly, get Biblio to be merged. # 1 #
    my $oldBiblio = C4::Biblio::GetBiblio( $oldBiblionumber ) if $oldBiblionumber;
    my $oldRecord = C4::Biblio::GetMarcBiblio( $oldBiblionumber ) if $oldBiblionumber;
    $errorsBuilder->setActiveBiblio($oldBiblio, $oldRecord);

    my $newRecord;

    #Overlay these records from BTJ if there is a semi-intelligent field 003.
    #Currently BTJ is our only cataloguing record vendor but we could extend to Melinda.
    my $f003 = 'BTJ'; #Default to BTJ if nothing else available
    eval { $f003 = $oldRecord->field('003')->data(); }; #Not all records for some reason have 003 ? We dont want to crash Koha because of that.
    my ($overlayRule) = _selectMatcherRule($f003, $errorsBuilder);
    if (not( ref $overlayRule eq 'C4::BatchOverlay::BatchOverlayRule' )) {
        return;
    }
    $mergeMatcher = $overlayRule->{mergeMatcher} unless $mergeMatcher;
    $componentMatcher = $overlayRule->{componentMatcher} unless $componentMatcher;

    ## Decide the external target to use ##
    my ($type, $id) = $overlayRule->getSource();
    push @z3950targets, $id;

    $newRecord = _fetchFromRemote($searchTerm, $oldBiblio, $oldRecord, \@z3950targets, $overlayRule->{remoteName}, $errorsBuilder);

    if ($oldRecord && $newRecord) {
        # 4 # Merge records with given merging rules # 4 #
        my $mergedRecord = $newRecord->clone(); #Preserve newRecord unchanged for reporting purposes.
        $mergeMatcher->overlayRecord($oldRecord, $mergedRecord); #Makes modifications directly to the $mergedRecord-object

        ### Build a biblio-record and save it ###
        $ok = C4::Biblio::ModBiblio($mergedRecord, $oldBiblionumber, $oldBiblio->{frameworkcode}) if $commit;
        if ($ok || not($commit)) {
            push (@$reports, {oldRecordXML => $oldRecord->as_xml_record($marcflavour),
                             newRecordXML => $newRecord->as_xml_record($marcflavour),
                             mergedRecordXML => $mergedRecord->as_xml_record($marcflavour),
                             operation => 'parent record merging :'.$mergedRecord->author().' - '.$mergedRecord->title().' ('.$oldBiblionumber.')',
                             });
            #All is ok and that is kewlö!
        }
        else {
            push (@$reports, {oldRecordXML => $oldRecord->as_xml_record($marcflavour),
                             newRecordXML => $newRecord->as_xml_record($marcflavour),
                             mergedRecordXML => $mergedRecord->as_xml_record($marcflavour),
                             operation => '!FAILED!: parent record merging :'.$mergedRecord->author().' - '.$mergedRecord->title().' ('.$oldBiblionumber.')',
                             });
        }

        _importChildBiblios( $mergedRecord, $oldBiblio, $componentMatcher, \@z3950targets, $commit, $reports, $errorsBuilder );
    }
    elsif ($searchTerm && $newRecord) {
        ### Build a biblio-record and save it ###
        my ($biblionumber, $biblioitemnumber) = C4::Biblio::AddBiblio($newRecord, '') if $commit;
        my $newBiblio = C4::Biblio::GetBiblio( $biblionumber ) if $commit;

        if ($biblionumber || not($commit)) {
            push (@$reports, {oldRecordXML => '',
                             newRecordXML => $newRecord->as_xml_record($marcflavour),
                             mergedRecordXML => '',
                             operation => 'importing a new record :'.$newRecord->author().' - '.$newRecord->title().' ('.$biblionumber.')',
                             });
            #All is ok and that is kewlö!
        }
        else {
            push (@$reports, {oldRecordXML => '',
                             newRecordXML => $newRecord->as_xml_record($marcflavour),
                             mergedRecordXML => '',
                             operation => '!FAILED!: importing a new record :'.$newRecord->author().' - '.$newRecord->title().' ('.$biblionumber.')',
                             });
        }

        _importChildBiblios( $newRecord, $newBiblio, $componentMatcher, \@z3950targets, $commit, $reports, $errorsBuilder );
    }
    return ($reports, $errorsBuilder);
}

sub _fetchFromRemote {
    my ($searchTerm, $oldBiblio, $oldRecord, $z3950targets, $remoteName, $errorsBuilder) = @_;

    ##Decide the search terms to use
    #my $title = getTitle($oldRecord, $oldBiblio);
    #my $author = getAuthor($oldRecord, $oldBiblio);
    my $stdid;
    if ($oldRecord) {
        $stdid = getEAN($oldRecord, $oldBiblio); #Standard ID
        $stdid = getISBN($oldRecord, $oldBiblio) unless $stdid;
        $stdid = getISSN($oldRecord, $oldBiblio) unless $stdid;
    }
    if ($searchTerm) {
        $stdid = $searchTerm;
    }

    # 2 # Secondly, look for fully catalogued Records from z39.50-targets. # 2 #
    ##Basic EAN-based search
    my $pars = {
            id => $z3950targets,
            stdid => $stdid,
    };
    my $searchResults = _z3950Wrapper($pars, $oldRecord, $oldBiblio, $errorsBuilder, $remoteName);

    unless ($searchResults) { #Lets try again with a different search term
        ##Basic EAN-based search with 0 removed
        $stdid =~ s/^\s*0//; #Remove first 0
        my $pars = {
                id => $z3950targets,
                stdid => $stdid,
        };
        $searchResults = _z3950Wrapper($pars, $oldRecord, $oldBiblio, $errorsBuilder, $remoteName);

        $errorsBuilder->popLastError(); #Remove the last error pushed in _z3950Wrapper, otherwise we get multiple "not found via Z3950" for each search retry
    }

    if ($searchResults) {
        ##Find the correct record amidst several candidates!
        my $parentBreedingResult = $searchResults->[0];
        my ($newRecord, $newRecordEncoding) = MARCfindbreeding( $parentBreedingResult->{breedingid} );
        return 0 if not($newRecord) || $newRecord < 0; #Couldn't find anything with Z-search

        # 3 # Thirdly, enforce charsets # 3 #
        if ($newRecordEncoding ne 'UTF-8') {
            $errorsBuilder->addBAD_ECODINGerror($oldRecord, $oldBiblio, $newRecordEncoding, $remoteName);
        }

        return $newRecord;
    }
    return 0;
}

=head
@param1 $z3950 search parameters HASH for C4::Breeding::Z3950Search
@param2 MARC::Record to overlay, used for error logging
@param3 C4::BatchOverlay::BatchOverlayErrors-object to gather errors
@param4 The plain text name of the remote target, eg. BTJ z39.50
=cut
sub _z3950Wrapper {
    my ($searchParameters, $oldRecord, $oldBiblio, $errorsBuilder, $remoteName) = @_;

    my $z3950results = {};

    Z3950Search($searchParameters, $z3950results, 'getAll');
    my $searchResults = $z3950results->{breeding_loop};

    if (@$searchResults == 1) {
        return $searchResults;
    }
    elsif (@$searchResults > 1) {
        $errorsBuilder->addREMOTE_SEARCH_TOOMANYerror($searchParameters, $remoteName, $oldRecord, $oldBiblio);
    }
    else {
        $errorsBuilder->addREMOTE_SEARCH_NOTFOUNDerror($searchParameters, $remoteName, $oldRecord, $oldBiblio);
    }

    return 0;
}

#Doesn't check again to prevent doubly importing the component parent. This is expected to be dealt with in the Z39.50-server.
#Currently the kohacatalogs-z3950 server uses the Local-number index just for component child linking.
sub _importChildBiblios {
    my ($parentRecord, $parentBiblio, $matcher, $z3950targets, $commit, $reports, $errorsBuilder) = @_;

    my $marcflavour = C4::Context->preference('marcflavour');

    ### Find linking component parts ###
    my $controlNumber = '';
    my $controlNumberIdentifier = '';
    eval { $controlNumber = $parentRecord->field('001')->data(); };
    eval { $controlNumberIdentifier = $parentRecord->field('003')->data(); }; #Not all records for some reason have 001/003 ? We dont want to crash Koha because of that.
    my $pars = {
    #        biblionumber => $oldBiblionumber,
    #        page => $page,
            id => $z3950targets,
    #        isbn => $isbn,
    #        issn => $issn,
    #        title => $title,
    #        author => $author,
    #        dewey => $dewey,
    #        subject => $subject,
    #        lccall => $lccall,
            controlnumber => $controlNumber,
    #        stdid => $stdid,
    #        srchany => $srchany,
    };
    my $z3950results = {};
    Z3950Search($pars, $z3950results, 'getAll');


    ### Touch component parts gently!


    my $searchResults = $z3950results->{breeding_loop};
    #Unreversing the reversal because something changed in the BTJ's end?? Initially BTJ sent their component parts in a reverse order.
    #    for ( my $i=scalar(@$searchResults)-1 ; $i>=0 ; $i--) { #Reverse the array, because component parts end up in reverse order to Koha.
    for ( my $i=0 ; $i<scalar(@$searchResults) ; $i++) { #Reverse the array, because component parts end up in reverse order to Koha.
        my $componentBreedingResult = $searchResults->[$i];
        my ($componentRecord, $componentEncoding) = MARCfindbreeding( $componentBreedingResult->{breedingid} );

        if ($componentEncoding ne 'UTF-8') {
            push @$errorsBuilder, "Bad encoding $componentEncoding";
        }

        my @matches = $matcher->get_matches( $componentRecord, 5 );
        unless (@matches) { #We don't want to add the component part if a match exists!

            _populateComponentPartFieldsFromParent($componentRecord, $parentRecord);
            my ($componentBiblionumber, $componentBiblioitemnumber) = ('',''); #Prevent undef errors when concatenating.
            ($componentBiblionumber, $componentBiblioitemnumber) = C4::Biblio::AddBiblio( $componentRecord, $parentBiblio->{frameworkcode} ) if $commit;
            if (($componentBiblionumber && $componentBiblioitemnumber) || not($commit)) {
                push (@$reports, {oldRecordXML => undef,
                             newRecordXML => $componentRecord->as_xml_record($marcflavour),
                             mergedRecordXML => undef,
                             operation => 'component record addition :'.$componentRecord->author().' - '.$componentRecord->title().' ('.$componentBiblionumber.') for ('.$parentBiblio->{biblionumber}.')',
                             });
                #All is ok and that is kewlö!
            }
            else {
                push (@$reports, {oldRecordXML => undef,
                             newRecordXML => $componentRecord->as_xml_record($marcflavour),
                             mergedRecordXML => undef,
                             operation => '!FAILED!: component record addition :'.$componentRecord->author().' - '.$componentRecord->title().' ('.$componentBiblionumber.') for ('.$parentBiblio->{biblionumber}.')',
                             });
            }
        }
        else {
            push (@$reports, {oldRecordXML => undef,
                             newRecordXML => $componentRecord->as_xml_record($marcflavour),
                             mergedRecordXML => undef,
                             operation => 'component record already present :'.$componentRecord->author().' - '.$componentRecord->title().' using matcher '.$matcher->code(),
                             });
        }
    }
}

sub generateReport {
    my $reports = shift;
    my $asHtml = shift;

    my $colWidth = 80;
    my $blank = "";


    my (@reportBuilder);
    foreach my $r (@$reports) {

        if ($asHtml) {
            $r->{operation} =~ s|\((\d+)\)|<a href="/cgi-bin/koha/cataloguing/addbiblio.pl?biblionumber=$1&frameworkcode=&op=" target="_blank">\($1\)</a>|g;
        }

        _modifyReportRecord($r);

        my $diff;
        $diff = Text::Diff::diff( \$r->{oldRecordXML} , \$r->{mergedRecordXML} , {STYLE => 'Text::Diff::Table', FILENAME_A => 'OLD RECORD', FILENAME_B => 'MERGED RECORD'}) if ($r->{oldRecordXML} && $r->{mergedRecordXML});
        $diff = Text::Diff::diff( \$r->{newRecordXML} , \$blank , {STYLE => 'Text::Diff::Table', FILENAME_A => 'NEW RECORD', FILENAME_B => ''}) if (not($diff) && $r->{newRecordXML});

        my $similarity; my $similarityString = '';
        if ($r->{operation} =~ /^parent record merging/) { #Component parts are 200% different than the "no record" they are compared to :)
            $similarity = _checkSimilarityWarning( $diff  ,  \$r->{oldRecordXML}  ,  \$r->{mergedRecordXML} );
            $similarityString = " ($similarity) ";
        }

        my $header;
        $header = "### ".$r->{operation}." ###" if $asHtml;
        $header = '##########################################################'."\n### ".$r->{operation}." ###".$similarityString."\n".'##########################################################'."\n" unless $asHtml;

        if ($asHtml) {
            $r->{diff} = $diff;
            $r->{similarity} = $similarity if $similarity;
            $r->{header} = $header;
        }
        else {
            push @reportBuilder, $header;
            push @reportBuilder, $diff;
        }

    }

    return $reports if $asHtml;
    return join "\n", @reportBuilder unless $asHtml;
}
#Do some minor xml formatting to better display the records in tabular view.
sub _modifyReportRecord {
    my $report = shift;

    $report->{oldRecordXML} =~ s|^(\s+)xsi:schemaLocation="http://www.loc.gov/MARC21/slim.+?$|$1xsi:schemaLocation="http://www.loc.gov/MARC21/slim|sgm if $report->{oldRecordXML};
    $report->{newRecordXML} =~ s|^(\s+)xsi:schemaLocation="http://www.loc.gov/MARC21/slim.+?$|$1xsi:schemaLocation="http://www.loc.gov/MARC21/slim|sgm if $report->{newRecordXML};
    $report->{mergedRecordXML} =~ s|^(\s+)xsi:schemaLocation="http://www.loc.gov/MARC21/slim.+?$|$1xsi:schemaLocation="http://www.loc.gov/MARC21/slim|sgm if $report->{mergedRecordXML};
}
sub _checkSimilarityWarning {
    my @diff = split "\n", $_[0];
    my @a = ${$_[1]} =~ /\n/g;
    my @b = ${$_[2]} =~ /\n/g;
    my $totalRows = scalar(@a) + scalar(@b);

    my $leftDiff = 0;
    my $rightDiff = 0;
    foreach my $diff (@diff) {
        if ($diff =~ /^([|*][ 0-9]+\|.*?)\s+([|*][ 0-9]+\|.*?)\s+[|*]$/) {
            if ($1 && $1 =~ /^\*/) {
                $leftDiff++;
            }
            if ($2 && $2 =~ /^\*/) {
                $rightDiff++;
            }
        }
    }

    my $similarityRating = (  ($leftDiff+$rightDiff) / $totalRows  ); #0 is exactly the same record. 0.5 means half of the rows in both records have changed.
    return $similarityRating;
}


sub _selectMatcherRule {
    my ($f003, $errorsBuilder) = (@_);

    my $overlayRule; #Go get the rule!

    if ($f003 && $f003 =~ /MELINDA/i) {
        $f003 = 'MELINDA';
    }
    elsif ($f003 && $f003 =~ /BTJ/i || $f003 =~ /KIVA/i || $f003 =~ /.+/) {
        $f003 = 'BTJ';
    }
    else {
        $errorsBuilder->addUNKNOWN_REMOTE_IDerror($f003);
    }

    unless ($batchOverlayrulesCache->{$f003}) {
        $overlayRule = C4::BatchOverlay::BatchOverlayRule->getBatchOverlayRule(undef,$f003);
        $batchOverlayrulesCache->{$f003} = $overlayRule if $overlayRule;
    }
    else {
        $overlayRule = $batchOverlayrulesCache->{$f003};
    }

    unless ($overlayRule) {
        $errorsBuilder->addUNKNOWN_BATCHOVERLAY_RULEerror($f003);
        return;
    }

    ##Decide the Matcher-object to use
    $overlayRule->{mergeMatcher} = C4::Matcher->fetch( $overlayRule->{matcher_id} );
    $overlayRule->{componentMatcher} = C4::Matcher->fetch( $overlayRule->{component_matcher_id} );
    my ($type, $id) = $overlayRule->getSource();
    $overlayRule->{remoteName} = _getRemoteSourceName($id);

    if (not($overlayRule->{mergeMatcher}) || not($overlayRule->{componentMatcher}) ) {
        $errorsBuilder->addUNKNOWN_MATCHERerror($overlayRule);
    }

    return $overlayRule;
}

sub _getRemoteSourceName {
    my $id = shift;
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT id,host,name,checked FROM z3950servers WHERE id = ?");
    $sth->execute($id);
    my $remoteSearchtarget = $sth->fetchrow_hashref();
    return $remoteSearchtarget->{name};
}

sub _populateComponentPartFieldsFromParent {
    my ($componentRecord, $parentRecord) = @_;

    ##Set the parents #952c to the component part.
    my $parent_f942c = $parentRecord->subfield('942','c');
    my $child_f942c = $componentRecord->subfield('942','c');
    my $child_f942 = $componentRecord->field('942');

    if ($child_f942c) {
        my $child_f942 = $componentRecord->field('942');
        $child_f942->update( 'a' => $parent_f942c);
    }
    else {
        my $new_f942 = MARC::Field->new( '942', '', '', 'c' => $parent_f942c);
        $componentRecord->append_fields( $new_f942 );
    }
}

sub getTitle {
    my ($record, $biblio) = @_;
    my $title = $biblio->{title};
    $title = $biblio->{unititle} unless $title;
    return $title;
}
sub getAuthor {
    my ($record, $biblio) = @_;
    my $author = $biblio->{author};

    unless ($author) {
        $author = $record->subfield('100','a');
        $author = $record->subfield('110','a') unless $author;
    }
    return $author;
}
sub getEAN {
    my ($record, $biblio) = @_;
    my $ean = $record->subfield('024','a');
    return $ean;
}
sub getISBN {
    my ($record, $biblio) = @_;
    my $isbn = $record->subfield('020','a');
    return $isbn;
}
sub getISSN {
    my ($record, $biblio) = @_;
    my $issn = $record->subfield('022','a');
    return $issn;
}

=head2 MARCfindbreeding

  $record = MARCfindbreeding($breedingid);

Look up the import record repository for the record with
record with id $breedingid.  If found, returns the decoded
MARC::Record; otherwise, -1 is returned (FIXME).
Returns as second parameter the character encoding.

=cut

sub MARCfindbreeding {
    my ( $id ) = @_;
    my $marcflavour = C4::Context->preference('marcflavour');
    my ($marc, $encoding) = GetImportRecordMarc($id);
    # remove the - in isbn, koha store isbn without any -
    if ($marc) {
        my $record = MARC::Record->new_from_usmarc($marc);
        my ($isbnfield,$isbnsubfield) = GetMarcFromKohaField('biblioitems.isbn','');
        if ( $record->field($isbnfield) ) {
            foreach my $field ( $record->field($isbnfield) ) {
                foreach my $subfield ( $field->subfield($isbnsubfield) ) {
                    my $newisbn = $field->subfield($isbnsubfield);
                    $newisbn =~ s/-//g;
                    $field->update( $isbnsubfield => $newisbn );
                }
            }
        }
        # fix the unimarc 100 coded field (with unicode information)
        if ($marcflavour eq 'UNIMARC' && $record->subfield(100,'a')) {
            my $f100a=$record->subfield(100,'a');
            my $f100 = $record->field(100);
            my $f100temp = $f100->as_string;
            $record->delete_field($f100);
            if ( length($f100temp) > 28 ) {
                substr( $f100temp, 26, 2, "50" );
                $f100->update( 'a' => $f100temp );
                my $f100 = MARC::Field->new( '100', '', '', 'a' => $f100temp );
                $record->insert_fields_ordered($f100);
            }
        }

        if ( !defined(ref($record)) ) {
            return -1;
        }
        else {
            # normalize author : probably UNIMARC specific...
            if (    C4::Context->preference("z3950NormalizeAuthor")
                and C4::Context->preference("z3950AuthorAuthFields") )
            {
                my ( $tag, $subfield ) = GetMarcFromKohaField("biblio.author", '');

#                 my $summary = C4::Context->preference("z3950authortemplate");
                my $auth_fields =
                C4::Context->preference("z3950AuthorAuthFields");
                my @auth_fields = split /,/, $auth_fields;
                my $field;

                if ( $record->field($tag) ) {
                    foreach my $tmpfield ( $record->field($tag)->subfields ) {

    #                        foreach my $subfieldcode ($tmpfield->subfields){
                        my $subfieldcode  = shift @$tmpfield;
                        my $subfieldvalue = shift @$tmpfield;
                        if ($field) {
                            $field->add_subfields(
                                "$subfieldcode" => $subfieldvalue )
                            if ( $subfieldcode ne $subfield );
                        }
                        else {
                            $field =
                            MARC::Field->new( $tag, "", "",
                                $subfieldcode => $subfieldvalue )
                            if ( $subfieldcode ne $subfield );
                        }
                    }
                }
                $record->delete_field( $record->field($tag) );
                foreach my $fieldtag (@auth_fields) {
                    next unless ( $record->field($fieldtag) );
                    my $lastname  = $record->field($fieldtag)->subfield('a');
                    my $firstname = $record->field($fieldtag)->subfield('b');
                    my $title     = $record->field($fieldtag)->subfield('c');
                    my $number    = $record->field($fieldtag)->subfield('d');
                    if ($title) {

#                         $field->add_subfields("$subfield"=>"[ ".ucfirst($title).ucfirst($firstname)." ".$number." ]");
                        $field->add_subfields(
                                "$subfield" => ucfirst($title) . " "
                            . ucfirst($firstname) . " "
                            . $number );
                    }
                    else {

#                       $field->add_subfields("$subfield"=>"[ ".ucfirst($firstname).", ".ucfirst($lastname)." ]");
                        $field->add_subfields(
                            "$subfield" => ucfirst($firstname) . ", "
                            . ucfirst($lastname) );
                    }
                }
                $record->insert_fields_ordered($field);
            }
            return $record, $encoding;
        }
    }
    return -1;
}

return 1;
