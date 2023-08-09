#!/usr/bin/perl

#script to add basket and edit header options (name, notes and contractnumber)
#written by john.soros@biblibre.com 15/09/2008

# Copyright 2008 - 2009 BibLibre SARL
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

basketheader.pl

=head1 DESCRIPTION

This script is used to edit the basket's "header", or add a new basket, the header contains the supplier ID,
notes to the supplier, local notes, and the contractnumber, which identifies the basket to a specific contract.

=head1 CGI PARAMETERS

=over 4

=item booksellerid

C<$booksellerid> is the id of the supplier we add the basket to.

=item basketid

If it exists, C<$basketno> is the basket we edit

=back

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Acquisition qw( GetBasket ModBasket ModBasketHeader NewBasket );
use C4::Contract qw( GetContracts GetContract );

use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Baskets;
use Koha::AdditionalFields;

my $input = CGI->new;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/basketheader.tt",
        query           => $input,
        type            => "intranet",
       flagsrequired   => { acquisition => 'order_manage' },
    }
);

#parameters:
my $booksellerid = $input->param('booksellerid');
my $basketno = $input->param('basketno');
my $basket;
my $op = $input->param('op');
my $is_an_edit = $input->param('is_an_edit');

$template->param( available_additional_fields => Koha::AdditionalFields->search( { tablename => 'aqbasket' } ) );

if ( $op eq 'add_form' ) {
    my @contractloop;
    if ( $basketno ) {
    #this is an edit
        $basket = GetBasket($basketno);
        if (! $booksellerid) {
            $booksellerid=$basket->{'booksellerid'};
        }
        my $contracts = GetContracts({
            booksellerid => $booksellerid,
            activeonly => 1,
        });

        @contractloop = @$contracts;
        for (@contractloop) {
            if ( $basket->{'contractnumber'} eq $_->{'contractnumber'} ) {
                $_->{'selected'} = 1;
            }
        }
        $template->param( is_an_edit => 1);
        $template->param(
            additional_field_values => { map {
                $_->field->id => $_->value
            } Koha::Acquisition::Baskets->find($basketno)->additional_field_values->as_list },
        );
    } else {
    #new basket
        my $basket;
        my $contracts = GetContracts({
            booksellerid => $booksellerid,
            activeonly => 1,
        });
        push(@contractloop, @$contracts);
    }
    my $bookseller = Koha::Acquisition::Booksellers->find( $booksellerid );
    my $count = scalar @contractloop;
    if ( $count > 0) {
        $template->param(contractloop => \@contractloop,
                         basketcontractnumber => $basket->{'contractnumber'});
    }

    $template->param( add_form => 1,
                    basketname => $basket->{'basketname'},
                    basketnote => $basket->{'note'},
                    basketbooksellernote => $basket->{'booksellernote'},
                    booksellername => $bookseller->name,
                    booksellerid => $booksellerid,
                    basketno => $basketno,
                    is_standing => $basket->{is_standing},
                    create_items => $basket->{create_items},
    );

    my $billingplace = $basket->{'billingplace'} || C4::Context->userenv->{"branch"};
    my $deliveryplace = $basket->{'deliveryplace'} || C4::Context->userenv->{"branch"};

    $template->param( billingplace => $billingplace );
    $template->param( deliveryplace => $deliveryplace );

#End Edit
} elsif ( $op eq 'add_validate' ) {
#we are confirming the changes, save the basket
    if ( $is_an_edit ) {
        ModBasketHeader(
            $basketno,
            scalar $input->param('basketname'),
            scalar $input->param('basketnote'),
            scalar $input->param('basketbooksellernote'),
            scalar $input->param('basketcontractnumber') || undef,
            scalar $input->param('basketbooksellerid'),
            scalar $input->param('deliveryplace'),
            scalar $input->param('billingplace'),
            scalar $input->param('is_standing') ? 1 : undef,
            scalar $input->param('create_items')
        );
    } else { #New basket
        $basketno = NewBasket(
            scalar $input->param('basketbooksellerid'),
            $loggedinuser,
            scalar $input->param('basketname'),
            scalar $input->param('basketnote'),
            scalar $input->param('basketbooksellernote'),
            scalar $input->param('basketcontractnumber') || undef,
            scalar $input->param('deliveryplace'),
            scalar $input->param('billingplace'),
            scalar $input->param('is_standing') ? 1 : undef,
            scalar $input->param('create_items')
        );
    }

    my @additional_fields;
    my $basket_fields = Koha::AdditionalFields->search({ tablename => 'aqbasket' });
    while ( my $field = $basket_fields->next ) {
        my $value = $input->param('additional_field_' . $field->id);
        push @additional_fields, {
            id => $field->id,
            value => $value,
        };
    }
    Koha::Acquisition::Baskets->find($basketno)->set_additional_fields(\@additional_fields);

    print $input->redirect('basket.pl?basketno='.$basketno);
    exit 0;
}
output_html_with_http_headers $input, $cookie, $template->output;
