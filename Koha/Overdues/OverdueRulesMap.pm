package Koha::Overdues::OverdueRulesMap;

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

=head1 OverdueRulesMap

Koha::Overdues::OvedueRulesMap - Object to control accessing and modifying overdue rules.

=head1 DESCRIPTION

OverdueRulesMap (orm) is a gateway to CRUD:ing the Koha overdue rules.
You can use it to conveniently fetch overdue rules for certain queued messages, or
help in generating overdue notifications.
Also it is possible to create automated tests for orm more conveniently.

It uses
-Koha::Cache to quickly persist and retrieve itself.
-DBIx, to handle DB transactions
-Smart internal persistence operations buffer to make small overdue rule updates fast
-Abstracted layer of data retrieval designed to ease mainenance when database structure changes.
-Abstracted layer of internal mappings, designed for change.

It doesn't use
-Koha::Object, because orm is not a direct database table representation, but a gateway for
               managing a complex set of overdue rules.

=cut

use Modern::Perl;
use Carp qw(carp croak confess longmess);
use Scalar::Util 'blessed';

use C4::Context qw(dbh);
use Koha::Caches;
use Koha::Database;

use Koha::MessageQueue;
use Koha::MessageQueues;

use Koha::Overdues::OverdueRule;
=head new

    my $orm = Koha::Overdues::OverdueRulesMap->new();

Finds a OverdueRulesMap from Koha::Cache or instantiates a new one.

OverdueRulesMap (orm) is a map-representation of the overduerules- and
overduerules_transport_types-tables.
The cache entry is valid for 300 seconds.

See getRulesForBranch() for structural representation.
=cut

sub new {
    my ($class) = @_;

    my $cache = Koha::Caches->get_instance();
    my $orm = $cache->get_from_cache('overdueRulesMap');
    unless ($orm) {
        $orm = {};
        bless $orm, $class;
        $orm->_getOverdueRulesMap();
        $orm->_createModificationBuffer();
        $cache->set_in_cache('overdueRulesMap', $orm, {expiry => 300});
    }
    return $orm if ref $orm eq 'Koha::Overdues::OverdueRulesMap';
    return undef;
}

=head getRulesForBranch

    my $overduerules = $orm->getRulesForBranch('CPL');

Finds the overduerules and messageTransportTypes for the given branch.
If the branch has even one overduerule defined for a borrower category,
  will use that and skip checking for any defaults even for the missing
  borrower categories.
If the branch has no overduerules defined, will use the default rules.

@RETURNS Hash, of overduerules for the given branch. The HASH looks like this:
        {
            STAFF => {  #Borrower Categories
                1 => {  #Letter numbers
                    Koha::Overdues::OverdueRule-object
                },
                2 => {..},
                ...
            },
            PATRON => {...},
            ...
        }
=cut

sub getRulesForBranch {
    my ($orm, $branchCode) = @_;

    return $orm->{map}->{$branchCode} if $orm->{map}->{$branchCode};
    return $orm->{map}->{''};
}

=head getLetterCodesForNumber

    my $letters = $orm->getLetterCodesForNumber(1);

Finds all the used letter-template codes for the given overdue letter number.
These results are cached and the cache is invalidated when the internal mapping changes.
@PARAM1, Int, the overdue notification number.
@PARAM2, Boolean, '1' or undef. Should the return value be a reference to HASH (1)
                 or to an ARRAY (undef). Defaults to ARRAY.
@RETURNS Reference to a List of Strings,
=cut

sub getLetterCodesForNumber {
    my ($orm, $letterNumber, $asHash) = @_;

    #Check for cache.
    if ($orm->{letterCodes}->{$letterNumber}) {
        return $orm->{letterCodes}->{$letterNumber} if $asHash;
        return [sort keys %{$orm->{letterCodes}->{$letterNumber}}];
    }

    my $letters = {};
    foreach my $branchCode (keys %{$orm->{map}}) {
        my $branchRules = $orm->{map}->{$branchCode};
        foreach my $borrowerCategory (keys %$branchRules) {
            my $borCatRules = $branchRules->{$borrowerCategory};
            my $overdueRule = $borCatRules->{$letterNumber};
            next unless (blessed($overdueRule)); #we are expecting an OverdueRule

            my $letterCode = $overdueRule->{letterCode};
            $letters->{ $letterCode } = 1 unless $letters->{ $letterCode }; #Set it if it hasn't been found
        }
    }
    $orm->{letterCodes}->{$letterNumber} = $letters; #Cache the calculations.
    return $letters if ($asHash); #Return the hash if desired
    return [sort keys %$letters]; #otherwise return the ARRAY representation.
}

=head getLetterCodes

    my $letterCodes = $orm->getLetterCodes();

Gets all the letter codes used to generate overdue notifications.
This is a very strong indicator that letters generated using these letter templates
are overdue notifications.
These results are cached and the cache is invalidated when the internal mapping changes.

@RETURNS, List of Strings representing message_queue.letter_code
=cut

sub getLetterCodes {
    my ($orm) = @_;

    #Check for cache.
    if ($orm->{letterCodes}->{all}) {
        return [keys %{$orm->{letterCodes}->{all}}];
    }

    my %letterCodes;
    my $letterNumbers = $orm->getOverdueNotificationLetterNumbers();
    for (my $i=1 ; $i<=$letterNumbers ; $i++) {
        my $letterCodesForNumber = $orm->getLetterCodesForNumber($i, 1); #Get them as hash for easy deduplication.
        foreach my $letter_code (keys %$letterCodesForNumber) {
            $letterCodes{$letter_code} = 1;
        }
    }

    $orm->{letterCodes}->{all} = \%letterCodes; #Cache the calculations.

    return [keys %letterCodes];
}

=head getLastOverdueRules

    my $overdueRules = $orm->getLastOverdueRules();

Returns the Koha::Overdues::OverdueRule-objects that have the biggest sending
delay (koha.overduerules.delay*).
@RETURNS Arrayref of references to a Koha::Overdues::OverdueRule-objects
         all sharing the same biggest delay.

=cut

sub getLastOverdueRules {
    my ($orm) = @_;

    #Check for cache.
    if ($orm->{lastOverdueRules}) {
        return $orm->{lastOverdueRules};
    }

    #Find all the OverdueRules sharing the biggest delay.
    my $maxDelay = 0;
    my $lastOverdueRules = [];
    foreach my $branchCode (keys %{$orm->{map}}) {
        my $branchRules = $orm->{map}->{$branchCode};
        foreach my $borrowerCategory (keys %$branchRules) {
            my $borCatRules = $branchRules->{$borrowerCategory};
            foreach my $letterNumber (keys %$borCatRules) {
                my $overdueRule = $borCatRules->{$letterNumber};
                next unless (blessed($overdueRule)); #we are expecting an OverdueRule

                if ($overdueRule->{delay} > $maxDelay) {
                    $maxDelay = $overdueRule->{delay};
                    $lastOverdueRules = [$overdueRule];
                }
                elsif ($overdueRule->{delay} == $maxDelay) {
                    push @$lastOverdueRules, $overdueRule;
                }
            }
        }
    }
    $orm->{lastOverdueRules} = $lastOverdueRules;
    return $lastOverdueRules;
}

=head getLastOverdueRuleDelay

@RETURNS Integer, how big is the biggest delay for all the overdue rules?
         or undef.

=cut

sub getLastOverdueRuleDelay {
    my ($orm) = @_;

    #lookback defaults to the biggest available delay in the overduerules-table.
    my $lastOverdueRules = $orm->getLastOverdueRules();
    my $lastOverdueRule = $lastOverdueRules->[0] if $lastOverdueRules;
    return $lastOverdueRule->{delay} if $lastOverdueRule;
}

=head getBorrowerCategories

    my $letters = $orm->getBorrowerCategories();

Finds all the used Borrower category codes in the overduerules-map.
@RETURNS Reference to a List of Strings,
=cut

sub getBorrowerCategories {
    my ($orm, $letterNumber) = @_;

    my $borCats = {};
    foreach my $branchCode (keys %{$orm->{map}}) {
        my $branchRules = $orm->{map}->{$branchCode};
        foreach my $borrowerCategory (keys %$branchRules) {
            $borCats->{ $borrowerCategory } = 1 unless $borCats->{ $borrowerCategory };
        }
    }
    return [sort keys %$borCats];
}

=head getOverdueNotificationLetterNumbers

    my $overdueLetterNumbers = $orm->getOverdueNotificationLetterNumbers()

@RETURNS, Integer, how many overdueletters are configured to be sent?

Currently the hard-coded value is 3, but this subroutine can be easily changed
to support variable amount of overdue notifications if that some day gets
extended.
=cut

sub getOverdueNotificationLetterNumbers {
    my $orm = shift;

    #Bear in mind that the $orm-object might not be initialized and can be an empty blessed reference!
    unless (scalar(%$orm)) {
        #Find the maximum letters count from the DB
        return 3;
    }
    #Calculate the maximum overdue letters count from the OverdueRulesMap $orm.
    return 3;
}

=head getOverdueRule

    my $overdueRule = $orm->getOverdueRule( $branchCode, $borrowerCategory, $letterNumber );

@PARAM1 String, koha.branches.branchcode. If undef, then uses the default branch ''.
              If nothing is found with the given branchCode, then returns the default rules.
@PARAM2 String, koha.categories.categorycode.
@PARAM3 Int, one of koha.overduerules' letternumbers.
@RETURNS Koha::Overdues::OverdueRule-object
=cut

sub getOverdueRule {
    my ($orm, $branchCode, $borrowerCategory, $letterNumber) = @_;

    unless ($branchCode) {
        $branchCode = '';
    }
    my $overdueRule = $orm->_findOverdueRule( undef, $branchCode, $borrowerCategory, $letterNumber );
    return $overdueRule;
}

sub getOverdueRuleOrDefault {
    my ($orm, $branchCode, $borrowerCategory, $letterNumber) = @_;

    unless ($branchCode) {
        $branchCode = '';
    }

    my $overdueRule = $orm->_findOverdueRule( undef, $branchCode, $borrowerCategory, $letterNumber );
    if (not($overdueRule) && $branchCode ne '') { #Look for the default as well
        $overdueRule = $orm->_findOverdueRule( undef, '', $borrowerCategory, $letterNumber );
    }
    return $overdueRule;
}

sub getPreviousOverdueRule {
    my ($orm, $overdueRule) = @_;

    my $previousOverdueRule = $orm->_findOverdueRule( undef, $overdueRule->{branchCode}, $overdueRule->{borrowerCategory}, $overdueRule->{letterNumber}-1 );
    return $previousOverdueRule;
}

=head _findOverdueRule

    my $overdueRule = $orm->_findOverdueRule( undef, $branchCode, $borrowerCategory, $letterNumber );
    my $existingOverdueRule = $orm->_findOverdueRule( $overdueRule );

Finds an overduerule from the internal overdue map.

This abstracts the retrieval of overdue rules, so we can later change the internal mapping.
@PARAM1, Koha::Overdues::OverdueRule-object, to see if an OverdueRule with same targeting rules is present.
         or undef, if you are only interested in retrieving.
@PARAM2-4, MANDATORY if no @PARAM1 given, Targeting rules to find a OverdueRule.
@RETURNS Koha::Overdues::OverdueRule-object, of the object occupying the given position.
         or undef if nothing is found.
=cut

sub _findOverdueRule {
    my ($orm, $overdueRule, $branchCode, $borrowerCategory, $letterNumber) = @_;
    $branchCode       = $overdueRule->{branchCode}       if $overdueRule->{branchCode};
    $borrowerCategory = $overdueRule->{borrowerCategory} if $overdueRule->{borrowerCategory};
    $letterNumber     = $overdueRule->{letterNumber}     if $overdueRule->{letterNumber};

    my $existingOverduerule = $orm->{map}->{  $branchCode  }->{  $borrowerCategory  }->{  $letterNumber  };
    return $existingOverduerule;
}

=head _linkOverdueRule

    my $existingOverdueRule = $orm->_linkOverdueRule( $overdueRule );

Links the new overduerule to the internal overdue map, overwriting a possible existing
reference to a OverdueRule, and losing that into the binary limbo.

This abstracts the retrieval of overdue rules, so we can later change the internal mapping.
@PARAM1, Koha::Overdues::OverdueRule-object, to link to the internal mapping
@RETURNS undef, if all is OK and the object has been linked.
=cut

sub _linkOverdueRule {
    my ($orm, $overdueRule) = @_;

    $orm->{map}->{  $overdueRule->{branchCode}  }->{  $overdueRule->{borrowerCategory}  }->{  $overdueRule->{letterNumber}  } = $overdueRule;
}

=head _unlinkOverdueRule

    my $existingOverdueRule = $orm->_linkOverdueRule( $overdueRule );

Unlinks the overduerule from the internal overdue map and releasing it into the binary limbo.

This abstracts the retrieval of overdue rules, so we can later change the internal mapping.
@PARAM1, Koha::Overdues::OverdueRule-object
@RETURNS undef, if all is OK and the object linking has has been succesfully deleted
         String of error if operation failed.
=cut

sub _unlinkOverdueRule {
    my ($orm, $overdueRule) = @_;

    #Delete the OverdueRule on the letterNumberLevel
    eval{ delete( $orm->{map}->{  $overdueRule->{branchCode}  }->{  $overdueRule->{borrowerCategory}  }->{  $overdueRule->{letterNumber}  } ); };
    if ($@) {
        carp "Unlinking OverdueRule failed because of '".$@."'. Something wrong with this OverdueRule\n".$overdueRule->toString()."\n";
        return $@;
    }

    unless (scalar(%{$orm->{map}->{  $overdueRule->{branchCode}  }->{  $overdueRule->{borrowerCategory}  }})) {
        #Delete the borrowerCategoryLevel
        delete( $orm->{map}->{  $overdueRule->{branchCode}  }->{  $overdueRule->{borrowerCategory}  } );

        unless (scalar(%{$orm->{map}->{  $overdueRule->{branchCode}  }})) {
            #Delete the branchLevel
            delete( $orm->{map}->{  $overdueRule->{branchCode}  } );
        }
    }
}

=head upsertOverdueRule

    my ($overdueRule, $error) = $orm->upsertOverdueRule( $params );
    if ($error) {
        #I must have given some bad object properties
    }
    else {
        $orm->store();
    }

Adds or modifies an existing overduerule. Take note that this is only a local modification
for this instance of OverdueRulesMap-object.
If changes need to persists, call the $orm->store() method to save changes to DB.

@PARAM1, HASH, See Koha::Overdues::OverdueRule->new() for parameter descriptions.
@RETURN, Koha::Overdues::OverdueRule-object if success and
         String errorCode, if something bad hapened.

         See Koha::Overdues::OverdueRule->new() for error code definitions.
=cut

sub upsertOverdueRule {
    my ($orm, $params) = @_;
    my ($overdueRule, $error) = Koha::Overdues::OverdueRule->new($params); #While creating this object we sanitate the parameters.
    return (undef, $error) if $error;

    my $existingOverdueRule = $orm->getOverdueRule($params->{branchCode}, $params->{borrowerCategory}, $params->{letterNumber});
    my $operation;
    if ($existingOverdueRule) { #We are modifying an existing rule
        #Should we somehow tell that we are updating an existing rule?
        $existingOverdueRule->replace($overdueRule); #Replace with the new sanitated values, we preserve the internal data structure position.
        #Replacing might be less costly than recursively unlinking a large internal mapping.
        $operation = 'MOD';
    }
    else { #Just adding more rules
        $orm->_linkOverdueRule( $overdueRule );
        $operation = 'ADD';
    }

    $orm->_pushToModificationBuffer([$overdueRule, $operation]);
    return ($overdueRule, $error);
}

=head deleteOverdueRule

    my $error = $orm->deleteOverdueRule($overdueRule);
    unless($error) {
        $orm->store();
    }

@PARAM1, Koha::Overdues::OverdueRule-object to delete from DB.
@RETURNS, String, the error description or undef if all is ok.
=cut

sub deleteOverdueRule {
    my ($orm, $overdueRule) = @_;

    my $error = $orm->_unlinkOverdueRule( $overdueRule );
    $orm->_pushToModificationBuffer([$overdueRule, 'DEL']) unless $error;
    return $error;
}

=head $orm->deleteAllOverdueRules()

Deletes all OverdueRules in the DB, shows no pity.
Invalidates $orm in the Koha::Cache
=cut

sub deleteAllOverdueRules {
    my ($orm) = @_;
    my $schema = Koha::Database->new->schema();
    $schema->resultset('Overduerule')->search({})->delete_all;
    $orm = undef;

    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache('overdueRulesMap');
}

=head getOverdueRuleForMessageQueue

    my $overdueRule = $orm->getOverdueRuleForMessageQueue( $messageQueue );
    my $overdueRule = $orm->getOverdueRuleForMessageQueue( 322131242 );

Given an MessageQueue-object, this function returns the overduerule for it.
@PARAM1, MessageQueue-object or message_queue.message_id
@RETURNS, undef if no message_queue found, or
          Koha::Overdues::OverdueRule-object
=cut

sub getOverdueRuleForMessageQueue {
    my ($orm, $messageQueue) = @_;

    unless (blessed($messageQueue) && $messageQueue->isa('Koha::MessageQueue')) { #We accept Koha::MessageQueue and subclasses.
        $messageQueue = Koha::MessageQueues->find($messageQueue);
        return undef unless $messageQueue;
    }

    my @items = $messageQueue->items();
    my $borrower = $messageQueue->borrower();
    my $borrowerCategoryCode = $borrower->categorycode();
    my $firstItem = $items[0];
    my $borrowernumber = $messageQueue->borrowernumber();
    my $letter_code = $messageQueue->letter_code();
    my $letternumber = $firstItem->letternumber();
    my $branchcode = $firstItem->branch();
    #It would be more convenient to have the itemnumber and branchcode -columns in the message_queue -table,
    #but this approach has better long-term maintainability ouside of Koha master. (less coupling)

    my $overdueRule = $orm->getOverdueRuleOrDefault($branchcode, $borrowerCategoryCode, $letternumber);
    return $overdueRule;
}

=head _getOverdueRulesMap

    $orm->_getOverdueRulesMap();

Builds the internal map representation out of overduerules- and overduerules_transport_types-tables.
Hopefully some day they are rewritten in a more dynamic manner enabling a selectable amount of overdueLetters.
=cut

sub _getOverdueRulesMap {
    my $orm = shift;

    my $overduerules = _getOverduerules();
    my $overduerules_transport_types = _getOverduerules_transport_types();
    my $maximumLetters = $orm->getOverdueNotificationLetterNumbers();

    #Merge a map of the overduerules_transport_types
    my $otts = {};
    foreach my $ott (@$overduerules_transport_types) {
        $otts->
              { $ott->{overduerules_id} }->
              { $ott->{letternumber} }->
              { 'messageTransportTypes' }->
              { $ott->{message_transport_type} } = 1;
    }
    #Make a map out of the overduerules-table.
    foreach my $o (@$overduerules) {
        for(my $i=1 ; $i<=$maximumLetters ; $i++) {
            next() if (not($o->{"delay$i"})); #Skip undefined letter numbers

            my $messageTransportTypes = $otts->{ $o->{overduerules_id} }->{ $i }->{messageTransportTypes};
            my $params = {  branchCode   => $o->{branchcode},
                            borrowerCategory => $o->{categorycode},
                            overduerules_id => $o->{overduerules_id},
                            letterNumber => $i,
                            delay        => $o->{"delay$i"},
                            letterCode   => $o->{"letter$i"},
                            debarred     => $o->{"debarred$i"},
                            fine         => $o->{"fine$i"},
                            messageTransportTypes => $messageTransportTypes,
            };
            my ($overdueRule, $error) = Koha::Overdues::OverdueRule->new($params);
            if ($error) {
                confess "Error '$error' when creating an OverdueRule-object from ".$overdueRule->toString()."\n";
                next();
            }

            $orm->_linkOverdueRule($overdueRule);
        }
    }

    return $orm;
}

sub _getOverduerules {
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT * FROM overduerules");
    $sth->execute();
    my $overduerules = $sth->fetchall_arrayref({});
    return $overduerules;
}
sub _getOverduerules_transport_types {
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT * FROM overduerules_transport_types");
    $sth->execute();
    my $overduerules_transport_types = $sth->fetchall_arrayref({});
    return $overduerules_transport_types;
}

=head store

    $orm->store();

Transforms this object representation to DB-rows and replaces the
overduerules- and overduerules_transport_types-tables.

TODO:: Rewrite this to support Koha::Overdues::OverdueRule and the database buffer.
       This is not a performance critical aspect, so it doesn't make any difference ATM.

=cut

sub store {
    my $orm = shift;
    my $schema = Koha::Database->new()->schema();

    my $pendingModifications = $orm->_consumeModificationBuffer();
    foreach my $modRequest (@$pendingModifications) {
        my $overdueRule = $modRequest->[0];
        my $operation = $modRequest->[1];
        if ($operation eq 'MOD' || $operation eq 'ADD') {
            $overdueRule->store();
        }
        elsif ($operation eq 'DEL') {
            $overdueRule->delete();
        }
        else {
            carp "Unsupported database access operation '$operation'!";
        }
    }

    my $cache = Koha::Caches->get_instance();
    $cache->set_in_cache('overdueRulesMap', $orm, {expiry => 300});
}

sub _storeOverduerules {
    my ($orm, $branchCode, $borCat, $borcatLevel) = @_;
    my $schema = Koha::Database->new()->schema();

    my $oldOverduerule = $schema->resultset( 'Overduerule' )->find({branchcode => $branchCode, categorycode => $borCat});
    if ($oldOverduerule) {
        $orm->_updateOverduerulesRow($oldOverduerule, $borcatLevel);
    }
    else {
        $orm->_insertOverduerulesRow($branchCode, $borCat, $borcatLevel);
    }
}
sub _insertOverduerulesRow {
    my ($orm, $branchcode, $borcat, $borcatLevel) = @_;
    my $schema = Koha::Database->new()->schema();

    my $letterColumns = { branchcode => $branchcode,
                          categorycode => $borcat  };
    _buildOverduerulesColumns($letterColumns, $borcatLevel);

    my $newOverduerule = $schema->resultset( 'Overduerule' )->create( $letterColumns );
    return $newOverduerule;
}
sub _updateOverduerulesRow {
    my ($orm, $oldOverduerule, $borcatLevel) = @_;

    my $letterColumns = _buildOverduerulesColumns({}, $borcatLevel);

    $oldOverduerule->update( $letterColumns );
    return $oldOverduerule;
}
sub _buildOverduerulesColumns {
    my ($letterColumns, $borcatLevel) = @_;

    foreach my $i (sort keys %$borcatLevel) { #Iterate each letterNumber. $i == letterNumber
        my $overduerule = $borcatLevel->{$i};
        $letterColumns->{"delay$i"} = $overduerule->{delay};
        $letterColumns->{"letter$i"} = $overduerule->{letterCode};
        $letterColumns->{"debarred$i"} = $overduerule->{debarred};
        $letterColumns->{"fine$i"} = $overduerule->{fine};
    }
    return $letterColumns;
}

sub _storeOverduerules_transport_types {
    my ($orm, $branchCode, $borCat, $borcatLevel) = @_;
    my $schema = Koha::Database->new()->schema();

    foreach my $letterNumber (sort keys %$borcatLevel) { #Iterate each letterNumber. $i == letterNumber
        my $overdueRule = $borcatLevel->{$letterNumber};
        foreach my $ott (sort keys %{$overdueRule->{messageTransportTypes}}) {
            my $oldOverdueruleTransportType = $schema->resultset( 'OverduerulesTransportType' )->find({
                                            branchcode => $branchCode,
                                            categorycode => $borCat,
                                            letternumber => $letterNumber,
                                            message_transport_type => $ott
                                        });
            if ($oldOverdueruleTransportType) { #UPDATE
                $oldOverdueruleTransportType->update( {message_transport_type => $ott} );
            }
            else { #INSERT
                my $columns = { branchcode => $branchCode,
                                categorycode => $borCat,
                                letternumber => $letterNumber,
                                message_transport_type => $ott, #overduerules_transport_type
                };
                my $newOverduerule = $schema->resultset( 'OverduerulesTransportType' )->create( $columns );
            }
        }
    }
}

sub _deleteOverduerules_transport_typesRow {
    my ($orm, $oldOverduerulesTransportType, $overdueRule) = @_;

    foreach my $ott (sort keys %{$overdueRule->{messageTransportTypes}}) {
        my $columns = {
                       message_transport_type => $ott, #overduerules_transport_type
                      };
        $oldOverduerulesTransportType->update( $columns );
    }
}

=head _pushToModificationBuffer

    $orm->_pushToModificationBuffer([$overdueRule, $operation]);

To be able to more effectively service DB write operations, especially when using
OverdueRulesMap with an REST(ful?) API giving lots of write operations, it is useful
to be able to know which Overduerules need changing and which do not.
Thus we don't need to either
DELETE all overduerules from DB and re-add them (what if the rewrite request dies?)
  or
check each rule for possible changes.

The modification buffer tells what information needs changing.

To write the changes to DB, use $orm->store().

@PARAM1, Tuple (Two-index ARRAY reference). [0] = $overdueRule (see. upsertOverdueRule())
                                            [1] = The operation, either 'ADD', 'MOD' or 'DEL'
@RETURN, always nothing.

=cut

sub _pushToModificationBuffer {
    my ($orm, $tuple) = @_;
    push @{$orm->{modBuffer}}, $tuple;

    #Delete the precalculated caches
    delete $orm->{letterCodes};
    delete $orm->{lastOverdueRules};
    return undef;
}
=head _consumeModificationBuffer
Detaches the modification buffer from the orm (parent) and returns it.
Orm now has an empty modification buffer ready for new modifications.
=cut

sub _consumeModificationBuffer {
    my ($orm) = @_;
    my $modBuffer = $orm->{modBuffer};
    $orm->{modBuffer} = [];
    return $modBuffer;
}
sub _createModificationBuffer {
    my ($orm) = @_;
    $orm->{modBuffer} = [];
    return undef;
}

1; #Satisfy the compiler