use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40445",
    description => "Add cashup reconciliation support with surplus/deficit tracking",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add CASHUP_SURPLUS credit type
        $dbh->do(
            q{
            INSERT IGNORE INTO account_credit_types
            (code, description, can_be_added_manually, credit_number_enabled, is_system, archived)
            VALUES ('CASHUP_SURPLUS', 'Cash register surplus found during cashup', 0, 0, 1, 0)
        }
        );

        # Add CASHUP_DEFICIT debit type
        $dbh->do(
            q{
            INSERT IGNORE INTO account_debit_types
            (code, description, can_be_invoiced, can_be_sold, default_amount, is_system, archived, restricts_checkouts)
            VALUES ('CASHUP_DEFICIT', 'Cash register deficit found during cashup', 0, 0, NULL, 1, 0, 0)
        }
        );

        say $out "Added new account credit type 'CASHUP_SURPLUS'";
        say $out "Added new account debit type 'CASHUP_DEFICIT'";
        say_success( $out, "Cashup reconciliation account types created successfully" );
        say_info(
            $out,
            "Staff can now record actual cash amounts during cashup with automatic surplus/deficit tracking"
        );
    },
};
