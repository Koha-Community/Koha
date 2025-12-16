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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

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

use Modern::Perl;
use CGI             qw ( -utf8 );
use C4::Auth        qw( get_template_and_user );
use C4::Output      qw( output_html_with_http_headers );
use C4::Acquisition qw( GetHistory );
use Koha::AdditionalFields;
use Koha::DateUtils qw( dt_from_string );

my $input     = CGI->new;
my $do_search = $input->param('do_search') || 0;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "acqui/histsearch.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { acquisition => '*' },
    }
);

my $filters = {
    basket                  => scalar $input->param('basket'),
    title                   => scalar $input->param('title'),
    author                  => scalar $input->param('author'),
    isbn                    => scalar $input->param('isbn'),
    issn                    => scalar $input->param('issn'),
    name                    => scalar $input->param('name'),
    internalnote            => scalar $input->param('internalnote'),
    vendornote              => scalar $input->param('vendornote'),
    ean                     => scalar $input->param('ean'),
    basketgroupname         => scalar $input->param('basketgroupname'),
    budget                  => scalar $input->param('budget'),
    booksellerinvoicenumber => scalar $input->param('booksellerinvoicenumber'),
    budget                  => scalar $input->param('budget'),
    orderstatus             => scalar $input->param('orderstatus'),
    is_standing             => scalar $input->param('is_standing'),
    ordernumber             => scalar $input->param('ordernumber'),
    search_children_too     => scalar $input->param('search_children_too'),
    created_by              => [ $input->multi_param('created_by') ],
    managing_library        => scalar $input->param('managing_library'),
};

my $from_placed_on = eval { dt_from_string( scalar $input->param('from') ) } || dt_from_string;
my $to_placed_on   = eval { dt_from_string( scalar $input->param('to') ) }   || dt_from_string;
unless ( $input->param('from') ) {

    # Fill the form with year-1
    $from_placed_on->set_time_zone('floating')->subtract( years => 1 );
}
$filters->{from_placed_on} = $from_placed_on;
$filters->{to_placed_on}   = $to_placed_on;
my $additional_fields = Koha::AdditionalFields->search( { tablename => 'aqbasket', searchable => 1 } );
$template->param( available_additional_fields => $additional_fields );
my @additional_field_filters;
while ( my $additional_field = $additional_fields->next ) {
    my $value = $input->param( 'additional_field_' . $additional_field->id );
    if ( defined $value and $value ne '' ) {
        push @additional_field_filters, {
            id    => $additional_field->id,
            value => $value,
        };
    }
}
$filters->{additional_fields} = \@additional_field_filters;

# Set filter for 'all status'
if ( $filters->{orderstatus} eq "any" ) {
    $filters->{get_canceled_order} = 1;
}

my $order_loop;

# If we're supplied any value then we do a search. Otherwise we don't.
if ($do_search) {
    $order_loop = GetHistory(%$filters);
}

my $budgetperiods = C4::Budgets::GetBudgetPeriods;
my $bp_loop       = $budgetperiods;
for my $bp ( @{$budgetperiods} ) {
    my $hierarchy = C4::Budgets::GetBudgetHierarchy( $$bp{budget_period_id}, undef, undef, 1 );
    for my $budget ( @{$hierarchy} ) {
        $$budget{budget_display_name} = sprintf( "%s", ">" x $$budget{depth} . $$budget{budget_name} );
    }
    $$bp{hierarchy} = $hierarchy;
}

$template->param(
    order_loop  => $order_loop,
    filters     => $filters,
    bp_loop     => $bp_loop,
    search_done => $do_search,
);

output_html_with_http_headers $input, $cookie, $template->output;
