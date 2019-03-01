#!/usr/bin/perl

#-----------------------------------
# Copyright 2015 Vaara-kirjastot
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#-----------------------------------

use Modern::Perl;
use Getopt::Long;

use Koha::RecordProcessor;
use C4::Biblio::Chunker;
use C4::Biblio;

use Koha::Filter::MARC::ISBNTrim;
Koha::Filter::MARC::ISBNTrim->filter();
my ($help, $confirm, $verbose, $filter);

GetOptions(
  'h|help'      => \$help,
  'v|verbose:i' => \$verbose,
  'c|confirm'   => \$confirm,
  'f|filter:s'  => \$filter,
);

my $usage = << 'ENDUSAGE';

Runs the given Koha::Filter for all records in the DB using the Koha::RecordProcessor.
Remember to reindex search index afterwards.

  -h --help    This nice help!

  -v --verbose More chatty output, something between 0 - 3 or undef.

  -c --confirm Confirm that you want to mangle your bibliographic records

  -f --filter  The Koha::Filter to use

EXAMPLE:

perl batchRecordProcessor.pl -v 3 -f ISBNTrim

ENDUSAGE

if ($help || !$confirm || !$filter) {
    print $usage;
    exit 0;
}

use Koha::Logger;
Koha::Logger->setVerbosity($verbose);

my $chunker = C4::Biblio::Chunker->new(undef, undef, undef, $verbose);
my $processor = Koha::RecordProcessor->new( { filters => ( $filter ) });
while (my $chunk = $chunker->getChunkAsMARCRecord()) {
    foreach my $r (@$chunk) {
        my $record = $processor->process($r);
        C4::Biblio::ModBiblio($record, $r->{biblionumber}, $r->{frameworkcode});
    }
}
