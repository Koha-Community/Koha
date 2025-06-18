#!/usr/bin/perl
# Copyright 2013 BibLibre
#
# This file is part of Koha
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
use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Item::Search::Field qw(GetItemSearchField AddItemSearchField ModItemSearchField);

my $cgi = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => 'admin/items_search_field.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { parameters => 'manage_item_search_fields' },
    }
);

my $op   = $cgi->param('op') || '';
my $name = $cgi->param('name');

if ( $op eq 'cud-mod' ) {
    my %vars   = $cgi->Vars;
    my $field  = { name => $name };
    my @params = qw(label tagfield tagsubfield authorised_values_category);
    @$field{@params} = @vars{@params};
    if ( $field->{authorised_values_category} eq '' ) {
        $field->{authorised_values_category} = undef;
    }
    $field = ModItemSearchField($field);
    my $updated = ($field) ? 1 : 0;
    print $cgi->redirect( '/cgi-bin/koha/admin/items_search_fields.pl?updated=' . $updated );
    exit;
} elsif ( $op eq 'cud-add' ) {
    my %vars = $cgi->Vars;
    my $field;
    my @params = qw(name label tagfield tagsubfield authorised_values_category);
    @$field{@params} = @vars{@params};
    if ( $field->{authorised_values_category} eq '' ) {
        $field->{authorised_values_category} = undef;
    }
    $field = AddItemSearchField($field);
    my $added = ($field) ? 1 : 0;
    print $cgi->redirect( '/cgi-bin/koha/admin/items_search_fields.pl?added=' . $added );
    exit;
}

my $field = GetItemSearchField($name);

$template->param(
    field => $field,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
