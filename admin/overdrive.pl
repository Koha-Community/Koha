#!/usr/bin/perl

# Copyright Koha Development Team
#
# This file is part of Koha.
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
use C4::Context;
use C4::Output;

use Koha::Libraries;
use Koha::Library::OverDriveInfos;

my $input         = CGI->new;
my @branchcodes   = $input->multi_param('branchcode');
my @authnames     = $input->multi_param('authname');
my $op            = $input->param('op');
my @messages;

our ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => 'admin/overdrive.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
    }
);

if ( $op && $op eq 'update' ) {
    my %od_info;
    @od_info{ @branchcodes } = @authnames;
    while( my($branchcode,$authname) = each %od_info){
        my $cur_info = Koha::Library::OverDriveInfos->find($branchcode);
        if( $cur_info ) {
            $cur_info->authname($authname)->store;
        } else {
            Koha::Library::OverDriveInfo->new({
                branchcode => $branchcode,
                authname   => $authname,
            })->store;
        }
    }
}

my @branches = Koha::Libraries->search();
my @branch_od_info;
foreach my $branch ( @branches ){
    my $od_info =  Koha::Library::OverDriveInfos->find($branch->branchcode);
    if( $od_info ){
        push @branch_od_info, { branchcode => $od_info->branchcode, authname => $od_info->authname };
    } else {
        push @branch_od_info, { branchcode => $branch->branchcode, authname => "" };
    }
}

$template->param(
    branches => \@branch_od_info,
);

output_html_with_http_headers $input, $cookie, $template->output;
