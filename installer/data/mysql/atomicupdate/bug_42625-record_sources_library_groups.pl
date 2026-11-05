use Modern::Perl;

return {
    bug_number  => "42625",
    description => "Allow record source locking to be overridden by library group",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'library_groups', 'ft_record_source_editing' ) ) {
            $dbh->do(
                q{
                ALTER TABLE library_groups
                    ADD COLUMN `ft_record_source_editing` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Use this group to identify libraries allowed to edit records from locked record sources'
                    AFTER ft_reports
                    }
            );

            say $out "Added column 'library_groups.ft_record_source_editing'";
        }

        unless ( TableExists('record_sources_library_groups') ) {
            $dbh->do(
                q{
                CREATE TABLE `record_sources_library_groups` (
                    `record_source_id` int(11) NOT NULL COMMENT 'link to the record source',
                    `library_group_id` int(11) NOT NULL COMMENT 'link to the library group exempt from the record source lock',
                    PRIMARY KEY (`record_source_id`,`library_group_id`),
                    KEY `record_sources_library_groups_ibfk_2` (`library_group_id`),
                    CONSTRAINT `record_sources_library_groups_ibfk_1` FOREIGN KEY (`record_source_id`) REFERENCES `record_sources` (`record_source_id`) ON DELETE CASCADE ON UPDATE CASCADE,
                    CONSTRAINT `record_sources_library_groups_ibfk_2` FOREIGN KEY (`library_group_id`) REFERENCES `library_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                }
            );

            say $out "Added new table 'record_sources_library_groups'";
        }
    },
};
