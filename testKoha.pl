#!/usr/bin/perl -w

# $Id$


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
	't/format.t',
	't/Input.t',
	't/koha.t',
	't/output.t',
	't/require.t',
	't/Catalogue.t',
);


runtests (@tests);

exit;

# $Log$
# Revision 1.6  2002/08/14 18:12:51  tonnesen
# Added copyright statement to all .pl and .pm files
#
# Revision 1.5  2002/06/20 18:04:46  tonnesen
# Are we getting sick of merging yet?  Not me!
#
# Revision 1.1.2.7  2002/06/20 15:19:33  amillar
# Test valid ISBN numbers in Input.pm
#
