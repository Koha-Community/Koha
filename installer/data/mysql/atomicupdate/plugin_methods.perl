$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q{
        CREATE TABLE IF NOT EXISTS plugin_methods (
          plugin_class varchar(255) NOT NULL,
          plugin_method varchar(255) NOT NULL,
          PRIMARY KEY ( `plugin_class` (191), `plugin_method` (191) )
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    });

    require Koha::Plugins;
    Koha::Plugins->new()->InstallPlugins;

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - description)\n";
}
