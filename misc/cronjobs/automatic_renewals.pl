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

./automatic_renewals.pl [-c|--confirm] [-s|--send-notices] [-d|--digest] [-b|--digest-per-branch] [-v|--verbose]

or, in crontab:
# Once every day for digest messages
0 3 * * * automatic_renewals.pl -c -d
# Three times a day for non digest messages
0 0,8,16 * * * automatic_renewals.pl -c

=head1 DESCRIPTION

This script searches for issues scheduled for automatic renewal
(issues.auto_renew). If there are still renews left (Renewals allowed)
and the renewal isn't premature (No Renewal before) the issue is renewed.

=head1 OPTIONS

=over

=item B<-s|--send-notices>

DEPRECATED: The system preference AutoRenewalNotices should be used to determine
whether notices are sent or not
Send AUTO_RENEWALS notices to patrons if the auto renewal has been done.

=item B<-v|--verbose>

Print report to standard out.

=item B<-c|--confirm>

Without this parameter no changes will be made

=item B<-b|--digest-per-branch>

Flag to indicate that generation of message digests should be
performed separately for each branch.

A patron could potentially have loans at several different branches
There is no natural branch to set as the sender on the aggregated
message in this situation so the default behavior is to use the
borrowers home branch.  This could surprise to the borrower when
message sender is a library where they have not borrowed anything.

Enabling this flag ensures that the issuing library is the sender of
the digested message.  It has no effect unless the borrower has
chosen 'Digests only' on the advance messages.

=back

=cut

use Modern::Perl;
use Pod::Usage qw( pod2usage );
use Getopt::Long qw( GetOptions );

use Koha::Script -cron;
use C4::Circulation qw( CanBookBeRenewed AddRenewal );
use C4::Context;
use C4::Log qw( cronlogaction );
use C4::Letters;
use Koha::Checkouts;
use Koha::Libraries;
use Koha::Patrons;

my $command_line_options = join(" ",@ARGV);

my ( $help, $send_notices, $verbose, $confirm, $digest_per_branch );
GetOptions(
    'h|help' => \$help,
    's|send-notices' => \$send_notices,
    'v|verbose'    => \$verbose,
    'c|confirm'     => \$confirm,
    'b|digest-per-branch' => \$digest_per_branch,
) || pod2usage(1);

pod2usage(0) if $help;

my $send_notices_pref = C4::Context->preference('AutoRenewalNotices');
if ( $send_notices_pref eq 'cron' ) {
    warn <<'END_WARN';

The "AutoRenewalNotices" syspref is set to 'Follow the cron switch'.
The send_notices switch for this script is deprecated, you should either set the preference
to 'Never send emails' or 'Follow patron messaging preferences'

END_WARN
} else {
    # If not following cron then:
    # - we should not send if set to never
    # - we will send any notice generated according to preferences if following those
    $send_notices = $send_notices_pref eq 'never' ? 0 : 1;
}

# Since advance notice options are not visible in the web-interface
# unless EnhancedMessagingPreferences is on, let the user know that
# this script probably isn't going to do much
if ( ! C4::Context->preference('EnhancedMessagingPreferences') ) {
    warn <<'END_WARN';

The "EnhancedMessagingPreferences" syspref is off.
Therefore, it is unlikely that this script will actually produce any messages to be sent.
To change this, edit the "EnhancedMessagingPreferences" syspref.

END_WARN
}

cronlogaction({ info => $command_line_options });

$verbose = 1 unless $verbose or $confirm;
print "Test run only\n" unless $confirm;

print "getting auto renewals\n" if $verbose;
my $auto_renews = Koha::Checkouts->search(
    {
        auto_renew                   => 1,
        'patron.autorenew_checkouts' => 1,
    },
    {
        join => ['patron','item']
    }
);
print "found " . $auto_renews->count . " auto renewals\n" if $verbose;

my $renew_digest = {};
my %report;
my @item_renewal_ids;
while ( my $auto_renew = $auto_renews->next ) {
    print "examining item '" . $auto_renew->itemnumber . "' to auto renew\n" if $verbose;

    my ( $borrower_preferences, $wants_messages, $wants_digest ) = ( undef, 0, 0 );
    if ( $send_notices_pref eq 'preferences' ){
        $borrower_preferences = C4::Members::Messaging::GetMessagingPreferences(
            {
                borrowernumber => $auto_renew->borrowernumber,
                message_name   => 'auto_renewals'
            }
        );
        $wants_messages = 1
            if $borrower_preferences
            && $borrower_preferences->{transports};
        $wants_digest = 1
            if $wants_messages
            && $borrower_preferences->{wants_digest};
    } else { # Preference is never or cron
        $wants_messages = $send_notices;
        $wants_digest = 0;
    }

    # CanBookBeRenewed returns 'auto_renew' when the renewal should be done by this script
    my ( $ok, $error ) = CanBookBeRenewed( $auto_renew->patron, $auto_renew, undef, 1 );
    my $updated;
    if ( $error eq 'auto_renew' ) {
        $updated = 1;
        if ($verbose) {
            say sprintf "Issue id: %s for borrower: %s and item: %s %s be renewed.",
              $auto_renew->issue_id, $auto_renew->borrowernumber, $auto_renew->itemnumber, $confirm ? 'will' : 'would';
        }
        if ($confirm){
            my $date_due = AddRenewal({
                borrowernumber => $auto_renew->borrowernumber,
                itemnumber => $auto_renew->itemnumber,
                branch => $auto_renew->branchcode,
                seen => 0,
                automatic => 1,
            });
            push @item_renewal_ids, $auto_renew->itemnumber;
            $auto_renew->auto_renew_error(undef)->store;
        }
        push @{ $report{ $auto_renew->borrowernumber } }, $auto_renew
            if ( $wants_messages ) && !$wants_digest;
    } elsif (
        $error eq 'too_many' ||
        $error eq 'on_reserve' ||
        $error eq 'restriction' ||
        $error eq 'overdue' ||
        $error eq 'too_unseen' ||
        $error eq 'auto_account_expired' ||
        $error eq 'auto_too_late' ||
        $error eq 'auto_too_much_oweing' ||
        $error eq 'auto_too_soon' ||
        $error eq 'item_denied_renewal' ||
        $error eq 'item_issued_to_other_patron'
    ) {
        if ( $verbose ) {
            say sprintf "Issue id: %s for borrower: %s and item: %s %s not be renewed. (%s)",
              $auto_renew->issue_id, $auto_renew->borrowernumber, $auto_renew->itemnumber, $confirm ? 'will' : 'would', $error;
        }
        $updated = 1 if (!$auto_renew->auto_renew_error || $error ne $auto_renew->auto_renew_error);
        if ( $updated ) {
            $auto_renew->auto_renew_error($error)->store if $confirm;
            push @{ $report{ $auto_renew->borrowernumber } }, $auto_renew
              if $error ne 'auto_too_soon' && ( $wants_messages  && !$wants_digest );    # Do not notify if it's too soon
        }
    }

    if ( $wants_digest ) {
        # cache this one to process after we've run through all of the items.
        if ($digest_per_branch) {
            $renew_digest->{ $auto_renew->branchcode }->{ $auto_renew->borrowernumber }->{success}++ if $error eq 'auto_renew';
            $renew_digest->{ $auto_renew->branchcode }->{ $auto_renew->borrowernumber }->{error}++ unless $error eq 'auto_renew' || $error eq 'auto_too_soon';
            $renew_digest->{ $auto_renew->branchcode }->{ $auto_renew->borrowernumber }->{results}->{$error}++ ;
            push @{$renew_digest->{ $auto_renew->branchcode }->{ $auto_renew->borrowernumber }->{issues}}, $auto_renew->itemnumber;
            $renew_digest->{ $auto_renew->branchcode }->{ $auto_renew->borrowernumber }->{updated} = 1 if $updated && $error ne 'auto_too_soon';
        } else {
            $renew_digest->{ $auto_renew->borrowernumber }->{success} ++ if $error eq 'auto_renew';
            $renew_digest->{ $auto_renew->borrowernumber }->{error}++ unless $error eq 'auto_renew' || $error eq 'auto_too_soon';
            $renew_digest->{ $auto_renew->borrowernumber }->{results}->{$error}++ ;
            $renew_digest->{ $auto_renew->borrowernumber }->{updated} = 1 if $updated && $error ne 'auto_too_soon';
            push @{$renew_digest->{ $auto_renew->borrowernumber }->{issues}}, $auto_renew->itemnumber;
        }
    }

}

if( @item_renewal_ids ){
    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    $indexer->index_records( \@item_renewal_ids, "specialUpdate", "biblioserver" );
}

if ( $send_notices && $confirm ) {
    for my $borrowernumber ( keys %report ) {
        my $patron = Koha::Patrons->find($borrowernumber);
        my $borrower_preferences =
            C4::Members::Messaging::GetMessagingPreferences(
                {
                    borrowernumber => $borrowernumber,
                    message_name   => 'auto_renewals'
                }
            );
        for my $issue ( @{ $report{$borrowernumber} } ) {
            my $item = $issue->item;
            # Force sending of email and only email if pref is set to "cron"
            my @transports = $send_notices_pref eq 'preferences' ? keys %{ $borrower_preferences->{'transports'} } : 'email';
            foreach my $transport ( @transports ) {
                my $letter = C4::Letters::GetPreparedLetter (
                    module      => 'circulation',
                    letter_code => 'AUTO_RENEWALS',
                    tables      => {
                        borrowers => $patron->borrowernumber,
                        issues    => $issue->itemnumber,
                        items     => $issue->itemnumber,
                        biblio    => $item->biblionumber,
                    },
                    lang => $patron->lang,
                    message_transport_type => $transport,
                );

                if ($letter) {
                    my $library = $patron->library;
                    my $admin_email_address = $library->from_email_address;

                    C4::Letters::EnqueueLetter(
                        {
                            letter                 => $letter,
                            borrowernumber         => $borrowernumber,
                            from_address           => $admin_email_address,
                            message_transport_type => $transport
                        }
                    );
                }
            }
        }
    }

    if ($digest_per_branch) {
        while (my ($branchcode, $digests) = each %$renew_digest) {
            send_digests({
                digests => $digests,
                branchcode => $branchcode,
                letter_code => 'AUTO_RENEWALS_DGST',
            });
        }
    } else {
        send_digests({
            digests => $renew_digest,
            letter_code => 'AUTO_RENEWALS_DGST',
        });
    }
}

cronlogaction({ action => 'End', info => "COMPLETED" });

=head1 METHODS

=head2 send_digests

    send_digests({
        digests => ...,
        letter_code => ...,
    })

Enqueue digested letters.

Parameters:

=over 4

=item C<$digests>

Reference to the array of digested messages.

=item C<$letter_code>

String that denote the letter code.

=back

=cut

sub send_digests {
    my $params = shift;

    PATRON: while ( my ( $borrowernumber, $digest ) = each %{$params->{digests}} ) {
        next unless defined $digest->{updated} && $digest->{updated} == 1;
        my $borrower_preferences =
            C4::Members::Messaging::GetMessagingPreferences(
                {
                    borrowernumber => $borrowernumber,
                    message_name   => 'auto_renewals'
                }
            );

        next PATRON unless $borrower_preferences; # how could this happen?

        my $patron = Koha::Patrons->find( $borrowernumber );
        my $branchcode;
        if ( defined $params->{branchcode} ) {
            $branchcode = $params->{branchcode};
        } else {
            $branchcode = $patron->branchcode;
        }
        my $library = Koha::Libraries->find( $branchcode );
        my $from_address = $library->from_email_address;

        foreach my $transport ( keys %{ $borrower_preferences->{'transports'} } ) {
            my $letter = C4::Letters::GetPreparedLetter (
                module => 'circulation',
                letter_code => $params->{letter_code},
                branchcode => $branchcode,
                lang => $patron->lang,
                substitute => {
                    error => $digest->{error}||0,
                    success => $digest->{success}||0,
                    results => $digest->{results},
                },
                loops => { issues => \@{$digest->{issues}} },
                tables      => {
                    borrowers => $patron->borrowernumber,
                },
                message_transport_type => $transport,
            );

            if ($letter) {
                C4::Letters::EnqueueLetter(
                    {
                        letter                 => $letter,
                        borrowernumber         => $borrowernumber,
                        from_address           => $from_address,
                        message_transport_type => $transport
                    }
                );
            }
            else {
                warn
"no letter of type '$params->{letter_code}' found for borrowernumber $borrowernumber. Please see sample_notices.sql";
            }

        }
    }
}
