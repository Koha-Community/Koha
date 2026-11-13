use Modern::Perl;

return {
    bug_number  => "44012",
    description => "Add record source to import batches",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'import_batches', 'record_source_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE import_batches
                    ADD COLUMN `record_source_id` int(11) DEFAULT NULL COMMENT 'record source to set on bibliographic records committed from this batch'
                    AFTER profile_id,
                    ADD KEY `import_batches_ibfk_2` (`record_source_id`),
                    ADD CONSTRAINT `import_batches_ibfk_2` FOREIGN KEY (`record_source_id`) REFERENCES `record_sources` (`record_source_id`) ON DELETE SET NULL ON UPDATE CASCADE
                    }
            );

            say $out "Added column 'import_batches.record_source_id'";
        }
    },
};
