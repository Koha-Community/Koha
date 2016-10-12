package C4::BatchOverlay::Notifier;

use Modern::Perl;

use C4::Context;
use C4::Letters;
use C4::Biblio::Diff;

=head1 Notifier

Checks if notifications need to be done due to merge operations and prepares the queuing of merge notifications

=cut

use Koha::Exception::BadParameter;

sub new {
    my ($class) = @_;
    my $self = {};
    bless $self, $class;

    $self->setTriggeredNotificationsStash({});

    return $self;
}

sub setTriggeredNotificationsStash {
    my ($self, $stash) = @_;
    unless (ref($stash) eq 'HASH') {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc[3]." is setTriggeredNotificationsStash() but the stash '$stash' is not a HASH");
    }
    $self->{notifications} = $stash;
}
sub getTriggeredNotificationsStash {
    return shift->{notifications};
}
sub triggerNotification {
    my ($self, $biblionumber, $changes) = @_;
    return unless ($changes && @$changes);
    my $stash = $self->getTriggeredNotificationsStash();

    if (exists($stash->{$biblionumber})) {
        push(@{$stash->{$biblionumber}}, @$changes);
    }
    else {
        $stash->{$biblionumber} = $changes;
    }
}
sub hasTriggeredNotifications {
    my ($self) = @_;
    return 0 if (scalar keys %{$self->getTriggeredNotificationsStash()});
    return 1;
}

sub setDestinationEmails {
    my ($self, $emails) = @_;
    $self->{emails} = $emails;
    return $self;
}
sub getDestinationEmails {
    return shift->{emails};
}

=head2 detectNotifiableFieldChanges

@PARAM1 C4::BatchOverlay::Report

=cut

sub detectNotifiableFieldChanges {
    my ($self, $report) = @_;
    my $rule = $report->getOverlayRule();
    return if $report->isa('C4::BatchOverlay::Report::Error'); #Errors don't have MARC diffs but error messages
    $self->setDestinationEmails($rule->getNotificationEmails()) unless $self->getDestinationEmails;

    my $marcSubfieldsToLookFor = $rule->getNotifyOnChangeSubfields();
    my $changes = C4::Biblio::Diff::grepChangedElements($report->getDiff(), $marcSubfieldsToLookFor);

    $self->triggerNotification($report->getBiblionumber(), $changes);
}

sub getNotifiableChangesByBiblionumber {
    return shift->getTriggeredNotificationsStash();
}

sub queueTriggeredNotifications {
    my ($self) = @_;
    return if $self->hasTriggeredNotifications();

    my $emails = $self->getDestinationEmails();
    foreach my $email (@$emails) {
        my $letter = makeLetter($self->getTriggeredNotificationsStash(),
                                $email,
                                'email',
                                'text/html; charset="UTF-8"');

        C4::Letters::EnqueueLetter({
                        letter => $letter,
                        borrowernumber => $letter->{borrowernumber},
                        message_transport_type => $letter->{message_transport_type},
                        from_address => $letter->{from_address},
                        to_address => $letter->{to_address},
        });
    }
}

sub makeLetter {
    my ($changesByBiblionumber, $destination, $mtt, $contentType) = @_;

    #Currently the C4::Letter::GetPreparedLetter() is so messy and broken and untested that this type of repeated item notifiactions cannot be generated with it.
    $mtt = 'email';
    $contentType = 'text/html; charset="UTF-8"';

    my %letter = (
        borrowernumber => C4::Context::userenv()->{number} || 1,
        title          => "BatchOverlay notification",
        code           => 'BATCOVER',
        message_transport_type => $mtt,
        to_address     => $destination,
        from_address   => C4::Context->preference('KohaAdminEmailAddress'),
        'content-type' => $contentType,
        content        => _getLetterContent($changesByBiblionumber),
    );
    return \%letter;
}

sub _getLetterContent {
    my ($changesByBiblionumber) = @_;
    my $baseUrl = C4::Context->preference('staffClientBaseURL');

    my @sb; #Java.Lang.StringBuilder
    push(@sb, <<HEAD);
<p>
    For your convenience,<br/>
    BatchOverlay wishes to notify,<br/>
    that the following fields have been automatically changed:
</p>
HEAD

    foreach my $biblionumber (sort keys %$changesByBiblionumber) {
        my $changes = $changesByBiblionumber->{$biblionumber};

        push(@sb, <<BIBLIOTITLE);
<p>
    <a href='https://$baseUrl/cgi-bin/koha/catalogue/detail.pl?biblionumber=$biblionumber'><h3>Biblio $biblionumber</h3></a>
    <table border=1 cellpadding=3>
BIBLIOTITLE

        foreach my $c (@$changes) {
            push(@sb, <<CHANGE);
        <tr>
CHANGE
            foreach my $v (@$c) {
                push(@sb, <<CHANGE);
            <td>$v</td>
CHANGE
            }
            push(@sb, <<CHANGE);
        </tr>
CHANGE
        }
        push(@sb, <<CHANGES);
    </table>
</p>
CHANGES
    }

    push(@sb, <<FOOTER);
<br/>
<p>
    Thank you for letting me serve you!<br/>
    <i>-Your friendly BatchOverlay-daemon</i>
</p>
<p>
P.S. You can change the notification settings from the BatchOverlay-system preference
</p>
FOOTER

    return join('', @sb);
}

1;
