#!/usr/bin/perl

# $Id$

#script to update charges for overdue in database
#updates categoryitem
# is called by charges.pl
# written 1/1/2000 by chris@katipo.co.nz


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
use CGI;
use C4::Context;
use C4::Output;

my $input = new CGI;

my $dbh = C4::Context->dbh;
my @names=$input->param();

foreach my $key (@names){
	$key =~ /(.*)\.(.*)/;
	my $bor=$1;
	my $cat=$2;
	my $data=$input->param($key);
	my @dat=split(',',$data);
	my $sth_search = $dbh->prepare("select count(*) as total from categoryitem where categorycode=? and itemtype=?");
	my $sth_insert = $dbh->prepare("insert into categoryitem (categorycode,itemtype,fine,firstremind,chargeperiod) values (?,?,?,?,?)");
	my $sth_update=$dbh->prepare("Update categoryitem set fine=?,firstremind=?,chargeperiod=? where categorycode=? and itemtype=?");
	$sth_search->execute($bor,$cat);
	my $res = $sth_search->fetchrow_hashref();
	if ($res->{total}) {
		$sth_update->execute($dat[0],$dat[1],$dat[2],$bor,$cat);
	} else {
		$sth_insert->execute($bor,$cat,$dat[0],$dat[1],$dat[2]);
	}
}
print $input->redirect("/cgi-bin/koha/admin/charges.pl");
