#!/usr/bin/perl

#written 27/01/2000
#script to display borrowers reading record



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
my $input=new CGI;


my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);
my $order=$input->param('order');
my $order2=$order;
if ($order2 eq ''){
  $order2="date_due desc";
}
my $limit=$input->param('limit');
if ($limit eq 'full'){
  $limit=0;
} else {
  $limit=50;
}
my ($count,$issues)=allissues($bornum,$order2,$limit);


print $input->header;
print startpage();
print startmenu('member');
#print $count;
print mkheadr(3,"$data->{'title'} $data->{'initials'} $data->{'surname'}");
print mktablehdr();
print mktablerow(1,'white',"<a href=/cgi-bin/koha/readingrec.pl?bornum=$bornum&limit=full>Full output</a>");
print mktablerow(4,'white',"<a href=/cgi-bin/koha/readingrec.pl?bornum=$bornum&order=title&limit=$limit><b>TITLE</b></a>","<a href=/cgi-bin/koha/readingrec.pl?bornum=$bornum&order=author&limit=$limit><b>AUTHOR</b></a>","<a href=/cgi-bin/koha/readingrec.pl?bornum=$bornum&limit=$limit><b>DATE</b></a>","<b>Volume</b>");
for (my $i=0;$i<$count;$i++){
  print mktablerow(4,'white',$issues->[$i]->{'title'},$issues->[$i]->{'author'},$issues->[$i]->{'returndate'},$issues->[$i]->{'volumeddesc'});
}
print mktableft();
print endmenu('member');
print endpage();

