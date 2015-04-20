package Koha::Overdues::Builder;

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

use Modern::Perl;
use Carp;

use Koha::Overdues::OverdueRulesMap;
use C4::Circulation;
use C4::Letters;
use C4::Members;

use Koha::MessageQueue::MessageQueueItem;
use Koha::MessageQueue::MessageQueueItems;
use Koha::MessageQueue;
use Koha::MessageQueues;
use Koha::MessageQueue::Notification::Overdues;

sub new {
    my ($class, $self) = @_;

    $self = {} unless ref $self eq 'HASH';
    bless $self, $class;

    $self->{verbose} = (defined $self->{verbose}) ? $self->{verbose} : 1;
    $self->{mergeBranches} = (defined $self->{mergeBranches}) ? $self->{mergeBranches} : 1;
    if ($self->{_repeatPageChange}) {
        unless (ref($self->{_repeatPageChange}) eq 'HASH' &&
                $self->{_repeatPageChange}->{items} =~ /^\d+$/ &&
                defined($self->{_repeatPageChange}->{separator})) {
            carp "Overdues::Builder->new():> _repeatPageChange-parameter is faulty.";
            $self->{_repeatPageChange} = undef;
        }
        else {
            #sanitate funny characters
            $self->{_repeatPageChange}->{separator} =~ s/\\n/\n/gsm;
        }
    }

    return $self;
}

=head mergeOverdueIssuesToOverdueNotification

    $finder->mergeOverdueIssuesToOverdueNotification($overdueIssue, $existingMessageQueue);

It is possible that we try to enqueue an Overdue Issue even if we already have
an unsent exactly similar notifications. We don't want to send multiple same
notifications to our borrowers at once, and even further issue multiple fines,
because we have been unable to send the notifications in time.
To fix this, we rebuild the message_queue.content and add the new Issue to the
message_queue_items.
=cut

sub _mergeOverdueIssuesToOverdueNotification {
    my ($self, $overdues, $messageTransportType, $branchCode, $repeat, $existingMessageQueue) = @_;

    my @messageQueueItems = $existingMessageQueue->items();
    foreach my $mqItem (@messageQueueItems) {
        my $biblionumber = C4::Biblio::GetBiblionumberFromItemnumber($mqItem->itemnumber());
        push @$repeat, {'biblio'      => $biblionumber,
                        'biblioitems' => $biblionumber,
                        'items'       => $mqItem->itemnumber(),
#                        'issues'      => $mqItem->issue_id(),
                        'issues'      => $mqItem->itemnumber(),
                       };
    }

    my ($letter, $error) = $self->_getPreparedLetter($overdues->[0], $branchCode, $messageTransportType, $repeat);
    return $error if $error;

    if ($letter) {
        $existingMessageQueue->set({content => $letter->{content}});
        $existingMessageQueue->store();

        my $error = Koha::MessageQueue::Notification::Overdues->addItemsFromOverdueIssues($overdues, $existingMessageQueue);
        return $error if $error;
    }
}

sub _enqueueNewOverdueNotification {
    my ($self, $overdues, $messageTransportType, $branchCode, $repeat, $existingMessageQueue) = @_;

    my ($letter, $error) = $self->_getPreparedLetter($overdues->[0], $branchCode, $messageTransportType, $repeat);
    return (undef, $error) if $error;

    if ($letter) {
        my $message_queue_id = C4::Letters::EnqueueLetter({
                            letter                 => $letter,
                            borrowernumber         => $overdues->[0]->{borrowernumber},
                            message_transport_type => $messageTransportType,
                            from_address           => C4::Context->preference('KohaAdminEmailAddress'),
                            to_address             => 'nobody@example.com',
        });

        my $overdueLetter = Koha::MessageQueue::Notification::Overdues->find($message_queue_id);

        #Create the MessageQueueItems for OverdueLetters.
        my $error = Koha::MessageQueue::Notification::Overdues->addItemsFromOverdueIssues($overdues, $overdueLetter);
        return ($overdueLetter, $error);
    }
}

sub _getPreparedLetter {
    my ($self, $overdue, $branchCode, $messageTransportType, $repeat) = @_;
    my $overdueRule = $overdue->{overdueRule};

    my $letter = C4::Letters::GetPreparedLetter (
                            module => 'circulation',
                            letter_code => $overdueRule->{'letterCode'},
                            branchcode => $branchCode,
                            tables => {borrowers => $overdue->{borrowernumber}, biblio => $overdue->{biblionumber}},
                            #substitute => $substitute,
                            repeat => { item => $repeat },
                            _repeatPageChange => $self->{_repeatPageChange},
                            message_transport_type => $messageTransportType,
    );
    return $letter;
}

sub _createAndEnqueueOverdueNotifications {
    my ($self, $overdues, $message_queue_rows, $branchCode, $borrowerCategory, $letterNumber, $sortByKey, $errors) = @_;

    my $schema  = Koha::Database->new->schema;
    $message_queue_rows = [] unless ref $message_queue_rows eq 'ARRAY';

    #Prepare the repeated letter tag placeholder replacements to deal with
    #replaceable tag-groups like <item>.+?</item>
    my @repeat;
    foreach my $od (@$overdues) {
        push @repeat, { 'biblio' => $od->{biblionumber},
                        'biblioitems' => $od->{biblionumber},
                        'items' => $od->{itemnumber},
                        #'issues' => $od->{issue_id},
                        'issues' => $od->{itemnumber},
                      };
    }
    unless (scalar(@repeat)) {
        carp "Builder::_createAndEnqueueOverdueLetters($branchCode, $borrowerCategory, $letterNumber):> No Overdue Issues?";
        return;
    }

    #Create and enqueue overdues by the message_transport_types
    my $overdueRule = $overdues->[0]->{overdueRule};
    my $messageTransportTypes = $overdueRule->{messageTransportTypes};
    unless ($messageTransportTypes) {
        carp "Builder::_createAndEnqueueOverdueLetters($branchCode, $borrowerCategory, $letterNumber):> Overdue has no message_transport_types defined?";
        return;
    }
    foreach my $mtt (keys %$messageTransportTypes) {
        my $existingOverdueNotification = Koha::MessageQueue::Notification::Overdues->checkIfNotSentNotificationForOverdueIssueEnqueued($overdues->[0], $mtt);

        if ($existingOverdueNotification) {
            my $error = $self->_mergeOverdueIssuesToOverdueNotification($overdues, $mtt, $branchCode, \@repeat, $existingOverdueNotification);
            if ($error) {
                push(@$errors, $error);
                next();
            }
        }
        else {
            my ($messageQueue, $error) = $self->_enqueueNewOverdueNotification($overdues, $mtt, $branchCode, \@repeat);
            push(@$message_queue_rows, $messageQueue) if $messageQueue;
            push(@$errors, $error) if $error;
        }
    }
    return ($message_queue_rows, $errors);
}

sub buildOverdueNotifications {
    my ($self, $overdues, $message_queue_rows, $branchCode, $borrowerCategory, $letterNumber, $sortByKey) = @_;

    return $self->_createAndEnqueueOverdueNotifications($overdues, $message_queue_rows, $branchCode, $borrowerCategory, $letterNumber, $sortByKey);
}

sub buildAllOverdueNotifications {
    my ($self, $overduesSet) = @_;

    my $message_queue_rows = []; #Gather all enqueued overdue letters here.
    my $errors = []; #Gather all errors here in addition to carping them.

    #Should we send notifications from each separate branch?
    #Or merge all borrowers and send from the "system" not from an individual branch.
    $overduesSet = $self->_mergeNotificationsBranches($overduesSet) if $self->{mergeBranches};

    #Iterate overdues by branch
    foreach my $branchCode (sort keys %$overduesSet) {
        foreach my $borrowerCategory (sort keys %{$overduesSet->{$branchCode}}) {
            foreach my $letterNumber (sort keys %{$overduesSet->{$branchCode}->{$borrowerCategory}}) {
                print "\nEnqueing for $branchCode, $borrowerCategory, $letterNumber\n";
                foreach my $sortByKey (sort keys %{$overduesSet->{$branchCode}->{$borrowerCategory}->{$letterNumber}}) {
                    print '.';
                    my $overdues = $overduesSet->{$branchCode}->{$borrowerCategory}->{$letterNumber}->{$sortByKey};

                    $self->_createAndEnqueueOverdueNotifications($overdues, $message_queue_rows, $branchCode, $borrowerCategory, $letterNumber, $sortByKey, $errors) if @$overdues;
                }
            }
        }
    }
    $errors = undef unless (scalar(@$errors)); #Don't pass anything as error if no errors to report.
    return ($message_queue_rows, $errors);
}

sub _mergeNotificationsBranches {
    my ($self, $overdues, $targetBranch) = @_;
    $targetBranch = $targetBranch ? $targetBranch : '';

    my $targetBranchHash = {}; #Collect the merged overdues under this branch

    foreach my $branchCode (keys %$overdues) {
        my $branch = $overdues->{$branchCode};
        foreach my $borCatCode (keys %$branch) {
            my $borrowerCategory = $branch->{$borCatCode};
            foreach my $letterNumber (keys %$borrowerCategory) {
                my $source = $borrowerCategory->{$letterNumber};

                #Establish the target HASH
                my $target;
                if (defined $targetBranchHash->{$borCatCode}->{$letterNumber}) {
                    $target = $targetBranchHash->{$borCatCode}->{$letterNumber};
                }
                else {
                    $target = (ref $source eq 'ARRAY') ? [] : {}; #For unsorted overdues SETs we use ARRAY, for sorted SETs we use HASH
                    $targetBranchHash->{$borCatCode}->{$letterNumber} = $target;
                }

                #Deal with unsorted $overdues SETs. They simply have all overdues as an array
                if (ref $source eq 'ARRAY') {
                    push @$target, @$source;
                    unless (ref $target eq 'ARRAY') { #No reference, so it must not be an array
                        $target = $source; #Init an array
                    }
                    else {
                        push @{$target}, $source;
                    }
                }
                #Sorted overdues SETs are collected under the given hash-key in an array.
                elsif (ref $source eq 'HASH') {
                    foreach my $sourceNodeKey (keys %$source) {
                        my $sourceNode = $source->{$sourceNodeKey};
                        if (ref $target->{$sourceNodeKey} eq 'ARRAY') {
                            push @{$target->{$sourceNodeKey}}, @$sourceNode;
                        }
                        else { #No reference, so it must not be an array
                            $target->{$sourceNodeKey} = $sourceNode; #Copy an array
                        }
                        $borrowerCategory->{$letterNumber}->{$sourceNodeKey} = undef; #Destroy the original link to avoid memory leaking.
                    }
                }
                $borrowerCategory->{$letterNumber} = undef; #Destroy the original link to avoid memory leaking.
            }
            $branch->{$borCatCode} = undef;
        }
        $overdues->{$branchCode} = undef;
    }

    #Link the new merged HASH to its desired position.
    return {$targetBranch => $targetBranchHash};
}

=head populateMessageQueueItemsFromMessageQueues

    Koha::Overdues::Builder->populateMessageQueueItemsFromMessageQueues(  '^Barcode:\s*(.*?)$'  );

Analyzes all sent overdueletters.
This function should be called only once to migrate from the old model of overduenotices
to the new generate-on-demand overduenotifications.
Creates MessageQueueItem-objects and saves them to the DB based on the overdue notified Items in
the message_queue messages.
Also removes all pending or failed overdue notifications. They are automatically regenerated
during the next overdue notifications gathering cycle using the new instructions.

This script depends on each overdueletter (1,2,3) using a separate letter template to differentiate
between overdueletters.
The challenge here is that we cannot know for sure if overdue notifications have been succesfully
sent whenever they have been scheduled to be sent, due to errors.
If you don't really care much for that, then don't run this function and things will take care of itself
eventually :)

@PARAM1, Regexp, to find the Item's barcode or itemnumber from the message.
                 Regexp will be ran like =~ /$regexp/smg
                 to find multiple results from a multiline regexp search.
                 Regexp must have one capture group to get the identifier.
                 Eg. '^Item:\s*(.+?)$'
                 Then the message_queue content is searched for all instances of the given regexp.
                 These found item ids' are then checked whether or not they are the barcode or an
                 itemnumber to resolve the proper itemnumber.

=cut

sub populateMessageQueueItemsFromMessageQueues {
    my ($builder, $itemParsingRegexp, $populateDelete) = @_;

    my $orm = Koha::Overdues::OverdueRulesMap->new();
    ##We need to find the overdue notified Items for each overdue letter number
    foreach my $letterNumber (  1..$orm->getOverdueNotificationLetterNumbers()  ) { #Iterate each configured overdue notification

        #Gather all sent overdue notifications for this letter number
        my $letterCodes = $orm->getLetterCodesForNumber($letterNumber);
        my @messageQueues = Koha::MessageQueues->search({letter_code => { -in => $letterCodes }, status => 'sent'});

        if ($populateDelete) {
            my @pendingMq = Koha::MessageQueues->search({letter_code => { -in => $letterCodes }, status => { -in => ['pending','failed'] }});
            foreach my $mq (@pendingMq) {
                $mq->delete();
            }
        }

        print "\nFound '".(scalar(@messageQueues) || '0')."' message queues for letter codes '".join(', ', @$letterCodes)."'\n";

        #Find the items that have been notified of.
        my $i = 0;
        foreach my $messageQueue (@messageQueues) {
            if ($i++ % 100 == 0) {
                print "\n$i";
            }
            else {
                print ".";
            }


            my $messageQueueItems = $messageQueue->items();
            if ($messageQueueItems->count()) {
                next(); #This messageQueue has already been populated.
            }

            #Find all the Items notified inside this message_queue.
            my $itemnumbers = _findItemnumberFromMessage_queue($messageQueue, $itemParsingRegexp);

            my $issuesFound = 0; #Keep track if the pending messageQueue has any outstanding issues attached. If none, then delete the messageQueue if it has not been sent.
            foreach my $itemnumber (@$itemnumbers) {
                #Ok we got the itemnumber, now to get the issue.
                my $issues = C4::Circulation::GetIssues({borrowernumber => $messageQueue->borrowernumber, itemnumber => $itemnumber});
                next() unless ($issues && @$issues);

                $issuesFound++;
                my $issue = $issues->[0];

                my $messageQueueItem = Koha::MessageQueue::MessageQueueItem->new();
                $messageQueueItem->set({
                                        issue_id          => ($issue) ? $issue->{issue_id} : undef,
                                        letternumber     => $letterNumber,
                                        itemnumber       => $itemnumber,
                                        branch           => ($issue) ? $issue->{branchcode} : undef,
                                        message_id       => $messageQueue->message_id,
                                      });
                eval { $messageQueueItem->store(); }; #Don't crash the process if there are minor issues.
            }
            if (not($issuesFound) && $populateDelete) {
                $messageQueue->delete();
            }
            else {
                $builder->rebuildMessageQueue($messageQueue);
            }
        }
    }
}

sub _findItemnumberFromMessage_queue {
    my ($messageQueue, $itemParsingRegexp) = @_;

    #Find all the Items notified inside this message_queue.
    my @itemnumbers;
    my @itemIds = $messageQueue->content =~ /$itemParsingRegexp/sgm;
    foreach my $itemId (@itemIds) {
        $itemId =~ s/\s+//gsm;
        my $itemnumber = C4::Items::GetItemnumberFromBarcode($itemId);
        unless ($itemnumber) {
            $itemnumber = C4::Items::GetItem($itemnumber);
            $itemnumber = $itemnumber->{itemnumber} if $itemnumber;
        }
        unless ($itemnumber) {
            carp "Unknown Item identifier $itemId\n";
            next();
        }
        push @itemnumbers, $itemnumber;
    }
    return \@itemnumbers;
}

sub rebuildMessageQueue {
    my ($self, $messageQueue) = @_;

    my @messageQueueItems = $messageQueue->items();

    my @repeat;
    foreach my $it (@messageQueueItems) {
        my $biblionumber = C4::Biblio::GetBiblionumberFromItemnumber($it->itemnumber);
        push @repeat, { 'biblio' => $biblionumber,
                        'biblioitems' => $biblionumber,
                        'items' => $it->itemnumber,
                        'issues' => $it->itemnumber,
                      };
    }
    my $letter = C4::Letters::GetPreparedLetter (
                            module => 'circulation',
                            letter_code => $messageQueue->letter_code(),
                            branchcode => '', #message_queue-table doesn't have branchcode?
                            tables => {borrowers => $messageQueue->borrowernumber()},
                            #substitute => $substitute,
                            repeat => { item => \@repeat },
                            _repeatPageChange => {items => 7, separator => "10\n31"},
                            message_transport_type => $messageQueue->message_transport_type(),
    );
    $messageQueue->set({content => $letter->{content}});
    $messageQueue->store();
}
1; #Satisfy the compiler
