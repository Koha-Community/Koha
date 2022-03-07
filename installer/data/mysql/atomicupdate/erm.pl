use Modern::Perl;

return {
    bug_number => "BUG_NUMBER",
    description => "Some tables for ERM",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do(q{
            INSERT IGNORE INTO systempreferences (variable,value,explanation,options,type)
            VALUES ('ERMModule', '0', NULL, 'Enable the E-Resource management module', 'YesNo');
        });

        $dbh->do(q{
            INSERT IGNORE INTO userflags (bit, flag, flagdesc, defaulton)
            VALUES (28, 'erm', 'Manage electronic resources', 0)
        });

        unless ( TableExists('erm_agreements') ) {
            $dbh->do(q{
                CREATE TABLE `erm_agreements` (
                    `agreement_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `vendor_id` INT(11) DEFAULT NULL COMMENT 'foreign key to aqbooksellers',
                    `name` VARCHAR(255) NOT NULL COMMENT 'name of the agreement',
                    `description` LONGTEXT DEFAULT NULL COMMENT 'description of the agreement',
                    `status` VARCHAR(80) NOT NULL COMMENT 'current status of the agreement',
                    `closure_reason` VARCHAR(80) DEFAULT NULL COMMENT 'reason of the closure',
                    `is_perpetual` TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'is the agreement perpetual',
                    `renewal_priority` VARCHAR(80) DEFAULT NULL COMMENT 'priority of the renewal',
                    `license_info` VARCHAR(80) DEFAULT NULL COMMENT 'info about the license',
                    CONSTRAINT `erm_agreements_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    PRIMARY KEY(`agreement_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES
                ('ERM_AGREEMENT_STATUS', 1),
                ('ERM_AGREEMENT_CLOSURE_REASON', 1),
                ('ERM_AGREEMENT_RENEWAL_PRIORITY', 1)
            });
        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
            VALUES
                ('ERM_AGREEMENT_STATUS', 'active', 'Active'),
                ('ERM_AGREEMENT_STATUS', 'in_negotiation', 'In negotiation'),
                ('ERM_AGREEMENT_STATUS', 'closed', 'Closed'),
                ('ERM_AGREEMENT_CLOSURE_REASON', 'expired', 'Expired'),
                ('ERM_AGREEMENT_CLOSURE_REASON', 'cancelled', 'Cancelled'),
                ('ERM_AGREEMENT_RENEWAL_PRIORITY', 'for_review', 'For review'),
                ('ERM_AGREEMENT_RENEWAL_PRIORITY', 'renew', 'Renew'),
                ('ERM_AGREEMENT_RENEWAL_PRIORITY', 'cancel', 'Cancel')
        });

        unless ( TableExists('erm_agreement_periods') ) {
            $dbh->do(q{
                CREATE TABLE `erm_agreement_periods` (
                    `agreement_period_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `agreement_id` INT(11) NOT NULL COMMENT 'link to the agreement',
                    `started_on` DATE NOT NULL COMMENT 'start of the agreement period',
                    `ended_on` DATE COMMENT 'end of the agreement period',
                    `cancellation_deadline` DATE DEFAULT NULL COMMENT 'Deadline for the cancellation',
                    `notes` mediumtext DEFAULT NULL COMMENT 'notes about this period',
                    CONSTRAINT `erm_agreement_periods_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    PRIMARY KEY(`agreement_period_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }
    },
};
