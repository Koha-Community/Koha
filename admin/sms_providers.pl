#!/usr/bin/perl

# Copyright 2012 ByWater Solutions
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

use C4::Context;
use C4::Auth;
use C4::Output;

use Koha::SMS::Provider;
use Koha::SMS::Providers;

my $cgi = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/sms_providers.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

my $op     = $cgi->param('op');
my $id     = $cgi->param('id');
my $name   = $cgi->param('name');
my $domain = $cgi->param('domain');

if ( $op eq 'add_update' ) {
    if ( $name && $domain ) {
        if ($id) {
            my $provider = Koha::SMS::Providers->find($id);
            $provider->set( { name => $name, domain => $domain } )->store()
              if $provider;
        }
        else {
            Koha::SMS::Provider->new( { name => $name, domain => $domain } )
              ->store();
        }
    }
}
elsif ( $op eq 'delete' ) {
    my $provider = Koha::SMS::Providers->find($id);
    $provider->delete() if $provider;
}

my @providers = Koha::SMS::Providers->search();

$template->param( providers => \@providers );

output_html_with_http_headers $cgi, $cookie, $template->output;
