#!/usr/bin/perl
#
# Copyright 2009 Liblime
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

use MARC::Record;
use MARC::File::XML;
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
    $VERSION = 0.02;
}

our $debug;

## OPTIONS
my $help    = 0;
my $man     = 0;
my $verbose = 0;

my $limit;      # undef, not zero.
my $offset  = 0;
my $dump    = 0;
my $summary = 1;
my $fix     = 0;

GetOptions(
    'help|?'    => \$help,
    'man'       => \$man,
    'verbose=i' => \$verbose,
    'limit=i'   => \$limit,
    'offset=i'  => \$offset,
    'dump!'     => \$dump,
    'summary!'  => \$summary,
    'fix!'      => \$fix,
) or pod2usage(2);
pod2usage( -verbose => 2 ) if ($man);
pod2usage( -verbose => 2 ) if ($help and $verbose);
pod2usage(1) if $help;

if ($debug) {
    $summary++;
    $verbose++;
}

my $marcflavour = C4::Context->preference('marcflavour');

my $all = C4::Context->dbh->prepare("SELECT COUNT(*) FROM biblioitems");
$all->execute;
my $total = $all->fetchrow;

my $count_query = "SELECT COUNT(*) FROM biblioitems WHERE substr(marc, 10, 1)  = ?";
my $query       = "SELECT     *    FROM biblioitems WHERE substr(marc, 10, 1) <> ?";

my $sth = C4::Context->dbh->prepare($count_query);
$sth->execute('a');
my $count    = $sth->fetchrow;
my $badcount = $total-$count;

if ($summary) {
    print  "# biblioitems with leader/09 = 'a'\n";
    printf "# %9s match\n",   $count;
    printf "# %9s  BAD \n",   $badcount;
    printf "# %9s total\n\n", $total;
    printf "# Examining %s BAD record(s), offset %d:\n", ($limit || 'all'), $offset;
}

my $bad_recs = C4::Context->dbh->prepare($query);
$bad_recs->execute('a');
$limit or $limit = $bad_recs->rows();   # limit becomes max if unspecified
$limit += $offset if $offset;           # increase limit for offset
my $i = 0;

$marcflavour or die "No marcflavour (MARC21 or UNIMARC) set in syspref";

MARC::File::XML->default_record_format($marcflavour) or die "FAILED MARC::File::XML->default_record_format($marcflavour)";

while ( my $row = $bad_recs->fetchrow_hashref() ) {
    (++$i > $limit) and last;
    (  $i > $offset) or next;
    my $xml = $row->{marcxml};
    $xml =~ s/.*(\<leader\>)/$1/s;
    $xml =~ s/(\<\/leader\>).*/$1/s;
    # $xml now pared down to just the <leader> element
    printf "# %4d of %4d: biblionumber %s : %s\n", $i, $badcount, $row->{biblionumber}, $xml;
    my $stripped = StripNonXmlChars($row->{marcxml});
    ($stripped eq $row->{marcxml}) or printf STDERR "%d NON-XML Characters removed!!\n", (length($row->{marcxml}) - length($stripped));
    my $record = eval { MARC::Record::new_from_xml( $stripped, 'utf8', $marcflavour ) };
    if ($@ or not $record) {
        print STDERR "ERROR in MARC::Record::new_from_xml(\$marcxml, 'utf8', $marcflavour): $@\n\tSkipping $row->{biblionumber}\n";
        next;
    }
    if ($fix) {
        $record->encoding('UTF-8');
        if (ModBiblioMarc($record, $row->{biblionumber})) {
            printf "# %4d of %4d: biblionumber %s : <leader>%s</leader>\n", $i, $badcount, $row->{biblionumber}, $record->leader();
        } else {
            print STDERR "ERROR in ModBiblioMarc(\$record, $row->{biblionumber})\n";
        }
    }
    $dump and print $row->{marcxml}, "\n";
}

__END__

=head1 NAME

leader_fix.pl - Repair missing leader position 9 value ("a" for MARC21 - UTF8).

=head1 SYNOPSIS

leader_fix.pl [ -h ] [ -m ] [ -v ] [ -d ] [ -s ] [ -l 7 ] [ -o 4 ] [ -f ]

Help Options:
   -h --help -?   Brief help message
   -m --man       Full documentation, same as --help --verbose
      --version   Prints version info

Feeback Options:
   -d --dump      Dump MARCXML of biblioitems processed, default OFF
   -s --summary   Print initial summary of good and bad biblioitems counted, default ON
   -v --verbose   Increase verbosity of output, default OFF

Run Options:
   -f --fix       Save repaired leaders to biblioitems.marcxml, 
   -l --limit     Number of biblioitems to display or fix
   -o --offset    Number of biblioitems to skip (not displayed or fixed)

=head1 OPTIONS

=over 8

=item B<--fix>

This is the most important option.  Without it, the script just tells you about the problem records.
With --fix, the script fixes the same records.

=item B<--limit=N>

Like a LIMIT statement in SQL, this contrains the number of records targeted by the script to an integer N.  
The default is to target all records with bad leaders.

=item B<--offset=N>

Like an OFFSET statement in SQL, this tells the script to skip N of the targetted records.
The default is 0, i.e. skip none of them.

=back

The binary ON/OFF options can be negated like:
   B<--nosummary>   Do not display summary.
   B<--nodump>      Do not dump MARCXML.
   B<--nofix>       Do not change any records.  This is the default mode.

=head1 DESCRIPTION

Koha expects to have all MARXML records internalized in UTF-8 encoding.  This 
presents a problem when records have been inserted with the leader/09 showing
blank for MARC8 encoding.  This script is used to determine the extent of the 
problem and to fix the affected leaders.

Run leader_fix.pl the first time with no options, and assuming you agree that the leaders
presented need fixing, run it again with B<--fix>.  

=head1 USAGE EXAMPLES

B<leader_fix.pl>

In the most basic form, displays summary of biblioitems examined
and the leader from any found without /09 = a.

B<leader_fix.pl --fix>

Fixes the same biblioitems, displaying summary and each leader before/after change.

B<leader_fix.pl --limit=3 --offset=15 --nosummary --dump>

Dumps MARCXML from the 16th, 17th and 18th bad records found.

B<leader_fix.pl -l 3 -o 15 -s 0 -d>

Same thing as previous example in terse form.

=head1 TO DO

Allow biblionumbers to be piped into STDIN as the selection mechanism.

=head1 SEE ALSO

C4::Biblio

=cut
