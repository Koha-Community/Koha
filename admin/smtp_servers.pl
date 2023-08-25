#!/usr/bin/perl

# Copyright 2020 Theke Solutions
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

use CGI qw ( -utf8 );
use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Libraries;
use Koha::SMTP::Servers;

my $input = CGI->new;
my $op    = $input->param('op') || 'list';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/smtp_servers.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_smtp_servers' },
    }
);

my @messages;

my $smtp_servers = Koha::SMTP::Servers->search;

if ( $op eq 'add' ) {

    my $name       = $input->param('smtp_name');
    my $host       = $input->param('smtp_host');
    my $port       = $input->param('smtp_port') || 25;
    my $timeout    = $input->param('smtp_timeout') || 120;
    my $ssl_mode   = $input->param('smtp_ssl_mode');
    my $user_name  = $input->param('smtp_user_name') || undef;
    my $password   = $input->param('smtp_password') || undef;
    my $debug      = ( scalar $input->param('smtp_debug_mode') ) ? 1 : 0;
    my $is_default = ( scalar $input->param('smtp_default') ) ? 1 : 0;

    try {

        Koha::SMTP::Server->new(
            {
                name       => $name,
                host       => $host,
                port       => $port,
                timeout    => $timeout,
                ssl_mode   => $ssl_mode,
                user_name  => $user_name,
                password   => $password,
                debug      => $debug,
                is_default => $is_default,
            }
        )->store;

        push @messages, { type => 'message', code => 'success_on_insert' };
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            push @messages,
              {
                type   => 'alert',
                code   => 'error_on_insert',
                reason => 'duplicate_id'
              };
        }
    };

    # list servers after adding
    $op = 'list';
}
elsif ( $op eq 'edit_form' ) {
    my $smtp_server_id = $input->param('smtp_server_id');
    my $smtp_server;

    $smtp_server = Koha::SMTP::Servers->find($smtp_server_id)
        unless !$smtp_server_id;

    if ( $smtp_server ) {
        $template->param(
            smtp_server => $smtp_server,
            default_config => $smtp_servers->get_default,
        );
    }
    else {
        push @messages,
            {
                type   => 'alert',
                code   => 'error_on_edit',
                reason => 'invalid_id'
            };
    }
}
elsif ( $op eq 'edit_save' ) {

    my $smtp_server_id = $input->param('smtp_server_id');
    my $smtp_server;

    $smtp_server = Koha::SMTP::Servers->find($smtp_server_id)
        unless !$smtp_server_id;

    if ( $smtp_server ) {

        my $name       = $input->param('smtp_name');
        my $host       = $input->param('smtp_host');
        my $port       = $input->param('smtp_port') || 25;
        my $timeout    = $input->param('smtp_timeout') || 120;
        my $ssl_mode   = $input->param('smtp_ssl_mode');
        my $user_name  = $input->param('smtp_user_name') || undef;
        my $password   = $input->param('smtp_password') || undef;
        my $debug      = ( scalar $input->param('smtp_debug_mode') ) ? 1 : 0;
        my $is_default = ( scalar $input->param('smtp_default') ) ? 1 : 0;

        try {

            $smtp_server->password( $password )
                if defined $password and $password ne '****'
                    or not defined $password;

            $smtp_server->set(
                {
                    name       => $name,
                    host       => $host,
                    port       => $port,
                    timeout    => $timeout,
                    ssl_mode   => $ssl_mode,
                    user_name  => $user_name,
                    debug      => $debug,
                    is_default => $is_default,
                }
            )->store;

            push @messages,
            {
                type => 'message',
                code => 'success_on_update'
            };
        }
        catch {
            push @messages,
            {
                type   => 'alert',
                code   => 'error_on_update'
            };
        };

        # list servers after adding
        $op = 'list';
    }
    else {
        push @messages,
            {
                type   => 'alert',
                code   => 'error_on_update',
                reason => 'invalid_id'
            };
    }
}

if ( $op eq 'list' ) {
    $template->param(
        servers_count  => $smtp_servers->count,
        default_config => $smtp_servers->get_default,
    );
}

$template->param(
    op       => $op,
    messages => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
