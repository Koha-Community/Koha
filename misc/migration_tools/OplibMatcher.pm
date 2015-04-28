#/usr/bin/perl
package OplibMatcher;

use Modern::Perl;
use Carp;

my $legacyBiblionumberRegexp; #Use this regexp to make sure the biblionumber we are dealing with is of proper format
#$legacyBiblionumberRegexp = qr(\d+); #For Pallas and other full number biblionumbers
$legacyBiblionumberRegexp = qr/([0-9A-Z]{8}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{4}-[0-9A-Z]{12})/; #For crazy Origo
sub new {
    my ($class, $manualRulesFile, $matcherLogFile, $verbose) = @_;
    my $self = {};
    bless($self, $class);
    $self->{verbose} = $verbose;
    $self->_loadManualMatchingRules($manualRulesFile);
    $self->_openMatcherLog($matcherLogFile);
    return $self;
}

sub getLegacyBiblionumber {
    my ($self, $record) = @_;

    #my $legacyBiblionumber = $record->subfield('999','c'); #From old system migrating to Koha #FOR LIBRA3
    my $legacyBiblionumber = $record->field('001'); #From old system migrating to Koha #FOR PALLASPRO
    $legacyBiblionumber = $legacyBiblionumber->data() if $legacyBiblionumber;
    return $legacyBiblionumber;
}

sub _loadManualMatchingRules {
    my ($self, $manualRulesFile) = @_;

    $self->{mergeVerifications} = {};

    open(MVF, "<:encoding(utf-8)", $manualRulesFile) or warn "Couldn't open the matcher verification file '$manualRulesFile' ".$!;
    while (<MVF>) {
        if ($_ =~ /^\s*($legacyBiblionumberRegexp)\s+(.*?)(\s+#.*?)?$/) {
            $self->_putManualMatchingRuleToHash( $1, $2 ); #Map the legacy biblionumber to an existing koha biblionumber.
        }
        else {
            warn "Couldn't parse matcher verification file entry $_\n";
        }
    }
    close(MVF);
    open(my $MVF, ">>:encoding(utf-8)", $manualRulesFile) or die "Couldn't open the matcher verification file '$manualRulesFile' ".$!;
    $self->{manualRulesFile} = $MVF;
}
sub _putManualMatchingRuleToHash {
    my ($self, $legacyBiblionumber, $status) = @_;
    $self->{mergeVerifications}->{$legacyBiblionumber} = uc($status);
}
sub _writeManualMatchingRuleToFile {
    my ($self, $legacyBiblionumber, $status, $comment) = @_;
    my $handle = $self->{manualRulesFile};
    my $text = sprintf("%38s %12s",$legacyBiblionumber, $status).(($comment) ? "    $comment" : "")."\n";
    print $handle $text;
}
=head
Only allow status 'PENDING' to be set from the script. This is a manual verification file so end user needs to
check the statuses.
=cut
sub addPendingToManualMatchingRules {
    my ($self, $legacyBiblionumber) = @_;

    carp "legacyBiblionumber '$legacyBiblionumber' is not valid!" unless($legacyBiblionumber && $legacyBiblionumber =~ /^$legacyBiblionumberRegexp$/);

    my $status = 'PENDING';
    my $comment;
    $self->_writeManualMatchingRuleToFile($legacyBiblionumber, $status, $comment);
    $self->_putManualMatchingRuleToHash($legacyBiblionumber, $status);
}
=head
We need to add verified automatic matches as well, so component parts know what matches hapened,
and we can decide what to do with component parts whose parent matches an existing record.
=cut
sub addMatchToManualMatchingRules {
    my ($self, $legacyBiblionumber, $matchingBiblionumber) = @_;
    my $handle = $self->{manualRulesFile};

    carp "legacyBiblionumber '$legacyBiblionumber' is not valid!" unless($legacyBiblionumber && $legacyBiblionumber =~ /^$legacyBiblionumberRegexp$/);
    carp "matchingBiblionumber '$matchingBiblionumber' is not a digit!" unless($matchingBiblionumber && $matchingBiblionumber =~ /^\d+$/);

    my $comment = "#automatch";
    $self->_writeManualMatchingRuleToFile($legacyBiblionumber, $matchingBiblionumber, $comment);
    $self->_putManualMatchingRuleToHash($legacyBiblionumber, $matchingBiblionumber);
}
sub fetchManualMatchingRule {
    my ($self, $legacyBiblionumber) = @_;
    return undef unless $legacyBiblionumber;
    return $self->{mergeVerifications}->{$legacyBiblionumber};
}

=head heckManualMAtchingRule
@RETURN String, undef, if no matchingRule
                biblionumber, the Koha biblionumber this Record matches
                KILL, if this Record is instructed to die
                PENDING, if this Record is pending manual matching
                OK, if this Record can be pushed as a new Record
                CP, if the record is a component part and has no other matching rules applied
=cut

sub checkManualMatchingRule {
    my ($self, $record) = @_;

    my $legacyBiblionumber = $self->getLegacyBiblionumber($record);
    ##Check if the record is a component part.
    ## Migrate component parts only if the legacy parent is added as a new record.
    my $componentParentLegacyBiblionumber = checkIsAComponentPart( $record );
    if (my $rule = $self->fetchManualMatchingRule($componentParentLegacyBiblionumber)) { #Is there a rule for this component parts parent?
        if ($rule =~ /^\d+$/) {
            $self->writeToMatcherLog("Legacy biblionumber '$legacyBiblionumber', component parent matches an existing record. Removing this component part.\n") if $self->{verbose};
            return 'KILL';
        }
        elsif ($rule =~ /^PEN/i) {
            $self->writeToMatcherLog("Legacy biblionumber '$legacyBiblionumber', component parent is PENDING manual inspection. Skipping this component part.\n") if $self->{verbose};
            return 'KILL';
        }
        elsif ($rule =~ /^KILL/i) {
            $self->writeToMatcherLog("Legacy biblionumber '$legacyBiblionumber', component parent is KILLED during manual inspection. Killing component part too.") if $self->{verbose};
            return 'KILL';
        }
        elsif ($rule =~ /^OK/i) { #OK, This record has been confirmed as a new addition.
            return $rule;
        }
        else { #Something is very very wrong with the merge override rules.
            warn "Unknown value in \$mergeOverrides: $rule\nWhen searching for legacy biblionumber '$legacyBiblionumber'.\n";
            return;
        }
    }

    #Check for manual overrides for unknown mergings and merge history.
    if (my $rule = $self->fetchManualMatchingRule($legacyBiblionumber)) { #Is there a rule for this biblionumber?
        if ($rule =~ /^\d+$/) { #This is a Koha biblionumber and we know to match to that record.
            $self->writeToMatcherLog("Legacy biblionumber '$legacyBiblionumber' manually converted to $rule.\n") if $self->{verbose};
            return $rule;
        }
        elsif ($rule =~ /^PEN/i) { #PENDING, This record has triggered a fuzzy warning and is under manual inspection.
            $self->writeToMatcherLog("Legacy biblionumber '$legacyBiblionumber' is PENDING manual inspection.\n") if $self->{verbose};
            return $rule;
        }
        elsif ($rule =~ /^KILL/i) { #KILL, This record is not wanted in this migration.
            $self->writeToMatcherLog("Legacy biblionumber '$legacyBiblionumber' is KILLED during manual inspection.\n") if $self->{verbose};
            return $rule;
        }
        elsif ($rule =~ /^OK/i) { #OK, This record has been confirmed as a new addition.
            return $rule;
        }
        else { #Something is very very wrong with the merge override rules.
            warn "Unknown value in \$mergeOverrides: $rule\nWhen searching for legacy biblionumber '$legacyBiblionumber'.\n";
            return;
        }
    }
    return 'CP' if checkIsAComponentPart( $record );
    return undef; #Make sure we retun undef even under all strange eval cases and whatnot.
}

sub _openMatcherLog {
    my ($self, $logFile) = @_;

    open(my $MATCHERLOG, ">>:encoding(utf-8)", $logFile) or die "Couldn't open the matcher log file '$logFile' ".$!;
    $self->{matcherLog} = $MATCHERLOG;
}
sub writeToMatcherLog {
    my ($self, $text) = @_;
    my $handle = $self->{matcherLog};
    print $handle $text;
}

sub checkIsAComponentPart {
    my $record = shift;
    return $record->{isaComponentPart_parentBiblionumber} if exists $record->{isaComponentPart_parentBiblionumber};
    $record->{isaComponentPart_parentBiblionumber} = $record->subfield('773','w');
    return $record->{isaComponentPart_parentBiblionumber};
}
sub checkIsASerial {
    my $record = shift;
    return $record->{isaSerial} if exists $record->{isaSerial};
    my $itemtype = $record->subfield('942','c');
    $record->{isaSerial} = 1 if $itemtype eq 'AL' || $itemtype eq 'SL';
    return $record->{isaSerial};
}

=head checkMatch
This function does the dirty work of matching.
First it checks the manualMatchingRule to see if a rule already applies for this
Record (identified by the legacy biblionumber).

If a rule is given, return the rule, and conclude the matching process.

If no rule is given, proceed to make a tiered search.
If for the new record, many different matches are found, or if the matching rules are considered to
be fuzzy, manual matching is needed.
When manual matching is needed, the manualMatchingRules are updated in memory, so component parts and other
linked records can check their host matchingRules.

=head COMPONENT PARTS
The matching rules for component parts are more strict
and component parts are only pushed to Koha if the parent record doesn't match anything,
(there was no manualMatchingRule generated for the parent)
or the manualMatchingRules explicitly allow the component parent to be pushed.
There is no multitiered matching for component parts and other linked records, so they are either
pushed if the parent was pushed or not at all.
=cut

sub checkMatch {
    my ($self, $record) = @_;

    my $legacy_biblionumber = $self->getLegacyBiblionumber($record);
    my $resolution = $self->checkManualMatchingRule($record);
    return $resolution if $resolution;

    my ($zebraerror, $results, $resultSetSize, $needManualVerification, $searchQuery) =
                $self->_makeMultitierMatchingSearches_pielinen($record);


    if ($zebraerror) { #The Zebra query might have failed catastrophically!
        $resultSetSize = 0;
        $needManualVerification = 1;
        $self->writeToMatcherLog("\nZebraerror biblionumber $legacy_biblionumber: $zebraerror\n");
    }


    if ($resultSetSize == 1 && not($needManualVerification)) {
        #Get the biblionumber!
        my $matching_biblionumber;
        if ($results->[0] =~ /<(data|control)field tag="999".*?>(.*?)<\/(data|control)field>/s) {
            my $fieldStr = $2;
            if ($fieldStr =~ /<subfield code="c">(.*?)<\/subfield>/) {
                $matching_biblionumber = $1;
            }
        }
        if ($matching_biblionumber) {
            $self->addMatchToManualMatchingRules($legacy_biblionumber, $matching_biblionumber);
            return $matching_biblionumber;
        }
        else {
            $self->writeToMatcherLog("Koha record matches searchQuery $searchQuery but doesn't have a biblionumber??");
            $needManualVerification = 1;
        }
    }
    if ($resultSetSize > 1 || $needManualVerification) {
        my $text = join(
                   "\nxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxo\n",
                   "Legacy record $legacy_biblionumber needs manual confirmation\nMatching with $searchQuery. Got $resultSetSize matches.\n",
                   $record->as_formatted(),
                   "\nxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxoxo\n\n");
        $self->writeToMatcherLog($text);
        $self->addPendingToManualMatchingRules($legacy_biblionumber);
        return -1;
    }
}

sub normalizeTerm {
    my $term = shift;
    return '' unless $term;
    $term =~ s/\(.*?\)//ugsm; #Remove everything between parenthesis
    $term =~ s/\W/ /ugsm; #Remove all non-alphanumeric characters
    return $term;
}

sub _removeComponentPartsFromSearchResults {
    my ($self, $results, $resultSetSize) = @_;
    my $noncomponentresults = [];
    foreach my $result (@$results) {
        #Get the field 773 to proove this record is a component part.
        if ($result =~ /<datafield tag="773".*?>(.*?)<\/datafield>/s) {
            my $fieldStr = $1;
        }
        else {
            push @$noncomponentresults, $result;
        }
    }
    my $noncomponentResultSetSize = scalar(@$noncomponentresults);
    if ($noncomponentResultSetSize) {
        $self->writeToMatcherLog("Component parts filtered from $resultSetSize to $noncomponentResultSetSize\n") if $self->{verbose};
        return ($noncomponentresults, $noncomponentResultSetSize);
    }

    return ($results, $resultSetSize);
}


sub _makeMultitierMatchingSearches_pielinen {
    my ($self, $record) = @_;

    my ($zebraerror, $results, $resultSetSize, $needManualVerification, $searchQuery);

    my $isbn_ean;
    if (my $sf020a = $record->subfield('020','a')) {
        $isbn_ean = "Identifier-standard='$sf020a'";
    }
    elsif (my $sf024a = $record->subfield('024','a')) {
        $isbn_ean = "Identifier-standard='$sf024a'";
    }
    elsif (my $sf028a = $record->subfield('028','c')) {
        $isbn_ean = "Identifier-standard='$sf028a'";
    }
    my $author          = "au='".normalizeTerm($record->author())."'";
    my $title           = "ti='".normalizeTerm($record->title()) ."'";
    my $edition         = "Edition='".normalizeTerm($record->edition())."'";
    my $publicationYear = "yr='".normalizeTerm($record->subfield('260','c'))."'";
#    my $publisher = normalizeTerm($record->subfield('260','b'));
    my $itemtype        = "mc-itype='".normalizeTerm($record->subfield('942','c'))."'";

    if (checkIsASerial($record)) {
        if (not($zebraerror) && not($resultSetSize)) {
            $searchQuery = "$title and $itemtype";
            ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery, undef, 1 );
            unless ($zebraerror) {
                $self->writeToMatcherLog("SearchSerial: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
                ($results, $resultSetSize) = $self->_removeComponentPartsFromSearchResults($results, $resultSetSize) if $resultSetSize > 1;
            }
        }
        return ($zebraerror, $results, $resultSetSize, $needManualVerification, $searchQuery);
    }

    # Check ISBN/EAN, author, title, edition, publisher for a strong match
    if (not($zebraerror) && not($resultSetSize) && $isbn_ean) {
        $searchQuery = "$isbn_ean and $itemtype";
        ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery, undef, 1 ); #Offset undef, max_results = 1
        unless ($zebraerror) {
            $self->writeToMatcherLog("SearchISBNStrong: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
            ($results, $resultSetSize) = $self->_removeComponentPartsFromSearchResults($results, $resultSetSize) if $resultSetSize > 1;
        }
    }
    # Check for a strong match without ISBN/EAN
    if (not($zebraerror) && not($resultSetSize)) {
        $searchQuery = "$author and $title and $edition and $publicationYear and $itemtype";
        ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery, undef, 1 ); #Offset undef, max_results = 1
        unless ($zebraerror) {
            $self->writeToMatcherLog("SearchStrong: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
            ($results, $resultSetSize) = $self->_removeComponentPartsFromSearchResults($results, $resultSetSize) if $resultSetSize > 1;
        }
    }
    # Check only title + author + itemtype and ask for manual confirmation
    if (not($zebraerror) && not($resultSetSize)) {
        $searchQuery = "$author and $title and $itemtype";
        ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery, undef, 1 ); #Offset undef, max_results = 1
        unless ($zebraerror) {
            $self->writeToMatcherLog("SearchFuzzy: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
            $needManualVerification = 1 if $resultSetSize; #Need to manually verify only if a match is found
        }
    }

    return ($zebraerror, $results, $resultSetSize, $needManualVerification, $searchQuery);
}

sub _makeMultitierMatchingSearches_libra3 {
    my ($self, $record) = @_;

    my ($zebraerror, $results, $resultSetSize, $needManualVerification, $searchQuery);

    ##Make a 4-tier search.
    my $isbn_ean;
    if (my $sf020a = $record->subfield('020','a')) {
        $isbn_ean = $sf020a;
    }
    elsif (my $sf028a = $record->subfield('028','c')) {
        $isbn_ean = $sf028a;
    }
    my $author    = normalizeTerm($record->author());
    my $title     = normalizeTerm($record->title());
    my $edition   = normalizeTerm($record->edition());
    my $publisher = normalizeTerm($record->subfield('260','b'));
    my $itemtype  = normalizeTerm($record->subfield('942','c'));


    # Check ISBN/EAN, author, title, edition, publisher for a strong match
    if (not($zebraerror) && $isbn_ean) {
        $searchQuery = "$isbn_ean $author $title $edition $publisher";
        ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery );
        unless ($zebraerror) {
            $self->writeToMatcherLog("SearchISBNStrong: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
            ($results, $resultSetSize) = $self->_removeComponentPartsFromSearchResults($results, $resultSetSize) if $resultSetSize > 1;
        }
    }
    # Check only ISBN/EAN, and ask for manual confirmation
    if (not($zebraerror) && $isbn_ean && not($resultSetSize)) {
        $searchQuery = "$isbn_ean";
        ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery );
        unless ($zebraerror) {
            $self->writeToMatcherLog("SearchISBN: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
            ($results, $resultSetSize) = $self->_removeComponentPartsFromSearchResults($results, $resultSetSize) if $resultSetSize > 1;
        }
    }
    # Check for a strong match without ISBN/EAN
    if (not($zebraerror) && not($resultSetSize)) {
        $searchQuery = "$author $title $edition $publisher";
        ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery );
        unless ($zebraerror) {
            $self->writeToMatcherLog("SearchStrong: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
            ($results, $resultSetSize) = $self->_removeComponentPartsFromSearchResults($results, $resultSetSize) if $resultSetSize > 1;
        }
    }
    # Check only title + author match, and ask for manual confirmation
    if (not($zebraerror) && not($resultSetSize)) {
        $searchQuery = "$author $title";
        ($zebraerror, $results, $resultSetSize) = C4::Search::SimpleSearch( $searchQuery );
        unless ($zebraerror) {
            $self->writeToMatcherLog("SearchFuzzy: $searchQuery\nResultSetSize: $resultSetSize.\n") if $self->{verbose};
            $needManualVerification = 1 if $resultSetSize; #Need to manually verify only if a match is found
        }
    }

    return ($zebraerror, $results, $resultSetSize, $needManualVerification, $searchQuery);
}

return 1;
