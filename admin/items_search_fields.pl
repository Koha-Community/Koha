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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Item::Search::Field qw(GetItemSearchFields DelItemSearchField);

my $cgi = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => 'admin/items_search_fields.tt',
        query         => $cgi,
        type          => 'intranet',
        flagsrequired => { parameters => 'manage_item_search_fields' },
    }
);

my $op = $cgi->param('op') || '';

if ( $op eq 'cud-del' ) {
    my $name = $cgi->param('name');
    my $rv   = DelItemSearchField($name);
    if ($rv) {
        $template->param( field_deleted => 1 );
    } else {
        $template->param( field_not_deleted => 1 );
    }
} else {
    my $updated = $cgi->param('updated');
    if ( defined $updated ) {
        if ($updated) {
            $template->param( field_updated => 1 );
        } else {
            $template->param( field_not_updated => 1 );
        }
    }
}

my @fields = GetItemSearchFields();

$template->param(
    fields => \@fields,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
