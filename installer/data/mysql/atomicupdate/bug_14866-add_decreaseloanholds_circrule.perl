$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value) VALUES (NULL, NULL, NULL, 'decreaseloanholds', NULL) });

    NewVersion( $DBversion, 14866, "Add decreaseloanholds circulation rule" );
}
