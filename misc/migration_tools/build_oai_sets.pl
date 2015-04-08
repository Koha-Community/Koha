#!/usr/bin/perl

# Copyright 2011 BibLibre
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

=head1 DESCRIPTION

This script build OAI-PMH sets (to be used by opac/oai.pl) according to sets
and mappings defined in Koha. It reads informations from oai_sets and
oai_sets_mappings, and then fill table oai_sets_biblios with builded infos.

=head1 USAGE

    build_oai_sets.pl [-h] [-v] [-r] [-i] [-l LENGTH [-o OFFSET]]
        -h          Print help message;
        -v          Be verbose
        -r          Truncate table oai_sets_biblios before inserting new rows
        -i          Embed items informations, mandatory if you defined mappings
                    on item fields
        -l LENGTH   Process LENGTH biblios
        -o OFFSET   If LENGTH is defined, start processing from OFFSET

=cut

use Modern::Perl;
use MARC::Record;
use MARC::File::XML;
use List::MoreUtils qw/uniq/;
use Getopt::Std;

use C4::Context;
use C4::Charset qw/StripNonXmlChars/;
use C4::Biblio;
use C4::OAI::Sets;

my %opts;
$Getopt::Std::STANDARD_HELP_VERSION = 1;
my $go = getopts('vo:l:ihr', \%opts);

if(!$go or $opts{h}){
    &print_usage;
    exit;
}

my $verbose = $opts{v};
my $offset = $opts{o};
my $length = $opts{l};
my $embed_items = $opts{i};
my $reset = $opts{r};

my $dbh = C4::Context->dbh;

# Get OAI sets mappings
my $mappings = GetOAISetsMappings;

# Get all biblionumbers and marcxml
print "Retrieving biblios... " if $verbose;
my $query = qq{
    SELECT biblionumber, marcxml
    FROM biblioitems
};
if($length) {
    $query .= "LIMIT $length";
    if($offset) {
        $query .= " OFFSET $offset";
    }
}
my $sth = $dbh->prepare($query);
$sth->execute;
my $results = $sth->fetchall_arrayref({});
print "done.\n" if $verbose;

# Build lists of parents sets
my $sets = GetOAISets;
my $parentsets;
foreach my $set (@$sets) {
    my $setSpec = $set->{'spec'};
    while($setSpec =~ /^(.+):(.+)$/) {
        my $parent = $1;
        my $parent_set = GetOAISetBySpec($parent);
        if($parent_set) {
            push @{ $parentsets->{$set->{'id'}} }, $parent_set->{'id'};
            $setSpec = $parent;
        } else {
            last;
        }
    }
}

my $num_biblios = scalar @$results;
my $i = 1;
my $sets_biblios = {};
foreach my $res (@$results) {
    my $biblionumber = $res->{'biblionumber'};
    my $marcxml = $res->{'marcxml'};
    if($verbose and $i % 1000 == 0) {
        my $percent = ($i * 100) / $num_biblios;
        $percent = sprintf("%.2f", $percent);
        say "Progression: $i/$num_biblios ($percent %)";
    }
    # The following lines are copied from GetMarcBiblio
    # We don't call GetMarcBiblio to avoid a sql query to be executed each time
    $marcxml = StripNonXmlChars($marcxml);
    MARC::File::XML->default_record_format(C4::Context->preference('marcflavour'));
    my $record;
    eval {
        $record = MARC::Record::new_from_xml($marcxml, "utf8", C4::Context->preference('marcflavour'));
    };
    if($@) {
        warn "(biblio $biblionumber) Error while creating record from marcxml: $@";
        next;
    }
    if($embed_items) {
        C4::Biblio::EmbedItemsInMarcBiblio($record, $biblionumber);
    }

    my @biblio_sets = CalcOAISetsBiblio($record, $mappings);
    foreach my $set_id (@biblio_sets) {
        push @{ $sets_biblios->{$set_id} }, $biblionumber;
        foreach my $parent_set_id ( @{ $parentsets->{$set_id} } ) {
            push @{ $sets_biblios->{$parent_set_id} }, $biblionumber;
        }
    }
    $i++;
}
say "Progression: done." if $verbose;

say "Summary:";
foreach my $set_id (keys %$sets_biblios) {
    $sets_biblios->{$set_id} = [ uniq @{ $sets_biblios->{$set_id} } ];
    my $set = GetOAISet($set_id);
    my $setSpec = $set->{'spec'};
    say "Set '$setSpec': ". scalar(@{$sets_biblios->{$set_id}}) ." biblios";
}

print "Updating database... ";
if($reset) {
    ModOAISetsBiblios( {} );
}
AddOAISetsBiblios($sets_biblios);
print "done.\n";

sub print_usage {
    print "build_oai_sets.pl: Build OAI-PMH sets, according to mappings defined in Koha\n";
    print "Usage: build_oai_sets.pl [-h] [-v] [-i] [-l LENGTH [-o OFFSET]]\n\n";
    print "\t-h\t\tPrint this help and exit\n";
    print "\t-v\t\tBe verbose\n";
    print "\t-i\t\tEmbed items informations, mandatory if you defined mappings on item fields\n";
    print "\t-l LENGTH\tProcess LENGTH biblios\n";
    print "\t-o OFFSET\tIf LENGTH is defined, start processing from OFFSET\n\n";
}
