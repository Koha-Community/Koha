#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Output;
use Koha::AdditionalField;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "serials/add_fields.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { serials => '*' },
        debug           => 1,
    }
);

my $op = $input->param('op') // 'list';
my $field_id = $input->param('field_id');
my @messages;

if ( $op eq 'add' ) {
    my $name = $input->param('name') // q{};
    my $authorised_value_category = $input->param('authorised_value_category') // q{};
    my $marcfield = $input->param('marcfield') // q{};
    my $searchable = $input->param('searchable') ? 1 : 0;
    if ( $field_id and $name ) {
        my $updated = 0;
        eval {
            my $af = Koha::AdditionalField->new({
                id => $field_id,
                name => $name,
                authorised_value_category => $authorised_value_category,
                marcfield => $marcfield,
                searchable => $searchable,
            });
            $updated = $af->update;
        };
        push @messages, {
            code => 'update',
            number => $updated,
        };
    } elsif ( $name ) {
        my $inserted = 0;
        eval {
            my $af = Koha::AdditionalField->new({
                tablename => 'subscription',
                name => $name,
                authorised_value_category => $authorised_value_category,
                marcfield => $marcfield,
                searchable => $searchable,
            });
            $inserted = $af->insert;
        };
        push @messages, {
            code => 'insert',
            number => $inserted,
        };
    } else {
        push @messages, {
            code => 'insert',
            number => 0,
        };
    }
    $op = 'list';
}

if ( $op eq 'delete' ) {
    my $deleted = 0;
    eval {
        my $af = Koha::AdditionalField->new( { id => $field_id } );
        $deleted = $af->delete;
        $deleted = 0 if $deleted eq '0E0';
    };
    push @messages, {
        code => 'delete',
        number => $deleted,
    };
    $op = 'list';
}

if ( $op eq 'add_form' ) {
    my $categories = C4::Koha::GetAuthorisedValueCategories();
    my $field;
    if ( $field_id ) {
        $field = Koha::AdditionalField->new( { id => $field_id } )->fetch;
    }

    $template->param(
        field => $field,
        categories => $categories,
    );
}

if ( $op eq 'list' ) {
    my $fields = Koha::AdditionalField->all( { tablename => 'subscription' } );
    $template->param( fields => $fields );
}

$template->param(
    op => $op,
    messages => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
