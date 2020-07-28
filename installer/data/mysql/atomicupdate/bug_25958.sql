$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('DefaultLongOverdueSkipLostStatuses', '', NULL, 'Skip these lost statuses by default in longoverdue.pl', 'Free'),
    });

    NewVersion( $DBversion, 25958, "Allow LongOverdue cron to exclude specified lost values");
}
