#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output      qw( output_html_with_http_headers );
use C4::Auth        qw( get_template_and_user );
use Koha::DateUtils qw( dt_from_string );

my $input = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "circ/transferstoreceive.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

$template->param(
    branchcode              => C4::Context->userenv->{'branch'},
    show_date               => dt_from_string,
    TransfersMaxDaysWarning => C4::Context->preference('TransfersMaxDaysWarning'),
);

output_html_with_http_headers $input, $cookie, $template->output;
