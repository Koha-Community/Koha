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

use CGI        qw( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Module::Policy::Checkin;

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/checkin.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

my $patron  = Koha::Patrons->find($loggedinuser);
my $library = C4::Context->userenv->{branch};

my $policy = Koha::Module::Policy::Checkin->new(
    {
        user    => $patron,
        library => $library,
    }
);

$template->param( module_policy => $policy );

# Check-in requested from another page (the header search box, ILL, ...):
# the page checks the item in once it is loaded. Only POST requests (with
# a CSRF token) do, a GET with a barcode only prefills it.
my $op = $input->param(q{op}) // q{};
if ( $op eq q{cud-checkin} ) {
    $template->param( checkin_barcode => scalar $input->param(q{barcode}) );
}

output_html_with_http_headers $input, $cookie, $template->output;
