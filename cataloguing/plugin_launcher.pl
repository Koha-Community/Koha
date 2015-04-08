#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Context;
use C4::Output;

my $input = new CGI;
my $plugin_name="cataloguing/value_builder/".$input->param("plugin_name");

# opening plugin. Just check whether we are on a developer computer on a production one
# (the cgidir differs)
my $cgidir = C4::Context->intranetdir ."/cgi-bin";
my $vbdir = "$cgidir/cataloguing/value_builder";
unless (-r $vbdir and -d $vbdir) {
	$cgidir = C4::Context->intranetdir;
}
do $cgidir."/".$plugin_name;
&plugin($input);
