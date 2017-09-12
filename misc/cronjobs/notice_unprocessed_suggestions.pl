#!/usr/bin/perl

use Modern::Perl;

use Pod::Usage;
use Getopt::Long;

use C4::Budgets qw( GetBudget );
use C4::Suggestions qw( GetUnprocessedSuggestions );
use Koha::Libraries;
use Koha::Patrons;

my ( $help, $verbose, $confirm, @days );
GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'days:s'    => \@days,
    'c|confirm' => \$confirm,
) || pod2usage( verbose => 2 );

if ($help) {
    pod2usage( verbose => 2 );
}

unless (@days) {
    pod2usage(q{At least one day parameter should be given});
    exit;
}

unless ($confirm) {
    say "Doing a dry run; no email will be sent.";
    say "Run again with --confirm to send emails.";
    $verbose = 1 unless $verbose;
}

for my $number_of_days (@days) {
    say "Searching suggestions suggested $number_of_days days ago" if $verbose;

    my $suggestions = C4::Suggestions::GetUnprocessedSuggestions($number_of_days);

    say "No suggestion found" if $verbose and not @$suggestions;

    for my $suggestion (@$suggestions) {

        say "Suggestion $suggestion->{suggestionid} should be processed" if $verbose;

        my $budget = C4::Budgets::GetBudget( $suggestion->{budgetid} );
        my $patron = Koha::Patrons->find( $budget->{budget_owner_id} );
        my $email_address = $patron->notice_email_address;
        my $library = $patron->library;
        my $admin_email_address = $library->branchemail
          || C4::Context->preference('KohaAdminEmailAddress');

        if ($email_address) {
            say "Patron " . $patron->borrowernumber . " is going to be notified" if $verbose;
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'suggestions',
                letter_code => 'TO_PROCESS',
                branchcode  => $patron->branchcode,
                lang        => $patron->lang,
                tables      => {
                    suggestions => $suggestion->{suggestionid},
                    branches    => $patron->branchcode,
                    borrowers   => $patron->borrowernumber,
                },
            );
            if ( $confirm ) {
                C4::Letters::EnqueueLetter(
                    {
                        letter                 => $letter,
                        borrowernumber         => $patron->borrowernumber,
                        message_transport_type => 'email',
                        from_address           => $admin_email_address,
                    }
                );
            }
        } else {
            say "Patron " . $patron->borrowernumber . " does not have an email address" if $verbose;
        }
    }

}

=head1 NAME

notice_unprocessed_suggestions.pl - Generate notification for unprocessed suggestions.

The budget owner will be notified.

The letter template 'TO_PROCESS' will be used.

=head1 SYNOPSIS

notice_unprocessed_suggestions.pl [-h|--help] [-v|--verbose] [-c|--confirm] [--days=NUMBER_OF_DAYS]

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<-c|--confirm>

This flag must be provided in order for the script to actually
generate notices.  If it is not supplied, the script will
only report on the patron it would have noticed.

=item B<--days>

This parameter is mandatory.
It must contain an integer representing the number of days elapsed since the last modification of suggestions to process.

=item B<-v|--verbose>

Verbose mode.

=back

=head1 AUTHOR

Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT

Copyright 2014 BibLibre

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along
with Koha; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=cut
