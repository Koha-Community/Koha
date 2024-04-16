use Modern::Perl;

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
  `authid` bigint(20) unsigned NOT NULL,
  `authtypecode` varchar(10) NOT NULL DEFAULT '',
  `datecreated` date DEFAULT NULL,
  `modification_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `origincode` varchar(20) DEFAULT NULL,
  `authtrees` longtext DEFAULT NULL,
  `linkid` bigint(20) DEFAULT NULL,
  `marcxml` longtext NOT NULL,
  PRIMARY KEY (`authid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;|
            );
            say $out "Added new table 'deletedauth_header'";
        }
    },
};
