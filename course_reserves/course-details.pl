#!/usr/bin/perl

#
# Copyright 2012 Bywater Solutions
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

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use C4::CourseReserves qw( DelCourse DelCourseReserve GetCourse GetCourseReserve GetCourseReserves );

my $cgi = CGI->new;

my $action = $cgi->param('action') || '';
my $course_id = $cgi->param('course_id');

my $flagsrequired;
$flagsrequired->{coursereserves} = 'delete_reserves' if ( $action eq 'del_reserve' or $action eq 'rm_all' );

my $tmpl = ($course_id) ? "course-details.tt" : "invalid-course.tt";
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "course_reserves/$tmpl",
        query           => $cgi,
        type            => "intranet",
        flagsrequired   => $flagsrequired,
    }
);

if ( $action eq 'del_reserve' ) {
    DelCourseReserve( cr_id => scalar $cgi->param('cr_id') );
}
elsif ( $action eq 'rm_all' ) {
    my $course_res = GetCourseReserves(course_id => $course_id);
    foreach my $cr (@$course_res) {
        if(exists $cr->{'cr_id'}) {
            DelCourseReserve(cr_id => $cr->{cr_id});
        }
    }
}

my $course          = GetCourse($course_id);
my $course_reserves = GetCourseReserves(
    course_id       => $course_id,
    include_items   => 1,
    include_courses => 1
);

$template->param(
    course          => $course,
    course_reserves => $course_reserves,
    user            => Koha::Patrons->find( $loggedinuser ),
);

output_html_with_http_headers $cgi, $cookie, $template->output;
