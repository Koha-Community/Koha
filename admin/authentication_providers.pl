#!/usr/bin/perl

# Copyright 2022 Theke Solutions
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

use Koha::Auth::Providers;

my $input         = CGI->new;
my $op            = $input->param('op') || 'list';
my $domain_ops    = $input->param('domain_ops');
my $auth_provider_id = $input->param('auth_provider_id');
my $auth_provider;

$auth_provider = Koha::Auth::Providers->find($auth_provider_id)
    unless !$auth_provider_id;

my $template_name = $domain_ops ? 'admin/authentication_provider_domains.tt' : 'admin/authentication_providers.tt';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => $template_name,
        query           => $input,
        type            => "intranet",
        flagsrequired   => { parameters => 'manage_authentication_providers' },
    }
);

my @messages;

if ( !$domain_ops && $op eq 'add' ) {

    my $code        = $input->param('code');
    my $config      = $input->param('config');
    my $description = $input->param('description');
    my $icon_url    = $input->param('icon_url');
    my $mapping     = $input->param('mapping');
    my $matchpoint  = $input->param('matchpoint'),
    my $protocol    = $input->param('protocol');

    try {
        my $provider = Koha::Auth::Provider->new(
            {   code        => $code,
                config      => $config,
                description => $description,
                icon_url    => $icon_url,
                mapping     => $mapping,
                matchpoint  => $matchpoint,
                protocol    => $protocol,
            }
        )->store;

        Koha::Auth::Provider::Domain->new(
            {
                auth_provider_id => $provider->auth_provider_id,
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
elsif ( $domain_ops && $op eq 'add' ) {

    my $allow_opac          = $input->param('allow_opac');
    my $allow_staff         = $input->param('allow_staff');
    my $auth_provider_id    = $input->param('auth_provider_id');
    my $auto_register       = $input->param('auto_register');
    my $default_category_id = $input->param('default_category_id');
    my $default_library_id  = $input->param('default_library_id');
    my $domain              = $input->param('domain');
    my $update_on_auth      = $input->param('update_on_auth');

    try {

        Koha::Auth::Provider::Domain->new(
            {
                allow_opac          => $allow_opac,
                allow_staff         => $allow_staff,
                auth_provider_id    => $auth_provider_id,
                auto_register       => $auto_register,
                default_category_id => $default_category_id,
                default_library_id  => $default_library_id,
                domain              => $domain,
                update_on_auth      => $update_on_auth,
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
elsif ( !$domain_ops && $op eq 'edit_form' ) {

    if ( $auth_provider ) {
        $template->param(
            auth_provider => $auth_provider
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
elsif ( $domain_ops && $op eq 'edit_form' ) {
    my $auth_provider_domain_id = $input->param('auth_provider_domain_id');
    my $auth_provider_domain;

    $auth_provider_domain = Koha::Auth::Provider::Domains->find($auth_provider_domain_id)
        unless !$auth_provider_domain_id;

    if ( $auth_provider_domain ) {
        $template->param(
            auth_provider_domain => $auth_provider_domain
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
elsif ( !$domain_ops && $op eq 'edit_save' ) {

    if ( $auth_provider ) {

        my $code        = $input->param('code');
        my $config      = $input->param('config');
        my $description = $input->param('description');
        my $icon_url    = $input->param('icon_url');
        my $mapping     = $input->param('mapping');
        my $matchpoint  = $input->param('matchpoint');
        my $protocol    = $input->param('protocol');

        try {

            $auth_provider->set(
                {   code        => $code,
                    config      => $config,
                    description => $description,
                    icon_url    => $icon_url,
                    mapping     => $mapping,
                    matchpoint  => $matchpoint,
                    protocol    => $protocol,
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
elsif ( $domain_ops && $op eq 'edit_save' ) {

    my $auth_provider_domain_id = $input->param('auth_provider_domain_id');
    my $auth_provider_domain;

    $auth_provider_domain = Koha::Auth::Provider::Domains->find($auth_provider_domain_id)
        unless !$auth_provider_domain_id;

    if ( $auth_provider_domain ) {

        my $auth_provider_id    = $input->param('auth_provider_id');
        my $domain              = $input->param('domain');
        my $auto_register       = $input->param('auto_register');
        my $update_on_auth      = $input->param('update_on_auth');
        my $default_library_id  = $input->param('default_library_id');
        my $default_category_id = $input->param('default_category_id');
        my $allow_opac          = $input->param('allow_opac');
        my $allow_staff         = $input->param('allow_staff');

        try {

            $auth_provider_domain->set(
                {
                    auth_provider_id    => $auth_provider_id,
                    domain              => $domain,
                    auto_register       => $auto_register,
                    update_on_auth      => $update_on_auth,
                    default_library_id  => $default_library_id,
                    default_category_id => $default_category_id,
                    allow_opac          => $allow_opac,
                    allow_staff         => $allow_staff,
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

if ( $domain_ops ) {
    $template->param(
        auth_provider_code => $auth_provider->code,
        auth_provider_id   => $auth_provider_id,
    );
}

$template->param(
    op       => $op,
    messages => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
