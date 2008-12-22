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
use CGI qw/:standard/;

use C4::Context;
use C4::Circulation;
use C4::Output;
use C4::Auth;
use C4::Print;
use C4::Koha;
use C4::Branch; # GetBranches

# this is a reorganisation of circulationold.pl
# dividing it up into three scripts......
# this will be the first one that chooses branch and printer settings....

#general design stuff...

# try to get the branch and printer settings from the http....
my $query    = new CGI;
my $branches = GetBranches();
my $printers = GetPrinters();
my $branch   = $query->param('branch');
my $printer  = $query->param('printer');

# set header with cookie....

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/selectbranchprinter.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);


($branch)  || ( $branch  = C4::Context->userenv->{'branch'} );
($printer) || ( $printer = C4::Context->userenv->{'branchprinter'} );
( $branches->{$branch} )  || ( $branch  = ( keys %$branches )[0] );
( $printers->{$printer} ) || ( $printer = ( keys %$printers )[0] );

# if you force a selection....
my $oldbranch  = $branch;
my $oldprinter = $printer;

# set up select options....
my $branchcount  = 0;
my $printercount = 0;
my @branchloop;
for my $br (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    next unless $br =~ /\S/; # next unless $br is not blank.

    $branchcount++;
    my %branch;
    $branch{selected} = ( $br eq $oldbranch );
    $branch{name}     = $branches->{$br}->{'branchname'};
    $branch{value}    = $br;
    push( @branchloop, \%branch );
}
my @printerloop;
foreach ( keys %$printers ) {
    (next) unless ($_); # next unless if this printer is blank.
    $printercount++;
    my %printer;
    $printer{selected} = ( $_ eq $oldprinter );
    $printer{name}     = $printers->{$_}->{'printername'};
    $printer{value}    = $_;
    push( @printerloop, \%printer );
}

# if there is only one....
my $printername;
my $branchname;

my $oneprinter = ( $printercount == 1 );
my $onebranch  = ( $branchcount == 1 );
if ( $printercount == 1 ) {
    my ($tmpprinter) = keys %$printers;
    $printername = $printers->{$tmpprinter}->{printername};
}
if ( $branchcount == 1 ) {
    my ($tmpbranch) = keys %$branches;
    $branchname = $branches->{$tmpbranch}->{branchname};
}

################################################################################
# Start writing page....

$template->param(
    oneprinter              => $oneprinter,
    onebranch               => $onebranch,
    printername             => $printername,
    branchname              => $branchname,
    printerloop             => \@printerloop,
    branchloop              => \@branchloop,
);

output_html_with_http_headers $query, $cookie, $template->output;
