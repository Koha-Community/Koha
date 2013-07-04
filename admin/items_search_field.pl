#!/usr/bin/perl
# Copyright 2013 BibLibre
#
# This file is part of Koha
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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

use Koha::Item::Search::Field qw(GetItemSearchField ModItemSearchField);

my $cgi = new CGI;

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => 'admin/items_search_field.tt',
    query => $cgi,
    type => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { catalogue => 1 },
});

my $op = $cgi->param('op') || '';
my $name = $cgi->param('name');

if ($op eq 'mod') {
    my %vars = $cgi->Vars;
    my $field = { name => $name };
    my @params = qw(label tagfield tagsubfield authorised_values_category);
    @$field{@params} = @vars{@params};
    if ( $field->{authorised_values_category} eq '' ) {
        $field->{authorised_values_category} = undef;
    }
    $field = ModItemSearchField($field);
    my $updated = ($field) ? 1 : 0;
    print $cgi->redirect('/cgi-bin/koha/admin/items_search_fields.pl?updated=' . $updated);
    exit;
}

my $field = GetItemSearchField($name);
my $authorised_values_categories = C4::Koha::GetAuthorisedValueCategories();

$template->param(
    field => $field,
    authorised_values_categories => $authorised_values_categories,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
