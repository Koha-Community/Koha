#!/usr/bin/perl

use C4::Context;
use Getopt::Long;
use C4::Biblio;

# 
# script that checks zebradir structure & create directories & mandatory files if needed
#
#

$|=1; # flushes output

print "Zebra directory =>".C4::Context->zebraconfig('biblioserver')->{directory}."\n";
print "Koha directory =>".C4::Context->config('intranetdir')."\n";

my $zebradir = C4::Context->zebraconfig('biblioserver')->{directory};
my $kohadir = C4::Context->config('intranetdir');
my $directory;
my $skip_export;
my $keep_export;
GetOptions(
	'd:s'      => \$directory,
	's'        => \$skip_export,
	'k'        => \$keep_export,
	);

$directory = "export" unless $directory;

my $created_dir_or_file = 0;
print "====================\n";
print "checking directories & files\n";
print "====================\n";
unless (-d "$zebradir") {
    system("mkdir -p $zebradir");
    print "created $zebradir\n";
    $created_dir_or_file++;
}
unless (-d "$zebradir/lock") {
    mkdir "$zebradir/lock";
    print "created $zebradir/lock\n";
    $created_dir_or_file++;
}
unless (-d "$zebradir/register") {
    mkdir "$zebradir/register";
    print "created $zebradir/register\n";
    $created_dir_or_file++;
}
unless (-d "$zebradir/shadow") {
    mkdir "$zebradir/shadow";
    print "created $zebradir/shadow\n";
    $created_dir_or_file++;
}
unless (-d "$zebradir/tab") {
    mkdir "$zebradir/tab";
    print "created $zebradir/tab\n";
    $created_dir_or_file++;
}

unless (-d "$zebradir/etc") {
    mkdir "$zebradir/etc";
    print "created $zebradir/etc\n";
    $created_dir_or_file++;
}

unless (-f "$zebradir/tab/record.abs") {
    system("cp -f $kohadir/zebraplugin/zebradb/biblios/tab/record_for_unimarc.abs $zebradir/tab/record.abs");
    print "copied record.abs\n";
    $created_dir_or_file++;
}
unless (-f "$zebradir/tab/sort-string-utf.chr") {
    system("cp -f $kohadir/zebraplugin/zebradb/biblios/tab/sort-string-utf.chr $zebradir/tab/sort-string-utf.chr");
    print "copied sort-string-utf.chr\n";
    $created_dir_or_file++;
}
unless (-f "$zebradir/tab/word-phrase-utf.chr") {
    system("cp -f $kohadir/zebraplugin/zebradb/biblios/tab/word-phrase-utf.chr $zebradir/tab/word-phrase-utf.chr");
    print "copied word-phase-utf.chr\n";
    $created_dir_or_file++;
}
unless (-f "$zebradir/tab/bib1.att") {
    system("cp -f $kohadir/zebraplugin/zebradb/biblios/tab/bib1.att $zebradir/tab/bib1.att");
    print "copied bib1.att\n";
    $created_dir_or_file++;
}

unless (-f "$zebradir/etc/zebra-biblios.cfg") {
    system("cp -f $kohadir/zebraplugin/etc/zebra-biblios.cfg $zebradir/etc/zebra-biblios.cfg");
    print "copied zebra-biblios.cfg\n";
    $created_dir_or_file++;
}
unless (-f "$zebradir/etc/ccl.properties") {
    system("cp -f $kohadir/zebraplugin/etc/ccl.properties $zebradir/etc/ccl.properties");
    print "copied ccl.properties\n";
    $created_dir_or_file++;
}
unless (-f "$zebradir/etc/pqf.properties") {
    system("cp -f $kohadir/zebraplugin/etc/pqf.properties $zebradir/etc/pqf.properties");
    print "copied pqf.properties\n";
    $created_dir_or_file++;
}

if ($created_dir_or_file) {
    print "created : $created_dir_or_file directories & files\n";
} else {
    print "file & directories OK\n";
}

if ($skip_export) {
    print "====================\n";
    print "SKIPPING biblio export\n";
    print "====================\n";
} else {
    print "====================\n";
    print "exporting biblios\n";
    print "====================\n";
    mkdir "$directory" unless (-d $directory);
    open(OUT,">:utf8","$directory/export") or die $!;
    my $dbh=C4::Context->dbh;
    my $sth;
    $sth=$dbh->prepare("select biblionumber from biblioitems order by biblionumber");
    $sth->execute();
    my $i=0;
    while (my ($biblionumber) = $sth->fetchrow) {
        my $record = MARCgetbiblio($dbh,$biblionumber);
        print ".";
        print "\r$i" unless ($i++ %100);
        print OUT $record->as_usmarc();
    }
    close(OUT);
}

print "====================\n";
print "REINDEXING zebra\n";
print "====================\n";
system("zebraidx -g iso2709 -c $zebradir/etc/zebra-biblios.cfg -d biblios update $directory");
system("zebraidx -g iso2709 -c $zebradir/etc/zebra-biblios.cfg -d biblios commit");

print "====================\n";
print "CLEANING\n";
print "====================\n";
if ($k) {
    print "NOTHING cleaned : the $directory has been kept. You can re-run this script with the -s parameter if you just want to rebuild zebra after changing the record.abs or another zebra config file\n";
} else {
    system("rm -rf $zebradir");
    print "directory $zebradir deleted\n";
}
}