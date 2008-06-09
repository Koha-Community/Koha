#!/usr/bin/perl 

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

=head1 NAME

syspref-diff.pl <syspref-file-1> <syspref-file-2> 

For example: 

  cd <koharoot>/installer/data/mysql
  syspref-diff.pl en/mandatory.sql fr-FR/1-Obligatoire/unimarcsp.sql

=head1 DESCRIPTION

Make a diff between two Koha syspref files. 
'en' syspref file beeing authoritative, this script identifies
variables to be added/deleted in another language syspref file.

=cut

use strict;


my $file1 = shift @ARGV;
my $file2 = shift @ARGV;

open FILE1, "<$file1" or die "Unable to open $file1\n";
open FILE2, "<$file2" or die "Unable to open $file2\n";

my (%syspref1, %syspref2);
my $variable;

while ( <FILE1> ) {
    /VALUES.*\(\'([\w-:]+)\'/;
    $variable = lc $1; 
    $syspref1{$variable} = 1 unless $syspref1{$variable};
}
while ( <FILE2> ) {
    /VALUES.*\(\'([\w-:]+)\'/;
    $variable = lc $1;
    $syspref2{$variable} = 1 unless $syspref2{$variable};
}

print "Variables present in $file1 but unavailable in $file2\n";
for ( sort keys %syspref1 ) {
    print $_, "\n" unless $syspref2{$_};
}
print "\nVariables present in $file2 but unavailable in $file2\n";
for ( sort keys %syspref2 ) {
    print $_, "\n" unless $syspref1{$_};
}


