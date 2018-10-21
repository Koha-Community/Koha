package C4::SelfService;

# Copyright 2016 KohaSuomi
# Copyright 2018 The National Library of Finland
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

use DateTime::Format::ISO8601;
use Try::Tiny;
use Scalar::Util qw(blessed);
use Carp;

use Time::Piece ();
use YAML::XS;

use C4::Context;
use C4::Log;
use C4::Members::Attributes;
use Koha::Patron::Debarments;
use Koha::Caches;

use Koha::Exception::FeatureUnavailable;
use Koha::Exception::SelfService;
use Koha::Exception::SelfService::Underage;
use Koha::Exception::SelfService::TACNotAccepted;
use Koha::Exception::SelfService::BlockedBorrowerCategory;
use Koha::Exception::SelfService::PermissionRevoked;
use Koha::Exception::SelfService::OpeningHours;

use Koha::Logger;
my $logger = bless({lazyLoad => {category => __PACKAGE__}}, 'Koha::Logger');

=head2 CheckSelfServicePermission

 @param {Koha::Patron or something castable}
 @param {String} Branchcode of the Branch where the user is requesting access
 @param {String} Action the user is trying to do, eg. access the main doors

=cut

sub CheckSelfServicePermission {
    my ($borrower, $requestingBranchcode, $action) = @_;
    $requestingBranchcode = C4::Context->userenv->{branch} unless $requestingBranchcode;
    $action = 'accessMainDoor' unless $action;

    try {
        _HasSelfServicePermission($borrower, $requestingBranchcode, $action);
    } catch {
        $logger->debug("Caught error. Type:'".ref($_)."', stringified: '$_'") if $logger->is_debug;
        unless (blessed($_) && $_->can('rethrow')) {
            confess $_;
        }
        if ($_->isa('Koha::Exception::SelfService::Underage')) {
            _WriteAccessLog($action, $borrower->{borrowernumber}, 'underage');
            $_->rethrow();
        }
        elsif ($_->isa('Koha::Exception::SelfService::TACNotAccepted')) {
            _WriteAccessLog($action, $borrower->{borrowernumber}, 'missingT&C');
            $_->rethrow();
        }
        elsif ($_->isa('Koha::Exception::SelfService::BlockedBorrowerCategory')) {
            _WriteAccessLog($action, $borrower->{borrowernumber}, 'blockBorCat');
            $_->rethrow();
        }
        elsif ($_->isa('Koha::Exception::SelfService::PermissionRevoked')) {
            _WriteAccessLog($action, $borrower->{borrowernumber}, 'revoked');
            $_->rethrow();
        }
        elsif ($_->isa('Koha::Exception::SelfService::OpeningHours')) {
            _WriteAccessLog($action, $borrower->{borrowernumber}, 'closed');
            $_->rethrow();
        }
        elsif ($_->isa('Koha::Exception::SelfService')) {
            _WriteAccessLog($action, $borrower->{borrowernumber}, 'denied');
            $_->rethrow();
        }
        elsif ($_->isa('Koha::Exception::FeatureUnavailable')) {
            _WriteAccessLog($action, $borrower->{borrowernumber}, 'misconfigured');
            $_->rethrow();
        }
        $_->rethrow;
    };
    _WriteAccessLog($action, $borrower->{borrowernumber}, 'granted');
    return 1;
}

sub _HasSelfServicePermission {
    my ($borrower, $requestingBranchcode, $action) = @_;

    my $rules = GetRules();

    _CheckTaC($borrower, $rules)              if ($rules->{TaC});
    _CheckPermission($borrower, $rules)       if ($rules->{Permission});
    _CheckBorrowerCategory($borrower, $rules) if ($rules->{BorrowerCategories});
    _CheckMinimumAge($borrower, $rules)       if ($rules->{MinimumAge});
    _CheckCardExpired($borrower, $rules)      if ($rules->{CardExpired});
    _CheckCardLost($borrower, $rules)         if ($rules->{CardLost});
    _CheckDebarred($borrower, $rules)         if ($rules->{Debarred});
    _CheckMaxFines($borrower, $rules)         if ($rules->{MaxFines});

    if ($rules->{OpeningHours}) {
        $rules->{OpeningHours} = $requestingBranchcode if ($requestingBranchcode);
        _CheckOpeningHours($borrower, $rules);
    }

    return 1;
}

sub _CheckCardLost {
    my ($borrower, $rules) = @_;
    Koha::Exception::SelfService->throw(error => "Card lost") if ($borrower->{lost});
}

sub _CheckCardExpired {
    my ($borrower, $rules) = @_;
    Koha::Exception::SelfService->throw(error => "Card expired") if ($borrower->{dateexpiry} lt Time::Piece::localtime->strftime('%F'));
}

sub _CheckDebarred {
    my ($borrower, $rules) = @_;
    Koha::Exception::SelfService->throw(error => "Debarred") if ($borrower->{debarred});
}

sub _CheckMaxFines {
    my ($borrower, $rules) = @_;

    my $dbh = C4::Context->dbh();
    my @totalFines = $dbh->selectrow_array('SELECT SUM(amountoutstanding) FROM accountlines WHERE borrowernumber = ?', undef, $borrower->{borrowernumber});
    return unless $totalFines[0];
    my $maxFinesBeforeBlock = C4::Context->preference('noissuescharge');
    if ($totalFines[0] >= $maxFinesBeforeBlock) {
        Koha::Exception::SelfService->throw(error => "Too many fines '$totalFines[0]'"); #It might be ok to throw something specific about max fines, but then Toveri needs to be retrofitted to handle the new exception type.
    }
}

sub _CheckMinimumAge {
    my ($borrower, $rules) = @_;
    if ($borrower->{dateofbirth}) {
        my $dob = DateTime::Format::ISO8601->parse_datetime($borrower->{dateofbirth});
        $dob->set_time_zone( C4::Context->tz() );
        my $minimumDob = DateTime->now(time_zone => C4::Context->tz())->subtract(years => $rules->{MinimumAge});
        if (DateTime->compare($dob, $minimumDob) < 0) {
            return 1;
        }
    }

    Koha::Exception::SelfService::Underage->throw(minimumAge => $rules->{MinimumAge});
}

sub _CheckTaC {
    my ($borrower, $rules) = @_;
    my $agreement = C4::Members::Attributes::GetBorrowerAttributeValue($borrower->{borrowernumber}, 'SST&C');
    unless ($agreement) {
        Koha::Exception::SelfService::TACNotAccepted->throw();
    }
}

sub _CheckPermission {
    my ($borrower, $rules) = @_;
    my $ban = C4::Members::Attributes::GetBorrowerAttributeValue($borrower->{borrowernumber}, 'SSBAN');
    if ($ban) {
        Koha::Exception::SelfService::PermissionRevoked->throw();
    }
}

sub _CheckBorrowerCategory {
    my ($borrower, $rules) = @_;

    unless ($borrower->{categorycode} && $rules->{BorrowerCategories} =~ /$borrower->{categorycode}/) {
        Koha::Exception::SelfService::BlockedBorrowerCategory->throw(error => "Borrower category '".$borrower->{categorycode}."' is not allowed");
    }
}

sub _CheckOpeningHours {
    my ($borrower, $rules) = @_;
    my $branchcode = $rules->{OpeningHours};
    # If no branchcode to check the opening hours for has been given, let it pass. This is important to allow using the same code from block list generating code, and for realtime checks.
    return 1 unless ($branchcode);

    unless (Koha::Libraries::isOpen($branchcode)) {
        my $openingHours = Koha::Libraries::getOpeningHours($branchcode);
        Koha::Exception::SelfService::OpeningHours->throw(
            error => "Self-service resource closed at this time. Try again later.",
            startTime => $openingHours->[0],
            endTime => $openingHours->[1],
        );
    }
}

sub GetAccessLogs {
    my ($userNumber) = @_;

    return C4::Log::GetLogs(undef, undef, undef, ['SS'], undef, $userNumber, undef);
}

=head2 _WriteAccessLog

@PARAM1 String, action to log, typically 'accessMainDoor' or other Self-service component
@PARAM2 Int, the borrowernumber of the user accessing the Self-service resource
@PARAM3 String, what was the outcome of the authorization? Typically 'denied', 'granted', 'underage', 'missingT&C'
@RETURNS undef, since C4::Log has no useful return values.

=cut

sub _WriteAccessLog {
    my ($action, $accessingBorrowernumber, $resolution) = @_;
    C4::Log::logaction('SS', $action, $accessingBorrowernumber, $resolution);
}

=head2

Deletes all Self-service logs from the koha.action_logs-table

=cut

sub FlushLogs {
    C4::Context->dbh->do("DELETE FROM action_logs WHERE module = 'SS'");
}

=head2 GetRules

    my $rules = GetRules();

Retrieves the Self-Service rules. This is basically a list of checks triggered, with the corresponding parameters if any.

@RETURNS HASHRef of:
            'TaC'                => Boolean, Terms and conditions of self-service usage accepted
            'Permission'         => Boolean, permissions to access the self-service resource. Basically not having SSBAN -borrower attribute.
            'BorrowerCategories' => String, list of allowed borrower categories
            'MinimumAge'         => Integer, age limit for self-service resources
            'CardExpired'        => Boolean, check for expired card
            'CardLost'           => Boolean, check for a lost card
            'Debarred'           => Boolean, check if user account is debarred
            'MaxFines'           => Boolean, checks the syspref 'MaxFine' against the borrowers accumulated fines,
            'OpeningHours'       => Boolean, use the syspref 'OpeningHours' to check against the current time and branch.

@THROWS Koha::Exception::FeatureUnavailable if SSRules is not properly configured

=cut

sub GetRules {
    my $cache = Koha::Caches->get_instance();
    my $rules = $cache->get_from_cache('SSRules');
    return $rules if $rules;

    my $ssrules = C4::Context->preference('SSRules');
    $rules = eval { YAML::XS::Load($ssrules) };
    if ($rules && ref($rules) eq 'HASH') {
        $cache->set_in_cache('SSRules', $rules, {expiry => 300});
        return $rules;
    }

    Koha::Exception::FeatureUnavailable->throw(error => "System preference 'SSRules' '".($ssrules||'undef')."' is not properly defined: $@");
}

1;
