package C4::Groups;

# $Id$

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

# FIXME - This package is only used in groups.pl, which in turn is
# never used. Presumably this module is therefore obsolete.

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Circulation::Circ2;
#use C4::Accounts;
#use C4::InterfaceCDK;
#use C4::Circulation::Main;
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
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select distinct groupshortname,grouplongname from borrowergroups");
    $sth->execute;
    while (my ($short, $long)=$sth->fetchrow) {
	$groups{$short}=$long;
    }
    return (\%groups);
}

sub groupmembers {
    my ($env, $group) = @_;
    my @members;
    my $dbh = C4::Context->dbh;
    my $q_group=$dbh->quote($group);
    my $sth=$dbh->prepare("select borrowernumber from borrowergroups where groupshortname=?");
    $sth->execute($q_group);
    while (my ($borrowernumber) = $sth->fetchrow) {
	my ($patron, $flags) = getpatroninformation($env, $borrowernumber);
	my $currentissues=currentissues($env, $patron);
	$patron->{'currentissues'}=$currentissues;
	push (@members, $patron);
    }
    return (\@members);
}


END { }       # module clean-up code here (global destructor)
