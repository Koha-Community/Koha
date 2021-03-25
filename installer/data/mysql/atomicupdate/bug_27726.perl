$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE problem_reports MODIFY content TEXT NOT NULL");

    NewVersion( $DBversion, 27726, "Increase field size for problem_reports.content");
}
