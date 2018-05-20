#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2002 Paul Poulain
# Copyright Koha Development Team
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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Context;
use C4::Output;

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Currencies;
use Koha::Acquisition::Orders;

my $input         = CGI->new;
my $searchfield   = $input->param('searchfield') || $input->param('description') || q{};
my $currency_code = $input->param('currency_code');
my $op            = $input->param('op') || 'list';
my @messages;

our ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => 'admin/currency.tt',
        query           => $input,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'currencies_manage' },
    }
);

if ( $op eq 'add_form' ) {
    my $currency;
    if ($currency_code) {
        $currency = Koha::Acquisition::Currencies->find($currency_code);
    }

    $template->param( currency => $currency, );
} elsif ( $op eq 'add_validate' ) {
    my $currency_code = $input->param('currency_code');
    my $symbol        = $input->param('symbol');
    my $isocode       = $input->param('isocode');
    my $rate          = $input->param('rate');
    my $active        = $input->param('active');
    my $p_sep_by_space = $input->param('p_sep_by_space');
    my $is_a_modif    = $input->param('is_a_modif');

    if ($is_a_modif) {
        my $currency = Koha::Acquisition::Currencies->find($currency_code);
        $currency->symbol($symbol);
        $currency->isocode($isocode);
        $currency->rate($rate);
        $currency->active($active);
        $currency->p_sep_by_space($p_sep_by_space);
        eval { $currency->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_update' };
        } else {
            push @messages, { type => 'message', code => 'success_on_update' };
        }
    } else {
        my $currency = Koha::Acquisition::Currency->new(
            {   currency => $currency_code,
                symbol   => $symbol,
                isocode  => $isocode,
                rate     => $rate,
                active   => $active,
                p_sep_by_space => $p_sep_by_space,
            }
        );
        eval { $currency->store; };
        if ($@) {
            push @messages, { type => 'error', code => 'error_on_insert' };
        } else {
            push @messages, { type => 'message', code => 'success_on_insert' };
        }
    }
    $searchfield = q||;
    $op          = 'list';
} elsif ( $op eq 'delete_confirm' ) {
    my $currency = Koha::Acquisition::Currencies->find($currency_code);

    my $nb_of_orders = Koha::Acquisition::Orders->search( { currency => $currency->currency } )->count;
    my $nb_of_vendors = Koha::Acquisition::Booksellers->search( { -or => { listprice => $currency->currency, invoiceprice => $currency->currency } })->count;
    $template->param(
        currency     => $currency,
        nb_of_orders => $nb_of_orders,
        nb_of_vendors => $nb_of_vendors,
    );
} elsif ( $op eq 'delete_confirmed' ) {
    my $currency = Koha::Acquisition::Currencies->find($currency_code);
    my $deleted = eval { $currency->delete; };

    if ( $@ or not $deleted ) {
        push @messages, { type => 'error', code => 'error_on_delete' };
    } else {
        push @messages, { type => 'message', code => 'success_on_delete' };
    }
    $op = 'list';
}

if ( $op eq 'list' ) {
    $searchfield =~ s/\,//g;
    my $currencies = Koha::Acquisition::Currencies->search( { currency => { -like => "$searchfield%" } } );

    my $no_active_currency = not Koha::Acquisition::Currencies->search( { active => 1 } )->count;
    $template->param(
        currencies         => $currencies,
        no_active_currency => $no_active_currency,
    );
}

$template->param(
    searchfield => $searchfield,
    messages    => \@messages,
    op          => $op,
);

output_html_with_http_headers $input, $cookie, $template->output;
