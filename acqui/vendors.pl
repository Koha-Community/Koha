#!/usr/bin/perl

# Copyright 2025 Open Fifth
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
use C4::Auth   qw( get_template_and_user haspermission );
use C4::Output qw( output_html_with_http_headers );
use CGI        qw ( -utf8 );

use C4::Context;

use Koha::Acquisition::Currencies;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name => 'acqui/vendors.tt',
        query         => $query,
        type          => 'intranet',
        flagsrequired => { acquisition => '*' },
    }
);

my $user_permissions = {};
my $var_data         = $template->{VARS};
foreach my $key ( keys %{$var_data} ) {
    $user_permissions->{$key} = $var_data->{$key} if ( $key =~ /CAN_user_(.*)/ );
}

my @gst_values = map { option => $_ + 0.0 }, split( '\|', C4::Context->preference("TaxRates") );

$template->param(
    user_permissions => $user_permissions,
    currencies       => Koha::Acquisition::Currencies->search->unblessed,
    gst_values       => \@gst_values,
    edifact          => C4::Context->preference('EDIFACT')
);

output_html_with_http_headers $query, $cookie, $template->output;
