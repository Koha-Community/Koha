use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35104",
    description => "Add biblio_metadata_errors table for normalised error tracking",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( TableExists('biblio_metadata_errors') ) {
            $dbh->do(
                q{
                    CREATE TABLE `biblio_metadata_errors` (
                        `id` int(11) NOT NULL AUTO_INCREMENT,
                        `metadata_id` int(11) NOT NULL COMMENT 'FK to biblio_metadata.id',
                        `error_type` varchar(64) NOT NULL COMMENT 'Error type identifier, e.g. nonxml_stripped',
                        `tag` varchar(3) DEFAULT NULL COMMENT 'MARC tag affected, if applicable',
                        `subfield` varchar(1) DEFAULT NULL COMMENT 'MARC subfield code affected, if applicable',
                        `message` mediumtext DEFAULT NULL COMMENT 'Error message details',
                        `created_on` timestamp NOT NULL DEFAULT current_timestamp(),
                        PRIMARY KEY (`id`),
                        KEY `biblio_metadata_errors_fk_1` (`metadata_id`),
                        CONSTRAINT `biblio_metadata_errors_fk_1` FOREIGN KEY (`metadata_id`) REFERENCES `biblio_metadata` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                }
            );
            say_success( $out, "Added new table 'biblio_metadata_errors'" );
        }
    },
};
