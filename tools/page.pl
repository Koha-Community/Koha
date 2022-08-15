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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::AdditionalContents;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/page.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

my $page_id = $query->param('page_id');
my $page;

if (defined $page_id){
    my $branch = C4::Context->userenv->{'branch'};
    $page = Koha::AdditionalContents->search({ idnew => $page_id, location => ['staff_only', 'staff_and_opac'], branchcode => [ $branch, undef ] });
    if ( $page->count > 0){
        $template->param( page => $page->next );
    } else {
        $template->param( page_error => 1 );
    }
}

output_html_with_http_headers $query, $cookie, $template->output;
