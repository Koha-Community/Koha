$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('ArticleRequestsSupportedFormats', 'PHOTOCOPY', 'PHOTOCOPY|SCAN', 'List supported formats between vertical bars', 'free')
    });
    NewVersion( $DBversion, 20472, "Add syspref ArticleRequestsSupportedFormats");
}
