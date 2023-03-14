package C4::SIP::ILS::Transaction::FeePayment;

use warnings;
use strict;

# Copyright 2011 PTFS-Europe Ltd.
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

use Try::Tiny;

use Koha::Account;
use Koha::Account::Lines;

use parent qw(C4::SIP::ILS::Transaction);

my %fields = ();

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();

    foreach ( keys %fields ) {
        $self->{_permitted}->{$_} = $fields{$_};    # overlaying _permitted
    }

    @{$self}{ keys %fields } = values %fields;    # copying defaults into object
    return bless $self, $class;
}

sub pay {
    my $self                 = shift;
    my $borrowernumber       = shift;
    my $amt                  = shift;
    my $sip_type             = shift;
    my $fee_id               = shift;
    my $is_writeoff          = shift;
    my $disallow_overpayment = shift;
    my $register_id          = shift;

    my $type = $is_writeoff ? 'WRITEOFF' : 'PAYMENT';

    my $account = Koha::Account->new( { patron_id => $borrowernumber } );

    if ($disallow_overpayment) {
        return { ok => 0 } if $account->balance < $amt;
    }

    my $pay_options = {
        amount        => $amt,
        type          => $type,
        payment_type  => 'SIP' . $sip_type,
        interface     => C4::Context->interface,
        cash_register => $register_id,
    };

    if ($fee_id) {
        my $fee = Koha::Account::Lines->find($fee_id);
        if ( $fee ) {
            $pay_options->{lines} = [$fee];
        }
        else {
            return {
                ok => 0
            };
        }
    }

    my $ok = 1;
    my $pay_response;
    my $error;
    try {
        $pay_response = $account->pay($pay_options);
    }
    catch {
        $ok = 0;

        if ( ref($_) =~ /^Koha::Exceptions/ ) {
            $error = $_->description;
        }
        else {
            $_->rethrow;
        }
    };

    return {
        ok           => $ok,
        pay_response => $pay_response,
        error        => $error,
    };
}

#sub DESTROY {
#}

1;
__END__

