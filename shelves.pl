#!/usr/bin/perl
#script to provide bookshelf management
#
# $Header$
#


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
use C4::Search;
use CGI;
use C4::Output;
use C4::BookShelves;
use C4::Circulation::Circ2;
use C4::Auth;
use HTML::Template;

my $env;
my $query = new CGI;
my ($loggedinuser, $cookie, $sessionID) = checkauth($query);
#print $query->header(-cookie => $cookie);
my $headerbackgroundcolor='#663266';
my $circbackgroundcolor='#555555';
my $circbackgroundcolor='#550000';
my $linecolor1='#bbbbbb';
my $linecolor2='#dddddd';
my $template=gettemplate("shelves.tmpl");
#print startpage();
#print startmenu('catalogue');
#print "<p align=left>Logged in as: $loggedinuser [<a href=/cgi-bin/koha/logout.pl>Log Out</a>]</p>\n";


my ($shelflist) = GetShelfList();

if ($query->param('modifyshelfcontents')) {
    my $shelfnumber=$query->param('shelfnumber');
    my $barcode=$query->param('addbarcode');
    my ($item) = getiteminformation($env, 0, $barcode);
    AddToShelf($env, $item->{'itemnumber'}, $shelfnumber);
    foreach ($query->param) {
	if (/REM-(\d*)/) {
	    my $itemnumber=$1;
	    RemoveFromShelf($env, $itemnumber, $shelfnumber);
	}
    }
}

SWITCH: {
	$template->param(	loggedinuser => $loggedinuser,
									viewshelf => $query->param('viewshelf'),
									shelves => $query->param('shelves'),
									headerbackground => $headerbackground,
									circbackgroundcolor => $circbackgroundcolor);
    if ($query->param('viewshelf')) {  viewshelf($query->param('viewshelf')); last SWITCH;}
    if ($query->param('shelves')) {  shelves(); last SWITCH;}
	my $color='';
	my @shelvesloop;
    foreach $element (sort keys %$shelflist) {
		my %line;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$line{'color'}= $color;
		$line{'shelf'}=$element;
		$line{'shelfname'}=$shelflist->{$element}->{'shelfname'};
		$line{'shelfbookcount'}=$shelflist->{$element}->{'count'};
		push (@shelvesloop, \%line);
    }
	$template->param(shelvesloop => \@shelvesloop);
}

print $query->header(-cookie => $cookie), $template->output;


sub shelves {
    if (my $newshelf=$query->param('addshelf')) {
	my ($status, $string) = AddShelf($env,$newshelf);
	if ($status) {
	    $template->param(status1 => $status, string1 => $string);
	}
    }
	my @paramsloop;
    foreach ($query->param()) {
		my %line;
		if (/DEL-(\d+)/) {
			my $delshelf=$1;
			my ($status, $string) = RemoveShelf($env,$delshelf);
			if ($status) {
				$line{'status'}=$status;
				$line{'string'} = $string;
			}
		}
		#if the shelf is not deleted, %line points on null
		push(@paramsloop,\%line);
    }
	$template->param(paramsloop => \@paramsloop);
    my ($shelflist) = GetShelfList();
    my $color='';
	my @shelvesloop;
    foreach $element (sort keys %$shelflist) {
		my %line;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$line{'color'}=$color;
		$line{'shelf'}=$element;
		$line{'shelfname'}=$shelflist->{$element}->{'shelfname'} ;
		$line{'shelfbookcount'}=$shelflist->{$element}->{'count'} ;
		push(@shelvesloop, \%line);
    }
	$template->param(shelvesloop=>\@shelvesloop);
}



sub viewshelf {
    my $shelfnumber=shift;
    my ($itemlist) = GetShelfContents($env, $shelfnumber);
    my $item='';
    my $color='';
	my @itemsloop;
    foreach $item (sort {$a->{'barcode'} cmp $b->{'barcode'}} @$itemlist) {
		my %line;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$line{'color'}=$color;
		$line{'itemnumber'}=$item->{'itemnumber'};
		$line{'barcode'}=$item->{'barcode'};
		$line{'title'}=$item->{'title'};
		$line{'author'}=$item->{'author'};
		push(@itemsloop, \%line);
    }
	$template->param(	itemsloop => \@itemsloop);
	$template->param(	shelfname => $shelflist->{$shelfnumber}->{'shelfname'});
	$template->param(	shelfnumber => $shelfnumber);
}

#print endpage();
#print endmenu('catalogue');

#
# $Log$
# Revision 1.9  2002/12/19 18:55:40  hdl
# Templating reservereport et shelves.
#
# Revision 1.9  2002/08/14 18:12:51  hdl
# Templating files
#
# Revision 1.8  2002/08/14 18:12:51  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.7  2002/07/05 05:03:37  tonnesen
# Minor changes to authentication routines.
#
# Revision 1.5  2002/07/04 19:42:48  tonnesen
# Minor changes
#
# Revision 1.4  2002/07/04 19:21:29  tonnesen
# Beginning of authentication api.  Applied to shelves.pl for now as a test case.
#
# Revision 1.2.2.1  2002/06/26 20:28:15  tonnesen
# Some udpates that I made here locally a while ago.  Still won't be useful, but
# should be functional
#
#
#



