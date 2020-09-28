$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        DELETE FROM circulation_rules WHERE
        rule_name IN ('holdallowed','hold_fulfillment_policy','returnbranch') AND
        rule_value = ''
    });
    NewVersion( $DBversion, 26529, "Description");
}
