use Modern::Perl;

return {
    bug_number  => "30708",
    description => "Add a preservation module",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('PreservationModule', '0', NULL, 'Enable the preservation module', 'YesNo')
        }
        );
        say $out "Added new system preference 'PreservationModule'";

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('PreservationNotForLoanWaitingListIn', '', '', 'Not for loan to apply to items added to the preservation waiting list', 'TextArea')
        }
        );
        say $out "Added new system preference 'PreservationNotForLoanWaitingListIn'";

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('PreservationNotForLoanDefaultTrainIn', '', '', 'Not for loan to apply to items removed from the preservation waiting list', 'TextArea')
        }
        );
        say $out "Added new system preference 'PreservationNotForLoanDefaultTrainIn'";

        $dbh->do(
            q{
            INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton)
            VALUES (30, 'preservation', 'Manage preservation module', 0)
        }
        );
        say $out "Added new permission 'preservation'";

        unless ( TableExists('preservation_processings') ) {
            $dbh->do(
                q{
                CREATE TABLE `preservation_processings` (
                  `processing_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                  `name` varchar(80) NOT NULL COMMENT 'name of the processing',
                  PRIMARY KEY (`processing_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say $out "Added new table 'preservation_processings'";
        }

        unless ( TableExists('preservation_trains') ) {
            $dbh->do(
                q{
                CREATE TABLE `preservation_trains` (
                  `train_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                  `name` varchar(80) NOT NULL COMMENT 'name of the train',
                  `description` varchar(255) NULL COMMENT 'description of the train',
                  `default_processing_id` int(11) NULL COMMENT 'default processing, link to preservation_processings.processing_id',
                  `not_for_loan` varchar(80) NOT NULL DEFAULT 0 COMMENT 'NOT_LOAN authorised value to apply toitem added to this train',
                  `created_on` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'creation date',
                  `closed_on` datetime DEFAULT NULL COMMENT 'closing date',
                  `sent_on` datetime DEFAULT NULL COMMENT 'sending date',
                  `received_on` datetime DEFAULT NULL COMMENT 'receiving date',
                  PRIMARY KEY (`train_id`),
                  CONSTRAINT `preservation_trains_ibfk_1` FOREIGN KEY (`default_processing_id`) REFERENCES `preservation_processings` (`processing_id`) ON DELETE SET NULL ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );
            say $out "Added new table 'preservation_trains'";
        }

        unless ( TableExists('preservation_processing_attributes') ) {
            $dbh->do(
                q{
                CREATE TABLE `preservation_processing_attributes` (
                  `processing_attribute_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                  `processing_id` int(11) NOT NULL COMMENT 'link to the processing',
                  `name` varchar(80) NOT NULL COMMENT 'name of the processing attribute',
                  `type` enum('authorised_value', 'free_text', 'db_column') NOT NULL COMMENT 'Type of the processing attribute',
                  `option_source` varchar(80) NULL COMMENT 'source of the possible options for this attribute',
                  PRIMARY KEY (`processing_attribute_id`),
                  CONSTRAINT `preservation_processing_attributes_ibfk_1` FOREIGN KEY (`processing_id`) REFERENCES `preservation_processings` (`processing_id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say $out "Added new table 'preservation_processing_attributes'";
        }

        unless ( TableExists('preservation_trains_items') ) {
            $dbh->do(
                q{
                CREATE TABLE `preservation_trains_items` (
                  `train_item_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                  `train_id` int(11) NOT NULL COMMENT 'link with preservation_train',
                  `item_id` int(11) NOT NULL COMMENT 'link with items',
                  `processing_id` int(11) NULL COMMENT 'specific processing for this item',
                  `user_train_item_id` int(11) NOT NULL COMMENT 'train item id for this train, starts from 1',
                  `added_on` datetime DEFAULT NULL COMMENT 'added date',
                  PRIMARY KEY (`train_item_id`),
                  UNIQUE KEY (`train_id`,`item_id`),
                  CONSTRAINT `preservation_item_ibfk_1` FOREIGN KEY (`train_id`) REFERENCES `preservation_trains` (`train_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                  CONSTRAINT `preservation_item_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                  CONSTRAINT `preservation_item_ibfk_3` FOREIGN KEY (`processing_id`) REFERENCES `preservation_processings` (`processing_id`) ON DELETE SET NULL ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say $out "Added new table 'preservation_trains_items'";
        }

        unless ( TableExists('preservation_processing_attributes_items') ) {
            $dbh->do(
                q{
                CREATE TABLE `preservation_processing_attributes_items` (
                  `processing_attribute_item_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                  `processing_attribute_id` int(11) NOT NULL COMMENT 'link with preservation_processing_attributes',
                  `train_item_id` int(11) NOT NULL COMMENT 'link with preservation_trains_items',
                  `value` varchar(255) NULL COMMENT 'value for this attribute',
                  PRIMARY KEY (`processing_attribute_item_id`),
                  CONSTRAINT `preservation_processing_attributes_items_ibfk_1` FOREIGN KEY (`processing_attribute_id`) REFERENCES `preservation_processing_attributes` (`processing_attribute_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                  CONSTRAINT `preservation_processing_attributes_items_ibfk_2` FOREIGN KEY (`train_item_id`) REFERENCES `preservation_trains_items` (`train_item_id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say $out "Added new table 'preservation_processing_attributes_items'";
        }

    },
};
