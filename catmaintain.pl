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
    print "\"<a href=\"/cgi-bin/koha/catmaintain.pl?type=allsub&sub=$sub\" onclick=\'messenger(\"/cgi-bin/koha/catmaintain.pl?type=modsub&sub=$sub2\");window1.focus()\'>$results->[$i]->{'subject'}\"</a><br>\n";
  }
} elsif ($type eq 'modsub'){
  my $sub=$input->param('sub');
  print "<form action=/cgi-bin/koha/catmaintain.pl>";
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
  print "<p><a href=/cgi-bin/koha/catmaintain.pl target=window0 onclick=\"window0.focus()\">Back to catalogue maintenance</a><br>";
  print "<a href=nowhere onclick=\"self.close()\">Close this window</a>";
} else {
  print "<form action=/cgi-bin/koha/catmaintain.pl method=post>";
  print "<input type=hidden name=type value=allsub>";
  print "Show all subjects beginning with <input type=text name=sub><br>";
  print "<input type=submit value=Show>";
  print "</form>";
}
print endmenu('catalog');
print endpage();
