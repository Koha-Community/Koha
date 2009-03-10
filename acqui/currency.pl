#!/usr/bin/perl

#written by chris@katipo.co.nz
#9/10/2000
#script to display and update currency rates

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
use warnings;
use CGI;
use C4::Bookfund qw(ModCurrencies);

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
