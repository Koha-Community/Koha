#!/usr/bin/perl

# Copyright 2015
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

use CGI qw ( -utf8 );

use C4::Output;
use C4::Auth qw( get_template_and_user );
use Koha::ArticleRequests;

my $query = CGI->new;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-account.tt",
        query         => $query,
        type          => "opac",
    }
);

my $id = $query->param('id');

if ($id) {
    my $ar = Koha::ArticleRequests->find($id);
    if ( !$ar ) {
        print $query->redirect("/cgi-bin/koha/errors/404.pl");
        exit;
    } elsif ( $ar->borrowernumber != $borrowernumber ) {
        print $query->redirect("/cgi-bin/koha/errors/403.pl");
        exit;
    }

    $ar->cancel();
}

print $query->redirect("/cgi-bin/koha/opac-user.pl#opac-user-article-requests");
