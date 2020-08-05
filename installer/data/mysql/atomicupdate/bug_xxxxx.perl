$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !column_exists( 'biblioimages', 'itemnumber' ) ) {
        $dbh->do(q|
            ALTER TABLE biblioimages
            ADD COLUMN itemnumber INT(11) DEFAULT NULL
            AFTER biblionumber;
        |);
        $dbh->do(q|
            ALTER TABLE biblioimages
            ADD FOREIGN KEY bibliocoverimage_fk2 (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
        |);
        $dbh->do(q|
            ALTER TABLE biblioimages MODIFY biblionumber INT(11) DEFAULT NULL
        |)
    }

    NewVersion( $DBversion, 'XXXXX', "Add the biblioimages.itemnumber column");

    if( !TableExists('cover_images') ) {
        $dbh->do(q|
            ALTER TABLE biblioimages RENAME cover_images
        |);
    }

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, "XXXXX", "Rename table biblioimages with cover_images");
}
