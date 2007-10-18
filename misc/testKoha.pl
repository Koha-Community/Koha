#!/usr/bin/perl -w



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
use Test::Harness;

# please add many tests here
# Please make the test name the same as the module name where possible

my @tests=(
	't/Accounts.t',
	't/Acquisition.t',
	't/Amazon.t',
	't/AuthoritiesMarc.t',
	't/Auth.t',
	't/Auth_with_ldap.t',
	't/Barcodes_PrinterConfig.t',
	't/Biblio.t',
	't/Bookfund.t',
	't/Bookseller.t',
	't/BookShelves.t',
	't/Boolean.t',
	't/Breeding.t',
	't/Calendar.t',
	't/Circulation.t',
	't/Context.t',
	't/Date.t',	
	't/Input.t',
	't/koha.t',
	't/Labels.t',
	't/Languages.t',
	't/Letters.t',
	't/Log.t',
	't/Maintainance.t',
	't/Members.t',
	't/NewsChannels.t',
	't/output.t',
	't/Overdues.t',
	't/Print.t',
	't/Record.t',
	't/Reserves.t',
	't/Review.t',
	't/Search.t',
	't/Serials.t',
	't/Stats.t',
	't/Suggestions.t',
	't/Z3950.t'
);


runtests (@tests);

exit;

# Revision 1.7  2007/06/18 03:20:19  rangi
# Finishing up the last of the tests
#
# Revision 1.6  2007/06/18 01:58:24  rangi
# Continuing on my tests mission
#
# Revision 1.5  2007/06/18 01:34:50  rangi
# More test files
#
# Revision 1.4  2007/06/18 00:51:10  rangi
# Continuing to add tests
#
# Revision 1.3  2007/06/17 23:44:04  rangi
# Simple compile only test for C4::Amazon
# Needs tests written for the 2 functions in it.
#
# Revision 1.2  2007/06/17 23:35:36  rangi
# Working on unit tests
#
# Revision 1.1  2002/11/22 09:05:18  tipaul
# moving non koha-running files to misc dir
#
# Revision 1.6  2002/08/14 18:12:51  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.5  2002/06/20 18:04:46  tonnesen
# Are we getting sick of merging yet?  Not me!
#
# Revision 1.1.2.7  2002/06/20 15:19:33  amillar
# Test valid ISBN numbers in Input.pm
#
