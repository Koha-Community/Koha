#!/usr/bin/perl

# script to find a guarantor

# Copyright 2008-2009 BibLibre SARL
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505
use C4::Auth ;
use C4::Output;
use CGI;
use C4::Dates qw/format_date/;
use C4::Members;

my $input = new CGI;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "admin/aqbudget_owner_search.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'budget_modify'  },
        debug           => 1,
    }
);

my $theme = $input->param('theme') || "default";

# only used if allowthemeoverride is set
my $member  = $input->param('member');
my $orderby = $input->param('orderby');

my $op = $input->param('op');
$template->param( $op || else => 1, );

$orderby = "surname,firstname" unless $orderby;
$member =~ s/,//g;     #remove any commas from search string
$member =~ s/\*/%/g;
if ( $member eq '' ) {
    $template->param( results => 0 );
} else {
    $template->param( results => 1 );
}

my ( $count, $count2, $results );
my @resultsdata;
my $toggle = 0;

if ( $member ) {
	my $results= SearchMember($member,"surname",undef,undef,undef);

    foreach my $res (@$results) {

        my $perms = haspermission( $res->{'userid'} );
        my $subperms =  get_user_subpermissions  ($res->{'userid'} );


        # if the member has 'acqui' permission set, then display to table.
        if (    $perms->{superlibrarian} == 1  || 
                $perms->{acquisition} == 1  || 
                $subperms->{acquisition}->{'budget_manage'} || 
                $subperms->{acquisition}->{'budget_modify'} || 
                $subperms->{acquisition}->{'budget_add_del'}  ) {

            $count2++;
            #find out stats
#            my ( $od, $issue, $fines ) = GetMemberIssuesAndFines( $res->{'borrowerid'} );
			#This looks unused and very unuseful
            my $guarantorinfo = uc( $res->{'surname'} ) . " , " . ucfirst( $res->{'firstname'} );
            my $budget_owner_name = $res->{'firstname'} . ' ' . $res->{'surname'}, my $budget_owner_id = $res->{'borrowernumber'};

            my %row = (
                borrowernumber    => $res->{'borrowernumber'},
                cardnumber        => $res->{'cardnumber'},
                surname           => $res->{'surname'},
                firstname         => $res->{'firstname'},
                categorycode      => $res->{'categorycode'},
                branchcode        => $res->{'branchcode'},
                guarantorinfo     => $guarantorinfo,
                budget_owner_id   => $budget_owner_id,
                budget_owner_name => $budget_owner_name,
#                odissue           => "$od/$issue",
#                fines             => $fines,
#                borrowernotes     => $res->{'borrowernotes'}
            );
            push( @resultsdata, \%row );
        }
    }
}

$template->param(
    member => $member,
    numres => $count2,
    resultsloop => \@resultsdata
);

output_html_with_http_headers $input, $cookie, $template->output;
