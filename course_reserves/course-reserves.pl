#!/usr/bin/perl

#
# Copyright 2012 Bywater Solutions
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;

use C4::Auth;
use C4::Output;

use C4::CourseReserves;

my $cgi = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "course_reserves/course-reserves.tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { coursereserves => '*' },
    }
);

my $search_on = $cgi->param('search_on');
my %params;
if ($search_on) {
    $params{'course_name'} = "%$search_on%";
}

my $courses = GetCourses(%params);
if ( $search_on && @$courses == 1 ) {
    print $cgi->redirect("/cgi-bin/koha/course_reserves/course-details.pl?course_id=" . $courses->[0]->{'course_id'});
} else {
    $template->param( courses => $courses );
    output_html_with_http_headers $cgi, $cookie, $template->output;
}
