#!/usr/bin/perl


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

use DBI;
use C4::Context;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Circulation::Main;
use C4::Format;
use C4::Scan;
use C4::Stats;
use C4::Search;
use C4::Print;
use C4::Circulation::Returns;


my %env = (
branchcode => $ARGV[0], usercode => $ARGV[1], proccode => "lgon", borrowernumber => "",
logintime  => "", lasttime => "", tempuser => "", debug => "9",
telnet => $ARGV[2], queue => $ARGV[3], printtype => $ARGV[4], brdata => $ARGV[5]
);
my $env=\%env;


my $dbh = C4::Context->dbh;
my @items;
@items[0]=" "x50;
my $reason;
my $item;
my $reason;
my $borrower;
my $itemno;
my $itemrec;
my $bornum;
my $amt_owing;
my $odues;
my $issues;
my $resp;
startint();
until ($reason ne "") {
  ($reason,$item) = returnwindow($env,"Enter Returns",$item,\@items,$borrower,$amt_owing,$odues,$dbh,$resp); #C4::Circulation
  if ($reason eq "")  {
    $resp = "";
    ($resp,$bornum,$borrower,$itemno,$itemrec,$amt_owing) = C4::Circulation::Returns::checkissue($env,$dbh,$item);
    if ($bornum ne "") {
      ($issues,$odues,$amt_owing) = borrdata2($env,$bornum);
    } else {
      $issues = "";
      $odues = "";
      $amt_owing = "";
    }
    if ($resp ne "") {
      if ($itemno ne "" ) {
        my $item = itemnodata($env,$dbh,$itemno);
	my $fmtitem = C4::Circulation::Issues::formatitem($env,$item,"",$amt_owing);
	unshift @items,$fmtitem;
	if ($items[20] > "") {
	  pop @items;
	}
      }
    }
  }
}
die;


