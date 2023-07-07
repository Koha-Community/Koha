use Modern::Perl;

return {
    bug_number => "33105",
    description => "Add vendor issues",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless (TableExists('aqbookseller_issues')) {
            $dbh->do(q{
                CREATE TABLE `aqbookseller_issues` (
                  `issue_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier assigned by Koha',
                  `vendor_id` int(11) NOT NULL COMMENT 'link to the vendor',
                  `type` varchar(80) DEFAULT NULL COMMENT 'type of the issue, authorised value VENDOR_ISSUE_TYPE',
                  `started_on` date DEFAULT NULL COMMENT 'start of the issue',
                  `ended_on` date DEFAULT NULL COMMENT 'end of the issue',
                  `notes` longtext DEFAULT NULL COMMENT 'notes',
                  PRIMARY KEY (`issue_id`),
                  CONSTRAINT `aqbookseller_issues_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
            say $out "Added new table 'aqbookseller_issues'";
        }

        $dbh->do(q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
            (11, 'issue_manage', 'Manage issues');
        });
        say $out "Added new permission 'acquisition.issue_manage'";

        $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES
                ('VENDOR_ISSUE_TYPE', 1)
        });
        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
            VALUES
                ('VENDOR_ISSUE_TYPE', 'MAINTENANCE', 'Maintenance'),
                ('VENDOR_ISSUE_TYPE', 'OUTAGE', 'Outage')
        });
        say $out "Added new authorised value category 'VENDOR_ISSUE_TYPE'";
    },
};
