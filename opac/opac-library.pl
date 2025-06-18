#!/usr/bin/perl

# Copyright 2020 Athens County Public Libraries
#
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

use CGI      qw ( -utf8 );
use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Koha::Libraries;

my $query = CGI->new();

my $branchcode = $query->param('branchcode');

# if OPACShowLibraries is disabled, leave immediately
if ( !C4::Context->preference('OPACShowLibraries') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-library.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

my $library;
my $libraries = Koha::Libraries->search( { public => 1 }, { order_by => ['branchname'] } );
$template->param( public_count => $libraries->count );
if ( $template->{VARS}->{singleBranchMode} || $libraries->count == 1 ) {
    $library = $libraries->next;
} elsif ($branchcode) {
    $library = $libraries->search( { branchcode => $branchcode } )->next;
}

if ($library) {
    $template->param( library => $library );
} else {
    $template->param(
        libraries  => $libraries,
        branchcode => C4::Context->userenv ? C4::Context->userenv->{branch} : q{},
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
