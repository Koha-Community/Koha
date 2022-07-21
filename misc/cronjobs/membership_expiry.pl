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

Options:
   --help                   brief help message
   --man                    full documentation
   --where <conditions>     where clause to add to the query
   -v -verbose              verbose mode
   -n --nomail              if supplied, messages will be output to STDOUT and no email or sms will be sent
   -c --confirm             commit changes to db, no action will be taken unless this switch is included
   -b --branch <branchname> only deal with patrons from this library/branch
   --before=X               include patrons expiring a number of days BEFORE the date set by the preference
   --after=X                include patrons expiring a number of days AFTER  the date set by the preference
   -l --letter <lettercode> use a specific notice rather than the default

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

Optional parameter to use another notice than the default: MEMBERSHIP_EXPIRY

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
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );

use Koha::Script -cron;
use C4::Context;
use C4::Letters;
use C4::Log qw( cronlogaction );

use Koha::Patrons;

# These are defaults for command line options.
my $confirm;                              # -c: Confirm that the user has read and configured this script.
my $nomail;                               # -n: No mail. Will not send any emails.
my $verbose = 0;                           # -v: verbose
my $help    = 0;
my $man     = 0;
my $before  = 0;
my $after   = 0;
my ( $branch, $letter_type );
my @where;

my $command_line_options = join(" ",@ARGV);

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'c'              => \$confirm,
    'n'              => \$nomail,
    'v'              => \$verbose,
    'branch:s'       => \$branch,
    'before:i'       => \$before,
    'after:i'        => \$after,
    'letter:s'       => \$letter_type,
    'where=s'        => \@where,
) or pod2usage(2);

pod2usage( -verbose => 2 ) if $man;
pod2usage(1) if $help || !$confirm;

cronlogaction({ info => $command_line_options });

my $expdays = C4::Context->preference('MembershipExpiryDaysNotice');
if( !$expdays ) {
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

my $where_literal = join ' AND ', @where;
$upcoming_mem_expires = $upcoming_mem_expires->search( \$where_literal ) if @where;

warn 'found ' . $upcoming_mem_expires->count . ' soon expiring members'
    if $verbose;

# main loop
$letter_type = 'MEMBERSHIP_EXPIRY' if !$letter_type;
while ( my $recent = $upcoming_mem_expires->next ) {
    my $from_address = $recent->library->from_email_address;
    my $letter =  C4::Letters::GetPreparedLetter(
        module      => 'members',
        letter_code => $letter_type,
        branchcode  => $recent->branchcode,
        lang        => $recent->lang,
        tables      => {
            borrowers => $recent->borrowernumber,
            branches  => $recent->branchcode,
        },
    );
    last if !$letter; # Letters.pm already warned, just exit
    if( $nomail ) {
        print $letter->{'content'}."\n";
        next;
    }

    C4::Letters::EnqueueLetter({
        letter                 => $letter,
        borrowernumber         =>  $recent->borrowernumber,
        from_address           => $from_address,
        message_transport_type => 'email',
    });

    if ($recent->smsalertnumber) {
        my $smsletter = C4::Letters::GetPreparedLetter(
            module      => 'members',
            letter_code => $letter_type,
            branchcode  => $recent->branchcode,
            lang        => $recent->lang,
            tables      => {
                borrowers => $recent->borrowernumber,
                branches  => $recent->branchcode,
            },
            message_transport_type => 'sms',
        );
        if ($smsletter) {
            C4::Letters::EnqueueLetter({
                letter                 => $smsletter,
                borrowernumber         => $recent->borrowernumber,
                message_transport_type => 'sms',
            });
        }
    }
}

cronlogaction({ action => 'End', info => "COMPLETED" });
