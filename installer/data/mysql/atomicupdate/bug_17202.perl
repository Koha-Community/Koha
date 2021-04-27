$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless( foreign_key_exists( 'collections_tracking', 'collectionst_ibfk_1' ) ) {
        $dbh->do(q{
            DELETE FROM collections_tracking WHERE colId NOT IN ( SELECT colId FROM collections )
        });
        $dbh->do(q{
            ALTER TABLE collections_tracking
            ADD CONSTRAINT `collectionst_ibfk_1` FOREIGN KEY (`colId`) REFERENCES `collections` (`colId`) ON DELETE CASCADE ON UPDATE CASCADE
        });
    }

    NewVersion( $DBversion, 17202, "Add FK constraint for collection to collections_tracking");
}
