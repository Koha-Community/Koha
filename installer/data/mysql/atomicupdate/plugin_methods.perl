$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    unless ( TableExists('plugin_methods') ) {
        $dbh->do(q{
            CREATE TABLE plugin_methods (
              plugin_class varchar(255) NOT NULL,
              plugin_method varchar(255) NOT NULL,
              PRIMARY KEY ( `plugin_class` (191), `plugin_method` (191) )
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        });
    }

    require Koha::Plugins;
    Koha::Plugins->new({ enable_plugins => 1 })->InstallPlugins;

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21073 - Improve plugin performance)\n";
}
