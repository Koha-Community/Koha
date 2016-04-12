#!/usr/bin/perl

# Copyright 2011,2014 Mark Gavillet & PTFS Europe Ltd
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

use strict;
use warnings;
use CGI;
use C4::Auth;
use C4::Output;
use Koha::Database;
use Koha::Plugins;

my $input = CGI->new();

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'admin/edi_accounts.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'edi_manage' },
    }
);

my $op = $input->param('op');
$op ||= 'display';
my $schema = Koha::Database->new()->schema();

if ( $op eq 'acct_form' ) {
    show_account();
    $template->param( acct_form => 1 );
    my @vendors = $schema->resultset('Aqbookseller')->search(
        undef,
        {
            columns => [ 'name', 'id' ],
            order_by => { -asc => 'name' }
        }
    );
    $template->param( vendors => \@vendors );

    my $plugins_enabled = C4::Context->preference('UseKohaPlugins') && C4::Context->config("enable_plugins");
    $template->param( plugins_enabled => $plugins_enabled );

    if ( $plugins_enabled ) {
        my @plugins = Koha::Plugins->new()->GetPlugins('edifact');
        $template->param( plugins => \@plugins );
    }
}
elsif ( $op eq 'delete_confirm' ) {
    show_account();
    $template->param( delete_confirm => 1 );
}
else {
    if ( $op eq 'save' ) {

        # validate & display
        my $id     = $input->param('id');
        my $fields = {
            description        => $input->param('description'),
            host               => $input->param('host'),
            username           => $input->param('username'),
            password           => $input->param('password'),
            vendor_id          => $input->param('vendor_id'),
            upload_directory   => $input->param('upload_directory'),
            download_directory => $input->param('download_directory'),
            san                => $input->param('san'),
            transport          => $input->param('transport'),
            quotes_enabled     => defined $input->param('quotes_enabled'),
            invoices_enabled   => defined $input->param('invoices_enabled'),
            orders_enabled     => defined $input->param('orders_enabled'),
            responses_enabled  => defined $input->param('responses_enabled'),
            auto_orders        => defined $input->param('auto_orders'),
            id_code_qualifier  => $input->param('id_code_qualifier'),
            plugin             => $input->param('plugin'),
        };

        if ($id) {
            $schema->resultset('VendorEdiAccount')->search(
                {
                    id => $id,
                }
            )->update_all($fields);
        }
        else {    # new record
            $schema->resultset('VendorEdiAccount')->create($fields);
        }
    }
    elsif ( $op eq 'delete_confirmed' ) {

        $schema->resultset('VendorEdiAccount')
          ->search( { id => $input->param('id'), } )->delete_all;
    }

    # we do a default dispaly after deletes and saves
    # as well as when thats all you want
    $template->param( display => 1 );
    my @ediaccounts = $schema->resultset('VendorEdiAccount')->search(
        {},
        {
            join => 'vendor',
        }
    );
    $template->param( ediaccounts => \@ediaccounts );
}

$template->param(
    code_qualifiers => [
        {
            code        => '14',
            description => 'EAN International',
        },
        {
            code        => '31B',
            description => 'US SAN Agency',
        },
        {
            code        => '91',
            description => 'Assigned by supplier',
        },
        {
            code        => '92',
            description => 'Assigned by buyer',
        },
    ]
);

output_html_with_http_headers( $input, $cookie, $template->output );

sub get_account {
    my $id = shift;

    my $account = $schema->resultset('VendorEdiAccount')->find($id);
    if ($account) {
        return $account;
    }

    # passing undef will default to add
    return;
}

sub show_account {
    my $acct_id = $input->param('id');
    if ($acct_id) {
        my $acct = $schema->resultset('VendorEdiAccount')->find($acct_id);
        if ($acct) {
            $template->param( account => $acct );
        }
    }
    return;
}
