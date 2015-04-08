#!/usr/bin/perl

#script to display and update currency rates

# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
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
use warnings;
use CGI;
use C4::Acquisition;
use C4::Biblio;
use C4::Budgets;

# FIXME: CHECK AUTH
# FIXME: This should be part of another script, not a throwaway standalone.
# FIXME: params should have better checks before passed to ModCurrencies
# FIXME: need error handling if ModCurrencies FAILS.

my $input = new CGI;

foreach my $param ($input->param) {
    if ($param ne 'type' && $param !~ /submit/) {
        ModCurrencies($param, $input->param($param));
    }
}
print $input->redirect('/cgi-bin/koha/acqui/acqui-home.pl');
