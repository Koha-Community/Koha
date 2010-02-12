#!/usr/bin/perl
# script to update all translations
use strict;
use warnings;

# Doesn't' handle anymore 'themes' since there is no theme .po files at all

# Get all available language codes
opendir my $fh, "po";
my @langs =  map { ($_) =~ /(.*)-i-opac/ } 
    grep { $_ =~ /.*-opac-/ } readdir($fh);
closedir DIR;

# Map interface name to .po file suffix
my %its = (
    opac     => '-i-opac-t-prog-v-3002000.po',
    intranet => '-i-staff-t-prog-v-3002000.po',
);
for my $lang ( @langs ) {
    print "Language: $lang\n";
    while ( my ($interface, $suffix) = each %its ) {
        my $cmd = "mkdir ../../koha-tmpl/$interface-tmpl/prog/$lang";
        system $cmd;
        $cmd =
            "./tmpl_process3.pl install " .
            "-i ../../koha-tmpl/$interface-tmpl/prog/en/ " .
            "-o ../../koha-tmpl/$interface-tmpl/prog/$lang ".
            "-s po/$lang$suffix -r";
        system $cmd;
    }
    system "./pref-trans install $lang";
}
