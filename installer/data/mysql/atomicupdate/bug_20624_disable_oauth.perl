$DBversion = "XXX";
if(CheckVersion($DBversion)) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
        VALUES
            ('RESTOAuth2ClientCredentials','0',NULL,'If enabled, the OAuth2 client credentials flow is enabled for the REST API.','YesNo');
    });

    print "Upgrade to $DBversion done (Bug 20624 - Disable OAuth2 client credentials grant by default)\n";
    SetVersion($DBversion);
}
