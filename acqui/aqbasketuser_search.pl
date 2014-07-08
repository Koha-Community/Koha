#!/usr/bin/perl

# script to find a basket user

# Copyright 2012 BibLibre SARL
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

use CGI;
use C4::Auth;
use C4::Output;
use C4::Members;

my $input = new CGI;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "acqui/aqbasketuser_search.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
    }
);

my $q = $input->param('q') || '';
my $op = $input->param('op') || '';

if( $op eq "do_search" ) {
    my $results = C4::Members::Search( $q, "surname");

    my @users_loop;
    my $nresults = 0;
    foreach my $res (@$results) {
        my $perms = haspermission( $res->{userid} );
        my $subperms = get_user_subpermissions( $res->{userid} );

        if( $perms->{superlibrarian} == 1
         || $perms->{acquisition} == 1
         || $subperms->{acquisition}->{'order_manage'} ) {
            my %row = (
                borrowernumber  => $res->{borrowernumber},
                cardnumber      => $res->{cardnumber},
                surname         => $res->{surname},
                firstname       => $res->{firstname},
                categorycode    => $res->{categorycode},
                branchcode      => $res->{branchcode},
            );
            push( @users_loop, \%row );
            $nresults ++;
        }
    }

    $template->param(
        q           => $q,
        nresults    => $nresults,
        users_loop  => \@users_loop,
    );
}

output_html_with_http_headers( $input, $cookie, $template->output );
