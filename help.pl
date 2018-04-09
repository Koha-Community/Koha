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

use C4::Auth;
use C4::Context;
use Koha::Manual;

my $query = new CGI;

# We need to call get_template_and_user to let it does the job correctly
# for the language
my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "intranet-main.tt", # Just a valid template path
        query           => $query,
        type            => "intranet",
        authnotrequired => 1,
    }
);

# find the script that called the online help using the CGI referer()
our $refer = $query->param('url');
$refer = $query->referer()  if !$refer || $refer eq 'undefined';

my $language = C4::Languages::getlanguage( $query );
my $manual_url = Koha::Manual::get_url($refer, $language);

print $query->redirect($manual_url);
