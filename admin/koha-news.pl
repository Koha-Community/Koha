#!/usr/bin/perl

# Script to manage the opac news.
# written 11/04
# Castañeda, Carlos Sebastian - seba3c@yahoo.com.ar - Physics Library UNLP Argentina

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

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::NewsChannels;


my $cgi = new CGI;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/koha-news.tmpl",
			     query => $cgi,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {management => 1},
			     debug => 1,
			     });

my $op = $cgi->param('op');

if ($op eq 'add_form') {
	$template->param(add_form => 1);
	my $id = $cgi->param("id");
	my $new;
	
	if ($id) {
		$template->param(op => 'edit');
		$new = get_opac_new($id);
		$template->param($new);
		$template->param(id => $new->{'idnew'});
	} else {
		$template->param(op => 'add');
	}
	
} elsif ($op eq 'add') {

	my $title	= $cgi->param('title');
	my $new		= $cgi->param('new');
	my $lang	= $cgi->param('lang');

	add_opac_new($title, $new, $lang);
	print $cgi->redirect('/cgi-bin/koha/admin/koha-news.pl');

} elsif ($op eq 'edit') {

	my $id		= $cgi->param('id');
	my $title	= $cgi->param('title');
	my $new		= $cgi->param('new');
	my $lang	= $cgi->param('lang');

	upd_opac_new($id, $title, $new, $lang);
	print $cgi->redirect('/cgi-bin/koha/admin/koha-news.pl');

} elsif ($op eq 'del') {
	my @ids = $cgi->param('ids');
	del_opac_new(join ",", @ids);
	print $cgi->redirect('/cgi-bin/koha/admin/koha-news.pl');

} else { 

	my $lang = $cgi->param('lang');
	my ($opac_news_count, $opac_news) = &get_opac_news(undef, $lang);
	$template->param($lang => 1);
	$template->param(opac_news => $opac_news);
	$template->param(opac_news_count => $opac_news_count);

}

output_html_with_http_headers $cgi, $cookie, $template->output;
