$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("
    CREATE TABLE IF NOT EXISTS batch_overlay_rules (
        id int(11) NOT NULL AUTO_INCREMENT,
        name varchar(10) NOT NULL,
        matcher_id int(11) NULL,
        component_matcher_id int(11) NULL,
        source varchar(20) NULL,
        usagerule varchar(20) NULL,
        PRIMARY KEY (id),
        UNIQUE KEY name (name) ,
        CONSTRAINT `batch_overlay_matcher_id_fk_1` FOREIGN KEY (`matcher_id`) REFERENCES `marc_matchers` (`matcher_id`)
          ON DELETE CASCADE ON UPDATE CASCADE
    ) ENGINE=InnoDB  DEFAULT CHARSET=utf8;");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1939 - Circulation rules matrix modifications)\n";
}
