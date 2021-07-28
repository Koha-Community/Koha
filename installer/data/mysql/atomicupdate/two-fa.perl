$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('TwoFactorAuthentication', '0', 'NULL', 'Enables two-factor authentication', 'YesNo')
    });

    NewVersion( $DBversion, 28786, "Add new syspref TwoFactorAuthentication");
}
