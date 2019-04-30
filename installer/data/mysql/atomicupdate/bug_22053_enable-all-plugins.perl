$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    use Koha::Plugins;

    my @plugins = Koha::Plugins->new({ enable_plugins => 1 })->GetPlugins({ all => 1 });
    foreach my $plugin ( @plugins ) {
        $plugin->enable;
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22053 - enable all plugins)\n";
}
