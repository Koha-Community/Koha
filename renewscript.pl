#!/usr/bin/perl

# $Id$

#written 18/1/2000 by chris@katipo.co.nz
#script to renew items from the web


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
# use C4::Circulation::Renewals2;
use C4::Circulation::Circ2;
#get input
my $input= new CGI;
#print $input->header;

#print $input->dump;

my @names=$input->param();
my $count=@names;
my %data;

for (my $i=0;$i<$count;$i++){
  if ($names[$i] =~ /renew/){
    my $temp=$names[$i];
    $temp=~ s/renew_item_//;
    $data{$temp}=$input->param($names[$i]);
  }
}
my %env;
my $bornum=$input->param("bornum");
while ( my ($itemno, $value) = each %data) {
#    warn "$itemno = $value\n";
   if ($value eq 'y'){
     #means we want to renew this item
     #check its status
     my $status=renewstatus(\%env,$bornum,$itemno);
# 	 warn "STATUS : $status";
     if ($status == 1){
       renewbook(\%env,$bornum,$itemno);
     }
   }
}

print $input->redirect("/cgi-bin/koha/members/moremember.pl?bornum=$bornum");
