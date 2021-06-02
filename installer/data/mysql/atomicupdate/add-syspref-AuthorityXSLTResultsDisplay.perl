$DBversion = 'XXX';
if (CheckVersion($DBversion)) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`) VALUES
        ('AuthorityXSLTResultsDisplay','','','Enable XSL stylesheet control over authority results page display on intranet','Free')
    });

    NewVersion($DBversion, '11083', 'Add syspref AuthorityXSLTResultsDisplay');
}
