package Koha::FloatingMatrix;

# Copyright 2015 Vaara-kirjastot
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

=head1 FloatingMatrix

Koha::FloatingMatrix - Object to control accessing and modifying floating matrix rules.

=cut

use Modern::Perl;
use Carp qw(carp croak confess longmess);
use Scalar::Util qw(blessed refaddr);

use C4::Context qw(dbh);
use Koha::Caches;
use Koha::Database;

use Koha::FloatingMatrix::BranchRule;

use Koha::Exception::BadParameter;

my $cacheExpiryTime = 1200;

=head new

    my $fm = Koha::FloatingMatrix->new();

Finds a FloatingMatrix from Koha::Caches or instantiates a new one.

=cut

sub new {
    my ($class) = @_;

    my $cache = Koha::Caches->get_instance();
    my $fm = $cache->get_from_cache('floatingMatrix');
    unless ($fm) {
        $fm = {};
        bless $fm, $class;
        $fm->_getFloatingMatrix();
        $fm->_createModificationBuffer();
        $cache->set_in_cache('floatingMatrix', $fm, {expiry => $cacheExpiryTime});
    }
    return $fm if blessed($fm) && $fm->isa('Koha::FloatingMatrix');
    return undef;
}

sub _getFloatingMatrix {
    my ($fm) = @_;

    my $schema = Koha::Database->new()->schema();
    my @rules = $schema->resultset('FloatingMatrix')->search({});

    my %map;
    $fm->_setBranchRules( \%map );
    foreach my $rule (@rules) {
        my $branchRule = Koha::FloatingMatrix::BranchRule->newFromDBIx($rule);
        $fm->_linkBranchRule($branchRule);
    }
}

=head GetFloatingTypes
Static Method

    my $floatingTypes = Koha::FloatingMatrix::GetFloatingTypes();

@RETURNS Reference to ARRAY, of koha.floating_matrix.floating enumerations.
            These are all the available ways Items can float in Koha.
=cut

sub GetFloatingTypes {
    my $schema = Koha::Database->new()->schema();
    my $source = $schema->source('FloatingMatrix');
    my $info = $source->column_info('floating');
    my $floatingTypeEnumerations =  $info->{extra}->{list};
    return $floatingTypeEnumerations;
}

=head getFloatingTypes
    $fm->getFloatingTypes();
See. GetFloatingTypes()
=cut
sub getFloatingTypes {
    my ($fm) = @_;

    return $fm->{floatingTypes} if $fm->{floatingTypes};

    $fm->{floatingTypes} = Koha::FloatingMatrix::GetFloatingTypes();
    return $fm->{floatingTypes};
}

=head upsertBranchRule

    my ($branchRule, $error) = $fm->upsertBranchRule( $params );
    if ($error) {
        #I must have given some bad object properties
    }
    else {
        $fm->store();
    }

Adds or modifies an existing overduerule. Take note that this is only a local modification
for this instance of OverdueRulesMap-object.
If changes need to persists, call the $orm->store() method to save changes to DB.

@PARAM1, HASH, See Koha::Overdues::OverdueRule->new() for parameter descriptions.
@RETURN, Koha::Overdues::OverdueRule-object if success and
         String errorCode, if something bad hapened.

@THROWS Koha::Exception::BadParameter from Koha::FloatingMatrix::BranchRule->new().
=cut

sub upsertBranchRule {
    my ($fm, $params) = @_;

    my $branchRule = Koha::FloatingMatrix::BranchRule->new($params); #While creating this object we sanitate the parameters.

    my $existingBranchRule = $fm->_findBranchRule($branchRule);
    my $operation;
    if ($existingBranchRule) { #We are modifying an existing rule
        #Should we somehow tell that we are updating an existing rule?
        $existingBranchRule->replace($branchRule); #Replace with the new sanitated values, we preserve the internal data structure position.
        #Replacing might be less costly than recursively unlinking a large internal mapping.
        $branchRule = $existingBranchRule;
        $operation = 'MOD';
    }
    else { #Just adding more rules
        $fm->_linkBranchRule($branchRule);
        $operation = 'ADD';
    }

    $fm->_pushToModificationBuffer([$branchRule, $operation]);
    return $branchRule;
}

=head getBranchRule

    my $branchRule = $fm->getBranchRule( $fromBranch, $toBranch );

@PARAM1 String, koha.floating_matrix.from_branch, must give @PARAM2 as well
@PARAM2 String, koha.floating_matrix.to_branch, must give @PARAM1 as well
@RETURNS Koha::FloatingMatrix::BranchRule-object matching the params or undef.
=cut

sub getBranchRule {
    my ($fm, $fromBranch, $toBranch) = @_;

    my $branchRule = $fm->_findBranchRule(undef, $fromBranch, $toBranch);

    return $branchRule;
}

=head getBranchRules

    my $branchRules = $fm->getBranchRules();

@RETURNS Reference to a HASH of Koha::FloatingMatrix::BranchRule-objects
         Hash keys are <fromBranch>-<toBranch>, eg. FFL-CPL
=cut

sub getBranchRules {
    my ($fm) = @_;
    return $fm->{branchRules};
}

=head _setBranchRules
Needs to be called only from the _getFloatingMatrix() to bind the branchRules-map to this object.
@PARAM1, Reference to HASH.
=cut

sub _setBranchRules {
    my ($fm, $hash) = @_;
    $fm->{branchRules} = $hash;
}

sub checkFloating {
    my ($fm, $item, $checkinBranch, $transferTargetBranch) = @_;
    unless ($transferTargetBranch) { #If no transfer branch is given, then we try our best to figure it out.
        my $branchItemRule = C4::Circulation::GetBranchItemRule($item->{'homebranch'}, $item->{'itype'});
        my $returnBranchRule = $branchItemRule->{'returnbranch'} || "homebranch";
        # get the proper branch to which to return the item
        $transferTargetBranch = $item->{$returnBranchRule} || C4::Context->userenv->{'branch'};
    }

    #If the check-in branch and transfer branch are the same, then no point in transferring.
    if ($checkinBranch eq $transferTargetBranch) {
        return undef;
    }

    my $branchRule = $fm->getBranchRule($checkinBranch, $transferTargetBranch);
    if ($branchRule) {
        my $floating = $branchRule->getFloating();
        if ($floating eq 'ALWAYS') {
            return 'ALWAYS';
        }
        elsif ($floating eq 'POSSIBLE') {
            return 'POSSIBLE';
        }
        elsif ($floating eq 'CONDITIONAL') {
            if(_CheckConditionalFloat($item, $branchRule)) {
                return 'ALWAYS';
            }
        }
        else {
            warn "FloatingMatrix->checkFloating():> Bad floating type for route from '$checkinBranch' to '$transferTargetBranch'. Not floating.\n";
        }
    }
    return undef;
}

=head _CheckConditionalFloat
Static method

@PARAM1, HASH of koha.items-row
@PARAM2, Koha::FloatingMatrix::BranchRule-object
@RETURNS 1 if floats, undef if not.
=cut

sub _CheckConditionalFloat {
    my ($item, $branchRule) = @_;

    my $evalCondition = $branchRule->getConditionRulesParsed();

    # $item must be in the current scope, as it is hard-coded into the eval'ld condition
    my $ok = eval("return 1 if($evalCondition);");
    if ($@) {
        warn "Koha::FloatingMatrix::_CheckConditionalFloat():> Something bad hapened when trying to evaluate the dynamic conditional: '$evalCondition'\n\n$@\n";
        return undef;
    }
    return $ok;
}

=head CheckFloating
Static Subroutine

A convenience Subroutine to checkFloating without intantiating a new Koha::FloatingMatrix-object
=cut

sub CheckFloating {
    my ($item, $checkinBranch, $transferTargetBranch) = @_;
    my $fm = Koha::FloatingMatrix->new();
    return $fm->checkFloating($item, $checkinBranch, $transferTargetBranch);
}

=head _findBranchRule

    my $branchRule = $fm->_findBranchRule( undef, $fromBranch, $toBranch );
    my $existingBranchRule = $fm->_findBranchRule( $branchRule );

Finds a branch rule from the internal floating matrix map.

This abstracts the retrieval of branch rules, so we can later change the internal mapping.
@PARAM1, Koha::FloatingMatrix::BranchRule-object, to see if a BranchRule with same targeting rules is present.
         or undef, if you are only interested in retrieving.
@PARAM2-3, MANDATORY if no @PARAM1 given, Targeting rules to find a BranchRule.
@RETURNS Koha::FloatingMatrix::BranchRule-object, of the object occupying the given position.
         or undef if nothing is found.
=cut

sub _findBranchRule {
    my ($fm, $branchRule, $fromBranch, $toBranch) = @_;
    if (blessed($branchRule) && $branchRule->isa('Koha::FloatingMatrix::BranchRule')) {
        $fromBranch = $branchRule->getFromBranch();
        $toBranch   = $branchRule->getToBranch();
    }

    my $existingBranchRule = $fm->getBranchRules()->{  $fromBranch  }->{  $toBranch  };
    return $existingBranchRule;
}

=head _linkBranchRule

    my $existingBranchRule = $fm->_linkBranchRule( $branchRule );

Links the new branchrule to the internal floating matrix map, overwriting a possible existing
reference to a BranchRule, and losing that into the binary limbo.

This abstracts the retrieval of floating matrix routes, so we can later change the internal mapping.
@PARAM1, Koha::FloatingMatrix::BranchRule-object, to link to the internal mapping
=cut

sub _linkBranchRule {
    my ($fm, $branchRule) = @_;

    $fm->{branchRules}->{  $branchRule->getFromBranch()  }->{  $branchRule->getToBranch()  } = $branchRule;
}

=head _unlinkBranchRule

    my $existingBranchRule = $fm->_unlinkBranchRule( $branchRule );

Unlinks the branchRule from the internal floating matrix map and releasing it into the binary limbo.

This abstracts the internal mapping of branch rules, so we can later change it.
@PARAM1, Koha::FloatingMatrix::BranchRule-object

=cut

sub _unlinkBranchRule {
    my ($fm, $branchRule) = @_;

    #Delete the BranchRule
    my $branchRules = $fm->getBranchRules();
    my $fromBranch = $branchRule->getFromBranch();
    my $toBranch = $branchRule->getToBranch();

    eval{ delete( $branchRules->{  $fromBranch  }->{  $toBranch  } ); };
    if ($@) {
        carp "Unlinking BranchRule failed because of '".$@."'. Something wrong with this BranchRule\n".$branchRule->toString()."\n";
        return $@;
    }

    unless (scalar(%{$branchRules->{  $fromBranch  }})) {
        #Delete the branchLevel
        delete( $branchRules->{  $fromBranch  } );
    }
}

=head deleteBranchRule

    $fm->deleteBranchRule($branchRule);
    $fm->deleteBranchRule($fromBranch, $toBranch);

Deletes the BranchRule from the internal mapping, but not from the DB.
Call $fm->store() to persist the removal.

The given $branchRule must be the same object gained using $fm->getBranchRule(),
or you are misusing the FloatingMatrix-object and bad things might happen.

@PARAM1, Koha::FloatingMatrix::BranchRule-object to delete from DB.
or
@PARAM1 {String, koha.floating_matrix.from_branch}
@PARAM1 {String, koha.floating_matrix.to_branch}

@THROWS Koha::Exception::BadParameter if no branchRule, with the given parameters, is found,
                or the given BranchRule doesn't match the one in the internal mapping.
=cut

sub deleteBranchRule {
    my ($fm, $fromBranch, $toBranch) = @_;
    my ($branchRule, $branchRuleLocal);
    #Process given parameters, see if we use parameter group1 (BranchRule-object) or group2 (branchcodes)?
    if (blessed $fromBranch && $fromBranch->isa('Koha::FloatingMatrix::BranchRule')) {
        $branchRule = $fromBranch;
        $fromBranch = $branchRule->getFromBranch();
        $toBranch = $branchRule->getToBranch();
    }

    $branchRuleLocal = $fm->getBranchRule($fromBranch, $toBranch);
    Koha::Exception::BadParameter->throw(error => "Koha::FloatingMatrix->deleteBranchRule($fromBranch, $toBranch):> No BranchRule exists for the given fromBranch '$fromBranch' and toBranch '$toBranch'")
                unless $branchRuleLocal;

    $fm->_unlinkBranchRule(  $branchRuleLocal  );
    $fm->_pushToModificationBuffer([$branchRuleLocal, 'DEL']);
}

=head $fm->deleteAllFloatingMatrixRules()

Deletes all Floating matrix rules in the DB, shows no pity.
Invalidates $fm in the Koha::Caches
=cut

sub deleteAllFloatingMatrixRules {
    my ($fm) = @_;
    my $schema = Koha::Database->new()->schema();
    $schema->resultset('FloatingMatrix')->search({})->delete_all;
    $fm = undef;

    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache('floatingMatrix');
}

=head store

    $fm->store();

Saves all pending transactions to DB, by calling the Koha::FloatingMatrix::BranchRule->store() || delete();

=cut

sub store {
    my $fm = shift;
    my $schema = Koha::Database->new()->schema();

    my $pendingModifications = $fm->_consumeModificationBuffer();
    foreach my $modRequest (@$pendingModifications) {
        my $branchRule = $modRequest->[0];
        my $operation = $modRequest->[1];
        if ($operation eq 'MOD' || $operation eq 'ADD') {
            $branchRule->store();
        }
        elsif ($operation eq 'DEL') {
            $branchRule->delete();
        }
        else {
            carp "Unsupported database access operation '$operation'!";
        }
    }

    my $cache = Koha::Caches->get_instance();
    $cache->set_in_cache('floatingMatrix', $fm, {expiry => $cacheExpiryTime});
}

=head _pushToModificationBuffer

    $fm->_pushToModificationBuffer([$branchRule, $operation]);

To be able to more effectively service DB write operations, especially when using
FloatingMatrix with an REST(ful?) API giving lots of write operations, it is useful
to be able to know which BranchRules need changing and which do not.
Thus we don't need to either
DELETE all BranchRules from DB and re-add them (what if the rewrite request dies?)
  or
check each rule for possible changes.

The modification buffer tells what information needs changing.

To write the changes to DB, use $fm->store().

@PARAM1, Tuple (Two-index ARRAY reference). [0] = $branchRule (see. upsertBranchRule())
                                            [1] = The operation, either 'ADD', 'MOD' or 'DEL'
@RETURN, always nothing.

=cut

sub _pushToModificationBuffer {
    my ($fm, $tuple) = @_;
    push @{$fm->{modBuffer}}, $tuple;
    return undef;
}
=head _consumeModificationBuffer
Detaches the modification buffer from the FloatingMatrix (parent) and returns it.
Fm now has an empty modification buffer ready for new modifications.
=cut

sub _consumeModificationBuffer {
    my ($fm) = @_;
    my $modBuffer = $fm->{modBuffer};
    $fm->{modBuffer} = [];
    return $modBuffer;
}
sub _createModificationBuffer {
    my ($fm) = @_;
    $fm->{modBuffer} = [];
    return undef;
}

1; #Satisfy the compiler
