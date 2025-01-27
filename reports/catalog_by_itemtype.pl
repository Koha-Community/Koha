#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Auth qw( get_template_and_user );
use CGI      qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );

my $input          = CGI->new;
my $report_name    = $input->param("report_name");
my $do_it          = $input->param('do_it');
my $fullreportname = "reports/itemtypes.tt";
my @values         = $input->multi_param("value");
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => $fullreportname,
        query         => $input,
        type          => "intranet",
        flagsrequired => { reports => '*' },
    }
);
$template->param(
    do_it => $do_it,
);
if ($do_it) {
    my $results = calculate( \@values );
    $template->param( mainloop => $results );
}
output_html_with_http_headers $input, $cookie, $template->output;

sub calculate {
    my ($parameters) = @_;
    my @results      = ();
    my $branch       = @$parameters[0];
    my $dbh          = C4::Context->dbh;
    my $sth;
    if ( C4::Context->preference('item-level_itypes') ) {
        $sth = $dbh->prepare(
            q|
            SELECT itemtypes.itemtype, description, COUNT(*) AS total
            FROM itemtypes, items
            WHERE items.itype=itemtypes.itemtype
            | . ( $branch ? q| AND items.holdingbranch=? | : () ) . q|
            GROUP BY itemtypes.itemtype, description, items.itype
            ORDER BY itemtypes.description
        |
        );
    } else {
        $sth = $dbh->prepare(
            q|
            SELECT itemtypes.itemtype, description, COUNT(*) AS total
            FROM itemtypes, biblioitems, items
            WHERE biblioitems.itemtype=itemtypes.itemtype
            AND items.biblioitemnumber=biblioitems.biblioitemnumber
            | . ( $branch ? q| AND items.holdingbranch=? | : () ) . q|
            GROUP BY itemtypes.itemtype, description
            ORDER BY itemtypes.description
        |
        );
    }
    $sth->execute( $branch || () );
    my ( $itemtype, $description, $total );
    my $grantotal = 0;
    my $count     = 0;
    while ( ( $itemtype, $description, $total ) = $sth->fetchrow ) {
        my %line;
        $line{itemtype} = $itemtype;
        $line{count}    = $total;
        $grantotal += $total;
        push @results, \%line;
        $count++;
    }
    my @mainloop;
    my %globalline;
    $globalline{loopitemtype} = \@results;
    $globalline{total}        = $grantotal;
    $globalline{branch}       = $branch;
    push @mainloop, \%globalline;
    return \@mainloop;
}

1;
