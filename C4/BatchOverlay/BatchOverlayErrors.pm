package C4::BatchOverlay::BatchOverlayErrors;

use Modern::Perl;

use C4::Context;

sub new {
    my ($class, $notHtmlOutput) = @_;

    my $self = { };
    $self->{notHtmlOutput} = $notHtmlOutput if $notHtmlOutput;
    $self->{errors} = []; #Collect the error Hashes here.
    bless $self, $class;

    return $self;
}

sub setActiveBiblio {
    my ($self, $biblio, $record) = @_;

    $self->{activeBiblio} = $biblio;
    $self->{activeRecord} = $record
}

sub addUNKNOWN_BATCHOVERLAY_RULEerror {
    my ($self, $overlayRuleName) = @_;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "Couldn't find the batch overlay rule with name <".$overlayRuleName.">.";
    } else {
        $self->_addErrorObject('UNKNOWN_BATCHOVERLAY_RULE', '', '', '<'.$overlayRuleName.'>');
    }
}
sub addUNKNOWN_MATCHERerror {
    my ($self, $overlayRule) = @_;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "Couldn't find the merging matcher or a component part matcher with ids' <".$overlayRule->{matcher_id}."> and <".$overlayRule->{component_matcher_id}. ">. Extremely unsafe to proceed and halting.";
    } else {
        $self->_addErrorObject('UNKNOWN_MATCHER', '', '', '<'.$overlayRule->{matcher_id}.'> & <'.$overlayRule->{component_matcher_id}.'>');
    }
}
sub addUNKNOWN_REMOTE_IDerror {
    my ($self, $f003, $record, $biblio) = @_;
    my ($biblionumber, $recordIdentifier);
    ($record, $biblio, $biblionumber, $recordIdentifier) = $self->_parseParamRecordBiblio($record, $biblio);

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$recordIdentifier.". Couldn't find the correct bibliographic record source for biblionumber <$biblionumber> based on the field 003 <$f003>. Currently BTJ and KV is supported.";
    } else {
        $self->_addErrorObject('UNKNOWN_REMOTE_ID', $biblionumber, $recordIdentifier, "<$f003>");
    }
}
sub addREMOTE_SEARCH_TOOMANYerror {
    my ($self, $searchParameters, $remoteName, $record, $biblio) = @_;
    my ($biblionumber, $recordIdentifier);
    ($record, $biblio, $biblionumber, $recordIdentifier) = $self->_parseParamRecordBiblio($record, $biblio);

    my @searchParameters; grep { unless ($_ eq 'id') {push @searchParameters, $searchParameters->{$_}} } keys %$searchParameters;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$recordIdentifier.". Too many $remoteName search results for this search! <@searchParameters>";
    } else {
        $self->_addErrorObject('REMOTE_SEARCH_TOOMANY', $biblionumber, $recordIdentifier, "<@searchParameters>", $remoteName);
    }
}
sub addREMOTE_SEARCH_NOTFOUNDerror {
    my ($self, $searchParameters, $remoteName, $record, $biblio) = @_;
    my ($biblionumber, $recordIdentifier);
    ($record, $biblio, $biblionumber, $recordIdentifier) = $self->_parseParamRecordBiblio($record, $biblio);

    my @searchParameters; grep { unless ($_ eq 'id') {push @searchParameters, $searchParameters->{$_}} } keys %$searchParameters;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$recordIdentifier.". No $remoteName search results for this search! <@searchParameters>";
    } else {
        $self->_addErrorObject('REMOTE_SEARCH_NOTFOUND', $biblionumber, $recordIdentifier, "<@searchParameters>", $remoteName);
    }
}
sub addBAD_ENCODINGerror {
    my ($self, $newRecordEncoding, $remoteName, $record, $biblio) = @_;
    my ($biblionumber, $recordIdentifier);
    ($record, $biblio, $biblionumber, $recordIdentifier) = $self->_parseParamRecordBiblio($record, $biblio);

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$recordIdentifier.". Bad encoding $newRecordEncoding";
    } else {
        $self->_addErrorObject('BAD_ENCODING', $biblionumber, $recordIdentifier, "<$newRecordEncoding>", $remoteName);
    }
}

sub popLastError {
    my ($self) = @_;
    return pop @{$self->{errors}};
}
sub countErrors {
    my $self = shift;
    return scalar( @{$self->{errors}} );
}
sub asText {
    my $self = shift;
    return (    join( "\n" , @{$self->{errors}} )    );
}
#Enforcing some formalness to the Error-"object" to make further processing more error-free
sub _addErrorObject {
    my ($self, $errcode, $biblionumber, $biblioname, $term, $remoteName) = @_;
    push (@{$self->{errors}}, { errcode => $errcode,
                                biblionumber => $biblionumber,
                                biblioname => $biblioname,
                                term => $term,
                                remotename => $remoteName,
                              });
}

sub _parseParamRecordBiblio {
    my ($self, $record, $biblio) = @_;

    $biblio = ($biblio) ? $biblio : $self->{activeBiblio};
    $record = ($record) ? $record : $self->{activeRecord};
    my $biblionumber = ($biblio) ? $biblio->{biblionumber} : '';
    my $recordIdentifier;
    if ($record) {
        $recordIdentifier = $record->author().' - '.$record->title();
    }
    return ($record, $biblio, $biblionumber, $recordIdentifier);
}
1; #Satisfying the compiler, we aim to please!