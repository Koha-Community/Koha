$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value)
        SELECT NULL, NULL, NULL, 'holds_pickup_period', ''
        WHERE NOT EXISTS ( SELECT rule_name FROM circulation_rules where rule_name = 'holds_pickup_period' )
    });

    NewVersion( $DBversion, 8367, "Add holds_pickup_period circulation rule" );
}
