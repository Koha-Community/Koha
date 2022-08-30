use Modern::Perl;
use C4::Context;

return {
    bug_number  => "31378",
    description => "Add auth_provider and auth_provider_domains configuration tables",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        # Add new permission
        $dbh->do(qq{
            INSERT IGNORE permissions (module_bit, code, description)
            VALUES
            ( 3, 'manage_authentication_providers', 'Manage authentication providers')
        });

        say $out "manage_authentication_providers permission added";

        unless (TableExists('auth_providers')) {
            $dbh->do(q{
                CREATE TABLE `auth_providers` (
                `auth_provider_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key, used to identify the provider',
                `code` varchar(20) NOT NULL COMMENT 'Provider code',
                `description` varchar(255) NOT NULL COMMENT 'Description for the provider',
                `protocol` enum('OAuth', 'OIDC', 'LDAP', 'CAS') COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Protocol provider speaks',
                `config` longtext NOT NULL DEFAULT '{}' COMMENT 'Configuration of the provider in JSON format',
                `mapping` longtext NOT NULL DEFAULT '{}' COMMENT 'Configuration to map provider data to Koha user',
                `matchpoint` enum('email','userid','cardnumber') NOT NULL COMMENT 'The patron attribute to be used as matchpoint',
                `icon_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Provider icon URL',
                PRIMARY KEY (`auth_provider_id`),
                UNIQUE KEY (`code`),
                KEY `protocol` (`protocol`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        unless (TableExists('auth_provider_domains')) {
            $dbh->do(q{
                CREATE TABLE `auth_provider_domains` (
                    `auth_provider_domain_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique key, used to identify providers domain',
                    `auth_provider_id` int(11) NOT NULL COMMENT 'Reference to provider',
                    `domain` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Domain name. If null means all domains',
                    `auto_register` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Allow user auto register',
                    `update_on_auth` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Update user data on auth login',
                    `default_library_id` varchar(10) DEFAULT NULL COMMENT 'Default library to create user if auto register is enabled',
                    `default_category_id` varchar(10) DEFAULT NULL COMMENT 'Default category to create user if auto register is enabled',
                    `allow_opac` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Allow provider from opac interface',
                    `allow_staff` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Allow provider from staff interface',
                    PRIMARY KEY (`auth_provider_domain_id`),
                    UNIQUE KEY (`auth_provider_id`, `domain`),
                    KEY `domain` (`domain`),
                    KEY `allow_opac` (`allow_opac`),
                    KEY `allow_staff` (`allow_staff`),
                    CONSTRAINT `auth_provider_domain_ibfk_1` FOREIGN KEY (`auth_provider_id`) REFERENCES `auth_providers` (`auth_provider_id`) ON DELETE CASCADE,
                    CONSTRAINT `auth_provider_domain_ibfk_2` FOREIGN KEY (`default_library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE,
                    CONSTRAINT `auth_provider_domain_ibfk_3` FOREIGN KEY (`default_category_id`) REFERENCES `categories` (`categorycode`) ON DELETE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
        }

        if (C4::Context->preference('GoogleOpenIDConnect')) {
            # Print useful stuff here
            say $out "Setting google provider";
            $dbh->do(q{
                INSERT INTO `auth_providers` (name, protocol, config, mapping), auto_register, registration_config, interface)
                SELECT  'google' as name,
                        'OIDC' as protocol,
                        JSON_OBJECT("key", k.value, "secret", s.value, "well_known_url", "https://accounts.google.com/.well-known/openid-configuration", "scope", "openid email profile") as config,
                        JSON_OBJECT("email", "email", "firstname", "given_name", "surname", "family_name", "_key", "email") as mapping
                FROM
                    (SELECT value FROM `systempreferences` where variable = 'GoogleOAuth2ClientID') k
                JOIN
                    (SELECT value FROM `systempreferences` where variable = 'GoogleOAuth2ClientSecret') s
            });

            $dbh->do(q{
                INSERT INTO `auth_provider_domains` (auth_provider_id, domain, auto_register, update_on_auth, default_library_id, default_category_id, allow_opac, allow_staff)
                        p.id as provider_id,
                        d.value as domain,
                        r.value as auto_register,
                        0 as update_on_auth,
                        b.value as default_branch,
                        c.value as default_category,
                        1 as allow_opac,
                        0 as allow_interface
                FROM
                    (SELECT id FROM `auth_provider` WHERE name = 'google') p
                JOIN
                    (SELECT CASE WHEN value = '' OR value IS NULL THEN NULL ELSE value END as value FROM `systempreferences` where variable = 'GoogleOpenIDConnectDomain') d
                JOIN
                    (SELECT CASE WHEN value = '' OR value IS NULL THEN '0' ELSE value END as value FROM `systempreferences` where variable = 'GoogleOpenIDConnectAutoRegister') r
                JOIN
                    (SELECT CASE WHEN value = '' OR value IS NULL THEN NULL ELSE value END as value FROM `systempreferences` where variable = 'GoogleOpenIDConnectDefaultCategory') c
                JOIN
                    (SELECT CASE WHEN value = '' OR value IS NULL THEN NULL ELSE value END as value FROM `systempreferences` where variable = 'GoogleOpenIDConnectDefaultBranch') b
            });
        }
    },
};
