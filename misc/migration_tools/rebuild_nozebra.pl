#!/usr/bin/perl

use C4::Context;
use Getopt::Long;
use C4::Biblio;
use C4::AuthoritiesMarc;

use strict;
# 
# script that fills the nozebra table
#
#

$|=1; # flushes output

# limit for database dumping
my $limit = "LIMIT 1000";
my $directory;
my $skip_export;
my $keep_export;
my $reset;
my $biblios;
my $authorities;
GetOptions(
	'd:s'      => \$directory,
	'reset'      => \$reset,
	's'        => \$skip_export,
	'k'        => \$keep_export,
	'b'        => \$biblios,
	'a'        => \$authorities,
	);

$directory = "export" unless $directory;
my $dbh=C4::Context->dbh;
$dbh->do("truncate nozebra");
my $sth;
$sth=$dbh->prepare("select biblionumber from biblioitems order by biblionumber $limit");
$sth->execute();
my $i=0;
my %result;

my %index = (
    'title' => '200a,200c,200d',
    'author' =>'200f,700*,701*,702*'
    );

$|=1;
while (my ($biblionumber) = $sth->fetchrow) {
    $i++;
    print "\r$i";
    my $record = GetMarcBiblio($biblionumber);

    # get title of the record (to store the 10 first letters with the index)
    my $title;
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        $title = lc($record->subfield('200','a'));
    } else {
        $title = lc($record->subfield('245','a'));
    }
    # remove blancks and comma (that could cause problem when decoding the string for CQL retrieval
    $title =~ s/ |,|;//g;
    # limit to 10 char, should be enough, and limit the DB size
    $title = substr($title,0,10);
    #parse each field
    foreach my $field ($record->fields()) {
        #parse each subfield
        next if $field->tag <10;
        foreach my $subfield ($field->subfields()) {
            my $tag = $field->tag();
            my $subfieldcode = $subfield->[0];
            my $indexed=0;
            # check each index to see if the subfield is stored somewhere
            # otherwise, store it in __RAW__ index
            foreach my $key (keys %index) {
                if ($index{$key} =~ /$tag\*/ or $index{$key} =~ /$tag$subfield/) {
                    $indexed=1;
                    my $line= lc $subfield->[1];
                    $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\// /g;
                    foreach (split / /,$line) {
                        $result{$key}->{$_}.="$biblionumber;$title," unless $subfield->[0] eq '9';
                    }
                }
            }
            # the subfield is not indexed, store it in __RAW__ index anyway
            unless ($indexed) {
                my $line= lc $subfield->[1];
                $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\// /g;
                foreach (split / /,$line) {
                    $result{'__RAW__'}->{$_}.="$biblionumber;$title," unless $subfield->[0] eq '9';
                }
            }
        }
    }
}
my $sth = $dbh->prepare("INSERT INTO nozebra (indexname,value,biblionumbers) VALUES (?,?,?)");
foreach my $key (keys %result) {
    foreach my $index (keys %{$result{$key}}) {
        $sth->execute($key,$index,$result{$key}->{$index});
    }
}
