use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "38207",
    description => "Add a payment method to the vendor table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'aqbooksellers', 'payment_method' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE aqbooksellers
                        ADD COLUMN `payment_method` varchar(255) NULL DEFAULT NULL
                        COMMENT 'the payment method for the vendor'
                        AFTER external_id
            }
            );

            say $out "Added new column 'aqbooksellers.payment_method'";
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_value_categories( category_name, is_system ) VALUES ('VENDOR_PAYMENT_METHOD', 1);
        }
        );
        say $out "Added VENDOR_PAYMENT_METHOD authorised value category";

        $dbh->do(
            q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
            VALUES
                ('VENDOR_PAYMENT_METHOD', 'card', 'Card'),
                ('VENDOR_PAYMENT_METHOD', 'bacs', 'BACS');
        }
        );
        say $out "Added Card and BACS to VENDOR_PAYMENT_METHODS authorised value category";
    },
};
