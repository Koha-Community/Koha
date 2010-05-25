#!/usr/bin/perl

# Copyright 2011 BibLibre
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
# 51 Franklin Street, Suite 500, Boston, MA 02110-1335, USA


# Re-create statistics from issues and old_issues tables

use strict;
use warnings;
use C4::Context;
use C4::Items;
use Data::Dumper;
use Getopt::Long;

my $dbh = C4::Context->dbh;

# Options
my $issues = 0;
my $returns = 0;
my $help = 0;

GetOptions ('issues' => \$issues, 'returns' => \$returns, 'help|?|h' => \$help);

# Show usage
if ($help == 1) {
        print ("Usage : perl $0 [--issues] [--returns]\n\n");
        print (" issues: process only issues\n");
        print (" returns: process only returns\n");
        exit 0;
}

if ($issues == 0 && $returns == 0) {
    $issues = 1;
    $returns = 1;
}

# Counters
my $count_issues = 0;
my $count_renewals = 0;
my $count_returns = 0;

# Issues and renewals can be found in both issues and old_issues tables
if ($issues == 1) {
    foreach my $table ('issues', 'old_issues') {
	# Getting issues
	print "looking for missing issues from $table\n";
	my $query = "SELECT borrowernumber, branchcode, itemnumber, issuedate, renewals, lastreneweddate from $table where itemnumber is not null";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	# Looking for missing issues
	while (my $hashref = $sth->fetchrow_hashref) {
	    my $ctnquery = "SELECT count(*) as cnt FROM statistics WHERE borrowernumber = ? AND itemnumber = ? AND DATE(datetime) = ? AND type = 'issue'";
	    my $substh = $dbh->prepare($ctnquery);
	    $substh->execute($hashref->{'borrowernumber'}, $hashref->{'itemnumber'}, $hashref->{'issuedate'});
	    my $count = $substh->fetchrow_hashref->{'cnt'};
	    if ($count == 0) {
		# Inserting missing issue
		    my $insert = "INSERT INTO statistics (datetime, branch, value, type, other, itemnumber, itemtype, borrowernumber)
					 VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
		    $substh = $dbh->prepare($insert);
		    my $item = GetItem($hashref->{'itemnumber'});

		    $substh->execute(
			$hashref->{'issuedate'},
			$hashref->{'branchcode'},
			0,
			'issue',
			'',
			$hashref->{'itemnumber'},
			$item->{'itype'},
			$hashref->{'borrowernumber'}
		    );
		    print "date: $hashref->{'issuedate'} branchcode: $hashref->{'branchcode'} type: issue itemnumber: $hashref->{'itemnumber'} itype: $item->{'itype'} borrowernumber: $hashref->{'borrowernumber'}\n";
		    $count_issues++;
		}

		# Looking for missing renewals
		if ($hashref->{'renewals'} && $hashref->{'renewals'} > 0 ) {
		    # This is the not-so accurate part :
		    # We assume that there are missing renewals, based on the last renewal date
		    # Maybe should this be deactivated by default ?
		    my $ctnquery = "SELECT count(*) as cnt FROM statistics WHERE borrowernumber = ? AND itemnumber = ? AND DATE(datetime) = ? AND type = 'renew'";
		    my $substh = $dbh->prepare($ctnquery);
		    $substh->execute($hashref->{'borrowernumber'}, $hashref->{'itemnumber'}, $hashref->{'lastreneweddate'});

		    my $missingrenewalscount = $hashref->{'renewals'} - $substh->fetchrow_hashref->{'cnt'};
		    print "We assume $missingrenewalscount renewals are missing. Creating them\n" if ($missingrenewalscount > 0);
		    for (my $i = 0; $i < $missingrenewalscount; $i++) {

			# Inserting missing renewals
			my $insert = "INSERT INTO statistics (datetime, branch, value, type, other, itemnumber, itemtype, borrowernumber)
					 VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
			$substh = $dbh->prepare($insert);
			my $item = GetItem($hashref->{'itemnumber'});

			$substh->execute(
			    $hashref->{'lastreneweddate'},
			    $hashref->{'branchcode'},
			    0,
			    'renew',
			    '',
			    $hashref->{'itemnumber'},
			    $item->{'itype'},
			    $hashref->{'borrowernumber'}
			    );
			print "date: $hashref->{'lastreneweddate'} branchcode: $hashref->{'branchcode'} type: renew itemnumber: $hashref->{'itemnumber'} itype: $item->{'itype'} borrowernumber: $hashref->{'borrowernumber'}\n";
			$count_renewals++;

		    }

		}
	}
    }
}

# Getting returns
if ($returns == 1) {
    print "looking for missing returns from old_issues\n";
    my $query = "SELECT * from old_issues where itemnumber is not null";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    # Looking for missing returns
    while (my $hashref = $sth->fetchrow_hashref) {
	my $ctnquery = "SELECT count(*) as cnt FROM statistics WHERE borrowernumber = ? AND itemnumber = ? AND DATE(datetime) = ? AND type = 'return'";
	my $substh = $dbh->prepare($ctnquery);
	$substh->execute($hashref->{'borrowernumber'}, $hashref->{'itemnumber'}, $hashref->{'returndate'});
	my $count = $substh->fetchrow_hashref->{'cnt'};
	if ($count == 0) {
	    # Inserting missing issue
		my $insert = "INSERT INTO statistics (datetime, branch, value, type, other, itemnumber, itemtype, borrowernumber)
				     VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
		$substh = $dbh->prepare($insert);
		my $item = GetItem($hashref->{'itemnumber'});

		$substh->execute(
		    $hashref->{'returndate'},
		    $hashref->{'branchcode'},
		    0,
		    'return',
		    '',
		    $hashref->{'itemnumber'},
		    $item->{'itype'},
		    $hashref->{'borrowernumber'}
		);
		print "date: $hashref->{'returndate'} branchcode: $hashref->{'branchcode'} type: return itemnumber: $hashref->{'itemnumber'} itype: $item->{'itype'} borrowernumber: $hashref->{'borrowernumber'}\n";
		$count_returns++;
	    }

    }
}

print "Missing issues added:   $count_issues\n" if $issues;
print "Missing renewals added: $count_renewals\n" if $issues;
print "Missing returns added:  $count_returns\n" if $returns;
