#!/usr/bin/perl

use strict;
use warnings;

use C4::Context;
use C4::Members;

my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare("SELECT * FROM overduerules_transport_types WHERE 0 = 1");
my $urv = $sth->execute();

my @data;

if ( $sth->{NUM_OF_FIELDS} > 0 )
{
    @data = @{$sth->{NAME}};

    my @letternumber = grep { $_ eq 'letternumber' } @data;

    if ( ! @letternumber )
    {
        my $urv = $dbh->do("ALTER TABLE overduerules_transport_types ADD COLUMN letternumber INT(1) NOT NULL DEFAULT 1 AFTER id");
        print "Bug 16007: adding column 'letternumber' back into table 'overduerules_transport_types'\n";
    }
    else
    {
        print "Bug 16007: your table 'overduerules_transport_types' already has a column 'letternumber'; nothing to do\n";
    }
}
else
{
    # table overduerules_transport_types should exist by now, but let's
    # warn the user here just in case
    print "Bug 16007: [ERROR] your table 'overduerules_transport_types' does not exists ?!\n";
}
