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
use C4::Auth;
use C4::Output;
use CGI;
use C4::Members;


my $input = new CGI;
my $quicksearch = $input->param('quicksearch');
my ($template, $loggedinuser, $cookie);
if($quicksearch){
    ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member-quicksearch-results.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 1},
                 debug => 1,
                 });
} else {
    ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "members/member.tmpl",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {borrowers => 1},
                 debug => 1,
                 });
}
my $theme = $input->param('theme') || "default";
            # only used if allowthemeoverride is set
#my %tmpldata = pathtotemplate ( template => 'member.tmpl', theme => $theme, language => 'fi' );
    # FIXME - Error-checking
#my $template = HTML::Template->new( filename => $tmpldata{'path'},
#                   die_on_bad_params => 0,
#                   loop_context_vars => 1 );


my $member=$input->param('member');
my $orderby=$input->param('orderby');
$orderby = "surname,firstname" unless $orderby;
$member =~ s/,//g;   #remove any commas from search string
$member =~ s/\*/%/g;

my ($count,$results);

if(length($member) == 1)
{
    ($count,$results)=SearchMember($member,$orderby,"simple");
}
else
{
    ($count,$results)=SearchMember($member,$orderby,"advanced");
}


my @resultsdata;
my $background = 0;
for (my $i=0; $i < $count; $i++){
  #find out stats
  my ($od,$issue,$fines)=GetMemberIssuesAndFines($results->[$i]{'borrowernumber'});

  my %row = (
    background => $background,
    count => $i+1,
    borrowernumber => $results->[$i]{'borrowernumber'},
    cardnumber => $results->[$i]{'cardnumber'},
    surname => $results->[$i]{'surname'},
    firstname => $results->[$i]{'firstname'},
    categorycode => $results->[$i]{'categorycode'},
    category_type => $results->[$i]{'category_type'},
    category_description => $results->[$i]{'description'},
    streetaddress => $results->[$i]{'streetaddress'},
    city => $results->[$i]{'city'},
    branchcode => $results->[$i]{'branchcode'},
    overdues => $od,
    issues => $issue,
    odissue => "$od/$issue",
    fines =>  sprintf("%.2f",$fines),
    borrowernotes => $results->[$i]{'borrowernotes'},
    sort1 => $results->[$i]{'sort1'},
    sort2 => $results->[$i]{'sort2'},
    );
  if ( $background ) { $background = 0; } else {$background = 1; }
  push(@resultsdata, \%row);
}

$template->param( 
        searching       => "1",
        member          => $member,
        numresults      => $count,
        resultsloop     => \@resultsdata,
        intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
        intranetstylesheet => C4::Context->preference("intranetstylesheet"),
        IntranetNav => C4::Context->preference("IntranetNav"),
            );

output_html_with_http_headers $input, $cookie, $template->output;
