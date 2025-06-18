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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI             qw( -utf8 );
use List::MoreUtils qw( uniq );

use C4::Auth           qw( get_template_and_user );
use C4::Circulation    qw( barcodedecode );
use C4::Output         qw( output_html_with_http_headers );
use C4::CourseReserves qw( GetCourse ModCourse ModCourseItem ModCourseReserve );

use Koha::Items;

my $cgi = CGI->new;

my $op            = $cgi->param('op')            || q{};
my $course_id     = $cgi->param('course_id')     || q{};
my $barcodes      = $cgi->param('barcodes')      || q{};
my $biblionumbers = $cgi->param('biblionumbers') || q{};

my $itype         = $cgi->param('itype');
my $ccode         = $cgi->param('ccode');
my $homebranch    = $cgi->param('homebranch');
my $holdingbranch = $cgi->param('holdingbranch');
my $location      = $cgi->param('location');

my $itype_enabled         = scalar $cgi->param('itype_enabled')         ? 1 : 0;
my $ccode_enabled         = scalar $cgi->param('ccode_enabled')         ? 1 : 0;
my $homebranch_enabled    = scalar $cgi->param('homebranch_enabled')    ? 1 : 0;
my $holdingbranch_enabled = scalar $cgi->param('holdingbranch_enabled') ? 1 : 0;
my $location_enabled      = scalar $cgi->param('location_enabled')      ? 1 : 0;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "course_reserves/batch_add_items.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { coursereserves => 'add_reserves' },
    }
);

my $course = GetCourse($course_id);

if ( $course_id && $course ) {
    $template->param( course => $course );

    if ( !$op ) {
        $template->param( action => 'display_form' );
    } elsif ( $op eq 'cud-add' ) {
        my @barcodes      = uniq( split( /\s\n/, $barcodes ) );
        my @biblionumbers = uniq( split( /\s\n/, $biblionumbers ) );

        if ( @barcodes > 0 ) {
            my @items;
            my @invalid_barcodes;
            for my $b (@barcodes) {
                $b = barcodedecode($b) if $b;
                my $item = Koha::Items->find( { barcode => $b } );

                if ($item) {
                    push( @items, $item );
                } else {
                    push( @invalid_barcodes, $b );
                }
            }

            foreach my $item (@items) {
                my $ci_id = ModCourseItem(
                    itemnumber            => $item->id,
                    biblionumber          => undef,
                    itype                 => $itype,
                    ccode                 => $ccode,
                    holdingbranch         => $holdingbranch,
                    homebranch            => $homebranch,
                    location              => $location,
                    itype_enabled         => $itype_enabled,
                    ccode_enabled         => $ccode_enabled,
                    holdingbranch_enabled => $holdingbranch_enabled,
                    homebranch_enabled    => $homebranch_enabled,
                    location_enabled      => $location_enabled,
                );

                my $staff_note  = $cgi->param('item_staff_note');
                my $public_note = $cgi->param('item_public_note');
                my $cr_id       = ModCourseReserve(
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
                barcodes         => 1,
            );

        } elsif ( @biblionumbers > 0 ) {
            my @biblios;
            my @invalid_biblionumbers;
            for my $b (@biblionumbers) {
                my $biblio = Koha::Biblios->find($b);

                if ($biblio) {
                    push( @biblios, $biblio );
                } else {
                    push( @invalid_biblionumbers, $b );
                }
            }

            foreach my $biblio (@biblios) {
                my $ci_id = ModCourseItem(
                    itemnumber            => undef,
                    biblionumber          => $biblio->id,
                    itype                 => $itype,
                    ccode                 => $ccode,
                    holdingbranch         => $holdingbranch,
                    homebranch            => $homebranch,
                    location              => $location,
                    itype_enabled         => $itype_enabled,
                    ccode_enabled         => $ccode_enabled,
                    holdingbranch_enabled => $holdingbranch_enabled,
                    homebranch_enabled    => $homebranch_enabled,
                    location_enabled      => $location_enabled,
                );

                my $staff_note  = $cgi->param('biblio_staff_note');
                my $public_note = $cgi->param('biblio_public_note');
                my $cr_id       = ModCourseReserve(
                    course_id   => $course_id,
                    ci_id       => $ci_id,
                    staff_note  => $staff_note,
                    public_note => $public_note,
                );
            }

            $template->param(
                action                => 'display_results',
                biblios_added         => \@biblios,
                invalid_biblionumbers => \@invalid_biblionumbers,
                course_id             => $course_id,
                biblionumbers         => 1,
            );
        }
    }
} else {
    $template->param( action => 'invalid_course' );
}

output_html_with_http_headers $cgi, $cookie, $template->output;
