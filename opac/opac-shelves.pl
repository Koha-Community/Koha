#!/usr/bin/perl

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
use C4::VirtualShelves::Page;
use C4::Auth;

my $query = CGI->new();

my ( $template, $loggedinuser, $cookie ) = get_template_and_user({
        template_name   => "opac-shelves.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    });

# if $loggedinuser is not defined, set it to -1, which should
# not correspond to any real borrowernumber.  
# FIXME: this is a hack to temporarily avoid changing several
#        routines in C4::VirtualShelves and C4::VirtualShelves::page
#        to deal with lists accessed during an anonymous OPAC session
shelfpage('opac', $query, $template, (defined($loggedinuser) ? $loggedinuser : -1), $cookie);
