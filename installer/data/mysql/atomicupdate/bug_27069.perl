$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        UPDATE circulation_rules
        SET
            rule_value = CASE
                WHEN rule_value='0' THEN 'not_allowed'
                WHEN rule_value='1' THEN 'from_home_library'
                WHEN rule_value='2' THEN 'from_any_library'
                WHEN rule_value='3' THEN 'from_local_hold_group'
            END
        WHERE rule_name='holdallowed' AND rule_value >= 0 AND rule_value <= 3;
    });

    NewVersion( $DBversion, 27069, "Change holdallowed values from numbers to strings");
}
