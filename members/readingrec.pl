#!/usr/bin/perl

# written 27/01/2000
# script to display borrowers reading record

# Copyright 2000-2002 Katipo Communications
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
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use List::MoreUtils qw( any uniq );
use Koha::DateUtils qw( dt_from_string );
use Koha::ActionLogs;

use Koha::Patrons;
use Koha::Patron::Categories;

my $input = CGI->new;

my ($template, $loggedinuser, $cookie)= get_template_and_user({template_name => "members/readingrec.tt",
				query => $input,
				type => "intranet",
                flagsrequired => {borrowers => 'edit_borrowers'},
				});

my $op = $input->param('op') || '';
my $patron;
if ($input->param('cardnumber')) {
    my $cardnumber = $input->param('cardnumber');
    $patron = Koha::Patrons->find( { cardnumber => $cardnumber } );
}
if ($input->param('borrowernumber')) {
    my $borrowernumber = $input->param('borrowernumber');
    $patron = Koha::Patrons->find( $borrowernumber );
}

my $logged_in_user = Koha::Patrons->find( $loggedinuser );
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

#   barcode export
if ( $op eq 'export_barcodes' ) {
    # FIXME This should be moved out of this script
    if ( $patron->privacy < 2) {
        my @barcodes = $patron->old_checkouts->search( {}, { prefetch => 'item' } )
          ->filter_by_todays_checkins->get_column('item.barcode');

        my $borrowercardnumber = $patron->cardnumber;
        my $delimiter = "\n";
        my $today = dt_from_string->ymd;
        binmode( STDOUT, ":encoding(UTF-8)" );
        print $input->header(
            -type       => 'application/octet-stream',
            -charset    => 'utf-8',
            -attachment => "$today-$borrowercardnumber-checkinexport.txt"
        );

        my $content = join $delimiter, uniq(@barcodes);
        print $content;
        exit;
    }
}

# Do not request the old issues of anonymous patron
if ( $patron->borrowernumber eq C4::Context->preference('AnonymousPatron') ){
    # use of 'eq' in the above comparison is intentional -- the
    # system preference value could be blank
    $template->param( is_anonymous => 1 );
} else {
    $template->param(
        checkouts => [
            $patron->checkouts(
                {},
                {
                    order_by => 'date_due desc',
                    prefetch => { item => { biblio => 'biblioitems' } },
                }
            )->as_list
        ]
    );
    $template->param(
        old_checkouts => [
            $patron->old_checkouts(
                {},
                {
                    order_by => 'date_due desc',
                    prefetch => { item => { biblio => 'biblioitems' } },
                }
            )->as_list
        ]
    );
}

$template->param(
    patron            => $patron,
    readingrecordview => 1,
);
output_html_with_http_headers $input, $cookie, $template->output;

