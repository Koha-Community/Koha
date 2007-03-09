#!/usr/bin/perl

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
use CGI;
use C4::Auth;
use C4::Output;
use C4::Labels;
use C4::Interface::CGI::Output;
use C4::Context;


my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "barcodes/label-home.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 1 },
        debug           => 1,
    }
);

my $data = get_label_options();

my $active_template = GetActiveLabelTemplate();
my @label_templates = GetAllLabelTemplates();

$template->param( guidebox => 1 ) if ( $data->{'guidebox'} );

$data->{'printingtype'} = 'both' if ( !$data->{'printingtype'} );
$template->param( "printingtype_$data->{'printingtype'}" => 1 );
$template->param( "papertype_$data->{'papertype'}"       => 1 );

$template->param( "$data->{'barcodetype'}_checked" => 1 );

$template->param( "startrow" . $data->{'startrow'} . "_checked" => 1 );
$template->param(
    itemtype        => $data->{'itemtype'},
    active_template => $data->{'active_template'},
    label_templates => \@label_templates,

    papertype      => $data->{'papertype'},
    author         => $data->{'author'},
    barcode        => $data->{'barcode'},
    id             => $data->{'id'},
    barcodetype    => $data->{'barcodetype'},
    title          => $data->{'title'},
    isbn           => $data->{'isbn'},
    dewey          => $data->{'dewey'},
    class          => $data->{'class'},
    startrow       => $data->{'startrow'},
    subclass       => $data->{'subclass'},
    itemcallnumber => $data->{'itemcallnumber'},
    startlabel     => $data->{'startlabel'},
    fontsize       => $active_template->{'fontsize'},

    intranetcolorstylesheet =>
      C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);

output_html_with_http_headers $query, $cookie, $template->output;
