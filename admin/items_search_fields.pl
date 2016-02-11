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

use Koha::Item::Search::Field qw(AddItemSearchField GetItemSearchFields DelItemSearchField);

my $cgi = new CGI;

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => 'admin/items_search_fields.tt',
    query => $cgi,
    type => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { catalogue => 1 },
});

my $op = $cgi->param('op') || '';

if ($op eq 'add') {
    my %vars = $cgi->Vars;
    my $field;
    my @params = qw(name label tagfield tagsubfield authorised_values_category);
    @$field{@params} = @vars{@params};
    if ( $field->{authorised_values_category} eq '' ) {
        $field->{authorised_values_category} = undef;
    }
    $field = AddItemSearchField($field);
    if ($field) {
        $template->param(field_added => $field);
    } else {
        $template->param(field_not_added => 1);
    }
} elsif ($op eq 'del') {
    my $name = $cgi->param('name');
    my $rv = DelItemSearchField($name);
    if ($rv) {
        $template->param(field_deleted => 1);
    } else {
        $template->param(field_not_deleted => 1);
    }
} else {
    my $updated = $cgi->param('updated');
    if (defined $updated) {
        if ($updated) {
            $template->param(field_updated => 1);
        } else {
            $template->param(field_not_updated => 1);
        }
    }
}

my @fields = GetItemSearchFields();

$template->param(
    fields => \@fields,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
