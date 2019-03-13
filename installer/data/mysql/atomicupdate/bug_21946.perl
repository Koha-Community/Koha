$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless ( column_exists('itemtypes', 'parent_type') ) {
        $dbh->do(q{
            ALTER TABLE itemtypes
                ADD COLUMN parent_type VARCHAR(10) NULL DEFAULT NULL
                AFTER itemtype;

        });
    }
    unless ( foreign_key_exists( 'itemtypes', 'itemtypes_ibfk_1') ){
        $dbh->do(q{
            ALTER TABLE itemtypes
            ADD CONSTRAINT itemtypes_ibfk_1
            FOREIGN KEY (parent_type) REFERENCES itemtypes (itemtype)
        });
    }
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 21946 - Add parent type to itemtypes)\n";
}
