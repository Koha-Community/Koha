#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014 BibLibre
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
use C4::Charset qw( SanitizeRecord );
use C4::Context;
use DBI;
use C4::Biblio;
use Getopt::Long;
use Pod::Usage;

my ( $help, $verbose, $confirm, $biblionumbers, $reindex, $filename,
    $auto_search, $fix_ampersand );
my $result = GetOptions(
    'h|help'          => \$help,
    'v|verbose'       => \$verbose,
    'c|confirm'       => \$confirm,
    'biblionumbers:s' => \$biblionumbers,
    'reindex'         => \$reindex,
    'f|filename:s'    => \$filename,
    'auto-search'     => \$auto_search,
    'fix-ampersand'   => \$fix_ampersand,
) || pod2usage(1);

# This script only fix ampersand at the moment.
# It is enabled by default.
$fix_ampersand = 1;

if ($help) {
    pod2usage(0);
}

unless ( $filename or $biblionumbers or $auto_search ) {
    pod2usage(
        -exitval => 1,
        -message =>
          qq{\n\tAt least one record number source should be provided.\n}
    );
}

if (   $filename and $biblionumbers
    or $filename and $auto_search
    or $biblionumbers and $auto_search )
{
    pod2usage(
        -exitval => 1,
        -message => qq{\n\tOnly one record number source should be provided.\n}
    );
}

my @biblionumbers;

# We first detect if we have a file or biblos directly entered by command line
#or if we want to use findAmp() sub
if ($auto_search) {
    @biblionumbers = biblios_to_sanitize();
}
elsif ($filename) {
    if ( -e $filename ) {
        open( my $fh, '<', $filename ) || die("Can't open $filename ($!)");
        while (<$fh>) {
            chomp;
            my $line = $_;
            push @biblionumbers, split( " |,", $line );
        }
        close $fh;
    }
    else {
        pod2usage(
            -exitval => 1,
            -message =>
qq{\n\tThis filename does not exist. Please verify the path is correct.\n}
        );
    }
}
else {
    @biblionumbers = split m|,|, $biblionumbers if $biblionumbers;
}

# We remove spaces
s/(^\s*|\s*$)//g for @biblionumbers;

# Remove empty lines
@biblionumbers = grep { !/^$/ } @biblionumbers;

say @biblionumbers . " records to process" if $verbose;

my @changes;
for my $biblionumber (@biblionumbers) {
    print "processing record $biblionumber..." if $verbose;
    unless ( $biblionumber =~ m|^\d+$| ) {
        say " skipping. ERROR: Invalid biblionumber." if $verbose;
        next;
    }
    my $record = C4::Biblio::GetMarcBiblio($biblionumber);
    unless ($record) {
        say " skipping. ERROR: Invalid record." if $verbose;
        next;
    }

    my ( $cleaned_record, $has_been_modified ) =
      C4::Charset::SanitizeRecord( $record, $biblionumber );
    if ($has_been_modified) {
        my $frameworkcode = C4::Biblio::GetFrameworkCode($record);

        C4::Biblio::ModBiblio( $cleaned_record, $biblionumber, $frameworkcode )
            if $confirm;
        push @changes, $biblionumber;
        say " Done!" if $verbose;
    }
    else {
        say " Nothing to do." if $verbose;
    }
}

if ($verbose) {
    say "Total: "
      . @changes
      . " records "
      . ( $confirm ? "cleaned!" : "to clean." );
}

if ( $reindex and $confirm and @changes ) {
    say "Now, reindexing using -b -v" if $verbose;
    my $kohapath = C4::Context->config('intranetdir');
    my $cmd      = qq|
        $kohapath/misc/migration_tools/rebuild_zebra.pl -b -v -where "biblionumber IN ( |
      . join( ',', @changes ) . q| )"
    |;
    system($cmd);
}

sub biblios_to_sanitize {
    my $dbh   = C4::Context->dbh;
    my $query = q{
        SELECT biblionumber
        FROM biblioitems
        WHERE marcxml
        LIKE "%&amp;amp;%"
    };
    return @{ $dbh->selectcol_arrayref( $query, { Slice => {} }, ) };
}

=head1 NAME

sanitize_records - This script sanitizes a record.

=head1 SYNOPSIS

sanitize_records.pl [-h|--help] [-v|--verbose] [-c|--confirm] [--biblionumbers=BIBLIONUMBER_LIST] [-f|--filename=FILENAME] [--auto-search] [--reindex] [--fix-ampersand]

You can either give some biblionumbers or a file with biblionumbers or ask for an auto-search.

=head1 OPTIONS

=over

=item B<-h|--help>

Print a brief help message

=item B<-v|--verbose>

Verbose mode.

=item B<-c|--confirm>

This flag must be provided in order for the script to actually
sanitize records. If it is not supplied, the script will
only report on the record list to process.

=item B<--biblionumbers=BIBLIONUMBER_LIST>

Give a biblionumber list using this parameter. They must be separated by
commas.

=item B<-f|--filename=FILENAME>

Give a biblionumber list using a filename. One biblionumber by line or separate them with a whitespace character.

=item B<--auto_search>

Automatically search records containing "&amp;" in biblioitems.marcxml or in the specified fields.

=item B<--fix-ampersand>

Replace '&amp;' by '&' in the records.
Replace '&amp;amp;amp;etc.' with '&amp;' in the records.

=item B<--reindex>

Reindex the modified records.

=back

=head1 AUTHOR

Alex Arnaud <alex.arnaud@biblibre.com>
Christophe Croullebois <christophe.croullebois@biblibre.com>
Jonathan Druart <jonathan.druart@biblibre.com>

=head1 COPYRIGHT

Copyright 2014 BibLibre

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later version.

You should have received a copy of the GNU General Public License along
with Koha; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=cut
