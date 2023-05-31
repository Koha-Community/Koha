use Modern::Perl;

return {
    bug_number => "33103",
    description => "Add vendor aliases",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        unless ( TableExists('aqbookseller_aliases') ) {
            $dbh->do(q{
                CREATE TABLE `aqbookseller_aliases` (
                  `alias_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key and unique identifier assigned by Koha',
                  `vendor_id` int(11) NOT NULL COMMENT 'link to the vendor',
                  `alias` varchar(255) NOT NULL COMMENT "the alias",
                  PRIMARY KEY (`alias_id`),
                  KEY `aqbookseller_aliases_ibfk_1` (`vendor_id`),
                  CONSTRAINT `aqbookseller_aliases_ibfk_1` FOREIGN KEY (`vendor_id`) REFERENCES `aqbooksellers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            });
            say $out "Added new table 'aqbookseller_aliases'";
        }
    },
};
