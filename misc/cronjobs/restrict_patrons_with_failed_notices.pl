#!/usr/bin/perl

# Copyright 2020 Catalyst IT
#
# This file is part of Koha.
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

use Modern::Perl;

use Getopt::Long;
use Pod::Usage;
use C4::Log;

use C4::Context;
use Koha::Patrons;
use C4::Letters;
use Koha::Notice::Message;

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

# Getting options
my ( $help, $verbose, $confirm );
GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'c|confirm' => \$confirm,
);

pod2usage(1) if $help;

if ( !C4::Context->preference('RestrictPatronsWithFailedNotices') and $verbose ) {
    warn <<'END_WARN';

The 'RestrictPatronsWithFailedNotices' system preference is disabled.
This script requires the 'RestrictPatronsWithFailedNotices' system preference to be enabled.
Exiting cronjob

END_WARN
}

my @failed_notices = Koha::Notice::Messages->get_failed_notices( { days => 7 } )->as_list;

if ( C4::Context->preference('RestrictPatronsWithFailedNotices') ) {
    if (@failed_notices) {
        say "There are patrons with failed SMS or email notices" if $verbose;

        foreach my $failed_notice (@failed_notices) {

            # If failed notice is not a sms or email notice then skip to next failed notice
            next
                unless ( $failed_notice->message_transport_type eq 'sms'
                || $failed_notice->message_transport_type eq 'email' );

            # If failed sms or email notice has no recipient patron then skip to next failed
            # notice
            next unless $failed_notice->borrowernumber;

            # Find the patron recipient of the failed SMS or email notice.
            my $patron = Koha::Patrons->find( $failed_notice->borrowernumber );

            # Check if patron of failed SMS or email notice is already restricted due to having
            # this happen before. If they are already restricted due to having invalid SMS or
            # email address don't apply a new restriction (debarment) to their account.
            if ( $patron->restrictions->search( { comment => 'SMS number invalid' } )->count > 0 ) {
                say "Patron "
                    . $patron->borrowernumber . ":" . " "
                    . $patron->firstname . " "
                    . $patron->surname . " "
                    . "is currently restricted due to having an invalid SMS number. No new restriction applied"
                    if $verbose;
                next;
            } elsif ( $patron->restrictions->search( { comment => 'Email address invalid' } )->count > 0 ) {
                say "Patron "
                    . $patron->borrowernumber . ":" . " "
                    . $patron->firstname . " "
                    . $patron->surname . " "
                    . "is currently restricted due to having an invalid email address. No new restriction applied"
                    if $verbose;
                next;
            }
            if ($confirm) {

                # Patron has not been previously restricted for having failed SMS
                # or email addresses apply a restriction now.
                say "Applying restriction to patron "
                    . $patron->borrowernumber . ":" . " "
                    . $patron->firstname . " "
                    . $patron->surname
                    if $verbose;
                $failed_notice->restrict_patron_when_notice_fails;
            }
        }
    } else {
        say "There are no failed SMS or email notices" if $verbose;
    }
}

exit(0);

__END__

=head1 NAME

restrict_patrons_with_failed_notices.pl

=head1 SYNOPSIS

./restrict_patrons_with_failed_notices.pl -h

Use this script to creates a debarment for all patrons with failed SMS and email notices.

The 'RestrictPatronsWithFailedNotices' syspref must be enabled for this script to place restrictions to patrons accounts.

=head1 OPTIONS

=over 8

=item B<-h|--help>

Prints this help message

=item B<-v|--verbose>

Set the verbose flag

=item B<-c|--confirm>

The script will alter the database placing a restriction on patrons with failed SMS and email notices.

=back

=head1 AUTHOR

Alex Buckley <alexbuckley@catalyst.net.nz>

=head1 COPYRIGHT

Copyright 2019 Catalyst IT

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.

=cut
