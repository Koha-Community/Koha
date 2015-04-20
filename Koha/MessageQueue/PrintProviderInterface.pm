package Koha::MessageQueue::PrintProviderInterface;

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

use C4::Context;
use Koha::Database;
use Koha::DateUtils;
use Koha::Overdues::OverdueRulesMap;
use Koha::Patron::Debarments;
use C4::Accounts;
use C4::Letters;

sub new {
    my ($class) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

sub chooseProvider {
    my ($self) = @_;

    my $printProviderImplementation = C4::Context->preference('PrintProviderImplementation');
    die "No PrintProviderImplementation selected! You must choose an implementation using the system preference 'PrintProviderImplementation'" unless $printProviderImplementation;
    $printProviderImplementation = 'Koha::MessageQueue::'.$printProviderImplementation;

    #Sanitate the system preference from DB. It could be an code injection attack.
    unless ($printProviderImplementation =~ /^[a-zA-Z0-9:]+$/) { #We expect only nice package names.
        carp("Bad Print Provider package name '$printProviderImplementation'!");
    }
    eval "require $printProviderImplementation";
    if ($@) {
        carp($@);
        die "No PrintProviderImplementation '$printProviderImplementation' available.";
    }
    $printProviderImplementation = $printProviderImplementation->new();
    return $printProviderImplementation;
}

=head sendAll
OVERLOAD this subroutine in subclasses to handle print letter printing.

    my $sentMessageQueues = $printProvider->sendAll( $messageQueues );

Override this method from a subclass to add meaningful behaviour to your
PrintProviderInterface-implementation.

REMEMBER to invoke the
    $self->SUPER::sendAll($sentMessageQueues, $params);
After sending the letters so fines and debarments can be properly applied.
=cut

sub sendAll {
    my ($self, $sentMessageQueues, $params) = @_;

    #OVERLOAD this subroutine in subclasses to handle print letter printing.
    #REMEMBER to invoke the SUPER::sendAll($self, $messageQueues, $params);
    # After sending the letters so fines and debarments can be properly applied.

    $self->addFines($sentMessageQueues);
    $self->addDebarments($sentMessageQueues);

    return $sentMessageQueues;
}

=head addFines

    $printProvider->addFines($sentMessageQueues);

=cut

sub addFines {
    my ($self, $sentMessageQueues) = @_;

    my $orm = Koha::Overdues::OverdueRulesMap->new();
    my $schema = Koha::Database->new->schema();

    foreach my $messageQueue (@$sentMessageQueues) {
        $self->addFine($messageQueue, $orm, $schema);
    }
    return (1, undef);
}
sub addFine {
    my ($self, $messageQueue, $orm, $schema) = @_;

    $orm = Koha::Overdues::OverdueRulesMap->new() unless $orm;
    $schema = Koha::Database->new->schema() unless $schema;

    my @messageQueueItems = $messageQueue->items();

    my $overdueRule = $orm->getOverdueRuleForMessageQueue($messageQueue);
    my $fine = $overdueRule->{fine};
    return unless $fine;

    my $letterTemplateMessageTransportType = $messageQueue->message_transport_type() || 'print';
    my $letterTemplateBranchcode = $messageQueueItems[0]->branch() || '' ;
    my $letterTemplateCode = $messageQueue->letter_code() || '';
    my $letterTemplate = $schema->resultset('Letter')->find({   code => $letterTemplateCode,
                                                                message_transport_type => $letterTemplateMessageTransportType,
                                                                branchcode => $letterTemplateBranchcode,
                                                           });
    $letterTemplate = $schema->resultset('Letter')->find({   code => $letterTemplateCode,
                                                                message_transport_type => $letterTemplateMessageTransportType,
                                                                branchcode => '',
                                                           }) unless $letterTemplate;
    my $fineTitle = ($letterTemplate) ? $letterTemplate->title() : '';

    my @manualInvoiceNote = map {
        my $item = $schema->resultset('Item')->search({itemnumber => $_->itemnumber})->single();
        _buildManualInvoiceNote($item)
    } @messageQueueItems;

    #Add a processing fine for sending a snail mail.
    my $letterNumber = $messageQueueItems[0]->letternumber || '';

    C4::Accounts::manualinvoice(  $messageQueue->borrowernumber, undef, $fineTitle, $letterTemplateCode, $fine, join(' ',@manualInvoiceNote)  );
}

sub _buildManualInvoiceNote {
    my $item = shift;

    return
    '<a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber='.$item->biblionumber.'&itemnumber='.$item->itemnumber.'#item'.$item->itemnumber.'">'.
      $item->barcode.
    '</a>';
}

sub addDebarments {
    my ($self, $sentMessageQueues) = @_;

    my $orm = Koha::Overdues::OverdueRulesMap->new();
    my $schema = Koha::Database->new->schema();

    foreach my $messageQueue (@$sentMessageQueues) {
        $self->addDebarment($messageQueue, $orm, $schema);
    }
    return (1, undef);
}

sub addDebarment {
    my ($self, $messageQueue, $orm, $schema) = @_;

    my $overdueRule = $orm->getOverdueRuleForMessageQueue( $messageQueue );

    if ($overdueRule->{debarred}) {
        Koha::Patron::Debarments::AddUniqueDebarment(
            {
                borrowernumber => $messageQueue->borrowernumber(),
                type           => 'OVERDUES',
                comment => "Restriction added by overdues process ".
                           Koha::DateUtils::output_pref( Koha::DateUtils::dt_from_string() ),
            }
        );
        $self->{verbose} and carp "debarring ".$messageQueue->borrowernumber()."\n";
    }
}

1; #Satisfy the compiler
