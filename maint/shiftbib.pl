#!/usr/bin/perl

#script to do some serious catalogue maintainance
#written 22/11/00
# by chris@katipo.co.nz

use strict;
use CGI;
use C4::Output;
use C4::Database;
use C4::Maintainance;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
my $bi=$input->param('bi');
my $bib=$input->param('bib');
my $type=$input->param('type');
print startpage();
print startmenu('catalog');

if ($type eq 'change'){
  my $biblionumber=$input->param('biblionumber');
  my $dbh=C4Connect;
  my $query="Select * from biblio where biblionumber=$biblionumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  print "Shifting group $bi to biblio $biblionumber<br>
  Title:$data->{'title'}<br>
  Author:$data->{'author'}<p>
  Are you sure?
  <p>
  ";
  print "<a href=/cgi-bin/koha/maint/shiftbib.pl?type=update&bi=$bi&bib=$biblionumber>Yes</a>";
} elsif ($type eq 'update'){
  shiftgroup($bib,$bi);
  print "Shifted";
} else {
  print "Shifting Group $bi from biblio $bib to <p>";
  print "<form action=/cgi-bin/koha/maint/shiftbib.pl method=post>";
  print "<input  name=bi type=hidden value=$bi>";
  print "<input type=hidden name=type value=change>";
  print "<input type=text name=biblionumber><br>";
  print "<input type=submit value=change></form>";
}
print endmenu('catalog');
print endpage();
