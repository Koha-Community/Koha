$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('HoldsNeedProcessingSIP', '0', NULL, 'Require staff to check-in before hold is set to waiting state', 'YesNo' )
    });
    NewVersion( $DBversion, 12556, "Add new syspref HoldsNeedProcessingSIP");
}
