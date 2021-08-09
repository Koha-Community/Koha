$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('HoldsQueueParallelLoopsCount', '1', NULL, 'Number of parallel loops to use when running the holds queue builder', 'Integer');
    });

    NewVersion( $DBversion, 28833, "Speed up holds queue builder via parallel processing");
}
