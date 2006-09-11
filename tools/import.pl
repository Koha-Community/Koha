#!/usr/bin/perl

# $Id$

# Script for handling import of MARC data into Koha db
#   and Z39.50 lookups

# Koha library project  www.koha.org

# Licensed under the GPL


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

# standard or CPAN modules used
use CGI;

# Koha modules used
use C4::Context;
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Breeding;

#------------------
# Constants



# HTML colors for alternating lines
my $lc1='#dddddd';
my $lc2='#ddaaaa';

#-------------
#-------------
# Initialize

my $userid=$ENV{'REMOTE_USER'};

my $input = new CGI;
my $dbh = C4::Context->dbh;

my $uploadmarc=$input->param('uploadmarc');
my $overwrite_biblio = $input->param('overwrite_biblio');
my $filename = $input->param('filename');
my $syntax = $input->param('syntax');
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "tools/breeding.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {parameters => 1, management => 1, tools => 1},
					debug => 1,
					});

$template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'},
						uploadmarc => $uploadmarc);
if ($uploadmarc && length($uploadmarc)>0) {
	my $marcrecord='';
	while (<$uploadmarc>) {
		$marcrecord.=$_;
	}
	my ($notmarcrecord,$alreadyindb,$alreadyinfarm,$imported) = ImportBreeding($marcrecord,$overwrite_biblio,$filename,$syntax,"");

	$template->param(imported => $imported,
							alreadyindb => $alreadyindb,
							alreadyinfarm => $alreadyinfarm,
							notmarcrecord => $notmarcrecord,
							total => $imported+$alreadyindb+$alreadyinfarm+$notmarcrecord,
							);

}

output_html_with_http_headers $input, $cookie, $template->output;
my $menu;
my $file;


#---------------
# log cleared, as marcimport is (almost) rewritten from scratch.
# $Log$
# Revision 1.2  2006/09/11 17:41:56  tgarip1957
# New XML API
#
# Revision 1.2.4.1  2005/04/07 10:10:52  tipaul
# copying processz3950queue from 2.0 branch. The 2.2 version misses an important fix
#
