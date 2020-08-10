$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
        VALUES ('LockExpiredDelay','','','Delay for locking expired patrons (empty means no locking)','Integer')
    |);

    NewVersion( $DBversion, 21549, "Add pref LockExpiredDelay");
}
