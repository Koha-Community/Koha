package Koha::Overdues::Finder;

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

use DateTime;

use C4::Context qw(dbh);
use Koha::Overdues::OverdueRulesMap;
use C4::Circulation;

sub new {
    my ($class, $self) = @_;

    $self = {} unless ref $self eq 'HASH';
    bless $self, $class;

    $self->{overduerules} = Koha::Overdues::OverdueRulesMap->new();
    $self->{verbose} = (defined $self->{verbose}) ? $self->{verbose} : 1;
    $self->{lookback} = $self->{lookback} || $self->{overduerules}->getLastOverdueRuleDelay()+30;
    $self->{notNotForLoan} = $self->{notNotForLoan} || undef;
    $self->{availableBranches} = $self->{availableBranches} || undef;
    $self->{letterNumbers} = $self->{letterNumbers} || undef;
    $self->{borrowerCategories} = $self->{borrowerCategories} || undef;
    $self->{sortBy} = $self->{sortBy} || 'borrowernumber';
    $self->{sortByAlt} = $self->{sortByAlt} || 'borrowernumber';
    $self->{now} = DateTime->now(  time_zone => C4::Context->tz()  );

    return $self;
}

=head setToday

    $finder->setToday('YYYY-MM-DD');
    $finder->setToday($dateTime);

Make this finder-object think that the current time is something else.
Now you can find overdue Issues like it was just another day in the office!
=cut

sub setToday {
    my ($self, $today) = @_;
    $today = Koha::DateUtils::dt_from_string($today, 'iso') unless ref $today eq 'DateTime';
    $self->{now} = $today;
}

sub findNewOverdues {
    my ($self, $lookBackDays, $notNotForLoan, $branchCode, $borrowerCategory, $letterNumber, $sortBy, $sortByAlt) = @_;

    my $overdueRule = $self->{overduerules}->getOverdueRuleOrDefault( $branchCode, $borrowerCategory, $letterNumber );
    if (not($overdueRule)) {
        if ($self->{verbose} > 1) {
            no warnings;
            carp "Finder->findNewOverdues($self, $branchCode, $borrowerCategory, $letterNumber, $sortBy, $sortByAlt):> No OverdueRule found from params. Skipping this group.";
            use warnings;
        }
        return;
    }
    my $delayDays = $overdueRule->{delay};
    my $lateDate = $self->{now}->clone();
    $lateDate->subtract(days => $delayDays); #Now we have the day after which these Issues are overdue.
    my $lookbackMaxDate = $lateDate->clone();
    $lookbackMaxDate->subtract(days => $lookBackDays); #Now we know from where to start looking for overdue due_dates.

    my $params = [];

    #Check if we want to exclude using the items.notforloan -column.
    #For ex we don't want to send notifications for Items that have alrady been claimed.
    my $notNotForLoanSql = '';
    if ($notNotForLoan) {
        $notNotForLoanSql = " i.notforloan != ? AND ";
        push(@$params, $notNotForLoan);
    }

    push(@$params, $lookbackMaxDate->iso8601(), $lateDate->iso8601(), $branchCode, $borrowerCategory);

    my ($olh_conditionWhere, @olh_conditionParam) = $self->_getSpecialIssueConditionForLetterNumber($overdueRule, $self->{overduerules});
    push @$params, @olh_conditionParam if @olh_conditionParam;

    my $dbh = C4::Context->dbh();
    my $sql =   "SELECT iss.*, b.*, i.* ".
                "FROM issues iss LEFT JOIN borrowers b ON b.borrowernumber = iss.borrowernumber ".
                "               LEFT JOIN message_queue_items mqi ON mqi.issue_id = iss.issue_id ".
                "               LEFT JOIN message_queue mq ON mqi.message_id = mq.message_id ".
                "               LEFT JOIN items i ON i.itemnumber = iss.itemnumber ".
                "WHERE $notNotForLoanSql date(iss.date_due) BETWEEN date(?) AND date(?) AND iss.branchcode = ? AND b.categorycode = ? AND $olh_conditionWhere;";

    my $sth = $dbh->prepare($sql);
    $sth->execute( @$params );
    my $overdues = $sth->fetchall_arrayref({});

    #Report the findings!
    if (ref($overdues) eq 'ARRAY' && scalar(@$overdues) == 0 && $self->{verbose} > 1) {
        print "Found 0 Overdue Issues for $branchCode, $borrowerCategory, $letterNumber, with due date <= ".$lateDate->iso8601()."\n";
    }
    if (ref($overdues) eq 'ARRAY' && scalar(@$overdues) > 0 && $self->{verbose}) {
        print "Found ".scalar(@$overdues)." Overdue Issues for $branchCode, $borrowerCategory, $letterNumber, with due date <= ".$lateDate->iso8601()."\n";
    }
    if ($self->{verbose} > 2) {
        foreach my $param (@$params) {
            $sql =~ s/\?/'$param'/;
        }
        print "Using this SQL:\n$sql\n";
    }

    foreach my $overdue (@$overdues) {
        #Store the overdueRule to the overdue-entry.
        $overdue->{overdueRule} = $overdueRule;
    }
    if ($sortBy) {
        $overdues = _sortBy($overdues, $sortBy, $sortByAlt);
    }

    return $overdues;
}

=head _getSpecialIssueConditionForLetterNumber

    my ($mqi_conditionWhere, $mqi_conditionParam) = _getSpecialIssueConditionForLetterNumber($overdueRule);

We need to make sure that the overdueletters are not sent before borrowers have had sufficient time to react.
For example it is very easy for the overdue message sending module to break at some point and after normal operations
continue, borrower can received overduenotices in a very rapid succession.
In a way overduenotices can become clogged, and then they all are sent as one big swarm of letters.
In the worst case borrowers can get overdue notices 1, 2 and 3 at once!
To save in message sending costs and public relations, it is smart to make sure that
there is a minimum fixed time between all overdue letters.
=cut

sub _getSpecialIssueConditionForLetterNumber {
    my ($self, $overdueRule, $orm) = @_;
    my $letterNumber = $overdueRule->{letterNumber};

    if ($letterNumber == 1) {
        #There are no previous overdue notifications sent for this Issue so we can safely send it away.
        return (" mqi.id IS NULL ",
               );
    }
    elsif ($letterNumber > 1) {
        #We need to calculate how many days apart on minimum letter 1 and 2 need to be.
        #Also letter 1 needs to be sent before we can send letter 2.
        #And letter 2 cannot be sent again! EVER!
        my $previousOverdueRule = $orm->getPreviousOverdueRule($overdueRule);
        my $previousDelay = $previousOverdueRule->{delay};
        my $currentDelay = $overdueRule->{delay};
        my $minimumDeltaBeforeCanSend = $currentDelay - $previousDelay;

        return (" mqi.letternumber = ? AND TO_DAYS(?)-TO_DAYS(mq.time_queued) >= ? AND mq.status = 'sent' ".
                " AND ".
                "  (SELECT issue_id FROM message_queue_items mqi2 ".
                "    LEFT JOIN message_queue mq2 ON mqi2.message_id = mq2.message_id ".
                "    WHERE mqi2.issue_id = mqi.issue_id AND mqi2.letternumber = ? AND mq2.message_transport_type = mq.message_transport_type ".
                "  ) ".
                " IS NULL ",
                $letterNumber-1, #Make sure the previous letter has been sent
                $self->{now}->ymd(), #We can make this check for any day! But I'd prefer today.
                $minimumDeltaBeforeCanSend, #Make sure that enough time has passed since the previous letter has been sent
                $letterNumber, #Make sure that we are not finding same Issues for this same letter again.
                );
    }
    else {
        carp "Overdue letternumber '$letterNumber' is not a real letternumber!\n";
        return (undef,undef);
    }
}

=head _sortByGuarantorId

    $overdues = Koha::Overdues::Finder::_sortBy( $overdues, $hashKey, $altHashKey )

Sorts the given {branchcode => {borrowerCategory => {letterNumber => [ OVERDUEDATA, ... ]}}} -overdues SET
based on $hashKey or $altHashKey if no guarantor is defined.

For example: _sortBy( $overdues, 'guarantorid', 'borrowernumber' );

=cut

sub _sortBy{
    my ($overdues, $hashKey, $altHashKey) = @_;

    my %sortedOverdues;
    foreach my $overdue (@$overdues) {
        my $id = $overdue->{$hashKey} ? $overdue->{$hashKey} : $overdue->{$altHashKey};
        $id = '' unless $id;

        unless (ref $sortedOverdues{ $id }) { #No reference, so it must not be an array
            $sortedOverdues{ $id } = [$overdue]; #Init an array
        }
        else {
            push @{$sortedOverdues{ $id }}, $overdue;
        }
    }
    return \%sortedOverdues;
}

=head findAll

    my $overdues = $finder->findAll();

Finds all the overdue items,
by the holdingbranch, borrowerCategory, letterNumber.
=cut

sub findAllNewOverdues {
    require Koha::Libraries;
    my ($self) = @_;
    my $orm = Koha::Overdues::OverdueRulesMap->new();

    #Find from all branches or from a given subset?
    my $branches = $self->{availableBranches};
    unless (ref $branches eq 'ARRAY') {
        my $overdueCalendar = Koha::Overdues::Calendar->new();
        $branches = $overdueCalendar->getNotifiableBranches();
    }

    #Find from all letterNumbers or from a given subset?
    my $letterNumbers = (ref $self->{letterNumbers} eq 'ARRAY') ? $self->{letterNumbers} : [ 1..$orm->getOverdueNotificationLetterNumbers() ];

    #Find from all borrower categories or from a given subset?
    my $borrowerCategories = (ref $self->{borrowerCategories} eq 'ARRAY') ? $self->{borrowerCategories} : $orm->getBorrowerCategories();

    my $overdues = {};
    foreach my $branchCode (@$branches) {
        foreach my $borCat (@$borrowerCategories) {
            foreach my $letterNumber (  @$letterNumbers  ) { #Iterate each configured overdue notification

                my $overduesSubSet = $self->findNewOverdues($self->{lookback}, $self->{notNotForLoan}, $branchCode, $borCat, $letterNumber, $self->{sortBy}, $self->{sortByAlt});
                $overdues->{$branchCode}->{$borCat}->{$letterNumber} = $overduesSubSet if ((ref $overduesSubSet eq 'HASH' && %$overduesSubSet) || (ref $overduesSubSet eq 'ARRAY' && @$overduesSubSet > 0));
            }
        }
    }
    return $overdues;
}

1; #Satisfy the compiler
