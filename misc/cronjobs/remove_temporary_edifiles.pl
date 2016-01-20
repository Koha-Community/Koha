#!/usr/bin/perl
use strict;
use warnings;

use C4::Context;

# this script will remove those older than 5 days
my $tmpdir = '/tmp';
#
opendir( my $dh, $tmpdir) || die "Cannot open $tmpdir : $!";

my @files_in_tmp = grep { /\.CE[IQ]$/ && -f "$tmpdir/$_" } readdir($dh);
closedir $dh;


my $dbh = C4::Context->dbh;

my $query =<<'ENDSQL';
select filename from edifact_messages
where message_type IN ('QUOTE','INVOICE')
and datediff( CURDATE(), transfer_date ) > 5
ENDSQL

my $ingested;

@{$ingested} = $dbh->selectcol_arrayref($query);

my %ingested_hash = map { $_ => 1 } @{$ingested};

my @delete_list;

foreach (@files_in_tmp) {
    if ( exists $ingested_hash{$_} ) {
        push @delete_list, $_;
    }
}

if ( @delete_list ) {
    chdir $tmpdir;
    unlink @delete_list;
}
