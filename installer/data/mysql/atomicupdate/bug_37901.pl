use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37901",
    description => "Update pseudonymized_borrower_attributes to pseudonymized_metadata_values",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( TableExists('pseudonymized_borrower_attributes') ) {
            say_info( $out, "Renaming table 'pseudonymized_borrower_attributes' to 'pseudonymized_metadata_values" );
            $dbh->do(
                q{
                    CREATE TABLE `pseudonymized_metadata_values` (
                    `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Row id field',
                    `transaction_id` int(11) NOT NULL,
                    `tablename` varchar(64) NOT NULL COMMENT 'Name of the related table',
                    `key` varchar(64) NOT NULL COMMENT 'key for the metadata',
                    `value` varchar(255) DEFAULT NULL COMMENT 'value for the metadata',
                    PRIMARY KEY (`id`),
                    KEY `pseudonymized_metadata_values_ibfk_1` (`transaction_id`),
                    CONSTRAINT `pseudonymized_metadata_values_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `pseudonymized_transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                }
            );

            $dbh->do(
                q{
                    INSERT INTO pseudonymized_metadata_values( transaction_id, tablename, `key`, value )
                    SELECT transaction_id, 'borrower_attributes', code, attribute
                    FROM pseudonymized_borrower_attributes;
                }
            );

            $dbh->do(q{ DROP TABLE pseudonymized_borrower_attributes; });
        }

        say_success( $out, "Finished" );
    },
};
