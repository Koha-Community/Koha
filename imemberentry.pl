#!/usr/bin/perl
# NOTE: standard 8-space tabs here

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
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Members;
use C4::Date;

my $input = new CGI;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/imemberentry.tmpl",
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

my $cardnumber=C4::Members::fixup_cardnumber($data->{'cardnumber'});

my @branches;
my @select_branch;
my %select_branches;
my $branches=getbranches();
foreach my $branch (keys %$branches) {
	push @select_branch, $branch;
  	$select_branches{$branch} = $branches->{$branch}->{'branchname'};
}
my $CGIbranch=CGI::scrolling_list( -name     => 'branchcode',
			-values   => \@select_branch,
			-default  => $data->{'branchcode'},
			-labels   => \%select_branches,
			-size     => 1,
			-multiple => 0 );

$template->param(member => $member,
				member          => $member,
				address         => $data->{'streetaddress'},
				firstname       => $data->{'firstname'},
				surname         => $data->{'surname'},
				othernames	=> $data->{'othernames'},
				streetaddress   => $data->{'streetaddress'},
				streetcity      => $data->{'streetcity'},
				zipcode => $data->{'zipcode'},
				homezipcode => $data->{'homezipcode'},
				city		=> $data->{'city'},
				phone           => $data->{'phone'},
				phoneday        => $data->{'phoneday'},
				faxnumber       => $data->{'faxnumber'},
				emailaddress    => $data->{'emailaddress'},
				textmessaging   => $data->{'textmessaging'},
				contactname     => $data->{'contactname'},
				altphone        => $data->{'altphone'},
				altnotes	=> $data->{'altnotes'},
				borrowernotes	=> $data->{'borrowernotes'},
				"title_".$data->{'title'} => " SELECTED ",
				dateenrolled	=> $data->{'dateenrolled'},
				expiry		=> $data->{'expiry'},
				cardnumber	=> $cardnumber,
				dateofbirth	=> $data->{'dateofbirth'},
				dateformat      => display_date_format(),
				cardnumber_institution => $cardnumber,
				CGIbranch => $CGIbranch);

output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 8
# End:
