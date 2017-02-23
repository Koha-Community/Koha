$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    print "IMPORTANT NOTE: If you are not using a regular Debian install, please verify that you no longer use misc/migration_tools/merge_authority.pl in your cron files AND add misc/cronjobs/merge_authorities.pl to cron now. This job is no longer optional! You need it to perform larger authority merges.\n";
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 9988 - Cron alert)\n";
}
