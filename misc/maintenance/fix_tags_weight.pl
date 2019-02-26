#!/usr/bin/perl

# Copyright 2018 Theke Solutions
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

use Modern::Perl;

use C4::Context;
use C4::Tags;

use Koha::Database;
use Koha::Tags;
use Koha::Tags::Approvals;
use Koha::Tags::Indexes;

use Getopt::Long;
use Pod::Usage;

=head1 NAME

fix_tags_weight.pl - Fix weight for tags

=head1 SYNOPSIS

fix_tags_weight.pl [ --verbose or -v ] [ --help or -h ]

 Options:
   --help or -h         Brief usage message
   --verbose or -v      Be verbose

=head1 DESCRIPTION

This script fixes the calculated weights for the tags introduced by patrons.

=over 8

=item B<--help>

Prints a brief usage message and exits.

=item B<--verbose>

Prints information about the current weight, and the new one for each term/biblionumber.

=back

=cut

binmode( STDOUT, ":encoding(UTF-8)" );

my $help;
my $verbose;

GetOptions(
    'help|h'    => \$help,
    'verbose|v' => \$verbose
) or pod2usage(2);

pod2usage(1) if $help;

fix_tags_approval($verbose);
fix_tags_index( $verbose );

sub fix_tags_approval {

    my ($verbose) = @_;

    print "Fix tags_approval\n=================\n" if $verbose;

    my $dbh = C4::Context->dbh;
    # Search the terms in tags_all that don't exist in tags_approval
    my $sth = $dbh->prepare(
        q{
        SELECT term
        FROM (
            SELECT DISTINCT(tags_all.term) AS term, tags_approval.term AS approval FROM tags_all
            LEFT JOIN tags_approval
            ON (tags_all.term=tags_approval.term)) a
        WHERE approval IS NULL;
    }
    );
    $sth->execute();
    my $approved = C4::Context->preference('TagsModeration') ? 0 : 1;

    # Add missing terms to tags_approval
    while ( my $row = $sth->fetchrow_hashref ) {
        my $term = $row->{term};
        C4::Tags::add_tag_approval( $term, 0, $approved );
        print "Added => $term\n";
    }

    my $approvals = Koha::Tags::Approvals->search;
    # Recalculate weight_total for all tags_approval rows
    while ( my $approval = $approvals->next ) {
        my $count = Koha::Tags->search( { term => $approval->term } )->count;
        print $approval->term . "\t|\t" . $approval->weight_total . "\t=>\t" . $count . "\n"
            if $verbose;
        $approval->weight_total($count)->store;
    }
}

sub fix_tags_index {

    my ($verbose) = @_;
    my $indexes = Koha::Tags::Indexes->search;

    print "Fix tags_index\n==============\n" if $verbose;

    while ( my $index = $indexes->next ) {
        my $count
            = Koha::Tags->search( { term => $index->term, biblionumber => $index->biblionumber } )
            ->count;
        print $index->term . "/"
            . $index->biblionumber . "\t|\t"
            . $index->weight
            . "\t=>\t"
            . $count . "\n"
            if $verbose;
        $index->weight($count)->store;
    }
}

1;
