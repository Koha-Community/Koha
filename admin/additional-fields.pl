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
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::AdditionalFields;

my $input = CGI->new;

my %flagsrequired;
$flagsrequired{parameters} = 'manage_additional_fields';

my $tablename = $input->param('tablename');
my $op = $input->param('op') // ( $tablename ? 'list' : 'list_tables' );

if( $op ne 'list_tables' ){
    $flagsrequired{acquisition} = 'order_manage' if $tablename eq 'aqbasket';
    $flagsrequired{serials} = 'edit_subscription' if $tablename eq 'subscription';
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/additional-fields.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired   => \%flagsrequired,
    }
);

my $field_id = $input->param('field_id');
my @messages;

if ( $op eq 'add' ) {
    my $name = $input->param('name') // q{};
    my $authorised_value_category = $input->param('authorised_value_category') // q{};
    my $marcfield = $input->param('marcfield') // q{};
    my $marcfield_mode = $input->param('marcfield_mode') // 'get';
    my $searchable = $input->param('searchable') ? 1 : 0;
    if ( $field_id and $name ) {
        my $updated = 0;
        eval {
            my $af = Koha::AdditionalFields->find($field_id);
            $af->set({
                name => $name,
                authorised_value_category => $authorised_value_category,
                marcfield => $marcfield,
                marcfield_mode => $marcfield_mode,
                searchable => $searchable,
            });
            $updated = $af->store ? 1 : 0;
        };
        push @messages, {
            code => 'update',
            number => $updated,
        };
    } elsif ( $name ) {
        my $inserted = 0;
        eval {
            my $af = Koha::AdditionalField->new({
                tablename => $tablename,
                name => $name,
                authorised_value_category => $authorised_value_category,
                marcfield => $marcfield,
                marcfield_mode => $marcfield_mode,
                searchable => $searchable,
            });
            $inserted = $af->store ? 1 : 0;
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
        my $af = Koha::AdditionalFields->find($field_id);
        $deleted = $af->delete;
    };
    push @messages, {
        code => 'delete',
        number => $deleted,
    };
    $op = 'list';
}

if ( $op eq 'add_form' ) {
    my $field;
    if ( $field_id ) {
        $field = Koha::AdditionalFields->find($field_id);
    }

    $tablename = $field->tablename if $field;

    $template->param(
        field => $field,
    );
}

if ( $op eq 'list' ) {
    my $fields = Koha::AdditionalFields->search( { tablename => $tablename } );
    $template->param( fields => $fields );
}

$template->param(
    op => $op,
    tablename => $tablename,
    messages => \@messages,
);

output_html_with_http_headers $input, $cookie, $template->output;
