$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("DROP INDEX title ON import_biblios");
    $dbh->do("DROP INDEX isbn ON import_biblios");
    $dbh->do("ALTER TABLE import_biblios MODIFY title LONGTEXT");
    $dbh->do("ALTER TABLE import_biblios MODIFY author LONGTEXT");
    $dbh->do("ALTER TABLE import_biblios MODIFY isbn LONGTEXT");
    $dbh->do("ALTER TABLE import_biblios MODIFY issn LONGTEXT");
    $dbh->do("CREATE INDEX title ON import_biblios (title(191));");
    $dbh->do("CREATE INDEX isbn ON import_biblios (isbn(191));");

    # Always end with this (adjust the bug info)
    NewVersion( $DBversion, 26853, "Update import_biblios columns and indexes");
}
