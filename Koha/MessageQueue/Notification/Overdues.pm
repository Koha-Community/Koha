package Koha::MessageQueue::Notification::Overdues;

# Copyright Vaara-kirjastot 2015
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

use Carp;

use Koha::Database;

use Koha::MessageQueue::Notification::Overdue;
use Koha::MessageQueue::MessageQueueItems;
use Koha::Overdues::OverdueRulesMap;
use base qw(Koha::MessageQueues);

=head1 NAME

Koha::MessageQueue::Notification::Overdues - Koha Overdue Object class factory

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'MessageQueue';
}

sub object_class {
    return 'Koha::MessageQueue::Notification::Overdue';
}

#Override Koha::Objects->find()
#Make sure that these searches only match valid Overdue Notifications
sub find {
    my ( $self, $id ) = @_;

    return unless $id;

    my $orm = Koha::Overdues::OverdueRulesMap->new();
    my $letterCodes = $orm->getLetterCodes();
    my $result = $self->_resultset()->find({message_id => $id, letter_code => { -in => $letterCodes }});

    my $object = $self->object_class()->_new_from_dbic( $result );

    return $object;
}

#Override Koha::Objects->search()
#Make sure that these searches only match valid Overdue Notifications
sub search {
    my ( $self, $params ) = @_;

    #Inject the Query to filter out only Overdue Notifications
    my $orm = Koha::Overdues::OverdueRulesMap->new();
    my $letterCodes = $orm->getLetterCodes();
    $params->{letter_code} = {'-in' => $letterCodes};

    return $self->SUPER::search($params);
}


sub getPendingAndFailedOverdueLetters {
    my ($self, $overdueLetterNumbers) = @_;

    #Query to filter out only Overdue Notifications
    my $orm = Koha::Overdues::OverdueRulesMap->new();
    my $letterCodes = $orm->getLetterCodes();

    my @messageQueues = $self->_resultset()->search(
                    {   '-and' => [ letter_code => {'-in' => $letterCodes},
                                    "message_queue_items.letternumber" => { '-in' => $overdueLetterNumbers },
                                    '-or' => [  status => 'pending',
                                                status => 'failed',
                                             ],
                                  ],
                    },
                    {   join => 'message_queue_items',
                        group_by => 'message_id',
                    }
                );
    @messageQueues = $self->_wrap(@messageQueues);
    return \@messageQueues;
}

=head checkIfNotSentNotificationForOverdueIssueEnqueued

    Koha::MessageQueue::Notification::Overdues::checkIfSimilarNotificationAlreadyEnqueued($overdueIssue);

See if the same notification this overdue would generate is already pending.
@RETURN Koha::MessageQueue::Notification::Overdue or undef.
=cut

sub checkIfNotSentNotificationForOverdueIssueEnqueued {
    my ($self, $overdue, $messageTransportType) = @_;

    my $overdueRule = $overdue->{overdueRule};
    my @MqS = $self->_resultset()->search(
                    {   '-and' => [ borrowernumber => $overdue->{borrowernumber},
                                    letter_code => $overdueRule->{letterCode},
                                    message_transport_type => $messageTransportType,
                                    "message_queue_items.branch" => $overdue->{branchcode},
                                    '-or' => [  status => 'pending',
                                                status => 'failed',
                                             ],
                                  ],
                    },
                    {   join => 'message_queue_items',
                        group_by => 'message_id',
                    }
                );
    if (scalar(@MqS)) {
        #We should have at most one messageQueue match, if any.
        unless (scalar(@MqS) == 1) {
            my @message_ids;
            foreach my $mq (@MqS) {
                push @message_ids, $mq->id();
            }
            carp "Overdues->checkIfNotSentNotificationForOverdueIssueEnqueued():> Multiple similar message_queue_ids '@message_ids' to merge to! Picking first one to recover from error.";
        }
        my $mq = $MqS[0];
        $mq = $self->object_class()->_new_from_dbic( $mq );
        return $mq;
    }
}

=head addItemsFromOverdueIssues

    Koha::MessageQueue::Notification::Overdues->addItemsFromOverdueIssues($issues, $messageQueue);

Adds the given Issues, with borrower- and item data, to the given MessageQueue

@PARAM1 ARRAY of HASH
@PARAM2 Koha::MessageQueue or subclass, or Integer message_queue.message_id
@RETURNS String error, if something bad hapened.
=cut

sub addItemsFromOverdueIssues {
    my ($self, $issues, $messageQueue) = @_;

    my @items;
    if (ref $issues eq 'ARRAY') {
        foreach my $issue (@$issues) {
            my $overdueRule = $issue->{overdueRule};
            my $params = {  issue_id => $issue->{issue_id}, letternumber => $overdueRule->{letterNumber},
                            itemnumber => $issue->{itemnumber}, branch => $issue->{holdingbranch},
                            #message_id => $message_queue_id, #This is generated in the addItem-function in MessageQueueItems.
                         };
            push @items, $params;
        }
    }
    unless (scalar(@items)) {
        carp "addItemsFromOverdueIssues():> Trying to add Items without Items";
        return "NO_ITEMS";
    }
    return Koha::MessageQueue::MessageQueueItems->addItems(\@items, $messageQueue);
}

=head1 AUTHOR

Olli-Antti Kivilahti <olli-antti.kivilahti@jns.fi>

=cut

1;
