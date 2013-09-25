#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
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

=head1 NAME

automatic_item_modification_by_age.pl: Update new status for items.

=cut

=head1 DESCRIPTION

This script allows a user to update the new status for items.

=cut

use Modern::Perl;

use CGI;
use JSON qw( to_json from_json );

use C4::Auth;
use C4::Context;
use C4::Items;
use C4::Output;
use C4::Koha;

my $cgi = new CGI;

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/automatic_item_modification_by_age.tt",
        query           => $cgi,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'items_batchmod' },
    }
);

my $op = $cgi->param('op') // 'show';

my $syspref_name = q|automatic_item_modification_by_age_configuration|;
if ( $op eq 'update' ) {
    my @rules;
    my @unique_ids = $cgi->param('unique_id');
    for my $unique_id ( @unique_ids ) {
        my @substitution_fields = $cgi->param("substitution_field_$unique_id");
        my @substitution_values = $cgi->param("substitution_value_$unique_id");
        my @condition_fields = $cgi->param("condition_field_$unique_id");
        my @condition_values = $cgi->param("condition_value_$unique_id");
        my $rule = {
            substitutions => [],
            conditions => [],
        };
        for my $value ( @substitution_values ) {
            my $field = shift @substitution_fields;
            last unless $field;
            push @{ $rule->{substitutions} }, { field => $field, value => $value };
        }
        push @{ $rule->{substitutions} }, {}
            unless @{ $rule->{substitutions} };
        for my $value ( @condition_values ) {
            my $field = shift @condition_fields;
            last unless $field;
            push @{ $rule->{conditions} }, { field => $field, value => $value };
        }
        push @{ $rule->{conditions} }, {}
            unless @{ $rule->{conditions} };
        $rule->{age} = $cgi->param("age_$unique_id");
        push @rules, $rule;
    }
    my $syspref_content = to_json( \@rules );
    C4::Context->set_preference($syspref_name, $syspref_content);

    $op = 'show';
}

my @messages;
my $syspref_content = C4::Context->preference($syspref_name);
my $rules;
$rules = eval { JSON::from_json( $syspref_content ) }
    if $syspref_content;
if ( $@ ) {
    push @messages, {
        type => 'error',
        code => 'unable_to_load_configuration'
    };
    $template->param( messages => \@messages );
    output_html_with_http_headers $cgi, $cookie, $template->output;
    exit;
}

my @item_fields = map { "items.$_" } C4::Items::columns;
my @biblioitem_fields = map { "biblioitems.$_" } C4::Items::biblioitems_columns;
$template->param(
    op => $op,
    messages => \@messages,
    condition_fields => [ @item_fields, @biblioitem_fields ],
    substitution_fields => \@item_fields,
    rules => $rules,
);

output_html_with_http_headers $cgi, $cookie, $template->output;
