package C4::Groups;

#package to deal with Returns
#written 3/11/99 by olwen@katipo.co.nz


# Copyright 2000-2002 Katipo Communications
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
require Exporter;
use DBI;
use C4::Database;
use C4::Circulation::Circ2;
#use C4::Accounts;
#use C4::InterfaceCDK;
#use C4::Circulation::Main;
#use C4::Format;
#use C4::Circulation::Renewals;
#use C4::Scan;
use C4::Stats;
#use C4::Search;
#use C4::Print;

use vars qw($VERSION @ISA @EXPORT);
  
# set the version for version checking
$VERSION = 0.01;
    
@ISA = qw(Exporter);
@EXPORT = qw(&getgroups &groupmembers);

sub getgroups {
    my ($env) = @_;
    my %groups;
    my $dbh=&C4Connect;  
    my $sth=$dbh->prepare("select distinct groupshortname,grouplongname from borrowergroups");
    $sth->execute;
    while (my ($short, $long)=$sth->fetchrow) {
	$groups{$short}=$long;
    }
    $dbh->disconnect;
    return (\%groups);
}

sub groupmembers {
    my ($env, $group) = @_;
    my @members;
    my $dbh=&C4Connect;
    my $q_group=$dbh->quote($group);
    my $sth=$dbh->prepare("select borrowernumber from borrowergroups where groupshortname=$q_group");
    $sth->execute;
    while (my ($borrowernumber) = $sth->fetchrow) {
	my ($patron, $flags) = getpatroninformation($env, $borrowernumber);
	my $currentissues=currentissues($env, $patron);
	$patron->{'currentissues'}=$currentissues;
	push (@members, $patron);
    }
    return (\@members);
}


END { }       # module clean-up code here (global destructor)
