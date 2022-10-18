#!/usr/bin/perl

# Copyright 2011,2014 Mark Gavillet & PTFS Europe Ltd
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
use Koha::Database;
use Koha::Encryption;
use Koha::Plugins;

our $input = CGI->new();
our $schema = Koha::Database->new()->schema();

our ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'admin/edi_accounts.tt',
        query           => $input,
        type            => 'intranet',
        flagsrequired   => { acquisition => 'edi_manage' },
    }
);

my $crypt = Koha::Encryption->new;

my $op = $input->param('op');
$op ||= 'display';

if ( $op eq 'acct_form' ) {
    show_account($crypt);
    $template->param( acct_form => 1 );
    my @vendors = $schema->resultset('Aqbookseller')->search(
        undef,
        {
            columns => [ 'name', 'id' ],
            order_by => { -asc => 'name' }
        }
    );
    $template->param( vendors => \@vendors );

    if ( C4::Context->config("enable_plugins") ) {
        my @plugins = Koha::Plugins->new()->GetPlugins({
            method => 'edifact',
        });
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
        my $password = scalar $input->param('password');
        $password = $crypt->encrypt_hex($password);
        my $fields = {
            description        => scalar $input->param('description'),
            host               => scalar $input->param('host'),
            username           => scalar $input->param('username'),
            password           => $password,
            vendor_id          => scalar $input->param('vendor_id'),
            upload_directory   => scalar $input->param('upload_directory'),
            download_directory => scalar $input->param('download_directory'),
            san                => scalar $input->param('san'),
            standard           => scalar $input->param('standard'),
            transport          => scalar $input->param('transport'),
            quotes_enabled     => $input->param('quotes_enabled') ? 1 : 0,
            invoices_enabled   => $input->param('invoices_enabled') ? 1 : 0,
            orders_enabled     => $input->param('orders_enabled') ? 1 : 0,
            responses_enabled  => $input->param('responses_enabled') ? 1 : 0,
            auto_orders        => $input->param('auto_orders') ? 1 : 0,
            id_code_qualifier  => scalar $input->param('id_code_qualifier'),
            plugin             => scalar $input->param('plugin'),
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
          ->search( { id => scalar $input->param('id'), } )->delete_all;
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
    ],
    standards => [ 'BIC', 'EUR' ]
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
    my $crypt = shift;
    my $acct_id = $input->param('id');
    if ($acct_id) {
        my $acct = $schema->resultset('VendorEdiAccount')->find($acct_id);
        $acct->password( $crypt->decrypt_hex($acct->password) );
        if ($acct) {
            $template->param( account => $acct );
        }
    }
    return;
}
