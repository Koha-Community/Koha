#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2020  Fenway Library Organization
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
use C4::CourseReserves qw( GetCourse GetCourseItem GetItemCourseReservesInfo DelCourse DelCourseReserve );

use Koha::Items;

my $cgi = CGI->new;

my $op       = $cgi->param('op')       || q{};
my $barcodes = $cgi->param('barcodes') || q{};

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "course_reserves/batch_rm_items.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { coursereserves => 'delete_reserves' },
    }
);

if ( !$op ) {
    $template->param( action => 'display_form' );

} elsif ( $op eq 'cud-batch_rm' ) {
    my @barcodes = uniq( split( /\s\n/, $barcodes ) );
    my @invalid_barcodes;
    my @item_and_count;

    foreach my $bar (@barcodes) {
        $bar = barcodedecode($bar) if $bar;
        my $item = Koha::Items->find( { barcode => $bar } );
        if ($item) {
            my $courseitem = GetCourseItem( itemnumber => $item->id );
            if ($courseitem) {

                my $res_info = GetItemCourseReservesInfo( itemnumber => $item->id );

                my $no_of_res = @$res_info;

                my $delitemcount = { 'delitem' => $item, 'delcount' => $no_of_res };
                push( @item_and_count, $delitemcount );

                foreach my $cr (@$res_info) {
                    if ( $cr->{cr_id} ) {
                        DelCourseReserve( 'cr_id' => $cr->{cr_id} );
                    }
                }
            } else {
                push( @invalid_barcodes, $bar );
            }
        } else {
            push( @invalid_barcodes, $bar );
        }

    }

    $template->param(
        action           => 'display_results',
        invalid_barcodes => \@invalid_barcodes,
        item_and_count   => \@item_and_count,
    );
}

output_html_with_http_headers $cgi, $cookie, $template->output;
