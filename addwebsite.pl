#!/usr/bin/perl

use strict;
use C4::Acquisitions;
use CGI;

my $input = new CGI;
my $biblionumber = $input->param('biblionumber');
my $website      = {
    biblionumber => $biblionumber,
    title        => $input->param('title')?$input->param('title'):"",
    description  => $input->param('description')?$input->param('description'):"",
    url          => $input->param('url')?$input->param('url'):""
}; # my $website


if (! $biblionumber) {
    print $input->redirect("/catalogue/");

} else {
    &addwebsite($website);

    print $input->redirect("modwebsites.pl?biblionumber=$biblionumber");
} # else
