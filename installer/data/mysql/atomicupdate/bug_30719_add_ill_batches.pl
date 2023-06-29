use Modern::Perl;

return {
    bug_number  => "30719",
    description => "Add ILL batches",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            CREATE TABLE IF NOT EXISTS `illbatch_statuses` (
                `id` int(11) NOT NULL auto_increment COMMENT "Status ID",
                `name` varchar(100) NOT NULL COMMENT "Name of status",
                `code` varchar(20) NOT NULL COMMENT "Unique, immutable code for status",
                `is_system` tinyint(1) COMMENT "Is this status required for system operation",
                PRIMARY KEY (`id`),
                UNIQUE KEY `u_illbatchstatuses__code` (`code`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        }
        );
        $dbh->do(
            q{
            CREATE TABLE IF NOT EXISTS `illbatches` (
                `id` int(11) NOT NULL auto_increment COMMENT "Batch ID",
                `name` varchar(100) NOT NULL COMMENT "Unique name of batch",
                `backend` varchar(20) NOT NULL COMMENT "Name of batch backend",
                `borrowernumber` int(11) COMMENT "Patron associated with batch",
                `branchcode` varchar(50) COMMENT "Branch associated with batch",
                `statuscode` varchar(20) COMMENT "Status of batch",
                PRIMARY KEY (`id`),
                UNIQUE KEY `u_illbatches__name` (`name`),
                CONSTRAINT `illbatches_bnfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
                CONSTRAINT `illbatches_bcfk` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE,
                CONSTRAINT `illbatches_sfk` FOREIGN KEY (`statuscode`) REFERENCES `illbatch_statuses` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        }
        );
        unless ( column_exists( 'illrequests', 'batch_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illrequests`
                    ADD COLUMN `batch_id` int(11) AFTER backend -- Optional ID of batch that this request belongs to
            }
            );
        }

        unless ( foreign_key_exists( 'illrequests', 'illrequests_ibfk' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illrequests`
                    ADD CONSTRAINT `illrequests_ibfk` FOREIGN KEY (`batch_id`) REFERENCES `illbatches` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
            }
            );
        }

        unless ( foreign_key_exists( 'illbatches', 'illbatches_bnfk' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illbatches`
                    ADD CONSTRAINT `illbatches_bnfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
            }
            );
        }

        unless ( foreign_key_exists( 'illbatches', 'illbatches_bcfk' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illbatches`
                    ADD CONSTRAINT `illbatches_bcfk` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`) ON DELETE SET NULL ON UPDATE CASCADE
            }
            );
        }

        unless ( foreign_key_exists( 'illbatches', 'illbatches_sfk' ) ) {
            $dbh->do(
                q{
                ALTER TABLE `illbatches`
                    ADD CONSTRAINT `illbatches_sfk` FOREIGN KEY (`statuscode`) REFERENCES `illbatch_statuses` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
            }
            );
        }

        # Get any existing NEW batch status
        my ($new_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='NEW';
        |
        );

        if ($new_status) {
            say $out "Bug 30719: NEW ILL batch status found. Update has already been run.";
        } else {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses ( name, code, is_system ) VALUES ('New', 'NEW', '1')
            }
            );
            say $out "Bug 30719: Added NEW ILL batch status";
        }

        # Get any existing IN_PROGRESS batch status
        my ($in_progress_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='IN_PROGRESS';
        |
        );

        if ($in_progress_status) {
            say $out "Bug 30719: IN_PROGRESS ILL batch status found. Update has already been run.";
        } else {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses( name, code, is_system ) VALUES( 'In progress', 'IN_PROGRESS', '1' )
            }
            );
            say $out "Bug 30719: Added IN_PROGRESS ILL batch status";
        }

        # Get any existing COMPLETED batch status
        my ($completed_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='COMPLETED';
        |
        );

        if ($completed_status) {
            say $out "Bug 30719: COMPLETED ILL batch status found. Update has already been run.";
        } else {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses( name, code, is_system ) VALUES( 'Completed', 'COMPLETED', '1' )
            }
            );
            say $out "Bug 30719: Added COMPLETED ILL batch status";
        }

        # Get any existing UNKNOWN batch status
        my ($unknown_status) = $dbh->selectrow_array(
            q|
            SELECT name FROM illbatch_statuses WHERE code='UNKNOWN';
        |
        );

        if ($unknown_status) {
            say $out "Bug 30719: UNKNOWN ILL batch status found. Update has already been run.";
        } else {
            $dbh->do(
                qq{
            INSERT INTO illbatch_statuses( name, code, is_system ) VALUES( 'Unknown', 'UNKNOWN', '1' )
            }
            );
            say $out "Bug 30719: Added UNKNOWN ILL batch status";
        }

        say $out "Bug 30719: Add ILL batches completed";
    },
};
