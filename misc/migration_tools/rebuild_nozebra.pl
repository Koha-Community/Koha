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
my $limit;# = "LIMIT 100";
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

unless (%index) {
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        $dbh->do("UPDATE systempreferences SET value=\"'title' => '200a,200c,200d,200e,225a,225d,225e,225f,225h,225i,225v,500*,501*,503*,510*,512*,513*,514*,515*,516*,517*,518*,519*,520*,530*,531*,532*,540*,541*,545*,604t,610t,605a',
        'author' =>'200f,600a,601a,604a,700a,700b,700c,700d,700a,701b,701c,701d,702a,702b,702c,702d,710a,710b,710c,710d,711a,711b,711c,711d,712a,712b,712c,712d',
        'isbn' => '010a',
        'issn' => '011a',
        'biblionumber' =>'0909',
        'itemtype' => '200b',
        'language' => '010a',
        'publisher' => '210x',
        'date' => '210d',
        'note' => '300a,301a,302a,303a,304a,305a,306az,307a,308a,309a,310a,311a,312a,313a,314a,315a,316a,317a,318a,319a,320a,321a,322a,323a,324a,325a,326a,327a,328a,330a,332a,333a,336a,337a,345a',
        'Koha-Auth-Number' => '6009,6019,6029,6039,6049,6059,6069,6109',
        'subject' => '600*,601*,606*,610*',
        'dewey' => '676a',
        'host-item' => '995a,995c',\" where variable='NoZebraIndexes'");
        %index = GetNoZebraIndexes();
    } else {
        # build a MARC21 default index file
    }
}
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
        if (length($result{$key}->{$index}) > 1000000) {
            print "very long index (".length($result{$key}->{$index}).")for $key / $index. update mySQL config file if you have an error just after this warning (max_paquet_size parameter)\n";
        }
        $sth->execute($key,$index,$result{$key}->{$index});
    }
}
