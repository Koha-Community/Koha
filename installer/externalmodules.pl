#!/usr/bin/perl

# This Script can be used to provide a list of ALL external modules ***used*** (uncommented) in Koha.
# It provides you not only the list of modules BUT ALSO the files that uses those modules.
# utf8 or warnings or other lib use are not taken into account at the moment.


use strict;
use warnings;
use C4::Context;
my $dir=C4::Context->config('intranetdir');
qx(grep -r "^ *use" $dir | grep -v "C4\|strict\|vars" >/tmp/modulesKoha.log);
$dir=C4::Context->config('opacdir');
qx(grep -r "^ *use" $dir | grep -v "C4\|strict\|vars" >>/tmp/modulesKoha.log);

open FILE, "< /tmp/modulesKoha.log" ||die "unable to open file /tmp/modulesKoha.log";
my %modulehash;
while (my $line=<FILE>){
  if ( $line=~m#(.*)\:\s*use\s+([A-Z][^\s;]+)# ){
    my ($file,$module)=($1,$2);
    my @filename = split /\//, $file;
    push @{$modulehash{$module}},$filename[scalar(@filename) - 1];
  }
}
print "external modules used in Koha ARE :\n";
map {print "* $_ \t in files ",join (",",@{$modulehash{$_}}),"\n" } sort keys %modulehash;
close FILE;
unlink "/tmp/modulesKoha.log";
