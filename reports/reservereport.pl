#!/usr/bin/perl

#written 26/4/2000
#script to display reports

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
use C4::Stats;
use Date::Manip;
use CGI;
use C4::Output;
use HTML::Template;
use C4::Auth;
use C4::Interface::CGI::Output;

my $input = new CGI;
my $time  = $input->param('time');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/reservereport.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
);

my ( $count, $data ) = unfilledreserves();

my @dataloop;
for ( my $i = 0 ; $i < $count ; $i++ ) {
    warn "here";
    my %line;
    $line{name} = "$data->[$i]->{'surname'}\, $data->[$i]->{'firstname'}";
    $line{'reservedate'}    = $data->[$i]->{'reservedate'};
    $line{'title'}          = $data->[$i]->{'title'};
    $line{'classification'} =
      "$data->[$i]->{'classification'}$data->[$i]->{'dewey'}";
    push( @dataloop, \%line );
}

$template->param(
    count    => $count,
    dataloop => \@dataloop
);

output_html_with_http_headers $input, $cookie, $template->output;
