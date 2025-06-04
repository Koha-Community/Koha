#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2008-2009 BibLibre SARL
# Copyright 2010 PTFS Europe
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

=head1 NAME

booksellers.pl

=head1 DESCRIPTION

this script displays the baskets for a vendor

=head1 CGI PARAMETERS

=over 4

=item id or booksellerid

The id of the supplier whose baskets we will display

=back

=cut

use Modern::Perl;
use C4::Auth   qw( get_template_and_user haspermission );
use C4::Output qw( output_html_with_http_headers );
use CGI        qw ( -utf8 );

use C4::Acquisition qw( GetBasket GetBasketsInfosByBookseller CanUserManageBasket GetBasketgroup );
use C4::Budgets     qw( GetBudgetHierarchy CanUserUseBudget );

use Koha::Acquisition::Booksellers;
use Koha::Patrons;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name => 'acqui/booksellers.tt',
        query         => $query,
        type          => 'intranet',
        flagsrequired => { acquisition => '*' },
    }
);

#parameters
my $booksellerid = $query->param('booksellerid');
my $allbaskets   = $query->param('allbaskets') || 0;

my $vendor;
my $loop_suppliers = [];

if ($booksellerid) {
    $vendor = Koha::Acquisition::Booksellers->find($booksellerid);

    $template->param(
        supplier_name      => $vendor->name,
        booksellerid       => $vendor->id,
        basketcount        => $vendor->baskets->count,
        subscriptionscount => $vendor->subscriptions->count,
        active             => $vendor->active,
    );

    my $baskets = GetBasketsInfosByBookseller( $vendor->id, $allbaskets );

    my $loop_basket = [];

    for my $basket ( @{$baskets} ) {
        if ( CanUserManageBasket( $loggedinuser, $basket, $userflags ) ) {
            my $patron = Koha::Patrons->find( $basket->{authorisedby} );
            foreach (qw(total_items total_biblios expected_items)) {
                $basket->{$_} ||= 0;
            }
            if ($patron) {
                $basket->{authorisedby} = $patron;
            }
            if ( $basket->{basketgroupid} ) {
                my $basketgroup = C4::Acquisition::GetBasketgroup( $basket->{basketgroupid} );
                if ($basketgroup) {
                    $basket->{basketgroup} = $basketgroup;
                }
            }
            push @{$loop_basket}, $basket;
        }
    }

    push @{$loop_suppliers},
        {
        loop_basket       => $loop_basket,
        booksellerid      => $vendor->id,
        name              => $vendor->name,
        active            => $vendor->active,
        vendor_type       => $vendor->type,
        basketcount       => $vendor->baskets->count,
        subscriptioncount => $vendor->subscriptions->count,
        };

}
my $budgets     = GetBudgetHierarchy;
my $has_budgets = 0;
foreach my $r ( @{$budgets} ) {
    next unless ( CanUserUseBudget( $loggedinuser, $r, $userflags ) );

    $has_budgets = 1;
    last;
}

$template->param(
    loop_suppliers => $loop_suppliers,
    booksellerid   => $booksellerid,
    count          => $vendor ? 1 : 0,
    has_budgets    => $has_budgets,
);
$template->{VARS}->{'allbaskets'} = $allbaskets;

output_html_with_http_headers $query, $cookie, $template->output;
