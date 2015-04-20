package Koha::Overdues::Controller;

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

use Koha::Database;
use Koha::MessageQueues;

use Koha::Overdues::Finder;
use Koha::Overdues::Builder;
use Koha::MessageQueue::PrintProviderInterface;
use Koha::Overdues::Calendar;
use Koha::MessageQueue::Notification::Overdues;


sub new {
    my ($class, $self) = @_;

    $self = {} unless ref $self eq 'HASH';
    bless $self, $class;
    return $self;
}

=head gatherOverdueLetters

    my $message_queue_rows = $overduesController->gatherOverdueLetters($self, $letterNumbers, $borrowerCategories, $mergeNotificationBranches);

Finds Issues gone overdue based on the rules set in the overdues.pl (Notice triggers).
Enqueues them to the message_queue-table and creates message_queue_items for them.

The notification generation can be filetered by $letterNumbers [1,2,3,...],
$borrowerCategories ["STAFF", "JUVENILE", "HOMEBOUND"].
Branches are selected using the OverdueCalendar, which defines which branches send
overdue notifications and during which days.

This module makes sure that there is a minimum time spent between each overdue letter for each Item,
so we cannot accidentally send Overdue notifications 1,2,3 at once.

@RETURNS, Reference to ARRAY, of freshly enqueued message_queue-rows and their dependant message_queue_items.

=cut

sub gatherOverdueNotifications {
    my ($self, $letterNumbers, $borrowerCategories) = @_;

    my $odueFinder = Koha::Overdues::Finder->new({
                                verbose => $self->{verbose},
                                lookback => $self->{lookback},
                                notNotForLoan => $self->{notNotForLoan},
                                letterNumbers => $letterNumbers,
                                borrowerCategories => $borrowerCategories,
                                sortBy => $self->{sortBy},
                                sortByAlt => $self->{sortByAlt},
    });
    my $overdues = $odueFinder->findAllNewOverdues();
    my $builder = Koha::Overdues::Builder->new({
                                _repeatPageChange => $self->{_repeatPageChange},
                                verbose => $self->{verbose},
                                mergeBranches => $self->{mergeBranches},
    });
    my ($message_queue_rows, $errors) = $builder->buildAllOverdueNotifications($overdues);
    return ($message_queue_rows, $errors);
}

=head sendOverdueLetters

    ($sentMessageQueues, $finedMessageQueues) = $overduesController->sendOverdueLetters($letterNumbers);

Send all pending overdue notifications for the given letter number.
Adds a fine for each sent letter if configured to do so.

@RETURN References to ARRAYs of sent MessageQueue::Notification::Overdue-objects and
        fined MessageQueue::Notification::Overdue-objects.
=cut

sub sendOverdueNotifications {
    my ($self, $letterNumbers) = @_;
    my $schema = Koha::Database->new()->schema();

    my $messageQueues = Koha::MessageQueue::Notification::Overdues->getPendingAndFailedOverdueLetters($letterNumbers);
    unless ($messageQueues && @$messageQueues) {
        print "No messageQueues to send this time.\n";
        return;
    }

    my $printProviderInterface = Koha::MessageQueue::PrintProviderInterface->new();
    my $printProvider = $printProviderInterface->chooseProvider();
    my ($sentMessageQueues, $error) = $printProvider->sendAll( $messageQueues );
    if ($error) {
        print $error;
        return (undef, $error);
    }
    return ($sentMessageQueues, undef);
}

1; #Satisfy the compiler
