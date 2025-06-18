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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use CGI          qw ( -utf8 );
use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );

use Koha::Database;
use Koha::Auth::Identity::Providers;

my $input                = CGI->new;
my $op                   = $input->param('op') || 'list';
my $domain_ops           = $input->param('domain_ops');
my $identity_provider_id = $input->param('identity_provider_id');
my $identity_provider;

$identity_provider = Koha::Auth::Identity::Providers->find($identity_provider_id)
    unless !$identity_provider_id;

my $template_name = $domain_ops ? 'admin/identity_provider_domains.tt' : 'admin/identity_providers.tt';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => $template_name,
        query         => $input,
        type          => "intranet",
        flagsrequired => { parameters => 'manage_identity_providers' },
    }
);

my @messages;

if ( !$domain_ops && $op eq 'cud-add' ) {

    # IdP configuration params
    my $code        = $input->param('code');
    my $config      = $input->param('config');
    my $description = $input->param('description');
    my $icon_url    = $input->param('icon_url');
    my $mapping     = $input->param('mapping');
    my $matchpoint  = $input->param('matchpoint');
    my $protocol    = $input->param('protocol');

    # Domain configuration params
    my $allow_opac          = $input->param('allow_opac')    // 0;
    my $allow_staff         = $input->param('allow_staff')   // 0;
    my $auto_register       = $input->param('auto_register') // 0;
    my $default_category_id = $input->param('default_category_id');
    my $default_library_id  = $input->param('default_library_id');
    my $domain              = $input->param('domain');
    my $update_on_auth      = $input->param('update_on_auth');

    try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $provider = Koha::Auth::Identity::Provider->new(
                    {
                        code        => $code,
                        config      => $config,
                        description => $description,
                        icon_url    => $icon_url,
                        mapping     => $mapping,
                        matchpoint  => $matchpoint,
                        protocol    => $protocol,
                    }
                )->store;

                Koha::Auth::Identity::Provider::Domain->new(
                    {
                        identity_provider_id => $provider->identity_provider_id,
                        allow_opac           => $allow_opac,
                        allow_staff          => $allow_staff,
                        auto_register        => $auto_register,
                        default_category_id  => $default_category_id,
                        default_library_id   => $default_library_id,
                        domain               => $domain,
                        update_on_auth       => $update_on_auth,
                    }
                )->store;

                push @messages, { type => 'message', code => 'success_on_insert' };
            }
        );
    } catch {
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
} elsif ( $domain_ops && $op eq 'cud-add' ) {

    my $allow_opac           = $input->param('allow_opac');
    my $allow_staff          = $input->param('allow_staff');
    my $identity_provider_id = $input->param('identity_provider_id');
    my $auto_register        = $input->param('auto_register');
    my $default_category_id  = $input->param('default_category_id') || undef;
    my $default_library_id   = $input->param('default_library_id')  || undef;
    my $domain               = $input->param('domain');
    my $update_on_auth       = $input->param('update_on_auth');

    try {

        Koha::Auth::Identity::Provider::Domain->new(
            {
                allow_opac           => $allow_opac,
                allow_staff          => $allow_staff,
                identity_provider_id => $identity_provider_id,
                auto_register        => $auto_register,
                default_category_id  => $default_category_id,
                default_library_id   => $default_library_id,
                domain               => $domain,
                update_on_auth       => $update_on_auth,
            }
        )->store;

        push @messages, { type => 'message', code => 'success_on_insert' };
    } catch {
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
} elsif ( !$domain_ops && $op eq 'edit_form' ) {

    if ($identity_provider) {
        $template->param( identity_provider => $identity_provider );
    } else {
        push @messages,
            {
            type   => 'alert',
            code   => 'error_on_edit',
            reason => 'invalid_id'
            };
    }
} elsif ( $domain_ops && $op eq 'edit_form' ) {
    my $identity_provider_domain_id = $input->param('identity_provider_domain_id');
    my $identity_provider_domain;

    $identity_provider_domain = Koha::Auth::Identity::Provider::Domains->find($identity_provider_domain_id)
        unless !$identity_provider_domain_id;

    if ($identity_provider_domain) {
        $template->param( identity_provider_domain => $identity_provider_domain );
    } else {
        push @messages,
            {
            type   => 'alert',
            code   => 'error_on_edit',
            reason => 'invalid_id'
            };
    }
} elsif ( !$domain_ops && $op eq 'cud-edit_save' ) {

    if ($identity_provider) {

        my $code        = $input->param('code');
        my $config      = $input->param('config');
        my $description = $input->param('description');
        my $icon_url    = $input->param('icon_url');
        my $mapping     = $input->param('mapping');
        my $matchpoint  = $input->param('matchpoint');
        my $protocol    = $input->param('protocol');

        try {

            $identity_provider->set(
                {
                    code        => $code,
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
        } catch {
            push @messages,
                {
                type => 'alert',
                code => 'error_on_update'
                };
        };

        # list servers after adding
        $op = 'list';
    } else {
        push @messages,
            {
            type   => 'alert',
            code   => 'error_on_update',
            reason => 'invalid_id'
            };
    }
} elsif ( $domain_ops && $op eq 'cud-edit_save' ) {

    my $identity_provider_domain_id = $input->param('identity_provider_domain_id');
    my $identity_provider_domain;

    $identity_provider_domain = Koha::Auth::Identity::Provider::Domains->find($identity_provider_domain_id)
        unless !$identity_provider_domain_id;

    if ($identity_provider_domain) {

        my $identity_provider_id = $input->param('identity_provider_id');
        my $domain               = $input->param('domain');
        my $auto_register        = $input->param('auto_register');
        my $update_on_auth       = $input->param('update_on_auth');
        my $default_library_id   = $input->param('default_library_id')  || undef;
        my $default_category_id  = $input->param('default_category_id') || undef;
        my $allow_opac           = $input->param('allow_opac');
        my $allow_staff          = $input->param('allow_staff');

        try {

            $identity_provider_domain->set(
                {
                    identity_provider_id => $identity_provider_id,
                    domain               => $domain,
                    auto_register        => $auto_register,
                    update_on_auth       => $update_on_auth,
                    default_library_id   => $default_library_id,
                    default_category_id  => $default_category_id,
                    allow_opac           => $allow_opac,
                    allow_staff          => $allow_staff,
                }
            )->store;

            push @messages,
                {
                type => 'message',
                code => 'success_on_update'
                };
        } catch {
            push @messages,
                {
                type => 'alert',
                code => 'error_on_update'
                };
        };

        # list servers after adding
        $op = 'list';
    } else {
        push @messages,
            {
            type   => 'alert',
            code   => 'error_on_update',
            reason => 'invalid_id'
            };
    }
}

if ($domain_ops) {
    $template->param(
        identity_provider_code => $identity_provider->code,
        identity_provider_id   => $identity_provider_id,
    );
}

$template->param(
    op       => $op,
    messages => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
