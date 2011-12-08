#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2007 LibLime
# Parts Copyright BSZ 2011
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
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use C4::Context;
use C4::ImportBatch;
use C4::Matcher;
use Getopt::Long;

$| = 1;

# command-line parameters
my $encoding = "";
my $match_bibs = 0;
my $add_items = 0;
my $input_file = "";
my $batch_comment = "";
my $want_help = 0;
my $no_replace ;

my $result = GetOptions(
    'encoding:s'    => \$encoding,
    'file:s'        => \$input_file,
    'match-bibs:s'  => \$match_bibs,
    'add-items'     => \$add_items,
    'no-replace'    => \$no_replace,
    'comment:s'     => \$batch_comment,
    'h|help'        => \$want_help
);

if ($encoding eq "") {
    $encoding = "utf8";
}

if (not $result or $input_file eq "" or $want_help) {
    print_usage();
    exit 0;
}

unless (-r $input_file) {
    die "$0: cannot open input file $input_file: $!\n";
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
process_batch($input_file, $match_bibs, $add_items, $batch_comment);
$dbh->commit();

exit 0;

sub process_batch {
    my ($input_file, $match_bibs, $add_items, $batch_comment) = @_;

    open IN, "<$input_file" or die "$0: cannot open input file $input_file: $!\n";
    my $marc_records = "";
    $/ = "\035";
    my $num_input_records = 0;
    while (<IN>) {
        s/^\s+//;
        s/\s+$//;
        next unless $_; # skip if record has only whitespace, as might occur
                        # if file includes newlines between each MARC record
        $marc_records .= $_; # FIXME - this sort of string concatenation
                             # is probably rather inefficient
        $num_input_records++;
    }
    close IN;

    print "... staging MARC records -- please wait\n";
    my ($batch_id, $num_valid, $num_items, @import_errors) = 
        BatchStageMarcRecords($encoding, $marc_records, $input_file, $batch_comment, '', $add_items, 0,
                              100, \&print_progress_and_commit);
    print "... finished staging MARC records\n";

    my $num_with_matches = 0;
    if ($match_bibs) {
        my $matcher = C4::Matcher->fetch($match_bibs) ;
        if (! defined $matcher) {
            $matcher = C4::Matcher->new('biblio');
            $matcher->add_simple_matchpoint('isbn', 1000, '020', 'a', -1, 0, '');
            $matcher->add_simple_required_check('245', 'a', -1, 0, '', 
                                            '245', 'a', -1, 0, '');
        } else {
            SetImportBatchMatcher($batch_id, $match_bibs);
        }
        # set default record overlay behavior
        SetImportBatchOverlayAction($batch_id, ($no_replace) ? 'ignore' : 'replace');
        SetImportBatchNoMatchAction($batch_id, 'create_new');
        SetImportBatchItemAction($batch_id, 'always_add');
        print "... looking for matches with records already in database\n";
        $num_with_matches = BatchFindBibDuplicates($batch_id, $matcher, 10, 100, \&print_progress_and_commit);
        print "... finished looking for matches\n";
    }

    my $num_invalid_bibs = scalar(@import_errors);
    print <<_SUMMARY_;

MARC record staging report
------------------------------------
Input file:              $input_file
Number of input bibs:    $num_input_records
Number of valid bibs:    $num_valid
Number of invalid bibs:  $num_invalid_bibs
_SUMMARY_
    if ($match_bibs) {
        print "Number of bibs matched:  $num_with_matches\n";
    } else {
        print "Incoming bibs not matched against existing bibs (--match-bibs option not supplied)\n";
    }
    if ($add_items) {
        print "Number of items parsed:  $num_items\n";
    } else {
        print "No items parsed (--add-items option not supplied)\n";
    }

    print "\n";
    print "Batch number assigned:  $batch_id\n";
    print "\n";
}

sub print_progress_and_commit {
    my $recs = shift;
    $dbh->commit();
    print "... processed $recs records\n";
}

sub print_usage {
    print <<_USAGE_;
$0: stage MARC bib file into reservoir.

Use this batch job to load a file of MARC bibliographic records
(with optional item information) into the Koha reservoir.

After running this program to stage your file, you can use
either the batch job commit_biblios_file.pl or the Koha
Tools option "Manage Staged MARC Records" to load the
records into the main Koha database.

Parameters:
    --file <file_name>      name of input MARC bib file
    --encoding <encoding>   encoding of MARC records, default is utf8.
                            Other possible options are: MARC-8,
                            ISO_5426, ISO_6937, ISO_8859-1, EUC-KR
    --match-bibs <match_id> use this option to match bibs
                            in the file with bibs already in 
                            the database for future overlay.
                            If <match_id> isn't defined, a default 
                            MARC21 ISBN & title match rule will be applied.
    --add-items             use this option to specify that
                            item data is embedded in the MARC
                            bibs and should be parsed.
    --no-replace            overlay action for bib record: default is to 
                            replace extant bib with the imported record.
    --comment <comment>     optional comment to describe
                            the record batch; if the comment
                            has spaces in it, surround the
                            comment with quotation marks.
    --help or -h            show this message.
_USAGE_
}
