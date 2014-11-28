#!/usr/bin/perl

# Copyright 2014-2015 Koha-community
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

use Modern::Perl;

use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Koha::Deduplicator;

use Getopt::Long qw(:config no_ignore_case);

my ($help, $biblionumber, $matcher_id, $merge);
my $limit = 500;
my $chunk = 500;
my $offset = 0;
my $verbose = 0;
my $maxMatchThreshold = 3;

GetOptions(
    'h|help'           => \$help,
    'v|verbose:i'      => \$verbose,
    'l|limit:i'        => \$limit,
    'c|chunk:i'        => \$chunk,
    'o|offset:i'       => \$offset,
    'b|biblionumber:i' => \$biblionumber,
    'm|matcher:i'      => \$matcher_id,
    'max-matches:i'    => \$maxMatchThreshold,
    'M|merge:s'        => \$merge,
);

my $usage = << 'ENDUSAGE';

This script runs the Koha::Deduplicator from the command line allowing for a much
larger biblio group to be deduplicated.
Finds duplicates for the parametrized group of biblios.

This script has the following parameters :
    -h --help         This help.

    -v --verbose      Integer, 1, prints found duplicates.
                               2, prints each biblionumber checked.

    -l --limit        How many biblios to check for duplicates. Is the SQL
                      LIMIT-clause for gathering biblios to deduplicate.
                      Defaults to 500. To run through the whole DB, set a sufficiently
                      large number, like 999999999999999 :)

    -c --chunk        How many records to process on one deduplicate->merge run.
                      Defaults to 500. Use this to prevent memory from running
                      out when deduplicating/merging large databases.

    -o --offset       How many records to skip from the start. Is the SQL
                      OFFSET-clause for gathering biblios to deduplicate.
                      Defaults to 0.

    -b --biblionumber From which biblionumber (inclusive) to start gathering
                      the biblios to deduplicate. Obsoletes --offset

    --max-matches     Safety trigger to stop matching a single biblio if it has
                      this many matches. This is used to prevent catastrophic
                      merge failures in your database caused by misconfigured
                      matchers. If you know your DB is really duplicated, try
                      making multiple deduplication runs with incrementally
                      higher --max-matches threshold to verify your matching
                      rules.
                      Defaults to 3.

    -m --matcher      MANDATORY. The matcher to use. References the
                      koha.marc_matcher.matcher_id.

    -M --merge        Automatically merge duplicates. WARNING! This feature can
                      potentially SCREW UP YOUR WHOLE BIBLIO DATABASE! Test
                      the found duplicates well before using this parameter.
                      This feature simply moves all Items, Subscriptions,
                      Acquisitions, Reservations etc. under the new merge target
                      from all matching Biblios and deletes the duplicate
                      Biblios.

                      This parameter has the following sub-modes:
                       'newest' : Uses the Biblio with the biggest timestamp in
                                  Field 005 as the target of the merge.

Examples:

perl deduplicator.pl --match 1 --offset 12000 --limit 500 --verbose
perl deduplicator.pl --match 3 --biblionumber 12313 --limit 500 --verbose
perl deduplicator.pl --match 3 --biblionumber 12313 --limit 500 --verbose --merge newest

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}
if ($merge && $merge eq 'newest') {
    #Merge mode OK
}
elsif ($merge) {
    print "--merge mode $merge not supported. Valid values are [newest]";
    exit;
}

my $lastOffset = $offset;
while ($lastOffset < $limit) {

    my $chunkSize = _calculateChunkSize($lastOffset, $chunk, $limit);

    runDeduplicateMergeChunk($matcher_id, $chunkSize, $lastOffset, $biblionumber, $verbose );

    $lastOffset += $chunk;
}

=head _calculateChunkSize

    my $chunkSize = _calculateChunkSize($lastOffset, $chunk, $limit);

It can be that the last chunk overflows the limit-paramter, thus leading to deduplicating/merging too many biblios.
We don't want that, so calculate the remaining chunk size to not exceed the given limit!
=cut

sub _calculateChunkSize {
    my ($lastOffset, $chunk, $limit) = @_;

    my $chunkSize = $chunk;
    if ($lastOffset + $chunk > $limit) {
        $chunkSize = $limit - $lastOffset;
    }
    return $chunkSize;
}

sub runDeduplicateMergeChunk {
    my ($matcher_id, $chunkSize, $offset, $biblionumber, $verbose ) = @_;

    my ($deduplicator, $initErrors) = Koha::Deduplicator->new( $matcher_id, $chunkSize, $offset, $biblionumber, $maxMatchThreshold, $verbose );
    if ($initErrors) {
        print "Errors happened when creating the Deduplicator:\n";
        print join("\n", @$initErrors);
        print "\n";
        print $usage;
        exit;
    }
    else {
        my $duplicates = $deduplicator->deduplicate();

        $deduplicator->printDuplicatesAsText() if $verbose > 0;

        if ($merge && scalar(@$duplicates) > 0) {
            my $errors = $deduplicator->batchMergeDuplicates($duplicates, $merge);
            if ($errors) {
                foreach my $error (@$errors) {
                    print $error;
                }
            }
        }
    }
}