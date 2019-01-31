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
use C4::Form::MessagingPreferences;
use Koha::Patrons;
use Koha::Database;
use Koha::DateUtils;
use Koha::Patron::Categories;
use Koha::Libraries;

my $input         = new CGI;
my $searchfield   = $input->param('description') // q||;
my $categorycode  = $input->param('categorycode');
my $op            = $input->param('op') // 'list';
my @messages;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "admin/categories.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 'manage_patron_categories' },
        debug           => 1,
    }
);

if ( $op eq 'add_form' ) {
    my ( $category, $selected_branches );
    if ($categorycode) {
        $category          = Koha::Patron::Categories->find($categorycode);
        $selected_branches = $category->branch_limitations;
    }

    my $branches = Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
    my @branches_loop;
    foreach my $branch ( @$branches ) {
        my $selected = ( grep { $_ eq $branch->{branchcode} } @$selected_branches ) ? 1 : 0;
        push @branches_loop,
          { branchcode => $branch->{branchcode},
            branchname => $branch->{branchname},
            selected   => $selected,
          };
    }

    $template->param(
        category => $category,
        branches_loop       => \@branches_loop,
    );

    if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
        C4::Form::MessagingPreferences::set_form_values(
            { categorycode => $categorycode }, $template );
    }
}
elsif ( $op eq 'add_validate' ) {

    my $categorycode = $input->param('categorycode');
    my $description = $input->param('description');
    my $enrolmentperiod = $input->param('enrolmentperiod');
    my $enrolmentperioddate = $input->param('enrolmentperioddate') || undef;
    my $upperagelimit = $input->param('upperagelimit');
    my $dateofbirthrequired = $input->param('dateofbirthrequired');
    my $enrolmentfee = $input->param('enrolmentfee');
    my $reservefee = $input->param('reservefee');
    my $hidelostitems = $input->param('hidelostitems');
    my $overduenoticerequired = $input->param('overduenoticerequired');
    my $category_type = $input->param('category_type');
    my $BlockExpiredPatronOpacActions = $input->param('BlockExpiredPatronOpacActions');
    my $checkPrevCheckout = $input->param('checkprevcheckout');
    my $default_privacy = $input->param('default_privacy');
    my $can_reset_password = $input->param('can_reset_password');
    my @branches = grep { $_ ne q{} } $input->multi_param('branches');

    my $is_a_modif = $input->param("is_a_modif");

    if ($enrolmentperioddate) {
        $enrolmentperioddate = output_pref(
            {
                dt         => dt_from_string($enrolmentperioddate),
                dateformat => 'iso',
                dateonly   => 1,
            }
        );
    }

    if ($is_a_modif) {
        my $category = Koha::Patron::Categories->find( $categorycode );
        $category->categorycode($categorycode);
        $category->description($description);
        $category->enrolmentperiod($enrolmentperiod);
        $category->enrolmentperioddate($enrolmentperioddate);
        $category->upperagelimit($upperagelimit);
        $category->dateofbirthrequired($dateofbirthrequired);
        $category->enrolmentfee($enrolmentfee);
        $category->reservefee($reservefee);
        $category->hidelostitems($hidelostitems);
        $category->overduenoticerequired($overduenoticerequired);
        $category->category_type($category_type);
        $category->BlockExpiredPatronOpacActions($BlockExpiredPatronOpacActions);
        $category->checkprevcheckout($checkPrevCheckout);
        $category->default_privacy($default_privacy);
        $category->can_reset_password($can_reset_password);
        eval {
            $category->store;
            $category->replace_branch_limitations( \@branches );
        };
        if ( $@ ) {
            push @messages, {type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    }
    else {
        my $category = Koha::Patron::Category->new({
            categorycode => $categorycode,
            description => $description,
            enrolmentperiod => $enrolmentperiod,
            enrolmentperioddate => $enrolmentperioddate,
            upperagelimit => $upperagelimit,
            dateofbirthrequired => $dateofbirthrequired,
            enrolmentfee => $enrolmentfee,
            reservefee => $reservefee,
            hidelostitems => $hidelostitems,
            overduenoticerequired => $overduenoticerequired,
            category_type => $category_type,
            BlockExpiredPatronOpacActions => $BlockExpiredPatronOpacActions,
            checkprevcheckout => $checkPrevCheckout,
            default_privacy => $default_privacy,
            can_reset_password => $can_reset_password,
        });
        eval {
            $category->store;
            $category->replace_branch_limitations( \@branches );
        };

        if ( $@ ) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }

    if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
        C4::Form::MessagingPreferences::handle_form_action( $input,
            { categorycode => scalar $input->param('categorycode') }, $template );
    }

    $searchfield = q||;
    $op = 'list';
}
elsif ( $op eq 'delete_confirm' ) {

    my $count = Koha::Patrons->search({
        categorycode => $categorycode
    })->count;

    my $category = Koha::Patron::Categories->find($categorycode);

    $template->param(
        category => $category,
        patrons_in_category => $count,
    );

}
elsif ( $op eq 'delete_confirmed' ) {
    my $categorycode = uc( $input->param('categorycode') );

    my $category = Koha::Patron::Categories->find( $categorycode );
    my $deleted = eval { $category->delete; };

    if ( $@ or not $deleted ) {
        push @messages, {type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }

    $op = 'list';
}

if ( $op eq 'list' ) {
    my $categories = Koha::Patron::Categories->search(
        {
            description => { -like => "$searchfield%" }
        },
        {
            order_by => ['category_type', 'description', 'categorycode' ]
        }
    );

    $template->param(
        categories => $categories,
    )
}

$template->param(
    categorycode => $categorycode,
    searchfield  => $searchfield,
    messages     => \@messages,
    op => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;

exit 0;
