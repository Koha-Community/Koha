#!/usr/bin/perl

# This file is part of Koha.
#
# Author : Frédérick Capovilla, 2011 - SYS-TECH
# Modified by : Élyse Morin, 2012 - Libéo
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


=head1 orders_by_budget

This script displays all orders associated to a selected budget.

=cut

use Modern::Perl;

use CGI qw( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Budgets;
use C4::Biblio;
use C4::Reports;
use C4::Acquisition; #GetBasket()
use Koha::DateUtils;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/orders_by_budget.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => '*' },
        debug           => 1,
    }
);

my $params = $query->Vars;
my $get_orders = $params->{'get_orders'};

if ( $get_orders ) {
    my $budgetfilter     = $params->{'budgetfilter'}    || undef;
    my $total_quantity = 0;
    my $total_rrp = 0;
    my $total_ecost = 0;
    my %budget_name;

    # Fetch the orders
    my @orders;
    unless($budgetfilter) {
        # If no budget filter was selected, get the orders of all budgets
        my @budgets = C4::Budgets::GetBudgetsReport();
        foreach my $budget (@budgets) {
            push(@orders, $budget);
            $budget_name{$budget->{'budget_id'}} = $budget->{'budget_name'};
        }
    }
    else {
        if ($budgetfilter eq 'activebudgets') {
           # If all active budgets's option was selected, get the orders of all active budgets
           my @active_budgets = C4::Budgets::GetBudgetsReport(1);
           foreach my $active_budget (@active_budgets)
           {
               push(@orders, $active_budget);
               $budget_name{$active_budget->{'budget_id'}} = $active_budget->{'budget_name'};
           }
        }
        else {
            # A budget filter was selected, only get the orders for the selected budget
            my @filtered_budgets = C4::Budgets::GetBudgetReport($budgetfilter);
            foreach my $budget (@filtered_budgets)
            {
                push(@orders, $budget);
                $budget_name{$budget->{'budget_id'}} = $budget->{'budget_name'};
            }
            if ($filtered_budgets[0]) {
                $template->param(
                    current_budget_name => $filtered_budgets[0]->{'budget_name'},
                );
            }
        }
    }

    # Format the order's informations
    foreach my $order (@orders) {
        # Get the title of the ordered item
        my $biblio = C4::Biblio::GetBiblio($order->{'biblionumber'});
        my $basket = C4::Acquisition::GetBasket($order->{'basketno'});

        $order->{'basketname'} = $basket->{'basketname'};
        $order->{'authorisedbyname'} = $basket->{'authorisedbyname'};

        $order->{'title'} = $biblio->{'title'} || $order->{'biblionumber'};

        $order->{'total_rrp'} = $order->{'quantity'} * $order->{'rrp'};
        $order->{'total_ecost'} = $order->{'quantity'} * $order->{'ecost'};

        # Format the dates and currencies correctly
        $order->{'datereceived'} = output_pref(dt_from_string($order->{'datereceived'}));
        $order->{'entrydate'} = output_pref(dt_from_string($order->{'entrydate'}));
        $total_quantity += $order->{'quantity'};
        $total_rrp += $order->{'total_rrp'};
        $total_ecost += $order->{'total_ecost'};

        # Get the budget's name
        $order->{'budget_name'} = $budget_name{$order->{'budget_id'}};
    }

    # If we are outputting to screen, output to the template.
    if($params->{"output"} eq 'screen') {
        $template->param(
            total       => scalar @orders,
            ordersloop   => \@orders,
            get_orders   => $get_orders,
            total_quantity => $total_quantity,
            total_rrp => $total_rrp,
            total_ecost => $total_ecost,
        );
    }
    # If we are outputting to a file, create it and exit.
    else {
        my $basename = $params->{"basename"};
        my $sep = $params->{"sep"};
        $sep = "\t" if ($sep eq 'tabulation');

        # TODO Use Text::CSV to generate the CSV file
        print $query->header(
           -type       => 'text/csv',
           -encoding    => 'utf-8',
           -attachment => "$basename.csv",
           -name       => "$basename.csv"
        );

        #binmode STDOUT, ":encoding(UTF-8)";

        # Surrounds a string with double-quotes and escape the double-quotes inside
        sub _surround {
            my $string = shift || "";
            $string =~ s/"/""/g;
            return "\"$string\"";
        }
        my @rows;
        foreach my $order (@orders) {
            my @row;
            push(@row, _surround($order->{'budget_name'}));
            push(@row, _surround($order->{'basketno'}));
            push(@row, _surround($order->{'basketname'}));
            push(@row, _surround($order->{'authorisedbyname'}));
            push(@row, _surround($order->{'biblionumber'}));
            push(@row, _surround($order->{'title'}));
            push(@row, _surround($order->{'currency'}));
            push(@row, _surround($order->{'listprice'}));
            push(@row, _surround($order->{'rrp'}));
            push(@row, _surround($order->{'ecost'}));
            push(@row, _surround($order->{'quantity'}));
            push(@row, _surround($order->{'total_rrp'}));
            push(@row, _surround($order->{'total_ecost'}));
            push(@row, _surround($order->{'entrydate'}));
            push(@row, _surround($order->{'datereceived'}));
            push(@row, _surround($order->{'order_internalnote'}));
            push(@row, _surround($order->{'order_vendornote'}));
            push(@rows, \@row);
        }

        my @totalrow;
        for(1..9){push(@totalrow, "")};
        push(@totalrow, _surround($total_quantity));
        push(@totalrow, _surround($total_rrp));
        push(@totalrow, _surround($total_ecost));

        my $csvTemplate = C4::Templates::gettemplate('reports/csv/orders_by_budget.tt', 'intranet', $query);
        $csvTemplate->param(sep => $sep, rows => \@rows, totalrow => \@totalrow);
        print $csvTemplate->output;

        exit(0);
    }
}
else {
    # Set file export choices
    my @outputFormats = ('CSV');
    my @CSVdelimiters =(',','#',qw(; tabulation \\ /));

    # getting all budgets
    my $budgets = GetBudgetHierarchy;
    my $budgetloop = [];
    foreach my $budget  (@{$budgets}) {
        push @{$budgetloop},{
            value    => $budget->{budget_id},
            description  => $budget->{budget_name},
            period       => $budget->{budget_period_description},
            active       => $budget->{budget_period_active},
        };
    }
    @{$budgetloop} =sort { uc( $a->{description}) cmp uc( $b->{description}) } @{$budgetloop};
    $template->param(   budgetsloop   => \@{$budgetloop},
        outputFormatloop => \@outputFormats,
        delimiterloop => \@CSVdelimiters,
        delimiterPreference => C4::Context->preference('delimiter')
    );
}

# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
