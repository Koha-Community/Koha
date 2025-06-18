#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use CGI             qw ( -utf8 );
use List::MoreUtils qw( any );

use C4::Auth qw( get_template_and_user );
use C4::Context;
use C4::Koha   qw( getitemtypeimagelocation );
use C4::Output qw( output_html_with_http_headers );

use Koha::AuthorisedValues;
use Koha::AuthorisedValueCategories;
use Koha::Libraries;

my $input       = CGI->new;
my $id          = $input->param('id');
my $op          = $input->param('op') || 'list';
my $searchfield = $input->param('searchfield');
$searchfield = '' unless defined $searchfield;
$searchfield =~ s/\,//g;
my @messages;

our ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "admin/authorised_values.tt",
        flagsrequired => { parameters => 'manage_auth_values' },
        query         => $input,
        type          => "intranet",
    }
);

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ( $op eq 'add_form' or $op eq 'edit_form' ) {
    my ( @selected_branches, $category, $category_name, $av );
    if ($id) {
        $av                = Koha::AuthorisedValues->new->find($id);
        @selected_branches = $av->library_limits ? $av->library_limits->as_list : ();
    } else {
        $category_name = $input->param('category');
        $category      = Koha::AuthorisedValueCategories->find($category_name);
    }

    my $branches = Koha::Libraries->search( {}, { order_by => ['branchname'] } );
    my @branches_loop;
    while ( my $branch = $branches->next ) {
        push @branches_loop, {
            branchcode => $branch->branchcode,
            branchname => $branch->branchname,
            selected   => any { $_->branchcode eq $branch->branchcode } @selected_branches,
        };
    }

    if ($id) {
        $template->param( action_modify => 1 );
    } elsif ( !$category_name ) {
        $template->param( action_add_category => 1 );
    } else {
        $template->param( action_add_value => 1 );
    }

    if ($av) {
        $template->param(
            category_name => $av->category,
            av            => $av,
            imagesets     => C4::Koha::getImageSets( checked => $av->imageurl ),
        );
    } else {
        $template->param(
            category      => $category,
            category_name => $category_name,
            imagesets     => C4::Koha::getImageSets(),
        );
    }
    $template->param(
        branches_loop => \@branches_loop,
        num_pattern   => Koha::AuthorisedValue::NUM_PATTERN_JS(),
    );

} elsif ( $op eq 'cud-add' ) {
    my $new_authorised_value = $input->param('authorised_value');
    my $new_category         = $input->param('category');
    my $image                = $input->param('image') || '';
    my $imageurl =
        $image eq 'removeImage' ? ''
        : (
          $image eq 'remoteImage' ? $input->param('remoteImage')
        : $image
        );
    my $duplicate_entry = 0;
    my @branches        = grep { $_ ne q{} } $input->multi_param('branches');

    if ( $new_category eq 'branches' or $new_category eq 'itemtypes' or $new_category eq 'cn_source' ) {
        push @messages, { type => 'error', code => 'invalid_category_name' };
    } elsif ($id) {    # Update
        my $av = Koha::AuthorisedValues->new->find($id);

        $av->lib( scalar $input->param('lib')           || undef );
        $av->lib_opac( scalar $input->param('lib_opac') || undef );
        $av->category($new_category);
        $av->authorised_value($new_authorised_value);
        $av->imageurl($imageurl);
        eval {
            $av->store;
            $av->replace_library_limits( \@branches );
        };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {    # Insert
        eval {
            my $av = Koha::AuthorisedValue->new(
                {
                    category         => $new_category,
                    authorised_value => $new_authorised_value,
                    lib              => scalar $input->param('lib')      || undef,
                    lib_opac         => scalar $input->param('lib_opac') || undef,
                    imageurl         => $imageurl,
                }
            )->store;
            $av->replace_library_limits( \@branches );
            $av->store;
        };

        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }

    $op          = 'list';
    $searchfield = $new_category;
} elsif ( $op eq 'cud-add_category' ) {
    my $new_category    = $input->param('category');
    my $is_integer_only = $input->param('is_integer_only') ? 1 : 0;

    my $already_exists = Koha::AuthorisedValueCategories->find(
        {
            category_name => $new_category,
        }
    );

    if ($already_exists) {
        if ( $new_category eq 'branches' or $new_category eq 'itemtypes' or $new_category eq 'cn_source' ) {
            push @messages, { type => 'error', code => 'invalid_category_name' };
        } else {
            push @messages, { type => 'error', code => 'cat_already_exists' };
        }
    } else {    # Insert
        my $av = Koha::AuthorisedValueCategory->new(
            {
                category_name => $new_category, is_integer_only => $is_integer_only,
            }
        );

        eval { $av->store; };

        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert_cat' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert_cat' };
            $searchfield = $new_category;
        }
    }

    $op = 'list';
} elsif ( $op eq 'cud-edit_category' ) {
    my $category_name   = $input->param('category');
    my $is_integer_only = $input->param('is_integer_only') ? 1 : 0;
    my $category        = Koha::AuthorisedValueCategories->find($category_name);

    if ($category) {
        $category->is_integer_only($is_integer_only)->store;
    } else {
        push @messages, { type => 'error', code => 'error_on_edit_cat' };
    }

    $op = 'list';
} elsif ( $op eq 'cud-delete' ) {
    my $av      = Koha::AuthorisedValues->new->find($id);
    my $deleted = eval { $av->delete };
    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }

    $op = 'list';
} elsif ( $op eq 'cud-delete_category' ) {
    my $category_name = $input->param('category_name');
    my $avc           = Koha::AuthorisedValueCategories->find($category_name);
    my $deleted       = eval { $avc->delete };
    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete_category' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete_category' };
    }

    $op = 'list';
}

$template->param(
    op          => $op,
    searchfield => $searchfield,
    messages    => \@messages,
);

if ( $op eq 'list' ) {

    # build categories list
    my $category_rs = Koha::AuthorisedValueCategories->search(
        { category_name => { -not_in => [ '', 'branches', 'itemtypes', 'cn_source' ] } },
        { order_by      => ['category_name'] }
    );
    my @category_names = $category_rs->get_column('category_name');

    $searchfield ||= "";

    my @avs_by_category = Koha::AuthorisedValues->new->search( { category => $searchfield } )->as_list;
    my @loop_data       = ();
    my $category        = $category_rs->find($searchfield);
    my $is_integer_only = $category && $category->is_integer_only;

    # builds value list
    for my $av (@avs_by_category) {
        my %row_data;    # get a fresh hash for the row data
        $row_data{category}         = $av->category;
        $row_data{authorised_value} = $av->authorised_value;
        $row_data{lib}              = $av->lib;
        $row_data{lib_opac}         = $av->lib_opac;
        $row_data{image}            = getitemtypeimagelocation( 'intranet', $av->imageurl );
        $row_data{branches}         = $av->library_limits ? $av->library_limits->as_list : [];
        $row_data{id}               = $av->id;
        $row_data{is_integer_only}  = $is_integer_only;
        push( @loop_data, \%row_data );
    }

    $template->param(
        loop     => \@loop_data,
        category => Koha::AuthorisedValueCategories->find($searchfield)
        ,    # TODO Move this up and add a Koha::AVC->authorised_values method to replace call for avs_by_category
        category_names => \@category_names,
    );

}
output_html_with_http_headers $input, $cookie, $template->output;
