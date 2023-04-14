use Modern::Perl;

return {
    bug_number => "33104",
    description => "Add vendor interfaces",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless ( TableExists('aqbookseller_interfaces') ) {
            $dbh->do(q{
                CREATE TABLE `aqbookseller_interfaces` (
                  `interface_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier assigned by Koha',
                  `vendor_id` int(11) NOT NULL COMMENT 'link to the vendor',
                  `type` varchar(80) DEFAULT NULL COMMENT "type of the interface, authorised value VENDOR_INTERFACE_TYPE",
                  `name` varchar(255) NOT NULL COMMENT 'name of the interface',
                  `uri` mediumtext DEFAULT NULL COMMENT 'uri of the interface',
                  `login` varchar(255) DEFAULT NULL COMMENT 'login',
                  `password` mediumtext DEFAULT NULL COMMENT 'hashed password',
                  `account_email` mediumtext DEFAULT NULL COMMENT 'account email',
                  `notes` longtext DEFAULT NULL COMMENT 'notes',
                  PRIMARY KEY (`interface_id`),
                  CONSTRAINT `aqbookseller_interfaces_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
            say $out "Added new table 'aqbookseller_interfaces'";
        }

        $dbh->do(q{
            INSERT IGNORE INTO authorised_value_categories (category_name, is_system)
            VALUES
                ('VENDOR_INTERFACE_TYPE', 1)
        });
        $dbh->do(q{
            INSERT IGNORE INTO authorised_values (category, authorised_value, lib)
            VALUES
                ('VENDOR_INTERFACE_TYPE', 'ADMIN', 'Admin'),
                ('VENDOR_INTERFACE_TYPE', 'ORDERS', 'Orders'),
                ('VENDOR_INTERFACE_TYPE', 'REPORTS', 'Reports')
        });
        say $out "Added new authorised value category 'VENDOR_INTERFACE_TYPE'";
    },
};
