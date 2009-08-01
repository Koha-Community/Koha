#!/usr/bin/perl -w

# Copyright 2009 PTFS, Inc.
#
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

use strict;
use warnings;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Dates;
#use C4::Debug;
#use C4::Letters;
#use File::Spec;
use Getopt::Long;

sub usage {
    print STDERR <<USAGE;
Usage: $0 [-h|--help] [--sessions] [-v|--verbose] [--zebraqueue DAYS]
   -h --help         prints this help message, and exits, ignoring all other options
   --sessions        purge the sessions table.  If you use this while users are logged
                     into Koha, they will have to reconnect.
   -v --verbose      will cause the script to give you a bit more information about the run.
   --zebraqueue DAYS purge completed entries from the zebraqueue from more than DAYS days ago.
USAGE
    exit $_[0];
}

my ($help, $sessions, $verbose, $zebraqueue_days);

GetOptions(
    'h|help' => \$help,
    'sessions' => \$sessions,
    'v|verbose' => \$verbose,
    'zebraqueue:i' => \$zebraqueue_days,
) || usage(1);

if ($help) {
    usage(0);
}

if (!($sessions || $zebraqueue_days)){
    print "You did not specify any cleanup work for the script to do.\n\n";
    usage(1);
}

my $dbh = C4::Context->dbh();
my $query;
my $sth;
my $sth2;
my $count;

if ($sessions) {
    if ($verbose){
        print "Session purge triggered.\n";
        $sth = $dbh->prepare("SELECT COUNT(*) FROM sessions");
        $sth->execute() or die $dbh->errstr;
        my @count_arr = $sth->fetchrow_array;
        print "$count_arr[0] entries will be deleted.\n";
    }
    $sth = $dbh->prepare("TRUNCATE sessions");
    $sth->execute() or die $dbh->errstr;;
    if ($verbose){
        print "Done with session purge.\n";
    }
}

if ($zebraqueue_days){
    $count = 0;
    if ($verbose){
        print "Zebraqueue purge triggered for $zebraqueue_days days.\n";
    }
    $sth = $dbh->prepare("SELECT id,biblio_auth_number,server,time FROM zebraqueue
                          WHERE done=1 and time < date_sub(curdate(), interval ? day)");
    $sth->execute($zebraqueue_days) or die $dbh->errstr;
    $sth2 = $dbh->prepare("DELETE FROM zebraqueue WHERE id=?");
    while (my $record = $sth->fetchrow_hashref){
        $sth2->execute($record->{id}) or die $dbh->errstr;
        $count++;
    }
    if ($verbose){
        print "$count records were deleted.\nDone with zebraqueue purge.\n";
    }
}
exit(0);
