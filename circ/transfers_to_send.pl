#!/usr/bin/perl

# Copyright 2019 PTFS-Europe Ltd.
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
use C4::Context;
use C4::Auth;
use C4::Output;

use Koha::DateUtils;

my $input      = CGI->new;
my $itemnumber = $input->param('itemnumber');

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "circ/transfers_to_send.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
        debug         => 1,
    }
);

# set the userenv branch
my $branchcode = C4::Context->userenv->{'branch'};

# transfers requested but not yet sent
my @transfers = Koha::Libraries->search(
    {
        'branchtransfers_tobranches.frombranch'    => $branchcode,
        'branchtransfers_tobranches.daterequested' => { '!=' => undef },
        'branchtransfers_tobranches.datesent'      => undef,
        'branchtransfers_tobranches.datearrived'   => undef,
        'branchtransfers_tobranches.datecancelled' => undef,
    },
    {
        prefetch => 'branchtransfers_tobranches',
        order_by => 'branchtransfers_tobranches.tobranch'
    }
);

$template->param(
    libraries => \@transfers,
    show_date => dt_from_string
);

output_html_with_http_headers $input, $cookie, $template->output;
