#!/usr/bin/perl

use strict;
use C4::Acquisitions;
use CGI;

my $input = new CGI;
my $biblionumber  = $input->param('biblionumber');
my $websitenumber = $input->param('websitenumber');
my $website       = {
    biblionumber  => $biblionumber,
    websitenumber => $websitenumber,
    title         => $input->param('title')?$input->param('title'):"",
    description   => $input->param('description')?$input->param('description'):"",
    url           => $input->param('url')?$input->param('url'):""
}; # my $website


if ($input->param('delete')) {
    print $input->redirect("deletewebsite.pl?biblionumber=$biblionumber&websitenumber=$websitenumber");

} elsif (! $biblionumber) {
    print $input->redirect("/catalogue/");
    
} elsif (! $websitenumber) {
    print $input->redirect("modwebsites.pl?biblionumber=$biblionumber");

} else {
    &updatewebsite($website);

    print $input->redirect("modwebsites.pl?biblionumber=$biblionumber");
} # else
