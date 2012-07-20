#!/usr/bin/perl

# Copyright 2008 BibLibre, BibLibre, Paul POULAIN
#                SAN Ouest Provence
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

=head1 admin/aqbudgetperiods.pl

script to administer the budget periods table
 This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

 ALGO :
 this script use an $op to know what to do.
 if $op is empty or none of the above values,
	- the default screen is build (with all records, or filtered datas).
	- the   user can clic on add, modify or delete record.
 if $op=add_form
	- if primkey exists, this is a modification,so we read the $primkey record
	- builds the add/modify form
 if $op=add_validate
	- the user has just send datas, so we create/modify the record
 if $op=delete_confirm
	- we show the record having primkey=$primkey and ask for deletion validation form
 if $op=delete_confirmed
	- we delete the record having primkey=$primkey
 if $op=duplicate_form
  - displays the duplication of budget period form (allowing specification of dates)
 if $op=duplicate_budget
  - we perform the duplication of the budget period specified as budget_period_id

=cut

## modules
use strict;
#use warnings; FIXME - Bug 2505
use Number::Format qw(format_price);
use CGI;
use List::Util qw/min/;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Koha;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Budgets;
use C4::Debug;
use C4::SQLHelper;

my $dbh = C4::Context->dbh;

my $input       = new CGI;

my $searchfield          = $input->param('searchfield');
my $budget_period_id     = $input->param('budget_period_id');
my $op                   = $input->param('op')||"else";

my $budget_period_hashref= $input->Vars;
#my $sort1_authcat = $input->param('sort1_authcat');
#my $sort2_authcat = $input->param('sort2_authcat');

my $activepagesize = 20;
my $inactivepagesize = 20;
$searchfield =~ s/\,//g;

my ($template, $borrowernumber, $cookie, $staff_flags ) = get_template_and_user(
	{   template_name   => "admin/aqbudgetperiods.tmpl",
		query           => $input,
		type            => "intranet",
		authnotrequired => 0,
		flagsrequired   => { acquisition => 'period_manage' },
		debug           => 1,
	}
);


my $cur = GetCurrency();
$template->param( symbol => $cur->{symbol},
                  currency => $cur->{currency}
               );
my $cur_format = C4::Context->preference("CurrencyFormat");
my $num;

if ( $cur_format eq 'US' ) {
    $num = new Number::Format(
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ',',
        'mon_decimal_point' => '.'
    );
} elsif ( $cur_format eq 'FR' ) {
    $num = new Number::Format(
        'decimal_fill'      => '2',
        'decimal_point'     => ',',
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ' ',
        'thousands_sep'     => ' ',
        'mon_decimal_point' => ','
    );
}


# ADD OR MODIFY A BUDGET PERIOD - BUILD SCREEN
if ( $op eq 'add_form' ) {
    ## add or modify a budget period (preparation)
    ## get information about the budget period that must be modified

    if ($budget_period_id) {    # MOD
		my $budgetperiod_hash=GetBudgetPeriod($budget_period_id);
        # get dropboxes

        my $editnum = new Number::Format(
            'int_curr_symbol'   => '',
            'thousands_sep'     => '',
            'mon_thousands_sep' => '',
            'mon_decimal_point' => '.'
        );

        $$budgetperiod_hash{budget_period_total}= $editnum->format_price($$budgetperiod_hash{'budget_period_total'});
        $template->param(
			%$budgetperiod_hash
        );
    } # IF-MOD
    $template->param( DHTMLcalendar_dateformat 	=> C4::Dates->DHTMLcalendar(),);
}

elsif ( $op eq 'add_validate' ) {
## add or modify a budget period (confirmation)

	## update budget period data
	if ( $budget_period_id ne '' ) {
		$$budget_period_hashref{$_}||=0 for qw(budget_period_active budget_period_locked);
		my $status=ModBudgetPeriod($budget_period_hashref);
	} 
	else {    # ELSE ITS AN ADD
		my $budget_period_id=AddBudgetPeriod($budget_period_hashref);
	}
	$op='else';
}

#--------------------------------------------------
elsif ( $op eq 'delete_confirm' ) {
## delete a budget period (preparation)
    my $dbh = C4::Context->dbh;
    ## $total = number of records linked to the record that must be deleted
    my $total = 0;
    my $data = GetBudgetPeriod( $budget_period_id);

	$$data{'budget_period_total'}=$num->format_price(  $data->{'budget_period_total'});
    $template->param(
		%$data
    );
}

elsif ( $op eq 'delete_confirmed' ) {
## delete the budget period record

    my $data = GetBudgetPeriod( $budget_period_id);
    DelBudgetPeriod($budget_period_id);
	$op='else';
}

# display the form for duplicating
elsif ( $op eq 'duplicate_form'){
    $template->param(
        DHTMLcalendar_dateformat 	=> C4::Dates->DHTMLcalendar(),
        'duplicate_form' => '1',
        'budget_period_id' => $budget_period_id,
    );
}

# handle the actual duplication
elsif ( $op eq 'duplicate_budget' ){
    die "please specify a budget period id\n" if( !defined $budget_period_id || $budget_period_id eq '' );
    my $startdate = $input->param('budget_period_startdate');
    my $enddate = $input->param('budget_period_enddate');

    my $data = GetBudgetPeriod( $budget_period_id);

    $data->{'budget_period_startdate'} = $startdate;
    $data->{'budget_period_enddate'} = $enddate;
    delete $data->{'budget_period_id'};
    my $new_budget_period_id = C4::SQLHelper::InsertInTable('aqbudgetperiods', $data);

    my $tree = GetBudgetHierarchy( $budget_period_id );

    # hash mapping old ids to new
    my %old_new;
    # hash mapping old parent ids to list of new children ids
    # only store a child here if the parents old id isnt in the old_new map
    # when the parent is found, this map will be used, and then the entry removed and their id placed in old_new
    my %parent_children;

    for my $entry( @$tree ){
        die "serious errors, parent period $budget_period_id doesnt match child ", $entry->{'budget_period_id'}, "\n" if( $entry->{'budget_period_id'} != $budget_period_id );
        my $orphan = 0; # set to 1 if we need to make an entry in parent_children
        my $old_id = delete $entry->{'budget_id'};
        my $parent_id = delete $entry->{'budget_parent_id'};
        $entry->{'budget_period_id'} = $new_budget_period_id;

        if( !defined $parent_id ){
        } elsif( defined $parent_id && $parent_id eq '' ){
        } elsif( defined $old_new{$parent_id} ){
            # set parent id now
            $entry->{'budget_parent_id'} = $old_new{$parent_id};
        } else {
            # make an entry in parent_children
            $parent_children{$parent_id} = [] unless defined $parent_children{$parent_id};
            $orphan = 1;
        }

        # write it to db
        my $new_id = C4::SQLHelper::InsertInTable('aqbudgets', $entry);
        $old_new{$old_id} = $new_id;
        push @{$parent_children{$parent_id}}, $new_id if $orphan;

        # deal with any children
        if( defined $parent_children{$old_id} ){
            # tell my children my new id
            for my $child ( @{$parent_children{$old_id}} ){
                C4::SQLHelper::UpdateInTable('aqcudgets', [ 'budget_id' => $child, 'budget_parent_id' => $new_id ]);
            }
            delete $parent_children{$old_id};
        }
    }

    # display the list of budgets
    $op = 'else';
}

# DEFAULT - DISPLAY AQPERIODS TABLE
# -------------------------------------------------------------------
# display the list of budget periods

my $activepage = $input->param('apage') || 1;
my $inactivepage = $input->param('ipage') || 1;
# Get active budget periods
my $results = GetBudgetPeriods(
    {budget_period_active => 1},
    [{budget_period_description => 0}]
);
my $first = ( $activepage - 1 ) * $activepagesize;
my $last = min( $first + $activepagesize - 1, scalar @{$results} - 1, );
my @period_active_loop;

foreach my $result ( @{$results}[ $first .. $last ] ) {
    my $budgetperiod = $result;
    $budgetperiod->{'budget_period_total'}     = $num->format_price( $budgetperiod->{'budget_period_total'} );
    $budgetperiod->{budget_active} = 1;
    push( @period_active_loop, $budgetperiod );
}
my $url = "aqbudgetperiods.pl";
$url .=  "?ipage=$inactivepage" if($inactivepage != 1);
my $active_pagination_bar = pagination_bar ($url, getnbpages( scalar(@$results), $activepagesize), $activepage, "apage");

# Get inactive budget periods
$results = GetBudgetPeriods(
    {budget_period_active => 0},
    [{budget_period_enddate => 1}]
);
my $first = ( $inactivepage - 1 ) * $inactivepagesize;
my $last = min( $first + $inactivepagesize - 1, scalar @{$results} - 1, );
my @period_inactive_loop;
foreach my $result ( @{$results}[ $first .. $last ] ) {
    my $budgetperiod = $result;
    $budgetperiod->{'budget_period_total'} = $num->format_price( $budgetperiod->{'budget_period_total'} );
    $budgetperiod->{budget_active} = 1;
    push( @period_inactive_loop, $budgetperiod );
}
$url = "aqbudgetperiods.pl?tab=2";
$url .= "&apage=$activepage" if($activepage != 1);
my $inactive_pagination_bar = pagination_bar ($url, getnbpages( scalar(@$results), $inactivepagesize), $inactivepage, "ipage");

my $tab = $input->param('tab') ? $input->param('tab') - 1 : 0;
$template->param(
    period_active_loop      => \@period_active_loop,
    period_inactive_loop    => \@period_inactive_loop,
    active_pagination_bar   => $active_pagination_bar,
    inactive_pagination_bar => $inactive_pagination_bar,
    tab                     => $tab,
    dateformat              => C4::Context->preference('dateformat'),
);

$template->param($op=>1);
output_html_with_http_headers $input, $cookie, $template->output;
