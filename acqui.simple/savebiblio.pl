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

use CGI;
use strict;
# use C4::Catalogue;
use C4::Biblio;

my $input  = new CGI;
my $biblio = {
    title    => $input->param('title'),
    subtitle => $input->param('subtitle') ? $input->param('subtitle') : "",
    author   => $input->param('author') ? $input->param('author') : "",
    seriestitle => $input->param('seriestitle') ? $input->param('seriestitle')
    : "",
    copyrightdate => $input->param('copyrightdate')
    ? $input->param('copyrightdate')
    : "",
    abstract => $input->param('abstract') ? $input->param('abstract') : "",
    notes    => $input->param('notes')    ? $input->param('notes')    : ""
};    # my $biblio

my $subjectheadings = $input->param('subjectheadings');
my @subjects = split ( /\n/, $subjectheadings );
my $biblionumber;
my $aauthors = $input->param('additionalauthors');
my @authors  = split ( /\n/, $aauthors );
my $force    = $input->param('force');

if ( !$biblio->{'title'} ) {
    print $input->redirect('addbiblio-nomarc.pl?error=notitle');
}
else {
    $biblionumber = &newbiblio($biblio);
    &newsubtitle( $biblionumber, $biblio->{'subtitle'} );
    my $error = modsubject( $biblionumber, 1, @subjects );
    modaddauthor( $biblionumber, @authors );
    print $input->redirect("additem-nomarc.pl?biblionumber=$biblionumber");
}    # else
