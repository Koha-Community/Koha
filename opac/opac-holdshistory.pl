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

use CGI qw ( -utf8 );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Patrons;
use Koha::Holds;
use Koha::Old::Holds;

my $query = CGI->new;
my @all_holds;

# if opacreadinghistory is disabled, leave immediately
unless ( C4::Context->preference('OPACHoldsHistory') ) {
    print $query->redirect("/cgi-bin/koha/errors/404.pl");
    exit;
}

my ( $template, $patron_id, $cookie ) = get_template_and_user(
    {
        template_name => "opac-holdshistory.tt",
        query         => $query,
        type          => "opac"
    }
);

my $patron = Koha::Patrons->find($patron_id);

my $sort = $query->param('sort');
$sort = 'reservedate' unless $sort;

my $unlimit = $query->param('unlimit');
my $ops     = {
    prefetch => [ 'biblio', 'item' ],
    order_by => $sort
};

$ops->{rows} = 50 unless $unlimit;

my $holds = Koha::Holds->search( { borrowernumber => $patron_id }, $ops );

my $old_holds = Koha::Old::Holds->search( { borrowernumber => $patron_id }, $ops );

while ( my $hold = $holds->next ) {
    push @all_holds, $hold;
}

while ( my $hold = $old_holds->next ) {
    push @all_holds, $hold;
}

if ( $sort eq 'reservedate' ) {
    @all_holds = sort { $b->$sort cmp $a->$sort } @all_holds;
} else {
    my ( $obj, $col ) = split /\./, $sort;
    @all_holds = sort { ( $a->$obj && $a->$obj->$col || '' ) cmp( $b->$obj && $b->$obj->$col || '' ) } @all_holds;
}

unless ($unlimit) {
    @all_holds = splice( @all_holds, 0, 50 );
}

$template->param(
    holdshistoryview => 1,
    patron           => $patron,
    holds            => \@all_holds,
    unlimit          => $unlimit,
    sort             => $sort
);

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
