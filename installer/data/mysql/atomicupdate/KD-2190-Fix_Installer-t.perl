$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do("ALTER TABLE `koha`.`borrowers` DROP INDEX `othernames`, ADD UNIQUE INDEX `othernames_3` (`othernames` ASC); ");

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD 2190 - Add othernames_3 unique constraint, fixes Installer.t)\n";
}
