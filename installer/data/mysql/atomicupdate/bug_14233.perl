$DBversion = 'XXX';    # will be replaced by the RM
if ( CheckVersion($DBversion) ) {

    if ( !column_exists( 'letter', 'id' ) ) {
        $dbh->do(q{ALTER TABLE letter DROP PRIMARY KEY});
        $dbh->do(
q{ALTER TABLE letter ADD COLUMN `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST}
        );
        $dbh->do(
q{ALTER TABLE letter ADD UNIQUE KEY letter_uniq_1 (`module`,`code`,`branchcode`,`message_transport_type`,`lang`)}
        );
    }

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
        VALUES ('NoticesLog','',NULL,'If enabled, log changes to notice templates','YesNo')
    });

    NewVersion( $DBversion, 14233, "Add id field to letter table" );
}
