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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth        qw( get_template_and_user );
use C4::Circulation qw( barcodedecode );
use C4::Output      qw( output_html_with_http_headers );
use C4::Koha        qw( GetAuthorisedValues );

use C4::CourseReserves qw( GetCourse GetCourseReserve ModCourse ModCourseItem ModCourseReserve );

use Koha::Items;
use Koha::ItemTypes;

my $cgi = CGI->new;

my $op           = $cgi->param('op')           || '';
my $course_id    = $cgi->param('course_id')    || '';
my $barcode      = $cgi->param('barcode')      || '';
my $return       = $cgi->param('return')       || '';
my $itemnumber   = $cgi->param('itemnumber')   || '';
my $is_edit      = $cgi->param('is_edit')      || '';
my $biblionumber = $cgi->param('biblionumber') || '';

$barcode = barcodedecode($barcode) if $barcode;
$biblionumber =~ s/^\s*|\s*$//g;    #remove leading/trailing whitespace

my ( $item, $biblio );

if ( $barcode || $itemnumber ) {

    # adding an item to course items
    $item = $itemnumber ? Koha::Items->find($itemnumber) : Koha::Items->find( { barcode => $barcode } );
    if ($item) {
        $itemnumber = $item->id;
        $biblio     = $item->biblio;
    }
} else {

    # adding a biblio to course items
    $biblio = Koha::Biblios->find($biblionumber);
}

my $step = ( $op eq 'lookup' && ( $item or $biblio ) ) ? '2' : '1';

my $tmpl = ($course_id) ? "add_items-step$step.tt" : "invalid-course.tt";
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "course_reserves/$tmpl",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { coursereserves => 'add_reserves' },
    }
);

if ( !$item && !$biblio && $op eq 'lookup' ) {
    $template->param( ERROR_ITEM_NOT_FOUND => 1 );
    $template->param( UNKNOWN_BARCODE      => $barcode )      if $barcode;
    $template->param( UNKNOWN_BIBLIONUMBER => $biblionumber ) if $biblionumber;
}

$template->param( course => GetCourse($course_id) );

if ( $op eq 'lookup' and $item ) {
    my $course_item    = Koha::Course::Items->find( { itemnumber => $item->id } );
    my $course_reserve = ($course_item)
        ? GetCourseReserve(
        course_id => $course_id,
        ci_id     => $course_item->ci_id,
        )
        : undef;

    my $itemtypes = Koha::ItemTypes->search;
    $template->param(
        item           => $item,
        biblio         => $biblio,
        course_item    => $course_item,
        course_reserve => $course_reserve,
        is_edit        => $is_edit,

        ccodes    => GetAuthorisedValues('CCODE'),
        locations => GetAuthorisedValues('LOC'),
        itypes    => $itemtypes,    # FIXME We certainly want to display the translated_description in the template
        return    => $return,
    );

} elsif ( $op eq 'lookup' and $biblio ) {
    my $course_item    = Koha::Course::Items->find( { biblionumber => $biblio->biblionumber } );
    my $course_reserve = ($course_item)
        ? GetCourseReserve(
        course_id => $course_id,
        ci_id     => $course_item->ci_id,
        )
        : undef;

    my $itemtypes = Koha::ItemTypes->search;
    $template->param(
        biblio         => $biblio,
        course_item    => $course_item,
        course_reserve => $course_reserve,
        is_edit        => $is_edit,

        return => $return,
    );

} elsif ( $op eq 'cud-add' ) {
    my $itype         = scalar $cgi->param('itype');
    my $ccode         = scalar $cgi->param('ccode');
    my $homebranch    = $cgi->param('homebranch');
    my $holdingbranch = scalar $cgi->param('holdingbranch');
    my $location      = scalar $cgi->param('location');

    my $itype_enabled         = scalar $cgi->param('itype_enabled')         ? 1 : 0;
    my $ccode_enabled         = scalar $cgi->param('ccode_enabled')         ? 1 : 0;
    my $homebranch_enabled    = $cgi->param('homebranch_enabled')           ? 1 : 0;
    my $holdingbranch_enabled = scalar $cgi->param('holdingbranch_enabled') ? 1 : 0;
    my $location_enabled      = scalar $cgi->param('location_enabled')      ? 1 : 0;

    my $ci_id = ModCourseItem(
        itemnumber            => $itemnumber,
        biblionumber          => $biblionumber,
        itype                 => $itype,
        ccode                 => $ccode,
        homebranch            => $homebranch,
        holdingbranch         => $holdingbranch,
        location              => $location,
        itype_enabled         => $itype_enabled,
        ccode_enabled         => $ccode_enabled,
        homebranch_enabled    => $homebranch_enabled,
        holdingbranch_enabled => $holdingbranch_enabled,
        location_enabled      => $location_enabled,
    );

    my $cr_id = ModCourseReserve(
        course_id   => $course_id,
        ci_id       => $ci_id,
        staff_note  => scalar $cgi->param('staff_note'),
        public_note => scalar $cgi->param('public_note'),
    );

    if ($return) {
        print $cgi->redirect("/cgi-bin/koha/course_reserves/course-details.pl?course_id=$return");
        exit;
    }
}

output_html_with_http_headers $cgi, $cookie, $template->output;
