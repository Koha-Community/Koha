$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    print "NOTE: The sender for serial claim notifications has been corrected. The email address of the staff member is no longer used. We will use the branch email address or KohaAdminEmailAddress, as is done for other notices.\n";
    print "Upgrade to $DBversion done (Bug 17866 - Change sender for serial claim notifications)\n";
}
