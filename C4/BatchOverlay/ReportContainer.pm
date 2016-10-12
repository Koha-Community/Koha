package C4::BatchOverlay::ReportContainer;

# Copyright (C) 2014 The Anonymous
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
use DateTime;

use C4::Biblio::Diff;
use C4::BatchOverlay::Report::Report;
use C4::BatchOverlay::Notifier;
use C4::Context;
use C4::Members;
use Koha::DateUtils;

use Koha::Exception::BadParameter;
use Koha::Exception::FeatureUnavailable;

sub new {
    my ($class, $self) = @_;
    $self = {} unless(ref($self) eq 'HASH');
    bless($self, $class);

    $self->{timestamp} = DateTime->now( time_zone => C4::Context->tz() );

    if($self->{borrowernumber} && not($self->{borrowernumber} =~ /^\d+$/)) {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc[3]." is creating a new report container, but the param \$borrowernumber '".$self->{borrowernumber}."' is not a digit");
    }
    unless($self->{borrowernumber}) {
        $self->{borrowernumber} = C4::Context->userenv();
        $self->{borrowernumber} = $self->{borrowernumber}->{number} if $self->{borrowernumber};
        unless($self->{borrowernumber}) {
            my @cc = caller(1);
            Koha::Exception::FeatureUnavailable->throw(error => $cc[3]." is creating a new report container, but the param \$borrowernumber was not given and cannot be found from 'userenv'");
        }
    }
    $self->{reports} = [];

    $self->setNotifier( C4::BatchOverlay::Notifier->new() );

    return $self;
}

sub newFromDB {
    my ($class, $row) = @_;
    _validateDBRow($row);

    eval {
        $row->{timestamp} = DateTime::Format::MySQL->parse_datetime( $row->{timestamp} );
    };
    if ($@) {
        my @cc = caller(1);
        Koha::Exception::Parse->throw(error => $cc[3]." is trying to create a ".__PACKAGE__."-object from a DB row '$row', but the 'timestamp' parameter '".$row->{timestamp}."' is not a valid ISO8601 datetime\n$@\n");
    }

    bless($row, $class);
    return $row
}

sub _validateDBRow {
    my ($row) = @_;
    unless (ref($row) eq 'HASH') {
        my @cc2 = caller(2);
        Koha::Exception::BadParameter->throw(
                error => $cc2[3]." is trying to add a ".__PACKAGE__."-object from a DB row '$row', but the DB row is not a HASH"
        );
    }

    my @mandatoryProperties = ('id', 'borrowernumber', 'timestamp');
    foreach my $prop (@mandatoryProperties) {
        unless($row->{$prop}) {
            my @cc = caller(1);
            Koha::Exception::BadParameter->throw(error => $cc[3]." is creating a ".__PACKAGE__."-object from a DB row, but the param '$prop' is undefined");
        }
    }
}

sub setNotifier {
    my ($self, $notifier ) = @_;
    unless (blessed($notifier) && $notifier->isa('C4::BatchOverlay::Notifier')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($notifier):> Param \$notifier '$notifier' is not of proper class");
    }
    $self->{notifier} = $notifier;
}
sub getNotifier {
    return shift->{notifier};
}

=head addReport

    my $report = $reportBuilder->addReport($params);

@PARAM1 HASHref of C4::BatchOverlay::Report::Report->new() parameters
        or C4::BatchOverlay::Report::Report-object
        or C4::BatchOverlay::Report::Error-object
@RETURNS this C4::BatchOverlay::ReportContainer-object

=cut

sub addReport {
    my ($self, $report) = @_;
    if (ref($report) eq 'HASH') {
        $report = C4::BatchOverlay::Report::Report->new($report);
    }
    elsif (blessed($report) && $report->isa('C4::BatchOverlay::Report::Error')) {
        #ok
    }
    elsif (blessed($report) && $report->isa('C4::BatchOverlay::Report::Report')) {
        #ok
    }
    else {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error $cc[3]."()> Param \$report '$report' is not a proper HASH or a Report-object");
    }

    push(@{$self->{reports}}, $report);
    $self->getNotifier()->detectNotifiableFieldChanges($report);
    return $self;
}

sub getReports {
    return shift->{reports};
}

sub persist {
    my ($self) = @_;

    $self->getNotifier->queueTriggeredNotifications();

    my $reports = $self->getReports();

    my $borc = C4::BatchOverlay::ReportManager->_insertReportContainerToDB($self->getTimestamp(), $self->getBorrowernumber());
    $self->setId($borc->{id});

    foreach my $report (@$reports) {
        $report->persist( $self->getId() );
    }
    return $self;
}

sub getId {
    return shift->{id};
}
sub setId {
    my ($self, $id) = @_;
    unless(defined($id) && $id =~ /^\d+$/) {
        my @cc1 = caller(1);
        Koha::Exception::BadParameter->throw(error $cc1[3]." is setting the id of '".__PACKAGE__."', but id '$id' is not a digit.");
    }
    $self->{id} = $id;
}
sub getBorrowernumber {
    return shift->{borrowernumber};
}
sub getBorrower {
    my ($self) = @_;
    $self->{borrower} = C4::Members::GetMember(borrowernumber => $self->getBorrowernumber());
    return $self->{borrower};
}
sub getTimestamp {
    return shift->{timestamp};
}
sub getTimestampLocalized {
    return Koha::DateUtils::output_pref( { dt => shift->getTimestamp() } );
}
sub getReportsCount {
    my ($self) = @_;
    if (my $reports = $self->getReports()) {
        my $count = 0;
        foreach my $r (@$reports) {
            $count++ if $r->isa('C4::BatchOverlay::Report::Report');
        }
        return $count;
    }
    else {
        return $self->{reportsCount};
    }
}
sub getErrorsCount {
    my ($self) = @_;
    if (my $reports = $self->getReports()) {
        my $count = 0;
        foreach my $r (@$reports) {
            $count++ if $r->isa('C4::BatchOverlay::Report::Error');
        }
        return $count;
    }
    else {
        return $self->{errorsCount};
    }
}

1;
