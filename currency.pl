#!/usr/bin/perl

# $Id$

#written by chris@katipo.co.nz
#9/10/2000
#script to display and update currency rates


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

# FIXME - There's an "admin/currency.pl", and this script never seems
# to be used. Is it obsolete?

use CGI;
use C4::Auth;
use C4::Acquisitions;
use C4::Biblio;

my $input=new CGI;

# Authentication script added, superlibrarian set as default requirement

my $flagsrequired;
$flagsrequired->{superlibrarian}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);


my $type=$input->param('type');
#find out what the script is being called for
#print $input->header();
if ($type ne 'change'){
  #display, we must fetch the exchange rate data and output it
  print $input->header();
  print <<printend
  <TABLE width="40%" cellspacing=0 cellpadding=5 border=1 >
  <FORM ACTION="/cgi-bin/koha/currency.pl">
  <input type=hidden name=type value=change>
  <TR VALIGN=TOP>
  <TD  bgcolor="99cc33" background="/images/background-mem.gif" colspan=2 ><b>EXCHANGE RATES </b></TD></TR>
  <TR VALIGN=TOP>
  <TD>
printend
;
  my ($count,$rates)=getcurrencies();
  for (my $i=0;$i<$count;$i++){
    if ($rates->[$i]->{'currency'} ne 'NZD'){
      print "$rates->[$i]->{'currency'}<INPUT TYPE=\"text\"  SIZE=\"5\"   NAME=\"$rates->[$i]->{'currency'}\" value=$rates->[$i]->{'rate'}>";
    }
#    print $rates->[$i]->{'currency'};
  }
  print <<printend
    <p>
  <input type=image  name=submit src=/images/save-changes.gif border=0 width=187 height=42>

  </TD></TR>
  </form>
  </table>
printend
;
} else {
#  print $input->Dump;
  my @params=$input->param;
  foreach my $param (@params){
    if ($param ne 'type' && $param !~ /submit/){
      my $data=$input->param($param);
      updatecurrencies($param,$data);
    }
  }
  print $input->redirect('/acquisitions/');
}
