#!/usr/bin/perl

# Copyright 2012 ByWater Solutions
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

use C4::Context;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::SMS::Provider;
use Koha::SMS::Providers;

my $cgi = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "admin/sms_providers.tt",
        query         => $cgi,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_sms_providers' },
    }
);

my $op     = $cgi->param('op') || '';
my $id     = $cgi->param('id');
my $name   = $cgi->param('name');
my $domain = $cgi->param('domain');

if ( $op eq 'cud-add_update' ) {
    if ( $name && $domain ) {
        if ($id) {
            my $provider = Koha::SMS::Providers->find($id);
            $provider->set( { name => $name, domain => $domain } )->store()
                if $provider;
        } else {
            Koha::SMS::Provider->new( { name => $name, domain => $domain } )->store();
        }
    }
} elsif ( $op eq 'cud-delete' ) {
    my $provider = Koha::SMS::Providers->find($id);
    $provider->delete() if $provider;
}

my $providers = Koha::SMS::Providers->search;

$template->param( providers => $providers );

output_html_with_http_headers $cgi, $cookie, $template->output;
