#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2015 Amit Gupta (amitddng135@gmail.com)
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

membership_expiry.pl - cron script to put membership expiry reminders into the message queue

=head1 SYNOPSIS

./membership_expiry.pl -c

or, in crontab:

0 1 * * * membership_expiry.pl -c

=head1 DESCRIPTION

This script sends membership expiry reminder notices to patrons.
It queues them in the message queue, which is processed by
the process_message_queue.pl cronjob.

=head1 OPTIONS

=over 8

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<-v>

Verbose. Without this flag set, only fatal errors are reported.

=item B<-n>

Do not send any email. Membership expire notices that would have been sent to
the patrons are printed to standard out.

=item B<-c>

Confirm flag: Add this option. The script will only print a usage
statement otherwise.

=item B<-branch>

Optional branchcode to restrict the cronjob to that branch.

=item B<-before>

Optional parameter to extend the selection with a number of days BEFORE
the date set by the preference.

=item B<-after>

Optional parameter to extend the selection with a number of days AFTER
the date set by the preference.

=back

=head1 CONFIGURATION

The content of the messages is configured in Tools -> Notices and slips. Use the MEMBERSHIP_EXPIRY notice.

Typically, messages are prepared for each patron when the memberships are going to expire.

These emails are staged in the outgoing message queue, as are messages
produced by other features of Koha. This message queue must be
processed regularly by the
F<misc/cronjobs/process_message_queue.pl> program.

In the event that the C<-n> flag is passed to this program, no emails
are sent. Instead, messages are sent on standard output from this
program.

Notices can contain variables enclosed in double angle brackets like
E<lt>E<lt>thisE<gt>E<gt>. Those variables will be replaced with values
specific to the soon expiring members.
Available variables are:

=over

=item E<lt>E<lt>borrowers.*E<gt>E<gt>

any field from the borrowers table

=item E<lt>E<lt>branches.*E<gt>E<gt>

any field from the branches table

=back

=cut

use Modern::Perl;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Letters;
use C4::Log;

# These are defaults for command line options.
my $confirm;                              # -c: Confirm that the user has read and configured this script.
my $nomail;                               # -n: No mail. Will not send any emails.
my $verbose = 0;                           # -v: verbose
my $help    = 0;
my $man     = 0;
my $before  = 0;
my $after   = 0;
my $branch;

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'c'              => \$confirm,
    'n'              => \$nomail,
    'v'              => \$verbose,
    'branch:s'       => \$branch,
    'before:i'       => \$before,
    'after:i'        => \$after,
) or pod2usage(2);

pod2usage( -verbose => 2 ) if $man;
pod2usage(1) if $help || !$confirm;

cronlogaction();

my $expdays = C4::Context->preference('MembershipExpiryDaysNotice');
if( !$expdays ) {
    #If the pref is not set, we will exit
    warn 'Exiting membership_expiry.pl: MembershipExpiryDaysNotice not set'
        if $verbose;
    exit;
}

my $admin_adress = C4::Context->preference('KohaAdminEmailAddress');
warn 'getting upcoming membership expires' if $verbose;
my $upcoming_mem_expires = C4::Members::GetUpcomingMembershipExpires({ branch => $branch, before => $before, after => $after });
warn 'found ' . scalar( @$upcoming_mem_expires ) . ' soon expiring members'
    if $verbose;

# main loop
foreach my $recent ( @$upcoming_mem_expires ) {
    my $from_address = $recent->{'branchemail'} || $admin_adress;
    my $letter_type = 'MEMBERSHIP_EXPIRY';
    my $letter = C4::Letters::getletter( 'members', $letter_type,
        $recent->{'branchcode'} );
    die "no letter of type '$letter_type' found. Please see sample_notices.sql"
        unless $letter;

    $letter = parse_letter({
        letter         => $letter,
        borrowernumber => $recent->{'borrowernumber'},
        firstname      => $recent->{'firstname'},
        categorycode   => $recent->{'categorycode'},
        branchcode     => $recent->{'branchcode'},
    });
    if ($letter) {
        if ($nomail) {
            print $letter->{'content'}."\n";
        } else {
            C4::Letters::EnqueueLetter({
                letter                 => $letter,
                borrowernumber         =>  $recent->{'borrowernumber'},
                from_address           => $from_address,
                message_transport_type => 'email',
            });
        }
    }
}

=head1 SUBROUTINES

=head2 parse_letter

=cut

sub parse_letter {
    my $params = shift;
    foreach my $required ( qw( letter borrowernumber ) ) {
        return unless exists $params->{$required};
    }
    my $letter =  C4::Letters::GetPreparedLetter (
        module => 'members',
        letter_code => 'MEMBERSHIP_EXPIRY',
        tables => {
            'borrowers', $params->{'borrowernumber'},
            'branches', $params->{'branchcode'}
        },
    );
}
