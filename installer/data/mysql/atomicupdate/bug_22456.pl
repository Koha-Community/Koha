use Modern::Perl;

return {
    bug_number  => "22456",
    description => "Allow cancelling waiting holds",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        unless ( TableExists( 'hold_cancellation_requests' ) ) {
            $dbh->do(q{
                CREATE TABLE `hold_cancellation_requests` (
                `hold_cancellation_request_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Unique ID of the cancellation request',
                `hold_id` int(11) NOT null COMMENT 'ID of the hold',
                `creation_date` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'Time and date the cancellation request was created',
                PRIMARY KEY (`hold_cancellation_request_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }
    },
};
