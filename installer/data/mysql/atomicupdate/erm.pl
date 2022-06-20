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

        unless ( TableExists('erm_agreement_user_roles') ) {
            $dbh->do(q{
                CREATE TABLE `erm_agreement_user_roles` (
                    `agreement_id` INT(11) NOT NULL COMMENT 'link to the agreement',
                    `user_id` INT(11) NOT NULL COMMENT 'link to the user',
                    `role` VARCHAR(80) NOT NULL COMMENT 'role of the user',
                    CONSTRAINT `erm_agreement_users_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `erm_agreement_users_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }
        $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES
                ('ERM_AGREEMENT_USER_ROLES', 1)
        });
        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
            VALUES
                ('ERM_AGREEMENT_USER_ROLES', 'librarian', 'ERM librarian'),
                ('ERM_AGREEMENT_USER_ROLES', 'subject_specialist', 'Subject specialist')
        });

        unless ( TableExists('erm_licenses') ) {
            $dbh->do(q{
                CREATE TABLE `erm_licenses` (
                    `license_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `name` VARCHAR(255) NOT NULL COMMENT 'name of the license',
                    `description` LONGTEXT DEFAULT NULL COMMENT 'description of the license',
                    `type` VARCHAR(80) NOT NULL COMMENT 'type of the license',
                    `status` VARCHAR(80) NOT NULL COMMENT 'current status of the license',
                    `started_on` DATE COMMENT 'start of the license',
                    `ended_on` DATE COMMENT 'end of the license',
                    PRIMARY KEY(`license_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }
        unless ( TableExists('erm_agreement_licenses') ) {
            $dbh->do(q{
                CREATE TABLE `erm_agreement_licenses` (
                    `agreement_license_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `agreement_id` INT(11) NOT NULL COMMENT 'link to the agreement',
                    `license_id` INT(11) NOT NULL COMMENT 'link to the license',
                    `status` VARCHAR(80) NOT NULL COMMENT 'current status of the license',
                    `physical_location` VARCHAR(80) DEFAULT NULL COMMENT 'physical location of the license',
                    `notes` mediumtext DEFAULT NULL COMMENT 'notes about this license',
                    `uri` varchar(255) DEFAULT NULL COMMENT 'URI of the license',
                    CONSTRAINT `erm_licenses_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `erm_licenses_ibfk_2` FOREIGN KEY (`license_id`) REFERENCES `erm_licenses` (`license_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    PRIMARY KEY(`agreement_license_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }
        $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES
                ('ERM_LICENSE_TYPE', 1),
                ('ERM_LICENSE_STATUS', 1),
                ('ERM_AGREEMENT_LICENSE_STATUS', 1),
                ('ERM_AGREEMENT_LICENSE_LOCATION', 1);
        });

        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
            VALUES
                ('ERM_LICENSE_TYPE', 'local', 'Local'),
                ('ERM_LICENSE_TYPE', 'consortial', 'Consortial'),
                ('ERM_LICENSE_TYPE', 'national', 'National'),
                ('ERM_LICENSE_TYPE', 'alliance', 'Alliance'),
                ('ERM_LICENSE_STATUS', 'in_negotiation', 'In negotiation'),
                ('ERM_LICENSE_STATUS', 'not_yet_active', 'Not yet active'),
                ('ERM_LICENSE_STATUS', 'active', 'Active'),
                ('ERM_LICENSE_STATUS', 'rejected', 'Rejected'),
                ('ERM_LICENSE_STATUS', 'expired', 'Expired'),
                ('ERM_AGREEMENT_LICENSE_STATUS', 'controlling', 'Controlling'),
                ('ERM_AGREEMENT_LICENSE_STATUS', 'future', 'Future'),
                ('ERM_AGREEMENT_LICENSE_STATUS', 'history', 'Historic'),
                ('ERM_AGREEMENT_LICENSE_LOCATION', 'filing_cabinet', 'Filing cabinet'),
                ('ERM_AGREEMENT_LICENSE_LOCATION', 'cupboard', 'Cupboard');
        });

        unless ( TableExists('erm_agreement_relationships') ) {
            $dbh->do(q{
                CREATE TABLE `erm_agreement_relationships` (
                    `agreement_id` INT(11) NOT NULL COMMENT 'link to the agreement',
                    `related_agreement_id` INT(11) NOT NULL COMMENT 'link to the related agreement',
                    `relationship` ENUM('supersedes', 'is-superseded-by', 'provides_post-cancellation_access_for', 'has-post-cancellation-access-in', 'tracks_demand-driven_acquisitions_for', 'has-demand-driven-acquisitions-in', 'has_backfile_in', 'has_frontfile_in', 'related_to') NOT NULL COMMENT 'relationship between the two agreements',
                    `notes` mediumtext DEFAULT NULL COMMENT 'notes about this relationship',
                    CONSTRAINT `erm_agreement_relationships_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `erm_agreement_relationships_ibfk_2` FOREIGN KEY (`related_agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    PRIMARY KEY(`agreement_id`, `related_agreement_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        unless ( TableExists('erm_agreement_documents') ) {
            $dbh->do(q{
                CREATE TABLE `erm_agreement_documents` (
                    `document_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `agreement_id` INT(11) NOT NULL COMMENT 'link to the agreement',
                    `file_name` varchar(255) DEFAULT NULL COMMENT 'name of the file',
                    `file_type` varchar(255) DEFAULT NULL COMMENT 'type of the file',
                    `file_description` varchar(255) DEFAULT NULL COMMENT 'description of the file',
                    `file_content` longblob DEFAULT NULL COMMENT 'the content of the file',
                    `uploaded_on` datetime DEFAULT NULL COMMENT 'datetime when the file as attached',
                    `physical_location` VARCHAR(255) DEFAULT NULL COMMENT 'physical location of the document',
                    `uri` varchar(255) DEFAULT NULL COMMENT 'URI of the document',
                    `notes` mediumtext DEFAULT NULL COMMENT 'notes about this relationship',
                    CONSTRAINT `erm_agreement_documents_ibfk_1` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    PRIMARY KEY(`document_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        unless ( TableExists('erm_eholdings_packages') ) {
            $dbh->do(q{
                CREATE TABLE `erm_eholdings_packages` (
                    `package_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `vendor_id` INT(11) DEFAULT NULL COMMENT 'foreign key to aqbooksellers',
                    `name` VARCHAR(255) NOT NULL COMMENT 'name of the package',
                    `external_id` VARCHAR(255) DEFAULT NULL COMMENT 'External key',
                    `package_type` VARCHAR(80) DEFAULT NULL COMMENT 'type of the package',
                    `content_type` VARCHAR(80) DEFAULT NULL COMMENT 'type of the package',
                    `created_on` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'date of creation of the package',
                    CONSTRAINT `erm_packages_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    PRIMARY KEY(`package_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        unless ( TableExists('erm_eholdings_packages_agreements') ) {
            $dbh->do(q{
                CREATE TABLE `erm_eholdings_packages_agreements` (
                    `package_id` INT(11) NOT NULL COMMENT 'link to the package',
                    `agreement_id` INT(11) NOT NULL COMMENT 'link to the agreement',
                    CONSTRAINT `erm_eholdings_packages_agreements_ibfk_1` FOREIGN KEY (`package_id`) REFERENCES `erm_eholdings_packages` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `erm_eholdings_packages_agreements_ibfk_2` FOREIGN KEY (`agreement_id`) REFERENCES `erm_agreements` (`agreement_id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        unless ( TableExists('erm_eholdings_titles') ) {
            $dbh->do(q{
                CREATE TABLE `erm_eholdings_titles` (
                    `title_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `biblio_id` INT(11) DEFAULT NULL,
                    `vendor_id` INT(11) DEFAULT NULL,
                    `publication_title` VARCHAR(255) DEFAULT NULL,
                    `external_id` VARCHAR(255) DEFAULT NULL,
                    `print_identifier` VARCHAR(255) DEFAULT NULL,
                    `online_identifier` VARCHAR(255) DEFAULT NULL,
                    `date_first_issue_online` VARCHAR(255) DEFAULT NULL,
                    `num_first_vol_online` VARCHAR(255) DEFAULT NULL,
                    `num_first_issue_online` VARCHAR(255) DEFAULT NULL,
                    `date_last_issue_online` VARCHAR(255) DEFAULT NULL,
                    `num_last_vol_online` VARCHAR(255) DEFAULT NULL,
                    `num_last_issue_online` VARCHAR(255) DEFAULT NULL,
                    `title_url` VARCHAR(255) DEFAULT NULL,
                    `first_author` VARCHAR(255) DEFAULT NULL,
                    `embargo_info` VARCHAR(255) DEFAULT NULL,
                    `coverage_depth` VARCHAR(255) DEFAULT NULL,
                    `notes` VARCHAR(255) DEFAULT NULL,
                    `publisher_name` VARCHAR(255) DEFAULT NULL,
                    `publication_type` VARCHAR(255) DEFAULT NULL,
                    `date_monograph_published_print` VARCHAR(255) DEFAULT NULL,
                    `date_monograph_published_online` VARCHAR(255) DEFAULT NULL,
                    `monograph_volume` VARCHAR(255) DEFAULT NULL,
                    `monograph_edition` VARCHAR(255) DEFAULT NULL,
                    `first_editor` VARCHAR(255) DEFAULT NULL,
                    `parent_publication_title_id` VARCHAR(255) DEFAULT NULL,
                    `preceeding_publication_title_id` VARCHAR(255) DEFAULT NULL,
                    `access_type` VARCHAR(255) DEFAULT NULL,
                    CONSTRAINT `erm_eholdings_titles_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
                    CONSTRAINT `erm_eholdings_titles_ibfk_2` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE SET NULL ON UPDATE CASCADE,
                    PRIMARY KEY(`title_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }
        unless ( TableExists('erm_eholdings_resources') ) {
            $dbh->do(q{
                CREATE TABLE `erm_eholdings_resources` (
                    `resource_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                    `title_id` INT(11) NOT NULL,
                    `package_id` INT(11) NOT NULL,
                    `started_on` DATE,
                    `ended_on` DATE,
                    `proxy` VARCHAR(80) DEFAULT NULL,
                    CONSTRAINT `erm_eholdings_resources_ibfk_1` FOREIGN KEY (`title_id`) REFERENCES `erm_eholdings_titles` (`title_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `erm_eholdings_resources_ibfk_2` FOREIGN KEY (`package_id`) REFERENCES `erm_eholdings_packages` (`package_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    PRIMARY KEY(`resource_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        unless ( column_exists('aqbooksellers', 'external_id') ) {
            $dbh->do(q{
                ALTER TABLE `aqbooksellers`
                ADD COLUMN `external_id` VARCHAR(255) DEFAULT NULL
                AFTER `deliverytime`
            });
        }

        $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES
                ('ERM_PACKAGE_TYPE', 1),
                ('ERM_PACKAGE_CONTENT_TYPE', 1)
        });

        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
            VALUES
                ('ERM_PACKAGE_TYPE', 'local', 'Local'),
                ('ERM_PACKAGE_TYPE', 'complete', 'Complete'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'mixed_content', 'Aggregated full'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'mixed_content', 'Abstract and index'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'e_book', 'E-book'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'mixed_content', 'Mixed content'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'e_journal', 'E-journal'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'online_reference', 'Online reference'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'print', 'Print'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'streaming_media', 'Streaming media'),
                ('ERM_PACKAGE_CONTENT_TYPE', 'unknown', 'Unknown')
        });
    }
};
