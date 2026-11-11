use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "33501",
    description => "Add CashupPaymentTypes system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES (
                'CashupPaymentTypes',
                'CASH,SIP00',
                '',
                'Comma-separated, ordered list of PAYMENT_TYPE authorised value codes that participate in the cashup reconciliation workflow. Each listed type gets its own expected/actual entry in the Complete cashup modal. Order is significant.',
                'Free'
            )
        }
        );

        say_success( $out, "Added CashupPaymentTypes system preference" );
        say_info(
            $out,
            "CashupPaymentTypes: Defaults to 'CASH,SIP00' to preserve existing behaviour. Edit via Administration > System preferences > Accounting to add Cheque, Card, etc."
        );

        # Backfill payment_type on any historical CASHUP_SURPLUS / CASHUP_DEFICIT
        # lines that pre-date the per-payment-type reconciliation work — those
        # lines are conceptually cash because every cashup before this bug
        # treated all takings as cash. Setting it explicitly lets the cashup
        # summary group these lines under 'CASH' without a runtime fallback.
        my $rows = $dbh->do(
            q{
            UPDATE accountlines
               SET payment_type = 'CASH'
             WHERE payment_type IS NULL
               AND (credit_type_code = 'CASHUP_SURPLUS' OR debit_type_code = 'CASHUP_DEFICIT')
        }
        );

        if ( $rows && $rows > 0 ) {
            say_success(
                $out,
                "Backfilled payment_type='CASH' on $rows existing CASHUP_SURPLUS/CASHUP_DEFICIT accountline(s)"
            );
        } else {
            say_warning( $out, "No historical CASHUP_SURPLUS/CASHUP_DEFICIT accountlines needed backfilling" );
        }
    },
};
