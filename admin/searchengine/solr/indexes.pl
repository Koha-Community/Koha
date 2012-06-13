#!/usr/bin/perl

# Copyright 2012 BibLibre SARL
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
use C4::Koha;
use C4::Output;
use C4::Auth;
use Koha::SearchEngine;

my $input = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => 'admin/searchengine/solr/indexes.tt',
        query           => $input,
        type            => 'intranet',
#        authnotrequired => 0,
#        flagsrequired   => { reserveforothers => "place_holds" }, #TODO
    }
);

my $ressource_type = $input->param('ressource_type') || 'biblio';
my $se = Koha::SearchEngine->new;
my $se_config = $se->config;

my $indexes;
if ( $input->param('op') and $input->param('op') eq 'edit' ) {
    my @code            = $input->param('code');
    my @label           = $input->param('label');
    my @type            = $input->param('type');
    my @sortable        = $input->param('sortable');
    my @facetable       = $input->param('facetable');
    my @mandatory       = $input->param('mandatory');
    my @ressource_type  = $input->param('ressource_type');
    my @mappings        = $input->param('mappings');
    my @indexes;
    my @errors;
    for ( 0 .. @code-1 ) {
        my $icode = $code[$_];
        my @current_mappings = split /\r\n/, $mappings[$_];
        if ( not @current_mappings ) {
            @current_mappings = split /\n/, $mappings[$_];
        }
        if ( not @current_mappings ) {
            push @errors, { type => 'no_mapping', value => $icode};
        }

        push @indexes, {
            code           => $icode,
            label          => $label[$_],
            type           => $type[$_],
            sortable       => scalar(grep(/^$icode$/, @sortable)),
            facetable      => scalar(grep(/^$icode$/, @facetable)),
            mandatory      => $mandatory[$_] eq '1' ? '1' : '0',
            ressource_type => $ressource_type[$_],
            mappings       => \@current_mappings,
        };
        for my $m ( @current_mappings ) {
            push @errors, {type => 'malformed_mapping', value => $m}
                if not $m =~ /^\d(\d|\*|\.){2}\$.$/;
        }
    }
    $indexes = \@indexes if @errors;
    $template->param( errors => \@errors );

    $se_config->indexes(\@indexes) if not @errors;
}

my $ressource_types = $se_config->ressource_types;
$indexes //= $se_config->indexes;

my $indexloop;
for my $rt ( @$ressource_types ) {
    my @indexes = map {
        $_->{ressource_type} eq $rt ? $_ : ();
    } @$indexes;
    push @$indexloop, {
        ressource_type => $rt,
        indexes => \@indexes,
    }
}

$template->param(
    indexloop       => $indexloop,
);

output_html_with_http_headers $input, $cookie, $template->output;
