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
print startpage();
print startmenu('catalog');
my $blah;
my $num=0;
my $offset=0;
if ($type eq 'allsub'){
  my $sub=$input->param('sub');
  my ($count,$results)=listsubjects($sub,$num,$offset);
  for (my $i=0;$i<$count;$i++){
    my $sub2=$results->[$i]->{'subject'};
    $sub2=~ s/ /%20/g;
    print "\"<a href=\"/cgi-bin/koha/maint/catmaintain.pl?type=allsub&sub=$sub\" onclick=\'messenger(\"/cgi-bin/koha/maint/catmaintain.pl?type=modsub&sub=$sub2\");window1.focus()\'>$results->[$i]->{'subject'}\"</a><br>\n";
  }
} elsif ($type eq 'modsub'){
  my $sub=$input->param('sub');
  print "<form action=/cgi-bin/koha/maint/catmaintain.pl>";
  print "Subject:<input type=text value=\"$sub\" name=sub size=40><br>\n";
  print "<input type=hidden name=type value=upsub>";
  print "<input type=hidden name=oldsub value=\"$sub\">";
  print "<input type=submit value=modify>";
#  print "<a href=\"nowhere\" onclick=\"document.forms[0].submit();\">Modify</a>";
  print "</form>";
  print "<p> This will change the subject headings on all the biblios this subject is applied to"
} elsif ($type eq 'upsub'){
  my $sub=$input->param('sub');
  my $oldsub=$input->param('oldsub');
  updatesub($sub,$oldsub);
  print "Successfully modified $oldsub is now $sub";
  print "<p><a href=/cgi-bin/koha/maint/catmaintain.pl target=window0 onclick=\"window0.focus()\">Back to catalogue maintenance</a><br>";
  print "<a href=nowhere onclick=\"self.close()\">Close this window</a>";
} elsif ($type eq 'undel'){
  my $title=$input->param('title');
  my ($count,$results)=deletedbib($title);
  print "<table border=0>";
  print "<tr><td><b>Title</b></td><td><b>Author</b></td><td><b>Undelete</b></td></tr>";
  for (my $i=0;$i<$count;$i++){
    print "<tr><td>$results->[$i]->{'title'}</td><td>$results->[$i]->{'author'}</td><td><a href=/cgi-bin/koha/maint/catmaintain.pl?type=finun&bib=$results->[$i]->{'biblionumber'}>Undelete</a></td>\n";
  }
  print "</table>";
} elsif ($type eq 'finun'){
  my $bib=$input->param('bib');
  undeletebib($bib);
  print "Succesfully undeleted";
  print "<p><a href=/cgi-bin/koha/maint/catmaintain.pl>Back to Catalogue Maintenance</a>";
} elsif ($type eq 'fixitemtype'){
  my $bi=$input->param('bi');
  my $item=$input->param('item');
  print "<form method=post action=/cgi-bin/koha/maint/catmaintain.pl>";
  print "<input type=hidden name=bi value=$bi>";
  print "<input type=hidden name=type value=updatetype>";
  print "Itemtype:<input type=text name=itemtype value=$item><br>\n";
  print "<input type=submit value=Change>";
  print "</form>";
} elsif ($type eq 'updatetype'){
  my $bi=$input->param('bi');
  my $itemtype=$input->param('itemtype');
  updatetype($bi,$itemtype);
  print "Updated successfully";
  print "<p><a href=/cgi-bin/koha/maint/catmaintain.pl>Back to Catalogue Maintenance</a>";
} else {
  print "<B>Subject Maintenance</b><br>";
  print "<form action=/cgi-bin/koha/maint/catmaintain.pl method=post>";
  print "<input type=hidden name=type value=allsub>";
  print "Show all subjects beginning with <input type=text name=sub><br>";
  print "<input type=submit value=Show>";
  print "</form>";
  print "<p>";
  print "<B>Group Maintenance</b></br>";
  print "<form action=/cgi-bin/koha/search.pl method=post>";
  print "<input type=hidden name=type value=catmain>";
  print "Show all Titles beginning with <input type=text name=title><br>";
  print "<input type=submit value=Show>";
  print "</form>";
  print "<p>";
  print "<B>Undelete Biblio</b></br>";
  print "<form action=/cgi-bin/koha/maint/catmaintain.pl method=post>";
  print "<input type=hidden name=type value=undel>";
  print "Show all Titles beginning with <input type=text name=title><br>";
  print "<input type=submit value=Show>";
  print "</form>";
}
print endmenu('catalog');
print endpage();
