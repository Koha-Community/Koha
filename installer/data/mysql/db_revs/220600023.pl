use Modern::Perl;

return {
    bug_number  => "22456",
    description => "Allow cancelling waiting holds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('hold_cancellation_requests') ) {
            $dbh->do(
                q{
                CREATE TABLE `hold_cancellation_requests` (
                `hold_cancellation_request_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID of the cancellation request',
                `hold_id` int(11) NOT null COMMENT 'ID of the hold',
                `creation_date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Time and date the cancellation request was created',
                PRIMARY KEY (`hold_cancellation_request_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'hold_cancellation_requests'";
        }

        my ($count) = $dbh->selectrow_array(
            q{
                SELECT COUNT(*)
                FROM circulation_rules
                WHERE rule_name = 'waiting_hold_cancellation'
        }
        );

        unless ($count) {
            $dbh->do(
                q{
                INSERT INTO circulation_rules (rule_name, rule_value)
                VALUES ('waiting_hold_cancellation', 0)
            }
            );
        } else {
            say $out "Found already existing 'waiting_hold_cancellation' circulation rules on the DB. Please review.";
        }
    },
};
