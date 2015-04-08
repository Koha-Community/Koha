#!/usr/bin/perl

# Copyright 2008-2009 BibLibre SARL
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

#script to administer the aqbudgets0 table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use List::Util qw/min/;
use Date::Calc qw/Delta_YMD Easter_Sunday Today Decode_Date_EU/;
use Date::Manip qw/ ParseDate UnixDate DateCalc/;
use C4::Dates qw/format_date format_date_in_iso/;
use Text::CSV_XS;

use C4::Acquisition;
use C4::Budgets;
use C4::Context;
use C4::Output;
use C4::Koha;
use C4::Auth;
use C4::Input;
use C4::Debug;

my $input = new CGI;
####  $input

my $dbh = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie, $staff_flags ) = get_template_and_user(
    {   template_name   => "admin/aqplan.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'planning_manage' },
        debug           => 0,
    }
);

my $budget_period_id = $input->param('budget_period_id');
# ' ------- get periods stuff ------------------'
# IF PERIOD_ID IS DEFINED,  GET THE PERIOD - ELSE GET THE ACTIVE PERIOD BY DEFAULT
my $period = GetBudgetPeriod($budget_period_id);
my $count  = GetPeriodsCount();
my $cur    = GetCurrency;
$template->param( symbol => $cur->{symbol},
                  currency => $cur->{currency}
               );
$template->param( period_button_only => 1 ) if $count == 0;



# authcats_loop populates the YUI planning button
my $auth_cats_loop            = GetBudgetAuthCats($budget_period_id);
my $budget_period_id          = $period->{'budget_period_id'};
my $budget_period_startdate   = $period->{'budget_period_startdate'};
my $budget_period_enddate     = $period->{'budget_period_enddate'};
my $budget_period_locked      = $period->{'budget_period_locked'};
my $budget_period_description = $period->{'budget_period_description'};


$template->param(
    budget_period_id          => $budget_period_id,
    budget_period_locked      => $budget_period_locked,
    budget_period_description => $budget_period_description,
    auth_cats_loop            => $auth_cats_loop,
);

# ------- get periods stuff ------------------

my $borrower_id         = $template->{VARS}->{'USER_INFO'}[0]->{'borrowernumber'};
my $borrower_branchcode = $template->{VARS}->{'USER_INFO'}[0]->{'branchcode'};

my $periods;
my $authcat      = $input->param('authcat');
my $show_active  = $input->param('show_active');
my $show_actual  = $input->param('show_actual');
my $show_percent = $input->param('show_percent');
my $output       = $input->param("output");
my $basename     = $input->param("basename");
my $del          = $input->param("sep");

my $show_mine       = $input->param('show_mine') ;

my @hide_cols      = $input->param('hide_cols');

if ( $budget_period_locked == 1  && not defined  $show_actual ) {
     $show_actual  = 1;
}

$authcat = 'Asort1' if  not defined $authcat; # defaults to Asort if no authcat given

my $budget_id = $input->param('budget_id');
my $op        = $input->param("op");

my $budget_branchcode;

my $budgets_ref = GetBudgetHierarchy( $budget_period_id, $show_mine?$template->{VARS}->{'USER_INFO'}[0]->{'branchcode'}:'', $show_mine?$template->{VARS}->{'USER_INFO'}[0]->{'borrowernumber'}:'' );

# build categories list
my $sth = $dbh->prepare("select distinct category from authorised_values where category like 'A%' ");
$sth->execute;

# the list
my @category_list;

# a hash, to check that some hardcoded categories exist.
my %categories;
while ( my ($category) = $sth->fetchrow_array ) {
    push( @category_list, $category );
    $categories{$category} = 1;
}

# push koha system categories
push( @category_list, 'MONTHS' );
push( @category_list, 'ITEMTYPES' );
push( @category_list, 'BRANCHES' );
push( @category_list, $$_{'authcat'} ) foreach @$auth_cats_loop;

#reorder the list
@category_list = sort { $a cmp $b } @category_list;

$template->param( authcat_dropbox => {
        values => \@category_list,
        default => $authcat,
    });

my @budgets = @$budgets_ref;
my $CGISort;
my @authvals;
my %labels;

my @names = $input->param();
# ------------------------------------------------------------
if ( $op eq 'save' ) {
    #get budgets
    my ( @buds, @auth_values );
    foreach my $n (@names) {
        next if $n =~ m/^[^0-9]/;
        my @moo = split( ',', $n );
        push @buds, $moo[0];
        push @auth_values, $moo[1];
    }

    #uniq buds and auth
    my %seen;
    @buds        = grep { !$seen{$_}++ } @buds;
    @auth_values = grep { !$seen{$_}++ } @auth_values;
    my @budget_ids;
    my @budget_lines;

    foreach my $budget (@buds) {
        my %budget_line;
        my @cells_line;
        my %cell_hash;

        foreach my $authvalue (@auth_values) {
            # get actual stats
            my $cell_name        = "$budget,$authvalue";
            my $estimated_amount = $input->param("$cell_name");
            my %cell_hash = (
                estimated_amount => $estimated_amount,
                authvalue        => $authvalue,
                authcat          => $authcat,
                budget_id        => $budget,
                budget_period_id => $budget_period_id,
            );
            push( @cells_line, \%cell_hash );
        }

        %budget_line = (
            lines => \@cells_line,
        );
        push( @budget_lines, \%budget_line );
    }
    my $plan = \@budget_lines;
    ModBudgetPlan( $plan, $budget_period_id, $authcat );

HideCols($authcat, @hide_cols);


}
# ------------------------------------------------------------
if ( $authcat =~ m/^Asort/ ) {
   my $query = qq{ SELECT * FROM authorised_values WHERE category=? order by lib };
    my $sth   = $dbh->prepare($query);
    $sth->execute($authcat  );
    if ( $sth->rows > 0 ) {
        for ( my $i = 0 ; $i < $sth->rows ; $i++ ) {
            my $results = $sth->fetchrow_hashref;
            push @authvals, $results->{authorised_value};
            $labels{ $results->{authorised_value} } = $results->{lib};
        }
    }
    $sth->finish;
    @authvals = sort { $a <=> $b } @authvals;
}
elsif ( $authcat eq 'MONTHS' ) {

    # build months
    my @start_date = UnixDate( $budget_period_startdate, ( '%Y', '%m', '%d' ) );
    my @end_date   = UnixDate( $budget_period_enddate,   ( '%Y', '%m', '%d' ) );

    my ( $Dy, $Dm, $Dd ) = Delta_YMD( @start_date, @end_date );

    #calc number of months between
    my $months      = ( $Dy * 12 ) + $Dm;
    my $start_month = @start_date[1];
    my $end_month   = ( $Dy * 12 ) + $Dm;

    for my $mth ( 0 ... $months ) {
        $mth = DateCalc( $budget_period_startdate, "+ $mth months" );
        $mth = UnixDate( $mth, "%Y-%m" );
        push( @authvals, $mth );
    }
    foreach my $vv (@authvals) {
        $labels{$vv} = $vv;
    }
}

elsif ( $authcat eq 'ITEMTYPES' ) {
    my $query = qq| SELECT itemtype, description FROM itemtypes |;
    my $sth   = $dbh->prepare($query);
    $sth->execute(  );

    if ( $sth->rows > 0 ) {
        for ( my $i = 0 ; $i < $sth->rows ; $i++ ) {
            my $results = $sth->fetchrow_hashref;
            push @authvals, $results->{itemtype};
            $labels{ $results->{itemtype} } = $results->{description};
        }
    }
    $sth->finish;

} elsif ( $authcat eq 'BRANCHES' ) {

    my $query = qq| SELECT branchcode, branchname FROM branches |;
    my $sth   = $dbh->prepare($query);
    $sth->execute();

    if ( $sth->rows > 0 ) {
        for ( my $i = 0 ; $i < $sth->rows ; $i++ ) {
            my $results = $sth->fetchrow_hashref;
            push @authvals, $results->{branchcode};
            $labels{ $results->{branchcode} } = $results->{branchname};
        }
    }
    $sth->finish;
} elsif ($authcat) {
    my $query = qq{ SELECT * FROM authorised_values WHERE category=? order by lib };
    my $sth   = $dbh->prepare($query);
    $sth->execute($authcat);
    if ( $sth->rows > 0 ) {
        for ( my $i = 0 ; $i < $sth->rows ; $i++ ) {
            my $results = $sth->fetchrow_hashref;
            push @authvals, $results->{authorised_value};
            $labels{ $results->{authorised_value} } = $results->{lib};
        }
    }
    $sth->finish;
}

my @authvals_row;
my $i=1;
foreach my $val (@authvals) {
    my %auth_hash;
    $auth_hash{val} =   $labels{$val};
    $auth_hash{code} =   $val;
    $auth_hash{colnum} =   $i++;

    # display lookup
    $auth_hash{display} = GetCols( $authcat,  $auth_hash{code});

    push( @authvals_row, \%auth_hash );
}

#get budgets
my ( @buds, @auth_values );
foreach my $n (@names) {
    next if $n =~ m/^[^0-9]/;
    $n =~ m/(\d*),(.*)/;
    push @buds, $1;
    push @auth_values, $2;
}


# ------------------------------------------------------------
#         DEFAULT DISPLAY BEGINS

my $CGIextChoice = ( 'CSV' ); # FIXME translation
my $CGIsepChoice = ( C4::Context->preference("delimiter") );

my ( @budget_lines, %cell_hash );


foreach my $budget (@budgets) {
    my $budget_lock;

    unless (CanUserUseBudget($borrowernumber, $budget, $staff_flags)) {
        $budget_lock = 1
    }

    # check budget permission
    if ( $period->{budget_period_locked} == 1 ) {
        $budget_lock = 1;
    } elsif ( $budget->{budget_permission} == 1 ) {
        $budget_lock = 1 if $borrower_id != $budget->{'budget_owner_id'};
    } elsif ( $budget->{budget_permission} == 2 ) {
        $budget_lock = 1 if $borrower_branchcode ne $budget->{budget_branchcode};
    }

    # allow hard-coded itemtype and branch planning
    unless ( $authcat eq 'ITEMTYPES'
        or  $authcat eq 'BRANCHES'
        or  $authcat eq 'MONTHS' ) {

        # but skip budgets that dont match the current auth-category
        next if ( $budget->{'sort1_authcat'} ne $authcat
            && $budget->{'sort2_authcat'} ne $authcat );
    }

    my %budget_line; # each row of the  table
    my @cells_line;
    my $actual_spent;
    my $estimated_spent;

    my $i = 0;
    foreach my $authvalue (@authvals) {

        # get actual stats
        my %cell = (
            budget_id        => $budget->{'budget_id'},
            budget_period_id => $budget->{'budget_period_id'},
            cell_name        => $budget->{'budget_id'} . ',' . $authvalue,
            authvalue        => $authvalue,
            authcat          => $authcat,
            cell_authvalue   => $authvalue,
            budget_lock      => $budget_lock,
        );

        my ( $actual, $estimated, $display ) = GetBudgetsPlanCell( \%cell, $period, $budget );
        $cell{actual_amount}    = sprintf( "%.2f", $actual );
        $cell{estimated_amount} = sprintf( "%.2f", $estimated );
        $cell{display}          = $authvals_row[$i]{display};
        $cell{colnum}           = $i;

        $actual_spent    += $cell{actual_amount};
        $estimated_spent += $cell{estimated_amount};


        push( @cells_line, \%cell );
        $i++;
    }

    my $budget_act_remain = $budget->{budget_amount} - $actual_spent;
    my $budget_est_remain = $budget->{budget_amount} - $estimated_spent;

    %budget_line = (
        lines                   => \@cells_line,
        budget_name_indent      => $budget->{budget_name_indent},
        budget_amount           => $budget->{budget_amount},
        budget_alloc            => $budget->{budget_alloc},
        budget_act_remain       => sprintf( "%.2f", $budget_act_remain ),
        budget_est_remain       => sprintf( "%.2f", $budget_est_remain ),
        budget_id               => $budget->{budget_id},
        budget_lock             => $budget_lock,
    );



    $budget_line{est_negative} = '1' if $budget_est_remain < 0;
    $budget_line{est_positive} = '1' if $budget_est_remain > 0;
    $budget_line{act_negative} = '1' if $budget_act_remain < 0;
    $budget_line{act_positive} = '1' if $budget_act_remain > 0;

    # skip if active set , and spent == 0
    next if ( $show_active == '1' && ( $actual_spent == 0 ) );

    push( @budget_lines, \%budget_line );
}

if ( $output eq "file" ) {
    _print_to_csv(\@authvals_row, \@budget_lines);
    exit(1);
}

my $branchloop = C4::Branch::GetBranchesLoop();
$template->param(
    authvals_row              => \@authvals_row,
    budget_lines              => \@budget_lines,
    budget_period_description => $period->{'budget_period_description'},
    budget_period_locked      => $period->{'budget_period_locked'},
    budget_period_id          => $budget_period_id,
    authcat                   => $authcat,
    show_active               => $show_active,
    show_actual               => $show_actual,
    show_percent              => $show_percent,
    show_mine                 => $show_mine,
    CGIextChoice              => $CGIextChoice,
    CGIsepChoice              => $CGIsepChoice,

    authvals              => \@authvals_row,
    hide_cols_loop              => \@hide_cols,
    branchloop                => $branchloop,
);

output_html_with_http_headers $input, $cookie, $template->output;

sub _print_to_csv {
    my ( $header, $results ) = @_;

    binmode STDOUT, ':encoding(UTF-8)';

    my $csv = Text::CSV_XS->new(
        {   sep_char     => $del,
            always_quote => 'TRUE',
        }
    );
    print $input->header(
        -type       => 'application/vnd.sun.xml.calc',
        -encoding   => 'utf-8',
        -attachment => "$basename.csv",
        -name       => "$basename.csv"
    );
    my @col = ( 'Budget name', 'Budget total' );
    foreach my $row (@$header) {
        push @col, $row->{'val'};
    }
    push @col, 'Budget remaining';

    $csv->combine(@col);
    my $str = $csv->string;
    print "$str\n";

    foreach my $row (@$results) {
        $row->{'budget_name_indent'} =~ s/&nbsp;/ /g;
        my @col = ( $row->{'budget_name_indent'}, $row->{'budget_amount'} );
        my $l = $row->{'lines'};
        foreach my $line (@$l) {
            push @col, $line->{'estimated_amount'};
        }
        push @col, $row->{'budget_est_remain'};
        $csv->combine(@col);
        my $str = $csv->string;
        print "$str\n";
    }
}
