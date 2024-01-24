use Modern::Perl;

return {
    bug_number  => "35919",
    description => "Add record_sources table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('record_sources') ) {
            $dbh->do(
                q{
                CREATE TABLE `record_sources` (
                    `record_source_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Primary key for the `record_sources` table',
                    `name` text NOT NULL COMMENT 'User defined name for the record source',
                    `can_be_edited` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'If records from this source can be edited',
                    PRIMARY KEY (`record_source_id`)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );

            say $out "Added new table 'record_sources'";
        }

        unless ( column_exists( 'biblio_metadata', 'record_source_id' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE biblio_metadata
                        ADD COLUMN `record_source_id` int(11) NULL DEFAULT NULL
                        COMMENT 'The record source for the metadata'
                        AFTER timestamp
            }
            );

            say $out "Added new column 'biblio_metadata.record_source_id'";
        }

        unless ( foreign_key_exists( 'biblio_metadata', 'record_metadata_fk_2' ) ) {
            $dbh->do(
                q{
                ALTER TABLE biblio_metadata
                ADD CONSTRAINT `record_metadata_fk_2` FOREIGN KEY (`record_source_id`) REFERENCES `record_sources` (`record_source_id`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );

            say $out "Added new foreign key 'biblio_metadata.record_metadata_fk_2'";
        }

        unless ( column_exists( 'deletedbiblio_metadata', 'record_source_id' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE deletedbiblio_metadata
                        ADD COLUMN `record_source_id` int(11) NULL DEFAULT NULL
                        COMMENT 'The record source for the metadata'
                        AFTER timestamp
            }
            );

            say $out "Added new column 'deletedbiblio_metadata.record_source_id'";
        }

        unless ( foreign_key_exists( 'deletedbiblio_metadata', 'deletedrecord_metadata_fk_2' ) ) {
            $dbh->do(
                q{
                ALTER TABLE deletedbiblio_metadata
                ADD CONSTRAINT `deletedrecord_metadata_fk_2` FOREIGN KEY (`record_source_id`) REFERENCES `record_sources` (`record_source_id`) ON DELETE CASCADE ON UPDATE CASCADE
            }
            );

            say $out "Added new foreign key 'deletedbiblio_metadata.record_metadata_fk_2'";
        }

        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
            ( 3, 'manage_record_sources', 'Manage record sources')
        }
        );

        say $out "Added new permission 'manage_record_sources'";

    },
};
