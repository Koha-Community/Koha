#!/usr/bin/perl

#script to show suppliers and orders

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

this script displays the list of suppliers & baskets like C<$supplier> given on input arg.
thus, this page brings differents features like to display supplier's details,
to add an order for a specific supplier or to just add a new supplier.

=head1 CGI PARAMETERS

=over 4

=item supplier

C<$supplier> is the string with which we search for a supplier

=back

=over 4

=item id or booksellerid

The id of the supplier whose baskets we will display

=back

=cut

use strict;
use warnings;
use C4::Auth;
use C4::Biblio;
use C4::Budgets;
use C4::Output;
use CGI;

use C4::Acquisition qw/ GetBasketsInfosByBookseller CanUserManageBasket /;
use C4::Bookseller qw/ GetBookSellerFromId GetBookSeller /;
use C4::Members qw/GetMember/;
use C4::Context;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {   template_name   => 'acqui/booksellers.tt',
        query           => $query,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

#parameters
my $supplier = $query->param('supplier');
my $booksellerid = $query->param('booksellerid');
my $allbaskets= $query->param('allbaskets')||0;
my @suppliers;

if ($booksellerid) {
    push @suppliers, GetBookSellerFromId($booksellerid);
} else {
    @suppliers = GetBookSeller($supplier);
}

my $supplier_count = @suppliers;
if ( $supplier_count == 1 ) {
    $template->param(
        supplier_name => $suppliers[0]->{'name'},
        booksellerid  => $suppliers[0]->{'id'},
        basketcount   => $suppliers[0]->{'basketcount'}
    );
}

my $uid;
if ($loggedinuser) {
    $uid = GetMember( borrowernumber => $loggedinuser )->{userid};
}

my $userenv = C4::Context::userenv;
my $viewbaskets = C4::Context->preference('AcqViewBaskets');

my $userbranch = $userenv->{branch};

my $budgets = GetBudgetHierarchy;
my $has_budgets = 0;
foreach my $r (@{$budgets}) {
    if (!defined $r->{budget_amount} || $r->{budget_amount} == 0) {
        next;
    }
    next unless (CanUserUseBudget($loggedinuser, $r, $userflags));

    $has_budgets = 1;
    last;
}

#build result page
my $loop_suppliers = [];

for my $vendor (@suppliers) {
    my $baskets = GetBasketsInfosByBookseller( $vendor->{id}, $allbaskets );

    my $loop_basket = [];

    for my $basket ( @{$baskets} ) {
        if (CanUserManageBasket($loggedinuser, $basket, $userflags)) {
            my $member = GetMember( borrowernumber => $basket->{authorisedby} );
            foreach (qw(total_items total_biblios expected_items)) {
                $basket->{$_} ||= 0;
            }
            if($member) {
                $basket->{authorisedby_firstname} = $member->{firstname};
                $basket->{authorisedby_surname} = $member->{surname};
            }
            if ($basket->{basketgroupid}) {
                my $basketgroup = C4::Acquisition::GetBasketgroup($basket->{basketgroupid});
                if ($basketgroup) {
                    $basket->{basketgroup} = $basketgroup;
                }
            }
            push @{$loop_basket}, $basket; 
        }
    }

    push @{$loop_suppliers},
      { loop_basket => $loop_basket,
        booksellerid  => $vendor->{id},
        name        => $vendor->{name},
        active      => $vendor->{active},
      };

}
$template->param(
    loop_suppliers => $loop_suppliers,
    supplier       => ( $booksellerid || $supplier ),
    count          => $supplier_count,
    has_budgets          => $has_budgets,
);
$template->{VARS}->{'allbaskets'} = $allbaskets;

output_html_with_http_headers $query, $cookie, $template->output;
