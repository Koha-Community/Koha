use Modern::Perl;
use C4::Context;

return {
    bug_number  => "31378",
    description => "Add identity_provider and identity_provider_domains configuration tables",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Add new permission
        $dbh->do(
            qq{
            INSERT IGNORE permissions (module_bit, code, description)
            VALUES
            ( 3, 'manage_identity_providers', 'Manage authentication providers')
        }
        );

        say $out "Added new permission 'manage_identity_providers'";

        unless ( TableExists('identity_providers') ) {
            $dbh->do(
                q{
                CREATE TABLE `identity_providers` (
                `identity_provider_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key, used to identify the provider',
                `code` varchar(20) NOT NULL COMMENT 'Provider code',
                `description` varchar(255) NOT NULL COMMENT 'Description for the provider',
                `protocol` enum('OAuth', 'OIDC', 'LDAP', 'CAS') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Protocol provider speaks',
                `config` longtext NOT NULL COMMENT 'Configuration of the provider in JSON format',
                `mapping` longtext NOT NULL COMMENT 'Configuration to map provider data to Koha user',
                `matchpoint` enum('email','userid','cardnumber') NOT NULL COMMENT 'The patron attribute to be used as matchpoint',
                `icon_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Provider icon URL',
                PRIMARY KEY (`identity_provider_id`),
                UNIQUE KEY (`code`),
                KEY `protocol` (`protocol`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'identity_providers'";
        }

        unless ( TableExists('identity_provider_domains') ) {
            $dbh->do(
                q{
                CREATE TABLE `identity_provider_domains` (
                    `identity_provider_domain_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key, used to identify providers domain',
                    `identity_provider_id` int(11) NOT NULL COMMENT 'Reference to provider',
                    `domain` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Domain name. If null means all domains',
                    `auto_register` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Allow user auto register',
                    `update_on_auth` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Update user data on auth login',
                    `default_library_id` varchar(10) DEFAULT NULL COMMENT 'Default library to create user if auto register is enabled',
                    `default_category_id` varchar(10) DEFAULT NULL COMMENT 'Default category to create user if auto register is enabled',
                    `allow_opac` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Allow provider from opac interface',
                    `allow_staff` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Allow provider from staff interface',
                    PRIMARY KEY (`identity_provider_domain_id`),
                    UNIQUE KEY (`identity_provider_id`, `domain`),
                    KEY `domain` (`domain`),
                    KEY `allow_opac` (`allow_opac`),
                    KEY `allow_staff` (`allow_staff`),
                    CONSTRAINT `identity_provider_domain_ibfk_1` FOREIGN KEY (`identity_provider_id`) REFERENCES `identity_providers` (`identity_provider_id`) ON DELETE CASCADE,
                    CONSTRAINT `identity_provider_domain_ibfk_2` FOREIGN KEY (`default_library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE,
                    CONSTRAINT `identity_provider_domain_ibfk_3` FOREIGN KEY (`default_category_id`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'identity_provider_domains'";
        }
    },
};
