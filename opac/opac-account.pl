#!/usr/bin/perl

# Copyright Katipo Communications 2002
# Copyright Biblibre 2007,2010
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
use C4::Members;
use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use Koha::Account::Lines;
use Koha::Patrons;
use Koha::Plugins;

my $query = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-account.tt",
        query         => $query,
        type          => "opac",
    }
);

my $patron              = Koha::Patrons->find($borrowernumber);
my $account             = $patron->account;
my $accountlines        = $account->lines->search( { amountoutstanding => { '>=' => 0 } } );
my $total_outstanding   = $accountlines->total_outstanding;
my $outstanding_credits = $account->outstanding_credits;

if (   C4::Context->preference('AllowPatronToSetFinesVisibilityForGuarantor')
    || C4::Context->preference('AllowStaffToSetFinesVisibilityForGuarantor') )
{
    my @relatives;

    # Filter out guarantees that don't want guarantor to see checkouts
    foreach my $gr ( $patron->guarantee_relationships->as_list ) {
        my $g = $gr->guarantee;
        if ( $g->privacy_guarantor_fines ) {

            my $relatives_accountlines = Koha::Account::Lines->search(
                { borrowernumber => $g->borrowernumber },
                { order_by       => { -desc => 'accountlines_id' } }
            );
            push(
                @relatives,
                {
                    patron       => $g,
                    accountlines => $relatives_accountlines,
                }
            );
        }
    }
    $template->param( relatives => \@relatives );
}

$template->param(
    ACCOUNT_LINES       => $accountlines,
    total               => $total_outstanding,
    outstanding_credits => $outstanding_credits,
    accountview         => 1,
    message             => scalar $query->param('message')       || q{},
    message_value       => scalar $query->param('message_value') || q{},
    payment             => scalar $query->param('payment')       || q{},
    payment_error       => scalar $query->param('payment-error') || q{},
);

if ( C4::Context->config("enable_plugins") ) {
    my @plugins = Koha::Plugins->new()->GetPlugins(
        {
            method => 'opac_online_payment',
        }
    );

    # Only pass in plugins where opac online payment is enabled
    @plugins = grep { $_->opac_online_payment } @plugins;
    $template->param(
        plugins         => \@plugins,
        payment_methods => scalar @plugins > 0
    );
}

output_html_with_http_headers $query, $cookie, $template->output, undef, { force_no_caching => 1 };
