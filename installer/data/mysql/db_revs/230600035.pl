use Modern::Perl;

return {
    bug_number  => "16223",
    description => "Add new columns lift_after_payment and fee_limit to table restriction_types",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'restriction_types', 'lift_after_payment' ) ) {
            $dbh->do(
                q{
                ALTER TABLE restriction_types
                    ADD COLUMN `lift_after_payment` tinyint(1) NOT NULL DEFAULT 0
                    AFTER `is_default`
            }
            );

            say $out "Added column 'restriction_types.lift_after_payment'";
        }

        if ( !column_exists( 'restriction_types', 'fee_limit' ) ) {
            $dbh->do(
                q{
                ALTER TABLE restriction_types
                    ADD COLUMN `fee_limit` decimal(28,6) DEFAULT NULL
                    AFTER `lift_after_payment`
            }
            );

            say $out "Added column 'restriction_types.fee_limit'";
        }
    },
};
