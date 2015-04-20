package Koha::Overdues::Calendar;

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

use Koha::Caches;
use Koha::Database;
use Koha::DateUtils;
use Koha::Libraries;

sub new {
    my ($class) = @_;

    my $cache = Koha::Caches->get_instance();
    my $oc = $cache->get_from_cache('overdueCalendar');
    unless ($oc) {
        $oc = {};
        bless $oc, $class;
        $oc->_getOverdueCalendarMap();
        $cache->set_in_cache('overdueCalendar', $oc, {expiry => 300});
    }
    return $oc if ref $oc eq 'Koha::Overdues::Calendar';
    return undef;
}

sub _getOverdueCalendarMap {
    my ($self) = @_;

    my @weekdays = $self->getAllWeekdays();
    my %weekdaysByBranch = map { $_->branchcode() => $_ } @weekdays;
    my %weekdays;

    my %branchesFollowingDefaultRules;
    my $allBranches = Koha::Libraries->search;
    foreach my $branchCode (keys %$allBranches) {
        unless ($weekdaysByBranch{ $branchCode }) {
            $branchesFollowingDefaultRules{$branchCode} = 1;
        }
    }

    foreach my $weekdayBranchCode (sort keys %weekdaysByBranch) {
        my @days = split(',', $weekdaysByBranch{$weekdayBranchCode}->weekdays());
        foreach my $day (@days) {
            $weekdays{$day}->{ $weekdayBranchCode } = 1;
        }
    }

    $self->{map} = \%weekdays;
    $self->{defaultBranches} = \%branchesFollowingDefaultRules;
}

=head getNotifiableBranches

    my $allowedBranchCodes = $overdueCalendar->getNotifiableBranches();
    my $allowedBranchCodes = $overdueCalendar->getNotifiableBranches($dateTime);

Gets all the branchCodes from which overdue notifications can now be sent.
Sending for a certain time can be blocked by the overdues manager,
if for ex. a library is closed for a long period of time.

@PARAM1  DateTime, OPTIONAL, the time to check for available notifier branches.
                   DEFAULTS to NOW().
@RETURNS Arrayref of Strings, branchcodes of all the eligible branches.
=cut

sub getNotifiableBranches {
    my ($self, $onDate) = @_;
    my $error;
    if ($onDate) {
        ($onDate, $error) = _sanitateDate($onDate);
        return (undef, $error) if $error;
    }
    else {
        $onDate = DateTime->now( time_zone => C4::Context->tz() );
    }

    my $weekday = $onDate->day_of_week();

    my $branchesByWeekday = $self->getBranchesWithWeekday( $weekday );
    my %branchesByWeekdaySplicable = %$branchesByWeekday if $branchesByWeekday; #Clone the original HASH so we can splice it.
    my %defaultBranchesSplicable = %{$self->{defaultBranches}} if $self->{defaultBranches};
    my @overdueCalendarExceptions = $self->getBranchesWithException($onDate);

    foreach my $ocExceptions (@overdueCalendarExceptions) {
        #Check if the exception applies to branch-specific rules
        if ($branchesByWeekdaySplicable{ $ocExceptions->branchcode() }) {
            delete $branchesByWeekdaySplicable{ $ocExceptions->branchcode() } ;
        }
        #Check if the exception is for a branch using default rules
        elsif ($defaultBranchesSplicable{ $ocExceptions->branchcode() }) {
            delete $defaultBranchesSplicable{ $ocExceptions->branchcode() };
        }
    }

    my @branchCodes;
    foreach my $branchCode (sort keys %branchesByWeekdaySplicable) {
        if ($branchCode eq '') { #Catch the default case
            push @branchCodes, sort(keys(%defaultBranchesSplicable));
        }
        else {
            push @branchCodes, $branchCode;
        }
    }
    return \@branchCodes;
}

sub upsertWeekdays {
    my ($oc, $branchCode, $weekdays) = @_;

    my $error = _validateWeekdays($weekdays);
    return (undef, $error) if $error;

    my $schema = Koha::Database->new()->schema();
    $weekdays = $schema->resultset('OverdueCalendarWeekday')->update_or_create({branchcode => $branchCode,
                                                                                weekdays   => $weekdays
                                                                               });

    my $cache = Koha::Cache->new();
    $oc->_getOverdueCalendarMap();
    $cache->set_in_cache('overdueCalendar', $oc, {expiry => 300});

    return ($weekdays->weekdays, undef) if $weekdays;
}
sub _validateWeekdays {
    my $weekdays = shift;
    $weekdays =~ s/\s+//gsm;
    $weekdays =~ s/,{2,}/,/gsm; #Remove multiple commas
    $weekdays =~ s/(?:^,|,$)//gsm; #Remove leading or trailing commas
    unless ($weekdays || length $weekdays > 0) {
        return 'EMPTYWEEKDAYS';
    }
    unless ($weekdays =~ m/^[1-7,]+$/) { #Weekdays can be only from 1-7
        return 'BADCHARACTERS';
    }
    return undef; #All is OK!
}

sub getWeekdays {
    my ($self, $branchCode) = @_;
    unless (defined($branchCode)) {
        carp "Overdues::Calendar->getWeekdays():> You must give a branchCode whose weekdays you want. Else use getAllWeekdays()";
        return undef;
    }
    my $schema = Koha::Database->new()->schema();
    my $weekdays = $schema->resultset('OverdueCalendarWeekday')->find({branchcode => $branchCode});
    return $weekdays->weekdays if $weekdays;
}
sub getAllWeekdays {
    my $schema = Koha::Database->new()->schema();
    return $schema->resultset('OverdueCalendarWeekday')->search({});
}
sub getBranchesWithWeekday {
    my ($self, $weekday) = @_;

    return $self->{map}->{$weekday} if exists $self->{map}->{$weekday};
}

sub deleteWeekdays {
    my ($self, $branchCode) = @_;
    my $schema = Koha::Database->new()->schema();
    $schema->resultset('OverdueCalendarWeekday')->find({branchcode => $branchCode})->delete();

    $self->_unlinkWeekdays($branchCode);
}
sub _unlinkWeekdays {
    my ($self, $branchCode) = @_;
    my @days=keys %{$self->{map}};
    foreach my $day (@days) {
        delete $self->{map}->{$day}->{$branchCode} if exists $self->{map}->{$day}->{$branchCode};
        delete $self->{map}->{$day} unless scalar(%{$self->{map}->{$day}});
    }
    if ($branchCode eq '') {
        undef $self->{defaultBranches};
    }
    else {
        $self->{defaultBranches}->{$branchCode} = 1;
    }

    my $cache = Koha::Caches->get_instance();
    $cache->set_in_cache('overdueCalendar', $self, {expiry => 300});
}

sub upsertException {
    my ($oc, $branchCode, $exceptionDt) = @_;
    my ($error);

    ($exceptionDt, $error) = _sanitateDate($exceptionDt);
    return (undef, $error) if $error;

    my $schema = Koha::Database->new()->schema();
    my $exception = $schema->resultset('OverdueCalendarException')->update_or_create({branchcode => $branchCode,
                                                                                      exceptiondate   => $exceptionDt->iso8601(),
                                                                                    });

    return _sanitateDate( $exception->exceptiondate ) if $exception;
}
sub _sanitateDate {
    my $exception = shift;
    unless ($exception) {
        return (undef, 'NODATE');
    }
    if (ref $exception eq 'DateTime') {
        return ($exception, undef);
    }
    my $dt = Koha::DateUtils::dt_from_string($exception, 'iso');
    unless($dt) {
        return (undef, 'BADDATE');
    }
    return ($dt, undef); #All is OK!
}

sub getException {
    my ($self, $branchCode, $exceptionDt) = @_;
    my ($error);

    ($exceptionDt, $error) = _sanitateDate($exceptionDt);
    return (undef, $error) if $error;

    my $schema = Koha::Database->new()->schema();
    my $exception = $schema->resultset('OverdueCalendarException')->find({branchcode => $branchCode,
                                                                         exceptiondate => $exceptionDt->iso8601(),
                                                                        });
    return _sanitateDate( $exception->exceptiondate ) if $exception;
}

sub getBranchesWithException {
    my ($self, $exceptionDt) = @_;
    my ($error);

    ($exceptionDt, $error) = _sanitateDate($exceptionDt);
    return (undef, $error) if $error;
    my $schema = Koha::Database->new()->schema();
    return $schema->resultset('OverdueCalendarException')->search({exceptiondate => $exceptionDt->iso8601()});
}

sub getAllExceptions {
    my ($self, $branchCode) = @_;
    my ($error);

    my $schema = Koha::Database->new()->schema();
    my @exceptions = $schema->resultset('OverdueCalendarException')->search({branchcode => $branchCode,
                                                                           });
    return \@exceptions;
}

sub deleteException {
    my ($self, $branchCode, $exceptionDt) = @_;
    my ($error);

    ($exceptionDt, $error) = _sanitateDate($exceptionDt);
    return (undef, $error) if $error;

    my $schema = Koha::Database->new()->schema();
    my $exception = $schema->resultset('OverdueCalendarException')->find({branchcode => $branchCode,
                                                                         exceptiondate => $exceptionDt->iso8601(),
                                                                        });
    $exception->delete() if $exception;
}

sub deleteAllExceptiondays {
    my ($self) = @_;
    my $schema = Koha::Database->new()->schema();
    $schema->resultset('OverdueCalendarException')->search({})->delete_all;
}

sub deleteAllWeekdays {
    my ($self) = @_;
    my $schema = Koha::Database->new()->schema();
    $schema->resultset('OverdueCalendarWeekday')->search({})->delete_all;
    undef $self->{map};
    undef $self->{defaultBranches};
    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache('overdueCalendar');
}

=head toSring

    my ($text, $error) = $calendar->toString('FFL', '2016-01-01', '2016-06-06', undef, undef);
    my ($text, $error) = $calendar->toString('FFL', '2016-01-01', undef, 4, 'weeks');

$error => undef,
          NOENDINGDATE,

$text => YYYY-MM-DD => OK
         YYYY-MM-DD => EXCEPTION
         ...
=cut

sub toString {
    my ($self, $branchCode, $startDt, $toDt, $duration, $durationUnit) = @_;
    my $error;

    ($startDt, $error) = _sanitateDate($startDt);
    return (undef, $error) if $error;
    ($toDt, $error) = _sanitateDate($toDt) if $toDt;
    return (undef, $error) if $error;

    ($toDt, $error) = _calculateEndingDate($startDt, $toDt, $duration, $durationUnit);
    return (undef, $error) if ($error);

    my $weekdays = $self->getWeekdays( $branchCode );
    my $usingDefaultWeekdays;
    unless ($weekdays) {
        $weekdays = $self->getWeekdays( '' ); #Default values
        die "Overdues::Calendar:> No default weekdays given. Dying." unless $weekdays;
        $usingDefaultWeekdays = 1;
    }

    my %availableDays;
    my @days = split(',',$weekdays);
    foreach my $day (@days) {
        $day =~ s/\s+//g;
        my $dayDt = _findWeekday($startDt, $day);
        my $ymds = _repeatWeekdayUntilTimeRunsOut($dayDt, $toDt);
        foreach my $ymd (@$ymds) {
            $availableDays{ $branchCode }->{$ymd} = 'OK'; #Store by branchcode by ymd
        }
    }

    my $exceptions = $self->getAllExceptions($branchCode);
    if ($usingDefaultWeekdays) {
        my $defaultExceptions = $self->getAllExceptions('');
        push @$exceptions, @$defaultExceptions;
    }

    foreach my $exception (@$exceptions) {
        if ($availableDays{ $branchCode }->{$exception->exceptiondate}) {
            $availableDays{ $branchCode }->{$exception->exceptiondate} = 'EXCEPTION'; #Store by branchcode by ymd
        }
    }

    my @text;
    foreach my $branch (sort keys %availableDays) {
        my $ymds = $availableDays{$branch};
        foreach my $ymd (sort keys %$ymds) {
            push(@text, "$ymd => ".$ymds->{$ymd});
        }
    }
    return join("\n", @text);
}
sub _calculateEndingDate {
    my ($startDt, $toDt, $duration, $durationUnit) = @_;

    if (not($toDt) && $duration) {
        $toDt = $startDt->clone();

        $durationUnit = 'days' unless $durationUnit;
        if ($durationUnit eq 'days') {
            $toDt->add(days => $duration);
        }
        elsif ($durationUnit eq 'weeks') {
            $toDt->add(days => $duration*7);
        }
        elsif ($durationUnit eq 'months') {
            $toDt->add(months => $duration);
        }
    }
    else {
        carp "Koha:Overdues::Calendar:> You must give either the ending Date or the duration.";
        return (undef, 'NOENDINGDATE');
    }
    return ($toDt, undef);
}
#Rewind the datetime to the next given weekday
sub _findWeekday {
    my ($dt, $day) = @_;

    $dt = $dt->clone();
    my $dtDow = $dt->day_of_week();
    while ($dtDow != $day) {
        $dtDow = $dt->add(days => 1)->day_of_week();
    }
    return $dt;
}
sub _repeatWeekdayUntilTimeRunsOut {
    my ($dt, $toDt) = @_;
    my @ymds;
    while (DateTime->compare($dt, $toDt) < 1) { #Continue until the toDate, inlcusively
        push(@ymds, $dt->ymd());
        $dt->add(days => 7); #Jump one week forward
    }
    return \@ymds;
}

1; #Satisfy the compiler