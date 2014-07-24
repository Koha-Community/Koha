#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014 BibLibre
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Members;

my $input = new CGI;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "acqui/add_user_search.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'order_manage' },
    }
);

my $q = $input->param('q') || '';
my $op = $input->param('op') || '';

my $referer = $input->referer();

# If this script is called by acqui/basket.pl
# the patrons to return should be superlibrarian or have the order_manage
# acquisition flag.
my $search_patrons_with_acq_perm_only =
    ( $referer =~ m|acqui/basket.pl| )
        ? 1 : 0;

if( $op eq "do_search" ) {
    my $results = C4::Members::Search( $q, "surname");

    my @users_loop;
    my $nresults = 0;
    foreach my $res (@$results) {
        my $should_be_returned = 1;

        if ( $search_patrons_with_acq_perm_only ) {
            $should_be_returned = 0;
            my $perms = haspermission( $res->{userid} );
            my $subperms = get_user_subpermissions( $res->{userid} );

            if( $perms->{superlibrarian} == 1
             || $perms->{acquisition} == 1
             || $subperms->{acquisition}->{'order_manage'} ) {
                $should_be_returned = 1;
            }
        }
        if ( $should_be_returned ) {
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

$template->param(
    patrons_with_acq_perm_only => $search_patrons_with_acq_perm_only,
);
output_html_with_http_headers( $input, $cookie, $template->output );
