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

sub addUNKNOWN_MATCHERerror {
    my ($self, $overlayRule) = @_;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "Couldn't find the merging matcher or a component part matcher with ids' <".$overlayRule->{matcher_id}."> and <".$overlayRule->{component_matcher_id}. ">. Extremely unsafe to proceed and halting.";
    } else {
        $self->_addErrorObject('UNKNOWN_MATCHER', '', '', '<'.$overlayRule->{matcher_id}.'> & <'.$overlayRule->{component_matcher_id}.'>');
    }
}
sub addUNKNOWN_REMOTE_IDerror {
    my ($self, $oldRecord, $oldBiblionumber, $f003) = @_;
    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$oldRecord->author().' - '.$oldRecord->title().". Couldn't find the correct bibliographic record source for biblionumber <$oldBiblionumber> based on the field 003 <$f003>. Currently BTJ and KV is supported.";
    } else {
        $self->_addErrorObject('UNKNOWN_REMOTE_ID', $oldBiblionumber, ($oldRecord->author().' - '.$oldRecord->title()), "<$f003>");
    }
}
sub addREMOTE_SEARCH_TOOMANYerror {
    my ($self, $remoteName, $oldRecord, $oldBiblio, $searchParameters) = @_;

    my @searchParameters; grep { unless ($_ eq 'id') {push @searchParameters, $searchParameters->{$_}} } keys %$searchParameters;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$oldRecord->author().' - '.$oldRecord->title().". Too many $remoteName search results for this search! <@searchParameters>";
    } else {
        $self->_addErrorObject('REMOTE_SEARCH_TOOMANY', $oldBiblio->{biblionumber}, ($oldRecord->author().' - '.$oldRecord->title()), "<@searchParameters>", $remoteName);
    }
}
sub addREMOTE_SEARCH_NOTFOUNDerror {
    my ($self, $remoteName, $oldRecord, $oldBiblio, $searchParameters) = @_;

    my @searchParameters; grep { unless ($_ eq 'id') {push @searchParameters, $searchParameters->{$_}} } keys %$searchParameters;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$oldRecord->author().' - '.$oldRecord->title().". No $remoteName search results for this search! <@searchParameters>";
    } else {
        $self->_addErrorObject('REMOTE_SEARCH_NOTFOUND', $oldBiblio->{biblionumber}, ($oldRecord->author().' - '.$oldRecord->title()), "<@searchParameters>", $remoteName);
    }
}
sub addBAD_ENCODINGerror {
    my ($self, $oldRecord, $oldBiblio, $newRecordEncoding, $remoteName) = @_;

    if ($self->{notHtmlOutput}) {
        push @{$self->{errors}}, "For record ".$oldRecord->author().' - '.$oldRecord->title().". Bad encoding $newRecordEncoding";
    } else {
        $self->_addErrorObject('BAD_ENCODING', $oldBiblio->{biblionumber}, ($oldRecord->author().' - '.$oldRecord->title()), "<$newRecordEncoding>", $remoteName);
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
1; #Satisfying the compiler, we aim to please!
