#!/usr/bin/perl

# Copyright 2013 C & P Bibliography Services
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
use C4::Auth;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "circ/offline-mf.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

$template->{'VARS'}->{'cookie'} = $cookie;
print $query->header( -type => 'text/cache-manifest', cookie => $cookie );
print $template->output;
