$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
ALTER TABLE article_requests MODIFY COLUMN created_on timestamp NULL, MODIFY COLUMN updated_on timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
    |);
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22273: Column article_requests.created_on should not be updated)\n";
}
