$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    print q{WARNING: Bug 18811 fixed an inconsistency in the visibility settings for authority frameworks. It is recommended that you run script misc/maintenance/auth_show_hidden_data.pl to check if you have data in hidden fields and adjust your frameworks accordingly to prevent data loss when editing such records.};
    print "\n";

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18811 - Visibility settings inconsistent between framework and authority editor)\n";
}
