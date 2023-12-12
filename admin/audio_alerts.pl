#!/usr/bin/perl

# Copyright 2014 ByWater Solutions
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

use CGI;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::AudioAlert;
use Koha::AudioAlerts;

my $cgi = CGI->new;

my $selector = $cgi->param('selector');
my $sound    = $cgi->param('sound');
my $id       = $cgi->param('id');
my $action     = $cgi->param('action');
my $where    = $cgi->param('where');
my @delete   = $cgi->multi_param('cud-delete');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/audio_alerts.tt",
        query           => $cgi,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_audio_alerts' },
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

$template->param( AudioAlertsPage => 1, audio_alerts => Koha::AudioAlerts->search() );

output_html_with_http_headers $cgi, $cookie, $template->output;
