$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists('borrowers','autorenewal') ){
        $dbh->do( "ALTER TABLE borrowers ADD COLUMN autorenewal TINYINT(1) NOT NULL DEFAULT 1" );
    }
    unless( column_exists('deletedborrowers','autorenewal') ){
        $dbh->do( "ALTER TABLE deletedborrowers ADD COLUMN autorenewal TINYINT(1) NOT NULL DEFAULT 1" );
    }
    unless( column_exists('borrower_modifications','autorenewal') ){
        $dbh->do( "ALTER TABLE borrower_modifications ADD COLUMN autorenewal TINYINT(1) NOT NULL DEFAULT 1" );
    }
    $dbh->do(q{
        UPDATE systempreferences
        SET value  = CONCAT(value,'|autorenewal')
        WHERE variable IN
        ('PatronSelfModificationBorrowerUnwantedField','PatronSelfRegistrationBorrowerUnwantedField')
        AND value NOT LIKE '%autorenewal%'
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24476 - Allow patrons to opt-out of autorenewal)\n";
}
