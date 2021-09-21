$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT INTO circulation_rules (branchcode, categorycode, itemtype, rule_name, rule_value)
        SELECT u.* FROM (SELECT NULL as branchcode, NULL as categorycode, NULL as itemtype, 'holds_pickup_period' as rule_name, '' as rule_value) u
        WHERE NOT EXISTS ( SELECT rule_name FROM circulation_rules where rule_name = 'holds_pickup_period' );
    });

    NewVersion( $DBversion, 8367, "Add holds_pickup_period circulation rule" );
}
