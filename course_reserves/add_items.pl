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
use C4::Koha;
use C4::Biblio;
use C4::Branch;

use C4::CourseReserves qw(GetCourse GetCourseItem GetCourseReserve ModCourseItem ModCourseReserve);

my $cgi = new CGI;

my $action    = $cgi->param('action')    || '';
my $course_id = $cgi->param('course_id') || '';
my $barcode   = $cgi->param('barcode')   || '';
my $return    = $cgi->param('return')    || '';

my $item = GetBiblioFromItemNumber( undef, $barcode );

my $step = ( $action eq 'lookup' && $item ) ? '2' : '1';

my $tmpl = ($course_id) ? "add_items-step$step.tt" : "invalid-course.tt";
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "course_reserves/$tmpl",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { coursereserves => 'add_reserves' },
    }
);
$template->param( ERROR_BARCODE_NOT_FOUND => $barcode )
  unless ( $barcode && $item && $action eq 'lookup' );

$template->param( course => GetCourse($course_id) );

if ( $action eq 'lookup' ) {
    my $course_item = GetCourseItem( itemnumber => $item->{'itemnumber'} );
    my $course_reserve =
      ($course_item)
      ? GetCourseReserve(
        course_id => $course_id,
        ci_id     => $course_item->{'ci_id'}
      )
      : undef;

    $template->param(
        item           => $item,
        course_item    => $course_item,
        course_reserve => $course_reserve,

        ccodes    => GetAuthorisedValues('CCODE'),
        locations => GetAuthorisedValues('LOC'),
        itypes    => GetItemTypes( style => 'array' ),
        branches  => GetBranchesLoop(),
        return    => $return,
    );

} elsif ( $action eq 'add' ) {
    my $ci_id = ModCourseItem(
        itemnumber    => $cgi->param('itemnumber'),
        itype         => $cgi->param('itype'),
        ccode         => $cgi->param('ccode'),
        holdingbranch => $cgi->param('holdingbranch'),
        location      => $cgi->param('location'),
    );

    my $cr_id = ModCourseReserve(
        course_id   => $course_id,
        ci_id       => $ci_id,
        staff_note  => $cgi->param('staff_note'),
        public_note => $cgi->param('public_note'),
    );

    if ( $return ) {
        print $cgi->redirect("/cgi-bin/koha/course_reserves/course-details.pl?course_id=$return");
        exit;
    }
}

output_html_with_http_headers $cgi, $cookie, $template->output;
