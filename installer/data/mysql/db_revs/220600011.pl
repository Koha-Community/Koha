use Modern::Perl;

return {
    bug_number  => "30275",
    description => "Add a checkout_renewals table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( TableExists('checkout_renewals') ) {
            $dbh->do(
                q{
                CREATE TABLE `checkout_renewals` (
                  `renewal_id` int(11) NOT NULL auto_increment,
                  `checkout_id` int(11) DEFAULT NULL COMMENT 'the id of the checkout this renewal pertains to',
                  `renewer_id` int(11) DEFAULT NULL COMMENT 'the id of the user who processed the renewal',
                  `seen` tinyint(1) DEFAULT 0 COMMENT 'boolean denoting whether the item was present or not',
                  `interface` varchar(16) NOT NULL COMMENT 'the interface this renewal took place on',
                  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'the date and time the renewal took place',
                  PRIMARY KEY(`renewal_id`),
                  KEY `renewer_id` (`renewer_id`),
                  CONSTRAINT `renewals_renewer_id` FOREIGN KEY (`renewer_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
            }
            );
            say $out "Added new table 'checkout_renewals'";

            $dbh->do(
                q{ ALTER TABLE `issues` CHANGE `renewals` `renewals_count` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'lists the number of times the item was renewed' }
            );
            say $out "Renamed `issues.renewals` to `issues.renewals_count`";

            $dbh->do(
                q{ ALTER TABLE `old_issues` CHANGE `renewals` `renewals_count` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'lists the number of times the item was renewed' }
            );
            say $out "Renamed `old_issues.renewals` to `old_issues.renewals_count`";
        }
    },
    }
