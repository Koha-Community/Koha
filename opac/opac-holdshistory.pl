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

use C4::Auth;
use C4::Output;

use Koha::Patrons;

my $query = CGI->new;
my @all_holds;

# if opacreadinghistory is disabled, leave immediately
unless ( C4::Context->preference('OPACHoldsHistory') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $patron_id, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-holdshistory.tt",
        query           => $query,
        type            => "opac"
    }
);

my $patron = Koha::Patrons->find( $patron_id );

my $holds = $patron->holds;
my $old_holds = $patron->old_holds;

while (my $hold = $holds->next) {
    push @all_holds, $hold;
}

while (my $hold = $old_holds->next) {
    push @all_holds, $hold;
}

my $sort = $query->param('sort');

$sort = 'reservedate' unless $sort;

if($sort eq 'reservedate') {
    @all_holds = sort {$b->$sort cmp $a->$sort} @all_holds;
} else {
    my ($obj, $col) = split /\./, $sort;
    @all_holds = sort {$a->$obj->$col cmp $b->$obj->$col} @all_holds;
}

my $unlimit = $query->param('unlimit');

unless($unlimit) {
    @all_holds = splice(@all_holds, 0, 50);
}

$template->param(
    holdshistoryview => 1,
    patron           => $patron,
    holds            => \@all_holds,
    unlimit          => $unlimit,
    sort             => $sort
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
