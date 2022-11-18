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
my $code = $query->param('code');
my $page;

my $homebranch = $ENV{OPAC_BRANCH_DEFAULT};
if (C4::Context->userenv) {
    $homebranch = C4::Context->userenv->{'branch'};
}

if( $page_id ) {
    $page = Koha::AdditionalContents->search({ idnew => $page_id, location => ['opac_only', 'staff_and_opac'], branchcode => [ $homebranch, undef ] });
} elsif( $code ) {
    my $lang = $query->param('language') || $query->cookie('KohaOpacLanguage') || $template->lang;
    # In the next query we make sure that the 'default' records come after the regular languages
    $page = Koha::AdditionalContents->search({ code => $code, lang => ['default', $lang], location => ['opac_only', 'staff_and_opac'], branchcode => [ $homebranch, undef ] }, { order_by => { -desc => \[ 'CASE WHEN lang="default" THEN "" ELSE lang END' ]}} );
}
$template->param( $page && $page->count ? ( page => $page->next ) : ( page_error => 1 ) );

output_html_with_http_headers $query, $cookie, $template->output;
