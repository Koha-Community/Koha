#!/usr/bin/perl

# Copyright 2017 BibLibre
#
# This file is part of Koha
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;

use C4::Auth;
use C4::Output;

my $cgi = new CGI;

my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => 'catalogue/itemsearch_csv.tt',
    query => $cgi,
    type => 'intranet',
    authnotrequired => 0,
    flagsrequired   => { catalogue => 1 },
});

my @itemnumbers = $cgi->multi_param('itemnumber');
my $format = $cgi->param('format') // 'csv';

my @items = Koha::Items->search({ itemnumber => { -in => \@itemnumbers } });

if ($format eq 'barcodes') {
    print $cgi->header({
        type => 'text/plain',
        attachment => 'barcodes.txt',
    });

    foreach my $item (@items) {
        print $item->barcode . "\n";
    }
    exit;
}

$template->param(
    results => \@items,
);

print $cgi->header({
    type => 'text/csv',
    attachment => 'items.csv',
});
for my $line ( split '\n', $template->output ) {
    print "$line\n" unless $line =~ m|^\s*$|;
}
