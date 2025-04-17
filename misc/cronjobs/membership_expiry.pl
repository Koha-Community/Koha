#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2023 Koha development team
# Copyright 2015 Amit Gupta (amitddng135@gmail.com)
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

./membership_expiry.pl -c [-v] [-n] [-branch CODE] [-before DAYS] [-after DAYS] [-where COND] [-renew] [-letter X] [-letter-renew Y] [-active|-inactive]

or, in crontab:

0 1 * * * membership_expiry.pl -c [other options you need as mentioned above]

=head1 DESCRIPTION

This script sends membership expiry reminder notices to patrons, by email and sms.
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


=item B<-p>

Force the generation of print notices, even if the borrower has an email address.
Note that this flag cannot be used in combination with -n

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

=item B<-where>

Use this option to specify a condition built with columns from the borrowers table

e.g.
--where 'lastseen IS NOT NULL'
will only notify patrons who have been seen.

=item B<-letter>

Optional parameter to use another expiry notice than the default: MEMBERSHIP_EXPIRY

=item B<-letter_renew>

Optional parameter to use another renewal notice than the default: MEMBERSHIP_RENEWED

=item B<-active>

Optional parameter to include active patrons only (active within passed number of months).
This parameter needs the preference TrackLastPatronActivityTriggers.

IMPORTANT: You should be using those triggers already for the period that you
consider a user to be (in)active.

=item B<-inactive>

Optional parameter to include inactive patrons only (inactive within passed number of months).
This allows you to e.g. send expiry warnings only to inactive patrons.
This parameter needs the preference TrackLastPatronActivityTriggers.

IMPORTANT: You should be using those triggers already for the period that you
consider a user to be (in)active.

=item B<-renew>

Optional parameter to automatically renew patrons instead of sending them an expiry notice.
They will be informed by a patron renewal notice.

=back

=head1 CONFIGURATION

The content of the messages is configured in Tools -> Notices and slips. Use the MEMBERSHIP_EXPIRY notice or
supply another via the parameters.

Typically, messages are prepared for each patron when the memberships are going to expire.

These emails are staged in the outgoing message queue, as are messages
produced by other features of Koha. This message queue must be
processed regularly by the
F<misc/cronjobs/process_message_queue.pl> program.

In the event that the C<-n> flag is passed to this program, no emails
are sent. Instead, messages are sent on standard output from this
program.

When using the C<-p> flag, print notices are generated regardless of whether or
not the borrower has an email address. This can be useful for libraries that
prefer to deal with print notices.

Notices can contain variables enclosed in double angle brackets like
<<this>>. Those variables will be replaced with values
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
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );

use Koha::Script -cron;
use C4::Context;
use C4::Letters;
use C4::Log qw( cronlogaction );

use Koha::Patrons;

# These are defaults for command line options.
my $confirm;        # -c: Confirm that the user has read and configured this script.
my $nomail;         # -n: No mail. Will not send any emails.
my $forceprint;     # -p: Force print notices, even if email is found
my $verbose = 0;    # -v: verbose
my $help    = 0;
my $man     = 0;
my $before  = 0;
my $after   = 0;
my $branch;
my @where;
my $active;
my $inactive;
my $renew;
my $letter_expiry;
my $letter_renew;

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'c'              => \$confirm,
    'n'              => \$nomail,
    'p'              => \$forceprint,
    'v'              => \$verbose,
    'branch:s'       => \$branch,
    'before:i'       => \$before,
    'after:i'        => \$after,
    'letter:s'       => \$letter_expiry,
    'letter_renew:s' => \$letter_renew,
    'where=s'        => \@where,
    'active:i'       => \$active,
    'inactive:i'     => \$inactive,
    'renew'          => \$renew,
) or pod2usage(2);
$letter_expiry = 'MEMBERSHIP_EXPIRY'  if !$letter_expiry;
$letter_renew  = 'MEMBERSHIP_RENEWED' if !$letter_renew;

pod2usage( -verbose => 2 ) if $man;
pod2usage(1)               if $help || !$confirm;

# Check active/inactive. Note that passing no value or zero is a no-op.
if ( !C4::Context->preference('TrackLastPatronActivityTriggers')
    && ( $active || $inactive ) )
{
    pod2usage(
        -verbose => 1,
        -msg     =>
            q{Exiting membership_expiry.pl: Using --active or --inactive needs use of TrackLastPatronActivityTriggers over specified period},
        -exitval => 1
    );
} elsif ( $active && $inactive ) {
    pod2usage(
        -verbose => 1,
        -msg     => q{The --active and --inactive flags are mutually exclusive},
        -exitval => 1
    );
} elsif ( ( defined $active && !$active ) || ( defined $inactive && !$inactive ) ) {
    pod2usage(
        -verbose => 1,
        -msg     => q{Options --active and --inactive need a number of months},
        -exitval => 1
    );
}

my $expdays = C4::Context->preference('MembershipExpiryDaysNotice');
if ( !$expdays ) {

    #If the pref is not set, we will exit
    warn 'Exiting membership_expiry.pl: MembershipExpiryDaysNotice not set'
        if $verbose;
    exit;
}

warn 'getting upcoming membership expires' if $verbose;
my $upcoming_mem_expires = Koha::Patrons->search_upcoming_membership_expires(
    {
        ( $branch ? ( 'me.branchcode' => $branch ) : () ),
        before => $before,
        after  => $after,
    }
);
my @mandatory_expiry_notice_categories =
    map { $_->categorycode } Koha::Patron::Categories->search( { 'me.enforce_expiry_notice' => 1 } )->as_list;

my $where_literal = join ' AND ', @where;
$upcoming_mem_expires = $upcoming_mem_expires->search( \$where_literal ) if @where;

warn 'found ' . $upcoming_mem_expires->count . ' soon expiring members'
    if $verbose;

# main loop
my ( $count_skipped, $count_renewed, $count_enqueued ) = ( 0, 0, 0 );
while ( my $expiring_patron = $upcoming_mem_expires->next ) {
    if ( $active && !$expiring_patron->is_active( { months => $active } ) ) {
        $count_skipped++;
        next;
    } elsif ( $inactive && $expiring_patron->is_active( { months => $inactive } ) ) {
        $count_skipped++;
        next;
    }

    my $which_notice;
    if ($renew) {
        $expiring_patron->renew_account;
        $which_notice = $letter_renew;
        $count_renewed++;
    } else {
        $which_notice = $letter_expiry;
    }

    my $from_address  = $expiring_patron->library->from_email_address;
    my $letter_params = {
        module         => 'members',
        letter_code    => $which_notice,
        branchcode     => $expiring_patron->branchcode,
        lang           => $expiring_patron->lang,
        borrowernumber => $expiring_patron->borrowernumber,
        tables         => {
            borrowers => $expiring_patron->borrowernumber,
            branches  => $expiring_patron->branchcode,
        },
    };

    my $sending_params = {
        letter_params => $letter_params,
        message_name  => 'Patron_Expiry',
        forceprint    => $forceprint
    };

    my $is_notice_mandatory = grep( $expiring_patron->categorycode, @mandatory_expiry_notice_categories );
    if ($is_notice_mandatory) {
        $sending_params->{expiry_notice_mandatory} = 1;
        $sending_params->{primary_contact_method}  = $forceprint ? 'print' : $expiring_patron->primary_contact_method;
    }

    my $result = $expiring_patron->queue_notice($sending_params);
    $count_enqueued++ if $result->{sent};
}

if ($verbose) {
    print "Membership renewed for $count_renewed patrons\n" if $count_renewed;
    print "Enqueued notices for $count_enqueued patrons\n";
    print "Skipped $count_skipped inactive patrons\n" if $active;
    print "Skipped $count_skipped active patrons\n"   if $inactive;
}

cronlogaction( { action => 'End', info => "COMPLETED" } );
