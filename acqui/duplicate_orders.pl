#!/usr/bin/perl

# Copyright 2018 Koha Development Team
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

use CGI qw ( -utf8 );

use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_and_exit output_html_with_http_headers );
use C4::Acquisition qw( GetHistory );
use C4::Budgets     qw( GetBudgetHierarchy GetBudget CanUserUseBudget GetBudgetPeriods GetBudgetPeriod );
use Koha::Acquisition::Baskets;
use Koha::Acquisition::Currencies;
use Koha::Acquisition::Orders;
use Koha::DateUtils qw( dt_from_string );

my $input    = CGI->new;
my $basketno = $input->param('basketno');
my $op       = $input->param('op') || 'search';    # search, select, batch_edit

my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name => "acqui/duplicate_orders.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { acquisition => 'order_manage' },
    }
);

my $basket = Koha::Acquisition::Baskets->find($basketno);

output_and_exit( $input, $cookie, $template, 'unknown_basket' )
    unless $basket;

my $vendor = $basket->bookseller;
my $patron = Koha::Patrons->find($loggedinuser)->unblessed;

my $filters = {
    basket                  => scalar $input->param('basket'),
    title                   => scalar $input->param('title'),
    author                  => scalar $input->param('author'),
    isbn                    => scalar $input->param('isbn'),
    name                    => scalar $input->param('name'),
    ean                     => scalar $input->param('ean'),
    basketgroupname         => scalar $input->param('basketgroupname'),
    booksellerinvoicenumber => scalar $input->param('booksellerinvoicenumber'),
    budget                  => scalar $input->param('budget'),
    orderstatus             => scalar $input->param('orderstatus'),
    ordernumber             => scalar $input->param('ordernumber'),
    search_children_too     => scalar $input->param('search_children_too'),
    created_by              => [ $input->multi_param('created_by') ]
};

my $from_placed_on =
    eval { dt_from_string( scalar $input->param('from') ) } || dt_from_string;
my $to_placed_on =
    eval { dt_from_string( scalar $input->param('to') ) } || dt_from_string;

unless ( $input->param('from') ) {

    # Fill the form with year-1
    $from_placed_on->set_time_zone('floating')->subtract( years => 1 );
}
$filters->{from_placed_on} = $from_placed_on;
$filters->{to_placed_on}   = $to_placed_on;

my ( @result_order_loop, @selected_order_loop );
my @ordernumbers = split ',', scalar $input->param('ordernumbers') || '';
if ( $op eq 'select' ) {

    # Set filter for 'all status'
    if ( $filters->{orderstatus} eq "any" ) {
        $filters->{get_canceled_order} = 1;
    }

    @result_order_loop = map {
        my $order = $_;
        ( grep { $_ eq $order->{ordernumber} } @ordernumbers ) ? () : $order
    } @{ C4::Acquisition::GetHistory(%$filters) };

    @selected_order_loop =
        scalar @ordernumbers
        ? @{ C4::Acquisition::GetHistory( ordernumbers => \@ordernumbers ) }
        : ();
} elsif ( $op eq 'cud-batch_edit' ) {
    @ordernumbers = $input->multi_param('ordernumber');

    # build budget list
    my $budget_loop       = [];
    my $budgets_hierarchy = GetBudgetHierarchy;
    foreach my $r ( @{$budgets_hierarchy} ) {
        next
            unless ( C4::Budgets::CanUserUseBudget( $patron, $r, $userflags ) );

        push @{$budget_loop},
            {
            b_id            => $r->{budget_id},
            b_txt           => $r->{budget_name},
            b_code          => $r->{budget_code},
            b_sort1_authcat => $r->{'sort1_authcat'},
            b_sort2_authcat => $r->{'sort2_authcat'},
            b_active        => $r->{budget_period_active},
            };
    }
    @{$budget_loop} =
        sort { uc( $a->{b_txt} ) cmp uc( $b->{b_txt} ) } @{$budget_loop};

    $template->param(
        currencies  => Koha::Acquisition::Currencies->search,
        budget_loop => $budget_loop,
    );
} elsif ( $op eq 'cud-do_duplicate' ) {
    my @fields_to_copy = $input->multi_param('copy_existing_value');

    my $default_values;
    for my $field (qw(currency budget_id order_internalnote order_vendornote sort1 sort2 )) {
        next if grep { $_ eq $field } @fields_to_copy;
        $default_values->{$field} = $input->param("all_$field");
    }

    @ordernumbers = $input->multi_param('ordernumber');
    my @new_ordernumbers;
    for my $ordernumber (@ordernumbers) {
        my $original_order = Koha::Acquisition::Orders->find($ordernumber);
        next unless $original_order;
        my $new_order = $original_order->duplicate_to( $basket, $default_values );
        push @new_ordernumbers, $new_order->ordernumber;
    }

    my $new_orders = C4::Acquisition::GetHistory( ordernumbers => \@new_ordernumbers );
    $template->param( new_orders => $new_orders );
    $op = 'duplication_done';
}

my $budgetperiods = C4::Budgets::GetBudgetPeriods;
my $bp_loop       = $budgetperiods;
for my $bp ( @{$budgetperiods} ) {
    my $hierarchy = C4::Budgets::GetBudgetHierarchy( $$bp{budget_period_id} );
    for my $budget ( @{$hierarchy} ) {
        $$budget{budget_display_name} =
            sprintf( "%s", ">" x $$budget{depth} . $$budget{budget_name} );
    }
    $$bp{hierarchy} = $hierarchy;
}

$template->param(
    basket              => $basket,
    vendor              => $vendor,
    filters             => $filters,
    result_order_loop   => \@result_order_loop,
    selected_order_loop => \@selected_order_loop,
    bp_loop             => $bp_loop,
    ordernumbers        => \@ordernumbers,
    op                  => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
