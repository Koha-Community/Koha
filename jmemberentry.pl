#!/usr/bin/perl

#script to set up screen for modification of borrower details
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
use C4::Auth;
use C4::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::Interface::CGI::Output;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/jmemberentry.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $member=$input->param('bornum');
if ($member eq ''){
  $member=NewBorrowerNumber();
}
my $type=$input->param('type');

my $data=borrdata('',$member);

my @titles = ('Miss', 'Mrs', 'Ms', 'Mr', 'Dr', 'Sir');
	# FIXME - Assumes English. This ought to be made part of i18n.
my @titledata;
while (@titles) {
  my $title = shift @titles;
  my %row = ('title' => $title);
  if ($data->{'title'} eq $title) {
    $row{'selected'}=' selected';
  } else {
    $row{'selected'}='';
  }
  push(@titledata, \%row);
}

# get the data for children
my $cmember1=NewBorrowerNumber();
my @cmemdata;
for (my $i=0;$i<3;$i++){
  my %row;
  $row{'cmember'}=$cmember1+$i;
  $row{'i'}=$i;
  $row{'count'}=$i+1;
  push(@cmemdata, \%row);
}


$template->param( startmenumember => join('', startmenu('member')),
			 endmenumember   => join('', endmenu('member')),
			endmenumember   => endmenu('member'),
			member         => $member,
			firstname       => $data->{'firstname'},
			surname         => $data->{'surname'},
			cardnumber      => $data->{'cardnumber'},
			area            => $data->{'area'},
			city            => $data->{'city'},
			address         => $data->{'address'},
			streetaddress   => $data->{'streetaddress'},
			streetcity      => $data->{'streetcity'},
			phone           => $data->{'phone'},
			phoneday        => $data->{'phoneday'},
			faxnumber       => $data->{'faxnumber'},
			emailaddress    => $data->{'emailaddress'},
			contactname     => $data->{'contactname'},
			altphone        => $data->{'altphone'},
			titleloop       => \@titledata,
			cmemloop        => \@cmemdata );

output_html_with_http_headers $input, $cookie, $template->output;
