package Koha::MessageQueue::PrintProviderLimbo;

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

use C4::Context;

use base "Koha::MessageQueue::PrintProviderInterface";

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

=head sendAll

    my $sentMessageQueues = $printProvider->sendAll( $messageQueues );

"Sends" all print notifications to limbo, from where they never return,
but leaves all other message transport types unsent.
Sets fines and debarments normally.
=cut

sub sendAll {
    my ($self, $messageQueues, $params) = @_;

    return (undef, "PrintProviderLimbo->sendAll(): the given MessageQueues-array is empty!") unless $messageQueues && @$messageQueues;

    #We don't actually send anything, just mark notifications as sent.
    my $sentMessageQueues = _markAllMessageQueuesSent($messageQueues);

    #We could call the parent to deal fines and debarments on the messageQueues we pass through,
    #but we can control it more finely from withing.
    #$sentMessageQueues = $self->SUPER::sendAll($sentMessageQueues, $params);

    #Add a fine for only the sent messageQueues, which are all print notifications
    $self->addFines($sentMessageQueues); #call the parent to handle this.

    #We want a debarment for all message_transport_types, if debarment is applicable
    $self->addDebarments($messageQueues); #call the parent to handle this, simply giving all message transport types.

    return ($sentMessageQueues, undef);
}

sub _markAllMessageQueuesSent {
    my $messageQueues = shift;

    my @sentMessageQueues;
    foreach my $messageQueue (@$messageQueues) {
        if ($messageQueue->message_transport_type() eq 'print') {
            $messageQueue->setStatus( 'sent' );
            push @sentMessageQueues, $messageQueue;
        }
    }
    return \@sentMessageQueues;
}

1; #Satisfy the compiler