$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    use Koha::Auth::PermissionManager;
	my $pm = Koha::Auth::PermissionManager->new();
	$pm->addPermissionModule({module => 'messages', description => 'Permission regarding notifications and messages in message queue.'});
	$pm->addPermission({module => 'messages', code => 'get_message', description => "Allows to get the messages in message queue."});
	$pm->addPermission({module => 'messages', code => 'create_message', description => "Allows to create a new message and queue it."});
	$pm->addPermission({module => 'messages', code => 'update_message', description => "Allows to update messages in message queue."});
	$pm->addPermission({module => 'messages', code => 'delete_message', description => "Allows to delete a message and queue it."});
	$pm->addPermission({module => 'messages', code => 'resend_message', description => "Allows to resend messages in message queue."});

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14843: Add Pemissions for message queue REST operations)\n";
}
