#!/usr/bin/perl

# Copyright 2012 BibLibre
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

=head1 batchdeletebiblios.pl

    This script batch deletes biblios which contain a biblionumber present in file passed in parameter.
    If one biblio has items, it is not deleted.

=cut

use Modern::Perl;
use C4::Biblio;

use IO::File;

for my $file ( @ARGV ) {
    say "Find biblionumber in file $file";
    open(FD, $file) or say "Error: '$file' $!" and next;

    while ( <FD> ) {
        my $biblionumber = $_;
        $biblionumber =~ s/$1/\n/g if $biblionumber =~ m/(\r\n?|\n\r?)/;
        chomp $biblionumber;
        my $dbh = C4::Context->dbh;
        next if not $biblionumber =~ /^\d*$/;
        print "Delete biblionumber $biblionumber ";
        my $error;
        eval {
            $error = DelBiblio $biblionumber;
        };
        if ( $@ or $error) {
            say "KO $@ ($! | $error)";
        } else {
            say "OK";
        }
    }
}
