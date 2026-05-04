use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42418",
    description => "Add checkins table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('checkins') ) {
            $dbh->do(
                q{
                CREATE TABLE `checkins` (
                    `checkin_id`  int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `item_id`     int(11) NOT NULL COMMENT 'foreign key from the items table defining which item was checked in',
                    `user_id`     int(11) DEFAULT NULL COMMENT 'foreign key from the borrowers table defining which staff member processed the checkin',
                    `library_id`  varchar(10) NOT NULL COMMENT 'foreign key from the branches table defining where the checkin took place',
                    `desk_id`     int(11) DEFAULT NULL COMMENT 'foreign key from the desks table defining which desk the checkin took place at',
                    `timestamp`   timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date and time the checkin was processed',
                    `exempt_fine` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether fines were exempted on this checkin',
                    `local_use`   tinyint(1) NOT NULL DEFAULT 0 COMMENT 'whether this checkin was recorded as a local use',
                    `checkout_id` int(11) DEFAULT NULL COMMENT 'foreign key from the old_issues table if this checkin returned a checkout',
                    `transfer_id` int(11) DEFAULT NULL COMMENT 'foreign key from the branchtransfers table if this checkin triggered a transfer',
                    `hold_id`     int(11) DEFAULT NULL COMMENT 'foreign key from the reserves table if this checkin filled a hold',
                    `recall_id`   int(11) DEFAULT NULL COMMENT 'foreign key from the recalls table if this checkin filled a recall',
                    `restriction_id` int(11) DEFAULT NULL COMMENT 'foreign key from the borrower_debarments table if this checkin triggered a restriction',
                    `claim_id`    int(11) DEFAULT NULL COMMENT 'foreign key from the return_claims table if this checkin resolved a claim',
                    `interface`   varchar(16) DEFAULT NULL COMMENT 'the interface this checkin was processed from (intranet, api, sip, cron, commandline)',
                    PRIMARY KEY (`checkin_id`),
                    KEY `item_id` (`item_id`),
                    KEY `user_id` (`user_id`),
                    KEY `library_id` (`library_id`),
                    KEY `desk_id` (`desk_id`),
                    KEY `checkout_id` (`checkout_id`),
                    KEY `transfer_id` (`transfer_id`),
                    KEY `hold_id` (`hold_id`),
                    KEY `recall_id` (`recall_id`),
                    KEY `restriction_id` (`restriction_id`),
                    KEY `claim_id` (`claim_id`),
                    CONSTRAINT `checkins_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_3` FOREIGN KEY (`library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_4` FOREIGN KEY (`desk_id`) REFERENCES `desks` (`desk_id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_5` FOREIGN KEY (`checkout_id`) REFERENCES `old_issues` (`issue_id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_6` FOREIGN KEY (`transfer_id`) REFERENCES `branchtransfers` (`branchtransfer_id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_7` FOREIGN KEY (`hold_id`) REFERENCES `reserves` (`reserve_id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_8` FOREIGN KEY (`recall_id`) REFERENCES `recalls` (`recall_id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_9` FOREIGN KEY (`restriction_id`) REFERENCES `borrower_debarments` (`borrower_debarment_id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `checkins_ibfk_10` FOREIGN KEY (`claim_id`) REFERENCES `return_claims` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );

            say $out "Added new table 'checkins'";
        }

        # Backfill: create checkin rows from old_issues
        my ($backfilled) = $dbh->selectrow_array(q{ SELECT COUNT(*) FROM checkins WHERE checkout_id IS NOT NULL });
        unless ($backfilled) {
            $dbh->do(
                q{
                INSERT INTO checkins (item_id, user_id, library_id, timestamp, checkout_id)
                SELECT oi.itemnumber,
                       oi.issuer_id,
                       COALESCE(oi.checkin_library, oi.branchcode),
                       oi.returndate,
                       oi.issue_id
                FROM old_issues oi
                WHERE oi.returndate IS NOT NULL
                  AND oi.itemnumber IS NOT NULL
                  AND (oi.checkin_library IS NOT NULL OR oi.branchcode IS NOT NULL)
            }
            );

            my $count = $dbh->rows;
            say $out "Backfilled $count checkin records from old_issues"
                if $count > 0;
        }
    },
};
