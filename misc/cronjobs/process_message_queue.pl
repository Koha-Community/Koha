#!/usr/bin/perl -w

# Copyright 2008 LibLime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

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

my $help = 0;
my $verbose = 0;

GetOptions( 'h'    => \$help,
            'v'    => \$verbose,
       );
my $usage = << 'ENDUSAGE';

This script processes the message queue in the message_queue database
table. It sends out the messages in that queue and marks them
appropriately to indicate success or failure. It is recommended that
you run this regularly from cron, especially if you are using the
advance_notices.pl script.

This script has the following parameters :
    -h help: this message
    -v verbose

ENDUSAGE

die $usage if $help;

C4::Letters::SendQueuedMessages( { verbose => $verbose } );

