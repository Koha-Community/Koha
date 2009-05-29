#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
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

use strict;
use warnings;
use CGI;

use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Print;  # GetPrinters
use C4::Koha;
use C4::Branch; # GetBranches GetBranchesLoop

# this will be the script that chooses branch and printer settings....

my $query = CGI->new();
my ( $template, $borrowernumber, $cookie ) = get_template_and_user({
    template_name   => "circ/selectbranchprinter.tmpl",
    query           => $query,
    type            => "intranet",
    debug           => 1,
    authnotrequired => 0,
    flagsrequired   => { circulate => "circulate_remaining_permissions" },
});

# try to get the branch and printer settings from http, fallback to userenv
my $branches = GetBranches();
my $printers = GetPrinters();
my $branch   = $query->param('branch' ) || C4::Context->userenv->{'branch'}; 
my $printer  = $query->param('printer') || C4::Context->userenv->{'branchprinter'};

unless ($branches->{$branch}) {
    $branch = (keys %$branches)[0];  # if branch didn't really exist, then replace it w/ one that does
}

my @printkeys = sort keys %$printers;
if (scalar(@printkeys) == 1 or not $printers->{$printer}) {
    $printer = $printkeys[0];
}

my @printerloop;
foreach ( @printkeys ) {
    next unless ($_); # skip printer if blank.
    push @printerloop, {
        selected => ( $_ eq $printer ),
        name     => $printers->{$_}->{'printername'},
        value    => $_,
    };
}

my @recycle_loop;
foreach ($query->param()) {
    /^branch(printer)?$/ and next;  # disclude branch and branchprinter
    push @recycle_loop, {
        param => $_,
        value => $query->param($_),
    };
}

$template->param(
    referer     => $ENV{HTTP_REFERER},
    printerloop => \@printerloop,
    branchloop  => GetBranchesLoop($branch),
    recycle_loop=> \@recycle_loop,
);

output_html_with_http_headers $query, $cookie, $template->output;
