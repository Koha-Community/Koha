$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( q|
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
        VALUES ('FailedLoginAttempts','','','Number of login attempts before lockout the patron account','Integer');
    |);

    unless( column_exists( 'borrowers', 'login_attempts' ) ) {
        $dbh->do(q|
            ALTER TABLE borrowers ADD COLUMN login_attempts INT(4) DEFAULT 0 AFTER lastseen
        |);
        $dbh->do(q|
            ALTER TABLE deletedborrowers ADD COLUMN login_attempts INT(4) DEFAULT 0 AFTER lastseen
        |);
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add FailedLoginAttempts and borrowers.login_attempts)\n";
}
