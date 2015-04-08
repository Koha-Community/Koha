#!/usr/bin/perl

# Copyright 2008 LibLime
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

use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Letters;
use Getopt::Long;

my $username = undef;
my $password = undef;
my $method = 'LOGIN';
my $help = 0;
my $verbose = 0;

GetOptions(
    'u|username:s'      => \$username,
    'p|password:s'      => \$password,
    'm|method:s'        => \$method,
    'h|help|?'          => \$help,
    'v|verbose'         => \$verbose,
);
my $usage = << 'ENDUSAGE';

This script processes the message queue in the message_queue database
table. It sends out the messages in that queue and marks them
appropriately to indicate success or failure. It is recommended that
you run this regularly from cron, especially if you are using the
advance_notices.pl script.

This script has the following parameters :
    -u --username: username of mail account
    -p --password: password of mail account
    -m --method: authentication method required by SMTP server (See perldoc Sendmail.pm for supported authentication types.)
    -h --help: this message
    -v --verbose: provides verbose output to STDOUT

ENDUSAGE

die $usage if $help;

C4::Letters::SendQueuedMessages( { verbose => $verbose, username => $username, password => $password, method => $method } );

