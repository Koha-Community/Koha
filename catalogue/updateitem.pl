#!/usr/bin/perl

# $Id: updateitem.pl,v 1.9.2.1.2.4 2006/10/05 18:36:50 kados Exp $
# Copyright 2006 LibLime
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
use CGI;
use C4::Auth;
use C4::Context;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Circulation;
use C4::Accounts;
use C4::Reserves;

my $cgi= new CGI;

my ($loggedinuser, $cookie, $sessionID) = checkauth($cgi, 0, {circulate => 1}, 'intranet');

my $biblionumber=$cgi->param('biblionumber');
my $itemnumber=$cgi->param('itemnumber');
my $biblioitemnumber=$cgi->param('biblioitemnumber');
my $itemlost=$cgi->param('itemlost');
my $itemnotes=$cgi->param('itemnotes');
my $wthdrawn=$cgi->param('wthdrawn');
my $damaged=$cgi->param('damaged');

my $confirm=$cgi->param('confirm');
my $dbh = C4::Context->dbh;

# get the rest of this item's information
my $item_data_hashref = GetItem($itemnumber, undef);

# make sure item statuses are set to 0 if empty or NULL
for ($damaged,$itemlost,$wthdrawn) {
    if (!$_ or $_ eq "") {
        $_ = 0;
    }
}

# modify MARC item if input differs from items table.
my $item_changes = {};
if (defined $itemnotes) { # i.e., itemnotes parameter passed from form
    if ((not defined  $item_data_hashref->{'itemnotes'}) or $itemnotes ne $item_data_hashref->{'itemnotes'}) {
        $item_changes->{'itemnotes'} = $itemnotes;
    }
} elsif ($itemlost ne $item_data_hashref->{'itemlost'}) {
    $item_changes->{'itemlost'} = $itemlost;
} elsif ($wthdrawn ne $item_data_hashref->{'wthdrawn'}) {
    $item_changes->{'wthdrawn'} = $wthdrawn;
} elsif ($damaged ne $item_data_hashref->{'damaged'}) {
    $item_changes->{'damaged'} = $damaged;
} else {
    #nothings changed, so do nothing.
    print $cgi->redirect("moredetail.pl?biblionumber=$biblionumber&itemnumber=$itemnumber#item$itemnumber");
	exit;
}

ModItem($item_changes, $biblionumber, $itemnumber);

C4::Accounts::chargelostitem($itemnumber) if ($itemlost==1) ;

print $cgi->redirect("moredetail.pl?biblionumber=$biblionumber&itemnumber=$itemnumber#item$itemnumber");
