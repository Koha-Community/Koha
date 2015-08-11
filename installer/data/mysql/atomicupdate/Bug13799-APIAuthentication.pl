use C4::Context;
use Koha::AtomicUpdater;

my $dbh = C4::Context->dbh();
my $atomicUpdater = Koha::AtomicUpdater->new();

unless ($atomicUpdater->find('Bug13799')) {

    $dbh->do(q{
        CREATE TABLE api_keys (
            api_key_id INT(11) NOT NULL auto_increment,
            borrowernumber INT(11) NOT NULL, -- foreign key to the borrowers table
            api_key VARCHAR(255) NOT NULL, -- API key used for API authentication
            last_request_time INT(11) default 0, -- UNIX timestamp of when was the last transaction for this API-key? Used for request replay control.
            active INT(1) DEFAULT 1, -- 0 means this API key is revoked
            PRIMARY KEY (api_key_id),
            UNIQUE KEY apk_bornumkey_idx (borrowernumber, api_key),
            CONSTRAINT api_keys_fk_borrowernumber
              FOREIGN KEY (borrowernumber)
              REFERENCES borrowers (borrowernumber)
              ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
    });

    use Koha::Auth::PermissionManager;
    my $pm = Koha::Auth::PermissionManager->new();
    $pm->addPermission({module => 'borrowers', code => 'manage_api_keys', description => "Manage Borrowers' REST API keys"});

    print "Upgrade done (Bug 13799: Add API keys table)\n";
}