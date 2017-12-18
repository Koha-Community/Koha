#!/usr/bin/perl

# Copyright 2017 Koha Development team
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

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Context;
use Koha::Manual;

my $query = new CGI;

# find the script that called the online help using the CGI referer()
our $refer = $query->param('url');
$refer = $query->referer()  if !$refer || $refer eq 'undefined';

my $manual_url = Koha::Manual::get_url($refer);

print $query->redirect($manual_url);
