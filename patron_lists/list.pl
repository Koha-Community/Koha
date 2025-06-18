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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth           qw( get_template_and_user );
use C4::Output         qw( output_html_with_http_headers );
use Koha::List::Patron qw(
    AddPatronsToList
    DelPatronsFromList
    GetPatronLists
);
use List::MoreUtils qw( uniq );

my $cgi = CGI->new;
my $op  = $cgi->param('op') // q{};

my ( $template, $logged_in_user, $cookie ) = get_template_and_user(
    {
        template_name => "patron_lists/list.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { tools => 'manage_patron_lists' },
    }
);

my ($list) =
    GetPatronLists( { patron_list_id => scalar $cgi->param('patron_list_id') } );

my @existing = $list->patron_list_patrons;

my $patrons_by_id = $cgi->param('patrons_by_id');
my $id_column     = $cgi->param('id_column');

if ( $op eq 'cud-add' && $patrons_by_id ) {
    push my @patrons_list, uniq( split( /\s\n/, $patrons_by_id ) );
    my %add_params;
    $add_params{list} = $list;
    $add_params{$id_column} = \@patrons_list;
    my @results = AddPatronsToList( \%add_params );
    my $id      = $id_column eq 'borrowernumbers' ? 'borrowernumber' : 'cardnumber';
    my %found   = map { $_->borrowernumber->$id => 1 } @results;
    my %exist   = map { $_->borrowernumber->$id => 1 } @existing;
    my ( @not_found, @existed );

    foreach my $patron (@patrons_list) {
        push( @not_found, $patron ) unless defined $found{$patron};
        push( @existed,   $patron ) if defined $exist{$patron};
    }
    $template->param(
        not_found => \@not_found,
        existed   => \@existed,
        id_column => $id_column,
    );
}

my @patrons_to_add = $cgi->multi_param('patrons_to_add');
if ( $op eq 'cud-add' && @patrons_to_add ) {
    AddPatronsToList( { list => $list, cardnumbers => \@patrons_to_add } );
}

my @patrons_to_remove = $cgi->multi_param('patrons_to_remove');
if ( $op eq 'cud-delete' && @patrons_to_remove ) {
    DelPatronsFromList( { list => $list, patron_list_patrons => \@patrons_to_remove } );
}

$template->param( list => $list );

output_html_with_http_headers( $cgi, $cookie, $template->output );
