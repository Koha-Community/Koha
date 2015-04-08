#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2004 Biblibre
# Parts copyright 2011 Catalyst IT Ltd.
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

=head1 NAME

histsearch.pl

=head1 DESCRIPTION

this script offer a interface to search among order.

=head1 CGI PARAMETERS

=over 4

=item title
if the script has to filter the results on title.

=item author
if the script has to filter the results on author.

=item name
if the script has to filter the results on supplier.

=item fromplacedon
to filter on started date.

=item toplacedon
to filter on ended date.

=back

=cut

use strict;
#use warnings; FIXME - Bug 2505
use CGI;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Acquisition;
use C4::Dates;
use C4::Debug;
use C4::Branch;
use C4::Koha;

my $input = new CGI;
my $title                   = $input->param( 'title');
my $author                  = $input->param('author');
my $isbn                    = $input->param('isbn');
my $name                    = $input->param( 'name' );
my $ean                     = $input->param('ean');
my $basket                  = $input->param( 'basket' );
my $basketgroupname             = $input->param('basketgroupname');
my $booksellerinvoicenumber = $input->param( 'booksellerinvoicenumber' );
my $do_search               = $input->param('do_search') || 0;
my $from_placed_on          = C4::Dates->new($input->param('from'));
my $to_placed_on            = C4::Dates->new($input->param('to'));
my $budget                  = $input->param( 'budget' );
my $orderstatus             = $input->param( 'orderstatus' );
my $ordernumber             = $input->param( 'ordernumber' );
my $search_children_too     = $input->param( 'search_children_too' );

if ( not $input->param('from') ) {
    # FIXME Dirty but we can't sent a Date::Calc to C4::Dates ?
    # We would use a function like Add_Delta_YM(-1, 0, 0);
    $$from_placed_on{dmy_arrayref}[5] -= 1;
}

my $dbh = C4::Context->dbh;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/histsearch.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

my ( $from_iso, $to_iso, $d );
if ( $d = $input->param('from') ) {
    $from_iso = C4::Dates->new($d)->output('iso');
}
if ( $d = $input->param('iso') ) {
    $to_iso = C4::Dates->new($d)->output('iso');
}

my $order_loop;
# If we're supplied any value then we do a search. Otherwise we don't.
if ($do_search) {
    $order_loop = GetHistory(
        title => $title,
        author => $author,
        isbn   => $isbn,
        ean   => $ean,
        name => $name,
        from_placed_on => $from_iso,
        to_placed_on => $to_iso,
        basket => $basket,
        booksellerinvoicenumber => $booksellerinvoicenumber,
        basketgroupname => $basketgroupname,
        budget => $budget,
        orderstatus => $orderstatus,
        ordernumber => $ordernumber,
        search_children_too => $search_children_too,
    );
}

my $from_date = $from_placed_on ? $from_placed_on->output('syspref') : undef;
my $to_date = $to_placed_on ? $to_placed_on->output('syspref') : undef;

my $budgetperiods = C4::Budgets::GetBudgetPeriods;
my $bp_loop = $budgetperiods;
for my $bp ( @{$budgetperiods} ) {
    my $hierarchy = C4::Budgets::GetBudgetHierarchy( $$bp{budget_period_id} );
    for my $budget ( @{$hierarchy} ) {
        $$budget{budget_display_name} = sprintf("%s", ">" x $$budget{depth} . $$budget{budget_name});
    }
    $$bp{hierarchy} = $hierarchy;
}

$template->param(
    order_loop              => $order_loop,
    numresults              => $order_loop ? scalar(@$order_loop) : undef,
    title                   => $title,
    author                  => $author,
    isbn                    => $isbn,
    ean                     => $ean,
    name                    => $name,
    basket                  => $basket,
    booksellerinvoicenumber => $booksellerinvoicenumber,
    basketgroupname         => $basketgroupname,
    ordernumber             => $ordernumber,
    search_children_too     => $search_children_too,
    from_placed_on          => $from_date,
    to_placed_on            => $to_date,
    orderstatus             => $orderstatus,
    budget_id               => $budget,
    bp_loop                 => $bp_loop,
    search_done             => $do_search,
    debug                   => $debug || $input->param('debug') || 0,
    uc(C4::Context->preference("marcflavour")) => 1
);

output_html_with_http_headers $input, $cookie, $template->output;
