package Koha::PaymentsTransaction;

# Copyright 2016 KohaSuomi
#
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

use base qw(Koha::Object);

use Data::Dumper;
use Scalar::Util qw (looks_like_number);

use C4::Accounts;
use C4::Context;
use C4::Log;
use C4::Stats;
use Koha::Account;

use Koha::Patron::Debarments;
use Koha::Database;
use Koha::Exception::BadParameter;

sub _type {
    return 'PaymentsTransaction';
}

=head2 AddRelatedAccountlines

  &AddRelatedAccountlines({
            paid => 10.0,
            selected => @{ 1, 2, 3 }
        });

Adds the related accountlines' to a payment. The parameter selected requires
"accountline_id"s of this borrower.

The related accountlines will go to database table
payments_transactions_accountlines and will have a foreign key to
"accountlines.accountlines_id" and "payments_transactions.transaction_id"

=cut

sub AddRelatedAccountlines {
    my ($self, $data) = @_;

    # Make some simple validations
    Koha::Exception::BadParameter->throw(error => "Parameter 'paid' must be given")
            unless defined $data->{paid};
    Koha::Exception::BadParameter->throw(error => "Parameter 'paid' must be numeric")
            unless Scalar::Util::looks_like_number($data->{paid});

    my $dbh = C4::Context->dbh;
    my $borrowernumber = $self->borrowernumber;
    my @selected = @{ $data->{selected} } if defined $data->{selected};
    @selected = sort { $a <=> $b } @selected if @selected > 1;

    my $money_left = _convert_to_cents($data->{paid});
    my $total_price = 0;
    my $use_selected = (@selected > 0) ? "AND accountlines_id IN (?".+(",?") x (@selected-1).")" : "";
    my $sql = "SELECT * FROM accountlines WHERE borrowernumber=? AND (amountoutstanding>0) ".$use_selected." ORDER BY date";
    my $sth = $dbh->prepare($sql);

    $sth->execute($borrowernumber, @selected);

    my $added_accountlines;

    while ( (my $accdata = $sth->fetchrow_hashref) and $money_left > 0) {
        my $product;
        $product->{accounttype} = $accdata->{'accounttype'};
        $product->{amount} = 1;
        $product->{description} = $accdata->{'description'};

        if ( _convert_to_cents($accdata->{'amountoutstanding'}) >= $money_left ) {
            $product->{price} = $money_left;
            $money_left = 0;
        } else {
            $product->{price} = _convert_to_cents($accdata->{'amountoutstanding'});
            $money_left -= _convert_to_cents($accdata->{'amountoutstanding'});
        }
        push @$added_accountlines, $product;
        $total_price += $product->{price};

        $self->_add_related_accountline($accdata->{'accountlines_id'}, $product->{price});
    }

    $self->set({ price_in_cents => $total_price })->store();

    return $added_accountlines;
}

sub _add_related_accountline {
    my ($self, $accountlines_id, $paid_price) = @_;

    return 0 unless defined $accountlines_id and defined $paid_price;

    my $dbh = C4::Context->dbh;
    my $sql = "INSERT INTO payments_transactions_accountlines (transaction_id, accountlines_id, paid_price_cents) VALUES (?, ?, ?)";

    my $sth = $dbh->prepare($sql);
    $sth->execute($self->transaction_id, $accountlines_id, $paid_price);

    return $dbh->last_insert_id(undef,undef,'payments_transactions_accountlines',undef);
}

sub GetRelatedAccountlines {
    my ($self) = @_;

    my $dbh = C4::Context->dbh;
    my $sql = "SELECT accountlines.accountlines_id, accountlines.amountoutstanding, accountlines.accountno, payments_transactions_accountlines.paid_price_cents, payments_transactions_accountlines.transaction_id, accountlines.description, accountlines.itemnumber FROM accountlines INNER JOIN payments_transactions_accountlines
ON payments_transactions_accountlines.accountlines_id = accountlines.accountlines_id AND payments_transactions_accountlines.transaction_id=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($self->transaction_id);

    my $hash_ref = $sth->fetchall_arrayref({});
    $sth->finish;
    return $hash_ref;
}

sub GetProducts {
    my ($self) = @_;

    my $dbh = C4::Context->dbh;
    my $sql = "SELECT accountlines.accounttype, payments_transactions_accountlines.paid_price_cents, accountlines.description, accountlines.itemnumber FROM accountlines INNER JOIN payments_transactions_accountlines
ON payments_transactions_accountlines.accountlines_id = accountlines.accountlines_id AND payments_transactions_accountlines.transaction_id=?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($self->transaction_id);

    my @products;

    while (my $accountline = $sth->fetchrow_hashref) {
        my $product;
        $product->{accounttype} = $accountline->{'accounttype'};
        $product->{price} = $accountline->{'paid_price_cents'};
        $product->{description} = $accountline->{'description'};
        $product->{itemnumber} = $accountline->{'itemnumber'};
        push @products, $product;
    }

    return \@products;
}

=head2 CompletePayment

  &CompletePayment("paid");

Completes the payment in Koha with the given status.

"paid" = complete payment and modify accountlines accordingly
"cancelled" = cancel payment and leave accountlines untouched

=cut

sub CompletePayment {
    my ($self, $status) = @_;
    my $dbh                 = C4::Context->dbh;
    my $manager_id          = 0;
    $manager_id             = $self->manager_id;
    my $branch              = $self->is_self_payment == 1
                                ? $self->user_branch
                                : C4::Context->userenv
                                    ? C4::Context->userenv->{'branch'}
                                    : $self->user_branch;
    my $description = "";
    my $itemnumber;
    my $old_status;
    my $new_status;

    my $transaction = $self;
    return if not $transaction;

    my $logger = Koha::Logger->get({ interface => 'intranet' });

    if ($status ne "paid" and $status ne "cancelled") {
        warn "Invalid status $status. Call subroutine with 'cancelled' or 'paid' status";
        return;
    }

    # It's important that we don't process this subroutine twice at the same time!
    $transaction = Koha::PaymentsTransactions->find($transaction->transaction_id);

    $old_status = $transaction->status;
    $new_status = $status;

    if ($old_status eq $new_status){
        # Trying to complete with same status, makes no sense
        return;
    }

    if ($old_status ne "processing"){
        $transaction->set({ status => "processing" })->store();
    } else {
        # Another process is already processing the payment
        return;
    }

    # Defined accountlines_id means that the payment is already completed in Koha.
    # We don't want to make duplicate payments. So make sure it is not defined!
    #return if defined $transaction->accountlines_id;
    # Reverse the payment if old status is different than new status (and either paid or cancelled)
    if (defined $transaction->accountlines_id && (($old_status eq "paid" and $new_status eq "cancelled") or ($old_status eq "cancelled" and $new_status eq "paid"))){
        C4::Accounts::ReversePayment($transaction->accountlines_id);
        $transaction->set({ status => $status, description => $transaction->description . "\n\nPayment was reverted after it has already been paid" })->store();
        return;
    }

    # Payment was cancelled
    if ($new_status eq "cancelled") {
        $transaction->set({ status => "cancelled" })->store();
        if ( C4::Context->preference("FinesLog") ) {
            C4::Log::logaction("FINES", 'PAYMENT_CANCELLED', $transaction->borrowernumber, Dumper({
                action                => 'payment_cancelled',
                borrowernumber        => $transaction->borrowernumber,
                manager_id            => $manager_id,
            }));
        }
        return;
    }

    # If transaction is found, pay the accountlines associated with the transaction.
    my $accountlines = $transaction->GetRelatedAccountlines();

    # Define a variable for leftovers. This should not be needed, but it's a fail-safe.
    my $leftovers = 0;

    my $sth = $dbh->prepare('UPDATE accountlines SET amountoutstanding= ? ' .
        'WHERE accountlines_id=?');

    my @ids;
    foreach my $acct (@$accountlines){
        if (_convert_to_cents($acct->{amountoutstanding}) == 0) {
            $leftovers += _convert_to_euros($acct->{paid_price_cents});
            next;
        }

        my $paidamount = _convert_to_euros($acct->{paid_price_cents});
        my $newamount = 0;

        $itemnumber = $acct->{itemnumber} if @$accountlines == 1;

        if ($acct->{amountoutstanding} >= $paidamount) {
            $newamount = $acct->{amountoutstanding}-$paidamount;
        }
        else {
            $leftovers += $paidamount-$acct->{amountoutstanding};
        }

        $sth->execute( $newamount, $acct->{accountlines_id} );
        $logger->debug('Setting accountlines_id '.$acct->{accountlines_id}." to $newamount");
        $description .= ((length($description) > 0) ? "\n" : "") . $acct->{description};

        if ( C4::Context->preference("FinesLog") ) {
            C4::Log::logaction("FINES", 'MODIFY', $transaction->borrowernumber, Dumper({
                action                => 'fee_payment',
                borrowernumber        => $transaction->borrowernumber,
                old_amountoutstanding => $acct->{'amountoutstanding'},
                new_amountoutstanding => $newamount,
                amount_paid           => $paidamount,
                accountlines_id       => $acct->{'accountlines_id'},
                accountno             => $acct->{'accountno'},
                manager_id            => $manager_id,
            }));
            push( @ids, $acct->{'accountlines_id'} );
        }
    }

    if ($leftovers > 0) {
        Koha::Account->new(
                    {
                        patron_id => $transaction->borrowernumber,
                    }
                  )->pay(
                    {
                        amount => $leftovers,
                        lines  => [],
                        note   => "Leftovers from transaction ".$transaction->transaction_id,
                    }
                  );
        $transaction->set({ status => $new_status })->store();
        $logger->debug("Leftovers $leftovers in transaction ".$transaction->transaction_id);
    }

    if ($transaction->price_in_cents-_convert_to_cents($leftovers) > 0) {
        my $nextacctno = C4::Accounts::getnextacctno($transaction->borrowernumber);
        # create new line
        my $sql = 'INSERT INTO accountlines ' .
        '(borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding,itemnumber,manager_id,note) ' .
        q|VALUES (?,?,now(),?,?,'Pay',?,?,?,?)|;
        my $amount = (-1)*_convert_to_euros($transaction->price_in_cents-_convert_to_cents($leftovers));
        $dbh->do($sql,{},$transaction->borrowernumber, $nextacctno,
                 $amount, $description, 0, $itemnumber, $manager_id, $transaction->description);

        $transaction->set({ status => $new_status, accountlines_id => $dbh->last_insert_id( undef, undef, 'accountlines', undef ) })->store();
        $logger->debug("Creating Pay for amount $amount, transaction ".$transaction->transaction_id);

        C4::Stats::UpdateStats({
            branch         => $branch,
            type           => 'payment',
            amount         => _convert_to_euros($transaction->price_in_cents),
            borrowernumber => $transaction->borrowernumber,
            accountno      => $nextacctno,
        });
        Koha::Patron::Debarments::DelDebarmentsAfterPayment({
            borrowernumber => $transaction->borrowernumber
        });

        if ( C4::Context->preference("FinesLog") ) {
            C4::Log::logaction("FINES", 'CREATE',$transaction->borrowernumber,Dumper({
                action            => 'create_payment',
                borrowernumber    => $transaction->borrowernumber,
                accountno         => $nextacctno,
                amount            => 0 - _convert_to_euros($transaction->price_in_cents),
                amountoutstanding => 0 - $leftovers,
                accounttype       => 'Pay',
                accountlines_paid => \@ids,
                manager_id        => $manager_id,
            }));
        }
    }
}

=head2 RevertPayment

  &RevertPayment();

Reverts the already completed payment.

=cut

sub RevertPayment {
    my ($self) = @_;
    my $dbh                 = C4::Context->dbh;

    my $transaction = $self;

    return if not $transaction;

    return if not defined $transaction->accountlines_id;

    C4::Accounts::ReversePayment($transaction->accountlines_id);
}


sub _convert_to_cents {
    my ($price) = @_;

    return sprintf "%.0f", $price*100; # convert into cents
}

sub _convert_to_euros {
    my ($price) = @_;

    return sprintf "%.6f", $price/100; # convert into euros/dollars
}
1;
