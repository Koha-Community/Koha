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
use CGI        qw ( -utf8 );
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

my $scheme = C4::Context->preference('SpineLabelFormat');
my $query  = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "labels/spinelabel-print.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { catalogue => 1 },
    }
);

my $barcode = $query->param('barcode');

my $dbh = C4::Context->dbh;
my $sth;

my $item;

my $sql = "SELECT * FROM biblio, biblioitems, items 
          WHERE biblio.biblionumber = items.biblionumber 
          AND biblioitems.biblioitemnumber = items.biblioitemnumber 
          AND items.barcode = ?";
$sth = $dbh->prepare($sql);
$sth->execute($barcode);
$item = $sth->fetchrow_hashref;

$template->param(
    Barcode         => $barcode,
    BarcodeNotFound => 1,
) unless defined $item;

my $body;

my $data;
while ( my ( $key, $value ) = each(%$item) ) {
    $data->{$key} .= "<span class='field' id='$key'>";

    $value = '' unless defined $value;
    my @characters   = split( //, $value );
    my $charnum      = 1;
    my $wordernumber = 1;
    my $i            = 1;
    foreach my $char (@characters) {
        if ( $char ne ' ' ) {
            $data->{$key} .= "<span class='character word$wordernumber character$charnum' id='$key$i'>$char</span>";
        } else {
            $data->{$key} .= "<span class='space character$charnum' id='$key$i'>$char</span>";
            $wordernumber++;
            $charnum = 1;
        }
        $charnum++;
        $i++;
    }

    $data->{$key} .= "</span>";
}

while ( my ( $key, $value ) = each(%$data) ) {
    $scheme =~ s/<$key>/$value/g;
}

$body = $scheme;

$template->param(
    autoprint         => C4::Context->preference("SpineLabelAutoPrint"),
    content           => $body,
    itemholdingbranch => $item->{holdingbranch},
    itemhomebranch    => $item->{homebranch},
);

output_html_with_http_headers $query, $cookie, $template->output;
