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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Context;
use C4::Koha;
use C4::Output;

use Koha::AuthorisedValues;
use Koha::Libraries;

my $input = new CGI;
my $id          = $input->param('id');
my $op          = $input->param('op') || 'list';
my $searchfield = $input->param('searchfield');
$searchfield = '' unless defined $searchfield;
$searchfield =~ s/\,//g;
my @messages;

our ($template, $borrowernumber, $cookie)= get_template_and_user({
    template_name => "admin/authorised_values.tt",
    authnotrequired => 0,
    flagsrequired => {parameters => 'parameters_remaining_permissions'},
    query => $input,
    type => "intranet",
    debug => 1,
});

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
    my ( $selected_branches, $category, $av );
    if ($id) {
        $av = Koha::AuthorisedValues->new->find( $id );
        $selected_branches = $av->branch_limitations;
    } else {
        $category = $input->param('category');
    }

    my $branches = Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
    my @branches_loop;
    foreach my $branch ( @$branches ) {
        my $selected = ( grep {$_ eq $branch->{branchcode}} @$selected_branches ) ? 1 : 0;
        push @branches_loop, {
            branchcode => $branch->{branchcode},
            branchname => $branch->{branchname},
            selected   => $selected,
        };
    }

	if ($id) {
		$template->param(action_modify => 1);
   } elsif ( ! $category ) {
		$template->param(action_add_category => 1);
	} else {
		$template->param(action_add_value => 1);
	}

    if ( $av ) {
        $template->param(
            category => $av->category,
            authorised_value => $av->authorised_value,
            lib              => $av->lib,
            lib_opac         => $av->lib_opac,
            id               => $av->id,
            imagesets        => C4::Koha::getImageSets( checked => $av->imageurl ),
        );
    } else {
        $template->param(
            category  => $category,
            imagesets => C4::Koha::getImageSets(),
        );
    }
    $template->param(
        branches_loop    => \@branches_loop,
    );

} elsif ($op eq 'add') {
    my $new_authorised_value = $input->param('authorised_value');
    my $new_category = $input->param('category');
    my $imageurl     = $input->param( 'imageurl' ) || '';
    $imageurl = '' if $imageurl =~ /removeImage/;
    my $duplicate_entry = 0;
    my @branches = grep { $_ ne q{} } $input->multi_param('branches');

    my $already_exists = Koha::AuthorisedValues->search(
        {
            category => $new_category,
            authorised_value => $new_authorised_value,
        }
    )->next;

    if ( $already_exists and ( not $id or $already_exists->id != $id ) ) {
        push @messages, {type => 'error', code => 'already_exists' };
    }
    elsif ( $id ) { # Update
        my $av = Koha::AuthorisedValues->new->find( $id );

        $av->lib( $input->param('lib') || undef );
        $av->lib_opac( $input->param('lib_opac') || undef );
        $av->category( $new_category );
        $av->authorised_value( $new_authorised_value );
        $av->imageurl( $imageurl );
        eval{
            $av->store;
            $av->replace_branch_limitations( \@branches );
        };
        if ( $@ ) {
            push @messages, {type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    }
    else { # Insert
        my $av = Koha::AuthorisedValue->new( {
            category => $new_category,
            authorised_value => $new_authorised_value,
            lib => scalar $input->param('lib') || undef,
            lib_opac => scalar $input->param('lib_opac') || undef,
            imageurl => $imageurl,
        } );

        eval {
            $av->store;
            $av->replace_branch_limitations( \@branches );
        };

        if ( $@ ) {
            push @messages, {type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }

    $op = 'list';
    $searchfield = $new_category;
} elsif ($op eq 'delete') {
    my $av = Koha::AuthorisedValues->new->find( $input->param('id') );
    my $deleted = eval {$av->delete};
    if ( $@ or not $deleted ) {
        push @messages, {type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }

    $op = 'list';
    $template->param( delete_success => 1 );
}

$template->param(
    op => $op,
    searchfield => $searchfield,
    messages => \@messages,
);

if ( $op eq 'list' ) {
    # build categories list
    my @categories = Koha::AuthorisedValues->new->categories;
    my @category_list;
    my %categories;    # a hash, to check that some hardcoded categories exist.
    for my $category ( @categories ) {
        push( @category_list, $category );
        $categories{$category} = 1;
    }

    # push koha system categories
    foreach (qw(Asort1 Asort2 Bsort1 Bsort2 SUGGEST DAMAGED LOST REPORT_GROUP REPORT_SUBGROUP DEPARTMENT TERM SUGGEST_STATUS ITEMTYPECAT)) {
        push @category_list, $_ unless $categories{$_};
    }

    #reorder the list
    @category_list = sort {$a cmp $b} @category_list;

    $searchfield ||= $category_list[0];

    my @avs_by_category = Koha::AuthorisedValues->new->search( { category => $searchfield } );
    my @loop_data = ();
    # builds value list
    for my $av ( @avs_by_category ) {
        my %row_data;  # get a fresh hash for the row data
        $row_data{category}              = $av->category;
        $row_data{authorised_value}      = $av->authorised_value;
        $row_data{lib}                   = $av->lib;
        $row_data{lib_opac}              = $av->lib_opac;
        $row_data{imageurl}              = getitemtypeimagelocation( 'intranet', $av->imageurl );
        $row_data{branches}              = $av->branch_limitations;
        $row_data{id}                    = $av->id;
        push(@loop_data, \%row_data);
    }

    $template->param(
        loop     => \@loop_data,
        category => $searchfield,
        categories => \@category_list,
    );

}
output_html_with_http_headers $input, $cookie, $template->output;
