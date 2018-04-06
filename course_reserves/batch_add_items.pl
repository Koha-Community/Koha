#!/usr/bin/perl

#
# Copyright 2018 Bywater Solutions
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

use CGI qw( -utf8 );
use List::MoreUtils qw( uniq );

use C4::Auth;
use C4::Output;
use C4::CourseReserves qw(ModCourseItem ModCourseReserve GetCourse);

use Koha::Items;

my $cgi = new CGI;

my $action    = $cgi->param('action')    || q{};
my $course_id = $cgi->param('course_id') || q{};
my $barcodes  = $cgi->param('barcodes')  || q{};

my $itype         = $cgi->param('itype');
my $ccode         = $cgi->param('ccode');
my $holdingbranch = $cgi->param('holdingbranch');
my $location      = $cgi->param('location');
my $staff_note    = $cgi->param('staff_note');
my $public_note   = $cgi->param('public_note');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "course_reserves/batch_add_items.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { coursereserves => 'add_reserves' },
    }
);

my $course = GetCourse($course_id);

if ( $course_id && $course ) {
    $template->param( course => $course );

    if ( !$action ) {
        $template->param( action => 'display_form' );
    }
    elsif ( $action eq 'add' ) {
        my @barcodes = uniq( split( /\s\n/, $barcodes ) );

        my @items;
        my @invalid_barcodes;
        for my $b (@barcodes) {
            my $item = Koha::Items->find( { barcode => $b } );

            if ($item) {
                push( @items, $item );
            }
            else {
                push( @invalid_barcodes, $b );
            }
        }

        foreach my $item (@items) {
            my $ci_id = ModCourseItem(
                itemnumber    => $item->id,
                itype         => $itype,
                ccode         => $ccode,
                holdingbranch => $holdingbranch,
                location      => $location,
            );

            my $cr_id = ModCourseReserve(
                course_id   => $course_id,
                ci_id       => $ci_id,
                staff_note  => $staff_note,
                public_note => $public_note,
            );
        }

        $template->param(
            action           => 'display_results',
            items_added      => \@items,
            invalid_barcodes => \@invalid_barcodes,
            course_id        => $course_id,
        );
    }
} else {
    $template->param( action => 'invalid_course' );
}

output_html_with_http_headers $cgi, $cookie, $template->output;
