#!/usr/bin/perl
#
# Copyright 2008 LibLime
# Parts copyright 2010 BibLibre
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
#

use Modern::Perl;

use CGI qw ( -utf8 );
use List::MoreUtils qw( uniq );

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use Koha::Patron::Attribute::Types;

use Koha::AuthorisedValues;
use Koha::Libraries;
use Koha::Patron::Categories;

my $script_name = "/cgi-bin/koha/admin/patron-attr-types.pl";

our $input = CGI->new;
my $op = $input->param('op') || '';


my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "admin/patron-attr-types.tt",
        query           => $input,
        type            => "intranet",
        flagsrequired => { parameters => 'manage_patron_attributes' }
    }
);


$template->param(script_name => $script_name);

my $code = $input->param("code");

my $display_list = 0;
if ($op eq "edit_attribute_type") {
    edit_attribute_type_form($template, $code);
} elsif ($op eq "edit_attribute_type_confirmed") {
    $display_list = add_update_attribute_type('edit', $template, $code);
} elsif ($op eq "add_attribute_type") {
    add_attribute_type_form($template);
} elsif ($op eq "add_attribute_type_confirmed") {
    $display_list = add_update_attribute_type('add', $template, $code);
} elsif ($op eq "delete_attribute_type") {
    $display_list = delete_attribute_type_form($template, $code);
} elsif ($op eq "delete_attribute_type_confirmed") {
    delete_attribute_type($template, $code);
    $display_list = 1;
} else {
    $display_list = 1;
}

if ($display_list) {
    unless (C4::Context->preference('ExtendedPatronAttributes')) {
        $template->param(WARNING_extended_attributes_off => 1); 
    }
    patron_attribute_type_list($template);
}

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;

sub add_attribute_type_form {
    my $template = shift;

    my $patron_categories = Koha::Patron::Categories->search_with_library_limits({}, {order_by => ['description']});
    $template->param(
        attribute_type_form => 1,
        confirm_op => 'add_attribute_type_confirmed',
        categories => $patron_categories,
    );
}

sub error_add_attribute_type_form {
    my $template = shift;

    $template->param(description => scalar $input->param('description'));
    $template->param( category_code => scalar $input->param('category_code') );
    $template->param( class => scalar $input->param('class') );

    $template->param(
        attribute_type_form => 1,
        confirm_op => 'add_attribute_type_confirmed',
        authorised_value_category => scalar $input->param('authorised_value_category'),
    );
}

sub add_update_attribute_type {
    my $op       = shift;
    my $template = shift;
    my $code     = shift;

    my $description               = $input->param('description');
    my $repeatable                = $input->param('repeatable') ? 1 : 0;
    my $unique_id                 = $input->param('unique_id') ? 1 : 0;
    my $opac_display              = $input->param('opac_display') ? 1 : 0;
    my $opac_editable             = $input->param('opac_editable') ? 1 : 0;
    my $staff_searchable          = $input->param('staff_searchable') ? 1 : 0;
    my $keep_for_pseudonymization = $input->param('keep_for_pseudonymization') ? 1 : 0;
    my $mandatory                 = $input->param('mandatory') ? 1 : 0;
    my $authorised_value_category = $input->param('authorised_value_category');
    my $display_checkout          = $input->param('display_checkout') ? 1 : 0;
    my $category_code             = $input->param('category_code') || undef;
    my $class                     = $input->param('class');

    my $attr_type = Koha::Patron::Attribute::Types->find($code);
    if ( $op eq 'edit' ) {
        $attr_type->description($description);
    }
    else {
        if ($attr_type) {    # Already exists
            $template->param( duplicate_code_error => $code );

            # FIXME Regression here
            # Form will not be refilled with entered values on error
            error_add_attribute_type_form($template);
            return 0;
        }
        $attr_type = Koha::Patron::Attribute::Type->new(
            {
                code        => $code,
                description => $description,
            }
        );
    }

    $attr_type->set(
        {
            repeatable                => $repeatable,
            unique_id                 => $unique_id,
            opac_display              => $opac_display,
            opac_editable             => $opac_editable,
            staff_searchable          => $staff_searchable,
            keep_for_pseudonymization => $keep_for_pseudonymization,
            mandatory                 => $mandatory,
            authorised_value_category => $authorised_value_category,
            display_checkout          => $display_checkout,
            category_code             => $category_code,
            class                     => $class,
        }
    )->store;

    my @branches = grep { ! /^\s*$/ } $input->multi_param('branches');
    $attr_type->library_limits( \@branches );

    if ( $op eq 'edit' ) {
        $template->param( edited_attribute_type => $attr_type->code() );
    }
    else {
        $template->param( added_attribute_type => $attr_type->code() );
    }

    return 1;
}

sub delete_attribute_type_form {
    my $template = shift;
    my $code = shift;

    my $attr_type = Koha::Patron::Attribute::Types->find($code);
    my $display_list = 0;
    if (defined($attr_type)) {
        $template->param(
            delete_attribute_type_form => 1,
            confirm_op => "delete_attribute_type_confirmed",
            code => $code,
            description => $attr_type->description(),
        );
    } else {
        $template->param(ERROR_delete_not_found => $code);
        $display_list = 1;
    }
    return $display_list;
}

sub delete_attribute_type {
    my $template = shift;
    my $code = shift;

    my $attr_type = Koha::Patron::Attribute::Types->find($code);
    if (defined($attr_type)) {
        # TODO Check must be done for previous step as well
        if ( my $num_patrons = Koha::Patrons->filter_by_attribute_type($code)->count ) {
            $template->param(ERROR_delete_in_use => $code);
            $template->param(ERROR_num_patrons => $num_patrons );
        } else {
            $attr_type->delete();
            $template->param(deleted_attribute_type => $code);
        }
    } else {
        # FIXME Really needed?
        $template->param(ERROR_delete_not_found => $code);
    }
}

sub edit_attribute_type_form {
    my $template = shift;
    my $code = shift;

    my $attr_type = Koha::Patron::Attribute::Types->find($code);

    my $patron_categories = Koha::Patron::Categories->search({}, {order_by => ['description']});

    my $can_be_set_to_nonrepeatable = 1;
    if ( $attr_type->repeatable == 1 ) {
        $attr_type->repeatable(0);
        eval {$attr_type->check_repeatables};
        $can_be_set_to_nonrepeatable = 0 if $@;
        $attr_type->repeatable(1);
    }
    my $can_be_set_to_unique = 1;
    if ( $attr_type->unique_id == 0 ) {
        $attr_type->unique_id(1);
        eval {$attr_type->check_unique_ids};
        $can_be_set_to_unique = 0 if $@;
        $attr_type->unique_id(0);
    }
    $template->param(
        attribute_type => $attr_type,
        attribute_type_form => 1,
        edit_attribute_type => 1,
        can_be_set_to_nonrepeatable => $can_be_set_to_nonrepeatable,
        can_be_set_to_unique => $can_be_set_to_unique,
        confirm_op => 'edit_attribute_type_confirmed',
        categories => $patron_categories,
    );

}

sub patron_attribute_type_list {
    my $template = shift;

    my @attr_types = Koha::Patron::Attribute::Types->search->as_list;

    my @classes = uniq( map { $_->class } @attr_types );
    @classes = sort @classes;

    my @attributes_loop;
    # FIXME This is not efficient and should be improved
    for my $class (@classes) {
        my @items;
        for my $attr (@attr_types) {
            next if $attr->class ne $class;
            push @items, $attr;
        }
        my $av = Koha::AuthorisedValues->search({ category => 'PA_CLASS', authorised_value => $class });
        my $lib = $av->count ? $av->next->lib : $class;
        push @attributes_loop, {
            class => $class,
            items => \@items,
            lib   => $lib,
        };
    }
    $template->param(available_attribute_types => \@attributes_loop);
    $template->param(display_list => 1);
}
