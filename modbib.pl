#!/usr/bin/perl

# $Id$

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 12/16/2002 by hdl@ifrance.com : templating


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

use C4::Search;
use CGI;
use C4::Output;
use HTML::Template;

my $input = new CGI;

my $bibnum=$input->param('bibnum');
my $data=&bibdata($bibnum);
my ($subjectcount, $subject)     = &subject($data->{'biblionumber'});
my ($subtitlecount, $subtitle)   = &subtitle($data->{'biblionumber'});
my ($addauthorcount, $addauthor) = &addauthor($data->{'biblionumber'});
my $sub        = $subject->[0]->{'subject'};
my $additional = $addauthor->[0]->{'author'};
my $dewey;
my $submit=$input->param('submit.x');
if ($submit eq '') {
  print $input->redirect("/cgi-bin/koha/delbiblio.pl?biblio=$bibnum");
} # if

#print $input->header;
# my ($analytictitle)  = &analytic($biblionumber,'t');
# my ($analyticauthor) = &analytic($biblionumber,'a');
#print startpage();
#print startmenu('catalogue');
my $template = gettemplate("modbib.tmpl");

# have to get all subtitles, subjects and additional authors
$sub = join("|", map { $_->{'subject'} } @{$subject});

$additional = join("|", map { $_->{'author'} } @{$addauthor});

$dewey = $data->{'dewey'};
$dewey =~ s/0+$//;
if ($dewey eq "000.") {
    $dewey = "";
} # if
if ($dewey < 10) {
    $dewey = '00' . $dewey;
} # if
if ($dewey < 100 && $dewey > 10) {
    $dewey = '0' . $dewey;
} # if
if ($dewey <= 0){
  $dewey='';
} # if
$dewey = ~ s/\.$//;

$data->{'title'} = &tidyhtml($data->{'title'});

$template->param ( biblionumber => $data->{'biblionumber'});
$template->param ( biblioitemnumber => $data->{'biblioitemnumber'});
$template->param ( author => $data->{'author'});
$template->param ( title => $data->{'title'});
$template->param ( abstract => $data->{'abstract'});
$template->param ( subject => $sub);
$template->param ( copyrightdate => $data->{'copyrightdate'});
$template->param ( seriestitle => $data->{'seriestitle'});
$template->param ( additionalauthor => $additional);
$template->param ( subtitle => $data->{'subtitle'});
$template->param ( untitle => $data->{'untitle'});
$template->param ( notes => $data->{'notes'});
$template->param ( serial => $data->{'serial'});

print "Content-Type: text/html\n\n", $template->output;

sub tidyhtml {
  my ($inp)=@_;
  $inp=~ s/\"/\&quot\;/g;
  return($inp);
}
