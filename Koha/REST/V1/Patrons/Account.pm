package Koha::REST::V1::Patrons::Account;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::Patrons;

use Try::Tiny qw( catch try );

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

    return try {
        my $account = $patron->account;

        # get outstanding debits and credits
        my $debits  = $account->outstanding_debits;
        my $credits = $account->outstanding_credits;

        return $c->render(
            status  => 200,
            openapi => {
                balance => $account->balance,
                outstanding_debits => {
                    total => $debits->total_outstanding,
                    lines => $debits->to_api
                },
                outstanding_credits => {
                    total => $credits->total_outstanding,
                    lines => $credits->to_api
                }
            }
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_credits

=cut

sub list_credits {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find($patron_id);

    unless ($patron) {
        return $c->render( status => 404, openapi => { error => "Patron not found." } );
    }

    return try {
        my $account = $patron->account;

        my $credits_set = $account->credits;
        my $credits = $c->objects->search( $credits_set );
        return $c->render( status => 200, openapi => $credits );
    }
    catch {
        $c->unhandled_exception($_);
    };
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
        my $credit_type = $body->{credit_type} || 'PAYMENT';    # default to 'PAYMENT'
        my $amount = $body->{amount};                           # mandatory, validated by openapi

        unless ( $amount > 0 ) {  # until we support newer JSON::Validator and thus minimumExclusive
            Koha::Exceptions::BadParameter->throw( { parameter => 'amount' } );
        }

        # read the rest of the params
        my $payment_type = $body->{payment_type};
        my $description  = $body->{description};
        my $note         = $body->{note};
        my $library_id   = $body->{library_id};

        my $credit = $account->add_credit(
            {   amount       => $amount,
                type         => $credit_type,
                payment_type => $payment_type,
                description  => $description,
                note         => $note,
                user_id      => $user->id,
                interface    => 'api',
                library_id   => $library_id
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

        if ($debits) {
            # pay them!
            $credit = $credit->apply({ debits => [ $debits->as_list ] });
        }

        if ($credit->amountoutstanding != 0) {
            my $outstanding_debits = $account->outstanding_debits;
            $credit->apply({ debits => [ $outstanding_debits->as_list ] });
        }

        $credit->discard_changes;

        return $c->render(
            status  => 201,
            openapi => $credit->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_debits

=cut

sub list_debits {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('patron_id');
    my $patron    = Koha::Patrons->find($patron_id);

    unless ($patron) {
        return $c->render( status => 404, openapi => { error => "Patron not found." } );
    }

    return try {
        my $account = $patron->account;

        my $debits_set = $account->debits;
        my $debits = $c->objects->search( $debits_set );
        return $c->render( status => 200, openapi => $debits );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
