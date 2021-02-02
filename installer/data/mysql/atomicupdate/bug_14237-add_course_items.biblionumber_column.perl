$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ){
    unless( column_exists( 'course_items', 'biblionumber') ) {
        $dbh->do(q{ ALTER TABLE course_items ADD `biblionumber` int(11) NOT NULL AFTER `itemnumber` });
        $dbh->do(q{ ALTER TABLE course_items ADD CONSTRAINT `fk_course_items_biblionumber` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE });
        $dbh->do(q{ ALTER TABLE course_items CHANGE `itemnumber` `itemnumber` int(11) DEFAULT NULL });
    }

    NewVersion( $DBversion, 14237, ["Add course_items.biblionumber column", "Add fk_course_items_biblionumber constraint", "Change course_items.itemnumber to allow NULL values"] );
}
