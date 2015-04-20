package Koha::MessageQueue::MessageQueueItems;

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

use Scalar::Util 'blessed';
use Koha::MessageQueue::MessageQueueItem;

use base qw(Koha::Objects);

=head1 NAME

Koha::MessageQueue::MessageQueueItem - Koha MessageQueueItem Object class

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'MessageQueueItem';
}

sub object_class {
    return 'Koha::MessageQueue::MessageQueueItem';
}

=head addItems

    Koha::MessageQueue::MessageQueueItems->addItems($items, $messageQueue);

Adds the given Items to the given MessageQueue
@PARAM1 ARRAY of HASHes, or something else
@PARAM2 Koha::MessageQueue or subclass, or Integer message_queue.message_id
@RETURNS String error, if something bad hapened.
=cut

sub addItems {
    my ($self, $items, $messageQueue) = @_;
    my @errors;

    #Check that we can get the proper messageQueue-object
    unless (blessed($messageQueue) && $messageQueue->isa('Koha::MessageQueue')) {
        my $messageQueueNew = Koha::MessageQueues->find($messageQueue);
        unless (blessed($messageQueueNew) && $messageQueueNew->isa('Koha::MessageQueue')) {
            carp "MessageQueueItems->addItems():> Unknown MessageQueue '$messageQueue' for Items. Not adding!";
            return "UNKNOWN_ITEM";
        }
        $messageQueue = $messageQueueNew;
    }

    #Choose the method of extracting the given Items.
    if (ref $items eq 'ARRAY') {
        if (ref $items->[0] eq 'HASH') {
            foreach my $item (@$items) {
                my $error = $self->_addItem( $item, $messageQueue );
                push @errors, $error if $error;
            }
        }
        else {
            carp "MessageQueueItems->addItems():> Unknown Item format '".ref($items->[0])."' for Items. Not adding!";
            return "UNKNOWN_ITEM";
        }
    }
    else {
        carp "MessageQueueItems->addItems():> Unknown container '".ref($items)."' for Items. Not adding!";
        return "UNKNOWN_CONTAINER";
    }
    return join("\n", @errors) if scalar(@errors) > 0;
}
sub _addItem {
    my ($self, $item, $messageQueue) = @_;

    my $params = {  issue_id => $item->{issue_id}, letternumber => $item->{letternumber},
                    itemnumber => $item->{itemnumber}, branch => $item->{branch},
                    message_id => $messageQueue->id(),
                 };

    my $messageQueueItem = Koha::MessageQueue::MessageQueueItem->new($params);
    unless($messageQueueItem) {
        my $errorStr = "MessageQueueItems->_addItemsFromArrayOfHashes():> MessageQueueItem adding failed for message_id '".$messageQueue->id()."' and issue_id '".$item->{issue_id}."'. ";
        carp $errorStr;
        return $errorStr;
    }
    eval { $messageQueueItem->store(); }; #We might get duplicates, so let's not die because of them
    return undef;
}

=head1 AUTHOR

Olli-Antti Kivilahti <olli-antti.kivilahti@jns.fi>

=cut

1;
