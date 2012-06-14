#!/usr/bin/perl

# Copyright Biblibre 2012
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Update::Database;

my $query = new CGI;
my $op = $query->param('op') || 'list';

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "admin/updatedatabase.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1 },
    }
);

if ( $op eq 'update' ) {
    my @versions = $query->param('version');
    @versions = sort {
        C4::Update::Database::TransformToNum( $a ) <=> C4::Update::Database::TransformToNum( $b )
    } @versions;

    my @reports;
    for my $version ( @versions ) {
        push @reports, C4::Update::Database::execute_version $version;
    }

    my @report_loop = map {
        my ( $v, $r ) = each %$_;
        my @errors = ref ( $r ) eq 'ARRAY'
            ?
                map {
                    { error => $_ }
                } @$r
            :
                { error => $r };
        {
            version => $v,
            report  => \@errors,
        }
    } @reports;
    $template->param( report_loop => \@report_loop );

    $op = 'list';
}

if ( $op eq 'mark_as_ok' ) {
    my @versions = $query->param('version');
    C4::Update::Database::mark_as_ok $_ for @versions;
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $versions_available = C4::Update::Database::list_versions_available;
    my $versions = C4::Update::Database::list_versions_already_applied;

    for my $v ( @$versions_available ) {
        if ( not grep { $v eq $$_{version} } @$versions ) {
            push @$versions, {
                version => $v,
                available => 1
            };
        }
    }
    my @sorted = sort {
        C4::Update::Database::TransformToNum( $$a{version} ) <=> C4::Update::Database::TransformToNum( $$b{version} )
    } @$versions;

    my @available = grep { defined $$_{available} and $$_{available} == 1 } @sorted;
    my @v_available = map { {version => $$_{version}} } @available;

    $template->param(
        dev_mode => $ENV{DEBUG},
        versions => \@sorted,
        nb_available => scalar @available,
        available => [ map { {version => $$_{version}} } @available ],
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
