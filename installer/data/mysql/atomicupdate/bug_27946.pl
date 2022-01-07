use Modern::Perl;

return {
    bug_number  => "27946",
    description => "Add article request fees",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'article_requests', 'debit_id' ) ) {

            $dbh->do(
                q{
                ALTER TABLE `article_requests`
                    ADD COLUMN `debit_id` int(11) NULL DEFAULT NULL COMMENT 'Debit line with cost for article scan request' AFTER `cancellation_reason`
            }
            );

            $dbh->do(
                q{
                ALTER TABLE `article_requests`
                    ADD CONSTRAINT `article_requests_ibfk_5` FOREIGN KEY (`debit_id`) REFERENCES `accountlines` (`accountlines_id`) ON DELETE SET NULL ON UPDATE CASCADE
            }
            );
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO account_debit_types ( code, description, can_be_invoiced, can_be_sold, default_amount, is_system )
            VALUES ('ARTICLE_REQUEST', 'Article request fee', 0, 0, NULL, 1);
        }
        );
    },
};
