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
use DBI;

# Koha modules used
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Input;
use C4::Biblio;
use MARC::File::USMARC;
use HTML::Template;
use C4::Output;
use C4::Auth;
use C4::Breeding;

#------------------
# Constants

my $includes = C4::Context->config('includes') ||
	"/usr/local/www/hdl/htdocs/includes";

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
my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "acqui.simple/marcimport.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {parameters => 1},
					debug => 1,
					});

$template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'},
						uploadmarc => $uploadmarc);
if ($uploadmarc && length($uploadmarc)>0) {
	my $marcrecord='';
	while (<$uploadmarc>) {
		$marcrecord.=$_;
	}
	my ($notmarcrecord,$alreadyindb,$alreadyinfarm,$imported) = ImportBreeding($marcrecord,$overwrite_biblio,$filename);

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
# Revision 1.32  2003/04/22 12:22:54  tipaul
# 1st draft for z3950 client import.
# moving Breeding farm script to a perl package C4/Breeding.pm
#
# Revision 1.31  2003/02/19 01:01:07  wolfpac444
# Removed the unecessary $dbh argument from being passed.
# Resolved a few minor FIXMEs.
#
# Revision 1.30  2003/02/02 07:18:38  acli
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
# Revision 1.29  2003/01/28 15:28:31  tipaul
# removing use MARC::Charset
# Was a buggy test
#
# Revision 1.28  2003/01/28 15:00:31  tipaul
# user can now search in breeding farm with isbn/issn or title. Title/name are stored in breeding farm and showed when a search is done
#
# Revision 1.27  2003/01/26 23:21:49  acli
# Handle non-latin1 charsets
#
# Revision 1.26  2003/01/23 12:26:41  tipaul
# upgrading import in breeding farm (you can now search on ISBN or on title) AND character encoding.
#
# Revision 1.25  2003/01/21 08:13:50  tipaul
# character encoding ISO646 => 8859-1, first draft
#
# Revision 1.24  2003/01/14 16:41:17  tipaul
# bugfix : use gettemplate_and_user instead of gettemplate.
# fix a blank screen in 1.3.3 in "import in breeding farm"
#
# Revision 1.23  2003/01/06 13:06:28  tipaul
# removing trailing #
#
# Revision 1.22  2002/11/12 15:58:43  tipaul
# road to 1.3.2 :
# * many bugfixes
# * adding value_builder : you can map a subfield in the marc_subfield_structure to a sub stored in "value_builder" directory. In this directory you can create screen used to build values with any method. In this commit is a 1st draft of the builder for 100$a unimarc french subfield, which is composed of 35 digits, with 12 differents values (only the 4th first are provided for instance)
#
# Revision 1.21  2002/10/22 15:50:23  tipaul
# road to 1.3.2 : adding a biblio in MARC format.
# seems to work a few.
# still to do :
# * manage html checks (mandatory subfields...)
# * add list of acceptable values (authorities)
# * manage ## in MARC format
# * manage correctly repeatable fields
# and probably a LOT of bugfixes
#
# Revision 1.20  2002/10/16 12:46:19  arensb
# Added a FIXME comment.
#
# Revision 1.19  2002/10/15 10:14:44  tipaul
# road to 1.3.2. Full rewrite of marcimport.pl.
# The acquisition system in MARC version will work like this :
# * marcimport will put marc records into a "breeding farm" table.
# * when the user want to add a biblio, he enters first the ISBN/ISSN of the biblio. koha searches into breeding farm and if the record exists, it is shown to the user to help him adding the biblio. When the biblio is added, it's deleted from the breeding farm.
#
# This commit :
# * modify acqui.simple home page  (addbooks.pl)
# * adds import into breeding farm
#
# Please note that :
# * z3950 functionnality is dropped from "marcimport" will be added somewhere else.
# * templates are in a new acqui.simple sub directory, and the marcimport template directory will become obsolete soon.I think this is more logic
#
