#!/usr/bin/perl

# script to find owner and users for a budget

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

use Modern::Perl;

use C4::Auth ;
use C4::Output;
use CGI qw ( -utf8 );
use C4::Dates qw/format_date/;
use C4::Members;

my $input = new CGI;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "admin/aqbudget_user_search.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'budget_modify'  },
        debug           => 1,
    }
);

# only used if allowthemeoverride is set
my $type = $input->param('type');
my $member  = $input->param('member') // '';

$member =~ s/,//g;     #remove any commas from search string
$member =~ s/\*/%/g;
if ( $member eq '' ) {
    $template->param( results => 0 );
} else {
    $template->param( results => 1 );
}

my @resultsdata;

if ( $member ) {
    my $results = Search($member, "surname");

    foreach my $res (@$results) {
        my $perms = haspermission( $res->{'userid'} );
        my $subperms = get_user_subpermissions( $res->{'userid'} );

        # if the member has 'acqui' permission set, then display to table.
        if ( $perms->{superlibrarian} == 1  ||
             $perms->{acquisition} == 1  ||
             exists $subperms->{acquisition} )
        {
            my %row = (
                borrowernumber    => $res->{'borrowernumber'},
                cardnumber        => $res->{'cardnumber'},
                surname           => $res->{'surname'},
                firstname         => $res->{'firstname'},
                categorycode      => $res->{'categorycode'},
                branchcode        => $res->{'branchcode'},
            );
            push( @resultsdata, \%row );
        }
    }
}

$template->param(
    type => $type,
    member => $member,
    resultsloop => \@resultsdata
);

output_html_with_http_headers $input, $cookie, $template->output;
