$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('ArticleRequestsHostRedirection', '0', NULL, 'Enables redirection from child to host', 'YesNo')
    });
    NewVersion( $DBversion, 20310, "Add pref ArticleRequestsHostRedirection");
}
