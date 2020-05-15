$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
  # you can use $dbh here like:
  # $dbh->do( "ALTER TABLE biblio ADD COLUMN badtaste int" );

  # or perform some test and warn
  if( !TableExists( 'import_batches_profile' ) ) {
    $dbh->do(q{
      CREATE TABLE `import_batches_profile` ( -- profile for batches of marc records to be imported
        `id` int(11) NOT NULL auto_increment, -- unique identifier and primary key
        `name` varchar(100) NOT NULL, -- name of this profile
        `matcher_id` int(11) default NULL, -- the id of the match rule used (matchpoints.matcher_id)
        `template_id` int(11) default NULL, -- the id of the marc modification template
        `overlay_action` varchar(50) default NULL, -- how to handle duplicate records
        `nomatch_action` varchar(50) default NULL, -- how to handle records where no match is found
        `item_action` varchar(50) default NULL, -- what to do with item records
        `parse_items` tinyint(1) default NULL, -- should items be parsed
        `record_type` varchar(50) default NULL, -- type of record in the batch
        `encoding` varchar(50) default NULL, -- file encoding
        `format` varchar(50) default NULL, -- marc format
        `comments` LONGTEXT, -- any comments added when the file was uploaded
        PRIMARY KEY (`id`),
        UNIQUE KEY `u_import_batches_profile__name` (`name`)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    });
  }

  if(!column_exists('import_batches', 'profile_id')) {
    $dbh->do(q{
      ALTER TABLE import_batches ADD COLUMN `profile_id` int(11) default NULL AFTER comments
    });

    $dbh->do(q{
      ALTER TABLE import_batches ADD CONSTRAINT `import_batches_ibfk_1` FOREIGN KEY (`profile_id`) REFERENCES `import_batches_profile` (`id`) ON DELETE SET NULL ON UPDATE SET NULL
    });
  }

  # Always end with this (adjust the bug info)
  NewVersion( $DBversion, 23019, "Add import_batches_profile table and profile_id column in import_batches");
}
