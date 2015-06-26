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

membership_expiry.pl - cron script to put membership expiry reminder into message queues

=head1 SYNOPSIS

./membership_expiry.pl -c

or, in crontab:

0 1 * * * membership_expiry.pl -c

=head1 DESCRIPTION

This script sends membership expiry reminder notices to patrons.
It queues them in the message queue, which is processed by
the process_message_queue.pl cronjob.

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
use C4::Dates qw/format_date/;
use C4::Log;


=head1 NAME

membership_expiry.pl - prepare messages to be sent to membership expiry reminder notices to patrons.

=head1 SYNOPSIS

membership_expiry.pl [-c]

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

=back

=head1 DESCRIPTION

This script is designed to alert send membership expire notices

=head2 Configuration

This script pays attention to send the membership expire notices
The content of the messages is configured in Tools -> Notices and slips. Use the MEMBERSHIP_EXPIRY template

=head2 Outgoing emails

Typically, messages are prepared for each patron when the memberships are going to expire


These emails are staged in the outgoing message queue, as are messages
produced by other features of Koha. This message queue must be
processed regularly by the
F<misc/cronjobs/process_message_queue.pl> program.

In the event that the C<-n> flag is passed to this program, no emails
are sent. Instead, messages are sent on standard output from this
program.

=head2 Templates

Templates can contain variables enclosed in double angle brackets like
E<lt>E<lt>thisE<gt>E<gt>. Those variables will be replaced with values
specific to the members there membership expiry date is coming.
Available variables are:

=over

=item E<lt>E<lt>borrowers.*E<gt>E<gt>

any field from the borrowers table

=item E<lt>E<lt>branches.*E<gt>E<gt>

any field from the branches table

=back

=head1 SEE ALSO

The F<misc/cronjobs/membership_expiry.pl> program allows you to send
messages to patrons when the membership are going to expires.
=cut

# These are defaults for command line options.

my $confirm;                              # -c: Confirm that the user has read and configured this script.
my $nomail;                               # -n: No mail. Will not send any emails.
my $verbose= 0;                           # -v: verbose

my $help    = 0;
my $man     = 0;

GetOptions(
            'help|?'         => \$help,
            'man'            => \$man,
            'c'              => \$confirm,
            'n'              => \$nomail,
            'v'              => \$verbose,
       ) or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;;

my $usage = << 'ENDUSAGE';
This script prepares for membership expiry reminders to be sent to
patrons. It queues them in the message queue, which is processed by
the process_message_queue.pl cronjob.
See the comments in the script for directions on changing the script.
This script has the following parameters :
    -c Confirm and remove this help & warning
    -n send No mail. Instead, all mail messages are printed on screen. Useful for testing purposes.
    -v verbose
ENDUSAGE

unless ($confirm) {
    print $usage;
    print "Do you wish to continue? (y/n)";
    chomp($_ = <STDIN>);
    exit unless (/^y/i);
}

cronlogaction();

my $admin_adress = C4::Context->preference('KohaAdminEmailAddress');
warn 'getting upcoming membership expires' if $verbose;
my $upcoming_mem_expires = C4::Members::GetUpcomingMembershipExpires();
warn 'found ' . scalar( @$upcoming_mem_expires ) . ' issues' if $verbose;


UPCOMINGMEMEXP: foreach my $recent ( @$upcoming_mem_expires ) {
    my $from_address = $recent->{'branchemail'} || $admin_adress;
    my $letter_type = 'MEMBERSHIP_EXPIRY';
    my $letter = C4::Letters::getletter( 'members', $letter_type, $recent->{'branchcode'} );
    die "no letter of type '$letter_type' found. Please see sample_notices.sql" unless $letter;

    $letter = parse_letter({  letter    => $letter,
                              borrowernumber => $recent->{'borrowernumber'},
                              firstname => $recent->{'firstname'},
                              categorycode  => $recent->{'categorycode'},
                              branchcode => $recent->{'branchcode'},
                          });
    if ($letter) {
        if ($nomail) {
            print $letter->{'content'};
        } else {
             C4::Letters::EnqueueLetter( {  letter               => $letter,
                                            borrowernumber       =>  $recent->{'borrowernumber'},
                                            from_address           => $from_address,
                                            message_transport_type => 'email',
                                        } );
         }
       }
    }


=head1 METHODS

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
            tables => {'borrowers', $params->{'borrowernumber'}, 'branches', $params->{'branchcode'}},
    );
}

1;

__END__
