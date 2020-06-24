$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("
        DELETE FROM circulation_rules WHERE rule_name='holdallowed' AND rule_value='';
    ");
    NewVersion( $DBversion, 25851, "Remove holdallowed rule if value is an empty string");
}
