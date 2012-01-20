#!/usr/bin/perl

# Copyright 2008-2009 BibLibre SARL
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

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Budgets;

=head1 NAME

fetch_sort_dropbox.pl

=head1 DESCRIPTION

 This script fetches sort values for a given budget id. Currently it is used to dynamically fill
 'Statistic 1' and 'Statistic 2' comboboxes in neworderempty page. Values retrieved depend on
 categories of authorized values defined in funds configuration.

=head1 CGI PARAMETERS

=over 4

=item budget_id

Budget identifier

=item sort

Sort number. 1 or 2 for the moment.

=back

=cut

my $input = new CGI;

my $budget_id = $input->param('budget_id');
my $sort_id   = $input->param('sort');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/ajax.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired => {editcatalogue => 'edit_catalogue'},
        debug => 0,
    }
);

my $budget = GetBudget($budget_id);
my $dropbox_values = GetAuthvalueDropbox( $budget->{'sort'.$sort_id.'_authcat'}, '' );

my @authorised_values;
my %authorised_lib;

foreach ( @$dropbox_values) {
    push @authorised_values, $_->{value};
    $authorised_lib{$_->{value}} = $_->{label};
}

my $budget_authvalue_dropbox = CGI::scrolling_list(
    -values   => \@authorised_values,
    -labels   => \%authorised_lib,
    -default  => $authorised_values[0],
);


# strip off select tags
$budget_authvalue_dropbox =~ s/^\<select.*?\"\>//;
$budget_authvalue_dropbox =~ s/\<\/select\>$//;
chomp $budget_authvalue_dropbox;

$template->param( return => $budget_authvalue_dropbox );
output_html_with_http_headers $input, $cookie, $template->output;
