#! /usr/bin/perl
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

use CGI;
use List::MoreUtils qw/uniq/;

use C4::Auth;
use C4::Branch;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Members qw/GetBorrowercategoryList/;
use C4::Members::AttributeTypes;

my $script_name = "/cgi-bin/koha/admin/patron-attr-types.pl";

our $input = new CGI;
my $op = $input->param('op') || '';


our ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/patron-attr-types.tt",
                 query => $input,
                 type => "intranet",
                 authnotrequired => 0,
                 flagsrequired => {parameters => 'parameters_remaining_permissions'},
                 debug => 1,
                 });

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

    my $branches = GetBranches;
    my @branches_loop;
    foreach my $branch (sort keys %$branches) {
        push @branches_loop, {
            branchcode => $$branches{$branch}{branchcode},
            branchname => $$branches{$branch}{branchname},
        };
    }

    $template->param(
        attribute_type_form => 1,
        confirm_op => 'add_attribute_type_confirmed',
        categories => GetBorrowercategoryList,
        branches_loop => \@branches_loop,
    );
    authorised_value_category_list($template);
    pa_classes($template);
}

sub error_add_attribute_type_form {
    my $template = shift;

    $template->param(description => $input->param('description'));

    if ($input->param('repeatable')) {
        $template->param(repeatable_checked => 1);
    }
    if ($input->param('unique_id')) {
        $template->param(unique_id_checked => 1);
    }
    if ($input->param('password_allowed')) {
        $template->param(password_allowed_checked => 1);
    }
    if ($input->param('opac_display')) {
        $template->param(opac_display_checked => 1);
    }
    if ($input->param('staff_searchable')) {
        $template->param(staff_searchable_checked => 1);
    }
    if ($input->param('display_checkout')) {
        $template->param(display_checkout_checked => 'checked="checked"');
    }

    $template->param( category_code => $input->param('category_code') );
    $template->param( class => $input->param('class') );

    $template->param(
        attribute_type_form => 1,
        confirm_op => 'add_attribute_type_confirmed',
    );
    authorised_value_category_list($template, $input->param('authorised_value_category'));
}

sub add_update_attribute_type {
    my $op = shift;
    my $template = shift;
    my $code = shift;

    my $description = $input->param('description');

    my $attr_type;
    if ($op eq 'edit') {
        $attr_type = C4::Members::AttributeTypes->fetch($code);
        $attr_type->description($description);
    } else {
        my $existing = C4::Members::AttributeTypes->fetch($code);
        if (defined($existing)) {
            $template->param(duplicate_code_error => $code);
            error_add_attribute_type_form($template);
            return 0;
        }
        $attr_type = C4::Members::AttributeTypes->new($code, $description);
        my $repeatable = $input->param('repeatable');
        $attr_type->repeatable($repeatable);
        my $unique_id = $input->param('unique_id');
        $attr_type->unique_id($unique_id);
    }

    my $opac_display = $input->param('opac_display');
    $attr_type->opac_display($opac_display);
    my $staff_searchable = $input->param('staff_searchable');
    $attr_type->staff_searchable($staff_searchable);
    my $authorised_value_category = $input->param('authorised_value_category');
    $attr_type->authorised_value_category($authorised_value_category);
    my $password_allowed = $input->param('password_allowed');
    $attr_type->password_allowed($password_allowed);
    my $display_checkout = $input->param('display_checkout');
    $attr_type->display_checkout($display_checkout);
    $attr_type->category_code($input->param('category_code'));
    $attr_type->class($input->param('class'));
    my @branches = $input->param('branches');
    $attr_type->branches( \@branches );

    if ($op eq 'edit') {
        $template->param(edited_attribute_type => $attr_type->code());
    } else {
        $template->param(added_attribute_type => $attr_type->code());
    }
    $attr_type->store();

    return 1;
}

sub delete_attribute_type_form {
    my $template = shift;
    my $code = shift;

    my $attr_type = C4::Members::AttributeTypes->fetch($code);
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

    my $attr_type = C4::Members::AttributeTypes->fetch($code);
    if (defined($attr_type)) {
        if ($attr_type->num_patrons() > 0) {
            $template->param(ERROR_delete_in_use => $code);
            $template->param(ERROR_num_patrons => $attr_type->num_patrons());
        } else {
            $attr_type->delete();
            $template->param(deleted_attribute_type => $code);
        }
    } else {
        $template->param(ERROR_delete_not_found => $code);
    }
}

sub edit_attribute_type_form {
    my $template = shift;
    my $code = shift;

    my $attr_type = C4::Members::AttributeTypes->fetch($code);

    $template->param(code => $code);
    $template->param(description => $attr_type->description());
    $template->param(class => $attr_type->class());

    if ($attr_type->repeatable()) {
        $template->param(repeatable_checked => 1);
    }
    $template->param(repeatable_disabled => 1);
    if ($attr_type->unique_id()) {
        $template->param(unique_id_checked => 1);
    }
    $template->param(unique_id_disabled => 1);
    if ($attr_type->password_allowed()) {
        $template->param(password_allowed_checked => 1);
    }
    if ($attr_type->opac_display()) {
        $template->param(opac_display_checked => 1);
    }
    if ($attr_type->staff_searchable()) {
        $template->param(staff_searchable_checked => 1);
    }
    if ($attr_type->display_checkout()) {
        $template->param(display_checkout_checked => 'checked="checked"');
    }
    authorised_value_category_list($template, $attr_type->authorised_value_category());
    pa_classes( $template, $attr_type->class );


    my $branches = GetBranches;
    my @branches_loop;
    my $selected_branches = $attr_type->branches;
    foreach my $branch (sort keys %$branches) {
        my $selected = ( grep {$$_{branchcode} eq $branch} @$selected_branches ) ? 1 : 0;
        push @branches_loop, {
            branchcode => $branches->{$branch}{branchcode},
            branchname => $branches->{$branch}{branchname},
            selected => $selected,
        };
    }
    $template->param( branches_loop => \@branches_loop );

    $template->param ( category_code => $attr_type->category_code );
    $template->param ( category_description => $attr_type->category_description );

    $template->param(
        attribute_type_form => 1,
        edit_attribute_type => 1,
        confirm_op => 'edit_attribute_type_confirmed',
        categories => GetBorrowercategoryList,
    );

}

sub patron_attribute_type_list {
    my $template = shift;

    my @attr_types = C4::Members::AttributeTypes::GetAttributeTypes( 1, 1 );

    my @classes = uniq( map { $_->{class} } @attr_types );
    @classes = sort @classes;

    my @attributes_loop;
    for my $class (@classes) {
        my ( @items, $branches );
        for my $attr (@attr_types) {
            next if $attr->{class} ne $class;
            my $attr_type = C4::Members::AttributeTypes->fetch($attr->{code});
            $attr->{branches} = $attr_type->branches;
            push @items, $attr;
        }
        my $lib = GetAuthorisedValueByCode( 'PA_CLASS', $class ) || $class;
        push @attributes_loop, {
            class => $class,
            items => \@items,
            lib   => $lib,
            branches => $branches,
        };
    }
    $template->param(available_attribute_types => \@attributes_loop);
    $template->param(display_list => 1);
}

sub authorised_value_category_list {
    my $template = shift;
    my $selected = @_ ? shift : '';

    my $categories = GetAuthorisedValueCategories();
    my @list = ();
    foreach my $category (@$categories) {
        my $entry = { category => $category };
        $entry->{selected} = 1 if $category eq $selected;
        push @list, $entry;
    }
    $template->param(authorised_value_categories => \@list);
}

sub pa_classes {
    my $template = shift;
    my $selected = @_ ? shift : '';

    $template->param(classes_val_loop => GetAuthorisedValues( 'PA_CLASS', $selected ) );
}
