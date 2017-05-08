package C4::BatchOverlay::RuleManager;

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
use Encode;
use YAML::XS;
use Hash::Merge::Simple;
use Storable;

use C4::Matcher;
use C4::Breeding;
use C4::BatchOverlay::Rule;

use Koha::Exception::BadParameter;
use Koha::Exception::FeatureUnavailable;
use Koha::Exception::BatchOverlay::UnknownMatcher;
use Koha::Exception::BatchOverlay::UnknownRemoteTarget;

=head2 new

    C4::BatchOverlay::RuleManager->new({
        #The Perlized BatchOverlayRules-syspref YAML
        #Pass this to skip loading it from db, but not validating it
        #WARNING! The given HASHRef is mangled and altered. If you want to preserve the existing data structure, pass a copy.
        BatchOverlayRules => {...}
    });

=cut

sub new {
    my ($class, $params) = @_;
    my $self = (ref($params) eq 'HASH') ? $params : {};
    bless $self, $class;

    $self->_loadBatchOverlayRules($params->{BatchOverlayRules});

    return $self;
}

=head2 loadRules
@STATIC

Warning fetching the syspref with this skips critical validations. Do not use
rules fetched with this subroutine to do batch overlaying!

@RETURNS Hashref of config
@THROWS Koha::Exception::FeatureUnavailable if there is something wrong with turning
                                            the syspref BatchOverlayRules to YAML

=cut

sub loadRules {
    my $yaml = Encode::encode_utf8(C4::Context->preference('BatchOverlayRules'));
    unless ($yaml) {
        my @cc = caller(0);
        Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> System preference 'BatchOverlayRules' is undefined. You must define it to use the BatchOverlay-feature.");
    }
    my $config;
    eval {
        $config = YAML::XS::Load($yaml);
    };
    if ($@) {
        my @cc = caller(0);
        Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> System preference 'BatchOverlayRules' is not proper YAML. YAML::XS error: '$@'");
    }
    return $config;
}

=head2 _storeRules

Persists Rules to BatchOverlayRules-syspref. Make sure you validate them beforehand!

=cut

sub _storeRules {
    my ($rules) = @_;

    my $yaml = YAML::XS::Dump($rules);
    C4::Context->set_preference('BatchOverlayRules', $yaml);
}

=head2 _loadBatchOverlayRules

Validates that the configurations have been configured properly

=cut

sub _loadBatchOverlayRules {
    my ($self, $existingRules) = @_;

    my $config;
    if ($existingRules) {
        $config = $existingRules;
    }
    else {
        $config = loadRules();
    }

    my $globals = {};
    my $defaultMissing = 1;
    foreach my $key (keys %$config) {
        if ($key =~ /^_excludeExceptions/) { #These are global directives
            $globals->{$key} = $config->{$key};
            delete $config->{$key};
        }
        else {
            unless (ref($config->{$key}) eq 'HASH') {
                my @cc = caller(0);
                Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> ".
                    "System preference 'BatchOverlayRules', given Ruleset name '$key' is not a HASH reference. For an example, see the 'default' Ruleset.");
            }
            $config->{$key}->{ruleName} = $key;
            $config->{$key} = C4::BatchOverlay::Rule->new( $config->{$key} );

            $defaultMissing = 0 if $key eq 'default';
        }
    }
    if ($defaultMissing) {
        my @cc = caller(0);
        Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> System preference 'BatchOverlayRules' is missing 'default' ruleset");
    }
    $self->{globals} = $globals;
    $self->{rules} = $config;

    unless (ref($globals->{_excludeExceptions}) eq 'ARRAY') {
        my @cc = caller(0);
        Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> System preference 'BatchOverlayRules' directive '_excludeExceptions' '".$globals->{_excludeExceptions}."' is not an array of exception names.");
    }

    try {
        C4::Biblio::GetMarcKohaFramework(MARC::Record->new()); #If this doesn't die, KohaToMarcMapping is properly set.
    } catch {
        my @cc = caller(0);
        Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> $_");
    };
}

=head2 alterAllRules
@STATIC

    ##Add a remote target to the default rule
    C4::BatchOverlay::RuleManager::alterAllRules({
        default => {
            remoteTargetCode => 'Z39.50_SERVER',
        }
    });

Update existing 'BatchOverlayRules'-syspref or create a new one.

Given a HASHRef of BatchOverlayRules-like syntax, deeply replaces existing fields
and adds new fields where missing.
Persists changes to DB if validation succeeds.

@PARAM1 HASHRef of BatchOverlayRules-like syntax
@RETURNS HASHRef of the mashed BatchOverlayRules
@THROWS Koha::Exception::BadParameter if validating the BatchOverlayRules-YAML
        fails after doing the modifications.

=cut

sub alterAllRules {
    my ($newRules) = @_;

    my $rules = loadRules();

    #Mash them together
    my $mashedRules = Hash::Merge::Simple::merge($rules, $newRules);

    #Clone the $mashedRules, because the RuleManager mangles the given HASHRef
    my $clone = Storable::dclone($mashedRules);
    #Instantiate a new RuleManager to see the config validates
    my $rm = C4::BatchOverlay::RuleManager->new({BatchOverlayRules => $mashedRules});
    _storeRules($clone);
    return $clone;
}

=head getAllRules

    my $rules = $ruleManager->getAllRules();

@RETURNS HashRef of C4::BatchOverlay::Rule-objects keyed using the rule name, including 'default'.

=cut

sub getAllRules {
    my ($self) = @_;

    return $self->{rules};
}

=head getRule

    my $rule = $ruleManager->getRule($MARC::Record);

@RETURNS C4::BatchOverlay::Rule matching the given MARC::Record

=cut

sub getRule {
    my ($self, $localRecord) = @_;
    my $ruleName = $self->getRuleNameFromRecord($localRecord);

    return $self->getRuleFromRuleName($ruleName);
}

=head getRuleNameFromRecord

    my $ruleName = $ruleManager->getRuleNameFromRecord($MARC::Record);

@RETURNS String, ruleName, deciphered from the mystical rules which the given record matches.

=cut

sub getRuleNameFromRecord {
    my ($self, $localRecord) = @_;

    unless (blessed($localRecord) && $localRecord->isa('MARC::Record')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($localRecord):> Param \$localRecord '$localRecord' is not a MARC::Record");
    }

    #TODO: One can check here what ruleset to use for this particular record.
    #We could possibly want to use a different Z39.50 server to overlay musical records,
    #one to overlay DVD's, or maybe pick a target depending on the field 003?
    #If you need to extend this functionality, do it here.

    #Cache the possible complex calculations and return the correct ruleset. Configured objects are later attached to the ruleset and by caching we avoid fetching them many times from the db.
    my $ruleName = "default";
    return $ruleName;
}

=head getRuleFromRuleName

    my $ruleName = $ruleManager->getRuleFromRuleName($ruleName);

@RETURNS C4::BatchOverlay::Rule matching the given ruleName

=cut

sub getRuleFromRuleName {
    my ($self, $ruleName) = @_;

    if ($self->{_rulesCache}->{$ruleName}) {
        return $self->{_rulesCache}->{$ruleName};
    }
    unless ($self->{rules}->{$ruleName}) {
        my @cc = caller(0);
        Koha::Exception::FeatureUnavailable->throw(error => $cc[3]."():> System preference 'BatchOverlayRules' is missing definitions for the '$ruleName' ruleset.");
    }
    $self->{_rulesCache}->{$ruleName} = $self->{rules}->{$ruleName};

    return $self->{_rulesCache}->{$ruleName};
}

=head2 getExcludedExceptions

    my $ee = $self->getExcludedExceptions();

@returns ArrayRef of exception classes not meant to be displayed by default

=cut

sub getExcludedExceptions {
    my ($self) = @_;
    return $self->{globals}->{_excludeExceptions};
}

=head testRemoteTargetConnections

    my $rm = C4::BatchOverlay::RuleManager->new();
    my $errDescs = $rm->testRemoteTargetConnections();

@RETURNS ArrayRef of Strings, Error descriptions connecting to remote search targets.

=cut

sub testRemoteTargetConnections {
    my ($self) = @_;

    my @statuses;
    my $overlayRules = $self->getAllRules();
    foreach my $key (keys %$overlayRules) {
        my $overlayRule = $overlayRules->{$key};
        my $remoteTarget = $overlayRule->getRemoteTarget();

        my $z3950results = {};
        C4::Breeding::Z3950Search({id => [$remoteTarget->{id}],
                                   title => 'xF53ASDg45Fxgt67Gth23rEtyy', #this shouldn't match anything
                                   }, $z3950results, 'getAll');

        my $status = {
            ruleName => $key,
            server => $remoteTarget->{name},
        };

        if (scalar(@{$z3950results->{errconn}})) {
            my @errDescs;
            push @errDescs, map {C4::Breeding::translateZOOMError($_->{error})} @{$z3950results->{errconn}};
            $status->{errors} = \@errDescs;
        }
        push @statuses, $status;
    }
    return \@statuses;
}

sub testDryRun {
    my ($self) = @_;

    my @statuses;
    my $overlayRules = $self->getAllRules();
    foreach my $key (keys %$overlayRules) {
        my $overlayRule = $overlayRules->{$key};
        my $dryRun = $overlayRule->isDryRun();
        my $status = {
            ruleName => $key,
            dryRun => $dryRun,
        };
        push @statuses, $status;
    }
    return \@statuses;
}

1; #Satisfying the compiler, we aim to please!
