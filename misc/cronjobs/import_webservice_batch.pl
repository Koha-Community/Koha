#!/usr/bin/perl -w

# Copyright 2012 CatalystIT
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
use C4::ImportBatch;

my ($help, $framework);

GetOptions(
    'help|?'         => \$help,
    'framework=s'    => \$framework,
);

if($help){
    print <<EOF
$0 --framework=myframework
Parameters :
--help|? This message
--framework default ""
EOF
;
    exit;
}

my $batch_ids = GetStagedWebserviceBatches() or exit;

$framework ||= '';
BatchCommitRecords($_, $framework) foreach @$batch_ids;
