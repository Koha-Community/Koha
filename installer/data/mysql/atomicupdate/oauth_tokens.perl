$DBversion = 'XXX';
if (CheckVersion($DBversion)) {
    $dbh->do(q{DROP TABLE IF EXISTS oauth_access_tokens});
    $dbh->do(q{
        CREATE TABLE oauth_access_tokens (
            access_token VARCHAR(255) NOT NULL,
            client_id VARCHAR(255) NOT NULL,
            expires INT NOT NULL,
            PRIMARY KEY (access_token)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
