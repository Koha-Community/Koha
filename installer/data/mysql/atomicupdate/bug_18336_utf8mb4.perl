$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|SET foreign_key_checks = 0|);
    my $sth = $dbh->table_info( '','','','TABLE' );

    while ( my ( $cat, $schema, $name, $type, $remarks ) = $sth->fetchrow_array ) {
        my $table_sth = $dbh->prepare(qq|SHOW CREATE TABLE $name|);
        $table_sth->execute;
        my @table = $table_sth->fetchrow_array;
        unless ( $table[1] =~ /COLLATE=utf8mb4_unicode_ci/ ) {
            # Some users might have done the upgrade to utf8mb4 on their own
            # to support supplemental chars (japanese, chinese, etc)
            if ( $name eq 'additional_fields' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `fields_uniq`,
                        ADD UNIQUE KEY `fields_uniq` (`tablename` (191), `name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'authorised_values' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `lib`,
                        ADD KEY `lib` (`lib` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'borrower_modifications' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        DROP KEY `verification_token`,
                        ADD PRIMARY KEY (`verification_token` (191),`borrowernumber`),
                        ADD KEY `verification_token` (`verification_token` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'columns_settings' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`module` (191), `page` (191), `tablename` (191), `columnname` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'illrequestattributes' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY  (`illrequest_id`, `type` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'items_search_fields' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'marc_subfield_structure' ) {
                # In this case we convert each column explicitly
                # to preserve 'tagsubield' collation (utf8mb4_bin)
                $dbh->do(qq|
                    ALTER TABLE $name
                        MODIFY COLUMN tagfield
                            VARCHAR(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN tagsubfield
                            VARCHAR(1) COLLATE utf8mb4_bin NOT NULL DEFAULT '',
                        MODIFY COLUMN liblibrarian
                            VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN libopac
                            VARCHAR(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN kohafield
                            VARCHAR(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN authorised_value
                            VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN authtypecode
                            VARCHAR(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN value_builder
                            VARCHAR(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN frameworkcode
                            VARCHAR(4) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
                        MODIFY COLUMN seealso
                            VARCHAR(1100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
                        MODIFY COLUMN link
                            VARCHAR(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL
                |);
                $dbh->do(qq|ALTER TABLE $name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'plugin_data' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`plugin_class` (191), `plugin_key` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'search_field' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `name`,
                        ADD UNIQUE KEY `name` (`name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'search_marc_map' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `index_name`,
                        ADD UNIQUE KEY `index_name` (`index_name`, `marc_field` (191), `marc_type`)
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'sms_providers' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP KEY `name`,
                        ADD UNIQUE KEY `name` (`name` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'tags' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        DROP PRIMARY KEY,
                        ADD PRIMARY KEY (`entry` (191))
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'tags_approval' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        MODIFY COLUMN `term` VARCHAR(191) NOT NULL
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            elsif ( $name eq 'tags_index' ) {
                $dbh->do(qq|
                    ALTER TABLE $name
                        MODIFY COLUMN `term` VARCHAR(191) NOT NULL
                |);
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
            else {
                $dbh->do(qq|ALTER TABLE $name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci|);
            }
        }
    }
    $dbh->do(q|SET foreign_key_checks = 1|);;

    print "Upgrade to $DBversion done (Bug 18336: Convert DB tables to utf8mb4)\n";
    SetVersion($DBversion);
}
