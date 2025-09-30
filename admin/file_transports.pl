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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI          qw ( -utf8 );
use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::File::Transports;

my $input = CGI->new;
my $op    = $input->param('op') || 'list';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "admin/file_transports.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_file_transports' },
    }
);

my @messages;

my $file_transports = Koha::File::Transports->search;

if ( $op eq 'cud-add' ) {
    my $name               = $input->param('name');
    my $host               = $input->param('host')      || 'localhost';
    my $port               = $input->param('port')      || 22;
    my $transport          = $input->param('transport') || 'sftp';
    my $passive            = ( scalar $input->param('passiv') ) ? 1 : 0;
    my $auth_mode          = $input->param('auth_mode')          || 'password';
    my $user_name          = $input->param('user_name')          || undef;
    my $password           = $input->param('password')           || undef;
    my $key_file           = $input->param('key_file')           || undef;
    my $download_directory = $input->param('download_directory') || undef;
    my $upload_directory   = $input->param('upload_directory')   || undef;
    my $status             = $input->param('status')             || '';
    my $debug              = ( scalar $input->param('debug_mode') ) ? 1 : 0;

    try {
        my $file_transport = Koha::File::Transport->new(
            {
                name               => $name,
                host               => $host,
                port               => $port,
                transport          => $transport,
                passive            => $passive,
                auth_mode          => $auth_mode,
                user_name          => $user_name,
                password           => $password,
                key_file           => $key_file,
                download_directory => $download_directory,
                upload_directory   => $upload_directory,
                status             => $status,
                debug              => $debug,
            }
        )->store;

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
    my $file_transport_id = $input->param('file_transport_id');
    my $file_transport;
    my $file_transport_plain_text_password;
    my $file_transport_plain_text_key;

    $file_transport = Koha::File::Transports->find($file_transport_id)
        unless !$file_transport_id;

    unless ( !$file_transport ) {
        $file_transport_plain_text_password = $file_transport->plain_text_password || '';
        $file_transport_plain_text_key      = $file_transport->plain_text_key      || '';
    }

    if ($file_transport) {
        $template->param(
            file_transport                     => $file_transport,
            file_transport_plain_text_password => $file_transport_plain_text_password,
            file_transport_plain_text_key      => $file_transport_plain_text_key,
        );
    } else {
        push @messages, {
            type   => 'alert',
            code   => 'error_on_edit',
            reason => 'invalid_id'
        };
    }

} elsif ( $op eq 'cud-edit_save' ) {
    my $file_transport_id = $input->param('file_transport_id');
    my $file_transport_plain_text_password;
    my $file_transport;

    $file_transport = Koha::File::Transports->find($file_transport_id)
        unless !$file_transport_id;

    $file_transport_plain_text_password = $file_transport->plain_text_password
        unless !$file_transport_id;

    if ($file_transport) {
        my $name               = $input->param('name');
        my $host               = $input->param('host')      || 'localhost';
        my $port               = $input->param('port')      || 22;
        my $transport          = $input->param('transport') || 'sftp';
        my $passive            = ( scalar $input->param('passiv') ) ? 1 : 0;
        my $auth_mode          = $input->param('auth_mode')          || 'password';
        my $user_name          = $input->param('user_name')          || undef;
        my $password           = $input->param('password')           || undef;
        my $key_file           = $input->param('key_file')           || undef;
        my $download_directory = $input->param('download_directory') || undef;
        my $upload_directory   = $input->param('upload_directory')   || undef;
        my $status             = $input->param('status')             || '';
        my $debug              = ( scalar $input->param('debug_mode') ) ? 1 : 0;

        try {
            $file_transport->set(
                {
                    name               => $name,
                    host               => $host,
                    port               => $port,
                    transport          => $transport,
                    passive            => $passive,
                    auth_mode          => $auth_mode,
                    user_name          => $user_name,
                    password           => $password,
                    key_file           => $key_file,
                    download_directory => $download_directory,
                    upload_directory   => $upload_directory,
                    status             => $status,
                    debug              => $debug,
                }
            )->store;

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
}

if ( $op eq 'list' ) {
    $template->param(
        servers_count => $file_transports->count,
    );
}

$template->param(
    op       => $op,
    messages => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
