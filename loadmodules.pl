#!/usr/bin/perl

#script to show list of budgets and bookfunds
#written 4/2/00 by chris@katipo.co.nz
#called as an include by the acquisitions index page


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

use C4::Context;
use CGI;
my $input=new CGI;

my $module=$input->param('module');

SWITCH: {
	if ($module eq 'acquisitions') { acquisitions(); last SWITCH; }
	if ($module eq 'search') { catalogue_search(); last SWITCH; }
	if ($module eq 'addbiblio') {addbiblio(); last SWITCH;}
	if ($module eq 'somethingelse') { somethingelse(); last SWITCH; }
}

sub acquisitions {
	my $aq_type = $input->param('acquisitions');
	$aq_type = C4::Context->preference("acquisitions") || "normal" unless $aq_type;
	my $marc_bool =$input->param('MARC');
	$marc_bool = C4::Context->boolean_preference('marc') || 0 unless $marc_bool;
	# Get the acquisition preference. This should be:
	#       "simple" - minimal information required
	#       "normal" - full information required
	#       other - Same as "normal"

	if ($aq_type eq 'simple') {
			print $input->redirect("/cgi-bin/koha/acqui.simple/addbooks.pl");
	} else {
		print $input ->redirect("/cgi-bin/koha/acqui/acqui-home.pl");
	}
}

sub addbiblio {
	my $marc_bool = C4::Context->boolean_preference("MARC") || 0;
		if ($marc_bool eq "1") {
			print $input->redirect("/cgi-bin/koha/acqui.simple/addbooks.pl");
		} else {
			print $input->redirect("/cgi-bin/koha/acqui.simple/addbiblio-nomarc.pl");
		}
}

sub catalogue_search {
	my $marc_p = $input->param('marc');
	$marc_p = C4::Context->boolean_preference('marc') unless defined $marc_p;
	$marc_p = 'ON' unless defined $marc_p;
	my $keyword=$input->param('keyword');
	my $query = new CGI;
	my $type = $query->param('type');
	if ($keyword) {
		if ($marc_p) {
			print $input->redirect("/cgi-bin/koha/search.marc/search.pl?type=$type");
		} else {
			print $input ->redirect("/cgi-bin/koha/search.pl?keyword=$keyword");
		}
	} else {
		if ($marc_p) {
			print $input->redirect("/cgi-bin/koha/search.marc/search.pl?type=$type");
		} else {
			print $input ->redirect("/cgi-bin/koha/catalogue-home.pl");
		}
	}
}

sub somethingelse {
# just an example subroutine
}
