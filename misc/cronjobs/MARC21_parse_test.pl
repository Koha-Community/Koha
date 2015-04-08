#!/usr/bin/perl
#
# Copyright 2009 Liblime
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

use MARC::Record;
use MARC::File::XML;
use MARC::File::USMARC;

use open OUT => ':encoding(UTF-8)';

use Getopt::Long qw(:config auto_help auto_version);
use Pod::Usage;

use C4::Biblio;
use C4::Charset;
use C4::Context;
use C4::Debug;

use vars qw($VERSION);

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
    $VERSION = 0.03;
}

our $debug;

## OPTIONS
my $help    = 0;
my $man     = 0;
my $verbose = 0;

my $limit;      # undef, not zero.
my $offset  = 0;
my $dump    = 0;
my $all     = 0;
my $summary = 1;
my $lint    = 0;
my $fix     = 0;
my $filename = "/tmp/MARC21_parse_test.$$.marc";

GetOptions(
       'help|?' => \$help,
          'man' => \$man,
      'verbose' => \$verbose,
      'limit=i' => \$limit,
     'offset=i' => \$offset,
     'filename' => \$filename,
         'All!' => \$all,
        'Lint!' => \$lint,
        'dump!' => \$dump,
     'summary!' => \$summary,
         'fix!' => \$fix,
) or pod2usage(2);
pod2usage( -verbose => 2 ) if ($man);
pod2usage( -verbose => 2 ) if ($help and $verbose);
pod2usage(1) if $help;

if ($debug) {
    $summary++;
    $verbose++;
    $lint++;
}

my $lint_object;
if ($lint) {
    require MARC::Lint;
    $lint_object = new MARC::Lint;
}
my $marcflavour = C4::Context->preference('marcflavour') or die "No marcflavour (MARC21 or UNIMARC) set in syspref";
(uc($marcflavour) eq 'MARC21') or die "Only marcflavour MARC21, not '$marcflavour'";

# my $countq = C4::Context->dbh->prepare("SELECT COUNT(*) FROM biblioitems");    # Too SLOW on large systems
# $countq->execute; $countq->fetchrow();
my $max = 999999;   # arbitrary ceiling

$limit or $limit = $max;       # limit becomes max if unspecified

if ($summary) {
    printf "# Examining marcxml from %s\n", ($all ? 'ALL biblioitems' : 'SELECT biblionumbers');
    printf "# limit %d, offset %d:\n", $limit, $offset;
    printf "# MARC::Lint warnings: %s\n", ($lint ? 'ON' : 'OFF');
    $verbose and print "# Using temp file: $filename\n"
}

MARC::File::XML->default_record_format($marcflavour) or die "FAILED MARC::File::XML->default_record_format($marcflavour)";

my $query = "SELECT  *  FROM biblioitems ";
my $recs;
if ($all) {
    if ($limit or $offset) {
        my $limit_clause = sprintf "LIMIT %d, %d", ($offset || 0), ($limit || $max);
        $query .= $limit_clause;
    }
    $verbose and print "# Query: $query\n";
    $recs = C4::Context->dbh->prepare($query);
    $recs->execute();
} else {
    $query .= "WHERE biblionumber=?";
    $verbose and print "# Query: $query\n";
    $recs = C4::Context->dbh->prepare($query);
    # no execute, we execute per biblionumber
    print "# Reading biblionumbers from STDIN\n";
}

sub next_row {
    $all and return $recs->fetchrow_hashref();  # no WHERE clause, just get it
    while (my $biblionumber = <>) {
        chomp($biblionumber);
        unless (defined $biblionumber) {
            print "Skipping blank line $.\n";
            next;
        } 
        unless ($biblionumber =~ s/^\s*(\d+)\s*$/$1/ and $biblionumber != 0) {
            print "Skipping illegal biblionumber: $biblionumber  (line $.)\n";
            next;
        }
        ($verbose > 1) and printf("(%9d) plausible biblionumber\n", $biblionumber);
        $recs->execute($biblionumber);
        return $recs->fetchrow_hashref();
    }
    return undef;   # just in case
}

my $ilimit = $limit;
$ilimit += $offset unless $all;    # increase ilimit for offset.  if $all, then offset is built into query.
my $i = 0;
my $found  = 0;
my $fixed  = 0;
my $fine   = 0;
my $failed = 0;
my $warns  = 0;
my $printline = 0;
while ( my $row = next_row() ) {
    ++$i;
    unless ($all) {
        ($i > $ilimit) and last;  # controls for user-input data/files
        ($i > $offset) or next;
    }
    my $xml = $row->{marcxml};
    my $bibnum_prefix = sprintf "(%9d)", $row->{biblionumber};
    # $xml now pared down to just the <leader> element
    $verbose and printf "# %4d of %4d: biblionumber %s\n", ++$printline, $limit, $row->{biblionumber};
    my $stripped = StripNonXmlChars($xml);
    ($stripped eq $xml) or printf "$bibnum_prefix: %d NON-XML Characters removed!!\n", (length($xml) - length($stripped));
    my $record = eval { MARC::Record::new_from_xml( $stripped, 'utf8', $marcflavour ) };
    if (not $record) {
        $found++;
    	my $msg = $@ || '';
        $verbose or $msg =~ s# at /usr/.*$##gs;    # shorten common error message
        print "$bibnum_prefix ERROR: $msg\n";
    } else {
        $fine++;
    }
    if ($lint) {
        open (FILE, ">$filename") or die "Cannot write to temp file: $filename";
        print FILE $xml;
        close FILE;
        my $file = MARC::File::XML->in( $filename );
        while ( my $marc = $file->next() ) {    # should be only 1
            # $marc->field("245") or print "pre check_record 245 check 1: FAIL\n"; use Data::Dumper;  print Dumper($marc);
            $lint_object->check_record( $marc );
            if ($lint_object->warnings) {
                $warns++;
                print join("\n", map {"$bibnum_prefix $_"} $lint_object->warnings), "\n";
            }
        }
    }
    if ($fix and not $record) {
        my $record_from_blob = MARC::Record->new_from_usmarc($row->{marc});
        unless ($record_from_blob) {
            print "$bibnum_prefix ERROR: Cannot recover from biblioitems.marc\n";
            $failed++;
        } else {
            my $mod = ModBiblioMarc($record_from_blob, $row->{biblionumber}, '');
            if ($mod) {
                $fixed++;  print "$bibnum_prefix FIXED\n";
            } else {
                $failed++; print "$bibnum_prefix FAILED from marc.  Manual intervention required.\n";
            }
        }
    }
    $dump and print $row->{marcxml}, "\n";
}

(-f $filename) and unlink ($filename);  # remove tempfile

if ($summary) {
    printf "# Examining marcxml from %s\n", ($all ? 'ALL biblioitems' : 'SELECT biblionumbers');
    printf "# limit %d, offset %d:\n", $limit, $offset;
    print "\nRESULTS (number of records)...\n";
    printf "  %6d -- OK              \n",  $fine;
    printf "  %6d -- w/ bad marcxml  \n",  $found;
    printf "  %6d -- w/ MARC::Lint warnings\n", $warns;
    printf "  %6d -- fixed from marc \n",  $fixed;
    printf "  %6d -- failed to fix   \n",  $failed;
}


__END__

=head1 NAME

MARC21_parse_test.pl - Try parsing and optionally fixing biblioitems.marcxml, report errors

=head1 SYNOPSIS

MARC21_parse_test.pl [ -h | -m ] [ -v ] [ -d ] [ -s ] [ -l=N ] [ -o=N ] [ -l ] [ -f ] [ -A | filename ...]

 Help Options:
   -h --help -?   Brief help message
   -m --man       Full documentation, same as --help --verbose
      --version   Prints version info

 Feedback Options:
   -d --dump      Dump MARCXML of biblioitems processed, default OFF
   -s --summary   Print initial and closing summary of good and bad biblioitems counted, default ON
   -L --Lint      Show any warnings from MARC::Lint, default OFF
   -v --verbose   Increase verbosity of output, default OFF

 Run Options:
   -f --fix       Replace biblioitems.marcxml from data in marc field, default OFF
   -A --All       Use the whole biblioitems table as target set, default OFF
   -l --limit     Number of biblioitems to display or fix
   -o --offset    Number of biblioitems to skip (not displayed or fixed)

=head1 OPTIONS

=over 8

=item B<--All>

Target the entire biblioitems table.
Beware, on a large table B<--All> can be very costly to performance.

=item B<--fix>

Without this option, no changes to any records are made.  With <--fix>, the script attempts to reconstruct
biblioitems.marcxml from biblioitems.marc.  

=item B<--limit=N>

Like a LIMIT statement in SQL, this constrains the number of records targeted by the script to an integer N.  
This applies whether the target records are determined by user input, filenames or <--All>.

=item B<--offset=N>

Like an OFFSET statement in SQL, this tells the script to skip N of the targetted records.
The default is 0, i.e. skip none of them.

=back

The binary ON/OFF options can be negated like:
   B<--nosummary>   Do not display summary.
   B<--nodump>      Do not dump MARCXML.
   B<--noLint>      Do not show MARC::Lint warnings.
   B<--nofix>       Do not change any records.  This is the default mode.

=head1 ARGUMENTS

Any number of filepath arguments can be referenced.  They will be read in order and used to select the target
set of biblioitems.  The file format should be simply one biblionumber per line.  The B<--limit> and B<--offset>
options can still be used with biblionumbers specified from file.  Files will be ignored under the B<--All> option.

=head1 DESCRIPTION

This checks for data corruption or otherwise unparsable data in biblioitems.marcxml.  
As the name suggests, this script is only useful for MARC21 and will die for marcflavour UNIMARC.

Run MARC21_parse_test.pl the first time with no options and type in individual biblionumbers to test.
Or run with B<--All> to go through the entire table.
Run the script again with B<--fix> to attempt repair of the same target set.

After fixing any records, you will need to rebuild your index, e.g. B<rebuild_zebra -b -r -x>.

=head1 USAGE EXAMPLES

B<MARC21_parse_test.pl>

In the most basic form, allows you to input biblionumbers and checks them individually.

B<MARC21_parse_test.pl --fix>

Same thing but fixes them if they fail to parse.

B<MARC21_parse_test.pl --fix --limit=15 bibnumbers1.txt>

Fixes biblioitems from the first 15 biblionumbers in file bibnumbers1.txt.  Multiple file arguments can be used.

B<MARC21_parse_test.pl --All --limit=3 --offset=15 --nosummary --dump>

Dumps MARCXML from the 16th, 17th and 18th records found in the database.

B<MARC21_parse_test.pl -A -l=3 -o=15 -s=0 -d>

Same thing as previous example in terse form.

=head1 TODO

Add more documentation for OPTIONS.

Update zebra status so rebuild of index is not necessary.

=head1 SEE ALSO

MARC::Lint
C4::Biblio

=cut
