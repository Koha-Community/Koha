#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2002 Paul Poulain
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
use Koha::Biblios;
use Koha::BiblioFramework;
use Koha::BiblioFrameworks;
use Koha::Cache;

my $input         = new CGI;
my $frameworkcode = $input->param('frameworkcode') || q||;
my $op            = $input->param('op') || q|list|;
my $cache         = Koha::Cache->get_instance();
my @messages;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/biblio_framework.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'parameters_remaining_permissions' },
        debug           => 1,
    }
);

my $dbh = C4::Context->dbh;
if ( $op eq 'add_form' ) {
    my $framework;
    if ($frameworkcode) {
        $framework = Koha::BiblioFrameworks->find($frameworkcode);
    }
    $template->param( framework => $framework );
} elsif ( $op eq 'add_validate' ) {
    my $frameworkcode = $input->param('frameworkcode');
    my $frameworktext = $input->param('frameworktext');
    my $is_a_modif    = $input->param('is_a_modif');

    if ($is_a_modif) {
        my $framework = Koha::BiblioFrameworks->find($frameworkcode);
        $framework->frameworktext($frameworktext);
        eval { $framework->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {
        my $framework = Koha::BiblioFramework->new(
            {   frameworkcode => $frameworkcode,
                frameworktext => $frameworktext,
            }
        );
        eval { $framework->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }
    $cache->clear_from_cache("MarcStructure-0-$frameworkcode");
    $cache->clear_from_cache("MarcStructure-1-$frameworkcode");
    $cache->clear_from_cache("default_value_for_mod_marc-$frameworkcode");
    $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
    $op = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    my $framework = Koha::BiblioFrameworks->find($frameworkcode);
    my $count = Koha::Biblios->search( { frameworkcode => $frameworkcode, } )->count;

    $template->param(
        framework                  => $framework,
        biblios_use_this_framework => $count,
    );
} elsif ( $op eq 'delete_confirmed' ) {
    my $framework = Koha::BiblioFrameworks->find($frameworkcode);
    my $deleted = eval { $framework->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    } else {
        eval {
            my $dbh = C4::Context->dbh;
            $dbh->do( q|DELETE FROM marc_tag_structure WHERE frameworkcode=?|,      undef, $frameworkcode );
            $dbh->do( q|DELETE FROM marc_subfield_structure WHERE frameworkcode=?|, undef, $frameworkcode );
        };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_delete_fk' };
        } else {
            push @messages, { type => 'message', code => 'success_on_delete' };
        }
    }
    $cache->clear_from_cache("MarcStructure-0-$frameworkcode");
    $cache->clear_from_cache("MarcStructure-1-$frameworkcode");
    $cache->clear_from_cache("default_value_for_mod_marc-$frameworkcode");
    $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $frameworks = Koha::BiblioFrameworks->search( {}, { order_by => ['frameworktext'], } );
    $template->param( frameworks => $frameworks, );
}

$template->param(
    messages => \@messages,
    op       => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;

