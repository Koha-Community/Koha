#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;

my $input = new CGI;
my $biblio = {
    title       => $input->param('title'),
    subtitle    => $input->param('subtitle')?$input->param('subtitle'):"",
    author      => $input->param('author')?$input->param('author'):"",
    seriestitle => $input->param('seriestitle')?$input->param('seriestitle'):"",
    copyright   => $input->param('copyrightdate')?$input->param('copyrightdate'):"",
    abstract    => $input->param('abstract')?$input->param('abstract'):"",
    notes       => $input->param('notes')?$input->param('notes'):""
}; # my $biblio
my $biblionumber;

if (! $biblio->{'title'}) {
    print $input->redirect('addbiblio.pl?error=notitle');
} else {

    $biblionumber = &newbiblio($biblio);
    &newsubtitle($biblionumber, $biblio->{'subtitle'});

    print $input->redirect("addbiblioitem.pl?biblionumber=$biblionumber");
} # else
