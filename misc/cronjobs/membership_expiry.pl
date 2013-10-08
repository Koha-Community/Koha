#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2013 Amit Gupta (amitddng135@gmail.com)
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

membership_expires.pl - cron script to put membership expiry reminders into message queue

=head1 SYNOPSIS

./membership_expires.pl -c

or, in crontab:

0 1 * * * membership_expires.pl -c

=cut

use strict;
use warnings;
use Getopt::Long;
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

# These are defaults for command line options.
my $confirm;                              # -c: Confirm that the user has read and configured this script.
my $nomail;                               # -n: No mail. Will not send any emails.
my $verbose= 0;                           # -v: verbose

GetOptions( 'c'              => \$confirm,
            'n'              => \$nomail,
            'v'              => \$verbose,
       );


my $usage = << 'ENDUSAGE';
This script prepares for membership expiry reminders to be sent to
patrons. It queues them in the message queue, which is processed by
the process_message_queue.pl cronjob.
See the comments in the script for directions on changing the script.
This script has the following parameters :
    -c Confirm and remove this help & warning
    -n send No mail. Instead, all mail messages are printed on screen. Usefull for testing purposes.
    -v verbose
ENDUSAGE

unless ($confirm) {
    print $usage;
    print "Do you wish to continue? (y/n)";
    chomp($_ = <STDIN>);
    exit unless (/^y/i);
}

my $admin_adress = C4::Context->preference('KohaAdminEmailAddress');
warn 'getting upcoming membership expires' if $verbose;
my $upcoming_mem_expires = C4::Members::GetUpcomingMembershipExpires();
warn 'found ' . scalar( @$upcoming_mem_expires ) . ' issues' if $verbose;


UPCOMINGMEMEXP: foreach my $recent ( @$upcoming_mem_expires ) {
    my $from_address = $recent->{'branchemail'} || $admin_adress;
    my $letter_type = 'MEMEXP';
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
            letter_code => 'MEMEXP',
            branchcode => $params->{'branchcode'},
            tables => {'borrowers', $params->{'borrowernumber'},},
    );
}

1;

__END__
