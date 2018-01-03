#!/usr/bin/perl

# Copyright 2013 ByWater Solutions
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
use C4::Output;
use Koha::List::Patron;
use List::MoreUtils qw/uniq/;

my $cgi = new CGI;

my ( $template, $logged_in_user, $cookie ) = get_template_and_user(
    {
        template_name   => "patron_lists/list.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired => { tools => 'manage_patron_lists' },
    }
);

my ($list) =
  GetPatronLists( { patron_list_id => scalar $cgi->param('patron_list_id') } );

my @existing = $list->patron_list_patrons;

my $cardnumbers = $cgi->param('patrons_by_barcode');
my @patrons_by_barcode;

if ( $cardnumbers ){
    push my @patrons_by_barcode, uniq( split(/\s\n/, $cardnumbers) );
    my @results = AddPatronsToList( { list => $list, cardnumbers => \@patrons_by_barcode } );
    my %found = map { $_->borrowernumber->cardnumber => 1 } @results;
    my %exist = map { $_->borrowernumber->cardnumber => 1 } @existing;
    my (@not_found, @existed);
    foreach my $barcode ( @patrons_by_barcode ){
        push (@not_found, $barcode) unless defined $found{$barcode};
        push (@existed, $barcode) if defined $exist{$barcode};
    }
    $template->param(
        not_found => \@not_found,
        existed   => \@existed,
    );
}

my @patrons_to_add = $cgi->multi_param('patrons_to_add');
if (@patrons_to_add) {
    AddPatronsToList( { list => $list, cardnumbers => \@patrons_to_add } );
}

my @patrons_to_remove = $cgi->multi_param('patrons_to_remove');
if (@patrons_to_remove) {
    DelPatronsFromList( { list => $list, patron_list_patrons => \@patrons_to_remove } );
}

$template->param( list => $list );

output_html_with_http_headers( $cgi, $cookie, $template->output );
