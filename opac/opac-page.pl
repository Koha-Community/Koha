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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI           qw ( -utf8 );
use C4::Auth      qw( get_template_and_user );
use C4::Output    qw( output_html_with_http_headers );
use C4::Languages qw( getlanguage );
use Koha::AdditionalContents;

my $query = CGI->new();

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-page.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $page_id = $query->param('page_id');

my $homebranch = $ENV{OPAC_BRANCH_DEFAULT};
if ( C4::Context->userenv ) {
    $homebranch = C4::Context->userenv->{'branch'};
}

my $page = Koha::AdditionalContents->find($page_id);

if (  !$page
    || $page->category ne 'pages'
    || $page->branchcode && $page->branchcode != $homebranch
    || $page->location ne 'opac_only' && $page->location ne 'staff_and_opac' )
{
    print $query->redirect('/cgi-bin/koha/errors/404.pl');
    exit;
}

# Sanitize $query->param('language') via getlanguage
my $content = $page->translated_content( C4::Languages::getlanguage($query) );

$template->param( page => $content );

output_html_with_http_headers $query, $cookie, $template->output;
