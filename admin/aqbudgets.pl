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

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use List::Util qw/min/;
use Number::Format qw(format_price);

use C4::Auth qw/get_user_subpermissions/;
use C4::Branch; # GetBranches
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Auth;
use C4::Acquisition;
use C4::Budgets;   #
use C4::Members;  # calls GetSortDetails()
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Debug;
#use POSIX qw(locale_h);

my $input = new CGI;
my $dbh     = C4::Context->dbh;

my ($template, $borrowernumber, $cookie, $staffflags ) = get_template_and_user(
    {   template_name   => "admin/aqbudgets.tmpl",
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

my $op = $input->param('op');

# see if the user want to see all budgets or only owned ones
my $show_mine    = 1; #SHOW BY DEFAULT
my $show         = $input->param('show'); # SET TO 1, BY A FORM SUMBIT
$show_mine       = $input->param('show_mine') if $show == 1;

# IF USER DOESNT HAVE PERM FOR AN 'ADD', THEN REDIRECT TO THE DEFAULT VIEW...
if  (  not defined $template->{VARS}->{'CAN_user_acquisition_budget_add_del'}  &&  $op ==  'add_form'  )   {
    $op = '';
}
my $num=FormatNumber;

my $script_name               = "/cgi-bin/koha/admin/aqbudgets.pl";
my $budget_hash               = $input->Vars;
my $budget_id                 = $$budget_hash{budget_id};
my $budget_permission         = $input->param('budget_permission');
my $filter_budgetbranch       = $input->param('filter_budgetbranch');
#filtering non budget keys
delete $$budget_hash{$_} foreach grep {/filter|^op$|show/} keys %$budget_hash;
my $filter_budgetname         = $input->param('filter_budgetname');
$template->param(
    notree => ($filter_budgetbranch or $show_mine)
);
# ' ------- get periods stuff ------------------'
# IF PERIODID IS DEFINED,  GET THE PERIOD - ELSE JUST GET THE ACTIVE PERIOD BY DEFAULT
my $period = GetBudgetPeriod($$budget_hash{budget_period_id});

$template->param(
	%$period
);
# ------- get periods stuff ------------------

# USED FOR PERMISSION COMPARISON LATER
my $borrower_id         = $template->{param_map}->{'USER_INFO'}[0]->{'borrowernumber'};
my $user                = GetMemberDetails($borrower_id);
my $user_branchcode     = $user->{'branchcode'};

$template->param(
    action      => $script_name,
    script_name => $script_name,
    show_mine   => $show_mine,
    $op || else => 1,
);


# retrieve branches
my ( $budget, );

my $branches = GetBranches($show_mine);
my @branchloop2;
foreach my $thisbranch (keys %$branches) {
    my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
    $row{selected} = 1 if $thisbranch eq $filter_budgetbranch;
    push @branchloop2, \%row;
}

$template->param(auth_cats_loop => GetBudgetAuthCats($$period{budget_period_id}) );

# Used to create form to add or  modify a record
if ($op eq 'add_form') {
#### ------------------- ADD_FORM -------------------------
    # if no buget_id is passed then its an add
    #  pass the period_id to build the dropbox - because we only want to show  budgets from this period
    my $dropbox_disabled;
    if (defined $budget_id ) {    ### MOD
        $budget           = GetBudget($budget_id);
        $dropbox_disabled = BudgetHasChildren($budget_id);
        my $borrower = &GetMember( borrowernumber=>$budget->{budget_owner_id} );
        $budget->{budget_owner_name} = $borrower->{'firstname'} . ' ' . $borrower->{'surname'};
        $$budget{$_}= sprintf("%.2f", $budget->{$_}) for grep{/amount/} keys %$budget;
    }

    # build budget hierarchy
    my %labels;
    my @values;
    my $hier = GetBudgetHierarchy($$period{budget_period_id});
    foreach my $r (@$hier) {
        $r->{budget_code_indent} =~ s/&nbsp;/\~/g;    #
        $labels{"$r->{budget_id}"} = $r->{budget_code_indent};
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
        $row{selected} = 1 if $thisbranch eq $budget->{'budget_branchcode'};
        push @branchloop_select, \%row;
    }
    
    # populates the YUI planning button
    my $categories = GetAuthorisedValueCategories();
    my @auth_cats_loop1 = ();
    foreach my $category (@$categories) {
        my $entry = { category => $category,
                        selected => $budget->{sort1_authcat} eq $category ?1:0,
                    };
        push @auth_cats_loop1, $entry;
    }
    my @auth_cats_loop2 = ();
    foreach my $category (@$categories) {
        my $entry = { category => $category,
                        selected => $budget->{sort2_authcat} eq $category ?1:0,
                    };
        push @auth_cats_loop2, $entry;
    }
    $template->param(authorised_value_categories1 => \@auth_cats_loop1);
    $template->param(authorised_value_categories2 => \@auth_cats_loop2);

    if($budget->{'budget_permission'}){
        my $budget_permission = "budget_perm_".$budget->{'budget_permission'};
        $template->param($budget_permission => 1);
    }

    # if no buget_id is passed then its an add
    $template->param(
        add_validate                  => 1,
        dateformat                => C4::Dates->new()->visual(),
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
        budget_amount => $num->format_price(  $budget->{'budget_amount'} ),
    );
                                                    # END $OP eq DELETE_CONFIRM
# called by delete_confirm, used to effectively confirm deletion of data in DB
}  else{
    if ( $op eq 'delete_confirmed' ) {
        my $rc = DelBudget($budget_id);
    }elsif( $op eq 'add_validate' ) {
        if ( defined $$budget_hash{budget_id} ) {
            ModBudget( $budget_hash );
        } else {
            AddBudget( $budget_hash );
        }
    }
    my $branches = GetBranches();
    $template->param(
        budget_id                 => $budget_id,
        %$period,
    );

    my $moo = GetBudgetHierarchy($$period{budget_period_id}, C4::Context->userenv->{branchcode}, $show_mine?$borrower_id:'');
    my @budgets = @$moo; #FIXME

    my $toggle = 0;
    my @loop;
    my $period_total = 0;
    my ( $period_alloc_total, $base_spent_total );

	#This Looks WEIRD to me : should budgets be filtered in such a way ppl who donot own it would not see the amount spent on the budget by others ?

    foreach my $budget (@budgets) {
        #Level and sublevels total spent
        $budget->{'total_levels_spent'} = GetChildBudgetsSpent($budget->{"budget_id"});

        # PERMISSIONS
        unless($staffflags->{'superlibrarian'} % 2   == 1 ) {
            #IF NO PERMS, THEN DISABLE EDIT/DELETE
            unless ( $template->{param_map}->{'CAN_user_acquisition_budget_modify'} ) {
                $budget->{'budget_lock'} = 1;
            }
            # check budget permission
            if ( $$period{budget_period_locked} == 1 ) {
                $budget->{'budget_lock'} = 1;

            } elsif ( $budget->{budget_permission} == 1 ) {

                if ( $borrower_id != $budget->{'budget_owner_id'} ) {
                    $budget->{'budget_lock'} = 1;
                }
                # check parent perms too
                my $parents_perm = 0;
                if ( $budget->{depth} > 0 ) {
                    $parents_perm = CheckBudgetParentPerm( $budget, $borrower_id );
                    delete $budget->{'budget_lock'} if $parents_perm == '1';
                }
            } elsif ( $budget->{budget_permission} == 2 ) {

                $budget->{'budget_lock'} = 1 if $user_branchcode ne $budget->{budget_branchcode};
            }
        }    # ...SUPER_LIB END

        # if a budget search doesnt match, next
        if ($filter_budgetname ) {
            next unless  $budget->{budget_code}  =~ m/$filter_budgetname/  ||
            $budget->{name}  =~ m/$filter_budgetname/ ;
        }
        if ($filter_budgetbranch ) {
            next unless  $budget->{budget_branchcode}  =~ m/$filter_budgetbranch/;
        }

## TOTALS
        # adds to total  - only if budget is a 'top-level' budget
        $period_alloc_total += $budget->{'budget_amount_total'} if $budget->{'depth'} == 0;
        $base_spent_total += $budget->{'budget_spent'};
        $budget->{'budget_remaining'} = $budget->{'budget_amount'} - $budget->{'total_levels_spent'};

# if amount == 0 dont display...
        delete  $budget->{'budget_unalloc_sublevel'} if  $budget->{'budget_unalloc_sublevel'} == 0 ;

        $budget->{'remaining_pos'} = 1 if $budget->{'budget_remaining'} > 0;
        $budget->{'remaining_neg'} = 1 if $budget->{'budget_remaining'} < 0;
		for (grep {/total_levels_spent|budget_spent|budget_amount|budget_remaining|budget_unalloc/} keys %$budget){
            $budget->{$_}               = $num->format_price( $budget->{$_} ) if defined($budget->{$_})
		}

        # Value of budget_spent equals 0 instead of undefined value
        $budget->{"budget_spent"} = $num->format_price(0) unless defined($budget->{"budget_spent"});

        my $borrower = &GetMember( borrowernumber=>$budget->{budget_owner_id} );
        $budget->{"budget_owner_name"}     = $borrower->{'firstname'} . ' ' . $borrower->{'surname'};
        $budget->{"budget_borrowernumber"} = $borrower->{'borrowernumber'};

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

        push( @loop, {  %{$budget},
                        branchname  => $branches->{ $budget->{branchcode} }->{branchname},
                        budget_hierarchy => \@budget_hierarchy,
                    }
        );
    }

    my $budget_period_total = $num->format_price($$period{budget_period_total}) if $$period{budget_period_total};
    $template->param(
        else                   => 1,
        budget                 => \@loop,
        budget_period_total    => $budget_period_total,
        period_alloc_total     => $num->format_price($period_alloc_total),
        base_spent_total       => $num->format_price($base_spent_total),
        branchloop             => \@branchloop2,
    );

} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
