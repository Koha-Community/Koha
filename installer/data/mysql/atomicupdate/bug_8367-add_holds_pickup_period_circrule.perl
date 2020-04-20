$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{INSERT IGNORE INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value) VALUES (NULL, NULL, NULL, 'holds_pickup_period', NULL) });

    NewVersion( $DBversion, 8367, "Add holds_pickup_period circulation rule" );
}
