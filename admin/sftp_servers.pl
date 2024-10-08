#!/usr/bin/perl

# Copyright 2024 PTFS Europe Ltd
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

use CGI          qw ( -utf8 );
use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::SFTP::Servers;

my $input = CGI->new;
my $op    = $input->param('op') || 'list';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "admin/sftp_servers.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_sftp_servers' },
    }
);

my @messages;

my $sftp_servers = Koha::SFTP::Servers->search;

if ( $op eq 'cud-add' ) {
    my $name               = $input->param('sftp_name');
    my $host               = $input->param('sftp_host')      || 'localhost';
    my $port               = $input->param('sftp_port')      || 22;
    my $transport          = $input->param('sftp_transport') || 'sftp';
    my $passive            = ( scalar $input->param('sftp_passiv') ) ? 1 : 0;
    my $auth_mode          = $input->param('sftp_auth_mode')          || 'password';
    my $user_name          = $input->param('sftp_user_name')          || undef;
    my $password           = $input->param('sftp_password')           || undef;
    my $key_file           = $input->param('sftp_key_file')           || undef;
    my $download_directory = $input->param('sftp_download_directory') || undef;
    my $upload_directory   = $input->param('sftp_upload_directory')   || undef;
    my $status             = $input->param('sftp_status')             || '';
    my $debug              = ( scalar $input->param('sftp_debug_mode') ) ? 1 : 0;

    try {
        my $sftp_server = Koha::SFTP::Server->new(
            {
                name               => $name,
                host               => $host,
                port               => $port,
                transport          => $transport,
                passive            => $passive,
                auth_mode          => $auth_mode,
                user_name          => $user_name,
                download_directory => $download_directory,
                upload_directory   => $upload_directory,
                status             => $status,
                debug              => $debug,
            }
        )->store;

        $sftp_server->update_password($password)
            if ($password);

        $sftp_server->update_key_file($key_file)
            if ($key_file);

        push @messages, {
            type => 'message',
            code => 'success_on_insert'
        };
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            push @messages, {
                type   => 'alert',
                code   => 'error_on_insert',
                reason => 'duplicate_id'
            };
        }
    };

    # list servers after adding
    $op = 'list';

} elsif ( $op eq 'edit_form' ) {
    my $sftp_server_id = $input->param('sftp_server_id');
    my $sftp_server;
    my $sftp_server_plain_text_password;
    my $sftp_server_plain_text_key;

    $sftp_server = Koha::SFTP::Servers->find($sftp_server_id)
        unless !$sftp_server_id;

    unless ( !$sftp_server ) {
        $sftp_server_plain_text_password = $sftp_server->plain_text_password || '';
        $sftp_server_plain_text_key      = $sftp_server->plain_text_key      || '';
    }

    if ($sftp_server) {
        $template->param(
            sftp_server                     => $sftp_server,
            sftp_server_plain_text_password => $sftp_server_plain_text_password,
            sftp_server_plain_text_key      => $sftp_server_plain_text_key,
        );
    } else {
        push @messages, {
            type   => 'alert',
            code   => 'error_on_edit',
            reason => 'invalid_id'
        };
    }

} elsif ( $op eq 'cud-edit_save' ) {
    my $sftp_server_id = $input->param('sftp_server_id');
    my $sftp_server_plain_text_password;
    my $sftp_server;

    $sftp_server = Koha::SFTP::Servers->find($sftp_server_id)
        unless !$sftp_server_id;

    $sftp_server_plain_text_password = $sftp_server->plain_text_password
        unless !$sftp_server_id;

    if ($sftp_server) {
        my $name               = $input->param('sftp_name');
        my $host               = $input->param('sftp_host')      || 'localhost';
        my $port               = $input->param('sftp_port')      || 22;
        my $transport          = $input->param('sftp_transport') || 'sftp';
        my $passive            = ( scalar $input->param('sftp_passiv') ) ? 1 : 0;
        my $auth_mode          = $input->param('sftp_auth_mode')          || 'password';
        my $user_name          = $input->param('sftp_user_name')          || undef;
        my $password           = $input->param('sftp_password')           || undef;
        my $key_file           = $input->param('sftp_key_file')           || undef;
        my $download_directory = $input->param('sftp_download_directory') || undef;
        my $upload_directory   = $input->param('sftp_upload_directory')   || undef;
        my $status             = $input->param('sftp_status')             || '';
        my $debug              = ( scalar $input->param('sftp_debug_mode') ) ? 1 : 0;

        try {
            $sftp_server->set(
                {
                    name               => $name,
                    host               => $host,
                    port               => $port,
                    transport          => $transport,
                    passive            => $passive,
                    auth_mode          => $auth_mode,
                    user_name          => $user_name,
                    download_directory => $download_directory,
                    upload_directory   => $upload_directory,
                    status             => $status,
                    debug              => $debug,
                }
            )->store;

            $sftp_server->update_password($password)
                if ($password);

            $sftp_server->update_key_file($key_file)
                if ($key_file);

            push @messages, {
                type => 'message',
                code => 'success_on_update'
            };

        } catch {

            push @messages, {
                type => 'alert',
                code => 'error_on_update'
            };

        };

        # list servers after adding
        $op = 'list';
    } else {
        push @messages, {
            type   => 'alert',
            code   => 'error_on_update',
            reason => 'invalid_id'
        };
    }

} elsif ( $op eq 'test_form' ) {
    my $sftp_server_id = $input->param('sftp_server_id');
    my $sftp_server;

    $sftp_server = Koha::SFTP::Servers->find($sftp_server_id)
        unless !$sftp_server_id;

    if ($sftp_server) {
        $template->param(
            sftp_server => $sftp_server,
        );
    } else {
        push @messages, {
            type   => 'alert',
            code   => 'error_on_test',
            reason => 'invalid_id',
        };
    }
}

if ( $op eq 'list' ) {
    $template->param(
        servers_count => $sftp_servers->count,
    );
}

$template->param(
    op       => $op,
    messages => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
