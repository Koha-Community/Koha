$DBversion = 'XXX';
if (CheckVersion($DBversion)) {

    if (!TableExists('oauth_access_tokens')) {
        $dbh->do(q{
            CREATE TABLE oauth_access_tokens (
                `access_token` VARCHAR(191) NOT NULL,
                `client_id`    VARCHAR(191) NOT NULL,
                `expires`      INT NOT NULL,
                PRIMARY KEY (`access_token`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 20402 - Implement OAuth2 authentication for REST API)\n";
}
