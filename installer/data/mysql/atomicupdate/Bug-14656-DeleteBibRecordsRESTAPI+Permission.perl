$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    use Koha::Auth::PermissionManager;
    my $pm = Koha::Auth::PermissionManager->new();
    $pm->addPermission({module => 'editcatalogue', code => 'delete_catalogue', description => "Allow deleting bibliographic records"});
    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14656: Add biblio delete (delete_catalogue) permission.)\n";
}
