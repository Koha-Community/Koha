#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use warnings;
use strict;
use CGI;
use C4::Auth;
use C4::Output;

my $scheme = C4::Context->preference('SpineLabelFormat');
my $query  = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "labels/spinelabel-print.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
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

unless (defined $item) {
  $template->param( 'Barcode' => $barcode );
  $template->param( 'BarcodeNotFound' => 1 );
}

my $body;

my $data;
while ( my ( $key, $value ) = each(%$item) ) {
    $data->{$key} .= "<span class='field' id='$key'>";

    $value = '' unless defined $value;
    my @characters = split( //, $value );
    my $charnum    = 1;
    my $wordnum    = 1;
    my $i          = 1;
    foreach my $char (@characters) {
        if ( $char ne ' ' ) {
            $data->{$key} .= "<span class='character word$wordnum character$charnum' id='$key$i'>$char</span>";
        } else {
            $data->{$key} .= "<span class='space character$charnum' id='$key$i'>$char</span>";
            $wordnum++;
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

$template->param( autoprint => C4::Context->preference("SpineLabelAutoPrint") );
$template->param( content   => $body );

output_html_with_http_headers $query, $cookie, $template->output;
