$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "ALTER TABLE marc_modification_template_actions CHANGE action action ENUM('delete_field','add_field','update_field','move_field','copy_field','copy_and_replace_field')" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 13560 - need an add option in marc modification templates)\n";
}
