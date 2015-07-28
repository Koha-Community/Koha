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

use strict;
use warnings;
use utf8;

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

my ($help, $days);

GetOptions(
    'help|?'         => \$help,
    'days=s'         => \$days,
);

my $usage = << 'ENDUSAGE';
This script delete old suggestions
Parameters:
-help|? This message
-days TTT to define the age of suggestions to delete

Example:
$PERL5LIB/misc/cronjobs/purge_suggestions.pl -days 30
ENDUSAGE

# If this script is called without the 'days' parameter, we use the system preferences value instead.
if ( ! defined($days) and not $help) {
    my $purge_sugg_days = C4::Context->preference('PurgeSuggestionsOlderThan') || '';
    if($purge_sugg_days ne '' and $purge_sugg_days >= 0) {
        $days = $purge_sugg_days;
    }
}
# If this script is called with the 'help' parameter, we show up the help message and we leave the script without doing anything.
if ($help) {
    print $usage;
    exit;
}

if(defined($days) && $days > 0 && $days ne ''){
    cronlogaction();
    DelSuggestionsOlderThan($days);
}

elsif(defined($days) && $days == 0) {
    print << 'ERROR';
    This script is not executed with 0 days. Aborted.
ERROR
}
else {
    print << 'ERROR';
    This script requires a positive number of days. Aborted.
ERROR
}