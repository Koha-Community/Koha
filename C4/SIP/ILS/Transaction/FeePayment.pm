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

use Koha::Account;
use Koha::Account::Lines;

use parent qw(C4::SIP::ILS::Transaction);

our $debug = 0;

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

    my $type = $is_writeoff ? 'writeoff' : undef;

    warn("RECORD:$borrowernumber::$amt");

    my $account = Koha::Account->new( { patron_id => $borrowernumber } );

    if ($disallow_overpayment) {
        return 0 if $account->balance < $amt;
    }

    if ($fee_id) {
        my $fee = Koha::Account::Lines->find($fee_id);
        if ( $fee ) {
            $account->pay(
                {
                    amount => $amt,
                    sip    => $sip_type,
                    type   => $type,
                    lines  => [$fee],
                }
            );
            return 1;
        }
        else {
            return 0;
        }
    }
    else {
        $account->pay(
            {
                amount => $amt,
                sip    => $sip_type,
                type   => $type,
            }
        );
        return 1;
    }
}

#sub DESTROY {
#}

1;
__END__

