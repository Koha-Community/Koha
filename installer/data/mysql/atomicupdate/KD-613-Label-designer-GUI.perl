$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

	use Koha::Auth::PermissionManager;
	my $pm = Koha::Auth::PermissionManager->new();
	$pm->addPermissionModule({module => 'labels', description => 'Permissions related to getting all kinds of labels to bibliographic items'});
	$pm->addPermission({module => 'labels', code => 'sheets_get', description => 'Allow viewing all label sheets'});
	$pm->addPermission({module => 'labels', code => 'sheets_new', description => 'Allow creating all label sheets'});
	$pm->addPermission({module => 'labels', code => 'sheets_mod', description => 'Allow modifying all label sheets'});
	$pm->addPermission({module => 'labels', code => 'sheets_del', description => 'Allow deleting all label sheets'});

	$dbh->do(
	"CREATE TABLE `label_sheets` (".
	"  `id`   int(11) NOT NULL,".
	"  `name` varchar(100) NOT NULL,".
	"  `author` int(11) DEFAULT NULL,".
	"  `version` float(4,1) NOT NULL,".
	"  `timestamp` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,".
	"  `sheet` MEDIUMTEXT NOT NULL,".
	"  KEY  (`id`),".
	"  UNIQUE KEY `id_version` (`id`, `version`),".
	"  KEY `name` (`name`),".
	"  CONSTRAINT `labshet_authornumber` FOREIGN KEY (`author`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE".
	") ENGINE=InnoDB DEFAULT CHARSET=utf8;"
	);

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade done (KD-613: Labels GUI editor and printer)\n";
}
