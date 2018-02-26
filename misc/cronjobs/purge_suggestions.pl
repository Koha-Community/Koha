#!/usr/bin/perl -w

# Copyright 2010 Biblibre SARL
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

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use Getopt::Long;
use Pod::Usage;
use C4::Suggestions;
use C4::Log;
use C4::Context;

my ( $help, $days, $confirm );

GetOptions(
    'help|?' => \$help,
    'days:i' => \$days,
    'confirm'=> \$confirm,
);

my $usage = << 'ENDUSAGE';
This script deletes old suggestions
Parameters:
-help|? This message
-days TTT to define the age of suggestions to delete
-confirm flag needed to confirm purge operation

The days parameter falls back to the value of system preference
PurgeSuggestionsOlderThan. Suggestions are deleted only for a positive
number of days.

Example:
ENDUSAGE
$usage .= $0 . " -confirm -days 30\n";

# If this script is called without the 'days' parameter, we use the system preferences value instead.
$days = C4::Context->preference('PurgeSuggestionsOlderThan') if !defined($days);

# If this script is called with the 'help' parameter, we show up the help message and we leave the script without doing anything.
if( !$confirm || $help || !defined($days) ) {
    print "No confirm parameter passed!\n\n" if !$confirm && !$help;
    print $usage;
} elsif( $days and $days > 0 ) {
    cronlogaction();
    DelSuggestionsOlderThan($days);
} else {
    warn "This script requires a positive number of days. Aborted.\n";
}
