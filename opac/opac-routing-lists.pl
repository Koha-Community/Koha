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
use C4::Members;
use C4::Auth;
use C4::Output;
use Koha::Patrons;

my $query = new CGI;

unless ( C4::Context->preference('RoutingSerials') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}


my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-routing-lists.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

my $patron = Koha::Patrons->find( $borrowernumber );
my $category = $patron->category;
my $borrower= $patron->unblessed;
$borrower->{description} = $category->description;
$borrower->{category_type} = $category->category_type;
$template->param( BORROWER_INFO => $borrower );

my @routinglists = $patron->get_routinglists();

$template->param(
    routinglists  => \@routinglists,
    routinglistview => 1,
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
