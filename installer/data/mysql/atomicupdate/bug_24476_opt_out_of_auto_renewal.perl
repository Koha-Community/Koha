$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless( column_exists('borrowers','autorenew_checkouts') ){
        $dbh->do( "ALTER TABLE borrowers ADD COLUMN autorenew_checkouts TINYINT(1) NOT NULL DEFAULT 1 AFTER anonymized" );
    }
    unless( column_exists('deletedborrowers','autorenew_checkouts') ){
        $dbh->do( "ALTER TABLE deletedborrowers ADD COLUMN autorenew_checkouts TINYINT(1) NOT NULL DEFAULT 1 AFTER anonymized" );
    }
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences
        ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES
        ('AllowPatronToControlAutorenewal','0',NULL,'If enabled, patrons will have a field in their account to choose whether their checkouts are auto renewed or not','YesNo')
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24476 - Allow patrons to opt-out of autorenewal)\n";
}
