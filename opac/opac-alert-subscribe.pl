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
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Dates;
use C4::Output;
use C4::Context;
use C4::Koha;
use C4::Letters;
use C4::Serials;


my $query = new CGI;
my $op    = $query->param('op') || '';
my $dbh   = C4::Context->dbh;

my $sth;
my ( $template, $loggedinuser, $cookie );
my $externalid   = $query->param('externalid');
my $alerttype    = $query->param('alerttype') || '';
my $biblionumber = $query->param('biblionumber');

( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-alert-subscribe.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0, # user must logged in to request
                              # subscription notifications
        debug           => 1,
    }
);

if ( $op eq 'alert_confirmed' ) {
    addalert( $loggedinuser, $alerttype, $externalid );
    if ( $alerttype eq 'issue' ) {
        print $query->redirect(
            "opac-serial-issues.pl?biblionumber=$biblionumber");
        exit;
    }
}
elsif ( $op eq 'cancel_confirmed' ) {
    my $alerts = getalert( $loggedinuser, $alerttype, $externalid );
    warn "CANCEL confirmed : $loggedinuser, $alerttype, $externalid".Data::Dumper::Dumper( $alerts );
    foreach (@$alerts)
    {    # we are supposed to have only 1 result, but just in case...
        delalert( $_->{alertid} );
    }
    if ( $alerttype eq 'issue' ) {
        print $query->redirect(
            "opac-serial-issues.pl?biblionumber=$biblionumber");
        exit;
    }

}
else {
    if ( $alerttype eq 'issue' ) {    # alert for subscription issues
        my $subscription = &GetSubscription($externalid);
        $template->param(
            "typeissue$op" => 1,
            bibliotitle    => $subscription->{bibliotitle},
            notes          => $subscription->{notes},
            externalid     => $externalid,
            biblionumber   => $biblionumber,
        );
    }
    else {
    }

}
output_html_with_http_headers $query, $cookie, $template->output;
