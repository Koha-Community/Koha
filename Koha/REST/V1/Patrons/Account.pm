package Koha::REST::V1::Patrons::Account;

# This file is part of Koha.
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::Patrons;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Patrons::Account

=head1 API

=head2 Methods

=head3 get

Controller function that handles retrieving a patron's account balance

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find($patron_id);

    unless ($patron) {
        return $c->render( status => 404, openapi => { error => "Patron not found." } );
    }

    my $account = $patron->account;
    my $balance;

    $balance->{balance} = $account->balance;

    # get outstanding debits and credits
    my $debits  = $account->outstanding_debits;
    my $credits = $account->outstanding_credits;

    my @debit_lines = map { _to_api( $_->TO_JSON ) } @{ $debits->as_list };
    $balance->{outstanding_debits} = {
        total => $debits->total_outstanding,
        lines => \@debit_lines
    };

    my @credit_lines = map { _to_api( $_->TO_JSON ) } @{ $credits->as_list };
    $balance->{outstanding_credits} = {
        total => $credits->total_outstanding,
        lines => \@credit_lines
    };

    return $c->render( status => 200, openapi => $balance );
}

=head3 add_credit

Controller function that handles adding a credit to a patron's account

=cut

sub add_credit {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find($patron_id);
    my $user      = $c->stash('koha.user');


    unless ($patron) {
        return $c->render( status => 404, openapi => { error => "Patron not found." } );
    }

    my $account = $patron->account;
    my $body    = $c->validation->param('body');

    return try {
        my $credit_type = $body->{credit_type} || 'payment';    # default to 'payment'
        my $amount = $body->{amount};                           # mandatory, validated by openapi

        unless ( $amount > 0 ) {  # until we support newer JSON::Validator and thus minimumExclusive
            Koha::Exceptions::BadParameter->throw( { parameter => 'amount' } );
        }

        # read the rest of the params
        my $payment_type = $body->{payment_type};
        my $description  = $body->{description};
        my $note         = $body->{note};

        my $credit = $account->add_credit(
            {   amount       => $amount,
                credit_type  => $credit_type,
                payment_type => $payment_type,
                description  => $description,
                note         => $note,
                user_id      => $user->id
            }
        );
        $credit->discard_changes;

        my $date = $body->{date};
        $credit->date( $date )->store
            if $date;

        my $debits_ids = $body->{account_lines_ids};
        my $debits;
        $debits = Koha::Account::Lines->search({ accountlines_id => { -in => $debits_ids } })
            if $debits_ids;

        my $outstanding_credit = $credit->amountoutstanding;
        if ($debits) {
            # pay them!
            $outstanding_credit = $credit->apply({ debits => $debits, offset_type => 'payment' });
        }

        if ($outstanding_credit) {
            my $outstanding_debits = $account->outstanding_debits;
            $credit->apply({ debits => $outstanding_debits, offset_type => 'payment' });
        }

        return $c->render( status => 200, openapi => { account_line_id => $credit->id } );
    }
    catch {
        if ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "$_" }
            );
        }
        else {
            # Exception, rely on the stringified exception
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs" }
            );
        }
    };
}


=head3 _to_api

Helper function that maps unblessed Koha::Account::Line objects
into REST API attribute names.

=cut

sub _to_api {
    my $account_line = shift;

    # Rename attributes
    foreach my $column ( keys %{ $Koha::REST::V1::Patrons::Account::to_api_mapping } ) {
        my $mapped_column = $Koha::REST::V1::Patrons::Account::to_api_mapping->{$column};
        if (    exists $account_line->{ $column }
             && defined $mapped_column )
        {
            # key != undef
            $account_line->{ $mapped_column } = delete $account_line->{ $column };
        }
        elsif (    exists $account_line->{ $column }
                && !defined $mapped_column )
        {
            # key == undef
            delete $account_line->{ $column };
        }
    }

    return $account_line;
}

=head3 _to_model

Helper function that maps REST API objects into Koha::Account::Line
attribute names.

=cut

sub _to_model {
    my $account_line = shift;

    foreach my $attribute ( keys %{ $Koha::REST::V1::Patrons::Account::to_model_mapping } ) {
        my $mapped_attribute = $Koha::REST::V1::Patrons::Account::to_model_mapping->{$attribute};
        if (    exists $account_line->{ $attribute }
             && defined $mapped_attribute )
        {
            # key => !undef
            $account_line->{ $mapped_attribute } = delete $account_line->{ $attribute };
        }
        elsif (    exists $account_line->{ $attribute }
                && !defined $mapped_attribute )
        {
            # key => undef / to be deleted
            delete $account_line->{ $attribute };
        }
    }

    return $account_line;
}

=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    accountlines_id   => 'account_line_id',
    accountno         => undef,                  # removed
    accounttype       => 'account_type',
    amountoutstanding => 'amount_outstanding',
    borrowernumber    => 'patron_id',
    dispute           => undef,
    issue_id          => 'checkout_id',
    itemnumber        => 'item_id',
    manager_id        => 'user_id',
    note              => 'internal_note',
};

=head3 $to_model_mapping

=cut

our $to_model_mapping = {
    account_line_id    => 'accountlines_id',
    account_type       => 'accounttype',
    amount_outstanding => 'amountoutstanding',
    checkout_id        => 'issue_id',
    internal_note      => 'note',
    item_id            => 'itemnumber',
    patron_id          => 'borrowernumber',
    user_id            => 'manager_id'
};

1;
