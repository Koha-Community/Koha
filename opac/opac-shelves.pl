#!/usr/bin/perl
#script to provide bookshelf management
# WARNING: This file uses 4-character tabs!
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
use C4::Interface::CGI::Output;
use HTML::Template;

my $env;
my $query = new CGI;
my $headerbackgroundcolor='#663266';
my $circbackgroundcolor='#555555';
my $circbackgroundcolor='#550000';
my $linecolor1='#bbbbbb';
my $linecolor2='#dddddd';
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "opac-shelves.tmpl",
							query => $query,
							type => "opac",
							authnotrequired => 1,
						});

if ($query->param('modifyshelfcontents')) {
	my $shelfnumber=$query->param('shelfnumber');
	my $barcode=$query->param('addbarcode');
	my ($item) = getiteminformation($env, 0, $barcode);
	if (ShelfPossibleAction($loggedinuser,$shelfnumber,'manage')) {
		AddToShelf($env, $item->{'itemnumber'}, $shelfnumber);
		foreach ($query->param) {
			if (/REM-(\d*)/) {
				my $itemnumber=$1;
				RemoveFromShelf($env, $itemnumber, $shelfnumber);
			}
		}
	}
}
my ($shelflist) = GetShelfList($loggedinuser,2);

$template->param({	loggedinuser => $loggedinuser,
					headerbackgroundcolor => $headerbackgroundcolor,
					circbackgroundcolor => $circbackgroundcolor });
SWITCH: {
	if ($query->param('op') eq 'modifsave') {
		ModifShelf($query->param('shelfnumber'),$query->param('shelfname'),$loggedinuser,$query->param('category'));
		last SWITCH;
	}
	if ($query->param('op') eq 'modif') {
		my ($shelfnumber,$shelfname,$owner,$category) = GetShelf($query->param('shelf'));
		$template->param(edit => 1,
						shelfnumber => $shelfnumber,
						shelfname => $shelfname,
						"category$category" => 1);
# 		editshelf($query->param('shelf'));
		last SWITCH;
	}
	if ($query->param('viewshelf')) {
		viewshelf($query->param('viewshelf'));
		last SWITCH;
	}
	if ($query->param('shelves')) {
		shelves();
		last SWITCH;
	}
}

($shelflist) = GetShelfList($loggedinuser,2); # rebuild shelflist in case a shelf has been added

my $color='';
my @shelvesloop;
foreach my $element (sort keys %$shelflist) {
		my %line;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$line{'color'}= $color;
		$line{'shelf'}=$element;
		$line{'shelfname'}=$shelflist->{$element}->{'shelfname'};
		$line{"category".$shelflist->{$element}->{'category'}} = 1;
		$line{'mine'} = 1 if $shelflist->{$element}->{'owner'} eq $loggedinuser;
		$line{'shelfbookcount'}=$shelflist->{$element}->{'count'};
		$line{'canmanage'} = ShelfPossibleAction($loggedinuser,$element,'manage');
		$line{'firstname'}=$shelflist->{$element}->{'firstname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
		$line{'surname'}=$shelflist->{$element}->{'surname'} unless $shelflist->{$element}->{'owner'} eq $loggedinuser;
;
		push (@shelvesloop, \%line);
}
$template->param(shelvesloop => \@shelvesloop);

output_html_with_http_headers $query, $cookie, $template->output;

# sub editshelf {
# 	my ($shelfnumber) = @_;
# 	my ($shelfnumber,$shelfname,$owner,$category) = GetShelf($shelfnumber);
# 	$template->param(edit => 1,
# 					shelfnumber => $shelfnumber,
# 					shelfname => $shelfname,
# 					"category$category" => 1);
# }
sub shelves {
	if (my $newshelf=$query->param('addshelf')) {
		my ($status, $string) = AddShelf($env,$newshelf,$query->param('owner'),$query->param('category'));
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
	my ($shelflist) = GetShelfList($loggedinuser,2);
	my $color='';
	my @shelvesloop;
	foreach my $element (sort keys %$shelflist) {
		my %line;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$line{'color'}=$color;
		$line{'shelf'}=$element;
		$line{'shelfname'}=$shelflist->{$element}->{'shelfname'} ;
		$line{'shelfbookcount'}=$shelflist->{$element}->{'count'} ;
		push(@shelvesloop, \%line);
	}
	$template->param(shelvesloop=>\@shelvesloop,
							shelves => 1,
						);
}

sub viewshelf {
	my $shelfnumber=shift;
	#check that the user can view the shelf
	return unless (ShelfPossibleAction($loggedinuser,$shelfnumber,'view'));
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
		$line{'classification'}=$item->{'classification'};		
		$line{'itemtype'}=$item->{'itemtype'};		
		$line{biblionumber} = $item->{biblionumber};
		push(@itemsloop, \%line);
	}
	$template->param(	itemsloop => \@itemsloop,
						shelfname => $shelflist->{$shelfnumber}->{'shelfname'},
						shelfnumber => $shelfnumber,
						viewshelf => $query->param('viewshelf'),
						manageshelf => &ShelfPossibleAction($loggedinuser,$shelfnumber,'manage'),
					);
}

#
# $Log$
# Revision 1.3.2.2  2005/01/11 20:18:29  oleonard
# Adding call number and item type to list of returned variables
#
# Revision 1.3.2.1  2005/01/11 16:33:57  tipaul
# fix for http://bugs.koha.org/cgi-bin/bugzilla/show_bug.cgi?id=811 :
# The OPAC requires uses to log in to view virtual shelves, and it requires a user
# with librarian privileges.  Virtual shelves should be viewable by all users,
# logged in or not, and editable by all logged-in users in good standing.
#
# Revision 1.3  2005/01/03 11:09:34  tipaul
# synch'ing virtual shelves management in opac with the librarian one, that has more features
#
# Revision 1.5  2004/12/16 11:30:57  tipaul
# adding bookshelf features :
# * create bookshelf on the fly
# * modify a bookshelf name & status
#
# Revision 1.4  2004/12/15 17:28:23  tipaul
# adding bookshelf features :
# * create bookshelf on the fly
# * modify a bookshelf (this being not finished, will commit the rest soon)
#
# Revision 1.3  2004/12/02 16:38:50  tipaul
# improvement in book shelves
#
# Revision 1.2  2004/11/19 16:31:30  tipaul
# bugfix for bookshelves not in official CVS
#
# Revision 1.1.2.1  2004/03/10 15:08:18  tipaul
# modifying shelves : introducing category of shelf : private, public, free for all
#
# Revision 1.13  2004/02/11 08:35:31  tipaul
# synch'ing 2.0.0 branch and head
#
# Revision 1.12.2.1  2004/02/06 14:22:19  tipaul
# fixing bugs in bookshelves management.
#
# Revision 1.12  2003/02/05 10:04:14  acli
# Worked around weirdness with HTML::Template; without the {}, it complains
# of being passed an odd number of arguments even though we are not
#
# Revision 1.11  2003/02/05 09:23:03  acli
# Fixed a few minor errors to make it run
# Noted correct tab size
#
# Revision 1.10  2003/02/02 07:18:37  acli
# Moved C4/Charset.pm to C4/Interface/CGI/Output.pm
#
# Create output_html_with_http_headers function to contain the "print $query
# ->header(-type => guesstype...),..." call. This is in preparation for
# non-HTML output (e.g., text/xml) and charset conversion before output in
# the future.
#
# Created C4/Interface/CGI/Template.pm to hold convenience functions specific
# to the CGI interface using HTML::Template
#
# Modified moremembers.pl to make the "sex" field localizable for languages
# where M and F doesn't make sense
#
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




# Local Variables:
# tab-width: 4
# End:
