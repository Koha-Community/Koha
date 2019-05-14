$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # you can use $dbh here like:
    unless ( foreign_key_exists( 'tmp_holdsqueue', 'tmp_holdsqueue_ibfk_1' ) ) {
        $dbh->do(q{
            DELETE t FROM tmp_holdsqueue t
            LEFT JOIN items i ON t.itemnumber=i.itemnumber
            WHERE i.itemnumber IS NULL
        });
        $dbh->do(q{
            ALTER TABLE tmp_holdsqueue
            ADD CONSTRAINT `tmp_holdsqueue_ibfk_1` FOREIGN KEY (`itemnumber`)
            REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
        });
    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug XXXXX - Add items constraint to tmp_holdsqueue)\n";
}
