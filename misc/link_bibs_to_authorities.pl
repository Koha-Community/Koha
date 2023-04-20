#!/usr/bin/perl

use strict;
use warnings;

use Koha::Script;
use C4::Context;
use C4::Biblio qw(
    GetFrameworkCode
    LinkBibHeadingsToAuthorities
    ModBiblio
);
use Koha::Biblios;
use Getopt::Long qw( GetOptions );
use Pod::Usage qw( pod2usage );
use Time::HiRes qw( time );
use POSIX qw( ceil strftime );
use Module::Load::Conditional qw( can_load );

use Koha::SearchEngine;
use Koha::SearchEngine::Indexer;

sub usage {
    pod2usage( -verbose => 2 );
    exit;
}

$| = 1;

# command-line parameters
my $verbose     = 0;
my $link_report = 0;
my $test_only   = 0;
my $want_help   = 0;
my $auth_limit;
my $bib_limit;
my $commit = 100;
my $tagtolink;
my $allowrelink = C4::Context->preference("CatalogModuleRelink") || '';

my $result = GetOptions(
    'v|verbose'      => \$verbose,
    't|test'         => \$test_only,
    'l|link-report'  => \$link_report,
    'a|auth-limit=s' => \$auth_limit,
    'b|bib-limit=s'  => \$bib_limit,
    'c|commit=i'     => \$commit,
    'g|tagtolink=i'  => \$tagtolink,
    'h|help'         => \$want_help
);

binmode( STDOUT, ":encoding(UTF-8)" );

if ( not $result or $want_help ) {
    usage();
}

my $linker_module =
  "C4::Linker::" . ( C4::Context->preference("LinkerModule") || 'Default' );
unless ( can_load( modules => { $linker_module => undef } ) ) {
    $linker_module = 'C4::Linker::Default';
    unless ( can_load( modules => { $linker_module => undef } ) ) {
        die "Unable to load linker module. Aborting.";
    }
}

my $linker = $linker_module->new(
    {
        'auth_limit' => $auth_limit,
        'options'    => C4::Context->preference("LinkerOptions")
    }
);

my $num_bibs_processed = 0;
my $num_bibs_modified  = 0;
my $num_bad_bibs       = 0;
my %unlinked_headings;
my %linked_headings;
my %fuzzy_headings;
my $dbh = C4::Context->dbh;
my @updated_biblios = ();
my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });

$dbh->{AutoCommit} = 0;
process_bibs( $linker, $bib_limit, $auth_limit, $commit, { tagtolink => $tagtolink, allowrelink => $allowrelink });
$dbh->commit();

exit 0;

sub process_bibs {
    my ( $linker, $bib_limit, $auth_limit, $commit, $args ) = @_;
    my $tagtolink = $args->{tagtolink};
    my $allowrelink = $args->{allowrelink};
    my $bib_where = '';
    my $starttime = time();
    if ($bib_limit) {
        $bib_where = "WHERE $bib_limit";
    }
    my $sql =
      "SELECT biblionumber FROM biblio $bib_where ORDER BY biblionumber ASC";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    my $linker_args = { tagtolink => $tagtolink, allowrelink => $allowrelink };
    while ( my ($biblionumber) = $sth->fetchrow_array() ) {
        $num_bibs_processed++;
        process_bib( $linker, $biblionumber, $linker_args );

        if ( not $test_only and ( $num_bibs_processed % $commit ) == 0 ) {
            print_progress_and_commit($num_bibs_processed);
        }
    }

    if ( not $test_only ) {
        $dbh->commit;
        $dbh->{AutoCommit} = 1;
        $indexer->index_records( \@updated_biblios, "specialUpdate", "biblioserver" );
    }

    my $headings_linked   = 0;
    my $headings_unlinked = 0;
    my $headings_fuzzy    = 0;
    for ( values %linked_headings )   { $headings_linked   += $_; }
    for ( values %unlinked_headings ) { $headings_unlinked += $_; }
    for ( values %fuzzy_headings )    { $headings_fuzzy    += $_; }

    my $endtime = time();
    my $totaltime = ceil (($endtime - $starttime) * 1000);
    $starttime = strftime('%D %T', localtime($starttime));
    $endtime = strftime('%D %T', localtime($endtime));

    my $summary = <<_SUMMARY_;

Bib authority heading linking report
=======================================================
Linker module:                          $linker_module
Run started at:                         $starttime
Run ended at:                           $endtime
Total run time:                         $totaltime ms
Number of bibs checked:                 $num_bibs_processed
Number of bibs modified:                $num_bibs_modified
Number of bibs with errors:             $num_bad_bibs
Number of headings linked:              $headings_linked
Number of headings unlinked:            $headings_unlinked
Number of headings fuzzily linked:      $headings_fuzzy
_SUMMARY_
    $summary .= "\n****  Ran in test mode only  ****\n" if $test_only;
    print $summary;

    if ($link_report) {
        my @keys;
        print <<_LINKED_HEADER_;

Linked headings (from most frequent to least):
-------------------------------------------------------

_LINKED_HEADER_

        @keys = sort {
            $linked_headings{$b} <=> $linked_headings{$a} or "\L$a" cmp "\L$b"
        } keys %linked_headings;
        foreach my $key (@keys) {
            print "$key:\t" . $linked_headings{$key} . " occurrences\n";
        }

        print <<_UNLINKED_HEADER_;

Unlinked headings (from most frequent to least):
-------------------------------------------------------

_UNLINKED_HEADER_

        @keys = sort {
            $unlinked_headings{$b} <=> $unlinked_headings{$a}
              or "\L$a" cmp "\L$b"
        } keys %unlinked_headings;
        foreach my $key (@keys) {
            print "$key:\t" . $unlinked_headings{$key} . " occurrences\n";
        }

        print <<_FUZZY_HEADER_;

Fuzzily-matched headings (from most frequent to least):
-------------------------------------------------------

_FUZZY_HEADER_

        @keys = sort {
            $fuzzy_headings{$b} <=> $fuzzy_headings{$a} or "\L$a" cmp "\L$b"
        } keys %fuzzy_headings;
        foreach my $key (@keys) {
            print "$key:\t" . $fuzzy_headings{$key} . " occurrences\n";
        }
        print $summary;
    }
}

sub process_bib {
    my $linker       = shift;
    my $biblionumber = shift;
    my $args = shift;
    my $tagtolink    = $args->{tagtolink};
    my $allowrelink = $args->{allowrelink};
    my $biblio = Koha::Biblios->find($biblionumber);
    my $record = $biblio->metadata->record;
    unless ( defined $record ) {
        print
"\nCould not retrieve bib $biblionumber from the database - record is corrupt.\n";
        $num_bad_bibs++;
        return;
    }

    my $frameworkcode = GetFrameworkCode($biblionumber);

    my ( $headings_changed, $results ) =
      LinkBibHeadingsToAuthorities( $linker, $record, $frameworkcode, $allowrelink, $tagtolink );
    foreach my $key ( keys %{ $results->{'unlinked'} } ) {
        $unlinked_headings{$key} += $results->{'unlinked'}->{$key};
    }
    foreach my $key ( keys %{ $results->{'linked'} } ) {
        $linked_headings{$key} += $results->{'linked'}->{$key};
    }
    foreach my $key ( keys %{ $results->{'fuzzy'} } ) {
        $fuzzy_headings{$key} += $results->{'fuzzy'}->{$key};
    }

    if ($headings_changed) {
        if ($verbose) {
            my $title = substr( $record->title, 0, 20 );
            printf(
                "Bib %12d (%-20s): %3d headings changed\n",
                $biblionumber,
                $title,
                $headings_changed
            );
        }
        if ( not $test_only ) {
            ModBiblio( $record, $biblionumber, $frameworkcode, {
                disable_autolink => 1,
                skip_holds_queue => 1,
                skip_record_index =>1
            });
            push @updated_biblios, $biblionumber;
            #Last param is to note ModBiblio was called from linking script and bib should not be linked again
            $num_bibs_modified++;
        }
    }
}

sub print_progress_and_commit {
    my $recs = shift;
    $dbh->commit();
    $dbh->{AutoCommit} = 1;
    $indexer->index_records( \@updated_biblios, "specialUpdate", "biblioserver" );
    $dbh->{AutoCommit} = 0;
    @updated_biblios = ();
    print "... processed $recs records\n";
}

=head1 NAME

link_bibs_to_authorities.pl

=head1 SYNOPSIS

  link_bibs_to_authorities.pl
  link_bibs_to_authorities.pl -v
  link_bibs_to_authorities.pl -l
  link_bibs_to_authorities.pl --commit=1000
  link_bibs_to_authorities.pl --auth-limit=STRING
  link_bibs_to_authorities.pl --bib-limit=STRING
  link_bibs_to_authorities.pl -g=700

=head1 DESCRIPTION

This batch job checks each bib record in the Koha database and attempts to link
each of its headings to the matching authority record.

=over 8

=item B<--help>

Prints this help

=item B<-v|--verbose>

Provide verbose log information (print the number of headings changed for each
bib record).

=item B<-l|--link-report>

Provide a report of all the headings that were processed: which were matched,
which were not, etc.

=item B<--auth-limit=S>

Only process those headings which match an authority record that matches the
user-specified WHERE clause.

=item B<--bib-limit=S>

Only process those bib records that match the user-specified WHERE clause.

=item B<--commit=N>

Commit the results to the database after every N records are processed.

=item B<-g=N>

Only process those headings found in MARC field N.

=item B<--test>

Only test the authority linking and report the results; do not change the bib
records.

=back

=cut
