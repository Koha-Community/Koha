#!/usr/bin/perl

#script to do a borrower enquiery/brin up borrower details etc
#written 20/12/99 by chris@katipo.co.nz


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
use C4::Output;
use CGI;
use C4::Search;


my $input = new CGI;
my $member=$input->param('member');
$member=~ s/\,//g;
print $input->header;
#start the page and read in includes
print startpage();
print startmenu('member');
my @inputs=(["text","member",$member],
            ["reset","reset","clr"]);
print mkheadr(2,'Member Search');
print mkformnotable("/cgi-bin/koha/member.pl",@inputs);
print <<printend 

printend
;
print "You Searched for $member<p>";
print mktablehdr;
print mktablerow(8,'#99cc33',bold('Card'),bold('Surname'),bold('Firstname'),bold('Category')
,bold('Address'),bold('OD/Issues'),bold('Charges'),bold('Notes'),'/images/background-mem.gif');
my $env;
my ($count,$results)=BornameSearch($env,$member,'web');
#print $count;
my $toggle="white";
for (my $i=0; $i < $count; $i++){
  #find out stats
  my ($od,$issue,$fines)=borrdata2($env,$results->[$i]{'borrowernumber'});
  $fines=$fines+0;
  if ($toggle eq 'white'){
    $toggle="#ffffcc";
  } else {
    $toggle="white";
  }
  #mklink("/cgi-bin/koha/memberentry.pl?bornum=".$results->[$i]{'borrowernumber'},$results->[$i]{'cardnumber'}),
  print mktablerow(8,$toggle,mklink("/cgi-bin/koha/moremember.pl?bornum=".$results->[$i]{'borrowernumber'},$results->[$i]{'cardnumber'}),
  $results->[$i]{'surname'},$results->[$i]{'firstname'},
  $results->[$i]{'categorycode'},$results->[$i]{'streetaddress'}." ".$results->[$i]{'city'},"$od/$issue",$fines,
  $results->[$i]{'borrowernotes'});
}
print mktableft;
print <<printend
<form action=/cgi-bin/koha/simpleredirect.pl method=post>
<input type=image src="/images/button-add-member.gif"  WIDTH=188  HEIGHT=44  ALT="Add New Member" BORDER=0 ></a><br>
<INPUT TYPE="radio" name="chooseform" value="adult" checked>Adult
<INPUT TYPE="radio" name="chooseform" value="organisation" >Organisation
</form>
printend
;
print endmenu('member');
print endpage();
