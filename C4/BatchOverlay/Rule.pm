package C4::BatchOverlay::Rule;

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
use Data::Dumper;

use C4::Biblio;
use Koha::Validation;

use Koha::Z3950Servers;

use Koha::Exception::BadParameter;
use Koha::Exception::BatchOverlay::UnknownSearchAlgorithm;
use Koha::Exception::BatchOverlay::UnknownMatcher;
use Koha::Exception::BatchOverlay::UnknownRemoteTarget;
use Koha::Exception::DuplicateObject;
use Koha::Exception::FeatureUnavailable;

sub new {
    my ($class, $params) = @_;
    my $self = _validateRule($params);
    bless $self, $class;
    $self->setRemoteFieldsDropped( $self->{remoteFieldsDropped} );
    $self->setDiffExcludedFields( $self->{diffExcludedFields} );
    $self->setNotifyOnChangeSubfields( $self->{notifyOnChangeSubfields} );
    $self->setNotificationEmails( $self->{notificationEmails} );
    return $self;
}

sub _validateRule {
    my ($rule) = @_;
    unless(ref($rule) eq 'HASH') {
        my @cc2 = caller(2);
        Koha::Exception::BadParameter->throw(error => $cc2[3]." is adding a '".__PACKAGE__."'-object but param is not a HASHref");
    }
    unless ($rule->{mergeMatcherCode}) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'matcherCode'. This is the Matcher used to match incoming records for overlay.");
    }
    unless ($rule->{componentPartMergeMatcherCode}) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'componentPartMergeMatcherCode'. This is the Matcher used to overlay the local component part with the remote component part if duplicate component parts exist.");
    }
    unless ($rule->{componentPartMatcherCode}) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'componentPartMatcherCode'. This is the Matcher used to match incoming component part records for overlay.");
    }
    unless ($rule->{remoteTargetCode}) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'remoteTargetCode'. This is the Z39.50 or a SRU server used to fetch records to overlay local records with.");
    }
    unless ($rule->{ruleName}) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'ruleName'. This is the name of the ruleset used to overlay the current record.");
    }
    unless (length($rule->{ruleName}) <= 20) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' directive 'ruleName' is longer than 20 characters and wont fit into the DB.");
    }
    unless ($rule->{searchAlgorithms} && ref($rule->{searchAlgorithms}) eq 'ARRAY' && scalar(@{$rule->{searchAlgorithms}})) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'searchAlgorithms' or it is an empty array. These are the prioritized algorithms used to try to find a remote record.");
    }
    unless ($rule->{candidateCriteria} && (ref($rule->{candidateCriteria}) eq 'HASH' && $rule->{candidateCriteria}->{lowlyCatalogued})) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'candidateCriteria' or it is not a proper hash with the mandatory key 'lowlyCatalogued'.");
    }
    unless (defined($rule->{dryRun})) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'dryRun'. This is used to define if overlay actions should persist to DB. This must be either 1 or 0.");
    }
    return $rule;
}

sub getRuleName {
    return shift->{ruleName};
}

=head getMergeMatcher
@RETURNS C4::Matcher which is configured to overlay a record. So we use that as a overlaying tool, instead of matching.
         C4::Matcher is superseded by MARC::Modification::Templates in the newest Koha version.
=cut

sub getMergeMatcher {
    my ($self) = (@_);

    if ($self->{mergeMatcher}) {
        return $self->{mergeMatcher};
    }
    $self->{mergeMatcher} = C4::Matcher->fetch(   C4::Matcher::GetMatcherId( $self->{mergeMatcherCode} )   );
    unless ($self->{mergeMatcher}) {
        Koha::Exception::BatchOverlay::UnknownMatcher->throw(error => "MergeMatcher '".$self->{mergeMatcherCode}."' not found");
    }
    return $self->{mergeMatcher};
}

=head getComponentPartMergeMatcher
@RETURNS C4::Matcher which is configured to overlay a record. So we use that as a overlaying tool, instead of matching.
         C4::Matcher is superseded by MARC::Modification::Templates in the newest Koha version.
=cut

sub getComponentPartMergeMatcher {
    my ($self) = (@_);

    if ($self->{componentPartMergeMatcher}) {
        return $self->{componentPartMergeMatcher};
    }
    $self->{componentPartMergeMatcher} = C4::Matcher->fetch(   C4::Matcher::GetMatcherId( $self->{componentPartMergeMatcherCode} )   );
    unless ($self->{componentPartMergeMatcher}) {
        Koha::Exception::BatchOverlay::UnknownMatcher->throw(error => "componentPartMergeMatcher '".$self->{componentPartMergeMatcherCode}."' not found");
    }
    return $self->{componentPartMergeMatcher};
}

=head getComponentPartMatcher
@RETURNS C4::Matcher which is configured to match for local records.
=cut

sub getComponentPartMatcher {
    my ($self) = (@_);

    if ($self->{componentPartMatcher}) {
        return $self->{componentPartMatcher};
    }
    $self->{componentPartMatcher} = C4::Matcher->fetch(   C4::Matcher::GetMatcherId( $self->{componentPartMatcherCode} )   );
    unless ($self->{componentPartMatcher}) {
        Koha::Exception::BatchOverlay::UnknownMatcher->throw(error => "componentPartMatcher '".$self->{componentPartMatcherCode}."' not found");
    }
    return $self->{componentPartMatcher};
}

sub getRemoteTarget {
    my ($self) = (@_);

    if ($self->{remoteTarget}) {
        return $self->{remoteTarget};
    }
    $self->{remoteTarget} = Koha::Z3950Servers->search({servername => $self->{remoteTargetCode}});
    unless ($self->{remoteTarget}->count) {
        Koha::Exception::BatchOverlay::UnknownRemoteTarget->throw(error => "Remote cataloguing source '".$self->{remoteTargetCode}."' not found. This should probably be a Z39.50 or a SRU server.");
    }
    if ($self->{remoteTarget}->count > 1) {
        Koha::Exception::DuplicateObject->throw(error => "Too many Z3950 servers found with search term\nservername:> ".$self->{remoteTargetCode}."\n");
    }
    $self->{remoteTarget} = $self->{remoteTarget}->next->unblessed;

    return $self->{remoteTarget};
}

=head

    my $searchRules = $rule->getSearchAlgorithms();

@RETURNS ARRAYref of Strings, the search algorithm subroutine names in priority order used when trying to fetch a remote record.
                 eg.[
                        'Control_number_identifier',
                        'Standard_identifier',
                    ]
@THROWS Koha::Exception::BatchOverlay::UnknownSearchAlgorithm if the search algorithm is not defined in C4::BatchOverlay::SearchAlgorithms

=cut

sub getSearchAlgorithms {
    my ($self) = (@_);

    if ($self->{searchAlgorithmsVerified}) {
        return $self->{searchAlgorithmsVerified};
    }
    foreach my $alg (@{$self->{searchAlgorithms}}) {
        my $fullName = "C4::BatchOverlay::SearchAlgorithms::$alg";
        unless (exists &{$fullName}) {
            Koha::Exception::BatchOverlay::UnknownSearchAlgorithm->throw(error => "Search algorithm '$alg' not defined. This must be defined in '$fullName'.");
        }
    }
    $self->{searchAlgorithmsVerified} = $self->{searchAlgorithms};
    return $self->{searchAlgorithmsVerified};
}
sub isDryRun {
    return 1 if shift->{dryRun} == 1;
    return 0;
}
sub setNotifyOnChangeSubfields {
    my ($self, $notifySubfieldsArray) = @_;

    if($notifySubfieldsArray && not(ref($notifySubfieldsArray) eq 'ARRAY')) {
        my @cc1 = caller(1);
        Koha::BadParameter->throw(error => $cc1[3]." is setNotifyOnChangeFields, but param \$notifySubfieldsArray '$notifySubfieldsArray' is not an ARRAYref");
    }
    unless ($notifySubfieldsArray) {
        $self->{notifySubfieldsArray} = [];
        return $self;
    }
    for( my $i=0 ; $i<scalar(@$notifySubfieldsArray) ; $i++) {
        Koha::Validation->tries('notifyOnChangeSubfields', $notifySubfieldsArray->[$i], 'marcSelector');
        $notifySubfieldsArray->[$i] = Koha::Validation::getMARCSelectorCache();
    }
    $self->{notifySubfieldsArray} = $notifySubfieldsArray;

    unless ($self->{notificationEmails}) {
        my @cc1 = caller(1);
        Koha::Exception::FeatureUnavailable->throw(error => $cc1[3]."():> System preference 'BatchOverlayRules' is missing directive 'notificationEmails'. This is mandatory if 'notifyOnChangeSubfields' is defined.");
    }

    return $notifySubfieldsArray;
}
sub setNotificationEmails {
    my ($self, $emails) = @_;
    Koha::Validation->tries('notificationEmails', $emails, 'email', 'a') if $emails;
    $self->{notificationEmails} = $emails;
}
sub getNotificationEmails {
    return shift->{notificationEmails};
}
sub setRemoteFieldsDropped {
    my ($self, $remoteFieldsDropped) = @_;
    if($remoteFieldsDropped && not(ref($remoteFieldsDropped) eq 'ARRAY')) {
        my @cc1 = caller(1);
        Koha::BadParameter->throw(error => $cc1[3]." is setRemoteFieldsDropped, but param \$remoteFieldsDropped '$remoteFieldsDropped' is not an ARRAYref");
    }
    unless ($remoteFieldsDropped) {
        $self->{remoteFieldsDropped} = [];
        return $self;
    }
    for( my $i=0 ; $i<scalar(@$remoteFieldsDropped) ; $i++) {
        $remoteFieldsDropped->[$i] = $self->_getFieldFromSelector( $remoteFieldsDropped->[$i] );
    }
    $self->{remoteFieldsDropped} = $remoteFieldsDropped;
    return $self;
}
sub getNotifyOnChangeSubfields {
    return shift->{notifySubfieldsArray}
}
sub getRemoteFieldsDropped {
    return shift->{remoteFieldsDropped};
}
sub getDiffExcludedFields {
    return shift->{diffExcludedFields};
}
sub setDiffExcludedFields {
    my ($self, $diffExcludedFields) = @_;
    if($diffExcludedFields && not(ref($diffExcludedFields) eq 'ARRAY')) {
        my @cc1 = caller(1);
        Koha::BadParameter->throw(error => $cc1[3]." is setDiffExcludedFields, but param \$diffExcludedFields '$diffExcludedFields' is not an ARRAYref");
    }
    unless ($diffExcludedFields) {
        $self->{diffExcludedFields} = [];
        return $self;
    }

    for( my $i=0 ; $i<scalar(@$diffExcludedFields) ; $i++) {
        $diffExcludedFields->[$i] = $self->_getFieldFromSelector( $diffExcludedFields->[$i] );
    }
    $self->{diffExcludedFields} = $diffExcludedFields;
    return $self;
}
sub getCandidateCriteria {
    return shift->{candidateCriteria};
}
sub _getFieldFromSelector {
    my ($self, $selector) = @_;
    if ($selector =~ /^[0-9.]{3}$/) { #a MARC field tag
        return $selector;
    }
    else {
        my ($selectorTag, $subfieldCode) = C4::Biblio::GetMarcFromKohaField($selector, '');
        unless ($selectorTag) {
            my @cc2 = caller(2);
            Koha::Exception::BadParameter->throw(error => $cc2[3]." is turning selector '$selector' to a MARC field code, but selector is not mapped to KohaToMARCMapping-table");
        }
        return $selectorTag;
    }
}
sub _getFieldSubfieldFromSelector {
    my ($self, $selector) = @_;
    if ($selector =~ /^([0-9.]{3})(\w)$/) { #a MARC field tag
        return ($1, $2);
    }
    else {
        my ($selectorTag, $subfieldCode) = C4::Biblio::GetMarcFromKohaField($selector, '');
        unless ($selectorTag && $subfieldCode) {
            my @cc2 = caller(2);
            Koha::Exception::BadParameter->throw(error => $cc2[3]." is turning selector '$selector' to a MARC field + sufield code, but selector is not mapped to KohaToMARCMapping-table");
        }
        return ($selectorTag, $subfieldCode);
    }
}

1; #Satisfying the compiler, we aim to please!
