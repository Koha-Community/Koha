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
my $sysprefs;
my $commit;

GetOptions(
    'd:s'      => \$directory,
    'reset'      => \$reset,
    's'        => \$skip_export,
    'k'        => \$keep_export,
    'b'        => \$biblios,
    'a'        => \$authorities,
    's'        => \$sysprefs,  # rebuild 'NoZebraIndexes' syspref
    'commit:f'    => \$commit,
    );

my $commitnum = 1000; 
$commitnum = $commit if ($commit) ;

$directory = "export" unless $directory;
my $dbh=C4::Context->dbh;
$dbh->do("update systempreferences set value=1 where variable='NoZebra'");

$dbh->do("truncate nozebra");

my %index = GetNoZebraIndexes();

if  (!%index || $sysprefs ) {
    if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
        $dbh->do("UPDATE systempreferences SET value=\"'title' => '200a,200c,200d,200e,225a,225d,225e,225f,225h,225i,225v,500*,501*,503*,510*,512*,513*,514*,515*,516*,517*,518*,519*,520*,530*,531*,532*,540*,541*,545*,604t,610t,605a',
        'author' =>'200f,600a,601a,604a,700a,700b,700c,700d,700a,701b,701c,701d,702a,702b,702c,702d,710a,710b,710c,710d,711a,711b,711c,711d,712a,712b,712c,712d',
        'isbn' => '010a',
        'issn' => '011a',
        'biblionumber' =>'0909',
        'itemtype' => '200b',
        'language' => '101a',
        'publisher' => '210c',
        'date' => '210d',
        'note' => '300a,301a,302a,303a,304a,305a,306az,307a,308a,309a,310a,311a,312a,313a,314a,315a,316a,317a,318a,319a,320a,321a,322a,323a,324a,325a,326a,327a,328a,330a,332a,333a,336a,337a,345a',
        'Koha-Auth-Number' => '6009,6019,6029,6039,6049,6059,6069,6109,7009,7019,7029,7109,7119,7129',
        'subject' => '600*,601*,606*,610*',
        'dewey' => '676a',
        'host-item' => '995a,995c',\" where variable='NoZebraIndexes'");
        %index = GetNoZebraIndexes();
    } elsif (C4::Context->preference('marcflavour') eq 'MARC21') {
        $dbh->do("UPDATE systempreferences SET value=\"
'title' => '130a,210a,222a,240a,243a,245a,245b,246a,246b,247a,247b,250a,250b,440a,830a',
'author' => '100a,100b,100c,100d,110a,111a,111b,111c,111d,245c,700a,710a,711a,800a,810a,811a',
'isbn' => '020a',
'issn' => '022a',
'lccn' => '010a',
'biblionumber => '999c',
'itemtype' => '942c',
'publisher' => '260b',
'date' => '260c',
'note' => '500a, 501a,504a,505a,508a,511a,518a,520a,521a,522a,524a,526a,530a,533a,538a,541a,546a,555a,556a,562a,563a,583a,585a,582a',
'subject' => '600*,610*,611*,630*,650*,651*,653*,654*,655*,662*,690*',
'dewey' => '082',
'bc' => '952p',
'callnum' => '952o',
'an' => '6009,6109,6119',
'series' => 440*,490*,
'host-item' => '9529
'shelf' => '952c',
'collection' => '9528',
\"WHERE variable='NoZebraIndexes'");

        %index = GetNoZebraIndexes();
    }
}
$|=1;

$dbh->{AutoCommit} = 0;

print "***********************************\n";
print "***** building BIBLIO indexes *****\n";
print "***********************************\n";

my $sth;
$sth=$dbh->prepare("select biblionumber from biblioitems order by biblionumber $limit");
$sth->execute();
my $i=0;
my %result;
while (my ($biblionumber) = $sth->fetchrow) {
        $i++;
        print "\r$i";
        my  $record;
    eval{
            $record = GetMarcBiblio($biblionumber);
    };
    if($@){
            print "  There was some pb getting biblionumber : ".$biblionumber."\n";
            next;
    }
    next unless $record;
    # get title of the record (to store the 10 first letters with the index)
    my ($titletag,$titlesubfield) = GetMarcFromKohaField('biblio.title', '');
    my $title = lc($record->subfield($titletag,$titlesubfield));

    # remove blancks comma (that could cause problem when decoding the string for CQL retrieval) and regexp specific values
    $title =~ s/ |\.|,|;|\[|\]|\(|\)|\*|-|'|=|://g;
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
                if ($index{$key} =~ /\Q$tag\E\*/ or $index{$key} =~ /\Q$tag$subfieldcode\E/) {
                    $indexed=1;
                    my $line= lc $subfield->[1];
                    # remove meaningless value in the field...
                    $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:/ /g;
                    # ... and split in words
                    foreach (split / /,$line) {
                        next unless $_; # skip  empty values (multiple spaces)
                        # remove any accented char
                        # if the entry is already here, improve weight
                        if ($result{$key}->{"$_"} =~ /$biblionumber,\Q$title\E\-(\d);/) {
                            my $weight=$1+1;
                            $result{$key}->{"$_"} =~ s/$biblionumber,\Q$title\E\-(\d);//;
                            $result{$key}->{"$_"} .= "$biblionumber,$title-$weight;";
                        # otherwise, create it, with weight=1
                        } else {
                            $result{$key}->{"$_"}.="$biblionumber,$title-1;";
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
                        if ($result{__RAW__}->{"$_"} =~ /$biblionumber,\Q$title\E\-(\d);/) {
                            my $weight=$1+1;
#                             $weight++;
                            $result{__RAW__}->{"$_"} =~ s/$biblionumber,\Q$title\E\-(\d);//;
                            $result{__RAW__}->{"$_"} .= "$biblionumber,$title-$weight;";
                        } else {
                            $result{__RAW__}->{"$_"}.="$biblionumber,$title-1;";
                        }
                }
            }
        }
    }
}


print "\nInserting records...\n";
$i=0;

my $commitnum = 100;
$dbh->{AutoCommit} = 0;

$sth = $dbh->prepare("INSERT INTO nozebra (server,indexname,value,biblionumbers) VALUES ('biblioserver',?,?,?)");
foreach my $key (keys %result) {
    foreach my $index (keys %{$result{$key}}) {
        if (length($result{$key}->{$index}) > 1000000) {
            print "very long index (".length($result{$key}->{$index}).")for $key / $index. update mySQL config file if you have an error just after this warning (max_paquet_size parameter)\n";
        }
        print "\r$i";
        $i++;
        $sth->execute($key,$index,$result{$key}->{$index});
        $dbh->commit() if (0 == $i % $commitnum);
    }
   $dbh->commit() if (0 == $i % $commitnum);
}
$dbh->commit;


print "\nbiblios done\n";

print "\n***********************************\n";
print "***** building AUTHORITIES indexes *****\n";
print "***********************************\n";

$sth=$dbh->prepare("select authid from auth_header order by authid $limit");
$sth->execute();
$i=0;
%result = ();
while (my ($authid) = $sth->fetchrow) {
    $i++;
    print "\r$i";
    my $record;
    eval{
        $record = GetAuthority($authid);
    };
    if($@){
        print "  There was some pb getting authnumber : ".$authid."\n";
        next;
    }
    
    my %index;
    # for authorities, the "title" is the $a mainentry
    my $authref = C4::AuthoritiesMarc::GetAuthType(C4::AuthoritiesMarc::GetAuthTypeCode($authid));

    warn "ERROR : authtype undefined for ".$record->as_formatted unless $authref;
    my $title = $record->subfield($authref->{auth_tag_to_report},'a');
    $index{'mainmainentry'}= $authref->{'auth_tag_to_report'}.'a';
    $index{'mainentry'}    = $authref->{'auth_tag_to_report'}.'*';
    $index{'auth_type'}    = '152b';

    # remove blancks comma (that could cause problem when decoding the string for CQL retrieval) and regexp specific values
    $title =~ s/ |\.|,|;|\[|\]|\(|\)|\*|-|'|:|=//g;
    $title = quotemeta $title;
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
                    $line =~ s/-|\.|\?|,|;|!|'|\(|\)|\[|\]|{|}|"|<|>|&|\+|\*|\/|=|:/ /g;
                    # ... and split in words
                    foreach (split / /,$line) {
                        next unless $_; # skip  empty values (multiple spaces)
                        # if the entry is already here, improve weight
                        if ($result{$key}->{"$_"} =~ /$authid,$title\-(\d);/) {
                            my $weight=$1+1;
                            $result{$key}->{"$_"} =~ s/$authid,$title\-(\d);//;
                            $result{$key}->{"$_"} .= "$authid,$title-$weight;";
                        # otherwise, create it, with weight=1
                        } else {
                            $result{$key}->{"$_"}.="$authid,$title-1;";
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
                        if ($result{__RAW__}->{"$_"} =~ /$authid,$title\-(\d);/) {
                            my $weight=$1+1;
#                             $weight++;
                            $result{__RAW__}->{"$_"} =~ s/$authid,$title\-(\d);//;
                            $result{__RAW__}->{"$_"} .= "$authid,$title-$weight;";
                        } else {
                            $result{__RAW__}->{"$_"}.="$authid,$title-1;";
                        }
                }
            }
        }
    }
}



print "\nInserting...\n";
$i=0;

my $commitnum = 100;
$dbh->{AutoCommit} = 0;
$sth = $dbh->prepare("INSERT INTO nozebra (server,indexname,value,biblionumbers) VALUES ('authorityserver',?,?,?)");
foreach my $key (keys %result) {
    foreach my $index (keys %{$result{$key}}) {
        if (length($result{$key}->{$index}) > 1000000) {
            print "very long index (".length($result{$key}->{$index}).")for $key / $index. update mySQL config file if you have an error just after this warning (max_paquet_size parameter)\n";
        }
        print "\r$i";
        $i++;
        $sth->execute($key,$index,$result{$key}->{$index});
        $dbh->commit() if (0 == $i % $commitnum);
    }
   $dbh->commit() if (0 == $i % $commitnum);
}
$dbh->commit;
print "\nauthorities done\n";
