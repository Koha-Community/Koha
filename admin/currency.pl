#!/usr/bin/perl

#script to administer the aqbudget table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# ALGO :
# this script use an $op to know what to do.
# if $op is empty or none of the above values,
#	- the default screen is build (with all records, or filtered datas).
#	- the   user can clic on add, modify or delete record.
# if $op=add_form
#	- if primkey exists, this is a modification,so we read the $primkey record
#	- builds the add/modify form
# if $op=add_validate
#	- the user has just send datas, so we create/modify the record
# if $op=delete_form
#	- we show the record having primkey=$primkey and ask for deletion validation form
# if $op=delete_confirm
#	- we delete the record having primkey=$primkey


# Copyright 2000-2002 Katipo Communications
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

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Budgets qw/GetCurrency GetCurrencies/;

our $input = CGI->new;
my $searchfield = $input->param('searchfield') || $input->param('description') || q{};
our $offset      = $input->param('offset') || 0;
my $op          = $input->param('op')     || q{};
my $script_name = '/cgi-bin/koha/admin/currency.pl';
our $pagesize = 20;

our ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => 'admin/currency.tt',
    query => $input,
    type => 'intranet',
    flagsrequired => {parameters => 'parameters_remaining_permissions'},
    authnotrequired => 0,
});

$searchfield=~ s/\,//g;


$template->param(searchfield => $searchfield,
        script_name => $script_name);

our $dbh = C4::Context->dbh;

if ( $op eq 'add_form' ) {
    add_form($searchfield);
} elsif ( $op eq 'save' ) {
    add_validate();
    print $input->redirect('/cgi-bin/koha/admin/currency.pl');
} elsif ( $op eq 'delete_confirm' ) {
    delete_confirm($searchfield);
} elsif ( $op eq 'delete_confirmed' ) {
    delete_currency($searchfield);
} else {
    default_path($searchfield);
}

output_html_with_http_headers $input, $cookie, $template->output;

sub default_path {
    my $searchfield = shift;
    $template->param( else => 1 );

    my @currencies = GetCurrencies();
    if ($searchfield) {
        @currencies = grep { $_->{currency} =~ m/^$searchfield/o } @currencies;
    }
    my $end_of_page = $offset + $pagesize;
    if ( $end_of_page > @currencies ) {
        $end_of_page = @currencies;
    } else {
        $template->param(
            ltcount  => 1,
            nextpage => $end_of_page
        );
    }
    $end_of_page--;
    my @display_curr = @currencies[ $offset .. $end_of_page ];
    my $activecurrency = GetCurrency();

    $template->param(
        loop           => \@display_curr,
        activecurrency => defined $activecurrency,
    );

    if ( $offset > 0 ) {
        $template->param(
            offsetgtzero => 1,
            prevpage     => $offset - $pagesize
        );
    }
    return;
}

sub delete_currency {
    my $curr = shift;

    # TODO This should be a method of Currency
    # also what about any orders using this currency
    $template->param( delete_confirmed => 1 );
    $dbh->do( 'delete from currency where currency=?', {}, $curr );
    return;
}

sub delete_confirm {
    my $curr = shift;

    $template->param( delete_confirm => 1 );
    my $total_row = $dbh->selectrow_hashref(
        'select count(*) as total from aqbooksellers where currency=?',
        {}, $curr );

    my $curr_ref = $dbh->selectrow_hashref(
        'select currency,rate from currency where currency=?',
        {}, $curr );

    if ( $total_row->{total} ) {
        $template->param( totalgtzero => 1 );
    }

    $template->param(
        rate  => $curr_ref->{rate},
        total => $total_row->{total}
    );

    return;
}

sub add_form {
    my $curr = shift;

    $template->param( add_form => 1 );

    #---- if primkey exists, it's a modify action, so read values to modify...
    my $date;
    if ($curr) {
        my $curr_rec =
          $dbh->selectrow_hashref( 'select * from currency where currency=?',
            {}, $curr );
        for ( keys %{$curr_rec} ) {
            if($_ eq "timestamp"){ $date = $curr_rec->{$_}; }
            $template->param( $_ => $curr_rec->{$_} );
        }
    }

    return;
}

sub add_validate {
    $template->param( add_validate => 1 );

    my $rec = {
        rate     => $input->param('rate'),
        symbol   => $input->param('symbol') || q{},
        isocode  => $input->param('isocode') || q{},
        active   => $input->param('active') || 0,
        currency => $input->param('currency'),
    };

    if ( $rec->{active} == 1 ) {
        $dbh->do('UPDATE currency SET active = 0');
    }

    my ($row_count) = $dbh->selectrow_array(
        'select count(*) as count from currency where currency = ?',
        {}, $input->param('currency') );
    if ($row_count) {
        $dbh->do(
q|UPDATE currency SET rate = ?, symbol = ?, isocode = ?, active = ? WHERE currency = ? |,
            {},
            $rec->{rate},
            $rec->{symbol},
            $rec->{isocode},
            $rec->{active},
            $rec->{currency}
        );
    } else {
        $dbh->do(
q|INSERT INTO currency (currency, rate, symbol, isocode, active) VALUES (?,?,?,?,?) |,
            {},
            $rec->{currency},
            $rec->{rate},
            $rec->{symbol},
            $rec->{isocode},
            $rec->{active}
        );

    }
    return;
}
