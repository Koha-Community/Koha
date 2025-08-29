use Modern::Perl;

return {
    bug_number  => "35761",
    description => "Add new table and permission for generalised file transports",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                INSERT IGNORE INTO permissions (module_bit, code, description)
                VALUES (3, 'manage_file_transports', 'Manage file transports configuration');
            }
        );
        say $out "Added new permission 'manage_file_transports'";

        unless ( TableExists('file_transports') ) {
            $dbh->do(
                q {
                    CREATE TABLE `file_transports` (
                    `id` int(11) NOT NULL AUTO_INCREMENT,
                    `name` varchar(80) NOT NULL,
                    `host` varchar(80) NOT NULL DEFAULT 'localhost',
                    `port` int(11) NOT NULL DEFAULT 22,
                    `transport` enum('ftp','sftp') NOT NULL DEFAULT 'sftp',
                    `passive` tinyint(1) NOT NULL DEFAULT 1,
                    `user_name` varchar(80) DEFAULT NULL,
                    `password` mediumtext DEFAULT NULL,
                    `key_file` mediumtext DEFAULT NULL,
                    `auth_mode` enum('password','key_file','noauth') NOT NULL DEFAULT 'password',
                    `download_directory` mediumtext DEFAULT NULL,
                    `upload_directory` mediumtext DEFAULT NULL,
                    `status` longtext DEFAULT NULL,
                    `debug` tinyint(1) NOT NULL DEFAULT 0,
                    PRIMARY KEY (`id`),
                    KEY `host_idx` (`host`)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
                }
            );
            say $out "Added new table 'file_transports";
        }
    },
};
