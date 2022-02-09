#!/usr/bin/perl

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
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Patron::Attribute::Types;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "members/search.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { catalogue => '*' },
    }
);

my $referer = $input->referer();

my @columns = split ',', $input->param('columns');
my $callback = $input->param('callback');
my $selection_type = $input->param('selection_type') || 'select';
my $filter = $input->param('filter');

$template->param(
    view           => ( $input->request_method() eq "GET" ) ? "show_form" : "show_results",
    callback       => $callback,
    columns        => \@columns,
    filter         => $filter,
    selection_type => $selection_type,
    attribute_type_codes => ( C4::Context->preference('ExtendedPatronAttributes')
        ? [ Koha::Patron::Attribute::Types->search( { staff_searchable => 1 } )->get_column('code') ]
        : [] ),
);
output_html_with_http_headers( $input, $cookie, $template->output );
