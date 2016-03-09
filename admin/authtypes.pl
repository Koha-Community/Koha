#!/usr/bin/perl

# Copyright 2002 paul.poulain@biblibre.com
# Copyright 2000-2002 Katipo Communications
# Copyright 2015 Koha Development Team
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
use C4::Context;
use C4::Auth;
use C4::Output;

use Koha::Authorities;
use Koha::Authority::Types;

my $input        = new CGI;
my $authtypecode = $input->param('authtypecode');
my $op           = $input->param('op') || 'list';
my @messages;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/authtypes.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

if ( $op eq 'add_form' ) {
    my $authority_type;
    if (defined $authtypecode) {
        $authority_type = Koha::Authority::Types->find($authtypecode);
    }

    $template->param( authority_type => $authority_type );
} elsif ( $op eq 'add_validate' ) {
    my $authtypecode       = $input->param('authtypecode');
    my $authtypetext       = $input->param('authtypetext');
    my $auth_tag_to_report = $input->param('auth_tag_to_report');
    my $summary            = $input->param('summary');
    my $is_a_modif         = $input->param('is_a_modif');

    if ($is_a_modif) {
        my $authority_type = Koha::Authority::Types->find($authtypecode);
        $authority_type->authtypetext($authtypetext);
        $authority_type->auth_tag_to_report($auth_tag_to_report);
        $authority_type->summary($summary);
        eval { $authority_type->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {
        my $authority_type = Koha::Authority::Type->new(
            {   authtypecode       => $authtypecode,
                authtypetext       => $authtypetext,
                auth_tag_to_report => $auth_tag_to_report,
                summary            => $summary,
            }
        );
        eval { $authority_type->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }
    $op = 'list';

} elsif ( $op eq 'delete_confirm' ) {
    my $authority_type = Koha::Authority::Types->find($authtypecode);
    my $authorities_using_it = Koha::Authorities->search( { authtypecode => $authtypecode } )->count;
    $template->param(
        authority_type       => $authority_type,
        authorities_using_it => $authorities_using_it,
    );
} elsif ( $op eq 'delete_confirmed' ) {
    my $authorities_using_it = Koha::Authorities->search( { authtypecode => $authtypecode } )->count;
    if ( $authorities_using_it == 0 ) {
        my $authority_type = Koha::Authority::Types->find($authtypecode);
        my $deleted = eval { $authority_type->delete; };

        if ( $@ or not $deleted ) {
            push @messages, { type => 'error', code => 'error_on_delete' };
        } else {
            push @messages, { type => 'message', code => 'success_on_delete' };
        }
    } else {
        push @messages, { type => 'error', code => 'error_on_delete' };
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $authority_types = Koha::Authority::Types->search( {}, { order_by => ['authtypecode'] } );
    $template->param( authority_types => $authority_types, );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
