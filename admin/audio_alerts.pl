#!/usr/bin/perl

# Copyright 2014 ByWater Solutions
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
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
use Koha::AudioAlert;
use Koha::AudioAlerts;

my $cgi = new CGI;

my $selector = $cgi->param('selector');
my $sound    = $cgi->param('sound');
my $id       = $cgi->param('id');
my $action     = $cgi->param('action');
my $where    = $cgi->param('where');
my @delete   = $cgi->multi_param('delete');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/audio_alerts.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

if ( $id && $action && $where && $action eq 'move' ) {
    Koha::AudioAlerts->find($id)->move($where);
}
elsif ( $id && $selector && $sound ) {
    my $alert = Koha::AudioAlerts->find($id);
    $alert->selector( $selector );
    $alert->sound( $sound );
    $alert->store();
}
elsif ( $selector && $sound ) {
    Koha::AudioAlert->new( { selector => $selector, sound => $sound } )->store();
}

if (@delete) {
    map { Koha::AudioAlerts->find($_)->delete() } @delete;
    Koha::AudioAlerts->fix_precedences();
}

$template->param( AudioAlertsPage => 1, audio_alerts => scalar Koha::AudioAlerts->search() );

output_html_with_http_headers $cgi, $cookie, $template->output;
