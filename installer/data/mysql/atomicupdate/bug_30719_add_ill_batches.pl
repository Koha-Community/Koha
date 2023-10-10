use Modern::Perl;

return {
    bug_number  => "30719",
    description => "Add ability to create batch ILL requests",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('illbatch_statuses') ) {
            $dbh->do(
                q{
                CREATE TABLE `illbatch_statuses` (
                    `id` int(11) NOT NULL auto_increment COMMENT "Status ID",
                    `name` varchar(100) NOT NULL COMMENT "Name of status",
                    `code` varchar(20) NOT NULL COMMENT "Unique, immutable code for status",
                    `is_system` tinyint(1) COMMENT "Is this status required for system operation",
                    PRIMARY KEY(`id`),
                    UNIQUE KEY `u_illbatchstatuses__code` (`code`)
                ) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'illbatch_statuses'";
        }

        unless ( TableExists('illbatches') ) {
            $dbh->do(
                q{
                CREATE TABLE `illbatches` (
                    `ill_batch_id` int(11) NOT NULL auto_increment COMMENT "Batch ID",
                    `name` varchar(100) NOT NULL COMMENT "Unique name of batch",
                    `backend` varchar(20) NOT NULL COMMENT "Name of batch backend",
                    `patron_id` int(11) NULL DEFAULT NULL COMMENT "Patron associated with batch",
                    `library_id` varchar(50) NULL DEFAULT NULL COMMENT "Branch associated with batch",
                    `status_code` varchar(20) NULL DEFAULT NULL COMMENT "Status of batch",
                    PRIMARY KEY (`ill_batch_id`),
                    UNIQUE KEY `u_illbatches__name` (`name`),
                    CONSTRAINT `illbatches_bnfk` FOREIGN KEY (`patron_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `illbatches_bcfk` FOREIGN KEY (`library_id`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `illbatches_sfk` FOREIGN KEY (`status_code`) REFERENCES `illbatch_statuses` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'illbatches'";
        }
        unless ( column_exists( 'illrequests', 'batch_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illrequests`
                    ADD COLUMN `batch_id` int(11) COMMENT 'Optional ID of batch that this request belongs to' AFTER backend
            }
            );

            say $out "Added column 'illrequests.batch_id'";
        }

        unless ( foreign_key_exists( 'illrequests', 'illrequests_ibfk' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illrequests`
                    ADD CONSTRAINT `illrequests_ibfk` FOREIGN KEY (`batch_id`) REFERENCES `illbatches` (`ill_batch_id`) ON DELETE SET NULL ON UPDATE CASCADE
            }
            );
        }

        # Get any existing NEW batch status
        my ($new_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='NEW';
        |
        );

        unless ($new_status) {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses ( name, code, is_system ) VALUES ('New', 'NEW', '1')
            }
            );
            say $out "Added new ILL batch status 'NEW'";
        }

        # Get any existing IN_PROGRESS batch status
        my ($in_progress_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='IN_PROGRESS';
        |
        );

        unless ($in_progress_status) {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses( name, code, is_system ) VALUES( 'In progress', 'IN_PROGRESS', '1' )
            }
            );
            say $out "Added new ILL batch status 'IN_PROGRESS'";
        }

        # Get any existing COMPLETED batch status
        my ($completed_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='COMPLETED';
        |
        );

        unless ($completed_status) {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses( name, code, is_system ) VALUES( 'Completed', 'COMPLETED', '1' )
            }
            );
            say $out "Added new ILL batch status 'COMPLETED'";
        }

        # Get any existing UNKNOWN batch status
        my ($unknown_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='UNKNOWN';
        |
        );

        unless ($unknown_status) {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses( name, code, is_system ) VALUES( 'Unknown', 'UNKNOWN', '1' )
            }
            );
            say $out "Added new ILL batch status 'UNKNOWN'";
        }
    },
};
