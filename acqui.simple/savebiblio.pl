#!/usr/bin/perl

use CGI;
use strict;
use C4::Acquisitions;

my $input = new CGI;
my $biblio->{'title'}       = $input->param('title');
my $biblio->{'subtitle'}    = $input->param('subtitle');
my $biblio->{'author'}      = $input->param('author');
my $biblio->{'seriestitle'} = $input->param('seriestitle');
my $biblio->{'copyright'}   = $input->param('copyrightdate');
my $biblio->{'abstract'}    = $input->param('abstract');
my $biblio->{'notes'}       = $input->param('notes');
my $biblionumber;

if (! $biblio->{'title'}) {
    print $input->redirect('addbiblio.pl?error=notitle');
} else {

    $biblionumber = &newbiblio($biblio);
    &newsubtitle($biblionumber, $subtitle);

    print $input->redirect('addbiblioitem.pl?biblionumber=$biblionumber');
} # else
