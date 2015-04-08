# Copyright 2010 Chris Cormack
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

use strict;
use warnings;

use Test::More;
use File::Spec;
use File::Find;
use IO::File;

my @files =('kohaversion.pl','installer/data/mysql/updatedatabase.pl');

foreach my $file (@files){
    next unless -f $file;
    my @name_parts = File::Spec->splitpath($file);
    my %dirs = map { $_ => 1 } File::Spec->splitdir($name_parts[1]);
    next if exists $dirs{'.git'};

    my $fh = IO::File->new($file, 'r');
    my $xxx_found = 0;
    my $line = 0;
    while (<$fh>) {
       $line++;
       if (/XXX/i) {
           #two lines are an exception for updatedatabase (routine SetVersion and TransferToNum)
           next
               if $file =~ /updatedatabase/
                  && (   /s\/XXX\$\/999\/;/
                      || /\$_\[0\]=~ \/XXX\$\/;/
                      || /version contains XXX/
                      || /\$proposed_version =~ m\/XXX\// );
           $xxx_found = 1;
          last;
       }
     }
     close $fh;
     if ($xxx_found) {
         fail("$file has no XXX in it");
        diag("XXX found in line $line");
     } else {
        pass("$file has no XXX in it");
    }
}

done_testing();
