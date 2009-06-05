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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
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

my $op = $input->param('op');

# see if the user want to see all budgets or only owned ones
my $show_mine    = 1; #SHOW BY DEFAULT
my $show         = $input->param('show'); # SET TO 1, BY A FORM SUMBIT
$show_mine       = $input->param('show_mine') if $show == 1;

# IF USER DOESNT HAVE PERM FOR AN 'ADD', THEN REDIRECT TO THE DEFAULT VIEW...
if  (  not defined $template->{param_map}->{'CAN_user_acquisition_budget_add_del'}  &&  $op ==  'add_form'  )   {
    $op = '';
}

my $cur  =  GetCurrency;
my $cur_format = C4::Context->preference("CurrencyFormat");
my $num;

if ( $cur_format eq 'FR' ) {
    $num = new Number::Format(
        'decimal_fill'      => '2',
        'decimal_point'     => ',',
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ' ',
        'thousands_sep'     => ' ',
        'mon_decimal_point' => ','
    );
} else {  # US by default..
    $num = new Number::Format(
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ',',
        'mon_decimal_point' => '.'
    );
}

my $script_name               = "/cgi-bin/koha/admin/aqbudgets.pl";
my $budget_id                 = $input->param('budget_id');
my $budget_code               = $input->param('budget_code');
my $budget_name               = $input->param('budget_name');
my $budget_amount             = $input->param('budget_amount');
my $budget_amount_sublevel    = $input->param('budget_amount_sublevel');
my $budget_encumb             = $input->param('budget_encumb');
my $budget_expend             = $input->param('budget_expend');
my $budget_notes              = $input->param('budget_notes');
my $sort1_authcat             = $input->param('sort1_authcat');
my $sort2_authcat             = $input->param('sort2_authcat');
my $budget_description        = $input->param('budget_description');
my $budget_branchcode         = $input->param('budget_branchcode');
my $budget_owner_id           = $input->param('budget_owner_id');
my $budget_parent_id          = $input->param('budget_parent_id');
my $budget_permission         = $input->param('budget_permission');
my $budget_period_dropbox     = $input->param('budget_period_dropbox');
my $filter_budgetname         = $input->param('filter_budgetname');
my $filter_budgetbranch       = $input->param('filter_budgetbranch');

# ' ------- get periods stuff ------------------'
# IF PERIODID IS DEFINED,  GET THE PERIOD - ELSE JUST GET THE ACTIVE PERIOD BY DEFAULT
my $budget_period_id  = $input->param('budget_period_id');
my $period = GetBudgetPeriod($budget_period_id);
my $budget_period_id          = $period->{'budget_period_id'};
my $budget_period_locked      = $period->{'budget_period_locked'};
my $budget_period_description = $period->{'budget_period_description'};
my $budget_period_total       = $period->{'budget_period_total'};

$template->param(
    budget_period_id          => $budget_period_id,
    budget_period_locked      => $budget_period_locked,
    budget_period_description => $budget_period_description,
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
my ( $budget, $period, $query, $sth );

my $branches = GetBranches;
my @branchloop2;
foreach my $thisbranch (keys %$branches) {
    my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
    $row{selected} = 1 if $thisbranch eq $filter_budgetbranch;
    push @branchloop2, \%row;
}

$template->param(auth_cats_loop => GetBudgetAuthCats($budget_period_id) );

# Used to create form to add or  modify a record
if ($op eq 'add_form') {
#### ------------------- ADD_FORM -------------------------

    # if no buget_id is passed then its an add
    #  pass the period_id to build the dropbox - because we only want to show  budgets from this period
    my $dropbox_disabled;
    if ( defined $budget_id ) {    ### MOD
        $budget           = GetBudget($budget_id);
        $dropbox_disabled = BudgetHasChildren($budget_id);
        my $borrower = &GetMember( $budget->{budget_owner_id} );
        $budget->{budget_owner_name} = $borrower->{'firstname'} . ' ' . $borrower->{'surname'};
    }

    # build budget hierarchy
    my %labels;
    my @values;
    my $hier = GetBudgetHierarchy($budget_period_id);
    foreach my $r (@$hier) {
        $r->{budget_code_indent} =~ s/&nbsp;/\~/g;    #
        $labels{"$r->{budget_id}"} = $r->{budget_code_indent};
        push @values, $r->{budget_id};
    }
    push @values, '';
    # if no buget_id is passed then its an add
    my $budget_parent_dropbox;
    my $budget_parent_id = $budget->{'budget_parent_id'} if $budget;
    $budget_parent_dropbox = CGI::scrolling_list(
        -name    => 'budget_parent_id',
        -values  => \@values,
        -default => $budget_parent_id ? $budget_parent_id : undef,
        -size    => 10,
        -style   => "min-width:100px;",
        -labels  => \%labels,
    );

    # build branches select
    my $branches = GetBranches;
    my @branchloop_select;
    foreach my $thisbranch ( keys %$branches ) {
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

    my $budget_perm_dropbox =
    GetBudgetPermDropbox($budget->{'budget_permission'});
    
    # if no buget_id is passed then its an add
    $template->param(
        add_form                  => 1,
        dateformat                => C4::Dates->new()->visual(),
        budget_id                 => $budget->{'budget_id'},
        budget_parent_id          => $budget->{'budget_parent_id'},
        budget_dropbox     => $budget_dropbox,
        budget_perm_dropbox       => $budget_perm_dropbox,
        budget_code               => $budget->{'budget_code'},
        budget_code_indent        => $budget->{'budget_code_indent'},
        budget_name               => $budget->{'budget_name'},
        budget_branchcode         => $budget->{'budget_branchcode'},
        budget_amount             => sprintf("%.2f", $budget->{'budget_amount'}),
        budget_amount_sublevel    => sprintf("%.2f", $budget->{'budget_amount_sublevel'}),
        budget_encumb             => $budget->{'budget_encumb'},
        budget_expend             => $budget->{'budget_expend'},
        budget_notes              => $budget->{'budget_notes'},
        budget_description        => $budget->{'budget_description'},
        budget_owner_id           => $budget->{'budget_owner_id'},
        budget_owner_name         => $budget->{'budget_owner_name'},
        budget_permission         => $budget->{'budget_permission'},
        budget_period_id          => $budget_period_id,
        budget_period_description => $budget_period_description,
        branchloop_select         => \@branchloop_select,
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
}  else {
    if ( $op eq 'delete_confirmed' ) {
        my $rc = DelBudget($budget_id);
    }
    if ( $op eq 'add_validate' ) {
        my %budget_hash = (
            budget_id              => $budget_id,
            budget_parent_id       => $budget_parent_id,
            budget_period_id       => $budget_period_id,
            budget_code            => $budget_code,
            budget_name            => $budget_name,
            budget_branchcode      => $budget_branchcode,
            budget_amount          => $budget_amount,
            budget_amount_sublevel => $budget_amount_sublevel,
            budget_encumb          => $budget_encumb,
            budget_expend          => $budget_expend,
            budget_notes           => $budget_notes,
            sort1_authcat          => $sort1_authcat,
            sort2_authcat          => $sort2_authcat,
            budget_description     => $budget_description,
            budget_owner_id        => $budget_owner_id,
            budget_permission      => $budget_permission,
        );
        if ( defined $budget_id ) {
            ModBudget( \%budget_hash );
        } else {
            AddBudget( \%budget_hash );
        }
    }
    my $branches = GetBranches();
    my $budget_period_dropbox = GetBudgetPeriodsDropbox($budget_period_id );
    $template->param(
        budget_period_dropbox     => $budget_period_dropbox,
        budget_id                 => $budget_id,
        budget_period_startdate   => $period->{'budget_period_startdate'},
        budget_period_enddate     => $period->{'budget_period_enddate'},
    );
    my $moo = GetBudgetHierarchy($budget_period_id, $template->{param_map}->{'USER_INFO'}[0]->{'branchcode'}, $show_mine?$borrower_id:'');
    my @budgets = @$moo; #FIXME

    my $toggle = 0;
    my @loop;
    my $period_total = 0;
    my ( $period_alloc_total, $base_alloc_total, $sub_alloc_total, $base_spent_total, $base_remaining_total );

    foreach my $budget (@budgets) {

        # PERMISSIONS
        unless($staffflags->{'superlibrarian'}   == 1 ) {
            #IF NO PERMS, THEN DISABLE EDIT/DELETE
            unless ( $template->{param_map}->{'CAN_user_acquisition_budget_modify'} ) {
                $budget->{'budget_lock'} = 1;
            }
            # check budget permission
            if ( $budget_period_locked == 1 ) {
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
        $base_alloc_total += $budget->{'budget_amount'};
        $sub_alloc_total  += $budget->{'budget_amount_sublevel'};
        $base_spent_total += $budget->{'budget_spent'};
        $budget->{'budget_remaining'} = $budget->{'budget_amount'} - $budget->{'budget_spent'};
        $base_remaining_total += $budget->{'budget_remaining'};

# if amount == 0 dont display...
        delete  $budget->{'budget_unalloc_sublevel'} if  $budget->{'budget_unalloc_sublevel'} == 0 ;
        delete  $budget->{'budget_amount_sublevel'} if  $budget->{'budget_amount_sublevel'} == 0 ;

        $budget->{'remaining_pos'} = 1 if $budget->{'budget_remaining'} > 0;
        $budget->{'remaining_neg'} = 1 if $budget->{'budget_remaining'} < 0;
        $budget->{'budget_amount'}           = $num->format_price( $budget->{'budget_amount'} );
        $budget->{'budget_spent'}            = $num->format_price( $budget->{'budget_spent'} );
        $budget->{'budget_remaining'}        = $num->format_price( $budget->{'budget_remaining'} );
        $budget->{'budget_amount_total'}     = $num->format_price( $budget->{'budget_amount_total'} );
        $budget->{'budget_amount_sublevel'}  = $num->format_price( $budget->{'budget_amount_sublevel'} ) if defined $budget->{'budget_amount_sublevel'};
        $budget->{'budget_unalloc_sublevel'} = $num->format_price( $budget->{'budget_unalloc_sublevel'} ) if defined $budget->{'budget_unalloc_sublevel'};

        my $borrower = &GetMember( $budget->{budget_owner_id} );
        $budget->{budget_owner_name}     = $borrower->{'firstname'} . ' ' . $borrower->{'surname'};
        $budget->{budget_borrowernumber} = $borrower->{'borrowernumber'};

        push( @loop, {  %{$budget},
                        toggle      => $toggle++%2,
                        branchname  => $branches->{ $budget->{branchcode} }->{branchname},
                        startdate   => format_date($budget->{startdate}),
                        enddate     => format_date($budget->{enddate}),
                    }
        );
    }

    $template->param(
        else                   => 1,
        budget                 => \@loop,
        budget_period_total    => $num->format_price($budget_period_total),
        period_alloc_total     => $num->format_price($period_alloc_total),
        base_alloc_total       => $num->format_price($base_alloc_total),
        sub_alloc_total        => $num->format_price($sub_alloc_total),
        base_spent_total       => $num->format_price($base_spent_total),
        base_remaining_total   => $num->format_price($base_remaining_total),
        period_remaining_total => $num->format_price( $period_alloc_total - $base_alloc_total ),
        branchloop             => \@branchloop2,
        cur                    => $cur->{symbol},
        cur_format             => $cur_format,
    );

} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
