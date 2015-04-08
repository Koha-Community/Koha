#!/usr/bin/perl

# Copyright (C) 2007 LibLime
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

# This script is used by command-line utilities to set
# @INC properly -- specifically, to point to the directory
# containing the installed version of the C4 modules.
#
# This depends on the installer replacing the \_\_PERL_MODULE_DIR\_\_
# string with the path to the Koha modules directory.  This is done
# only during a 'standard' or 'single' mode installation.  If Koha
# is being run from a git checkout (and thus installed in 'dev' mode),
# this is a no-op.
#
# To use this script, a command-line utility should do the following before
# 'use'ing any C4 modules.
#
#     BEGIN {
#         use FindBin;
#         eval { require "$FindBin::Bin/kohalib.pl" };
#         # adjust path to point to kohalib.pl relative
#         # to location of script
#     }
#

use strict;
#use warnings; FIXME - Bug 2505

my $module_dir;
BEGIN {
    $module_dir = '__PERL_MODULE_DIR__';
    die if $module_dir =~ /^[_]{2}PERL_MODULE_DIR[_]{2}$/;
}

use lib $module_dir;

1;
