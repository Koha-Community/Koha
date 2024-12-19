use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38689",
    description => "Add edifact_errors table to record edifact error messages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !TableExists('edifact_errors') ) {
            $dbh->do(
                q{
                CREATE TABLE `edifact_errors` (
                  `id` int(11) NOT NULL AUTO_INCREMENT,
                  `message_id` int(11) NOT NULL,
                  `date` date DEFAULT NULL,
                  `section` mediumtext DEFAULT NULL,
                  `details` mediumtext DEFAULT NULL,
                  PRIMARY KEY (`id`),
                  KEY `messageid` (`message_id`),
                  CONSTRAINT `emfk_message` FOREIGN KEY (`message_id`) REFERENCES `edifact_messages` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say_success( $out, "Added new table 'edifect_errors'" );
        } else {
            say_info( $out, "Table already exists" );
        }
    },
};
