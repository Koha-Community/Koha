#!/usr/bin/perl

use strict;
use C4::Acquisitions;
use CGI;

my $input = new CGI;
my $biblionumber  = $input->param('biblionumber');
my $websitenumber = $input->param('websitenumber');

if (! $biblionumber) {
    print $input->redirect("/catalogue/");

} elsif (! $websitenumber) {
    print $input->param("modwebsite.pl?biblionumber=$biblionumber");

} else {
    &deletewebsite($websitenumber);

    print $input->redirect("modwebsites.pl?biblionumber=$biblionumber");
} # else
