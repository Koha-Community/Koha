package C4::BatchOverlay;

# Copyright (C) 2014 The Anonymous
# Copyright (C) 2016 KohaSuomi
#
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
use Scalar::Util qw(blessed);
use Try::Tiny;
use Koha::Logger;

=head getting rid of these, but dont know which are needed :(
use MARC::Field;
use MARC::Record;
use Text::Diff;


use C4::Context;

use C4::Breeding;
use C4::Matcher;
=cut

use C4::ImportBatch;
use C4::Biblio;

use C4::BatchOverlay::LowlyFinder;
use C4::BatchOverlay::ErrorBuilder;
use C4::BatchOverlay::ReportContainer;
use C4::BatchOverlay::RuleManager;
use C4::BatchOverlay::SearchAlgorithms;
use C4::BatchOverlay::Notifier;
use Koha::Deduplicator;

use Koha::Exception;
use Koha::Exception::BatchOverlay::LocalSearchAmbiguous;
use Koha::Exception::BatchOverlay::LocalSearch;
use Koha::Exception::BatchOverlay::LocalSearchNoResults;
use Koha::Exception::BatchOverlay::DuplicateSearchTerm;
use Koha::Exception::BatchOverlay::UnknownMatcher;
use Koha::Exception::BatchOverlay::UnknownRemoteTarget;
use Koha::Exception::BatchOverlay::RemoteSearchAmbiguous;
use Koha::Exception::BatchOverlay::RemoteSearchFailed;
use Koha::Exception::BatchOverlay::RemoteSearchNoResults;
use Koha::Exception::BatchOverlay::NoBreedinRecord;
use Koha::Exception::BadParameter;
use Koha::Exception::Parse;
use Koha::Exception::DB;
use Koha::Exception::FeatureUnavailable;
use Koha::Exception::BadEncoding;
use Koha::Exception::UnknownProgramState;


our $logger = Koha::Logger->get();

=head new

    my $batchOverlayer = C4::BatchOverlayer->new();

=cut

sub new {
    my ($class, $self) = @_;
    $self = {} unless(ref($self) eq 'HASH');
    bless($self, $class);

    $self->setErrorBuilder( C4::BatchOverlay::ErrorBuilder->new() );
    $self->setReportContainer( C4::BatchOverlay::ReportContainer->new() );
    $self->setRuleManager( C4::BatchOverlay::RuleManager->new() );

    return $self;
}

sub setErrorBuilder {
    my ($self, $errorBuilder ) = @_;
    unless (blessed($errorBuilder) && $errorBuilder->isa('C4::BatchOverlay::ErrorBuilder')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($errorBuilder):> Param \$errorBuilder is not of proper class");
    }
    $self->{errorBuilder} = $errorBuilder;
}
sub getErrorBuilder {
    return shift->{errorBuilder};
}

=head addError

Populates the error with environment descriptions if they are missing
and passes the error to the ErrorBuilder.

=cut

sub addError {
    my ($self, $error, $operationName) = @_;
    unless (blessed($error)) {
        my @cc1 = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc1[3]." is adding an error, but the param \$error '$error' is not a Exception::Class derivative");
    }

    #Set the Record this error was about
    unless ($error->{records}) {
        eval {
            $error->{records} = [$self->getActiveRecord()];
        };
        if ($@) {
            $error->{records} = [];
        }
    }
    my $activeRecord = $error->{records}->[0] if @{$error->{records}} > 0;
    $error->{overlayRule} = $self->getRule($activeRecord) if (not($error->{overlayRule}) && $activeRecord);
    $error->{searchTerm} = $self->getActiveSearchTerm().'('. ($error->{searchTerm} || '') .')';
    $error->{operation} = $operationName unless ($error->{operation});

    my $report = $self->getErrorBuilder()->addError($error);
    $self->addReport($report);
}

=head setActiveRecord

Sets the active record so when stuff that needs reporting happens, we know for which record they are.

=cut

sub setActiveRecord {
    my ($self, $record) = @_;
    $self->{activeRecord} = $record;
}
sub clearActiveRecord {
    shift->{activeRecord} = undef;
}
sub getActiveRecord {
    my ($self) = @_;

    unless($self->{activeRecord}) {
        my @cc1 = caller(1);
        Koha::Exception::UnknownProgramState->throw(error => $cc1[3]." needs to know the active record, but '".__PACKAGE__."' doesn't have a active record set");
    }
    return $self->{activeRecord};
}

=head setActiveSearchTerm

Is used to mark thrown Exceptions with the currently active search term.
eg. the term we used to find the record currently being overlayed.

@param {MARC::Record or a search String}

=cut

sub setActiveSearchTerm {
    my ($self, $overlayable) = @_;
    my $term;
    if (blessed($overlayable) && $overlayable->isa('MARC::Record')) {
        $term = C4::Biblio::GetMarcBiblionumber($overlayable);
    }
    else {
        $term = $overlayable;
    }
    $self->{activeSearchTerm} = $term;
}
sub getActiveSearchTerm {
    return shift->{activeSearchTerm} || '';
}
sub setReportContainer {
    my ($self, $builder ) = @_;
    unless (blessed($builder) && $builder->isa('C4::BatchOverlay::ReportContainer')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($builder):> Param \$builder is not of proper class");
    }
    $self->{reportBuilder} = $builder;
}
sub getReportContainer {
    return shift->{reportBuilder};
}
sub addReport {
    my ($self, $report) = @_;
    $self->getReportContainer()->addReport($report);
}
sub getReports {
    return shift->getReportContainer()->getReports();
}
sub setRuleManager {
    my ($self, $ruleManager) = @_;
    $self->{ruleManager} = $ruleManager;
}
sub getRuleManager {
    return shift->{ruleManager};
}
sub getRule {
    my ($self, $record) = @_;
    return $self->getRuleManager()->getRule($record || $self->getActiveRecord());
}

=head isDryRun

Checks the overlaying rules if we are in dry-run mode or should we commit changes to DB
@RETURNS Boolean true, if not committing changes.

=cut

sub isDryRun {
    my ($self) = @_;
    return $self->getRule( $self->getActiveRecord )->isDryRun();
}

=head overlay

    my $reportContainer =  $batchOverlayer->overlay([$searchTerms]);

Looks for local biblios with the given search terms.
Then overlays the found local biblios from remote search target using the overlaying rules defined in syspref 'BatchOverlayRules'
@PARAM1 ArrayRef of search strings, must be unique identifiers for the given biblio, eg. items.barcode or isbn, ean, ...
@PARAM2 ArrayRef of MARC::Records
@RETURNS C4::BatchOverlay::ReportContainer->object containing a report of the overlaying action.

=cut

sub overlay {
    my ($self, $searchTerms, $records) = @_;
    $self->setReportContainer( C4::BatchOverlay::ReportContainer->new() ); #Clear the report container if overlaying multiple times.
    $searchTerms = $self->_sanitateSearchTermsArray($searchTerms) if $searchTerms;
    my $operationName = 'overlay record';

    my @overlayables;
    push(@overlayables, @$searchTerms) if ref $searchTerms eq 'ARRAY';
    push(@overlayables, @$records) if ref $records eq 'ARRAY';
    foreach my $overlayable (@overlayables) {
        $self->setActiveSearchTerm($overlayable); #This is needed to make reporting errors easier.
        $self->clearActiveRecord(); #Errors might happen before a new active record is found
        try {
            # 1 # Firstly, get Biblio to be merged. # 1 #
            my $localBiblionumber = (blessed($overlayable) && $overlayable->isa('MARC::Record')) ? C4::Biblio::GetMarcBiblionumber($overlayable) : $self->searchLocalRecord($overlayable);
            my $localBiblio = C4::Biblio::GetBiblio( $localBiblionumber ) if $localBiblionumber;
            my $localRecord = C4::Biblio::GetMarcBiblio( $localBiblionumber ) if $localBiblionumber;
            unless ($localBiblio && $localRecord) {
                Koha::Exception::BatchOverlay::LocalSearchNoResults->throw(error => "Searching with '".$self->getActiveSearchTerm()."' found a result from search index, but nothing from the DB");
            }
            $self->setActiveRecord($localRecord);

            # 2 # Secondly, look for fully catalogued Records from z39.50-targets. # 2 #
            my $newRecord = $self->fetchRecordFromRemoteTarget($localBiblio, $localRecord);

            # 3 # Merge records with given merging rules # 3 #
            my $mergedRecord = $self->_mergeMARCData($localRecord, $newRecord, $self->getRule()->getMergeMatcher());

            ### Mod the old biblio-record ###
            #Yikes, no way of knowing if the operation succeeded or not.
            C4::Biblio::ModBiblio($mergedRecord, $localBiblionumber, $localBiblio->{frameworkcode}) unless $self->isDryRun();
            #Add a report of the merge
            $self->addReport(
                {   localRecord => $localRecord,
                    newRecord => $newRecord,
                    mergedRecord => $mergedRecord,
                    operation => $operationName,
                    timestamp => DateTime->now( time_zone => C4::Context->tz() ),
                    overlayRule => $self->getRule(),
                }
            );

            $self->overlayComponentParts($mergedRecord, $localBiblio->{frameworkcode});
        } catch {
            unless(blessed($_) && $_->can('rethrow')) {
                #Save the report to DB before dying to know the real reason of death
                $self->addError( Koha::Exception->newFromDie($_) , $operationName);
                $self->getReportContainer()->persist();
                die $_;
            }
            if ($_->isa('Koha::Exception::BatchOverlay::LocalSearch') ||
                $_->isa('Koha::Exception::BatchOverlay::LocalSearchAmbiguous') ||
                $_->isa('Koha::Exception::BatchOverlay::LocalSearchNoResults') ||
                $_->isa('Koha::Exception::BatchOverlay::RemoteSearchNoResults') ||
                $_->isa('Koha::Exception::BatchOverlay::RemoteSearchFailed') ||
                $_->isa('Koha::Exception::BatchOverlay::RemoteSearchAmbiguous') ||
                $_->isa('Koha::Exception::BatchOverlay::NoBreedinRecord') ||
                $_->isa('Koha::Exception::Parse') ||
                $_->isa('Koha::Exception::Marc') ||
                $_->isa('Koha::Exception::BadEncoding')
                ) {
                $self->addError( $_ , $operationName);
            }
            else {
                #Save the report to DB before dying to know the real reason of death
                $self->addError( $_ , $operationName);
                $self->getReportContainer()->persist();
                $_->rethrow();
            }
        }
    }

    #Save the report to DB and return the reportContainer
    return $self->getReportContainer()->persist();
}

=head searchLocalRecord

    $batchOverlayer->searchLocalRecord( $search );

Uses the $search to make a SimpleSearch. The idea is to transform any barcode on the
physical item to a biblio match for the BatchOverlay-mechanism. This makes overlaying records super easy for the user.
@PARAM1 String, a SimpleSearch CQL query. can be just a plain string, like EAN-code or ISBN or barcode of an Item.
@RETURNS Integer, biblionumber of the local record matching the search.
@THROWS Koha::Exception::BatchOverlay::AmbiguousSearchTerm,
                                if there are multiple results for the SimpleSearch. Notify the user that the $search-words
                                needs more details to provide only one result.
@THROWS Koha::Exception::BatchOverlay::LocalSearch,
                                if an error happened when doing the search
@THROWS Koha::Exception::LocalSearchNoResults, if there are no search results
@THROWS Koha::Exception::Parse, if the biblionumber couldn't be extracted from the result XML

=cut

sub searchLocalRecord {
    my ( $self, $search ) = @_;

    #Find the biblios by the given code! There should be only 1!
    my ($error, $results, $resultSetSize) = C4::Search::SimpleSearch( $search );
#    unless ($resultSetSize) { #EAN is a bitch and often in our catalog we have an extra 0.
#        $search = '0'.$search;
#        ($error, $results, $resultSetSize) = C4::Search::SimpleSearch( $search );
#    }
    if ($resultSetSize && $resultSetSize == 1 && !$error) {
        my $bn = _getBiblionumberFromXML($results->[0]);
        return $bn if defined($bn);
        Koha::Exception::Parse->throw(error => "Couldn't extract the biblionumber from search result using search '$search'");
    }
    elsif ($resultSetSize && $resultSetSize > 1) { #Wow, an ambiguous search term, which result do we choose!!
        Koha::Exception::BatchOverlay::LocalSearchAmbiguous->throw(error => "Given local search '$search' matches '$resultSetSize' records.");
    }
    elsif ($error) {
        Koha::Exception::BatchOverlay::LocalSearch->throw(error => "Local search '$search', fails with error '$error'");
    }
    else {
        Koha::Exception::BatchOverlay::LocalSearchNoResults->throw(error => "Local search '$search' produced no results");
    }
    return undef;
}

=head fetchRecordFromRemoteTarget

    my $record = $batchOverlayer->fetchRecordFromRemoteTarget($localBiblio, $localRecord);

Fetches a matching record from the remote search target using the matching rules defined in the configuration syspref.
Can perform a multitiered search, where different search rules are tried if none of the previous
ones match, depending on the configuration.

@PARAM1 HASHref of a koha.biblio-table row
@PARAM2 MARC::Record of the @PARAM2
@THROWS a lot of different Koha::Exception::BatchOverlay::*

=cut

sub fetchRecordFromRemoteTarget {
    my ($self, $localBiblio, $localRecord) = @_;
    my $overlayRule = $self->getRule($localRecord);

    my ($searchResult, $exceptions) = $self->_trySearchAlgorithms($overlayRule->getSearchAlgorithms(), $overlayRule->getRemoteTarget(), $localRecord);

    unless ($searchResult) {
        $self->_handleErrorStack($exceptions);
    }

    if ($searchResult) {
        $self->_castSearchResultToRecord($searchResult, $overlayRule);
    }
}

sub _castSearchResultToRecord {
    my ($self, $searchResult, $overlayRule) = @_;

    ##Find the correct record amidst several candidates!
    my ($newRecord, $newRecordEncoding) = MARCfindbreeding( $searchResult->{breedingid} );

    unless ($newRecord) {
        my @cc = caller(0);
        Koha::Exception::BatchOverlay::NoBreedinRecord->throw(error => $cc[3]."():> No breeding record found with breeding_id '".$searchResult->{breedingid}."'.");
    }

    # 3 # Thirdly, enforce charsets # 3 #
    if ($newRecordEncoding ne 'UTF-8') {
        my @cc = caller(0);
        Koha::Exception::BadEncoding->throw(error => $cc[3]."():> Encoding '$newRecordEncoding' for breeding record is not 'UTF-8'");
    }

    $self->_sanitateRemoteRecord($newRecord, $overlayRule);
    $newRecord->{breedingid} = $searchResult->{breedingid};
    return $newRecord;
}

=head _trySearchAlgorithms

    my ($searchResult, $exceptions) = C4::BatchOverlay->_trySearchAlgorithms();

Executes all the search algorithms and collects any exceptions for the given record.

@PARAM1 ARRAYref, search algorithms
@PARAM2 HASHref, z3950 server HASH-object
@PARAM3 MARC::Record, the local record to match against remote
@RETURNS List, HASHref of a breeding record
               ARRAYref of Exception-objects or plain die-exceptions

=cut

sub _trySearchAlgorithms {
    my ($class, $searchAlgorithms, $z3950server, $localRecord) = @_;
    my $searchResult;
    my @exceptions; #Collect exceptions from multiple search attempts here and if no search produces results, throw them all
    for(my $i=0 ; $i<scalar(@$searchAlgorithms) ; $i++) {
        my $alg = $searchAlgorithms->[$i];
        try {
            $searchResult = C4::BatchOverlay::SearchAlgorithms::dispatch($alg, $z3950server, $localRecord);
        } catch {
            push(@exceptions, $_);
        };
        last if $searchResult;
    }
    return ($searchResult, \@exceptions);
}

=head _sanitateRemoteRecord

If the remote record has the same system controlfields set as in Koha, remove them
to avoid unnecessary complications with getting confused with remote biblionumbers
conflicting with ours, or having remote holdings records.

=cut

sub _sanitateRemoteRecord {
    my ($self, $record, $overlayRule) = @_;

    my $rfd = $overlayRule->getRemoteFieldsDropped();
    foreach my $field (@$rfd) {
        my @fields = $record->field($field);
        $record->delete_fields(@fields);
    }
}

sub _mergeMARCData {
    my ($class, $fromRecord, $toRecord, $mergeMatcher) = @_;

    my $mergedRecord = $toRecord->clone(); #Preserve newRecord unchanged for reporting purposes.
    $mergeMatcher->overlayRecord($fromRecord, $mergedRecord); #Makes modifications directly to the $mergedRecord-object

    return $mergedRecord;
}

=head

    my $searchTerms = C4::BatchOverlay::_sanitateSearchTermsArray(\@searchTerms);

Remove duplicate codes, because Zebra doesn't do real time indexing and then we get double import of component parts and parents get merged twice.
Appends duplicate search term errors to ErrorBuilder if detected.
@PARAM1 ARRAYRef of SimpleSearch search sentences

@THROWS Koha::Exception::BadParameter if parameters are not proper ARRAYRefs.
=cut

sub _sanitateSearchTermsArray {
    my ($self, $searchTerms) = @_;
    my %searchTerms;

    unless (ref($searchTerms) eq 'ARRAY' && scalar(@$searchTerms) > 0) {
        my @cc = caller(3);
        Koha::Exception::BadParameter->throw(error => $cc[3]."()> \$searchTerms is not an ARRAYRef or is empty");
    }

    for(my $i=0 ; $i<@$searchTerms ; $i++){
        #Sanitate the codes! Always sanitate input!! Mon dieu!
        $searchTerms->[$i] =~ s/^\s*//; #Trim codes from whitespace.
        $searchTerms->[$i] =~ s/\s*$//; #Otherwise very hard to debug!?!!?!?!?

        unless ($searchTerms{ $searchTerms->[$i] }){
            $searchTerms{ $searchTerms->[$i] } = 1;
        }
        else {
            $self->addError(Koha::Exception::BatchOverlay::DuplicateSearchTerm->new(error => "Duplicate search term '".$searchTerms->[$i]."'",
                                                                                    searchTerm => $searchTerms->[$i]),
                            'sanitate search terms');
        }
    }

    $searchTerms = [sort keys %searchTerms];

    return $searchTerms;
}

=head _handleErrorStack

Some operations work on a batch of values and collect exceptions into a stack.
This function passes the exceptions to be reportized, and rethrows the last exception,
to notify exception handlers that an error happened with the batch operation.

=cut

sub _handleErrorStack {
    my ($self, $exceptions) = @_;
    unless (@$exceptions) {
        my $activeRecord = { eval $self->getActiveRecord() };
        my @cc = caller(0);
        Koha::Exception::UnknownProgramState->throw(error => $cc[3]."():> No result, but no exception either for record ".
                                                                C4::Biblio::GetMarcTitle($activeRecord).' - '.C4::Biblio::GetMarcAuthor($activeRecord).' - '.C4::Biblio::GetMarcStdids($activeRecord).
                                                                ". This is very strange and shouldn't happen",
                                                    marcRecord => $activeRecord);
    }
    #Publish all but the last exception, finally throw the last one to end this fetchRecordFromRemoteTarget-operation as failed.
    for (my $i=0 ; $i<scalar(@$exceptions)-1 ; $i++) {
        my $e = $exceptions->[$i];
        $self->addError($e);
    }
    $exceptions->[-1]->rethrow() if blessed($exceptions->[-1]) && $exceptions->[-1]->can('rethrow');
    die $exceptions->[-1];
}

=head overlayComponentParts

    $batchOverlayer->overlayComponentParts($parentRecord, $frameworkcode);

Searches the remote for component parts for the given record.
If component parts are found, tries to deduplicate them against existing records using the
'componentPartMatcher'.
If duplicates are found, uses the 'componentPartMergeMatcher' to overlay existing component parts.

=cut

sub overlayComponentParts {
    my ($self, $parentRecord, $biblioFrameworkcode) = @_;
    my $overlayRule = $self->getRule($parentRecord);
    my $operationName = 'fiddling component parts';
    $self->setActiveRecord($parentRecord);

    try {
        my ($searchResults, $exceptions) = $self->_trySearchAlgorithms(['Component_part_773w_003'], $overlayRule->getRemoteTarget(), $parentRecord);

        unless ($searchResults) {
            $self->_handleErrorStack($exceptions);
        }

        for ( my $i=0 ; $i<scalar(@$searchResults) ; $i++) {
            my $componentRecord = $self->_castSearchResultToRecord($searchResults->[$i], $overlayRule);
            _populateComponentPartFieldsFromParent($componentRecord, $parentRecord);
            my ($localRecord, $newRecord, $mergedRecord) = $self->_deduplicateComponentPart($componentRecord, $overlayRule, $biblioFrameworkcode);
            if ($localRecord && $newRecord && $mergedRecord) {
                $operationName = "overlaying component part";
            }
            else {
                $operationName = "new component part";
            }

            #Add a report of the merge
            my %rep = (
                operation => $operationName,
                timestamp => DateTime->now( time_zone => C4::Context->tz() ),
                overlayRule => $overlayRule,
            );
            $rep{mergedRecord} = $mergedRecord if $mergedRecord;
            $rep{localRecord} = $localRecord if $localRecord;
            $rep{newRecord} = $newRecord if $newRecord;

            $self->addReport( \%rep );
        }
    } catch {
        unless(blessed($_) && $_->can('rethrow')) {
            my $e = Koha::Exception->newFromDie($_);
            $e->{operation} = $operationName;
            $e->throw();
        }
        if ($_->isa('Koha::Exception::BatchOverlay::RemoteSearchNoResults')) {
            ##We ignore this kind of exceptions. Not every record must have component
            ##parts and as such it would be cumbersome to return exceptions for every try.
        }
        elsif ($_->isa('Koha::Exception::BatchOverlay::RemoteSearchFailed') ||
            $_->isa('Koha::Exception::BatchOverlay::RemoteSearchAmbiguous') ||
            $_->isa('Koha::Exception::BatchOverlay::NoBreedinRecord') ||
            $_->isa('Koha::Exception::Parse') ||
            $_->isa('Koha::Exception::BadEncoding') ||
            $_->isa('Koha::Exception::Deduplicator::TooManyMatches')
            ) {
            $self->addError( $_, $operationName );
        }
        else {
            $_->{operation} = $operationName;
            $_->rethrow();
        }
    };
}

=head _deduplicateComponentPart

At this point the found remote component part has not yet been persisted to DB and is not available from the search index.
Look for matches from the local index, if we have more than one, deduplicate them, if we have more than 3, throw an error to protect against destruction.
Then overlay the remaining component part with the new remote component part.

@RETURNS (MARC::Record, MARC::Record, MARC::Record), The local record, new component part from remote, and the merged record.
@THROWS Koha::Exception::Deduplicator::TooManyMatches from Koha::Deduplicator if there are more than 2 matches of the same component part in the local index.
                    We never should have so many deduplicate component parts and there more certainly is a problem with the matching configuration.

=cut

sub _deduplicateComponentPart {
    my ($class, $componentRecord, $overlayRule, $biblioFramework) = @_;

    my $matches = Koha::Deduplicator->getMatches($overlayRule->getComponentPartMatcher(),
                                                 $componentRecord, 4, 2);

    my $lastMatchStanding;
    $lastMatchStanding = Koha::Deduplicator->mergeMatches($matches) if (scalar(@$matches) > 1); #Deduplicate multiple results
    $lastMatchStanding = $matches->[0] if( not($lastMatchStanding) && @$matches); #If nothing to deduplicate take the only existing record in local index

    if ($lastMatchStanding) {
        my $lastRecordStanding = $lastMatchStanding->{target_record};
        my $mergedRecord = $class->_mergeMARCData($lastRecordStanding, $componentRecord, $overlayRule->getComponentPartMergeMatcher());

        ### Mod the old biblio-record ###
        #Yikes, no way of knowing if the operation succeeded or not.
        C4::Biblio::ModBiblio($mergedRecord, $lastMatchStanding->{record_id}, $biblioFramework) unless $overlayRule->isDryRun();
        return ($lastRecordStanding, $componentRecord, $mergedRecord);
    }
    else {
        #Add the new component part to DB. Then fetch the persisted record with Koha-specific fields set.
        my ($componentBiblionumber, $componentBiblioitemnumber) = C4::Biblio::AddBiblio( $componentRecord, $biblioFramework ) unless $overlayRule->isDryRun();
        $componentRecord = C4::Biblio::GetMarcBiblio($componentBiblionumber, undef) if ($componentBiblionumber && not($overlayRule->isDryRun()));
        if (not($componentRecord) && not($overlayRule->isDryRun())) {
            my @cc = caller(0);
            Koha::Exception::DB->throw(error => $cc[3]."():> Couldn't get the component part MARC::Record from DB?! I just put it there! For component record '".C4::Biblio::GetMarcTitle($componentRecord).C4::Biblio::GetMarcAuthor($componentRecord)."'.");
        }
        return (undef, $componentRecord, undef);
    }
}

sub _populateComponentPartFieldsFromParent {
    my ($componentRecord, $parentRecord) = @_;

    C4::Biblio::SetMarcKohaDefaultItemType($componentRecord,
                                           C4::Biblio::GetMarcKohaDefaultItemType($parentRecord));

    C4::Biblio::SetMarcKohaFramework($componentRecord,
                                           C4::Biblio::GetMarcKohaFramework($parentRecord));
}

=head2 batchOverlay

=cut

sub batchOverlay {
    my ($self, $params) = @_;
    my $lowlyFinder = C4::BatchOverlay::LowlyFinder->new($params);

    while (my $records = $lowlyFinder->nextLowlyCataloguedRecords()) {
        $self->overlay(undef, $records);
    }
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
        my ($isbnfield,$isbnsubfield) = C4::Biblio::GetMarcFromKohaField('biblioitems.isbn','');
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
                my ( $tag, $subfield ) = C4::Biblio::GetMarcFromKohaField("biblio.author", '');

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

sub _getBiblionumberFromXML {
    my $marcxml = shift;

    my ( $tagid_biblionumber, $subfieldid_biblionumber ) = C4::Biblio::GetMarcFromKohaField( "biblio.biblionumber" );

    #Get the biblionumber!
    if ($marcxml =~ /<(data|control)field tag="$tagid_biblionumber".*?>(.*?)<\/(data|control)field>/s) {
        my $fieldStr = $2;
        if ($fieldStr =~ /<subfield code="$subfieldid_biblionumber">(.*?)<\/subfield>/) {
            return $1;
        }
    }
}

return 1;
