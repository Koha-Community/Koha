#!/usr/bin/perl

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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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
Usage: $0 [-h|--help] [--sessions] [--sessdays DAYS] [-v|--verbose] [--zebraqueue DAYS] [-m|--mail] [--merged]

   -h --help          prints this help message, and exits, ignoring all
                      other options
   --sessions         purge the sessions table.  If you use this while users 
                      are logged into Koha, they will have to reconnect.
   --sessdays DAYS    purge only sessions older than DAYS days (use together with sessions parameter).
   -v --verbose       will cause the script to give you a bit more information
                      about the run.
   --zebraqueue DAYS  purge completed entries from the zebraqueue from 
                      more than DAYS days ago.
   -m --mail          purge the mail queue. 
   --merged           purged completed entries from need_merge_authorities.
USAGE
    exit $_[0];
}

my ( $help, $sessions, $sess_days, $verbose, $zebraqueue_days, $mail, $purge_merged);

GetOptions(
    'h|help'       => \$help,
    'sessions'     => \$sessions,
    'sessdays:i'   => \$sess_days,
    'v|verbose'    => \$verbose,
    'm|mail'       => \$mail,
    'zebraqueue:i' => \$zebraqueue_days,
    'merged'       => \$purge_merged,
) || usage(1);

if ($help) {
    usage(0);
}

if ( !( $sessions || $zebraqueue_days || $mail || $purge_merged) ) {
    print "You did not specify any cleanup work for the script to do.\n\n";
    usage(1);
}

my $dbh = C4::Context->dbh();
my $query;
my $sth;
my $sth2;
my $count;

if ( $sessions && !$sess_days ) {
    if ($verbose) {
        print "Session purge triggered.\n";
        $sth = $dbh->prepare("SELECT COUNT(*) FROM sessions");
        $sth->execute() or die $dbh->errstr;
        my @count_arr = $sth->fetchrow_array;
        print "$count_arr[0] entries will be deleted.\n";
    }
    $sth = $dbh->prepare("TRUNCATE sessions");
    $sth->execute() or die $dbh->errstr;
    if ($verbose) {
        print "Done with session purge.\n";
    }
} elsif ( $sessions && $sess_days > 0 ) {
    if ($verbose) {
        print "Session purge triggered with days>$sess_days.\n";
    }
    RemoveOldSessions();
    if ($verbose) {
        print "Done with session purge with days>$sess_days.\n";
    }
}

if ($zebraqueue_days) {
    $count = 0;
    if ($verbose) {
        print "Zebraqueue purge triggered for $zebraqueue_days days.\n";
    }
    $sth = $dbh->prepare(
        "SELECT id,biblio_auth_number,server,time FROM zebraqueue
                          WHERE done=1 and time < date_sub(curdate(), interval ? day)"
    );
    $sth->execute($zebraqueue_days) or die $dbh->errstr;
    $sth2 = $dbh->prepare("DELETE FROM zebraqueue WHERE id=?");
    while ( my $record = $sth->fetchrow_hashref ) {
        $sth2->execute( $record->{id} ) or die $dbh->errstr;
        $count++;
    }
    if ($verbose) {
        print "$count records were deleted.\nDone with zebraqueue purge.\n";
    }
}

if ($mail) {
    if ($verbose) {
        $sth = $dbh->prepare("SELECT COUNT(*) FROM message_queue");
        $sth->execute() or die $dbh->errstr;
        my @count_arr = $sth->fetchrow_array;
        print "Deleting $count_arr[0] entries from the mail queue.\n";
    }
    $sth = $dbh->prepare("TRUNCATE message_queue");
    $sth->execute() or $dbh->errstr;
    print "Done with purging the mail queue.\n" if ($verbose);
}

if($purge_merged) {
    print "Purging completed entries from need_merge_authorities.\n" if $verbose;
    $sth = $dbh->prepare("DELETE FROM need_merge_authorities WHERE done=1");
    $sth->execute() or die $dbh->errstr;
    print "Done with purging need_merge_authorities.\n" if $verbose;
}

exit(0);

sub RemoveOldSessions {
    my ( $id, $a_session, $limit, $lasttime );
    $limit = time() - 24 * 3600 * $sess_days;

    $sth = $dbh->prepare("SELECT id, a_session FROM sessions");
    $sth->execute or die $dbh->errstr;
    $sth->bind_columns( \$id, \$a_session );
    $sth2  = $dbh->prepare("DELETE FROM sessions WHERE id=?");
    $count = 0;

    while ( $sth->fetch ) {
        $lasttime = 0;
        if ( $a_session =~ /lasttime:\s+(\d+)/ ) {
            $lasttime = $1;
        } elsif ( $a_session =~ /(ATIME|CTIME):\s+(\d+)/ ) {
            $lasttime = $2;
        }
        if ( $lasttime && $lasttime < $limit ) {
            $sth2->execute($id) or die $dbh->errstr;
            $count++;
        }
    }
    if ($verbose) {
        print "$count sessions were deleted.\n";
    }
}
