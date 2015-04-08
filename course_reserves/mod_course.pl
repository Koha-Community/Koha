#!/usr/bin/perl

# Copyright 2012 ByWater Solutions
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

use CGI;

use C4::Output;
use C4::Reserves;
use C4::Auth;

use C4::CourseReserves qw(DelCourse ModCourse ModCourseInstructors);

my $cgi = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "about.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { coursereserves => 'manage_courses' },
    }
);

my $action = $cgi->param('action') || '';

if ( $action eq 'del' ) {
    DelCourse( $cgi->param('course_id') );
    print $cgi->redirect("/cgi-bin/koha/course_reserves/course-reserves.pl");
} else {
    my %params;

    $params{'course_id'} = $cgi->param('course_id')
      if ( $cgi->param('course_id') );
    $params{'department'}     = $cgi->param('department');
    $params{'course_number'}  = $cgi->param('course_number');
    $params{'section'}        = $cgi->param('section');
    $params{'course_name'}    = $cgi->param('course_name');
    $params{'term'}           = $cgi->param('term');
    $params{'staff_note'}     = $cgi->param('staff_note');
    $params{'public_note'}    = $cgi->param('public_note');
    $params{'students_count'} = $cgi->param('students_count');
    $params{'enabled'}        = ( $cgi->param('enabled') eq 'on' ) ? 'yes' : 'no';

    my $course_id = ModCourse(%params);

    my @instructors = $cgi->param('instructors');
    ModCourseInstructors(
        mode        => 'replace',
        cardnumbers => \@instructors,
        course_id   => $course_id
    );
    print $cgi->redirect("/cgi-bin/koha/course_reserves/course-details.pl?course_id=$course_id");
}
