$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists('borrowers','autorenew_checkouts') ){
        $dbh->do( "ALTER TABLE borrowers ADD COLUMN autorenew_checkouts TINYINT(1) NOT NULL DEFAULT 1" );
    }
    unless( column_exists('deletedborrowers','autorenew_checkouts') ){
        $dbh->do( "ALTER TABLE deletedborrowers ADD COLUMN autorenew_checkouts TINYINT(1) NOT NULL DEFAULT 1" );
    }
    unless( column_exists('borrower_modifications','autorenew_checkouts') ){
        $dbh->do( "ALTER TABLE borrower_modifications ADD COLUMN autorenew_checkouts TINYINT(1) NOT NULL DEFAULT 1" );
    }
    $dbh->do(q{
        UPDATE systempreferences
        SET value  = CONCAT(value,'|autorenew_checkouts')
        WHERE variable IN
        ('PatronSelfModificationBorrowerUnwantedField','PatronSelfRegistrationBorrowerUnwantedField')
        AND value NOT LIKE '%autorenew_checkouts%'
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24476 - Allow patrons to opt-out of autorenewal)\n";
}
