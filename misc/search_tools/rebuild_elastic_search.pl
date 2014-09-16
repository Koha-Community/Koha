#!/usr/bin/perl

# This inserts records from a Koha database into elastic search

# Copyright 2014 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

rebuild_elastic_search.pl - inserts records from a Koha database into Elasticsearch

=head1 SYNOPSIS

B<rebuild_elastic_search.pl>
[B<-c|--commit>=C<count>]
[B<-v|--verbose>]
[B<-h|--help>]
[B<--man>]

=head1 DESCRIPTION

=head1 OPTIONS

=over

=item B<-c|--commit>=C<count>

Specify how many records will be batched up before they're added to Elasticsearch.
Higher should be faster, but will cause more RAM usage. Default is 100.

=item B<-d|--delete>

Delete the index and recreate it before indexing.

=item B<-b|--biblionumber>

Only index the supplied biblionumber, mostly for testing purposes. May be
repeated.

=item B<-v|--verbose>

By default, this program only emits warnings and errors. This makes it talk
more. Add more to make it even more wordy, in particular when debugging.

=item B<-h|--help>

Help!

=item B<--man>

Full documentation.

=cut

use autodie;
use Getopt::Long;
use Koha::Biblio;
use Koha::ElasticSearch::Indexer;
use MARC::Field;
use MARC::Record;
use Modern::Perl;
use Pod::Usage;

use Data::Dumper; # TODO remove

my $verbose = 0;
my $commit = 100;
my ($delete, $help, $man);
my (@biblionumbers);

GetOptions(
    'c|commit=i'       => \$commit,
    'd|delete'         => \$delete,
    'b|biblionumber=i' => \@biblionumbers,
    'v|verbose!'       => \$verbose,
    'h|help'           => \$help,
    'man'              => \$man,
);

pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

my $next;
if (@biblionumbers) {
    $next = sub {
        my $r = shift @biblionumbers;
        return () unless defined $r;
        return ($r, Koha::Biblio->get_marc_biblio($r, item_data => 1));
    };
} else {
    my $records = Koha::Biblio->get_all_biblios_iterator();
    $next = sub {
        $records->next();
    }
}
my $indexer = Koha::ElasticSearch::Indexer->new({index => 'biblios' });
if ($delete) {
    # We know it's safe to not recreate the indexer because update_index
    # hasn't been called yet.
    $indexer->delete_index();
}

my $count = 0;
my $commit_count = $commit;
my (@bibnums_buffer, @commit_buffer);
while (scalar(my ($bibnum, $rec) = $next->())) {
    _log(1,"$bibnum\n");
    $count++;

    push @bibnums_buffer, $bibnum;
    push @commit_buffer, $rec;
    if (!(--$commit_count)) {
        _log(2, "Committing...\n");
        $indexer->update_index(\@bibnums_buffer, \@commit_buffer);
        $commit_count = $commit;
        @bibnums_buffer = ();
        @commit_buffer = ();
    }
}
# There are probably uncommitted records
$indexer->update_index(\@bibnums_buffer, \@commit_buffer);
_log(1, "$count records indexed.\n");

# Output progress information.
#
#   _log($level, $msg);
#
# Will output $msg if the verbosity setting is set to $level or more. Will
# not include a trailing newline.
sub _log {
    my ($level, $msg) = @_;

    print $msg if ($verbose <= $level);
}
