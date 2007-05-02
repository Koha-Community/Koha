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
my $limit = "LIMIT 100";
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
$dbh->do("update systempreferences set value=1 where variable='NoZebra'");
$dbh->do("CREATE TABLE `nozebra` (
                `indexname` varchar(40) character set latin1 NOT NULL,
                `value` varchar(250) character set latin1 NOT NULL,
                `biblionumbers` longtext character set latin1 NOT NULL,
                KEY `indexname` (`indexname`),
                KEY `value` (`value`))
                ENGINE=InnoDB DEFAULT CHARSET=utf8");
$dbh->do("truncate nozebra");
my $sth;
$sth=$dbh->prepare("select biblionumber from biblioitems order by biblionumber $limit");
$sth->execute();
my $i=0;
my %result;

my %index = GetNoZebraIndexes();

$|=1;
while (my ($biblionumber) = $sth->fetchrow) {
    $i++;
    print "\r$i";
    my $record = GetMarcBiblio($biblionumber);

    # get title of the record (to store the 10 first letters with the index)
    my ($titletag,$titlesubfield) = GetMarcFromKohaField('biblio.title');
    my $title = lc($record->subfield($titletag,$titlesubfield));

    # remove blancks comma (that could cause problem when decoding the string for CQL retrieval) and regexp specific values
    $title =~ s/ |,|;|\[|\]|\(|\)|\*|-|'|=//g;
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
                if ($index{$key} =~ /$tag\*/ or $index{$key} =~ /$tag$subfieldcode/) {
                    $indexed=1;
                    my $line= lc $subfield->[1];
                    # remove meaningless value in the field...
                    $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=/ /g;
                    # ... and split in words
                    foreach (split / /,$line) {
                        next unless $_; # skip  empty values (multiple spaces)
                        # if the entry is already here, improve weight
                        if ($result{$key}->{$_} =~ /$biblionumber,$title\-(\d);/) {
                            my $weight=$1+1;
                            $result{$key}->{$_} =~ s/$biblionumber,$title\-(\d);//;
                            $result{$key}->{$_} .= "$biblionumber,$title-$weight;";
                        # otherwise, create it, with weight=1
                        } else {
                            $result{$key}->{$_}.="$biblionumber,$title-1;";
                        }
                    }
                }
            }
            # the subfield is not indexed, store it in __RAW__ index anyway
            unless ($indexed) {
                my $line= lc $subfield->[1];
                $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=/ /g;
                foreach (split / /,$line) {
                        next unless $_;
#                     warn $record->as_formatted."$_ =>".$title;
                        if ($result{__RAW__}->{$_} =~ /$biblionumber,$title\-(\d);/) {
                            my $weight=$1+1;
#                             $weight++;
                            $result{__RAW__}->{$_} =~ s/$biblionumber,$title\-(\d);//;
                            $result{__RAW__}->{$_} .= "$biblionumber,$title-$weight;";
                        } else {
                            $result{__RAW__}->{$_}.="$biblionumber,$title-1;";
                        }
                }
            }
        }
    }
}
my $sth = $dbh->prepare("INSERT INTO nozebra (indexname,value,biblionumbers) VALUES (?,?,?)");
foreach my $key (keys %result) {
    foreach my $index (keys %{$result{$key}}) {
        $sth->execute($key,$index,$result{$key}->{$index});
        if (length($result{$key}->{$index}) > 40000) {
            print length($result{$key}->{$index})."\n for $key / $index\n";
        }
    }
}
