#!/usr/bin/perl

#script to do some serious catalogue maintainance
#written 22/11/00
# by chris@katipo.co.nz


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
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Maintainance;
use HTML::Template;

my $input = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name   => 'maint/catmaintain.tmpl',
                             query           => $input,
                             type            => 'intranet',
                             authnotrequired => 0,
                             flagsrequired   => {catalogue => 1},
                             debug           => 1,
                             });

my %params = ();


my $type=$input->param('type');
my $blah;
my $num=0;
my $offset=0;
if ($type eq 'allsub'){
  my $sub=$input->param('sub');
  my ($count,$results)=listsubjects($sub,$num,$offset);
  my @it = ();
  for (my $i=0;$i<$count;$i++){
    my $sub2=$results->[$i]->{'subject'};
    push @it, {'sub2' => $sub2, 'subject' => $results->[$i]->{'subject'}};
  }
  %params = ('sub' => $sub, 'loop' => \@it);

} elsif ($type eq 'modsub'){
  %params = ('sub' => $input->param('sub'));

} elsif ($type eq 'upsub'){
  my $sub=$input->param('sub');
  my $oldsub=$input->param('oldsub');
  updatesub($sub,$oldsub);
  %params = ('sub' => $sub, 'oldsub' => $oldsub);

} elsif ($type eq 'undel'){
  my $title=$input->param('title');
  my ($count,$results)=deletedbib($title);
  my @it = ();
  for (my $i=0;$i<$count;$i++){
    push @it, {
	'title'    => $results->[$i]->{'title'},
	'author'   => $results->[$i]->{'author'},
	'undelete' => "type=finun&bib=$results->[$i]->{'biblionumber'}",
      };
  }
  %params = ('loop' => \@it);

} elsif ($type eq 'finun'){
  my $bib=$input->param('bib');
  undeletebib($bib);

} elsif ($type eq 'fixitemtype'){
  my $bi=$input->param('bi');
  my $item=$input->param('item');
  %params = ('bi' => $bi, 'item' => $item);

} elsif ($type eq 'updatetype'){
  my $bi=$input->param('bi');
  my $itemtype=$input->param('itemtype');
  updatetype($bi,$itemtype);

} else {
  $type = 'mainmenu'; # NOTE

}

$template->param(type => 'intranet',
                "$type-p" => 1,
                 %params);

output_html_with_http_headers $input, $cookie, $template->output;
