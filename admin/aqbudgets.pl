#!/usr/bin/perl

#script to administer the aqbudget table

# Copyright 2008-2009 BibLibre SARL
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
use List::Util qw/min/;

use Koha::Database;
use C4::Auth qw/get_user_subpermissions/;
use C4::Branch; # GetBranches
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Auth;
use C4::Acquisition;
use C4::Budgets;
use C4::Members;  # calls GetSortDetails()
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Debug;

my $input = new CGI;
my $dbh     = C4::Context->dbh;

my ($template, $borrowernumber, $cookie, $staffflags ) = get_template_and_user(
    {   template_name   => "admin/aqbudgets.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'budget_manage' },
        debug           => 0,
    }
);

my $cur = GetCurrency();
$template->param( symbol => $cur->{symbol},
                  currency => $cur->{currency}
               );

my $op = $input->param('op') || 'list';

# see if the user want to see all budgets or only owned ones by default
my $show_mine = $input->param('show_mine') // 0;

# IF USER DOESNT HAVE PERM FOR AN 'ADD', THEN REDIRECT TO THE DEFAULT VIEW...
if (not defined $template->{VARS}->{'CAN_user_acquisition_budget_add_del'}
    and $op eq 'add_form')
{
    $op = 'list';
}

# get only the columns of aqbudgets in budget_hash
my @columns = Koha::Database->new()->schema->source('Aqbudget')->columns;
my $budget_hash = { map { join(' ',@columns) =~ /$_/ ? ( $_ => $input->param($_) )  : () } keys( %{$input->Vars()}) } ;

my $budget_id                 = $input->param('budget_id');
my $budget_period_id          = $input->param('budget_period_id');
my $budget_permission         = $input->param('budget_permission');
my $budget_users_ids          = $input->param('budget_users_ids');
my $filter_budgetbranch       = $input->param('filter_budgetbranch') // '';
my $filter_budgetname         = $input->param('filter_budgetname');


# ' ------- get periods stuff ------------------'
# IF PERIODID IS DEFINED,  GET THE PERIOD - ELSE JUST GET THE ACTIVE PERIOD BY DEFAULT
my $period;
if ( $budget_period_id ) {
    $period = GetBudgetPeriod( $budget_period_id );
}

# ------- get periods stuff ------------------

# USED FOR PERMISSION COMPARISON LATER
my $borrower_id         = $template->{VARS}->{'USER_INFO'}[0]->{'borrowernumber'};
my $user                = GetMemberDetails($borrower_id);
my $user_branchcode     = $user->{'branchcode'};

$template->param(
    show_mine   => $show_mine,
    op  => $op,
);

my $budget;

my $branchloop = C4::Branch::GetBranchesLoop($filter_budgetbranch);

$template->param(auth_cats_loop => GetBudgetAuthCats( $budget_period_id ))
    if $budget_period_id;

# Used to create form to add or  modify a record
if ($op eq 'add_form') {
#### ------------------- ADD_FORM -------------------------
    # if no buget_id is passed then its an add
    #  pass the period_id to build the dropbox - because we only want to show  budgets from this period
    my $dropbox_disabled;
    if (defined $budget_id ) {    ### MOD
        $budget = GetBudget($budget_id);
        if (!CanUserModifyBudget($borrowernumber, $budget, $staffflags)) {
            $template->param(error_not_authorised_to_modify => 1);
            output_html_with_http_headers $input, $cookie, $template->output;
            exit;
        }
        $dropbox_disabled = BudgetHasChildren($budget_id);
        my $borrower = &GetMember( borrowernumber=>$budget->{budget_owner_id} );
        $budget->{budget_owner_name} = ( $borrower ? $borrower->{'firstname'} . ' ' . $borrower->{'surname'} : '' );
    }

    # build budget hierarchy
    my %labels;
    my @values;
    my $hier = GetBudgetHierarchy($$period{budget_period_id});
    foreach my $r (@$hier) {
        $labels{"$r->{budget_id}"} = $r->{budget_code};
        push @values, $r->{budget_id};
    }
    push @values, '';
    # if no buget_id is passed then its an add
    my $budget_parent;
    my $budget_parent_id;
    if ($budget){
        $budget_parent_id = $budget->{'budget_parent_id'} ;
    }else{
        $budget_parent_id = $input->param('budget_parent_id');
    }
    $budget_parent = GetBudget($budget_parent_id);

    # build branches select
    my $branches = GetBranches;
    my @branchloop_select;
    foreach my $thisbranch ( sort keys %$branches ) {
        my %row = (
            value      => $thisbranch,
            branchname => $branches->{$thisbranch}->{'branchname'},
        );
        $row{selected} = 1 if $budget and $thisbranch eq $budget->{'budget_branchcode'};
        push @branchloop_select, \%row;
    }
    
    # populates the YUI planning button
    my $categories = GetAuthorisedValueCategories();
    my @auth_cats_loop1 = ();
    foreach my $category (@$categories) {
        my $entry = { category => $category,
                        selected => ( $budget and $budget->{sort1_authcat} eq $category ? 1 : 0 ),
                    };
        push @auth_cats_loop1, $entry;
    }
    my @auth_cats_loop2 = ();
    foreach my $category (@$categories) {
        my $entry = { category => $category,
                        selected => ( $budget and $budget->{sort2_authcat} eq $category ? 1 : 0 ),
                    };
        push @auth_cats_loop2, $entry;
    }
    $template->param(authorised_value_categories1 => \@auth_cats_loop1);
    $template->param(authorised_value_categories2 => \@auth_cats_loop2);

    if($budget->{'budget_permission'}){
        my $budget_permission = "budget_perm_".$budget->{'budget_permission'};
        $template->param($budget_permission => 1);
    }

    if ($budget) {
        my @budgetusers = GetBudgetUsers($budget->{budget_id});
        my @budgetusers_loop;
        foreach my $borrowernumber (@budgetusers) {
            my $member = C4::Members::GetMember(
                borrowernumber => $borrowernumber);
            push @budgetusers_loop, {
                firstname => $member->{firstname},
                surname => $member->{surname},
                borrowernumber => $borrowernumber
            };
        }
        $template->param(
            budget_users => \@budgetusers_loop,
            budget_users_ids => join ':', @budgetusers
        );
    }

    # if no buget_id is passed then its an add
    $template->param(
        budget_has_children => BudgetHasChildren( $budget->{budget_id} ),
        budget_parent_id    		  => $budget_parent->{'budget_id'},
        budget_parent_name    		  => $budget_parent->{'budget_name'},
        branchloop_select         => \@branchloop_select,
		%$period,
		%$budget,
    );
                                                    # END $OP eq ADD_FORM
#---------------------- DEFAULT DISPLAY BELOW ---------------------

# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {

    my $budget = GetBudget($budget_id);
    $template->param(
        budget_id     => $budget->{'budget_id'},
        budget_code   => $budget->{'budget_code'},
        budget_name   => $budget->{'budget_name'},
        budget_amount => $budget->{'budget_amount'},
    );
                                                    # END $OP eq DELETE_CONFIRM
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ( $op eq 'delete_confirmed' ) {
    if ( BudgetHasChildren( $budget_id ) ) {
        # We should never be here, the interface does not provide this action.
        die("Delete a fund with children is not possible");
    }
    my $rc = DelBudget($budget_id);
    $op = 'list';
} elsif( $op eq 'add_validate' ) {
    my @budgetusersid;
    if (defined $budget_users_ids){
        @budgetusersid = split(':', $budget_users_ids);
    }

    my $budget_modified = 0;
    if (defined $budget_id) {
        if (CanUserModifyBudget($borrowernumber, $budget_hash->{budget_id},
            $staffflags)
        ) {
            ModBudget( $budget_hash );
            ModBudgetUsers($budget_hash->{budget_id}, @budgetusersid);
            $budget_modified = 1;
        }
        else {
            $template->param(error_not_authorised_to_modify => 1);
        }
    } else {
        $budget_hash->{budget_id} = AddBudget( $budget_hash );
        ModBudgetUsers($budget_hash->{budget_id}, @budgetusersid);
        $budget_modified = 1;
    }

    my $set_owner_to_children = $input->param('set_owner_to_children');
    if ( $set_owner_to_children and $budget_modified ) {
        C4::Budgets::SetOwnerToFundHierarchy( $budget_hash->{budget_id}, $budget_hash->{budget_owner_id} );
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    my $branches = GetBranches();
    $template->param(
        budget_id => $budget_id,
        %$period,
    );

    my @budgets = @{
        GetBudgetHierarchy($$period{budget_period_id},
            C4::Context->userenv->{branchcode}, $show_mine ? $borrower_id : '')
    };

    my $period_total = 0;
    my ($period_alloc_total, $spent_total, $ordered_total, $available_total) = (0,0,0,0);

	#This Looks WEIRD to me : should budgets be filtered in such a way ppl who donot own it would not see the amount spent on the budget by others ?

    my @budgets_to_display;
    foreach my $budget (@budgets) {
        # PERMISSIONS
        unless(CanUserModifyBudget($borrowernumber, $budget, $staffflags)) {
            $budget->{'budget_lock'} = 1;
        }

        # if a budget search doesnt match, next
        if ($filter_budgetname) {
            next
              unless $budget->{budget_code} =~ m/$filter_budgetname/i
                  || $budget->{budget_name} =~ m/$filter_budgetname/i;
        }
        if ($filter_budgetbranch ) {
            next unless  $budget->{budget_branchcode} eq $filter_budgetbranch;
        }

## TOTALS
        $budget->{'budget_remaining'} = $budget->{'budget_amount'} - $budget->{'budget_spent'} - $budget->{budget_ordered};
        $budget->{'total_remaining'} = $budget->{'budget_amount'} - $budget->{'total_spent'} - $budget->{total_ordered};
        # adds to total  - only if budget is a 'top-level' budget
        unless ( defined $budget->{budget_parent_id} ) {
            $period_alloc_total += $budget->{'budget_amount'};
            $spent_total += $budget->{total_spent};
            $ordered_total += $budget->{total_ordered};
            $available_total += $budget->{total_remaining};
        }

# if amount == 0 dont display...
        delete $budget->{'budget_unalloc_sublevel'}
            if (!defined $budget->{'budget_unalloc_sublevel'}
            or $budget->{'budget_unalloc_sublevel'} == 0);

        # Value of budget_spent equals 0 instead of undefined value
        $budget->{budget_spent} = 0 unless defined($budget->{budget_spent});
        $budget->{budget_ordered} = 0 unless defined($budget->{budget_ordered});

        #Make a list of parents of the bugdet
        my @budget_hierarchy;
        push  @budget_hierarchy, { element_name => $budget->{"budget_name"}, element_id => $budget->{"budget_id"} };
        my $parent_id = $budget->{"budget_parent_id"};
        while ($parent_id) {
            my $parent = GetBudget($parent_id);
            push @budget_hierarchy, { element_name => $parent->{"budget_name"}, element_id => $parent->{"budget_id"} };
            $parent_id = $parent->{"budget_parent_id"};
        }
        push  @budget_hierarchy, { element_name => $period->{"budget_period_description"} };
        @budget_hierarchy = reverse(@budget_hierarchy);

        $budget->{budget_hierarchy} = \@budget_hierarchy;

        $budget->{budget_has_children} = BudgetHasChildren( $budget->{budget_id} );
        push @budgets_to_display, $budget;
    }

    my $budget_period_total = $period->{budget_period_total};

    my $periods = GetBudgetPeriods();

    $template->param(
        op                     => 'list',
        budgets                => \@budgets_to_display,
        periods                => $periods,
        budget_period_total    => $budget_period_total,
        period_alloc_total     => $period_alloc_total,
        spent_total            => $spent_total,
        ordered_total          => $ordered_total,
        available_total        => $available_total,
        branchloop             => $branchloop,
        filter_budgetname      => $filter_budgetname,
    );

} #---- END list

output_html_with_http_headers $input, $cookie, $template->output;
