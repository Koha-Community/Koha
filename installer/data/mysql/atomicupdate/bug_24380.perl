$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('CalculateFinesOnBackdate','1','','Switch to control if overdue fines are calculated on return when backdating','YesNo');
    });

    NewVersion( $DBversion, 24380, "Add syspref CalculateFinesOnBackdate");
}
