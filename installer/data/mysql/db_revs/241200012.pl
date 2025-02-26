use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => 30888,
    description => "Add table deletedauth_header",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !TableExists('deletedauth_header') ) {
            $dbh->do(
                q|
CREATE TABLE `deletedauth_header` (
  `authid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `datecreated` date DEFAULT NULL,
  `modification_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `heading` longtext DEFAULT NULL,
  `origincode` varchar(20) DEFAULT NULL,
  `authtrees` longtext DEFAULT NULL,
  `linkid` bigint(20) DEFAULT NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY (`authid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;|
            );
            say_success( $out, "Added new table 'deletedauth_header'" );
        }
    },
};
