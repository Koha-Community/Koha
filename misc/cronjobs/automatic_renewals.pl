#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2014 Hochschule für Gesundheit (hsg), Germany
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

automatic_renewals.pl - cron script to renew loans

=head1 SYNOPSIS

./automatic_renewals.pl [-c|--confirm] [--send-notices]

or, in crontab:
0 3 * * * automatic_renewals.pl -c

=head1 DESCRIPTION

This script searches for issues scheduled for automatic renewal
(issues.auto_renew). If there are still renews left (Renewals allowed)
and the renewal isn't premature (No Renewal before) the issue is renewed.

=head1 OPTIONS

=over

=item B<--send-notices>

Send AUTO_RENEWALS notices to patrons if the auto renewal has been done.

Note that this option does not support digest yet.

=item B<-v|--verbose>

Print report to standard out.

=item B<-c|--confirm>

Without this parameter no changes will be made

=back

=cut

use Modern::Perl;
use Pod::Usage;
use Getopt::Long;

use Koha::Script -cron;
use C4::Circulation;
use C4::Context;
use C4::Log;
use C4::Letters;
use Koha::Checkouts;
use Koha::Libraries;
use Koha::Patrons;

my ( $help, $send_notices, $verbose, $confirm );
GetOptions(
    'h|help' => \$help,
    'send-notices' => \$send_notices,
    'v|verbose'    => \$verbose,
    'c|confirm'     => \$confirm,
) || pod2usage(1);

pod2usage(0) if $help;
cronlogaction();

my $auto_renews = Koha::Checkouts->search({ auto_renew => 1, 'borrower.autorenew_checkouts' => 1 },{ join => 'borrower'});

my %report;
$verbose = 1 unless $verbose or $confirm;
print "Test run only\n" unless $confirm;
while ( my $auto_renew = $auto_renews->next ) {

    # CanBookBeRenewed returns 'auto_renew' when the renewal should be done by this script
    my ( $ok, $error ) = CanBookBeRenewed( $auto_renew->borrowernumber, $auto_renew->itemnumber, undef, 1 );
    if ( $error eq 'auto_renew' ) {
        if ($verbose) {
            say sprintf "Issue id: %s for borrower: %s and item: %s ". ( $confirm ? 'will' : 'would') . " be renewed.",
              $auto_renew->issue_id, $auto_renew->borrowernumber, $auto_renew->itemnumber;
        }
        if ($confirm){
            my $date_due = AddRenewal( $auto_renew->borrowernumber, $auto_renew->itemnumber, $auto_renew->branchcode );
            $auto_renew->auto_renew_error(undef)->store;
        }
        push @{ $report{ $auto_renew->borrowernumber } }, $auto_renew;
    } elsif ( $error eq 'too_many'
        or $error eq 'on_reserve'
        or $error eq 'restriction'
        or $error eq 'overdue'
        or $error eq 'auto_account_expired'
        or $error eq 'auto_too_late'
        or $error eq 'auto_too_much_oweing'
        or $error eq 'auto_too_soon'
        or $error eq 'item_denied_renewal' ) {
        if ( $verbose ) {
            say sprintf "Issue id: %s for borrower: %s and item: %s ". ( $confirm ? 'will' : 'would') . " not be renewed. (%s)",
              $auto_renew->issue_id, $auto_renew->borrowernumber, $auto_renew->itemnumber, $error;
        }
        if ( not $auto_renew->auto_renew_error or $error ne $auto_renew->auto_renew_error ) {
            $auto_renew->auto_renew_error($error)->store if $confirm;
            push @{ $report{ $auto_renew->borrowernumber } }, $auto_renew
              if $error ne 'auto_too_soon';    # Do not notify if it's too soon
        }
    }
}

if ( $send_notices ) {
    for my $borrowernumber ( keys %report ) {
        my $patron = Koha::Patrons->find($borrowernumber);
        for my $issue ( @{ $report{$borrowernumber} } ) {
            my $item   = Koha::Items->find( $issue->itemnumber );
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'circulation',
                letter_code => 'AUTO_RENEWALS',
                tables      => {
                    borrowers => $patron->borrowernumber,
                    issues    => $issue->itemnumber,
                    items     => $issue->itemnumber,
                    biblio    => $item->biblionumber,
                },
                lang => $patron->lang,
            );

            my $library = Koha::Libraries->find( $patron->branchcode );
            my $admin_email_address = $library->branchemail || C4::Context->preference('KohaAdminEmailAddress');

            C4::Letters::EnqueueLetter(
                {   letter                 => $letter,
                    borrowernumber         => $borrowernumber,
                    message_transport_type => 'email',
                    from_address           => $admin_email_address,
                }
            ) if $confirm;
        }
    }
}
