$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
        VALUES ('Reference_NFL_Statuses','1|2',NULL,'Contains not for loan statuses considered as available for reference','Free')
    });
    NewVersion( $DBversion, 21260, "Add preference Reference_NFL_Statuses");
}
